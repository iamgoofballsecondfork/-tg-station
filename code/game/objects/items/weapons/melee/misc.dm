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

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</b>"
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