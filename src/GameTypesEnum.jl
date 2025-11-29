export game_type, minGame, avgGame

# enum for type of game
abstract type game_type end
struct minGame <: game_type end
struct avgGame <: game_type end
