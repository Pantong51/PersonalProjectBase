newoption {
    trigger = "cfg",
    value = "CONFIG",
    description = "Configuration to build (Development or Shipping). Defaults to Development."
}

newoption {
    trigger = "prj",
    value = "PROJECT",
    description = "Project name to build (use with buildproj)."
}

newoption {
    trigger = "arch",
    value = "ARCH",
    description = "Architexture to build (x64 by default)."
}

newoption {
    trigger = "msbuild",
    value = "PATH",
    description = "Override full path to MSBuild.exe (windows only)."
}

newoption {
    trigger = "stage",
    description = "Stages files after successful build."
}

newoption {
    trigger = "stage-dir",
    value = "PATH",
    description = "Override staging directory (default Artifacts/<cfg>)."
}

newoption {
    trigger = "plat",
    value = "PLATFORM",
    description = "Premake platform to build (Window, Linux, iOS). Default = host platform"
}