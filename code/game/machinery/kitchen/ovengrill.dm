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

/obj/machinery/govern/verb/TogglePower()