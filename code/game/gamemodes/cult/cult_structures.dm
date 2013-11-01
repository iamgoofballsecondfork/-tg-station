/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'

/obj/structure/cult/talisman
	name = "Altar"
	desc = "A bloodstained altar dedicated to Nar-Sie"
	icon_state = "talismanaltar"


/obj/structure/cult/forge
	name = "Daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie"
	icon_state = "forge"

/obj/structure/cult/pylon
	name = "Pylon"
	desc = "A floating crystal that hums with an unearthly energy"
	icon_state = "pylon"
	luminosity = 5

/obj/structure/cult/tome
	name = "Desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl"
	icon_state = "tomealtar"
//	luminosity = 5

//sprites for this no longer exist	-Pete
//(they were stolen from another game anyway)
/*
/obj/structure/cult/pillar
	name = "Pillar"
	desc = "This should not exist"
	icon_state = "pillar"
	icon = 'magic_pillar.dmi'
*/

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back"
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = 1
	unacidable = 1
	anchored = 1.0
	var/gateways = list()

/obj/effect/gateway/proc/connect_gateways()
	gateways = locate(/obj/effect/gateway) in /obj/effect/

/obj/effect/gateway/proc/do_teleport(mob/M as mob|obj)
	connect_gateways()
	if(gateways)
		var/obj/effect/gateway/destination = pick(gateways)
		if(destination == src)
			M << "\red The eldritch powers are weak in this location"
		else
			M << "\blue You feel strong powers pulling you to another location"
			M.loc = get_step(destination.loc, SOUTH)
			M.dir = SOUTH

/obj/effect/gateway/New()
	..()
	connect_gateways()

/obj/effect/gateway/Bumped(mob/M as mob|obj)
	spawn(0)
		do_teleport(M)
	return

/obj/effect/gateway/Crossed(AM as mob|obj)
	spawn(0)
		do_teleport(AM)
	return