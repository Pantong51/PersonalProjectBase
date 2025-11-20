local Global = require "_Globals"
local T = {}

local HostDefaultAction = {
    windows = "vs2022",
    --linux = "gmake2",
    --macosx = "xcode4",
}

local WS_NAME = "Core"
local SLN_NAME = WS_NAME .. ".sln"
local XCODEPROJ_NAME = WS_NAME .. ".xcodeproj"

local function FindMSBuild()
    local opt = _OPTIONS["msbuild"]
    if opt and #opt > 0 and os.isfile(opt) then
        return opt
    end

    local pf86 = os.getenv("ProgramFiles(x86)")
    local pf64 = os.getenv("ProgramW6432") or os.getenv("ProgramFiles")

    local function add_candidates(root, arr)
        if not root then return end
        local versions = { "2022", "2019", "2017" }
        local editions = { "BuildTools", "Enterprise", "Professional", "Community" }
        for _, v in ipairs(versions) do
            for _, e in ipairs(editions) do
                arr[#arr+1] = string.format('%s/Microsoft Visual Studio/%s/%s/MSBuild/Current/Bin/MSBuild.exe', root, v, e)
            end
        end
    end

    local candidates = {}
    add_candidates(pf64, candidates)
    add_candidates(pf86, candidates)

    for _, c in ipairs(candidates) do
        if os.isfile(c) then
            return c
        end
    end

    local vswhere = (pf86 or "C:/Program Files (x86)") .. "/Microsoft Visual Studio/Installer/vswhere.exe"
    if os.isfile(vswhere) then
        local tmp = os.tmpname()
        local cmd = string.format('"%s" -latest -requires Microsoft.Component.MSBuild -find MSBuild\\**\\Bin\\MSBuild.exe > "%s"', vswhere, tmp)
        os.execute(cmd)
        local f = io.open(tmp, "r")
        if f then
            local p = f:read("*l")
            f:close()
            os.remove(tmp)
            if p and #p > 0 and os.isfile(p) then
                return p
            end
        end
    end

    print("Warning: Could not locate MSBuild.exe")
    return nil
end

function T.DefaultActionForHost()
    return HostDefaultAction[os.host()] or "vs2022"
end

function T.RunCmd(cmd)
    print(">> " .. cmd)
    local ok, why, code = os.execute(os.host() == "windows" and ('cmd /c "'..cmd..'"') or cmd)
    if not ok or code ~= 0 then
        error(("Command failed (%s, %d): %s"):format(tostring(why), code or -1, cmd), 0)
    end
end

function T.BuildMSVC(cfg, prj, plat)
    local msbuild_path = FindMSBuild()
    local slnPlat = plat
    local projClause = ""

    if prj and #prj > 0 then
        projClause = string.format(' /t:%s:Build', prj)
    end

    local slnAbs = path.getabsolute(SLN_NAME)
    local cmd
    if msbuild_path then
        cmd = string.format('%s %s /m /p:Configuration=%s;Platform=%s%s',
            Global.QuoteIfNeeded(msbuild_path), Global.QuoteIfNeeded(slnAbs), cfg, slnPlat, projClause)
    else
        print("WARNING: MSBuild.exe not found; using dotnet msbuild.")
        cmd = string.format('dotnet msbuild %s /m /p:Configuration=%s;Platform=%s%s', Global.QuoteIfNeeded(slnAbs), cfg, slnPlat, projClause)
    end
    
    T.RunCmd(cmd)
end

function T.RestoreNuGet()
    T.RunCmd(('dotnet restore %s'):format(Global.QuoteIfNeeded(SLN_NAME)))

    local cwdRoot = os.getcwd()
    for _, dir in ipairs(os.matchdirs(path.join("Source", "*"))) do
        if os.isdir(dir) then
            print("----- Restoring in " .. dir .. " -----")
            os.chdir(dir)
            local projs = os.matchfiles("*.csproj")
            if #projs == 0 then projs = os.matchfiles("*.vbproj") end

            if #projs > 0 then
                for _, p in ipairs(projs) do
                    T.RunCmd(('dotnet restore %s'):format(Global.QuoteIfNeeded(p)))
                end
            end
        end
        os.chdir(cwdRoot)
    end
    print("----- Finished Restore -----")
end

function T.BuildXcode(cfg, prj)
    local tgt = prj and #prj > 0 and (" -target " .. prj) or ""
    RunCmd(string.format('xcodebuild -project %s -configuration %s%s', XCODEPROJ_NAME, cfg, tgt))
end

function T.BuildHost(cfg, prj, plat)
    plat = plat or _OPTIONS["plat"] or Global.DetectDefaultBuildPlatform()
    if plat == "Windows" then
        T.BuildMSVC(cfg, prj, "Windows")
    elseif plat == "Android" then
        T.BuildMSVC(cfg, prj, "Android")
    --elseif plat == "Linux" then
        --BuildGmake(cfg, prj)
    --elseif plat == "Macosx" then
        --BuildXcode(cfg, prj)
    else
        error("Unsupported build platform: " .. plat, 0)
    end
end

function T.GenerateProjects()
    local act = T.DefaultActionForHost()
    print("Generating project files (" .. act .. ") ...")
    local premakeExe = _PREMAKE_COMMAND
    T.RunCmd(string.format('"%s" %s', premakeExe, act))
end

return T