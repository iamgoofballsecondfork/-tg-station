/obj/item/scp/fourtwoseven
	icon_state = "427"
	var/on = 0
	var/mob/holder = null

/obj/item/scp/fourtwoseven/attack_self(mob/user)
	on = !on
	if(on)
		if(src.loc == user)
			holder = user
	else
		holder = null
	processing_objects.Add(src)
	user << "You [on ? "open" : "close"] the [src]"
	..()
	return

/obj/item/scp/fourtwoseven/process()
	if(on && src.loc == holder)
		if(prob(25))
			visible_message("<span class='danger'>The [src] glows brightly!</span>")
		for(var/mob/living/M in view(7,holder))
			M.heal_organ_damage(25, 25)
			M.apply_effects(0, 0, 0, 25, 0, 0, 0, 0)
			if(prob(1) && M.radiation > 75)
				if(!(HULK in M.mutations) && M.mind)
					M.mutations.Add(HULK)
					var/datum/objective/anger/anger = new
					anger.owner = M.mind
					M.mind.objectives += anger

/obj/item/scp/fourtwoseven/dropped(mob/user)
	on = 0
	holder = null