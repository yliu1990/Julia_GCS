struct PointRule
    val :: Int
end

struct RangeRule
    min :: Float64
    max :: Float64
end

mutable struct Rule
    atoms :: Dict{Symbol, Union{RangeRule, PointRule} }
    fitness :: Float64
    class :: Int
end

mutable struct RuleSet
    rules :: Array{Rule}
end
