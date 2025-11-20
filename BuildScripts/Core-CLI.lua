project "Core-CLI"
  location "%{wks.location}/Source/Core-CLI"
  kind "ConsoleApp"
  language "C++"
  staticruntime "on"
  floatingpoint "Fast"

  vectorextensions "SSE2"
  cppdialect "C++20"

  SetupDefaultOutputDirs()
  characterset "MBCS"

  flags
  {
    "NoBufferSecurityCheck"
  }

  files
  {
    "%{wks.location}/Source/Core/**.h",
    "%{wks.location}/Source/Core/**.cpp",
    "%{wks.location}/Source/%{prj.name}/**.h",
    "%{wks.location}/Source/%{prj.name}/**.cpp",
    "%{wks.location}/Source/ThirdParty/spdlog/include/**.h",
    "%{wks.location}/Source/ThirdParty/spdlog/include/**.hpp",
  }

  includedirs
  {
    "%{wks.location}/Source/Core",
    "%{wks.location}/Source/%{prj.name}",
    "%{IncludeDir.spdlog}/include",
  }

  links
  {    
    "Core-Static",
  }

  defines
  {
    "SPDLOG_NO_EXCEPTIONS",
    "SPDLOG_USE_STD_FORMAT",
    "FMT_UNICODE=0",
  }

  disablewarnings
  {
    
  }

  postbuildcommands
  {

  }

  filter "system:windows"
    staticruntime "on"
    defines
    {
      "_SCL_SECURE_NO_WARNINGS",
      "_CRT_SECURE_NO_WARNINGS",
    }
    
    buildoptions
    {
      "/GT",
      "/Oi",
      "/GR-",
      "/Ot",
      "/Ob2"
    }
    
  filter "configurations:Development"
    defines
    {
      "_DEBUG",
      "DEBUG"
    }
    runtime "Debug"
    symbols "On"

  filter "configurations:Debug"
    defines
    {
      "_DEBUG",
      "DEBUG"
    }
    runtime "Debug"
    symbols "On"
    
  filter "configurations:Shipping"
    defines
    {
      "NDEBUG"
    }
    runtime "Release"
    symbols "Off"
    optimize "Full"