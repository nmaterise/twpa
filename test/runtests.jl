using SafeTestsets

@time begin
    @time @safetestset "Uniform TWPA Test" begin
        include("uniform.jl")
    end
end
