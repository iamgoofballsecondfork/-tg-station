#define INTERACTING 1
#define TRAVEL 2
#define FIGHTING 3

/mob/living/carbon/human/interactive
	name = "interactive station member"
	var/doing = 0
	var/interest = 100
	var/timeout = 0
	var/atom/TARGET = null
	var/atom/LAST_TARGET = null
	var/list/nearby = list()
	var/best_force = 0
	var/obj/item/weapon/card/id/MYID
	var/obj/item/device/pda/MYPDA
	//clothes

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
	var/obj/item/weapon/storage/backpack/BPK = new/obj/item/weapon/storage/backpack(src)
	new /obj/item/weapon/storage/box/survival(BPK)
	equip_to_slot_or_del(BPK, slot_back,1)
	equip_to_slot_or_del(new /obj/item/device/radio/headset(src), slot_ears)
	equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/black(src), slot_shoes)

	MYID = new(src)
	MYID.name = "[src.real_name]'s ID Card (Crew)"
	MYID.assignment = "Crew"
	MYID.registered_name = src.real_name
	MYID.access = get_all_accesses()
	src.equip_to_slot_or_del(MYID, slot_wear_id)
	MYPDA = new(src)
	MYPDA.owner = src.real_name
	MYPDA.ownjob = "Crew"
	MYPDA.name = "PDA-[src.real_name] (Crew)"
	src.equip_to_slot_or_del(MYPDA, slot_belt)


/mob/living/carbon/human/interactive/attack_hand(mob/living/carbon/human/M as mob)
	..()
	if("help")
		if (health > 0)
			visible_message("I am feeling [interest2string(interest)]. I am [doing2string(doing)]")

/mob/living/carbon/human/interactive/proc/doing2string(var/doin)
	var/toReturn = "not doing anything"
	if(doin == INTERACTING)
		toReturn = "interacting with something"
	if(doin == FIGHTING)
		toReturn = "engaging in combat"
	if(doin == TRAVEL)
		toReturn = "going somewhere"
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
	if(istype(M, /obj/machinery/door))
		var/obj/machinery/door/D = M
		if(!istype(D, /obj/machinery/door/firedoor)) //access? fuck access!
			D.open()

/mob/living/carbon/human/interactive/Life()
	..()
	nearby = list()
	for(var/mob/living/M in view(2,src))
		if(M != src)
			nearby += M
	//---- interest flow control
	if(interest <= 0)
		interest = 0
	if(interest >= 100)
		interest = 100
	//---------------------------
	//this is boring, lets move
	if(!doing && canmove)
		doing = TRAVEL
		if(prob(50))
			TARGET = locate(/obj) in oview(14, src)
		else
			TARGET = locate(/turf/simulated) in oview(14, src)
		walk_to(src, TARGET, 1, 3)

	if((TARGET && doing == TRAVEL && (TARGET in view(1))) || timeout == 1)
		if(TARGET in view(1))//this is a bit redundant but it saves two if blocks
			doing = INTERACTING
			//--------DOORS
			if(istype(TARGET, /obj/machinery/door))
				var/obj/machinery/door/D = TARGET
				D.open()
				walk_to(src,D.loc,1,2)
			//---------TOOLS
			if(istype(TARGET, /obj/item/weapon))
				var/obj/item/weapon/W = TARGET
				if(W.force > best_force)
					if(!l_hand |!r_hand)
						W.loc = src
						best_force = W.force
						equip_in_one_of_slots(W, list(slot_l_hand,slot_r_hand),0)
					else
						var/slot = pick(l_hand,r_hand)
						var/obj/item/I = get_item_by_slot(slot)
						var/obj/item/weapon/storage/BP = get_item_by_slot(back)
						if(back)
							if(BP.can_be_inserted(I,0))
								BP.handle_item_insertion(I,0)
						else
							u_equip(I)
			//---------FASHION
			if(istype(TARGET,/obj/item/clothing))
				var/obj/item/clothing/C = TARGET
				if(prob(25))
					if(!l_hand |!r_hand)
						C.loc = src
						equip_in_one_of_slots(C, list(slot_l_hand,slot_r_hand),0)
						sleep(25)
						if(equip_to_appropriate_slot(C))
							//
						else
							var/obj/item/I = get_item_by_slot(C.slot_flags)
							u_equip(I)
							equip_to_appropriate_slot(C)
							if(MYPDA in src.loc || MYID in src.loc)
								if(MYPDA in src.loc)
									equip_to_appropriate_slot(MYPDA)
								if(MYID in src.loc)
									equip_to_appropriate_slot(MYID)
		sleep(25)
		doing = 0
		timeout = 0
		TARGET = null
	else
		timeout++

	if(!doing)
		interest--
	else
		interest++

#undef INTERACTING
#undef TRAVEL
#undef FIGHTING