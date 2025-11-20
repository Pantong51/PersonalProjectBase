local Global     = require "_Globals"
local ToolChains = require "ToolChains"
local Staging    = require "Staging"
local Actions    = require "Actions"
local Options    = require "Options"

local WORKSPACE_ARCH = "x64"
if _OPTIONS["arch"] then
    WORKSPACE_ARCH = Global.NormalizeArchLabel(_OPTIONS["arch"])
else
    WORKSPACE_ARCH = Global.NormalizeArchLabel("x64")
end

local ROOT = os.getcwd()

workspace "Project"

    configurations
    {
        "Development",
        "Debug",
        "Shipping"
    }

    platforms
    {
        "Windows",
    }

    filter "platforms:Windows"
        system "windows"
        architecture "x64"

    filter {}

    function SetupDefaultOutputDirs()
        targetdir (ROOT .. "/Builds/bin/%{cfg.buildcfg}/%{cfg.platform}/" .. WORKSPACE_ARCH .. "/%{prj.name}")
        objdir    (ROOT .. "/Builds/bin-int/%{cfg.buildcfg}/%{cfg.platform}/" .. WORKSPACE_ARCH .. "/%{prj.name}")
    end

IncludeDir = {}
IncludeDir["spdlog"] = ROOT .. "/Source/ThirdParty/spdlog"
IncludeDir["Catch2"] = ROOT .. "/Source/ThirdParty/Catch2"

group "Libraries"
    include "Buildscripts/Core-Static.lua"
group "Tests"
    include "Buildscripts/Core-Tests.lua"
group "Tools"
    include "Buildscripts/Core-CLI.lua"

--group "Documentation"