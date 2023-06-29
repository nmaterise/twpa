using TWPA
using Plots
    
# Filename to output
fignameprefix = "../figs/twpa_uniform_macklin_2015"

# Compute the circuit
Nj       = 2048
pmrpitch = 4
circuit, circuitdefs  = twpa_uniform_circuit(Nj, pmrpitch)

# One last test for exit
is_circuit_done = true
@test is_circuit_done

# Compute the sources
ws=2*pi*(1.0:0.1:14)*1e9
wp=(2*pi*7.12*1e9,)
Ip=1.85e-6
sources = [(mode=(1,),port=1,current=Ip)]
Npumpharmonics = (20,)
Nmodulationharmonics = (10,)

@time rpm = hbsolve(ws, wp, sources, Nmodulationharmonics,
    Npumpharmonics, circuit, circuitdefs)

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
    ylabel="dB");

p2=plot(ws/(2*pi*1e9),
    rpm.linearized.QE((0,),2,(0,),1,:)./rpm.linearized.QEideal((0,),2,(0,),1,:),    
    ylim=(0,1.05),
    legend=false,
    ylabel="QE/QE_ideal",xlabel="Signal Frequency (GHz)");


# Write figures
savefig(p1, "$(fignameprefix)_S21.png")
savefig(p2, "$(fignameprefix)_QE.png")
is_fig_done = true
@test is_fig_done
