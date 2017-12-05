include("RuleSet.jl")
include("DataSet.jl")

function dump_rule_set(rule_set :: RuleSet, dataset :: DataSet)
    for rule in rule_set.rules
        for col in keys(rule.atoms)
            atom = rule.atoms[col]
            if (typeof(atom) == PointRule)
                print("$(string(col))=$(dataset.meta.attrs[col].level_names[atom.val]) ")
            else
                print("$(string(col))($(round(atom.min,2)),$(round(atom.max,2))) ")
            end
        end
        classcol=names(dataset.data)[end]
        println("-> $(dataset.meta.attrs[Symbol(classcol)].level_names[rule.class])")
    end
end
