# TWPA Design for CMC Superconducting Quantum Workshop

## Directory structure
|Directory | Description|
| -------- | ---------- |
| src/     | source code|
| figs/    | figures    |
| data/    | data files |
| test/    | test source|
## Installation
1. Install Julia (version=1.9): [here](https://julialang.org/downloads/)
2. Install Julia packages from a `bash` command prompt
```bash
# Type "julia"
$julia
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.9.0 (2023-05-07)
 _/ |\__'_|_|_|\__'_|  |
|__/                   |

julia>
# Type "]"
(@v1.9) pkg>
# Type "activate ."
Activating project at `~/twpa`
(TWPA) pkg> add Plots UnicodePlots DocStringExtensions
(TWPA) pkg> add https://github.com/nmaterise/JosephsonCircuits.jl.git#main
(TWPA) pkg> add Reexport SafeTestsets Test
(TWPA) pkg> precompile
(TWPA) pkg> test
``` 

## Adding new scripts to the test/ directory
1. Add a new file to the `test/` directory
2. Add a new line to `test/runtests.jl` in the same format as the others. For
   example, create a file named `test/my-new-test.jl` and add to `runtests.jl`
```julia
# existing code
@time begin
    @time @safetestset "Uniform Pump Power TWPA Test" begin
        include("uniform_bode.jl")
    end
    # Add new test code here 
    @time @safetestset "My new test is running ..." begin
        include("my-new-test.jl")
    end
end
```
