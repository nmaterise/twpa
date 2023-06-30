"""
$(SIGNATURES)

Functions to manage the construction of uniform TWPA circuits

"""

"""
$(SIGNATURES)

Returns the uniform TWPA circuit from

Macklin et al., Science 350, 307 (2015)

Arguments:
=========

*   Nj::Int64           number of junctions
*   pmrpitch::Int64      

Returns:
=======

*  circuit::            circuit for hbsolve to act on
*  circuitdefs::Dict    dictionary of circuit parameters

"""
function twpa_uniform_circuit(circuit_params::Dict, Nj::Int64, pmrpitch::Int64)
    # Setup variable names
    @variables Rleft Rright Cg Lj Cj Cc Cr Lr
    circuit = Tuple{String,String,String,Num}[]
    
    # port on the input side
    push!(circuit,("P$(1)_$(0)","1","0",1))
    push!(circuit,("R$(1)_$(0)","1","0",Rleft))
    
    #first half cap to ground
    push!(circuit,("C$(1)_$(0)","1","0",Cg/2))
    #middle caps and jj's
    push!(circuit,("Lj$(1)_$(2)","1","2",Lj)) 
    push!(circuit,("C$(1)_$(2)","1","2",Cj)) 
    
    j=2
    for i = 2:Nj-1
        
        if mod(i,pmrpitch) == pmrpitch÷2
    
            # make the jj cell with modified capacitance to ground
            push!(circuit,("C$(j)_$(0)","$(j)","$(0)",Cg-Cc))
            push!(circuit,("Lj$(j)_$(j+2)","$(j)","$(j+2)",Lj))
    
            push!(circuit,("C$(j)_$(j+2)","$(j)","$(j+2)",Cj))
            
            #make the pmr
            push!(circuit,("C$(j)_$(j+1)","$(j)","$(j+1)",Cc))
            push!(circuit,("C$(j+1)_$(0)","$(j+1)","$(0)",Cr))
            push!(circuit,("L$(j+1)_$(0)","$(j+1)","$(0)",Lr))
            
            # increment the index
            j+=1
        else
            push!(circuit,("C$(j)_$(0)","$(j)","$(0)",Cg))
            push!(circuit,("Lj$(j)_$(j+1)","$(j)","$(j+1)",Lj))
            push!(circuit,("C$(j)_$(j+1)","$(j)","$(j+1)",Cj))
        end
        
        # increment the index
        j+=1
    
    end
    
    #last jj
    push!(circuit,("C$(j)_$(0)","$(j)","$(0)",Cg/2))
    push!(circuit,("R$(j)_$(0)","$(j)","$(0)",Rright))
    # port on the output side
    push!(circuit,("P$(j)_$(0)","$(j)","$(0)",2))
    
    # Set the circuit definitions
    circuitdefs = Dict(
        Lj =>     circuit_params["Lj"],  # IctoLj(3.4e-6),
        Cg =>     circuit_params["Cg"],  # 45.0e-15,
        Cc =>     circuit_params["Cc"],  # 30.0e-15,
        Cr =>     circuit_params["Cr"],  #  2.8153e-12,
        Lr =>     circuit_params["Lr"],  # 1.70e-10,
        Cj =>     circuit_params["Cj"],  # 55e-15,
        Rleft =>  circuit_params["Rleft"],  # 50.0,
        Rright => circuit_params["Rright"]  #  50.0,
    )

    return circuit, circuitdefs
    
end


"""
$(SIGNATURES)

Returns the Floquet TWPA circuit from

K. Peng et al., PRX Quantum 3, 020306 (2022) 

Arguments:
=========

*   Nj::Int64           number of junctions
*   pmrpitch::Int64     phase matching resonator pitch
*   weightwidth::Int64  weight applied

Returns:
=======

*  circuit::            circuit for hbsolve to act on
*  circuitdefs::Dict    dictionary of circuit parameters

"""
function twpa_floquet_circuit(Nj::Int64, pmrpitch::Int64, weightwidth::Int64)

    @variables Rleft Rright Lj Cg Cc Cr Lr Cj
    
    weight = (n,Nnodes,weightwidth) -> exp(-(n - Nnodes/2)^2/(weightwidth)^2)
    
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
        
    j=2
    for i = 2:Nj-1
        
        if mod(i,pmrpitch) == pmrpitch÷2
    
            # make the jj cell with modified capacitance to ground
            push!(circuit,("C$(j)_$(0)","$(j)","$(0)",
                           (Cg-Cc)*weight(i-0.5,Nj,weightwidth)))
            push!(circuit,("Lj$(j)_$(j+2)","$(j)","$(j+2)",
                           Lj*weight(i,Nj,weightwidth)))
            push!(circuit,("C$(j)_$(j+2)","$(j)","$(j+2)",
                           Cj/weight(i,Nj,weightwidth)))
            
            #make the pmr
            push!(circuit,("C$(j)_$(j+1)","$(j)","$(j+1)",
                           Cc*weight(i-0.5,Nj,weightwidth)))
            push!(circuit,("C$(j+1)_$(0)","$(j+1)","$(0)",Cr))
            push!(circuit,("L$(j+1)_$(0)","$(j+1)","$(0)",Lr))
            
            # increment the index
            j+=1
        else
            push!(circuit,("C$(j)_$(0)","$(j)","$(0)",
                           Cg*weight(i-0.5,Nj,weightwidth)))
            push!(circuit,("Lj$(j)_$(j+1)","$(j)","$(j+1)",
                           Lj*weight(i,Nj,weightwidth)))
            push!(circuit,("C$(j)_$(j+1)","$(j)","$(j+1)",
                           Cj/weight(i,Nj,weightwidth)))
        end
        
        # increment the index
        j+=1
    
    end
    
    #last jj
    push!(circuit,("C$(j)_$(0)","$(j)","$(0)",
                   Cg/2*weight(Nj-0.5,Nj,weightwidth)))
    push!(circuit,("R$(j)_$(0)","$(j)","$(0)",Rright))
    push!(circuit,("P$(j)_$(0)","$(j)","$(0)",2))
    
    circuitdefs = Dict(
        Rleft => 50.0,
        Rright => 50.0,
        Lj =>  IctoLj(1.75e-6),
        Cg =>  76.6e-15,
        Cc =>  40.0e-15,
        Cr =>  1.533e-12,
        Lr => 2.47e-10,
        Cj =>  40e-15,
    )  

    return circuit, circuitdefs
    
end
