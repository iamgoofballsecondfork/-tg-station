/obj/item/cigs
	name = "cigarette box"
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigpacket"
	desc = "Used to roll cigarettes."
	w_class = 1.0

/obj/item/cigs/paper
	name = "rolling paper"
	icon_state = "cig paper"

/obj/item/cigs/filter
	name = "cigarette filter"
	icon_state = "cig filter"

/obj/item/cigs/ground_insert
	name = "ground plants"
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	flags = NOREACT
	var/needs_filter = 1

/obj/item/cigs/ground_insert/New()
	..()
	create_reagents(30)

/obj/item/weapon/storage/snuffbox
	name = "tabacco box"
	desc = "Holds your 'tabacco' so you dont have to smoke pocket lint."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "snuffbox"
	item_state = "snuffbox"
	w_class = 1
	throwforce = 2
	flags = TABLEPASS
	slot_flags = SLOT_BELT
	storage_slots = 8
	can_hold = list("/obj/item/cigs/ground_insert")

/obj/item/weapon/storage/snuffbox/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/cigs/ground_insert(src)
	return


//ash grinder

/obj/machinery/ashgrinder
	name = "Plant Grinder"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "ashblend"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	var/inuse = 0
	var/limit = 3
	var/list/holdingitems = list()

/obj/machinery/ashgrinder/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(holdingitems && holdingitems.len >= limit)
		usr << "The machine cannot hold anymore items."
		return 1
	if(istype(O, /obj/item/weapon/storage/bag/plants))
		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in O.contents)
			O.contents -= G
			G.loc = src
			holdingitems += G
			if(holdingitems && holdingitems.len >= limit)
				user << "You fill the [src] to the brim."
				break
		if(!O.contents.len)
			user << "You empty the plant bag into the [src]."
		src.updateUsrDialog()
		return 0
	user.before_take_item(O)
	O.loc = src
	holdingitems += O
	src.updateUsrDialog()
	return 0

/obj/machinery/ashgrinder/attack_paw(mob/user as mob)
		return src.attack_hand(user)

/obj/machinery/ashgrinder/attack_ai(mob/user as mob)
		return 0

/obj/machinery/ashgrinder/attack_hand(mob/user as mob)
		user.set_machine(src)
		interact(user)

/obj/machinery/ashgrinder/interact(mob/user as mob)
	var/is_chamber_empty = 0
	var/processing_chamber = ""
	var/dat = ""
	if(!inuse)
		for (var/obj/item/O in holdingitems)
			processing_chamber += "\A [O.name]<BR>"
		if (!processing_chamber)
			is_chamber_empty = 1
			processing_chamber = "Nothing."
		else
			dat = {"<b>Processing chamber contains:</b><br>[processing_chamber]<br>"}
			if (!is_chamber_empty && !(stat & (NOPOWER|BROKEN)))
				dat += "<A href='?src=\ref[src];action=grind'>Grind the reagents</a><BR>"
			if(holdingitems && holdingitems.len > 0)
				dat += "<A href='?src=\ref[src];action=eject'>Eject the reagents</a><BR>"
	else
		dat += "Please wait..."
	user << browse("<HEAD><TITLE>Processing Chamber</TITLE></HEAD><TT>[dat]</TT>", "window=ashgrinder")
	onclose(user, "ashgrinder")
	return


/obj/machinery/ashgrinder/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	switch(href_list["action"])
		if ("grind")
			grind()
		if("eject")
			eject()
	src.updateUsrDialog()
	return

/obj/machinery/ashgrinder/proc/eject()
	if (usr.stat != 0)
		return
	if (holdingitems && holdingitems.len == 0)
		return
	for(var/obj/item/O in holdingitems)
		O.loc = src.loc
		holdingitems -= O
	holdingitems = list()

/obj/machinery/ashgrinder/proc/grind()
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
	inuse = 1
	spawn(60)
		inuse = 0
		interact(usr)
	var/obj/item/cigs/ground_insert/T = new(src.loc)
	for (var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
		if(O.reagents)
			var/space = T.reagents.maximum_volume - T.reagents.total_volume
			O.reagents.trans_to(T,min(O.reagents.total_volume, space))
			holdingitems -= O
			del(O)


//rolling

/obj/item/cigs/ground_insert/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if(istype(O, /obj/item/cigs/paper))
		user.visible_message("<span class='notice'>[user] lines the [src] up in the [O].")
		icon = 'icons/obj/cigarettes.dmi'
		src.icon_state = "cig ash"
		needs_filter = 0
		del(O)
	if(istype(O, /obj/item/cigs/filter))
		if(!src.needs_filter)
			var/obj/item/clothing/mask/cigarette/cigar/blunt/B = new(user.loc)
			src.reagents.trans_to(B,src.reagents.total_volume)
			del(O)
			del(src)
		else
			user << "You need to place something in the cigarette paper first"
			return

//cigs

//blunts
/obj/item/clothing/mask/cigarette/cigar/blunt
	name = "'Special' Cigar"
	desc = "Some call him.. Edgar"
	smoketime = 5200
	chem_volume = 30

/obj/item/clothing/mask/cigarette/cigar/blunt/New()
	..()
	var/skin = pick(1,2,3)
	switch(skin)
		if(1)
			icon_on = "cigon"
			icon_off = "cigoff"
			icon_state = "cigoff"
			item_state = "cigoff"
			type_butt = /obj/item/weapon/cigbutt
		if(2)
			icon_state = "cigaroff"
			icon_on = "cigaron"
			icon_off = "cigaroff"
			item_state = "cigaroff"
			type_butt = /obj/item/weapon/cigbutt/cigarbutt
		if(3)
			icon_state = "cigar2off"
			icon_on = "cigar2on"
			icon_off = "cigar2off"
			type_butt = /obj/item/weapon/cigbutt/cigarbutt