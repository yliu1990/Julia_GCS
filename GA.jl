using DataStructures
using Base.Order
using StatsBase

include("RuleSet.jl")
include("DataSet.jl")

function create_attrs_meta!(dataset)
    attrs = Dict()
    for name in names(dataset.data)
        if dataset.data[1, name] == "c"
            attrs[name] = NominalAttr(Dict(), Dict())
        elseif dataset.data[1, name] == "n"
            attrs[name] = NumericAttr(0, 0, 0, 0)
        else
            @assert false
        end
    end
    dataset.meta.attrs = attrs
end

function pre_process_nominal_attr!(dataset, colname)
    # use int to represent nominal attributes (how)
    attr = dataset.meta.attrs[colname]
    levels = Dict{Any, Int}()
    new_arr = Int[]
    c = 1
    for i in 1:nrow(dataset.data)
        n = dataset.data[i, colname]
        if ! haskey(levels, n)
            levels[n] = c
            c += 1
        end
        push!(new_arr, levels[n])
    end
    for col in keys(levels)
        attr.level_names[levels[col]] = col
    end
    dataset.data[:,colname] = new_arr

    # get statistics of nominal attr
    for i in 1:nrow(dataset.data)
        n = dataset.data[i, colname]
        if haskey(attr.levels, n)
            attr.levels[n] += 1
        else
            attr.levels[n] = 1
        end
    end
end

function pre_process_numeric_attr!(dataset, colname)
    # get statistics of numeric attr
    attr = dataset.meta.attrs[colname]
    attr.min = parse(Float64, dataset.data[1, colname])
    attr.max = attr.min
    attr.avg = 0;
    attr.std = 0;
    nr = nrow(dataset.data)
    new_arr = Float64[]
    for i in 1:nr
        n = dataset.data[i, colname]
        n = parse(Float64, dataset.data[i, colname])
        attr.min = min(attr.min, n)
        attr.max = max(attr.max, n)
        attr.avg += n
        attr.std += n*n
        push!(new_arr, n)
    end
    dataset.data[:,colname] = new_arr
    attr.avg /= nr
    attr.std = sqrt(attr.std/nr - attr.avg*attr.avg)
end

function pre_process!(dataset)
    create_attrs_meta!(dataset)

    # remove the first row
    deleterows!(dataset.data, 1)

    # get statistics of attributes
    for name in names(dataset.data)
        attr = dataset.meta.attrs[name]
        if typeof(attr) == NominalAttr
            pre_process_nominal_attr!(dataset, name)
        else
            pre_process_numeric_attr!(dataset, name)
        end
    end
end


    # compute sample number of each category
function pre_sample_examples(groups, n)
    classcol = names(groups[1])[end]
    levels = Array(1:length(groups))
    counts = Dict{eltype(levels), Int}()
    while n >= 1 && length(levels) > 0
        l = sample(levels)
        class = groups[l][1, end]
        if ! haskey(counts,class)
            counts[class] = 0
        end
        counts[class] += 1
        if counts[class] == nrow(groups[l])
            deleteat!(levels, findfirst(levels, l))
        end
        n -= 1
    end
    return counts
end


# generate rule from an example
function gen_rules_from_example(dataset, n)
    attMin = config["aMin"]
    attMax = config["aMax"]

    rule_set = RuleSet([])
    rules = rule_set.rules


    groups = groupby(dataset.data, ncol(dataset.data))

    counts = pre_sample_examples(groups, n)
    # println("counts=", counts, " n=", n)

    for group in groups
        class = group[1,end]
        if ! haskey(counts, class)
            continue
        end
        examples = sample(1:nrow(group), counts[class], replace = false)
        for example in examples
            nrAttr = rand(attMin:attMax)
            nrAttr = min(nrAttr, ncol(dataset.data)-1)
            cols = sample(1:ncol(dataset.data)-1, nrAttr, replace = false)
            rule = Rule(Dict(), -1, class)
            for col in cols
                name = names(dataset.data)[col]
                attr = dataset.meta.attrs[name]
                val = group[example, col]

                if typeof(attr) == NominalAttr
                    rule.atoms[name] = PointRule(val)
                else
                    @assert typeof(attr) == NumericAttr
                    interval = attr.min + (attr.max - attr.min) * (0.25 + rand() / 2)
                    mi = max(attr.min, val - interval / 2)
                    ma = min(attr.max, val + interval / 2)
                    rule.atoms[name] = RangeRule(mi, ma)
                end
            end
            push!(rules, rule)
        end
    end

    return rule_set
end

# generate rule randomly
function gen_random_rule(dataset)
    attMin = config["aMin"]
    attMax = config["aMax"]
    nrAttr = rand(attMin:attMax)
    nrAttr = min(nrAttr, ncol(dataset.data)-1)
    rule = Rule(Dict(), -1, -1)
    cols = sample(1:ncol(dataset.data)-1, nrAttr, replace = false)
    for icol in cols
        name = names(dataset.data)[icol]
        attr = dataset.meta.attrs[name]
        if typeof(attr) == NominalAttr
            rule.atoms[name] = PointRule(rand(1:length(attr.levels)))
        else
            @assert typeof(attr) == NumericAttr
            r1 = attr.min + (attr.max-attr.min) * rand()
            r2 = attr.min + (attr.max-attr.min) * rand()
            mi = min(r1, r2)
            ma = max(r1, r2)
            rule.atoms[name] = RangeRule(mi, ma)
        end
    end
    return rule
end

function caculate_rule_fitness(rule :: Rule, dataset)
    classesfit = Dict()
    for i in 1:nrow(dataset.data)
        if fit(rule, dataset.data[i, :])
            c = dataset.data[i, end]
            if ! haskey(classesfit, c)
                classesfit[c] = 0
            end
            classesfit[c] += 1
        end
    end

    nfit = 0
    class = rule.class
    if haskey(classesfit, class)
        nfit = classesfit[class]
    end
    total = 0
    for c in keys(classesfit)
        count = classesfit[c]
        total += count
        if rule.class == -1 && count > nfit
            nfit = count
            class = c
        end
    end

    return (nfit / total, class)
end

# determine class of random rule & sort rules
function sort_rules!(individual :: RuleSet, dataset, default_class)
    # caculate fitnesses of rules
    for rule in individual.rules[1:end]
        if rule.fitness >= 0
            continue
        end

        (rule.fitness, class) = caculate_rule_fitness(rule, dataset)
        if (rule.class == -1)
            rule.class = class
            if rule.class == -1
                rule.class = default_class
            end
        end
    end

    # sort rules
    pq = PriorityQueue{Int, Float64}(Reverse)
    for i in 1:length(individual.rules)
        enqueue!(pq, i, individual.rules[i].fitness)
    end

    rules = typeof(individual.rules)()
    while ! isempty(pq)
        push!(rules, individual.rules[dequeue!(pq)])
    end
    individual.rules = rules
end

function get_default_rule(dataset)
    # prepare default_rule
    colname = names(dataset.data)[end]
    @assert typeof(dataset.meta.attrs[colname]) == NominalAttr
    class_levels = dataset.meta.attrs[colname].levels
    default_class = first(class_levels).first
    for k in keys(class_levels)
        if class_levels[k] > class_levels[default_class]
            default_class = k
        end
    end
    return Rule(Dict(), -1, default_class)
end

# return an array of intial RuleSets
function initialize_population(dataset)
    nrPeople = pop
    default_rule = get_default_rule(dataset)

    population = RuleSet[]
    for i in 1:nrPeople
        nRules = rand(rMin:rMax)
        nExamples = round(0.8 * nRules)
        nExamples = min(nExamples, nrow(dataset.data))
        nRandoms = nRules - nExamples
        individual = gen_rules_from_example(dataset, nExamples)
        for j in 1:nRandoms
            push!(individual.rules, gen_random_rule(dataset))
        end

        # determine class of random rule & sort rules
        sort_rules!(individual, dataset, default_rule.class)

        # push default rule
        push!(individual.rules, default_rule)

        push!(population, individual)
    end

    return population
end

# return an array of fitnesses scores
function calculate_fitnesses(population, dataset)
    fitnesses = zeros(Float64,length(population))
    for i = 1:length(population)
        count = 0;
        for j = 1:nrow(dataset.data)
            if fit(population[i],dataset.data[j,:])==dataset.data[j, ncol(dataset.data)]
                count = count +1;
            end
        end
        fitnesses[i]= count/nrow(dataset.data)
    end
    return fitnesses
end

# return the predicted value of an instance based on one classifier

function fit(rule :: Rule, datarow)
    find = true
    for k in keys(rule.atoms)
        if typeof(rule.atoms[k])==PointRule
            if datarow[1,k]!=rule.atoms[k].val
                find = false
                break
            end
        elseif datarow[1,k]<rule.atoms[k].min || datarow[1,k]>rule.atoms[k].max
            find = false
            break
        end
    end

    return find
end

function fit(classifier :: RuleSet, datarow)
    for rule in classifier.rules
        if fit(rule, datarow)
            return rule.class
        end
    end
end

# get the :nr_elites individuals with the highest fitness score
# return (elites, elites_fitnesses)
function get_elites(population, fitnesses, nr_elites)
    pq = PriorityQueue{Int, eltype(fitnesses)}(Reverse)
    for i in 1:length(fitnesses)
        enqueue!(pq, i, fitnesses[i])
    end

    elites = typeof(population)()
    elites_fitnesses = typeof(fitnesses)()
    for i in 1:nr_elites
        if isempty(pq)
            break
        end

        index = dequeue!(pq)
        push!(elites, deepcopy(population[index]))
        push!(elites_fitnesses, fitnesses[index])
    end

    return (elites, elites_fitnesses)
end

# crossover population
function crossover(population, fitnesses, rMax)
    totalscore = 0
    #rMax = 10
    for i = 1: length(fitnesses)
        totalscore += fitnesses[i]
    end
    newpopulation = RuleSet[]
    while length(newpopulation)!=length(population)
    (parent1, parent2) = sample(population, Weights(fitnesses), 2, replace=false)

    # parent1 = 0
    # ran1 = rand(1:totalscore)
    # for i = 1: length(fitnesses)
    #     if (ran1 <= fitnesses[i])
    #         parent1 = i
    #         break
    #     else
    #         ran1 -= fitnesses[i]
    #     end
    # end
    # parent2 = parent1
    # while parent2 == parent1
    #     ran1 = rand(1:totalscore)
    #     for i = 1: length(fitnesses)
    #         if (ran1 <= fitnesses[i])
    #             parent2 = i
    #             break
    #         else
    #             ran1 -= fitnesses[i]
    #         end
    #     end
    # end
    ran1 = rand(1:length(parent1.rules)-1)
    k = 1
    if rMax+1-ran1 > length(parent2.rules)
        k = length(parent2.rules)
    elseif rMax+1-ran1 >0
        k = rMax+1-ran1
    end
    #println(ran1," ", k," ", rMax, " ", length(population[parent1].rules)," ",length(population[parent2].rules))
    if (k!=1)
    ran2 = rand(1:k-1)
    else
    ran2 = 0
    end
    child1 = RuleSet(Rule[])
    #child2 = RuleSet(Rule[])
    for i = 1:ran1
    push!(child1.rules, deepcopy(parent1.rules[i]))
    end
    for i = length(parent2.rules)-ran2: length(parent2.rules)
    push!(child1.rules, deepcopy(parent2.rules[i]))
    end
    # for i = 1:ran2
    # push!(child2.rules, population[parent2].rules[i])
    # end
    # for i = ran1+1: length(population[parent1].rules)
    # push!(child2.rules, population[parent1].rules[i])
    # end
    push!(newpopulation,child1)
#    push!(newpopulation,child2)
    end
    return newpopulation
end

# mutate population
function mutate!(population, dataset)
    for individual in population
        irule = rand(1:length(individual.rules)-1)
        rule = individual.rules[irule] # ignore default rule
        cols = []
        for k in keys(rule.atoms)
            push!(cols, k)
        end
        col = sample(cols)
        atom = rule.atoms[col]
        attr = dataset.meta.attrs[col]
        if typeof(atom) == PointRule
            rule.atoms[col] = PointRule(rand(1:length(attr.levels)))
        else
            @assert typeof(atom) == RangeRule
            mi = atom.min
            ma = atom.max
            offset = (attr.max - attr.min) * (rand() * 0.6 - 0.3)
            if rand() > 0.5
                # mutate upper bound
                ma += offset
                ma = min(ma, attr.max)
                ma = max(ma, attr.min)
            else
                # mutate lower bound
                mi += offset
                mi = min(mi, attr.max)
                mi = max(mi, attr.min)
            end

            if ma < mi
                (mi, ma) = (ma, mi)
            end

            rule.atoms[col] = RangeRule(mi, ma)
        end
        (rule.fitness, _) = caculate_rule_fitness(rule, dataset)

        rules = individual.rules
        i = irule
        while i > 1 && rules[i].fitness > rules[i-1].fitness
            (rules[i], rules[i-1]) = (rules[i-1], rules[i])
            i -= 1
        end

        while i < length(rules)-1 && rules[i].fitness < rules[i+1].fitness
            (rules[i], rules[i+1]) = (rules[i+1], rules[i])
            i += 1
        end
    end
end

# replace bad individuals in the population with elites
function replace_losers!(population, fitnesses, elites, elites_fitnesses)
    pq = PriorityQueue{Int, eltype(fitnesses)}(Forward)
    for i in 1:length(fitnesses)
        enqueue!(pq, i, fitnesses[i])
    end

    for i in 1:length(elites)
        @assert ! isempty(pq)
        index = dequeue!(pq)
        population[index] = elites[i];
        fitnesses[index] = elites_fitnesses[i]
    end

end

# return (classifier, fitness_score)
function ga(dataset)

    population = initialize_population(dataset)
    fitnesses = calculate_fitnesses(population, dataset)

    # main loop
    for i in 1:iteration
        (elites, elites_fitnesses) = get_elites(population, fitnesses, nr_elites)
        population = crossover(population, fitnesses, rMax)
        mutate!(population, dataset)
        fitnesses = calculate_fitnesses(population, dataset)
        replace_losers!(population, fitnesses, elites, elites_fitnesses)
        println(i)
    end

    (best, best_fitness) = get_elites(population, fitnesses, 1)
    return (best[1], best_fitness[1])
end
