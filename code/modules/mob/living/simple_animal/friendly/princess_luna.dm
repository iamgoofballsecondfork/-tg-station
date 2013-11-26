//LUNA! SQUEEEEEEEEE~
/mob/living/simple_animal/princess_luna
	name = "Princess Luna"
	real_name = "Princess Luna"
	gender = FEMALE
	desc = "It's Luuuuuunnaaaaaaa <3"
	icon_state = "princess_luna"
	icon_living = "princess_luna"
	icon_dead = null
	speak = list("Ha ha! The fun has been doubled!", "Huzzah! How many points do I receive?","Hello, everypony. Did I miss anything?")
	speak_emote = list("says")
	emote_hear = list("screams")
	emote_see = list("shakes her head", "shivers")
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	speak_chance = 3
	attacktext = "fires a magical beam at"
	melee_damage_lower = 0
	melee_damage_upper = 0

/mob/living/simple_animal/princess_luna/Life()
	..()

/mob/living/simple_animal/princess_luna/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if("help")	wuv(1,M)
		if("harm")	wuv(-1,M)

/mob/living/simple_animal/princess_luna/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			if(M)	flick_overlay(image('icons/mob/animal.dmi',src,"heart-ani2",MOB_LAYER+1), list(M.client), 20)
			emote("laughs happily")
		else
			emote("growls")
