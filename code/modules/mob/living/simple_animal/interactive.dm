#define INTERACTING 1
#define TRAVEL 2
#define FIGHTING 3

//TRAITS

#define TRAIT_ROBUST 64
#define TRAIT_UNROBUST 65
#define TRAIT_SMART 66
#define TRAIT_DUMB 67
#define TRAIT_MEAN 68
#define TRAIT_FRIENDLY 69
#define TRAIT_THIEVING 70

/*
	NPC VAR EXPLANATIONS (for modules and other things)

		doing = their current action, INTERACTING, TRAVEL or FIGHTING
		interest = how interested the NPC is in the situation, if they are idle, this drops
		timeout = this is internal
		TARGET = their current target
		LAST_TARGET = their last target
		nearby = a list of nearby mobs
		best_force = the highest force object, used for checking when to swap items

		MYID = their ID card
		MYPDA = their PDA
		main_hand = what is in their "main" hand (chosen from left > right)
		TRAITS = the traits assigned to this npc
		mymjob = the job assigned to the npc

		robustness = the chance for the npc to hit something
		smartness = the inverse chance for an npc to do stupid things
		attitude = the chance for an npc to do rude or mean things
		slyness = the chance for an npc to do naughty things ie thieving

		functions = the list of procs that the npc will use for modules

		graytide = shitmin var to make them go psycho
*/

/mob/living/carbon/human/interactive
	name = "interactive station member"
	var/doing = 0
	var/interest = 100
	var/timeout = 0
	var/atom/TARGET = null
	var/atom/LAST_TARGET = null
	var/list/nearby = list()
	var/best_force = 0
	//Job and mind data
	var/obj/item/weapon/card/id/MYID
	var/obj/item/device/pda/MYPDA
	var/obj/item/main_hand
	var/TRAITS = 0
	var/datum/job/myjob
	//trait vars
	var/robustness = 50
	var/smartness = 50
	var/attitude = 50
	var/slyness = 50
	var/graytide = 0
	//modules
	var/list/functions = list()

/mob/living/carbon/human/interactive/proc/random()
	//this is here because this has no client/prefs/brain whatever, and im lazy. copy my pasta, go fuck yourself
	underwear = random_underwear(gender)
	skin_tone = random_skin_tone()
	hair_style = random_hair_style(gender)
	facial_hair_style = random_facial_hair_style(gender)
	hair_color = random_short_color()
	facial_hair_color = hair_color
	eye_color = random_eye_color()
	age = rand(AGE_MIN,AGE_MAX)
	ready_dna(src,random_blood_type())
	//job handling
	var/list/jobs = job_master.occupations
	for(var/datum/job/J in jobs)
		if(J.title == "Cyborg" || J.title == "AI" || J.title == "Chaplain" || J.title == "Mime")
			jobs -= J
	myjob = pick(jobs)
	if(!graytide)
		myjob.equip(src)
	myjob.apply_fingerprints(src)
	src.job = myjob
	//
	var/obj/S = null
	for(var/obj/effect/landmark/start/sloc in landmarks_list)
		if(sloc.name != myjob.title)	continue
		if(locate(/mob/living) in sloc.loc)	continue
		S = sloc
		break
	if(!S)
		S = locate("start*[myjob.title]") // use old stype
	if(istype(S, /obj/effect/landmark/start) && istype(S.loc, /turf))
		src.loc = S.loc

/mob/living/carbon/human/interactive/New()
	..()
	gender = pick(MALE,FEMALE)
	if(gender == MALE)
		name = "[pick(first_names_male)] [pick(last_names)]"
		real_name = name
	else
		name = "[pick(first_names_female)] [pick(last_names)]"
		real_name = name
	random()
	MYID = new(src)
	MYID.name = "[src.real_name]'s ID Card ([myjob.title])"
	MYID.assignment = "[myjob.title]"
	MYID.registered_name = src.real_name
	MYID.access = myjob.access
	src.equip_to_slot_or_del(MYID, slot_wear_id)
	MYPDA = new(src)
	MYPDA.owner = src.real_name
	MYPDA.ownjob = "Crew"
	MYPDA.name = "PDA-[src.real_name] ([myjob.title])"
	src.equip_to_slot_or_del(MYPDA, slot_belt)

	if(prob(10)) //my x is augmented
		//arms
		if(prob(50))
			var/obj/item/organ/limb/r_arm/R = locate(/obj/item/organ/limb/r_arm) in organs
			del(R)
			organs += new /obj/item/organ/limb/robot/r_arm
		else
			var/obj/item/organ/limb/l_arm/L = locate(/obj/item/organ/limb/l_arm) in organs
			del(L)
			organs += new /obj/item/organ/limb/robot/l_arm
		//legs
		if(prob(50))
			var/obj/item/organ/limb/r_leg/R = locate(/obj/item/organ/limb/r_leg) in organs
			del(R)
			organs += new /obj/item/organ/limb/robot/r_leg
		else
			var/obj/item/organ/limb/l_leg/L = locate(/obj/item/organ/limb/l_leg) in organs
			del(L)
			organs += new /obj/item/organ/limb/robot/l_leg
		//chest and head
		if(prob(50))
			var/obj/item/organ/limb/chest/R = locate(/obj/item/organ/limb/chest) in organs
			del(R)
			organs += new /obj/item/organ/limb/robot/chest
		else
			var/obj/item/organ/limb/head/L = locate(/obj/item/organ/limb/head) in organs
			del(L)
			organs += new /obj/item/organ/limb/robot/head
		for(var/obj/item/organ/limb/LIMB in organs)
			LIMB.owner = src
	update_icons()
	update_damage_overlays(0)
	update_augments()

	//modifiers
	#define TRAIT_ROBUST 64
	#define TRAIT_UNROBUST 65
	#define TRAIT_SMART 66
	#define TRAIT_DUMB 67
	#define TRAIT_MEAN 68
	#define TRAIT_FRIENDLY 69
	#define TRAIT_THIEVING 70

	if(TRAITS & TRAIT_ROBUST)
		robustness = 75
	else if(TRAITS & TRAIT_UNROBUST)
		robustness = 25

	//modifiers are prob chances, lower = smarter
	if(TRAITS & TRAIT_SMART)
		smartness = 25
	else if(TRAITS & TRAIT_DUMB)
		mutations |= CLUMSY
		smartness = 75

	if(TRAITS & TRAIT_MEAN)
		attitude = 75
	else if(TRAITS & TRAIT_FRIENDLY)
		attitude = 1

	if(TRAITS & TRAIT_THIEVING)
		slyness = 75


/mob/living/carbon/human/interactive/attack_hand(mob/living/carbon/human/M as mob)
	..()
	if(M.a_intent == "help")
		if (health > 0)
			visible_message("[src]: I am feeling [interest2string(interest)]. I am [doing2string(doing)]")

/mob/living/carbon/human/interactive/proc/doing2string(var/doin)
	var/toReturn = ""
	if(doin == 0)
		toReturn = "not doing anything"
	if(doin & INTERACTING)
		toReturn += "interacting with something, "
	if(doin & FIGHTING)
		toReturn += "engaging in combat, "
	if(doin & TRAVEL)
		toReturn += "and going somewhere"
	return toReturn

/mob/living/carbon/human/interactive/proc/interest2string(var/inter)
	var/toReturn = "Flatlined"
	if(inter >= 0 && inter <= 25)
		toReturn = "Very Bored"
	if(inter >= 26 && inter <= 50)
		toReturn = "Bored"
	if(inter >= 51 && inter <= 75)
		toReturn = "Content"
	if(inter >= 76)
		toReturn = "Excited"
	return toReturn


/mob/living/carbon/human/interactive/Bump(M as mob|obj)
	..()
	/*if(istype(M, /obj/machinery/door))
		var/obj/machinery/door/D = M
		if(!istype(D, /obj/machinery/door/firedoor)) //access? fuck access!
			D.open()*/

/mob/living/carbon/human/interactive/Life()
	..()
	a_intent = "disarm"
	if(stat)
		return 0
	//---------------------------
	//---- interest flow control
	if(interest <= 0)
		interest = 0
	if(interest >= 100)
		interest = 100
	//---------------------------
	nearby = list()
	//VIEW FUNCTIONS
	for(var/mob/living/M in view(4,src))
		if(M != src)
			nearby += M

	for(var/obj/machinery/door/D in oview(1,src))
		if(D.loc == get_step(src,dir))
			if(D.check_access(MYID) && !istype(D,/obj/machinery/door/poddoor))
				D.open()
				sleep(10)
				var/turf/T = get_step(get_step(D.loc,dir),dir) //recursion yo
				walk_to(src,T,1,2)

	if(grabbed_by.len > 0)
		for(var/obj/item/weapon/grab/G in grabbed_by)
			a_intent = "disarm"
			G.assailant.attack_hand(src)
			sleep(10)

	if(l_hand || r_hand)
		if(l_hand)
			main_hand = l_hand
		else if(r_hand)
			main_hand = r_hand
		update_icons()

	if(canmove && main_hand)
		if(prob(attitude))
			a_intent = "harm"
			doing |= FIGHTING
			var/mob/living/M = locate(/mob/living) in oview(7,src)
			if(M != src)
				TARGET = M
			if(!M)
				doing = 0

	//proc functions
	for(var/Proc in functions)
		call(src,Proc)()

	if(TARGET && (doing & FIGHTING) || graytide)
		var/mob/living/M = TARGET
		if(istype(M,/mob/living))
			if(TARGET in oview())
				if(istype(main_hand,/obj/item/weapon/gun/projectile))
					var/obj/item/weapon/gun/projectile/P = main_hand
					if(!P.chambered)
						P.chamber_round()
						P.update_icon()
					else if(P.get_ammo(1) == 0)
						P.attack_self(src)
					else
						if(prob(robustness))
							P.afterattack(TARGET, src)
				else
					if(get_dist(src,TARGET) > 2)
						walk_to(src,TARGET,1,3)
					else
						var/obj/item/weapon/W = main_hand
						if(prob(robustness))
							W.attack(TARGET,src)
				sleep(1)
			else if(M.health <= 0 || !(TARGET in view()))
				doing = 0
				timeout = 0
				TARGET = null
		else
			timeout++

	if((TARGET && (doing & TRAVEL) && (TARGET in view(2))) || timeout == 2)
		if((TARGET in range(1,src)) && (doing & TRAVEL))//this is a bit redundant but it saves two if blocks
			doing |= INTERACTING
			//--------DOORS
			if(istype(TARGET, /obj/machinery/door))
				var/obj/machinery/door/D = TARGET
				if(D.check_access(MYID))
					D.open()
					walk_to(src,D.loc,1,2)
			//THIEVING SKILLS
			if(prob(slyness))
				var/list/slots = list ("left pocket" = slot_l_store,"right pocket" = slot_r_store,"left hand" = slot_l_hand,"right hand" = slot_r_hand)
				//---------TOOLS
				if(istype(TARGET, /obj/item/weapon))
					var/obj/item/weapon/W = TARGET
					if(W.force >= best_force || prob(10))
						if(!l_hand |!r_hand)
							W.loc = src
							best_force = W.force
							equip_in_one_of_slots(W, slots)
						else
							var/obj/item/I = get_item_by_slot(pick(slots))
							var/obj/item/weapon/storage/BP = get_item_by_slot(slot_back)
							if(back && BP && I)
								if(BP.can_be_inserted(I,0))
									BP.handle_item_insertion(I,0)
							else
								u_equip(I)
				//---------FASHION
				if(istype(TARGET,/obj/item/clothing))
					if(prob(25))
						if(!l_hand || !r_hand)
							var/obj/item/clothing/C = TARGET
							C.loc = src
							equip_in_one_of_slots(C, slots)
							sleep(25)
							if(equip_to_appropriate_slot(C))
								C.update_icon()
							else
								var/obj/item/I = get_item_by_slot(item2slot(C))
								u_equip(I)
								equip_to_appropriate_slot(C)
							if(MYPDA in src.loc || MYID in src.loc)
								if(MYPDA in src.loc)
									equip_to_appropriate_slot(MYPDA)
								if(MYID in src.loc)
									equip_to_appropriate_slot(MYID)
							update_icons()
			//THIEVING SKILLS END
			//-------------TOUCH ME
			if(istype(TARGET,/obj/structure))
				var/obj/structure/STR = TARGET
				if(main_hand)
					var/obj/item/weapon/W = main_hand
					STR.attackby(W, src)
				else
					STR.attack_hand(src)
		doing = 0
		timeout = 0
		TARGET = null
	else
		timeout++
	if(!doing)
		interest--
	else
		interest++

	//this is boring, lets move
	if(!doing && canmove)
		doing |= TRAVEL
		if(nearby.len > 4)
			TARGET = pick(target_filter(oview(32,src)))
		else if(prob(75))
			TARGET = locate(/obj/item) in oview(14,src)
		else
			TARGET = pick(target_filter(oview(14,src)))
		walk_to(src, TARGET, 1, 3)

/mob/living/carbon/human/interactive/proc/target_filter(var/target)
	var/list/L = target
	for(var/atom/A in target)
		if(istype(A,/area) || istype(A,/turf/unsimulated) || istype(A,/turf/space))
			L -= A
	return L

/mob/living/carbon/human/interactive/angry
	New()
		TRAITS |= TRAIT_ROBUST
		TRAITS |= TRAIT_MEAN
		..()

/mob/living/carbon/human/interactive/friendly
	New()
		TRAITS |= TRAIT_FRIENDLY
		TRAITS |= TRAIT_UNROBUST
		..()

/mob/living/carbon/human/interactive/greytide
	New()
		TRAITS |= TRAIT_ROBUST
		TRAITS |= TRAIT_MEAN
		TRAITS |= TRAIT_THIEVING
		TRAITS |= TRAIT_DUMB
		graytide = 1
		..()

#undef INTERACTING
#undef TRAVEL
#undef FIGHTING
#undef TRAIT_ROBUST
#undef TRAIT_UNROBUST
#undef TRAIT_SMART
#undef TRAIT_DUMB
#undef TRAIT_MEAN
#undef TRAIT_FRIENDLY
#undef TRAIT_THIEVING