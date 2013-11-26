/obj/item/weapon/photo/sevenfourzero
	name = "\[REDACTED\]"
	var/mob/living/holder = null

/obj/item/weapon/photo/sevenfourzero/New()
	..()
	img = icon("icons/misc/740.png")

/obj/item/weapon/photo/sevenfourzero/rename()
	return

/obj/item/weapon/photo/sevenfourzero/attackby(obj/item/weapon/P, mob/user)
	return

/obj/item/weapon/photo/sevenfourzero/show(mob/user)
	holder = user
	processing_objects.Add(src)
	..()

/obj/item/weapon/photo/sevenfourzero/process()
	if(src.loc == holder)
		if(prob(25))
			holder << "[pick("Your eyes are drawn towards","You cannot stop looking at", "You cannot resist")] the [src]"
		holder.bodytemperature = holder.bodytemperature + rand(10,100)
		holder.hallucination = holder.hallucination + rand(25,100)
		if(holder.bodytemperature > 350)
			holder.IgniteMob()
	else
		holder = null

/obj/item/weapon/photo/sevenfourzero/dropped(mob/user)
	holder = null