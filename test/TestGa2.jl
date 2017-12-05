using Base.Test
using DataFrames

include("GA.jl")



@testset "Test calculate_fitnesses" begin
df = DataFrame(A = [1,2,3,4], B = [1,2,3,4])
ds = DataSet(df, DataMeta(Dict()))
P = PointRule(1)
x = Rule(Dict(:A=>P),1)
Y = Rule(Dict(),2)
set = RuleSet([x,Y])
pop = [set]
    @test calculate_fitnesses(pop,ds) == ([0.5])



end



P = PointRule(1)
x = Rule(Dict(:A=>P),1)
Y = Rule(Dict(),2)
Z = Rule(Dict(:B=>P),3)
M = Rule(Dict(:C=>P, :B=>P),3)

set1 = RuleSet([x,Y])
set2 = RuleSet([Z,Y])
set3 = RuleSet([M,Y])
pop = [set1, set2, set3]
fitness = [500.000, 4000.000, 3000.000]
pop = crossover(pop,fitness,5)
println(pop)
