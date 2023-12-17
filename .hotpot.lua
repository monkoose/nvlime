return {
    compiler = {
        macros = {
            env = "_COMPILER",
            compilerEnv = _G,
        },
    },
    build = {
        {verbose = true, atomic = true},
        {"fnl/**/*macros.fnl", false},
        {"fnl/**/*.fnl", true},
        -- {"fnl/tests/**/*.fnl", function(path)
        --   return path:gsub("fnl/tests", "tests")
        -- end},
        {"after/**/*.fnl", true},
    }
}
