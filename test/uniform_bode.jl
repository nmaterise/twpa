using TWPA
using Plots
using Plots.PlotMeasures
    
# Filename to output
fignameprefix = "../figs/twpa_uniform_macklin_2015"

# Compute the circuit
Nj       = 2048
pmrpitch = 4

circuit_params = Dict(
    "Lj" => IctoLj(3.4e-6),
    "Cg" => 45.0e-15,
    "Cc" => 30.0e-15,
    "Cr" =>  2.8153e-12,
    "Lr" => 1.70e-10,
    "Cj" => 55e-15,
    "Rleft" => 50.0,
    "Rright"=> 50.0,
);
circuit, circuitdefs  = twpa_uniform_circuit(circuit_params, Nj, pmrpitch)

# One last test for exit
is_circuit_done = true
@test is_circuit_done

# Compute the sources
ws = 2*pi*(1.0:0.1:14)*1e9
wp = (2*pi*7.12*1e9,)
Ip = 0
sources = [(mode=(1,),port=1,current=Ip)]
Npumpharmonics = (20,)
Nmodulationharmonics = (10,)

@time rpm_no_current = hbsolve(ws, wp, sources, Nmodulationharmonics,
    Npumpharmonics, circuit, circuitdefs)

# Ipp = 10.0.^(log10(1e-6):0.25:log10(4e-6))
Ipp = 1e-6:0.1e-6:2.1e-6
println("Ipp: $(Ipp)\n")
max_gains = []
for Ip in Ipp
    # Ip=1.85e-6
    print("Ip: $(Ip/1e-6) μA ...")
    local sources = [(mode=(1,),port=1,current=Ip)]
    
    # Sweep the current
    @time rpm = hbsolve(ws, wp, sources, Nmodulationharmonics,
        Npumpharmonics, circuit, circuitdefs)

    gain = rpm.linearized.S(
                outputmode=(0,),
                outputport=2,
                inputmode=(0,),
                inputport=1,
                freqindex=:) .-
    rpm_no_current.linearized.S(
                outputmode=(0,),
                outputport=2,
                inputmode=(0,),
                inputport=1,
                freqindex=:)
    push!(max_gains, maximum(abs2.(gain)))
end

# Ip=1.85e-6
# sources = [(mode=(1,),port=1,current=Ip)]
# 
# # Sweep the current
# @time rpm = hbsolve(ws, wp, sources, Nmodulationharmonics,
#     Npumpharmonics, circuit, circuitdefs)
# # end


# One last test for exit
is_hbsolve_done = true
@test is_hbsolve_done

p1 = plot(Ipp / 1e-6,
    10*log10.(max_gains),
    legend=false,
    left_margin=20mm,
    bottom_margin=10mm,
    linestyle=:solid,
    marker=:circle,
    ylabel="Maximum Gain (dB)",
    xlabel="Pump Current (μA)");

# Write figures
savefig(p1, "$(fignameprefix)_gain_pump.png")
is_fig_done = true
@test is_fig_done
