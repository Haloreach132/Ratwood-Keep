/datum/migrant_wave
	abstract_type = /datum/migrant_wave
	/// Name of the wave
	var/name = "MIGRANT WAVE"
	/// Assoc list of roles types to amount
	var/list/roles = list()
	/// If defined, this is the minimum active migrants required to roll the wave
	var/min_active = null
	/// If defined, this is the maximum active migrants required to roll the wave
	var/max_active = null
	/// If defined, this is the minimum population playing the game that is required for wave to roll
	var/min_pop = null
	/// If defined, this is the maximum population playing the game that is required for wave to roll
	var/max_pop = null
	/// If defined, this is the maximum amount of times this wave can spawn
	var/max_spawns = null
	/// The relative probability this wave will be picked, from all available waves
	var/weight = 100
	/// Name of the latejoin spawn landmark for the wave to decide where to spawn
	var/spawn_landmark = "Refugee"
	/// Text to greet all players in the wave with
	var/greet_text
	/// Whether this wave can roll at all. If not, it can still be forced to be ran, or used as "downgrade" wave
	var/can_roll = TRUE
	/// What type of wave to downgrade to on failure
	var/downgrade_wave
	/// If defined, this will be the wave type to increment for purposes of checking `max_spawns`
	var/shared_wave_type = null
	/// Whether we want to spawn people on the rolled location, this may not be desired for bandits or other things that set the location
	var/spawn_on_location = TRUE

/datum/migrant_wave/proc/get_roles_amount()
	var/amount = 0
	for(var/role_type in roles)
		amount += roles[role_type]
	return amount

/datum/migrant_wave/adventurer
	name = "Adventure Party"
	weight = 60
	downgrade_wave = /datum/migrant_wave/adventurer_down_one
	roles = list(
		/datum/migrant_role/adventurer = 4,
	)
	greet_text = "Together with a party of trusted friends we decided to venture out, seeking thrills, glory and treasure, ending up in the misty and damp bog underneath Rockhill, perhaps getting ourselves into more than what we bargained for."

/datum/migrant_wave/adventurer_down_one
	name = "Adventure Party"
	can_roll = FALSE
	downgrade_wave = /datum/migrant_wave/adventurer_down_two
	roles = list(
		/datum/migrant_role/adventurer = 3,
	)
	greet_text = "Together with a party of trusted friends we decided to venture out, seeking thrills, glory and treasure, ending up in the misty and damp bog underneath Rockhill, perhaps getting ourselves into more than what we bargained for."

/datum/migrant_wave/adventurer_down_two
	name = "Adventure Party"
	weight = 60
	downgrade_wave = /datum/migrant_wave/adventurer_down_three
	roles = list(
		/datum/migrant_role/adventurer = 2,
	)
	greet_text = "Together with a party of trusted friends we decided to venture out, seeking thrills, glory and treasure, ending up in the misty and damp bog underneath Rockhill, perhaps getting ourselves into more than what we bargained for."

/datum/migrant_wave/adventurer_down_three
	name = "Adventure Party"
	can_roll = FALSE
	roles = list(
		/datum/migrant_role/adventurer = 1,
	)
	greet_text = "Together with a party of trusted friends we decided to venture out, seeking thrills, glory and treasure, ending up in the misty and damp bog underneath Rockhill, perhaps getting ourselves into more than what we bargained for."

/datum/migrant_wave/bandit
	name = "Bandit Raid"
	downgrade_wave = /datum/migrant_wave/bandit_down_one
	weight = 8
	spawn_landmark = "Bandit"
	roles = list(
		/datum/migrant_role/bandit = 2,
	)

/datum/migrant_wave/bandit_down_one
	name = "Bandit Raid"
	downgrade_wave = /datum/migrant_wave/bandit_down_two
	can_roll = FALSE
	spawn_landmark = "Bandit"
	roles = list(
		/datum/migrant_role/bandit = 2,
	)

/datum/migrant_wave/bandit_down_two
	name = "Bandit Raid"
	downgrade_wave = /datum/migrant_wave/bandit_down_three
	can_roll = FALSE
	spawn_landmark = "Bandit"
	roles = list(
		/datum/migrant_role/bandit = 2,
	)

/datum/migrant_wave/bandit_down_three
	name = "Bandit Raid"
	downgrade_wave = /datum/migrant_wave/bandit_down_four
	can_roll = FALSE
	spawn_landmark = "Bandit"
	roles = list(
		/datum/migrant_role/bandit = 2,
	)

/datum/migrant_wave/bandit_down_four
	name = "Bandit Raid"
	can_roll = FALSE
	spawn_landmark = "Bandit"
	roles = list(
		/datum/migrant_role/bandit = 1,
	)

