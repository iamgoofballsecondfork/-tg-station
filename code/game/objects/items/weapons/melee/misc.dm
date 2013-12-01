/obj/item/weapon/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = 3
	origin_tech = "combat=4"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")

/obj/item/weapon/melee/chainofcommand/suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</b>"
		return (OXYLOSS)



/obj/item/weapon/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	force = 10

/obj/item/weapon/melee/classic_baton/attack(mob/M, mob/living/user)
	add_fingerprint(user)
	if((CLUMSY in user.mutations) && prob(50))
		user << "<span class='warning'>You club yourself over the head!</span>"
		user.Weaken(3 * force)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2 * force, BRUTE, "head")
			H.forcesay(hit_appends)
		else
			user.take_organ_damage(2 * force)
		return

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")
	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

	if(user.a_intent == "harm")
		if(!..()) return
		playsound(loc, "swing_hit", 50, 1, -1)
		if(M.stuttering < 8 && !(HULK in M.mutations))
			M.stuttering = 8
		M.Stun(8)
		M.Weaken(8)
		M.visible_message("<span class='danger'>[M] has been beaten with [src] by [user]!</span>", \
							"<span class='userdanger'>[M] has been beaten with [src] by [user]!</span>")
	else
		playsound(loc, 'sound/weapons/Genhit.ogg', 50, 1, -1)
		M.Stun(5)
		M.Weaken(5)
		M.visible_message("<span class='danger'>[M] has been stunned with [src] by [user]!</span>", \
							"<span class='userdanger'>[M] has been stunned with [src] by [user]!</span>")

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.forcesay(hit_appends)
		return (OXYLOSS)

/obj/item/weapon/melee/larpsword
	name = "larp sword"
	desc = "A sword made of foam and plastic, so you can re-enact your bravest fantasies!"
	icon = 'icons/obj/items.dmi'
	icon_state = "larp"
	item_state = "classic_baton"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	force = 1
	throwforce = 1
	w_class = 3
	attack_verb = list("bopped", "whopped", "slapped", "hit")

	attack(mob/target, mob/user)
		..()
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			M.Weaken(1)
		return 1

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is ramming the [src.name] down \his throat! It looks like \he's trying to commit suicide.</b>"
		return (OXYLOSS)