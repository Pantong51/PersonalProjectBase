project "Core-Tests"
  location "%{wks.location}/Source/Core-Tests"
  kind "ConsoleApp"
  language "C++"
  staticruntime "on"
  floatingpoint "Fast"
  exceptionhandling "Off"
  vectorextensions "SSE2"
  cppdialect "C++20"

  SetupDefaultOutputDirs()
  characterset "MBCS"

  removeplatforms 
  {
    "Linux",
    "Android"
  }

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
    "%{wks.location}/Source/ThirdParty/Catch2/**.hpp",
    "%{wks.location}/Source/ThirdParty/Catch2/**.cpp",
  }

  includedirs
  {
    "%{wks.location}/Source/Core",
    "%{wks.location}/Source/%{prj.name}",
    "%{IncludeDir.spdlog}/include",
    "%{IncludeDir.Catch2}",
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
      "DEBUG",
      "CORE_DEV=Development"
    }
    runtime "Debug"
    symbols "On"

  filter "configurations:Debug"
    defines
    {
      "_DEBUG",
      "DEBUG",
      "CORE_DEBUG=Debug"
    }
    runtime "Debug"
    symbols "On"
    
  filter "configurations:Shipping"
    defines
    {
      "NDEBUG",
      "CORE_SHIP=Shipping"
    }
    runtime "Release"
    symbols "Off"
    optimize "Full"
