using SafeTestsets

@time begin
    # @time @safetestset "Uniform TWPA Test" begin
    #     include("uniform.jl")
    # end
    # @time @safetestset "Floquet TWPA Test" begin
    #     include("floquet_noiseless.jl")
    # end
    @time @safetestset "Uniform Pump Power TWPA Test" begin
        include("uniform_bode.jl")
    end
end
