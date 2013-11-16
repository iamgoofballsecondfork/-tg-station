/obj/machinery/bot/harvestbot
	name = "Harvestbot"
	desc = "A Water Tank on wheels. Not the most pretty of things."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "farmbot0"
	layer = 5.0
	density = 0
	anchored = 0
	health = 20
	maxhealth = 20
	req_access = list(access_hydroponics)
	var/currently_gardening = 0
	var/obj/machinery/hydroponics/tray = null
	var/obj/machinery/hydroponics/oldtray = null
	var/list/botcard_access = list(access_hydroponics)
	var/path[] = new()
	var/oldloc = null
	var/last_found = 0
	var/mode = 1 //1 = water 2 = nutrient 3 = weed and depest

/obj/machinery/bot/harvestbot/New()
	..()
	src.icon_state = "farmbot[src.on]"
	spawn(4)
		src.botcard = new /obj/item/weapon/card/id(src)
		if(isnull(src.botcard_access) || (src.botcard_access.len < 1))
			src.botcard.access = list(access_hydroponics)
		else
			src.botcard.access = src.botcard_access

/obj/machinery/bot/harvestbot/verb/ToggleMode()
	set category = "Object"
	set name = "Toggle Harvestbot Mode"
	set src in oview(1)
	switch(mode)
		if(1)
			mode = 2
			usr << "You switch the [src] to Fertilizer mode"
		if(2)
			mode = 3
			usr << "You switch the [src] to Care mode"
		if(3)
			mode = 1
			usr << "You switch the [src] to Water mode"

/obj/machinery/bot/harvestbot/process()
	set background = 1
	if(!src.tray)
		for (var/obj/machinery/hydroponics/C in view(7,src))
			if(C.myseed)
				if ((C == src.oldtray) && (world.time < src.last_found + 100))
					continue
				if(src.assess_tray(C))
					src.tray = C
					src.oldtray = C
					src.last_found = world.time
					break
				else
					continue

	if(src.tray && (get_dist(src,src.tray) <= 1))
		if(!src.currently_gardening)
			src.currently_gardening = 1
			src.garden_tray(src.tray)
		return
	else if(src.tray && (src.path.len) && (get_dist(src.tray,src.path[src.path.len]) > 2))
		src.path = new()
		src.currently_gardening = 0
		src.last_found = world.time

	if(src.tray && src.path.len == 0 && (get_dist(src,src.tray) > 1))
		//stuck here
		spawn(0)
			src.path = AStar(src.loc, src.tray, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance_cardinal, 0, 120,id=botcard)
			if(!src.path)
				src.path = list()
			if(src.path.len == 0)
				src.oldtray = src.tray
				src.tray = null
				src.currently_gardening = 0
				src.last_found = world.time
		return

	if(src.path.len > 0 && src.tray)
		world << "[src] is pathing to the [src.tray]"
		step_to(src, src.path[1])
		src.path -= src.path[1]
		spawn(3)
			if(src.path.len)
				step_to(src, src.path[1])
				src.path -= src.path[1]
	return

/obj/machinery/bot/harvestbot/proc/assess_tray(obj/machinery/hydroponics/C as obj)
	var/obj/machinery/hydroponics/T = C

	if(T.dead)
		return 1

	if(T.waterlevel <= 10)
		return 1

	if(T.nutrilevel <= 2)
		return 1

	if(T.pestlevel >= 5)
		return 1

	if(T.weedlevel >= 5)
		return 1

	if(T.toxic >= 40)
		return 1

	if(T.health < (T.myseed.endurance / 2))
		return 1

	return 0

/obj/machinery/bot/harvestbot/proc/garden_tray(obj/machinery/hydroponics/C as obj)
	var/obj/machinery/hydroponics/T = C

	if(!src.on)
		return

	if(!istype(T))
		src.oldtray = src.tray
		src.tray = null
		src.currently_gardening = 0
		src.last_found = world.time
		return

	switch(mode)
		if(1)
			icon_state = "farmbot_water"
		if(2)
			icon_state = "farmbot_fertile"
		if(3)
			icon_state = "farmbot_hoe"

	visible_message("\red <B>[src] does some work on [src.tray]!</B>")
	spawn(30)
		if ((get_dist(src, src.tray) <= 1) && (src.on))
			switch(mode)
				if(1)
					T.adjustWater(rand(1,10))
				if(2)
					T.adjustHealth(rand(1,10))
					T.adjustNutri(rand(1,10))
				if(3)
					T.adjustPests(-rand(1,5))
					T.adjustWeeds(-rand(1,5))
			if(T.dead)
				T.planted = 0
				T.dead = 0
				del(T.myseed)
				T.update_icon()
			icon_state = "farmbot[src.on]"
			visible_message("\red <B>[src] finishes it's work!</B>")
		src.currently_gardening = 0
		T.update_icon()
		return
	return

/obj/machinery/bot/harvestbot/Bump(M as mob|obj)
	if ((istype(M, /obj/machinery/door)) && (!isnull(src.botcard)))
		var/obj/machinery/door/D = M
		if (!istype(D, /obj/machinery/door/firedoor) && D.check_access(src.botcard))
			D.open()
	else if ((istype(M, /mob/living/)) && (!src.anchored))
		src.loc = M:loc
	return

//assemble

/obj/item/weapon/tank_arm_assembly
	name = "water tank/robot arm assembly"
	desc = "A water tank with a robot arm haphazardly jammed into it."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "water_arm"
	var/build_step = 0
	var/created_name = "HarvestBot"
	w_class = 3.0

/obj/structure/reagent_dispensers/watertank/attackby(var/obj/item/robot_parts/S, mob/user as mob)
	if ((!istype(S, /obj/item/robot_parts/l_arm)) && (!istype(S, /obj/item/robot_parts/r_arm)))
		..()
		return
	var/obj/item/weapon/tank_arm_assembly/A = new /obj/item/weapon/tank_arm_assembly
	del(S)
	user.put_in_hands(A)
	user << "<span class='notice'>You add the robot arm to the water tank.</span>"
	del(src)

/obj/item/weapon/tank_arm_assembly/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", src.name, src.created_name),1,MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return
		src.created_name = t
	else
		switch(build_step)
			if(0)
				if(istype(W, /obj/item/weapon/minihoe))
					user.drop_item()
					del(W)
					src.build_step++
					user << "<span class='notice'>You add the hoe to [src].</span>"
					src.name = "water tank/robot arm assembly with hoe"
			if(1)
				if(istype(W,/obj/item/weapon/reagent_containers/glass/bucket))
					user.drop_item()
					del(W)
					src.build_step++
					user << "<span class='notice'>You add the bucket to [src].</span>"
					src.name = "water tank/robot arm assembly with hoe and bucket"
			if(2)
				if(isprox(W))
					user.drop_item()
					del(W)
					src.build_step++
					user << "<span class='notice'>You complete the HarvestBot! Beep boop.</span>"
					var/turf/T = get_turf(src)
					var/obj/machinery/bot/harvestbot/S = new /obj/machinery/bot/harvestbot(T)
					S.name = src.created_name
					user.drop_from_inventory(src)
					del(src)