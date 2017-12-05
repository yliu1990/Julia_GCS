using Base.Test
using DataFrames

include("GA.jl")


@testset "Test get_elites" begin
    @test get_elites([], [], 1) == ([], [])
    @test get_elites(['a'], [1], 1) == (['a'], [1])
    @test get_elites(['a', 'b'], [1, 2], 1) == (['b'], [2])
    @test get_elites(['a', 'b'], [1.0, 2.0], 1) == (['b'], [2.0])
    @test get_elites(["a", "b", "foo"], [2.0, 1.0, 3.0], 1) == (["foo"], [3.0])
    @test get_elites(["a", "b", "foo"], [2.0, 1.0, 3.0], 2) == (["foo", "a"], [3.0, 2.0])
    @test get_elites(["a", "b", "foo"], [2.0, 1.0, 3.0], 3) == (["foo", "a", "b"], [3.0, 2.0, 1.0])
end

@testset "Test replace_losers!" begin
    @test_broken replace_losers!([], [], [1], [2])

    population = [1]
    fitnesses = [1]
    replace_losers!(population, fitnesses, [1], [2])
    @test population == [1]
    @test fitnesses == [2]

    population = ["a", "b", "c", "d"]
    fitnesses = [4.0, 3.0, 1.0, 2.0]
    replace_losers!(population, fitnesses, ["foo"], [2.0])
    @test population == ["a", "b", "foo", "d"]
    @test fitnesses == [4.0, 3.0, 2.0, 2.0]

    population = ["a", "b", "c", "d"]
    fitnesses = [4.0, 3.0, 1.0, 1.5]
    replace_losers!(population, fitnesses, ["foo", "bar"], [5.0, 2.0])
    @test population == ["a", "b", "foo", "bar"]
    @test fitnesses == [4.0, 3.0, 5.0, 2.0]
end

@testset "Test GA" begin
    df = DataFrame(A = ["n", 1,2,3,4], B=["c", -1, -1, 1, 1], C=["c", "a","a","a","b"], D=["c", true, false, true, false])
    ds = DataSet(df, DataMeta(Dict()))
    (best, best_fitness) = ga(ds)
end
