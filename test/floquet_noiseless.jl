using TWPA
using Plots
using Plots.PlotMeasures
    
# Filename to output
fignameprefix = "../figs/twpa_floquet_peng_noiseless_2022"

# Compute the circuit
Nj          = 2000
pmrpitch    = 8
weightwidth = 745

circuit, circuitdefs = twpa_floquet_circuit(Nj, pmrpitch, weightwidth)

# One last test for exit
is_circuit_done = true
@test is_circuit_done

ws=2*pi*(1.0:0.1:14)*1e9
wp=(2*pi*7.9*1e9,)
Npumpharmonics = (20,)
Nmodulationharmonics = (10,)

Ip=0
sources = [(mode=(1,),port=1,current=Ip)]
@time floquet0 = hbsolve(ws, wp, sources, Nmodulationharmonics,
    Npumpharmonics, circuit, circuitdefs)

Ip=1.1e-6
sources = [(mode=(1,),port=1,current=Ip)]
@time floquet = hbsolve(ws, wp, sources, Nmodulationharmonics,
    Npumpharmonics, circuit, circuitdefs)

gain = floquet.linearized.S((0,),2,(0,),1,:) .-
       floquet0.linearized.S((0,),2,(0,),1,:)

# One last test for exit
is_hbsolve_done = true
@test is_hbsolve_done

p1=plot(ws/(2*pi*1e9),
    10*log10.(abs2.(floquet.linearized.S((0,),2,(0,),1,:))),
    ylim=(-40,30),label="S21",
    xlabel="Signal Frequency (GHz)",
    legend=false,
    left_margin=20mm,
    bottom_margin=15mm,
    ylabel="S21 (dB)")

p2=plot(ws/(2*pi*1e9),
    floquet.linearized.QE((0,),2,(0,),1,:)./
    floquet.linearized.QEideal((0,),2,(0,),1,:),    
    ylim=(0.99,1.001),
    legend=false,
    left_margin=20mm,
    bottom_margin=15mm,
    ylabel="QE/QE_ideal",xlabel="Signal Frequency (GHz)");

p3=plot(ws/(2*pi*1e9),
    10*log10.(abs2.(gain)),
    xlabel="Signal Frequency (GHz)",
    legend=false,
    left_margin=20mm,
    bottom_margin=15mm,
    ylabel="Gain (dB)")

# Write figures
savefig(p1, "$(fignameprefix)_S21.png")
savefig(p2, "$(fignameprefix)_QE.png")
savefig(p3, "$(fignameprefix)_gain.pdf")
is_fig_done = true
@test is_fig_done
