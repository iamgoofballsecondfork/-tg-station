/*
This is a kitchen appliance to go along with the processor and the microwave. The Blender is for food items that are mixes or purees.
Currently, the end products of the blender are not compatable with the microwave but I hope to fix that eventually.

Summary of Blender Code: It's basically a large reagent container and, like any other container, reactions can occur in it. However,
unlike a normal container, if you stick certain kinds of "blendable" items (ie. many food products), it'll convert the food item from
an object (which you can pick up and eat) into a reagent (which you can pour and drink). Containers with reagents in it can be poured
directly into the blender. Other food items will be converted into reagents by the blender. When deciding whether should be made with
the blender or the processor: Processor items are solid objects and Blender results are reagents.
*/

/////////////////////////////////////////////////

/datum/blendable
	var/obj/item/weapon/reagent_containers/food/inserted
	var/list/datum/reagent/input_reagent = list()
	var/list/datum/reagent/output = list()

/proc/find_blendable(var/list/datum/blendable/availible, var/obj/obj as obj)
	var/list/datum/blendable/possible = new
	for(var/datum/blendable/blend in availible)
		if(istype(obj,blend.inserted))
			possible += blend
	if(possible.len == 0)
		return null
	else
		return possible[1]

/proc/find_whizzable(var/list/datum/blendable/availible, var/obj/src)
	var/list/datum/blendable/possible = new
	for(var/datum/blendable/blend in availible)
		var/checks = 0
		for(var/datum/reagent/R in blend.input_reagent)
			if(src.reagents.has_reagent(R))
				checks = checks + 1
			else
				break
		if(blend.input_reagent.len == checks)
			possible += blend
	if(possible.len == 0)
		return null
	else
		for(var/datum/blendable/blend in possible)
			for(var/datum/reagent/R in blend.input_reagent)
				src.reagents.remove_reagent(R,R.volume)
			break
		return possible[1]

///////////////////BLENDABLES/////////////////////

/datum/blendable/ketchup
	inserted = /obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	output = list("ketchup" = 5)

/datum/blendable/applesauce
	inserted = /obj/item/weapon/reagent_containers/food/snacks/grown/apple
	output = list("applesauce" = 5)

//////////////////////////////////////////////////

/obj/machinery/blender
	name = "Blender"
	desc = "A kitchen appliance used to blend stuff."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "blender_e"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 50
	var/global/list/datum/recipe/blendables_list = list()
	flags = OPENCONTAINER		//So that you can pour stuff into it.
	var/processing = 0			//This turns on (1) while it is processing so you don't accidentally get multiples from the same item.
	var/container = 1			//Is there a jug attached? Could have been done with a for loop but it's less code this way.

	New()
		var/datum/reagents/R = new/datum/reagents(100)		//Its large since you only get one.
		reagents = R
		R.my_atom = src
		src.contents += new /obj/item/weapon/reagent_containers/glass/blender_jug(src)
		src.container = "/obj/item/weapon/reagent_containers/glass/blender_jug"		//Loads a jug into the blender.
		for(var/type in (typesof(/datum/blendable) - /datum/blendable))
			blendables_list += new type

	on_reagent_change()			//When the reagents change, change the icon as well.
		update_icon()


	update_icon()			//Changes the icon depending on how full it is and whether it has the jug attached.
		if(src.container)
			switch(src.reagents.total_volume)
				if(0)
					src.icon_state = "blender_e"		//Empty
				if(1 to 75)
					src.icon_state = "blender_h"		//Some but not full
				if(76 to 100)
					src.icon_state = "blender_f"		//Mostly full.
		else
			src.icon_state = "blender_d"				//No jug. Should be redundant but just in case.
		return

/obj/machinery/blender/attackby(var/obj/item/O as obj, var/mob/user as mob)		//Attack it with an object.
	if(src.contents.len >= 10 || src.reagents.total_volume >= 80)		//Too full. Max 10 items or 80 units of reagent
		user << "Too many items are already in the blending chamber."
	else if(istype(O, /obj/item/weapon/reagent_containers/glass/blender_jug) && src.container == 0) //Load jug.
		O.reagents.trans_to(src, O.reagents.total_volume)
		del(O)
		src.contents += new /obj/item/weapon/reagent_containers/glass/blender_jug(src)
		//user.drop_item()
		//O.loc = src
		src.container = 1
		src.flags = OPENCONTAINER
		src.update_icon()
	else if(src.container == 0)											//No jug to load in to.
		user << "There is no container to put [O] in to!"
	else
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))	//Will only blend food items. Add others in this else clause.
			user.drop_item()
			O.loc = src
			user << "You drop the [O] into the blender."
		else if (istype(O, /obj/item/weapon/storage/bag/plants)) //Allows plant bags to empty into the blender.
			for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in O.contents)
				O.contents -= G
				G.loc = src
				if(src.contents.len >= 10 || src.reagents.total_volume >= 80) //Sanity checking so the blender doesn't overfill
					user << "You fill the blender to the brim."
					break
			if(src.contents.len < 10 && src.reagents.total_volume < 80)
				user << "You empty the plant bag into the blender."
		else
			user << "That probably won't blend."
	return 0


/obj/machinery/blender/verb/blend()		//Blend shit. Note: In the actual blending loop, make sure it can't include the jug.
	set category = "Object"
	set name = "Turn Blender On"
	set src in oview(1)					// Otherwise, it'll try to blend it too.
	if (usr.stat != 0)
		return
	if (src.stat != 0) //NOPOWER etc
		return
	if(src.processing)
		usr << "\red The blender is in the process of blending."
		return
	if(!src.container)
		usr << "\red The blender doesn't have an attached container!"
		return
	playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
	src.processing = 1
	usr << "\blue You turn on the blender."
	use_power(250)
	for(var/obj/O in src.contents)
		if(!istype(O, /obj/item/weapon/reagent_containers/glass/blender_jug))
			var/datum/blendable/blending = find_blendable(blendables_list,O)
			if(blending)
				for(var/datum/reagent/R in blending.output)
					src.reagents.add_reagent(R, R.volume)
				del(O)
				usr << "The contents of the blender have been blended."
			var/datum/blendable/whizzing = find_whizzable(blendables_list,src)
			if(whizzing)
				for(var/datum/reagent/R in whizzing.output)
					src.reagents.add_reagent(R, R.volume)
				usr << "The contents of the blender have been mixed."
	src.processing = 0
	return

/obj/machinery/blender/verb/detach()		//Transfers the contents of the Blender to the Blender Jug and then ejects the jug.
	set category = "Object"
	set name = "Detach Blender Jug"
	set src in oview(1)
	if (usr.stat != 0)
		return
	if(src.processing)
		usr << "The blender is in the process of blending."
	else if(!src.container)
		usr << "There is nothing to detach!"
	else
		for(var/obj/O in src.contents)			//Searches through the contents for the jug.
			if(istype(O, /obj/item/weapon/reagent_containers/glass/blender_jug))
				O.loc = get_turf(src)
				src.reagents.trans_to(O, src.reagents.total_volume)
				O = null
				src.flags = null
				src.icon_state = "blender_d"
				usr << "You detatch the blending jug."
		src.container = 0
	return

/obj/machinery/blender/verb/eject()			//Ejects the non-reagent contents of the blender besides the jug.
	set category = "Object"
	set name = "Empty Blender Jug"
	set src in oview(1)
	if (usr.stat != 0)
		return
	if(src.processing)
		usr << "The blender is in the process of blending."
	else if(!src.container)
		usr << "There is nothing to eject!"
	else
		for(var/obj/O in src.contents)
			if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
				O.loc = get_turf(src)
				O = null
	return