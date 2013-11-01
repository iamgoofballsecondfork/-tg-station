/mob/living/simple_animal/spidermmi
	name = "\improper spidermmi"
	real_name = "spidermmi"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a walking apparatus."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_spider"
	icon_living = "mmi_spider"
	icon_dead = "mmi_spider_dead"
	speak_chance = 0
	turns_per_move = 0
	response_help  = "prods"
	response_disarm = "swats"
	response_harm   = "smacks"
	see_in_dark = 5
	pass_flags = PASSTABLE
	var/alien = 0
	var/charge = 1
	var/obj/item/weapon/reagent_containers/glass/beaker/beaker


/mob/living/simple_animal/spidermmi/proc/check_charge()
	if(charge)
		return 1
	else
		src << "\blue Your circuits are still charging."
		return 0

/mob/living/simple_animal/spidermmi/proc/inject(mob/target,var/time)
	src << "\red You inject [target]."
	for(var/mob/O in oviewers())
		if ((O.client && !( O.blinded )))
			O << "\red [src] injects [target]!"
	beaker.reagents.trans_to(target, beaker.volume)
	charge = 0
	spawn(time)
		charge = 1

/mob/living/simple_animal/spidermmi/New()
	..()
	if(alien)
		icon_state = "mmi_spider_xeno"
		icon_living = "mmi_spider_xeno"
		icon_dead = "mmi_spider_xeno_dead"
	verbs += /mob/living/simple_animal/spidermmi/verb/itemize
	verbs += /mob/living/simple_animal/spidermmi/verb/ventcrawl
	verbs += /mob/living/simple_animal/spidermmi/verb/stun
	verbs += /mob/living/simple_animal/spidermmi/verb/tox
	verbs += /mob/living/simple_animal/spidermmi/verb/assist
	beaker = new(src)

/mob/living/simple_animal/spidermmi/Die()
	..()
	for(var/mob/V in viewers(src, null))
		V.show_message(text("\red [src] shudders and collapses, they need to be redeployed."))
	var/obj/item/device/mmi/spider/S = new(src.loc)
	S.to_item(src)
	del(src)

/mob/living/simple_animal/spidermmi/verb/ventcrawl()
	set name = "Enter Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "SpiderMMI"
	handle_ventcrawl()

/mob/living/simple_animal/spidermmi/verb/itemize()
	set name = "Retract"
	set category = "SpiderMMI"
	for(var/mob/V in viewers(src, null))
		V.show_message(text("\blue [src] retracts it's appendages, ready to be handled."))
	var/obj/item/device/mmi/spider/S = new(src.loc)
	S.to_item(src)
	del(src)

/mob/living/simple_animal/spidermmi/verb/stun(mob/target as mob in oview(2))
	set name = "Sleep Injection (30s)"
	set category = "SpiderMMI"
	if(check_charge())
		beaker.reagents.add_reagent("stoxin", 5)
		inject(target,30)


/mob/living/simple_animal/spidermmi/verb/tox(mob/target as mob in oview(2))
	set name = "Toxic Injection (60s)"
	set category = "SpiderMMI"
	if(check_charge())
		beaker.reagents.add_reagent("lexorin", 5)
		inject(target,60)

/mob/living/simple_animal/spidermmi/verb/assist(mob/target as mob in oview(2))
	set name = "Stabilizing Injection (120s)"
	set category = "SpiderMMI"
	if(check_charge())
		beaker.reagents.add_reagent("inaprovaline", 5)
		beaker.reagents.add_reagent("leporazine", 5)
		beaker.reagents.add_reagent("tricordrazine", 5)
		inject(target,120)