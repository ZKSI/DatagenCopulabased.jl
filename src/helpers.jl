lefttail(v1::Vector{T}, v2::Vector{T}, α::T = 0.002) where T <: AbstractFloat =
        sum((v1 .< α) .* (v2 .< α))./(length(v1)*α)

 righttail(v1::Vector{T}, v2::Vector{T}, α::T = 0.998) where T <: AbstractFloat =
         sum((v1 .> α) .* (v2 .> α))./(length(v1)*(1-α))


function ρ2θ(ρ::Union{Float64, Int}, copula::String)
  if copula == "gumbel"
    return 1/(1-2*asin(ρ)/pi)
  elseif copula == "clayton"
    return 4*asin(ρ)/(pi-2*asin(ρ))
  elseif copula == "frank"
    return 1/0.25*tan(ρ/0.7)
  elseif copula == "amh"
    return AMHθ(ρ)
  else
  return 0.
  end
end

τ2λ₁₂(τ::Float64, λ₁::Float64, λ₂::Float64) = (λ₁+λ₂)*τ/(1-τ)


function AMHθ(ρ::Union{Float64, Int})
  if ρ >= 0.5
    return 0.999999
  elseif -0.3 < ρ <0.5
    function f1!(θ, fvec)
      fvec[1] = sin(pi/2*(1 - 2*(*(1-θ[1])*(1-θ[1])log(1-θ[1]) + θ[1])/(3*θ[1]^2)))-ρ
    end
    return nlsolve(f1!, [ρ]).zero[1]
  end
end


function logseriescdf(p::Float64)
  cdfs = [0.]
  for i in 1:100000000
    @inbounds push!(cdfs, cdfs[i]-(p^i)/(i*log(1-p)))
    if cdfs[i] ≈ 1.0
      return cdfs
    end
  end
  cdfs
end

function logseriesquantile(v::Vector{Float64}, p::Float64)
  w = logseriescdf(p)
  [findlast(w .< b) for b in v]
end
