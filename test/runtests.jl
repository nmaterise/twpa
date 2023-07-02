using SafeTestsets

@time begin
    @time @safetestset "Uniform TWPA Test" begin
        include("uniform.jl")
    end
    @time @safetestset "Floquet TWPA Test" begin
        include("floquet_noiseless.jl")
    end
    @time @safetestset "Uniform Pump Power TWPA Test" begin
        include("uniform_bode.jl")
    end
    # Add a new test below and comment out the above to run only the new code
    # @time @safetestset "My new test is running ..." begin
    #     include("my-new-test.jl")
    # end
end
