local Global = require "_Globals"
local ToolChains = require "ToolChains"
local Staging = require "Staging"

newaction {
    trigger = "clean",
    description = "Delete all generated files and intermediate build folders",
    execute = function()
        Staging.Clean()
    end
}

newaction {
    trigger = "build",
    description = "Generate project files for host and build one configuration (default Development)",
    execute = function()
        local cfg = _OPTIONS["cfg"] or "Development"
        local plat = _OPTIONS["plat"] or Global.DetectDefaultBuildPlatform()
        ToolChains.GenerateProjects()
        ToolChains.RestoreNuGet()
        ToolChains.BuildHost(cfg, nil, plat)
        print("Build Complete (" .. plat .. "|" .. cfg .. ")")
        local StageOption = _OPTIONS["stage"] ~= nil
        
        if StageOption then
            Staging.StageArtifacts(cfg, plat)
        end
    end
}

local defaultPlats = {"Windows", "Android"}

newaction {
    trigger = "buildall",
    description = "Generate project files for host and build all configurations",
    execute = function()
        ToolChains.GenerateProjects()
        ToolChains.RestoreNuGet()
        configs = {
            "Development",
            "Debug",
            "Shipping"
        }

        local plats = _OPTIONS["plat"] and { _OPTIONS["plat"] } or defaultPlats

        for _, plat in ipairs(plats) do
            for _, cfg in ipairs(configs) do
                print("Building (".. plat .. "|" .. cfg ..")")
                ToolChains.BuildHost(cfg, nil, plat)
                print("Build Complete (" .. plat .. "|" .. cfg .. ")")
                local StageOption = _OPTIONS["stage"] ~= nil
            
                if StageOption then
                    Staging.StageArtifacts(cfg, plat)
                end
            end
        end
    end
}

newaction {
    trigger = "stageall",
    description = "force stageing all",
    execute = function()
        local plats = _OPTIONS["plat"] and { _OPTIONS["plat"] } or defaultPlats
        configs = {
            "Development",
            "Debug",
            "Shipping"
        }
        for _, plat in ipairs(plats) do
            for _, cfg in ipairs(configs) do
                Staging.StageArtifacts(cfg, plat)
            end
        end
    end
}