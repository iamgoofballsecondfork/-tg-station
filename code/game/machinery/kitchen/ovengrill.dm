/obj/machinery/goven
	name = "Oven with Grill"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "goven"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 150
	flags = OPENCONTAINER | NOREACT
	var/power = 1
	var/on = 0
	var/dirty = 0
	var/broken = 0

/obj/machinery/goven/verb/TogglePower()
	set category = "Kitchen"
	set name = "Toggle Heat Level"
	set src in oview(1)
	if(power < 4)
		power = power + 1
	else
		power = 1
	on = 0
	ToggleGrills()


/obj/machinery/goven/verb/ToggleGrills()
	set category = "Kitchen"
	set name = "Toggle Grills"
	set src in oview(1)
	var/image/burnera = image('icons/obj/kitchen.dmi', src, "goven_burna")
	var/image/burnerb = image('icons/obj/kitchen.dmi', src, "goven_burnb")
	var/image/burnerc = image('icons/obj/kitchen.dmi', src, "goven_burnc")
	var/image/burnerd = image('icons/obj/kitchen.dmi', src, "goven_burnd")
	overlays.Cut()
	if(!on)
		on = 1
		switch(power)
			if(1)
				overlays += burnera
			if(2)
				overlays += burnera
				overlays += burnerb
			if(3)
				overlays += burnera
				overlays += burnerb
				overlays += burnerc
			if(4)
				overlays += burnera
				overlays += burnerb
				overlays += burnerc
				overlays += burnerd
	else
		on = 0

/obj/machinery/goven/New()
	create_reagents(100)