//This is a redesign of the AntiMatter engine
//Some parts corrected/contributed by Head (Sebastian) of Baystation12
/obj/effect/hadron/particle
	name = "Hadron Particle"
	desc = "If you can see this, you are probably dead ten minutes ago."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "energy2"
	var/powercarried = 0
	var/passing = 0
	var/lastdirection = WEST
	var/list/clockwise = list( NORTH, EAST, SOUTH, WEST )

/obj/effect/hadron/particle/process()
	if(dir != lastdirection)
		dir = lastdirection
		update_icon()

/obj/effect/hadron/particle/proc/shoo()
	for(var/direction in clockwise)
		if(direction != lastdirection)
			var/turf/currentTile = get_step(src.loc,direction)
			var/obj/machinery/power/hadron/machine = locate(/obj/machinery/power/hadron) in currentTile
			if(machine)
				src.loc = machine
				lastdirection = reverse_direction(direction)
				return
//////////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/power/hadron
	name = "Hadron Collider"
	desc = "Part of a Hadron Collider."
	icon = 'icons/obj/hadron.dmi'
	icon_state = "none"
	anchored = 1
	density = 1
	var/hasparticle = 0

/obj/machinery/power/hadron/bouncer
	name = "Hadron Collider Repeater"
	desc = "Part of a Hadron Collider, this accelerates the particles."
	icon_state = "hadron-tl"
	var/obj/machinery/power/hadron/console/Main = null

/obj/machinery/power/hadron/bouncer/New()
	..()
	spawn(1)
		Main = locate(/obj/machinery/power/hadron/console) in orange(30,src)
	if(!Main)
		spawn(15)
			Main = locate(/obj/machinery/power/hadron/console) in orange(60,src)

/obj/machinery/power/hadron/bouncer/process()
	for(var/obj/effect/D in contents)
		if(istype(D,/obj/effect/hadron/particle))
			luminosity = 5
			var/obj/effect/hadron/particle/T = D
			if(!T.passing)
				T.passing = 1
			T.powercarried += Main.fuel_usage
			T.shoo()
			spawn(65)
				luminosity = 0
		else
			del(D)

/obj/machinery/power/hadron/pipe
	name = "Hadron Collider Pipe"
	desc = "Part of a Hadron Collider, this funnels the particles."
	icon_state = "hadron-r"

/obj/machinery/power/hadron/pipe/process()
	for(var/obj/effect/D in contents)
		if(istype(D,/obj/effect/hadron/particle))
			luminosity = 5
			var/obj/effect/hadron/particle/T = D
			if(!T.passing)
				T.passing = 1
			T.shoo()
			spawn(65)
				luminosity = 0
		else
			del(D)

/obj/machinery/power/hadron/console
	name = "Hadron Collider Console"
	desc = "Part of a Hadron Collider, this controls the Hadron."
	icon = 'icons/obj/hadron.dmi'
	icon_state = "hadron-console"
	anchored = 1
	density = 1
	use_power = 1
	idle_power_usage = 100
	active_power_usage = 250
	var/on = 0
	var/stored = 0
	var/cycletime = 30
	var/fuel_usage = 2
	var/obj/effect/hadron/particle/hadronparticle = null
	var/obj/item/weapon/am_containment/fueljar = null
	var/SWEET_TOXIC = 0
	var/SWEET_BLACKHOLE = 0
	var/SWEET_WELLSHIT = 0

/obj/machinery/power/hadron/console/New()
	..()
	spawn(1)
		SWEET_TOXIC = rand(1,100)
		SWEET_BLACKHOLE = rand(1,50)
		SWEET_WELLSHIT = rand(1,10)

/obj/machinery/power/hadron/console/attack_hand(mob/user as mob)
	if(anchored)
		interact(user)
	return

/obj/machinery/power/hadron/console/proc/produce_power(var/input)
	var/fuel = fueljar.usefuel(input)
	if(fuel == input)
		playsound(src.loc, 'sound/effects/phasein.ogg', 25, 1)
		stored = (fuel/input)*fuel*200000
	else
		playsound(src.loc, 'sound/effects/EMPulse.ogg', 25, 1)
		if(prob(SWEET_TOXIC))
			for(var/mob/living/M in range(25))
				var/radiation = (input)
				M.apply_effect((radiation*3),IRRADIATE,0)
				M.updatehealth()
		if(prob(SWEET_BLACKHOLE))
			command_alert("We appear to be experiencing a localised bend in space and time around the engine, please stand by.")
			spawn(60)
				var/datum/round_event_control/wormholes/W = new()
				W.runEvent()
		if(prob(SWEET_WELLSHIT))
			command_alert("ALERT: Hadron-initiated bioanomaly detected; Please evacuate all departments and proceed to safe zones.")
			for(var/turf/simulated/floor/T in world)
				if(T.z == 1)
					if(prob(1))
						var/obj/effect/rift/R = new(T.loc)
						R.name = "bioanomaly [rand(1,1000)]"
	return

/obj/machinery/power/hadron/console/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/am_containment))
		if(fueljar)
			user << "\red There is already a [fueljar] inside!"
			return
		user.drop_item()
		fueljar = W
		W.loc = src
		user.update_icons()
		user.visible_message("[user.name] loads a [W.name] into the [src.name].", \
				"You load a [W.name].", \
				"You hear a thunk.")
		return

/obj/machinery/power/hadron/console/process()
	if(on && fueljar)
		spawn(cycletime)
			if(!hadronparticle)
				hadronparticle = new(src)
				hadronparticle.shoo()
		add_avail(stored)
		for(var/obj/effect/D in contents)
			if(istype(D,/obj/effect/hadron/particle))
				var/obj/effect/hadron/particle/T = D
				if(T.passing)
					produce_power(T.powercarried)
					del(T)
					hadronparticle = null

/obj/machinery/power/hadron/console/interact(mob/user)
	if((get_dist(src, user) > 1) || (stat & (BROKEN|NOPOWER)))
		if(!istype(user, /mob/living/silicon/ai))
			user.unset_machine()
			user << browse(null, "window=Hadron")
			return
	user.set_machine(src)

	var/dat = ""
	dat += "Hadron Control Panel<BR>"
	dat += "Status: [(on?"Firing":"Standby")] <BR>"
	dat += "<A href='?src=\ref[src];togglestatus=1'>Toggle</A><BR>"
	dat += "Output: [stored]<BR>"
	dat += "Particles fuel left: "
	if(!fueljar)
		dat += "<BR>No fuel receptacle detected."
	else
		dat += "[fueljar.fuel]/[fueljar.fuel_max] units<BR>"
		dat += "Firing: [fuel_usage] units "
		dat += "- <A href='?src=\ref[src];strengthdown=1'>--</A>|<A href='?src=\ref[src];strengthup=1'>++</A><BR><BR>"
		dat += "<A href='?src=\ref[src];ejectjar=1'>Eject</A><BR>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh</A><BR>"
	dat += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
	var/datum/browser/popup = new(user, "Hadron","Hadron Control Panel", 420, 500, src)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/power/hadron/console/proc/toggle_power()
	on = !on
	if(on)
		use_power = 2
		visible_message("The [src.name] starts up.")
	else
		use_power = 1
		visible_message("The [src.name] shuts down.")
	update_icon()
	return

/obj/machinery/power/hadron/console/Topic(href, href_list)
	if(..())
		return
	if(href_list["close"])
		usr << browse(null, "window=Hadron")
		usr.unset_machine()
		return
	if(href_list["togglestatus"])
		toggle_power()
	if(href_list["ejectjar"])
		if(fueljar)
			fueljar.loc = src.loc
			fueljar = null
	if(href_list["strengthup"])
		fuel_usage++
	if(href_list["strengthdown"])
		fuel_usage--
		if(fuel_usage < 0) fuel_usage = 0
	src.updateUsrDialog()
	return