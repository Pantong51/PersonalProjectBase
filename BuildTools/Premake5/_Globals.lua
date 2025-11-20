local M = {}

M.ROOT = os.getcwd()

function M.NormalizeArchLabel(arch)
    arch = (arch or ""):lower()
    if     arch == "x86_64" or arch == "amd64" or arch == "win64" then return "x64"
    elseif arch == "x86"    or arch == "win32"                     then return "x86"
    elseif arch == "arm64"  or arch == "aarch64"                   then return "arm64"
    end
    return arch
end

function M.Rmdir(dir)
    if os.isdir(dir) then
        print("Removing " .. dir)
        os.rmdir(dir)
    end
end


function M.QuoteIfNeeded(path)
    return '"' .. path .. '"'
end

function M.DetectDefaultBuildPlatform()
    local h = os.host()
    if h == "windows" then return "Windows"
    --elseif h == "linux" then return "Linux"
    end
    return "Windows"
end

return M