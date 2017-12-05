include("GA.jl")
include("dump.jl")

config = Dict("nelites"=>3, "iteration"=>100,  "pop"=>30,"rMin" => 1, "rMax"=>10, "aMin" => 1, "aMax" => 10, "verbose" => 0)
filename = ARGS[1]
for i = 2:length(ARGS)
    temp = ARGS[i]
    #println(temp)
    for j = 1:length(temp)
        if temp[j]=='='
            config[temp[3:j-1]] = parse(Int64,temp[j+1:length(temp)])
            #println("AAA")
            break
        end
    end
end

nr_elites = config["nelites"]
iteration = config["iteration"]
pop = config["pop"]
rMin = config["rMin"]
rMax = config["rMax"]
aMin = config["aMin"]
aMax = config["aMax"]


mydata = readtable(filename)
#println(mydata)


dataset = DataSet(mydata, DataMeta(Dict()))
pre_process!(dataset)
# index = []
# for i = 1: nrow(dataset.data)
#     push!(index, rand(1:5))
# end
# dataset2 = dataset
# dataset2.data = dataset.data[1,:]
# newdata = DataSet[dataset2,dataset2, dataset2, dataset2. dataset2]
# traindata = DataSet[dataset2,dataset2, dataset2, dataset2. dataset2]
# for i = 1: nrow(dataset.data)
# append!(newdata[index[i]].data,dataset.data[i,:])
# end

index1 = []
#println(dataset.data[1,:Stemp])
for i = 1:nrow(dataset.data)
    push!(index1,rand(1:5))
end


traindata = [deepcopy(dataset),deepcopy(dataset),deepcopy(dataset),deepcopy(dataset),deepcopy(dataset)]
validation = [deepcopy(dataset),deepcopy(dataset),deepcopy(dataset),deepcopy(dataset),deepcopy(dataset)]
for i = 1:5
    for j = nrow(dataset.data):-1:1
        #println(j)
        if index1[j]==i
            deleterows!(traindata[i].data,j)
        else
            deleterows!(validation[i].data,j)
        end
    end
    #println(nrow(validation[i].data))
#    println(nrow(traindata[i].data))
end

totalfitness = 0
totalvali = 0
for i = 1:5
(rule_set, fitness) = ga(traindata[i])
#println(fitness)
#println(rule_set)
totalfitness+= fitness
temp = [rule_set]
#trainfit = calculate_fitnesses(temp, traindata[i])
#println(fitness)
#println(trainfit[1])
vali=calculate_fitnesses(temp, validation[i])
#println(vali[1])
totalvali+=vali[1]
if (config["verbose"] == 1)
  dump_rule_set(rule_set, traindata[i])
end
end
println("Average traning accuracy: ", totalfitness/5)
println("Average validation accuracy: ", totalvali/5)
