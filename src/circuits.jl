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
function twpa_uniform_circuit(Nj::Int64, pmrpitch::Int64)
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
        Lj => IctoLj(3.4e-6),
        Cg => 45.0e-15,
        Cc => 30.0e-15,
        Cr =>  2.8153e-12,
        Lr => 1.70e-10,
        Cj => 55e-15,
        Rleft => 50.0,
        Rright => 50.0,
    )

    return circuit, circuitdefs
    
end
