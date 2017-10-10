α = 0.025

@testset "copula mixture" begin
  srand(43)
  x = copulamixgen(100000, 5, [[1,2]], [[3,4]], [[4,5]])[1];
  @test pvalue(ExactOneSampleKSTest(x[:,1], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,2], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,3], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,4], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,5], Uniform(0,1))) > α
end

@testset "copula mixture" begin
  srand(43)
  x ,s = copulamix1(100000, 20, false, [2,3,4,5,6], [1,20], [9,10]);
  println(s[1,20])
  @test pvalue(ExactOneSampleKSTest(x[:,1], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,2], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,3], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,4], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,5], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,6], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,9], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,10], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,20], Uniform(0,1))) > α
  λₗ = (2^(-1/ρ2θ(s[2,3], "clayton")))
  λᵣ = (2-2.^(1./ρ2θ(s[9,10], "gumbel")))
  @test lefttail(x[:,2], x[:,3]) ≈ λₗ atol=1.0e-1
  @test lefttail(x[:,3], x[:,4]) ≈ λₗ atol=1.0e-1
  @test lefttail(x[:,4], x[:,5]) ≈ λₗ atol=1.0e-1
  @test lefttail(x[:,2], x[:,4]) ≈ λₗ atol=1.0e-1
  @test lefttail(x[:,1], x[:,20]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,1], x[:,20]) ≈ 0 atol=1.0e-1
  @test lefttail(x[:,9], x[:,10]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,9], x[:,10]) ≈ λᵣ atol=1.0e-1
  println(λᵣ)
  println(righttail(x[:,9], x[:,10]))
end

@testset "heplers" begin
  @testset "axiliary functions" begin
    srand(43)
    @test cormatgen(2) ≈ [1.0 -0.258883; -0.258883 1.0] atol=1.0e-5
  end
  @testset "tail dependencies" begin
    v1 = vcat(zeros(5), 0.5*ones(5), zeros(5), 0.5*ones(70), ones(5), 0.5*ones(5), ones(5));
    v2 = vcat(zeros(10), 0.5*ones(80), ones(10))
    @test lefttail(v1, v2, 0.1) ≈ 0.5
    @test righttail(v1, v2, 0.9) ≈ 0.5
  end
  @testset "archimedean copula helpers" begin
    srand(43)
    @test pvalue(ExactOneSampleKSTest(rand2cop(rand(500000), 0.5, "clayton"), Uniform(0,1))) > α
    srand(43)
    @test pvalue(ExactOneSampleKSTest(rand2cop(rand(500000), 0.5, "frank"), Uniform(0,1))) > α
    srand(43)
    @test pvalue(ExactOneSampleKSTest(rand2cop(rand(500000), 0.5, "amh"), Uniform(0,1))) > α
    srand(43)
    @test rand2cop([0.815308, 0.894269], 0.5, "clayton") ≈ [0.292041, 0.836167] atol=1.0e-5
  end
  @testset "transform marginals" begin
    x = [0.2 0.4; 0.4 0.6; 0.6 0.8]
    x1 = [0.2 0.4; 0.4 0.6; 0.6 0.8]
    convertmarg!(x, Normal)
    convertmarg!(x1, TDist, [[10],[10]])
    @test x ≈ [-0.841621 -0.253347; -0.253347 0.253347; 0.253347 0.841621] atol=1.0e-5
    @test x1 ≈ [-0.879058  -0.260185; -0.260185 0.260185; 0.260185 0.879058] atol=1.0e-5
    srand(43)
    x = rand(10000, 2)
    srand(43)
    x1 = rand(10000, 2)
    convertmarg!(x, Normal, [[0., 2.],[0., 3.]])
    convertmarg!(x1, TDist, [[10],[6]])
    @test pvalue(ExactOneSampleKSTest(x[:,1],Normal(0,2))) > α
    @test pvalue(ExactOneSampleKSTest(x[:,2],Normal(0,3))) > α
    @test pvalue(ExactOneSampleKSTest(x1[:,1],TDist(10))) > α
    @test pvalue(ExactOneSampleKSTest(x1[:,2],TDist(6))) > α
    srand(43)
    @test_throws AssertionError convertmarg!(randn(1000, 2), Normal)
  end
  @testset "correlations vs parameter" begin
    @test ρ2θ(0.3090169943749474, "clayton") ≈ 0.5
    @test ρ2θ(0.08694, "frank") ≈ 0.5 atol=1.0e-3
    @test ρ2θ(0.5, "gumbel") ≈ 1.5
    @test AMHθ(0.2) ≈ 0.4980977569203229
  end
  @testset "logseries dist" begin
    @test logseriescdf(0.01)[1:3] ≈ [0.0, 0.994992, 0.999967] atol=1.0e-5
    @test logseriesquantile([0.25, 0.5, 0.75], 0.9) == [1, 2, 5]
    srand(43)
    v = logseriesquantile(rand(1000000), 0.4)
    @test mean(v) ≈ 1.304 atol=1.0e-2
    @test std(v) ≈ 0.687 atol=1.0e-2
    @test skewness(v) ≈ 3.1 atol=1.0e-2
    @test kurtosis(v) ≈ 13.5 atol=1.0
  end
end

@testset "gaussian copula" begin
  srand(43)
  @test gausscopulagen(2, [[1. 0.5];[0.5 1.]]) ≈ [0.589188 0.815308; 0.708285 0.924962] atol=1.0e-5
  srand(43)
  x = gausscopulagen(500000, [1. 0.5; 0.5 1.])
  @test pvalue(ExactOneSampleKSTest(x[:,1], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,2], Uniform(0,1))) > α
  @test lefttail(x[:,1], x[:,2]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,1], x[:,2]) ≈ 0 atol=1.0e-1
end
@testset "t-student copula" begin
  srand(43)
  @test tstudentcopulagen(2, [1. 0.5; 0.5 1.], 20) ≈ [0.581625 0.792144; 0.76935 0.968669] atol=1.0e-5
  ν = 10
  dt = TDist(ν+1)
  rho = 0.5
  λ = 2*pdf(dt, -sqrt.((ν+1)*(1-rho)/(1+rho)))
  srand(43)
  xt = tstudentcopulagen(500000, [1. 0.5; 0.5 1.], ν);
  @test pvalue(ExactOneSampleKSTest(xt[:,1], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(xt[:,2], Uniform(0,1))) > α
  @test lefttail(xt[:,1], xt[:,2]) ≈ λ atol=1.0e-1
  @test righttail(xt[:,1], xt[:,2]) ≈ λ atol=1.0e-1
  convertmarg!(xt, Normal)
  @test cov(xt) ≈ [1. 0.5; 0.5 1.] atol=1.0e-2
end
@testset "product copula" begin
  srand(43)
  x = productcopula(500000, 3);
  @test pvalue(ExactOneSampleKSTest(x[:,1], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,2], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,3], Uniform(0,1))) > α
  @test lefttail(x[:,1], x[:,3]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,1], x[:,2]) ≈ 0 atol=1.0e-1
end
@testset "gumbel copula" begin
  srand(43)
  x = gumbelcopulagen(500000, 3, 2.);
  @test pvalue(ExactOneSampleKSTest(x[:,1], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,2], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,3], Uniform(0,1))) > α
  @test righttail(x[:,1], x[:,2]) ≈ 0.5858 atol=1.0e-1
  @test righttail(x[:,1], x[:,2]) ≈ 0.5858 atol=1.0e-1
  @test lefttail(x[:,1], x[:,2]) ≈ 0. atol=1.0e-1
  @test lefttail(x[:,1], x[:,3]) ≈ 0. atol=1.0e-1
  srand(44)
  x = gumbelcopulagen(500000, 3, 1.5; reverse = true);
  @test lefttail(x[:,1], x[:,2]) ≈ 0.4126 atol=1.0e-1
  @test lefttail(x[:,1], x[:,2]) ≈ 0.4126 atol=1.0e-1
  @test righttail(x[:,1], x[:,2]) ≈ 0. atol=1.0e-1
  @test righttail(x[:,1], x[:,3]) ≈ 0. atol=1.0e-1
  @test pvalue(ExactOneSampleKSTest(x[:,1], Uniform(0,1))) > α
  srand(43)
  x = gumbelcopulagen(500000, 3, 0.5; pearsonrho = true)
  convertmarg!(x, Normal)
  @test cov(x) ≈ [1. 0.5 0.5; 0.5 1. 0.5; 0.5 0.5 1.] atol=1.0e-2
  x = gumbelcopulagen(500000, 3, 0.3; pearsonrho = true, reverse = true)
  convertmarg!(x, Normal)
  @test cov(x) ≈ [1. 0.3 0.3; 0.3 1. 0.3; 0.3 0.3 1.] atol=1.0e-1
end
@testset "clayton copula" begin
  srand(43)
  @test claytoncopulagen(2,2,1) ≈ [0.629041  0.182246; 0.950303  0.942292] atol=1.0e-5
  srand(43)
  xc = claytoncopulagen(500000, 3, 1);
  @test pvalue(ExactOneSampleKSTest(xc[:,1], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(xc[:,2], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(xc[:,3], Uniform(0,1))) > α
  @test lefttail(xc[:,1], xc[:,2]) ≈ 0.5 atol=1.0e-1
  @test lefttail(xc[:,1], xc[:,3]) ≈ 0.5 atol=1.0e-1
  @test righttail(xc[:,1], xc[:,2]) ≈ 0 atol=1.0e-1
  srand(43)
  x = claytoncopulagen(500000, 3, 0.5; pearsonrho = true)
  convertmarg!(x, Normal)
  @test cov(x) ≈ [1. 0.5 0.5; 0.5 1. 0.5; 0.5 0.5 1.] atol=1.0e-2
  srand(43)
  xic = claytoncopulagen(500000, 3, 1; reverse = true);
  @test pvalue(ExactOneSampleKSTest(xic[:,1], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(xic[:,2], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(xic[:,3], Uniform(0,1))) > α
  @test lefttail(xic[:,1], xic[:,3]) ≈ 0 atol=1.0e-1
  @test righttail(xic[:,1], xic[:,2]) ≈ 0.5 atol=1.0e-1
end
@testset "clayton bivariate subcopulas" begin
  srand(43)
  x = claytoncopulagen(500000, [-0.9, 3., 2., 3., 0.5])
  @test pvalue(ExactOneSampleKSTest(x[:,2], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,4], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,6], Uniform(0,1))) > α
  @test lefttail(x[:,1], x[:,2]) ≈ 0 atol=1.0e-1
  @test lefttail(x[:,3], x[:,4]) ≈ 1/(2^(1/2)) atol=1.0e-1
  @test lefttail(x[:,4], x[:,5]) ≈ 1/(2^(1/3)) atol=1.0e-1
  @test lefttail(x[:,5], x[:,6]) ≈ 1/(2^2) atol=1.0e-1
  @test righttail(x[:,1], x[:,2]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,4], x[:,5]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,3], x[:,4]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,3], x[:,6]) ≈ 0 atol=1.0e-1
  convertmarg!(x, Normal)
  @test cor(x[:,1], x[:,2]) ≈ -0.959 atol=1.0e-1
  srand(43)
  x = claytoncopulagen(500000, [0.6, -0.6]; pearsonrho = true)
  @test cor(x[:,1], x[:,2]) ≈ 0.6 atol=1.0e-1
  @test cor(x[:,2], x[:,3]) ≈ -0.6 atol=1.0e-1
  srand(43)
  x = claytoncopulagen(500000, [-0.9, 3., 2., 3., 0.5]; reverse = true)
  @test pvalue(ExactOneSampleKSTest(x[:,2], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,4], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,6], Uniform(0,1))) > α
  @test righttail(x[:,1], x[:,2]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,3], x[:,4]) ≈ 1/(2^(1/2)) atol=1.0e-1
  @test lefttail(x[:,3], x[:,4]) ≈ 0 atol=1.0e-1
  convertmarg!(x, Normal)
  @test cor(x[:,1], x[:,2]) ≈ -0.959 atol=1.0e-1
end
@testset "frank copula" begin
  npr.seed(43)
  srand(43)
  x = frankcopulagen(500000, 5, 0.8)
  @test pvalue(ExactOneSampleKSTest(x[:,2], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,4], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,5], Uniform(0,1))) > α
  @test lefttail(x[:,1], x[:,2]) ≈ 0 atol=1.0e-1
  @test lefttail(x[:,2], x[:,3]) ≈ 0 atol=1.0e-1
  @test lefttail(x[:,3], x[:,4]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,1], x[:,2]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,3], x[:,2]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,4], x[:,3]) ≈ 0 atol=1.0e-1
  convertmarg!(x, Normal)
  @test cor(x[:,1], x[:,2]) ≈ 0.138 atol=1.0e-1
  @test cor(x[:,2], x[:,3]) ≈ 0.138 atol=1.0e-1
  @test cor(x[:,1], x[:,4]) ≈ 0.138 atol=1.0e-1
end
@testset "frank bivariate subcopulas" begin
  srand(43)
  x = frankcopulagen(500000, [4., 11., 0.5, -12.])
  @test pvalue(ExactOneSampleKSTest(x[:,1], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,2], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,3], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,4], Uniform(0,1))) > α
  @test lefttail(x[:,1], x[:,2]) ≈ 0 atol=1.0e-1
  @test lefttail(x[:,2], x[:,3]) ≈ 0 atol=1.0e-1
  @test lefttail(x[:,3], x[:,4]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,1], x[:,2]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,3], x[:,2]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,4], x[:,3]) ≈ 0 atol=1.0e-1
  convertmarg!(x, Normal)
  @test cor(x[:,1], x[:,2]) ≈ 0.5726 atol=1.0e-1
  @test cor(x[:,2], x[:,3]) ≈ 0.8843 atol=1.0e-1
  srand(43)
  x = frankcopulagen(500000, [0.8, 0.3, -0.5]; pearsonrho = true)
  convertmarg!(x, Normal)
  @test cor(x[:,1], x[:,2]) ≈ 0.8 atol=1.0e-1
  @test cor(x[:,2], x[:,3]) ≈ 0.3 atol=1.0e-1
  @test cor(x[:,3], x[:,4]) ≈ -0.5 atol=1.0e-1
end
@testset "Ali-Mikhail-Haq copula" begin
  srand(43)
  x = amhcopulagen(500000, 4, 0.8)
  @test pvalue(ExactOneSampleKSTest(x[:,1], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,2], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,3], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,4], Uniform(0,1))) > α
  @test lefttail(x[:,1], x[:,2]) ≈ 0 atol=1.0e-1
  @test lefttail(x[:,2], x[:,3]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,1], x[:,2]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,2], x[:,3]) ≈ 0 atol=1.0e-1
  convertmarg!(x, Normal)
  @test cor(x[:,1], x[:,2]) ≈ 0.359 atol=1.0e-1
end
@testset "Ali-Mikhail-Haq bivariate subcopulas" begin
  srand(43)
  x = amhcopulagen(500000, [0.3, 0.6, 1.])
  @test pvalue(ExactOneSampleKSTest(x[:,1], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,2], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,3], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,4], Uniform(0,1))) > α
  @test lefttail(x[:,1], x[:,2]) ≈ 0 atol=1.0e-1
  @test lefttail(x[:,2], x[:,3]) ≈ 0 atol=1.0e-1
  @test lefttail(x[:,3], x[:,4]) ≈ 0.5 atol=1.0e-1
  @test righttail(x[:,1], x[:,2]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,2], x[:,3]) ≈ 0 atol=1.0e-1
  @test righttail(x[:,3], x[:,4]) ≈ 0 atol=1.0e-1
  srand(43)
  x = amhcopulagen(500000, [0.45, 0.3]; pearsonrho = true)
  convertmarg!(x, Normal)
  @test cor(x[:,1], x[:,2]) ≈ 0.45 atol=1.0e-1
  @test cor(x[:,2], x[:,3]) ≈ 0.3 atol=1.0e-1
end
@testset "Marhall-Olkin copula" begin
  srand(43)
  x = marshalolkincopulagen(100000, [1.1, 0.2, 0.6])
  @test pvalue(ExactOneSampleKSTest(x[:,1], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,2], Uniform(0,1))) > α
  a2 = 0.6/0.8
  a1 = 0.6/1.7
  @test corkendall(x)[1,2]≈ a1*a2/(a1+a2-a1*a2) atol=1.0e-2
  @test righttail(x[:,1], x[:,2]) ≈ a1 atol=1.0e-1
  srand(43)
  x = marshalolkincopulagen(100000, [1.1, 0.2, 2.1, 0.6, 0.5, 3.2, 7.1, 2.1])
  @test pvalue(ExactOneSampleKSTest(x[:,1], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,2], Uniform(0,1))) > α
  @test pvalue(ExactOneSampleKSTest(x[:,3], Uniform(0,1))) > α

end
@testset "subcopulas" begin
  @testset "t-student subcopula" begin
    srand(43)
    x = gausscopulagen(3, [1. 0.5 0.5; 0.5 1. 0.5; 0.5 0.5 1.])
    g2tsubcopula!(x, [1. 0.5 0.5; 0.5 1. 0.5; 0.5 0.5 1.], [1,2])
    @test x ≈ [0.558652  0.719921  0.794493; 0.935573  0.922409  0.345177; 0.217512  0.174138  0.123049] atol=1.0e-5
    srand(43)
    y = gausscopulagen(500000, [1. 0.5 0.5; 0.5 1. 0.5; 0.5 0.5 1.])
    g2tsubcopula!(y, [1. 0.5 0.5; 0.5 1. 0.5; 0.5 0.5 1.], [1,2])
    @test pvalue(ExactOneSampleKSTest(y[:,1], Uniform(0,1))) > α
    @test pvalue(ExactOneSampleKSTest(y[:,2], Uniform(0,1))) > α
  end
end
