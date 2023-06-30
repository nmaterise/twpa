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

# Ipp = 10^.(log10(1.e-9), log10(1.9e-5), 25)
# for Ip in Ipp
#     # Ip=1.85e-6
#     sources = [(mode=(1,),port=1,current=Ip)]
#     
#     # Sweep the current
#     @time rpm = hbsolve(ws, wp, sources, Nmodulationharmonics,
#         Npumpharmonics, circuit, circuitdefs)
# end
# Ipp = 10^.(log10(1.e-9), log10(1.9e-5), 25)
# for Ip in Ipp
Ip=1.85e-6
sources = [(mode=(1,),port=1,current=Ip)]

# Sweep the current
@time rpm = hbsolve(ws, wp, sources, Nmodulationharmonics,
    Npumpharmonics, circuit, circuitdefs)
# end

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

# One last test for exit
is_hbsolve_done = true
@test is_hbsolve_done

p1=plot(ws/(2*pi*1e9),
    10*log10.(abs2.(rpm.linearized.S(
            outputmode=(0,),
            outputport=2,
            inputmode=(0,),
            inputport=1,
            freqindex=:),
    )),
    ylim=(-40,30),label="S21",
    xlabel="Signal Frequency (GHz)",
    legend=false,
    left_margin=20mm,
    bottom_margin=10mm,
    ylabel="dB");

p2=plot(ws/(2*pi*1e9),
    rpm.linearized.QE((0,),2,(0,),1,:)./rpm.linearized.QEideal((0,),2,(0,),1,:),    
    ylim=(0,1.05),
    legend=false,
    left_margin=20mm,
    bottom_margin=10mm,
    ylabel="QE/QE_ideal",xlabel="Signal Frequency (GHz)");

p3=plot(ws/(2*pi*1e9),
    10.0 .* log10.(abs2.(gain)),
    ylabel="Gain (dB)",
    xlabel="Signal Frequency (GHz)",
    left_margin=20mm,
    bottom_margin=10mm,
    legend=false);

# Write figures
savefig(p1, "$(fignameprefix)_S21.png")
savefig(p2, "$(fignameprefix)_QE.png")
savefig(p3, "$(fignameprefix)_gain.png")
is_fig_done = true
@test is_fig_done
