export solution_concept, shapleyConcept, owenConcept

# enum for type of game
abstract type solution_concept end
struct shapleyConcept <: solution_concept end
struct owenConcept <: solution_concept end
