class GA
  attr_reader :population, :popsize, :genosize, :elitism, :nmutations, :printevery

  def initialize popsize:, genosize:, elitism:0, nmutations:1, printevery:false
    [:popsize,:genosize,:elitism,:nmutations,:printevery].each do |var|
      instance_eval "@#{var} = #{var}"
    end
    @population = init_pop
  end

  def init_pop
    popsize.times.collect { genosize.times.collect { random_gene } }
  end

  def sort_pop_by_fit
    population.sort_by! { |gen| -(fitness gen) }
  end

  def select_parent ratio=2
    population[rand(popsize)/ratio]
  end

  def select_parents ntries=10
    p1 = select_parent
    p2 = nil
    ntries.times do
      p2 = select_parent
      break if p1 != p2
    end
    [p1, p2]
  end

  def crossover p1, p2
    cutpoint = rand(genosize-1)
    c1 = p1[0..cutpoint] + p2[cutpoint+1..-1]
    c2 = p2[0..cutpoint] + p1[cutpoint+1..-1]
    [c1, c2]
  end

  def make_love nchildren
    (nchildren/2.0).ceil.times.collect do
      crossover *select_parents
    end.flatten(1).take(nchildren)
  end

  def mutate ind, pos
    population[ind][pos] = mutate_gene population[ind][pos]
  end

  def run ngens
    ngens.times do |ngen|
      sort_pop_by_fit
      population[elitism..-1] = make_love popsize-elitism
      rand(nmutations).times { mutate rand(popsize), rand(genosize) }
      if printevery && (ngen.zero? || ((ngen+1)%printevery).zero?)
        puts "Generation #{ngen+1}\n#{self}"
      end
    end
  end

  def to_s
    population.each_with_index.collect do |g, i|
      "#{format("%2d", i+1)}: #{g} => #{fitness g}"
    end.join("\n")
  end

  def random_gene
    rand 2
  end

  def mutate_gene g
    1 - g
  end

  def fitness genotype
    genotype.inject :+
  end

end

if __FILE__ == $0
  ga = GA.new(
    { popsize: 6,
      genosize: 8,
      elitism: 2,
      nmutations: 3,
      printevery: 5
    })
  ga.run 20
end

