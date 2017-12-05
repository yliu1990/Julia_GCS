using DataFrames

mutable struct NumericAttr
   min :: Float64
   max :: Float64
   avg :: Float64
   std :: Float64
end

mutable struct NominalAttr
   # category to its count
   levels :: Dict{Int, Int}
   level_names :: Dict{Int, String}
end

mutable struct DataMeta
   attrs :: Dict{Symbol, Union{NominalAttr, NumericAttr}}
end

mutable struct DataSet
   data :: DataFrame
   meta :: DataMeta
end
