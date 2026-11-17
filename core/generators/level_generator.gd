@abstract
class_name LevelGenerator
extends RefCounted
## Base class for level generation patterns (maze, caves, mines, prison...).
##
## A generator must return a level with the entrance and the exit set and
## connected. All randomness must come from the passed rng, so that the same
## seed always gives the same level.

## Smallest size any generator has to support.
const MIN_SIZE: int = 5


## Name shown in the generator lab.
@abstract
func get_display_name() -> String


@abstract
func generate(width: int, height: int, rng: RandomNumberGenerator) -> Level


func generate_from_seed(width: int, height: int, level_seed: int) -> Level:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = level_seed
	var level: Level = generate(maxi(width, MIN_SIZE), maxi(height, MIN_SIZE), rng)
	level.generation_seed = level_seed
	return level
