#define FOURTWOSEVEN 1
#define SEVENFOURZERO 2

/datum/round_event_control/scp
	name = "\[EXPUNGED DATA\]"
	typepath = /datum/round_event/scp
	weight = 5
	max_occurrences = 10

/datum/round_event/scp
	announceWhen	= 1200
	var/successSpawn = 0
	var/spawnType


/datum/round_event/scp/setup()
	spawnType = pick(FOURTWOSEVEN,SEVENFOURZERO)

/datum/round_event/scp/kill()
	if(!successSpawn && control)
		control.occurrences--
	return ..()

/datum/round_event/scp/announce()
	if(successSpawn)
		command_alert("Space-time anomalies detected on the station. There is no additional data.", "Anomaly Alert")
		world << sound('sound/AI/spanomalies.ogg')


/datum/round_event/scp/start()
	var/list/turfs = list()

	for(var/turf/simulated/floor/F in world)
		if(!F.contents.len)
			turfs += F

	if(turfs.len)
		var/turf/simulated/floor/T = pick(turfs)
		spawn(0)
			switch(spawnType)
				if(FOURTWOSEVEN)
					new/obj/item/scp/fourtwoseven(T)
				if(SEVENFOURZERO)
					new/obj/item/weapon/photo/sevenfourzero(T)
		successSpawn = 1

#undef FOURTWOSEVEN
#undef SEVENFOURZERO