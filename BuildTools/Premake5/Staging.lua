local Global = require "_Globals"
local ToolChains = require "ToolChains"

local S = {}

function S.CopyFileIfMatches(dstRoot, f)
    local ext = path.getextension(f):lower()
    if  ext == ".exe" or ext == ".dll"   or ext == ".pdb"
        or ext == ".lib" or ext == ".a"     or ext == ".so"
        or ext == ".dylib" or ext == ".exp" or ext == ".ilk"
        or ext == ".json"
        or ext == ".h"  or ext == ".hpp" or ext == ".inl" then
        local dst = path.join(dstRoot, path.getname(f))
        os.copyfile(f, dst)
    end
end

function S.CopySourceHeaderFiles(dstFolder, srcFolder, ext)
    local filePattern = "**" .. ext 
    for _, file in ipairs(os.matchfiles(path.join(srcFolder, filePattern))) do
        local rel = path.getrelative("Source", file)
        local dst = path.join(dstFolder, rel)
        os.mkdir(path.getdirectory(dst))
        os.copyfile(file, dst)
    end
end

function S.StageArtifacts(cfg, plat)
    local custom = _OPTIONS["stage-dir"]
    local archOpt = _OPTIONS["arch"]
    plat = plat or Global.DetectDefaultBuildPlatform()

    local candidates = {}
    if archOpt then table.insert(candidates, Global.NormalizeArchLabel(archOpt)) end
    table.insert(candidates, WORKSPACE_ARCH)
    table.insert(candidates, "x86_64")
    table.insert(candidates, "x64")

    local root = nil
    for _, a in ipairs(candidates) do
        local try = path.join("Builds", "bin", cfg, plat, a)
        if os.isdir(try) then
            root = try
            break
        end
    end

    if not root then
        print(string.format("StageArtifacts: No build output found under Builds/bin/%s/%s.", cfg, archOpt))
        return
    end

    local dstRoot = custom and path.getabsolute(custom) or path.join("Artifacts", plat, cfg)
    local dstInclude = path.join(dstRoot, "include")
    os.mkdir(path.getdirectory(dstRoot))
    os.mkdir(dstRoot)
    os.mkdir(dstInclude)

    print(("Staging Artifacts Here- %s"):format(dstRoot))
    print(("Looking in build output root: %s"):format(root))

    for _, prjdir in ipairs(os.matchdirs(path.join(root, "*"))) do
        for _, f in ipairs(os.matchfiles(path.join(prjdir, "**", "*.*"))) do
            S.CopyFileIfMatches(dstRoot, f)
        end
        for _, f in ipairs(os.matchfiles(path.join(prjdir, "*.*"))) do
            S.CopyFileIfMatches(dstRoot, f)
        end
    end

    for _, hdr in ipairs(os.matchdirs(path.join("Source", "*"))) do
        S.CopySourceHeaderFiles(dstInclude, hdr, ".h")
        S.CopySourceHeaderFiles(dstInclude, hdr, ".hpp")
        S.CopySourceHeaderFiles(dstInclude, hdr, ".inl")
    end
end

function S.Clean()
    os.remove("*.sln*")
    os.remove("*.vcxproj*")
    os.remove("*csproj*")
    Global.Rmdir("Builds")
    Global.Rmdir("bin")
    Global.Rmdir("bin-int")
    os.execute(('attrib -R "%s" /S /D'):format("Artifacts"))
    Global.Rmdir("Artifacts")
    for _, f in ipairs(os.matchfiles("**.vcxproj*")) do
        os.remove(f)
    end
    for _, f in ipairs(os.matchfiles("**.csproj*")) do
        os.remove(f)
    end
        print("Clean Complete")
end

return S