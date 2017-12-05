using Base.Test

include("GA.jl")

@testset "Test mutate" begin
    df = DataFrame(A = ["n", 1,2,3,4], B=["c", -1, -1, 1, 1], C=["c", "a","a","a","b"], D=["c", true, false, true, false])
    ds = DataSet(df, DataMeta(Dict()))
    pre_process!(ds)
    population = initialize_population(ds)
    mutate!(population, ds)
    @test length(population) == 100
end
