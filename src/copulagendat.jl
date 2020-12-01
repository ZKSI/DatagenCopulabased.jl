

# Old implemnetations

gausscopulagen(t::Int, Σ::Matrix{T}) where T <: Real = simulate_copula(t, Gaussian_cop(Σ))

tstudentcopulagen(t::Int, Σ::Matrix{T}, ν::Int) where T <: Real = simulate_copula(t, Student_cop(Σ, ν))

frechetcopulagen(t::Int, args...) = simulate_copula(t, Frechet_cop(args...))

marshallolkincopulagen(t::Int, λ::Vector{T}) where T <: Real = simulate_copula(t, Marshall_Olkin_cop(λ))


function archcopulagen(t::Int, n::Int, θ::Real, copula::String;
                                                              rev::Bool = false,
                                                              cor::String = "")

    args = (n, θ)
    if cor == "Kendall"
        args = (n, θ, KendallCorrelation)
    elseif cor == "Spearman"
        args = (n, θ, SpearmanCorrelation)
    end
    if copula == "gumbel"
        if !rev
            simulate_copula(t, Gumbel_cop(args...))
        else
            simulate_copula(t, Gumbel_cop_rev(args...))
        end
    elseif copula == "clayton"
        if !rev
            simulate_copula(t, Clayton_cop(args...))
        else
            simulate_copula(t, Clayton_cop_rev(args...))
        end
    elseif copula == "amh"
        if !rev
            simulate_copula(t, AMH_cop(args...))
        else
            simulate_copula(t, AMH_cop_rev(args...))
        end
    elseif copula == "frank"
           simulate_copula(t, Frank_cop(args...))

    else
        throw(AssertionError("$(copula) copula is not supported"))
    end
end


function nestedarchcopulagen(t::Int, n::Vector{Int}, ϕ::Vector{T}, θ::T, copula::String, m::Int = 0) where T <: Real
    if copula == "gumbel"
        children = [Gumbel_cop(n[i], ϕ[i]) for i in 1:length(n)]
        simulate_copula(t, Nested_Gumbel_cop(children, m, θ))
    elseif copula == "clayton"
        children = [Clayton_cop(n[i], ϕ[i]) for i in 1:length(n)]
        simulate_copula(t, Nested_Clayton_cop(children, m, θ))
    elseif copula == "amh"
        children = [AMH_cop(n[i], ϕ[i]) for i in 1:length(n)]
        simulate_copula(t, Nested_AMH_cop(children, m, θ))
    elseif copula == "frank"
        children = [Frank_cop(n[i], ϕ[i]) for i in 1:length(n)]
        simulate_copula(t, Nested_Frank_cop(children, m, θ))
    else
        throw(AssertionError("$(copula) copula is not supported"))
    end
end


function nestedarchcopulagen(t::Int, n::Vector{Vector{Int}}, Ψ::Vector{Vector{T}},
                                                             ϕ::Vector{T}, θ::T,
                                                             copula::String = "gumbel") where T <: Real

  copula == "gumbel" || throw(AssertionError("generator supported only for gumbel familly"))
  length(n) == length(Ψ) == length(ϕ) || throw(AssertionError("parameter vector must be of the sam size"))
  parents = Nested_Gumbel_cop{T}[]
  for i in 1:length(n)
      length(n[i]) == length(Ψ[i]) || throw(AssertionError("parameter vector must be of the sam size"))
      child = [Gumbel_cop(n[i][j], Ψ[i][j])  for j in 1:length(n[i])]
      push!(parents, Nested_Gumbel_cop{T}(child, 0, ϕ[i]))
  end
  simulate_copula(t, Double_Nested_Gumbel_cop(parents, θ))
end


function nestedarchcopulagen(t::Int, θ::Vector{T}, copula::String = "gumbel") where T <: Real

    copula == "gumbel" || throw(AssertionError("generator supported only for gumbel familly"))
    simulate_copula(t, Hierarchical_Gumbel_cop(θ))
end


function chainfrechetcopulagen(t::Int, α::Vector{Real}, β::Vector{Real} = zero(α))
    simulate_copula(t, Chain_of_Frechet(α, β))
end


function chaincopulagen(t::Int, θ::Vector{Real}, copula::Union{Vector{String}, String};
                                        rev::Bool = false, cor::String = "")
    args = (θ, copula)
    if cor != ""
        args = (θ, copula, cor)
    end

    if rev == false
      return simulate_copula(t, Chain_of_Archimedeans(args...))
    else
      return 1 .- simulate_copula(t, Chain_of_Archimedeans(args...))
    end
 end
