/obj/effect/biomass
	icon = 'icons/obj/biomass.dmi'
	icon_state = "stage1"
	opacity = 0
	density = 0
	anchored = 1
	layer = 20 //DEBUG
	var/health = 30
	var/stage = 1
	var/obj/effect/rift/originalRift = null //the originating rift of that biomass
	var/maxDistance = 15 //the maximum length of a thread
	var/newSpreadDistance = 10 //the length of a thread at which new ones are created
	var/curDistance = 1 //the current length of a thread
	var/continueChance = 3 //weighed chance of continuing in the same direction. turning left or right has 1 weight both
	var/spreadDelay = 1 //will change to something bigger later, but right now I want it to spread as fast as possible for testing

/obj/effect/rift
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	var/list/obj/effect/biomass/linkedBiomass = list() //all the biomass patches that have spread from it
	var/stage = 1

/obj/effect/rift/New()
	set background = 1
	visible_message("\red <B>A rip in space tears open before you!</B>")
	..()
	for(var/turf/T in orange(1,src))
		if(!IsValidBiomassLoc(T))
			continue
		var/obj/effect/biomass/starting = new /obj/effect/biomass(T)
		starting.dir = get_dir(src,starting)
		starting.originalRift = src
		linkedBiomass += starting
		spawn(1)
			starting.icon_state = "stage[stage]"
		spawn(1200)
			del(src)

/obj/effect/rift/Del()
	visible_message("\red <B>The rift fades!</B>")
	..()

/obj/effect/biomass/New()
	set background = 1
	spreadDelay = rand(120,240)
	..()
	if(!IsValidBiomassLoc(loc,src))
		del(src)
		return
	spawn(1) //so that the dir and stuff can be set by the source first
		spawn(10)
			process()
		if(curDistance >= maxDistance)
			return
		switch(dir)
			if(NORTHWEST)
				dir = NORTH
			if(NORTHEAST)
				dir = EAST
			if(SOUTHWEST)
				dir = WEST
			if(SOUTHEAST)
				dir = SOUTH
		sleep(spreadDelay)
		Spread()

/obj/effect/biomass/process()
	if(prob(25))
		if(stage < 3)
			stage = stage + 1
			icon_state = "stage[stage]"
		if(stage == 3)
			if(prob(25))
				visible_message("\red <B>Spores on the biomass pop, releasing deadly gas!</B>")
				var/datum/reagents/R = new/datum/reagents(50)
				R.my_atom = src.loc
				R.add_reagent("space_drugs", 25)
				R.add_reagent("toxin", 25)
				var/datum/effect/effect/system/chem_smoke_spread/smoke = new
				smoke.set_up(R, rand(1, 2), 0, src.loc, 0, silent = 1)
				playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
				smoke.start()
				R.delete()
				stage = 1
				icon_state = "stage[stage]"
	spawn(120)
		process()

/obj/effect/biomass/proc/Spread(var/direction = dir)
	set background = 1
	var/possibleDirsInt = 0

	for(var/newDirection in cardinal)
		if(newDirection == turn(direction,180)) //can't go backwards
			continue
		var/turf/T = get_step(loc,newDirection)
		if(!IsValidBiomassLoc(T,src))
			continue
		possibleDirsInt |= newDirection

	var/list/possibleDirs = list()

	if(possibleDirsInt & direction)
		for(var/i=0 , i<continueChance , i++)
			possibleDirs += direction
	if(possibleDirsInt & turn(direction,90))
		possibleDirs += turn(direction,90)
	if(possibleDirsInt & turn(direction,-90))
		possibleDirs += turn(direction,-90)

	if(!possibleDirs.len)
		return

	direction = pick(possibleDirs)

	var/obj/effect/biomass/newBiomass = new /obj/effect/biomass(get_step(src,direction))
	newBiomass.curDistance = curDistance + 1
	newBiomass.maxDistance = maxDistance
	newBiomass.dir = direction
	newBiomass.originalRift = originalRift
	newBiomass.stage = stage
	newBiomass.icon_state = "stage[originalRift.stage]"
	originalRift.linkedBiomass += newBiomass

/obj/effect/biomass/proc/NewSpread(maxDistance = 15)
	set background = 1
	for(var/turf/T in orange(1,src))
		if(!IsValidBiomassLoc(T,src))
			continue
		var/obj/effect/biomass/starting = new /obj/effect/biomass(T)
		starting.dir = get_dir(src,starting)
		starting.maxDistance = maxDistance

/proc/IsValidBiomassLoc(turf/location,obj/effect/biomass/source = null)
	set background = 1
	for(var/obj/effect/biomass/biomass in location)
		if(biomass != source)
			return 0
	if(istype(location,/turf/space))
		return 0
	if(location.density)
		return 0
	return 1

/obj/effect/biomass/proc/healthcheck()
	if(health <= 0)
		die()

/obj/effect/biomass/proc/die()
	visible_message("<span class='alert'>The biomass writhes and wriggles before melting away!</span>")
	del(src)

/obj/effect/biomass/attackby(var/obj/item/weapon/W, var/mob/user)
	if(W.attack_verb.len)
		visible_message("\red <B>\The [src] has been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]")
	else
		visible_message("\red <B>\The [src] has been attacked with \the [W][(user ? " by [user]." : ".")]")

	var/damage = W.force / 4.0

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			damage = 30
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)
	health -= damage
	healthcheck()