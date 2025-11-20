project "Core-Static"
  location "%{wks.location}/Source/Core"
  kind "StaticLib"
  language "c++"
  staticruntime "on"
  floatingpoint "Fast"
  exceptionhandling "Off"
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
    "%{wks.location}/Source/ThirdParty/spdlog/include/**.h",
    "%{wks.location}/Source/ThirdParty/spdlog/include/**.hpp",
  }

  includedirs
  {
    "%{wks.location}/Source/Core",
    "%{IncludeDir.spdlog}/include",
  }

  defines
  {
    "SPDLOG_NO_EXCEPTIONS",
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
      "SPDLOG_USE_STD_FORMAT",
      "CORE_WINDOWS"
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
    