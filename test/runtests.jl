using Base.Test
using DatagenCopulaBased
using Distributions
using HypothesisTests
using StatsBase

import DatagenCopulaBased: rand2cop, bivariatecopulamix, fncopulagen
import DatagenCopulaBased: logseriescdf, logseriesquantile, levyel, levygen, tiltedlevygen
import DatagenCopulaBased: Ginv, InvlaJ, sampleInvlaJ, elInvlaF, nestedfrankgen
import DatagenCopulaBased: getV0, phi
import DatagenCopulaBased: testθ, useρ, useτ, testbivθ, usebivρ
import DatagenCopulaBased: τ2λ, moρ2τ, norm2unifind
import DatagenCopulaBased: dilog, Debye, frankτ2θ, τ2θ, AMHτ2θ, Ccl, Cg
import DatagenCopulaBased: gumbelθ2ρ, claytonθ2ρ, gumbelρ2θ, claytonρ2θ, frankρ2θ, ρ2θ, AMHρ2θ
import DatagenCopulaBased: mocopula, copulagen
import DatagenCopulaBased: g2tsubcopula!, nestedcopulag, testnestedθϕ, nestedstep
import DatagenCopulaBased: findsimilar, getclust, makeind

include("tailtest.jl")
include("archcopulatests.jl")
include("chaincopulastests.jl")
include("nestedarchcoptest.jl")
include("univdatagentests.jl")
include("subcopulastests.jl")
include("copulatests.jl")
