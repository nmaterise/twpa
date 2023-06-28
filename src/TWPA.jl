# This is a test
using JosephsonCircuits
using Plots

@variables Rleft Rright Lj Cg Cc Cr Lr Cj

weightwidth = 745
weight = (n,Nnodes,weightwidth) -> exp(-(n - Nnodes/2)^2/(weightwidth)^2)
Nj=2000
pmrpitch = 8
jidx = 2

# define the circuit components
circuit = Tuple{String,String,String,Num}[]

# port on the left side
push!(circuit,("P$(1)_$(0)","1","0",1))
push!(circuit,("R$(1)_$(0)","1","0",Rleft))

#first half cap to ground
push!(circuit,("C$(1)_$(0)","1","0",Cg/2*weight(1-0.5,Nj,weightwidth)))

#middle caps and jj's
push!(circuit,("Lj$(1)_$(2)","1","2",Lj*weight(1,Nj,weightwidth)))
push!(circuit,("C$(1)_$(2)","1","2",Cj/weight(1,Nj,weightwidth)))
print("jidx: $(jidx)")

for i = 2:Nj-1

    if mod(i,pmrpitch) == pmrpitch÷2

        # make the jj cell with modified capacitance to ground
        push!(circuit,("C$(jidx)_$(0)","$(jidx)","$(0)",
                       (Cg-Cc)*weight(i-0.5,Nj,weightwidth)))
        push!(circuit,("Lj$(jidx)_$(jidx+2)","$(jidx)","$(jidx+2)",
                       Lj*weight(i,Nj,weightwidth)))
        push!(circuit,("C$(jidx)_$(jidx+2)","$(jidx)","$(jidx+2)",
                       Cj/weight(i,Nj,weightwidth)))

        #make the pmr
        push!(circuit,("C$(jidx)_$(jidx+1)","$(jidx)","$(jidx+1)",
                       Cc*weight(i-0.5,Nj,weightwidth)))
        push!(circuit,("C$(jidx+1)_$(0)","$(jidx+1)","$(0)",Cr))
        push!(circuit,("L$(jidx+1)_$(0)","$(jidx+1)","$(0)",Lr))

        # increment the index
        jidx+=1
    else
        push!(circuit,("C$(jidx)_$(0)","$(jidx)","$(0)",
                       Cg*weight(i-0.5,Nj,weightwidth)))
        push!(circuit,("Lj$(jidx)_$(jidx+1)","$(jidx)","$(jidx+1)",
                       Lj*weight(i,Nj,weightwidth)))
        push!(circuit,("C$(jidx)_$(jidx+1)","$(jidx)","$(jidx+1)",
                       Cj/weight(i,Nj,weightwidth)))
    end

    # increment the index
    jidx+=1

end

#last jj
push!(circuit,("C$(jidx)_$(0)","$(jidx)","$(0)",
               Cg/2*weight(Nj-0.5,Nj,weightwidth)))
push!(circuit,("R$(jidx)_$(0)","$(jidx)","$(0)",Rright))
push!(circuit,("P$(jidx)_$(0)","$(jidx)","$(0)",2))

circuitdefs = Dict(
    Rleft => 50.0,
    Rright => 50.0,
    Lj => IctoLj(1.75e-6),
    Cg => 76.6e-15,
    Cc => 40.0e-15,
    Cr =>  1.533e-12,
    Lr => 2.47e-10,
    Cj => 40e-15,
)

ws=2*pi*(1.0:0.1:14)*1e9
wp=(2*pi*7.9*1e9,)
Ip=1.1e-6
sources = [(mode=(1,),port=1,current=Ip)]
Npumpharmonics = (20,)
Nmodulationharmonics = (10,)

@time floquet = hbsolve(ws, wp, sources, Nmodulationharmonics,
    Npumpharmonics, circuit, circuitdefs)

p1=plot(ws/(2*pi*1e9),
    10*log10.(abs2.(floquet.linearized.S((0,),2,(0,),1,:))),
    ylim=(-40,30),label="S21",
    xlabel="Signal Frequency (GHz)",
    legend=:bottomright,
    title="Scattering Parameters",
    ylabel="dB")

plot!(ws/(2*pi*1e9),
    10*log10.(abs2.(floquet.linearized.S((0,),1,(0,),2,:))),
    label="S12",
    )

plot!(ws/(2*pi*1e9),
    10*log10.(abs2.(floquet.linearized.S((0,),1,(0,),1,:))),
    label="S11",
    )

plot!(ws/(2*pi*1e9),
    10*log10.(abs2.(floquet.linearized.S((0,),2,(0,),2,:))),
    label="S22",
    )

p2=plot(ws/(2*pi*1e9),
    floquet.linearized.QE((0,),2,(0,),1,:)./
    floquet.linearized.QEideal((0,),2,(0,),1,:),
    ylim=(0.99,1.001),
    title="Quantum efficiency",legend=false,
    ylabel="QE/QE_ideal",xlabel="Signal Frequency (GHz)");

p3=plot(ws/(2*pi*1e9),
    10*log10.(abs2.(floquet.linearized.S(:,2,(0,),1,:)')),
    ylim=(-40,30),label="S21",
    xlabel="Signal Frequency (GHz)",
    legend=false,
    title="All idlers",
    ylabel="dB")


p4=plot(ws/(2*pi*1e9),
    1 .- floquet.linearized.CM((0,),2,:),
    legend=false,title="Commutation \n relation error",
    ylabel="Commutation \n relation error",xlabel="Signal Frequency (GHz)");

plot(p1, p2, p3,p4,layout = (2, 2))
