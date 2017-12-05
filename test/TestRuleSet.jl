using Base.Test

include("RuleSet.jl")

rs1 = RuleSet([])
pr = PointRule(1)
rr = RangeRule(1.0, 2.0)
r1 = Rule(Dict(:foo => pr, :bar => rr), 1)
rs2 = RuleSet([r1])
rs3 = RuleSet([Rule(Dict(:foo => PointRule(1)), 2)])
rs3.rules[1]
@test rs3.rules[1].atoms[:foo].val == 1
