/datum/surgery/xenodechitin
	name = "alien chitin removal"
	steps = list(/datum/surgery_step/alien/armor_check, /datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/alien/saw, /datum/surgery_step/extract_xenochitin, /datum/surgery_step/close)
	species = list(/mob/living/carbon/alien/humanoid)
	location = "chest"

/datum/surgery_step/extract_xenochitin
	implements = list(/obj/item/weapon/circular_saw = 100, /obj/item/weapon/hatchet = 35, /obj/item/weapon/butch = 25)
	time = 64
	var/obj/item/organ/achitin/A = null

/datum/surgery_step/extract_xenochitin/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	A = locate() in target.internal_organs
	if(A)
		user.visible_message("<span class='notice'>[user] begins to pry off [target]'s armor.</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for remaining armor on [target].</span>")

/datum/surgery_step/extract_xenochitin/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(A)
		user.visible_message("<span class='notice'>[user] successfully removes [target]'s armor!</span>")
		A.loc = get_turf(target)
		target.internal_organs -= A
		var/mob/living/carbon/alien/humanoid/B = target
		B.maxHealth = B.maxHealth/2
	else
		user.visible_message("<span class='notice'>[user] can't find any more armor on [target]!</span>")
	return 1

/datum/surgery/xenodeclaw
	name = "alien declawing"
	steps = list(/datum/surgery_step/alien/armor_check, /datum/surgery_step/alien/saw, /datum/surgery_step/retract_skin, /datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/extract_xenoclaw, /datum/surgery_step/close)
	species = list(/mob/living/carbon/alien/humanoid)
	location = "l_arm"

/datum/surgery_step/extract_xenoclaw
	implements = list(/obj/item/weapon/circular_saw = 100, /obj/item/weapon/hatchet = 35, /obj/item/weapon/butch = 25)
	time = 64
	var/obj/item/organ/aclaws/A = null

/datum/surgery_step/extract_xenoclaw/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	A = locate() in target.internal_organs
	if(A)
		user.visible_message("<span class='notice'>[user] begins to remove [target]'s claws.</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for claws on [target].</span>")

/datum/surgery_step/extract_xenoclaw/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(A)
		user.visible_message("<span class='notice'>[user] successfully removes [target]'s claws!</span>")
		A.loc = get_turf(target)
		target.internal_organs -= A
		var/mob/living/carbon/alien/humanoid/B = target
		B.has_fine_manipulation = 1
	else
		user.visible_message("<span class='notice'>[user] can't find any claws on [target]!</span>")
	return 1

/datum/surgery/xenodetail
	name = "alien deveining"
	steps = list(/datum/surgery_step/alien/armor_check, /datum/surgery_step/alien/saw, /datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/incise, /datum/surgery_step/extract_xenotail, /datum/surgery_step/close)
	species = list(/mob/living/carbon/alien/humanoid)
	location = "groin"


//Got to check if xeno's armor is up


/datum/surgery_step/extract_xenotail
	implements = list(/obj/item/weapon/hemostat = 100, /obj/item/weapon/crowbar = 55)
	time = 64
	var/obj/item/organ/avein/A = null

/datum/surgery_step/extract_xenotail/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	A = locate() in target.internal_organs
	if(A)
		user.visible_message("<span class='notice'>[user] begins to extract [target]'s tail vein.</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for a tail vein in [target].</span>")

/datum/surgery_step/extract_xenotail/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(A)
		user.visible_message("<span class='notice'>[user] successfully removes [target]'s tail vein!</span>")
		A.loc = get_turf(target)
		target.internal_organs -= A
		var/mob/living/carbon/alien/humanoid/B = target
		B.verbs.Remove(/mob/living/carbon/alien/humanoid/proc/resin,/mob/living/carbon/alien/humanoid/proc/corrosive_acid,
			/mob/living/carbon/alien/humanoid/proc/neurotoxin,/mob/living/carbon/alien/humanoid/verb/transfer_plasma,
			/mob/living/carbon/alien/humanoid/verb/plant,/mob/living/carbon/alien/humanoid/drone/verb/evolve)
	else
		user.visible_message("<span class='notice'>[user] can't find a tail vein in [target]!</span>")
	return 1