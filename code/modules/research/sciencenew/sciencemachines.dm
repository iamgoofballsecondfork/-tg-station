//this is designed to replace the destructive analyzer

#define SCANTYPE_POKE 1
#define SCANTYPE_IRRADIATE 2
#define SCANTYPE_GAS 3
#define SCANTYPE_HEAT 4
#define SCANTYPE_COLD 5
#define SCANTYPE_OBLITERATE 6

/obj/machinery/r_n_d/experimentor
	name = "Experimentor"
	icon = 'icons/obj/machines/heavy_lathe.dmi'
	icon_state = "h_lathe"
	density = 1
	anchored = 1
	use_power = 1
	var/obj/item/weapon/loaded_item = null

/obj/machinery/r_n_d/experimentor/proc/ConvertReqString2List(var/list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list


/obj/machinery/r_n_d/experimentor/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/destructive_analyzer(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(src)
	RefreshParts()

/obj/machinery/r_n_d/experimentor/attackby(var/obj/O as obj, var/mob/user as mob)
	if (shocked)
		shock(user,50)
	if (istype(O, /obj/item/weapon/screwdriver))
		if (!opened)
			opened = 1
			if(linked_console)
				linked_console.linked_destroy = null
				linked_console = null
			icon_state = "d_analyzer_t"
			user << "You open the maintenance hatch of [src]."
		else
			opened = 0
			icon_state = "d_analyzer"
			user << "You close the maintenance hatch of [src]."
		return
	if (opened)
		if(istype(O, /obj/item/weapon/crowbar))
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/I in component_parts)
				I.loc = src.loc
			del(src)
			return 1
		else
			user << "\red You can't load the [src.name] while it's opened."
			return 1
	if (disabled)
		return
	if (!linked_console)
		user << "\red The [src] must be linked to an R&D console first!"
		return
	if (busy)
		user << "\red The [src] is busy right now."
		return
	if (istype(O, /obj/item) && !loaded_item)
		if(!O.origin_tech)
			user << "\red This doesn't seem to have a tech origin!"
			return
		var/list/temp_tech = ConvertReqString2List(O.origin_tech)
		if (temp_tech.len == 0)
			user << "\red You cannot experiment on this item!"
			return
		if(O.reliability < 90 && O.crit_fail == 0)
			usr << "\red Item is neither reliable enough or broken enough to learn from."
			return
		busy = 1
		loaded_item = O
		user.drop_item()
		O.loc = src
		user << "\blue You add the [O.name] to the machine!"
		flick("h_lathe_load", src)
		spawn(10)
			icon_state = "h_lathe_wloop"
			busy = 0
	return

/*

	else if(href_list["eject_item"]) //Eject the item inside the destructive analyzer.
		if(linked_destroy)
			if(linked_destroy.busy)
				usr << "\red The destructive analyzer is busy at the moment."

			else if(linked_destroy.loaded_item)
				linked_destroy.loaded_item.loc = linked_destroy.loc
				linked_destroy.loaded_item = null
				linked_destroy.icon_state = "d_analyzer"
				screen = 2.1

	else if(href_list["deconstruct"]) //Deconstruct the item in the destructive analyzer and update the research holder.
		if(linked_destroy)
			if(linked_destroy.busy)
				usr << "\red The experimentor is busy at the moment."
			else
				var/choice = input("Proceeding will destroy loaded item.") in list("Proceed", "Cancel")
				if(choice == "Cancel" || !linked_destroy) return
				linked_destroy.busy = 1
				screen = 0.1
				updateUsrDialog()
				flick("d_analyzer_process", linked_destroy)
				spawn(24)
					if(linked_destroy)
						linked_destroy.busy = 0
						if(!linked_destroy.hacked)
							if(!linked_destroy.loaded_item)
								usr <<"\red The destructive analyzer appears to be empty."
								screen = 1.0
								return
							if(linked_destroy.loaded_item.reliability >= 90)
								var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
								for(var/T in temp_tech)
									files.UpdateTech(T, temp_tech[T])
							if(linked_destroy.loaded_item.reliability < 100 && linked_destroy.loaded_item.crit_fail)
								files.UpdateDesign(linked_destroy.loaded_item.type)
							if(linked_lathe) //Also sends salvaged materials to a linked protolathe, if any.
								linked_lathe.m_amount += min((linked_lathe.max_material_storage - linked_lathe.TotalMaterials()), (linked_destroy.loaded_item.m_amt*linked_destroy.decon_mod))
								linked_lathe.g_amount += min((linked_lathe.max_material_storage - linked_lathe.TotalMaterials()), (linked_destroy.loaded_item.g_amt*linked_destroy.decon_mod))
							linked_destroy.loaded_item = null
						for(var/obj/I in linked_destroy.contents)
							for(var/mob/M in I.contents)
								M.death()
							if(istype(I,/obj/item/stack/sheet))//Only deconsturcts one sheet at a time instead of the entire stack
								var/obj/item/stack/sheet/S = I
								if(S.amount > 1)
									S.amount--
									linked_destroy.loaded_item = S
								else
									del(S)
									linked_destroy.icon_state = "d_analyzer"
							else
								if(!(I in linked_destroy.component_parts))
									del(I)
									linked_destroy.icon_state = "d_analyzer"
						use_power(250)
						screen = 1.0
						updateUsrDialog()

*/