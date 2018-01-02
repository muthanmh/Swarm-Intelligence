'''
Solving TSP using DEAP(genetic algorithm) library
-------------------------------------------------
Note: Execution can take time as results are recorded in logs.
-This file suppose to pick the TSP data from the TSP filename 'eil51.tsp.txt' (residing at same level)
-Execution of this python file will read the data and generate the local & best tour results across the generations
-Best tour obtained yet from this program (with PopulationSize = 100, MutationRate = 20%, CrossOverRate = 70%, Generations = 500 and TournamentSize=3):
BestTourLength: 481.674112841
BestTourCities: [26, 8, 48, 6, 27, 1, 22, 32, 11, 5, 38, 16, 2, 3, 28, 31, 36, 35, 20, 29, 21, 34, 50, 9, 49, 30, 10, 39, 33, 45, 15, 44, 37, 42, 19, 40, 41, 4, 17, 12, 46, 51, 47, 18, 13, 25, 14, 24, 43, 23, 7]
-Tune-in the parameters to obtain better results.
'''

from deap import algorithms, base, creator, tools
import numpy
import re

def read_file_data(tsp_name):
	tsp_name = tsp_name
	with open(tsp_name) as f:
		content = f.read().splitlines()
		cleaned = [x.lstrip() for x in content if x != ""]
		return cleaned

def detect_dimension(in_list):
	non_numeric = re.compile(r'[^\d]+')
	for element in in_list:
		if element.startswith("DIMENSION"):
			return non_numeric.sub("",element)

def get_cities(list,dimension):
	dimension = int(dimension)
	for item in list:
		for num in range(1, dimension + 1):
			if item.startswith(str(num)):
				if City(int(item.split(" ")[1]), int(item.split(" ")[2])) not in cities_set:
					cities_set.append(City(int(item.split(" ")[1]), int(item.split(" ")[2])))
	return cities_set

def create_tour(chromosome):
    return [list(cities)[e] for e in chromosome]

def evaluation(chromosome):
    #Evaluates the chromosome which is just a list of cities and passing that list to total_distance for calculating the fitness value (distance)
    return (total_distance(create_tour(chromosome)),)

def total_distance(tour):
    #Returning the total distance between each pair of consecutive cities in the tour.
    return sum(distance(tour[i], tour[i-1])
               for i in range(len(tour)))

def distance(a, b):
    #Returning the euclidean distance between two cities a and b.
    return abs(a - b)

cities_set = []
City = complex # Taking city as a complex number which can be instantiated with City class e.g. City(37, 50) = 37 + i50

data = read_file_data('eil51.tsp.txt')
cities = get_cities(data, detect_dimension(data))
#print cities
toolbox = base.Toolbox()

creator.create("FitnessMin", base.Fitness, weights=(-1.0,))
creator.create("Chromosome", list, fitness=creator.FitnessMin)

toolbox.register("indices", numpy.random.permutation, len(cities))
toolbox.register("chromosome", tools.initIterate, creator.Chromosome, toolbox.indices)
toolbox.register("population", tools.initRepeat, list, toolbox.chromosome)

toolbox.register("mate", tools.cxOrdered)
toolbox.register("mutate", tools.mutShuffleIndexes, indpb=0.05)

toolbox.register("evaluate", evaluation)
toolbox.register("select", tools.selTournament, tournsize=3)
pop = toolbox.population(n=100)


#result, log = algorithms.eaSimple(pop, toolbox, cxpb=0.9, mutpb=0.1, ngen=600, verbose=False)
dataForStats = tools.Statistics(key=numpy.copy)
dataForStats.register('pop', numpy.copy) # -- copies the populations themselves
dataForStats.register('fitness', lambda x : [evaluation(a) for a in x])
#pop_stats.register('mean', numpy.mean)
#pop_stats.register('min', numpy.min)
print 'Results are in progress...'

result, log = algorithms.eaSimple(toolbox.population(n=100), toolbox, cxpb=0.8, mutpb=0.2, ngen=500, verbose=False, stats=dataForStats)

best_chromosome = tools.selBest(result, k=1)[0]
#print('Best Tour length1: ', evaluation(best_chromosome)[0])
print 'Global Best Tour Length: ' + str(evaluation(best_chromosome)[0])
best_chromosome = map(lambda x: x+1, best_chromosome)
print 'Global Best Tour Cities: ' + str(best_chromosome)
#print len(log)

print "------------------------------------------------------------------------"
print "--------------------Generation-wise data--------------------------------"
print "------------------------------------------------------------------------"
#print log.select('mean')[0]
#print log.select('min')[0]
for i in range(len(log)):
	#localbest = tools.selBest(log, k=1)[0]
    local_best_index = numpy.argmin(log[i]['fitness'])
    local_best_value = numpy.min(log[i]['fitness'])
    local_fitness_avg = numpy.mean(log[i]['fitness'])
    local_best_chromosome = log[i]['pop'][local_best_index]
    local_best_chromosome = map(lambda x: x+1, local_best_chromosome)
    print "Generation: " + str(i)
    print "PopulationIndexOfBestTour(out of 100): " + str(local_best_index + 1)
    print "AverageTourLength: " + str(local_fitness_avg)
    print "BestTourLength: " + str(local_best_value)
    print "BestTourCities: " + str(local_best_chromosome)
    print "------------------------------------------------------------------------"


