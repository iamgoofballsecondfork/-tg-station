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

/mob/living/simple_animal/spidermmi/New()
	..()
	verbs += /mob/living/simple_animal/spidermmi/verb/itemize
	verbs += /mob/living/simple_animal/spidermmi/verb/ventcrawl

/mob/living/simple_animal/spidermmi/Die()
	..()
	var/obj/item/organ/brain/B = new(src.loc)
	src.loc = B//Throw mob into brain.
	B.brainmob = src//Set the brain to use the brainmob
	B.brainmob.cancel_camera()

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