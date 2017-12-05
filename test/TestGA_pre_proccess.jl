using Base.Test

include("GA.jl")

@testset "Test GA pre_process" begin
    df = DataFrame(A = ["n", 1,2,3,4], B=["c", "a","a","a","b"])
    ds = DataSet(df, DataMeta(Dict()))
    pre_process!(ds)
    @test length(ds.meta.attrs) == 2
    @test typeof(ds.meta.attrs[:A]) == NumericAttr
    @test typeof(ds.meta.attrs[:B]) == NominalAttr
    @test ds.meta.attrs[:A].min == 1
    @test ds.meta.attrs[:A].max == 4
    @test ds.meta.attrs[:A].avg == 2.5
    @test ds.meta.attrs[:A].std == sqrt(1.25)
    @test length(ds.meta.attrs[:B].levels) == 2
    @test ds.meta.attrs[:B].levels[1] == 3
    @test ds.meta.attrs[:B].levels[2] == 1
end
