GLOBAL_LIST_EMPTY(biggates)

/obj/structure/gate
	name = "gate"
	desc = "A steel, strong gate."
	icon = 'icons/roguetown/misc/gate.dmi'
	icon_state = "gate1"
	density = TRUE
	anchored = TRUE
	blade_dulling = DULLING_BASHCHOP
	max_integrity = 5000
	bound_width = 96
	appearance_flags = NONE
	opacity = TRUE
	var/base_state = "gate"
	var/isSwitchingStates = FALSE
	var/list/turfsy = list()
	var/list/blockers = list()
	var/gid
	attacked_sound = list('sound/combat/hits/onmetal/sheet (1).ogg', 'sound/combat/hits/onmetal/sheet (2).ogg')
	var/obj/structure/attached_to

/obj/structure/gate/preopen
	icon_state = "gate0"

/obj/structure/gate/preopen/Initialize()
	. = ..()
	open()

/obj/structure/gate/bars
	icon_state = "bar1"
	base_state = "bar"
	opacity = FALSE

/obj/structure/gate/bars/preopen
	icon_state = "bar0"

/obj/structure/gate/bars/preopen/Initialize()
	. = ..()
	open()

/obj/gblock
	name = ""
	desc = ""
	icon = null
	mouse_opacity = 0
	opacity = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/gate/Initialize()
	. = ..()
	update_icon()
	if(initial(opacity))
		var/turf/T = loc
		var/G = new /obj/gblock(T)
		turfsy += T
		blockers += G
		T = get_step(T, EAST)
		G = new /obj/gblock(T)
		turfsy += T
		blockers += G
		T = get_step(T, EAST)
		G = new /obj/gblock(T)
		turfsy += T
		blockers += G
	GLOB.biggates += src

/obj/structure/gate/Destroy()
	for(var/A in blockers)
		qdel(A)
	if(attached_to)
		var/obj/structure/winch/W = attached_to
		W.attached_gate = null
	return ..()

/obj/structure/gate/update_icon()
	cut_overlays()
	icon_state = "[base_state][density]"
	if(!density && !isSwitchingStates)
		add_overlay(mutable_appearance(icon, "[base_state]0_part", ABOVE_MOB_LAYER))
	else
		add_overlay(mutable_appearance(icon, "[base_state]1_part", ABOVE_MOB_LAYER))

/obj/structure/gate/proc/toggle()
	if(density)
		open()
	else
		close()

/obj/structure/gate/proc/open()
	if(isSwitchingStates || !density)
		return
	isSwitchingStates = TRUE
	playsound(src, 'sound/misc/gate.ogg', 100, extrarange = 5)
	flick("[base_state]_opening",src)
	layer = initial(layer)
	sleep(15)
	density = FALSE
	opacity = FALSE
	for(var/obj/gblock/B in blockers)
		B.opacity = FALSE
	isSwitchingStates = FALSE
	update_icon()


/obj/structure/gate/proc/close()
	if(isSwitchingStates || density)
		return
	isSwitchingStates = TRUE
	update_icon()
	layer = ABOVE_MOB_LAYER
	playsound(src, 'sound/misc/gate.ogg', 100, extrarange = 5)
	flick("[base_state]_closing",src)
	sleep(10)
	for(var/turf/T in turfsy)
		for(var/mob/living/M in T)
			var/zone = ran_zone(probability = 0)
			var/obj/item/bodypart/part = M.get_bodypart(check_zone(zone))
			M.apply_damage(200, BRUTE, zone)
			if(part)
				if((istype(part, /obj/item/bodypart/chest) || istype(part, /obj/item/bodypart/head)) && prob(50))
					part.add_wound(/datum/wound/slash/disembowel)
				part.add_wound(/datum/wound/fracture)
				part.dismember()
				M.visible_message(span_warningbig("[M] is crushed by \the [src]!"), span_userdanger("OH [uppertext(M.patron.name)], MY [uppertext(part.name)]!!!"))
			else if(!part)
				M.visible_message(span_warningbig("[M] is crushed by \the [src]!"), span_userdanger("OH [uppertext(M.patron.name)], THE PAIN!!!"))
			M.emote("agony")
			step(M, pick(dir, turn(dir, 180)))
			M.Knockdown(50)
			M.Stun(50)
	density = initial(density)
	opacity = initial(opacity)
	layer = initial(layer)
	for(var/obj/gblock/B in blockers)
		B.opacity = TRUE
	isSwitchingStates = FALSE
	update_icon()

/obj/structure/winch
	name = "winch"
	desc = "A gatekeeper's only, and most important responsibility."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "winch"
	density = TRUE
	anchored = TRUE
	max_integrity = 0
	var/gid
	var/obj/structure/gate/attached_gate

/obj/structure/winch/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/winch/Destroy()
	if(attached_gate)
		var/obj/structure/gate/W = attached_gate
		W.attached_to = null
	return ..()

/obj/structure/winch/LateInitialize()
	for(var/obj/structure/gate/G in GLOB.biggates)
		if(G.gid == gid)
			GLOB.biggates -= G
			attached_gate = G
			G.attached_to = src

	for(var/obj/structure/gate_vertical/V in GLOB.biggates)
		if(V.gid == gid)
			GLOB.biggates -= V
			attached_gate = V
			V.attached_to = src			

/obj/structure/winch/attack_hand(mob/user)
	. = ..()
	if(!attached_gate)
		to_chat(user, span_warning("The chain is not attached to anything."))
		return
	if(attached_gate.isSwitchingStates)
		return
	if(isliving(user))
		var/mob/living/L = user
		L.changeNext_move(CLICK_CD_MELEE)
		var/used_time = 105 - (L.STASTR * 10)
		user.visible_message(span_warning("[user] cranks the winch."))
		playsound(src, 'sound/foley/winch.ogg', 100, extrarange = 3)
		if(do_after(user, used_time, target = user))
			attached_gate.toggle()

