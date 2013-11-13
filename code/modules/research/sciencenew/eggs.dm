///Eggs for reasearch
#define STAGE_EARLY 0
#define STAGE_GROWING 1
#define STAGE_ALMOST 2
#define STAGE_HATCHING 3
#define GROWTH_MIN 100
#define GROWTH_MAX 800
#define MAX_TOX 200
//Flags
#define TOX_THING 4
#define OXY_THING 8
#define NITRO_THING 16
#define CARBON_THING 32
#define PLAS_THING 64
#define HOT_THING 128
#define COLD_THING 256

//This is similar to the alien egg, but fancier

/obj/structure/science/egg
	name = "strange egg"
	desc = "an egg"
	icon = 'icons/obj/newscience.dmi'
	icon_state = "egg-a-0"
	density = 0
	anchored = 1
	//ENVIRONMENT
	var/tox = 0
	var/oxy = 0
	var/n20 = 0
	var/carbon = 0
	var/plas = 0
	//temp (< 100 chilly) (290 regular) (390 - 490 plasma fire) (3000 - 5000 plasma fire) (5000+ you're fucked)
	var/temp = 0
	//Sweetspots
	var/SWEET_TOX
	var/SWEET_OXY
	var/SWEET_NITRO
	var/SWEET_CARBON
	var/SWEET_PLAS
	//
	var/babybit
	var/babyname = ""
	var/icon_chosen
	var/status = STAGE_EARLY
	//
	var/layed = 0
	var/mob/living/simple_animal/science/thing/PARENT_A
	var/mob/living/simple_animal/science/thing/PARENT_B

/obj/structure/science/egg/New()
	..()
	icon_chosen = pick("a","b","c","d")
	icon_state = "egg-[icon_chosen]-0"
	if(!layed)
		SWEET_TOX = rand(1,MAX_TOX)
		SWEET_OXY = rand(1,MAX_TOX)
		SWEET_NITRO = rand(1,MAX_TOX)
		SWEET_CARBON = rand(1,MAX_TOX)
		SWEET_PLAS = rand(1,MAX_TOX)
	spawn(rand(GROWTH_MIN,GROWTH_MAX))
		Grow()

/obj/structure/science/egg/proc/Grow()
	UpdateValues()
	Calculate()
	switch(status)
		if(STAGE_EARLY)
			visible_message("<span class='notice'>[src] shifts and squirms</span>")
			status = STAGE_GROWING
		if(STAGE_GROWING)
			visible_message("<span class='notice'>[src] hardens slightly</span>")
			status = STAGE_ALMOST
		if(STAGE_ALMOST)
			visible_message("<span class='notice'>[src] calcifies</span>")
			status = STAGE_HATCHING
		if(STAGE_HATCHING)
			visible_message("<span class='notice'>[src] begins to crack</span>")
			Hatch()
			return
	icon_state = "egg-[icon_chosen]-[status]"
	spawn(rand(GROWTH_MIN,GROWTH_MAX))
		Grow()

/obj/structure/science/egg/proc/UpdateValues()
	var/datum/gas_mixture/environment = src.loc.return_air()
	tox = environment.toxins
	oxy = environment.oxygen
	n20 = environment.nitrogen
	carbon = environment.carbon_dioxide
	temp = environment.temperature
	if(tox && plas < MAX_TOX)
		visible_message("<span class='notice'>[src] wheezes and jiggles</span>")
		plas += tox

/obj/structure/science/egg/proc/ToggleBit(var/bit, var/istrue)
	if(istrue)
		if(babybit & bit)
			return
		else
			babybit |= bit
	else
		if(babybit & bit)
			babybit = babybit & ~bit
		else
			return

/obj/structure/science/egg/proc/IsNear(var/a, var/b)
	//A = 10
	//B = 150
	//B + B/1.5 = 250 (10 < 250)
	//B - B/1.5 = 50 (10 !> 50)
	if(a <= (b+(b/1.5)) && a >= (b-(b/1.5)))
		return 1
	else
		return 0


/obj/structure/science/egg/proc/Calculate()
	//---------------------------------------
	if(IsNear(tox,SWEET_TOX))
		visible_message("<span class='notice'>[src]'s surface bubbles</span>")
		ToggleBit(TOX_THING,1)
	else
		ToggleBit(TOX_THING,0)
	//---------------------------------------
	if(IsNear(oxy,SWEET_OXY))
		visible_message("<span class='notice'>[src]'s surface forms large pores</span>")
		ToggleBit(OXY_THING,1)
	else
		ToggleBit(OXY_THING,0)
	//---------------------------------------
	if(IsNear(n20,SWEET_NITRO))
		visible_message("<span class='notice'>[src]'s surface tightens</span>")
		ToggleBit(NITRO_THING,1)
	else
		ToggleBit(NITRO_THING,0)
	//---------------------------------------
	if(IsNear(carbon,SWEET_CARBON))
		visible_message("<span class='notice'>[src] grows slightly</span>")
		ToggleBit(CARBON_THING,1)
	else
		ToggleBit(CARBON_THING,0)
	//---------------------------------------
	if(IsNear(plas,SWEET_PLAS))
		visible_message("<span class='notice'>[src]'s surface grows sticky</span>")
		ToggleBit(PLAS_THING,1)
	else
		ToggleBit(PLAS_THING,0)
	//---------------------------------------
	if(IsNear(temp,0))
		visible_message("<span class='notice'>[src]'s surface grows frosty</span>")
		ToggleBit(COLD_THING,1)
	else
		ToggleBit(COLD_THING,0)
	//---------------------------------------
	if(IsNear(temp,1000))
		visible_message("<span class='notice'>[src]'s begins to sizzle</span>")
		ToggleBit(HOT_THING,1)
	else
		ToggleBit(HOT_THING,0)

/obj/structure/science/egg/proc/CalcBreed(var/mob/D)
	var/tempname
	var/mob/living/simple_animal/science/thing/M = D
	if(layed)
		tox = pick(PARENT_A.min_tox,PARENT_B.min_tox)
		oxy = pick(PARENT_A.max_oxy,PARENT_B.max_oxy)
		n20 = pick(PARENT_A.max_co2,PARENT_B.max_co2)
		carbon = pick(PARENT_A.max_tox,PARENT_B.max_tox)
		plas = pick(PARENT_A.max_tox,PARENT_B.max_tox)
		temp = pick(PARENT_A.minbodytemp,PARENT_B.minbodytemp)
		Calculate()
	//---------------------------------------
	if(babybit & TOX_THING)
		tempname = pick("bubbling","sludgy","toxic","gooey")
		babyname += " [tempname]"
		if(tox > SWEET_TOX)
			M.max_tox = tox
			M.min_tox = SWEET_TOX/2
		else
			M.max_tox = SWEET_TOX
			M.min_tox = tox/2
	//---------------------------------------
	if(babybit & OXY_THING)
		tempname = pick("exhaling","puffing","windy","puffed")
		babyname += " [tempname]"
		if(oxy > SWEET_OXY)
			M.max_oxy = oxy
			M.min_oxy = SWEET_OXY/2
		else
			M.max_oxy = SWEET_OXY
			M.min_oxy = oxy/2
	//---------------------------------------
	if(babybit & NITRO_THING)
		tempname = pick("inflated","bloated","bursting","puffed")
		babyname += " [tempname]"
		if(n20 > SWEET_NITRO)
			M.max_n2 = n20
			M.min_n2 = SWEET_NITRO/2
		else
			M.max_n2 = SWEET_NITRO
			M.min_n2 = n20/2
	//---------------------------------------
	if(babybit & CARBON_THING)
		tempname = pick("tough","heavy","toxic","hardened")
		babyname += " [tempname]"
		if(carbon > SWEET_CARBON)
			M.max_co2 = carbon
			M.min_co2 = SWEET_CARBON/2
		else
			M.max_co2 = SWEET_CARBON
			M.min_co2 = carbon/2
	//---------------------------------------
	if(babybit & PLAS_THING)
		tempname = pick("sticky","slimy","glowing","irradiated")
		babyname += " [tempname]"
		if(tox > SWEET_TOX)
			M.max_tox = tox
			M.min_tox = SWEET_TOX
		else
			M.max_tox = SWEET_TOX
			M.min_tox = tox
	//---------------------------------------
	if(babybit & HOT_THING)
		tempname = pick("burnt","sizzling","roasted","hot")
		babyname += " [tempname]"
		M.maxbodytemp = temp
		M.minbodytemp = temp/2
	//---------------------------------------
	if(babybit & COLD_THING)
		tempname = pick("frosty","chilled","frozen","icy")
		babyname += " [tempname]"
		M.maxbodytemp = temp/2
		M.minbodytemp = temp
	babyname += " [M.name]"
	M.name = trim_left(babyname)


/obj/structure/science/egg/proc/Hatch()
	visible_message("<span class='notice'>[src] pops open and something sloshes out</span>")
	var/mob/living/simple_animal/science/thing/T = new(src.loc)
	CalcBreed(T)
	//SWEET_TOX,SWEET_OXY,SWEET_NITRO,SWEET_CARBON,SWEET_PLAS
	T.stored_sweets = list(SWEET_TOX,SWEET_OXY,SWEET_NITRO,SWEET_CARBON,SWEET_PLAS)
	del(src)


///Eggs for reasearch
#undef STAGE_EARLY
#undef STAGE_GROWING
#undef STAGE_ALMOST
#undef STAGE_HATCHING
#undef GROWTH_MIN
#undef GROWTH_MAX
#undef MAX_TOX
//Flags
#undef TOX_THING
#undef OXY_THING
#undef NITRO_THING
#undef CARBON_THING
#undef PLAS_THING
#undef HOT_THING
#undef COLD_THING



/////////////////////////////////////////EGG CREATURES////////////////////////////////////////////////////////

/mob/living/simple_animal/science/thing
	name = "astiomorph"
	real_name = "astiomorph"
	desc = "It's a little disgusting"
	icon = 'icons/obj/newscience.dmi'
	icon_state = "thing"
	icon_living = "thing"
	icon_dead = "thing-dead"
	speak_emote = list("hisses")
	health = 50
	maxHealth = 50
	response_help  = "prods"
	response_disarm = "slaps"
	response_harm   = "kicks"
	emote_see = list("tumbles", "rolls")
	var/eggs = 0
	var/mob/living/simple_animal/science/thing/MATE
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 250
	maxbodytemp = 350
	var/hit = 0
	var/list/stored_sweets = list()

/mob/living/simple_animal/science/thing/proc/TryRear()
	if(prob(1))
		visible_message("<span class='warning'>[src] rears up and hisses</span>")
		if(prob(1))
			var/datum/gas_mixture/environment = src.loc.return_air()
			visible_message("<span class='warning'>[src] vents itself</span>")
			environment.oxygen += min_oxy
			environment.toxins += min_tox
			environment.nitrogen += min_n2
			environment.carbon_dioxide += min_co2

/mob/living/simple_animal/science/thing/Life()
	..()
	if(health > 1)
		for(var/mob/M in oviewers(3, src))
			if(istype(M, /mob/living/simple_animal/science/thing))
				var/mob/living/simple_animal/science/thing/TEMP = M
				var/crowding = 0
				for(var/mob/S in oviewers(7,src))
					if(istype(S, /mob/living/simple_animal/science/thing))
						crowding = crowding + 1
				if(prob(1))
					if(TEMP.health > 0 && eggs < 2 && crowding < 5)
						MATE = M
						visible_message("<span class='notice'>[src] clicks seductively towards [M]</span>")
						break
				if(prob(1))
					visible_message("<span class='notice'>[src] chitters at [M]</span>")
				if(crowding > 5)
					if(prob(25))
						visible_message("<span class='warning'>[src] hisses uncomfortably</span>")
						health = health - 25
		if(MATE && eggs < 1)
			for(var/obj/O in loc.contents)
				if(istype(O,/obj/structure/science/egg))
					return
			visible_message("<span class='notice'>[src] excretes an egg</span>")
			var/obj/structure/science/egg/T = new(src.loc)
			T.layed = 1
			T.PARENT_A = src
			T.PARENT_B = MATE
			T.SWEET_TOX = stored_sweets[1]
			T.SWEET_OXY = stored_sweets[2]
			T.SWEET_NITRO = stored_sweets[3]
			T.SWEET_CARBON = stored_sweets[4]
			T.SWEET_PLAS = stored_sweets[5]
			MATE = 0
			eggs = eggs + 1
		TryRear()

/mob/living/simple_animal/science/thing/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/melee/baton) || istype(O, /obj/item/weapon/melee/baton/cattleprod))
		var/obj/item/weapon/melee/baton/B = O
		if(B.status && !hit)
			playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
			visible_message("<span class='notice'>[user] taps the [src] with the [O]</span>")
			TryRear()
			hit = 1
			spawn(30)
				hit = 0
		else
			user << "The [O] is off!"


/////////////////////////////////////////////////EGG BOX

/obj/item/device/egg_deployer
	name = "shielded egg deployer"
	desc = "A small bluespace container that can be primed to pop out an astiomorph egg. Point away from face."
	icon = 'icons/obj/device.dmi'
	icon_state = "empar"
	item_state = "electronic"
	w_class = 4.0
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	m_amt = 100

/obj/item/device/egg_deployer/attack_self(mob/user as mob)
	usr << "The [src] begins to blink rapidly"
	playsound(src.loc, 'sound/machines/twobeep.ogg', 10, 1)
	spawn(180)
		if(loc == user)
			new/obj/structure/science/egg(user.loc)
		else
			new/obj/structure/science/egg(loc)
		playsound(src.loc, 'sound/effects/extinguish.ogg', 75, 1)
		del(src)