class_name ArsenalCatalog
extends RefCounted

const MAX_WEAPON_SLOTS: int = 6
const MAX_PASSIVE_SLOTS: int = 6
const MAX_WEAPON_LEVEL: int = 8
const MAX_PASSIVE_LEVEL: int = 5

# IMPORTANT: catalog dictionaries are immutable runtime data. get_weapon/get_passive
# intentionally return shared read-only dictionaries instead of duplicate(true), because
# the old version allocated copies every frame inside ArsenalController's hot loop.
const WEAPONS: Dictionary = {
	"heart_blaster": {"name":"HEART BLASTER","short":"HB","description":"Taffi's signature heart shots. Auto-aims at the nearest sweetheart-shaped problem.","family":"projectile","passive":"extra_sprinkles","evolution":"HEARTSTORM DELUXE ♡","legacy":true,"rarity":100},
	"ribbon_ripper": {"name":"RIBBON RIPPER","short":"RR","description":"A huge satin melee sweep in the direction Taffi is facing.","family":"melee_arc","passive":"lucky_ribbon","evolution":"LOVE HURTS ♡","legacy":false,"rarity":82},
	"kawaii_chainsaw": {"name":"KAWAII CHAINSAW","short":"KC","description":"A close-range buzzing wall of affection. Extremely affectionate.","family":"melee_aura","passive":"plush_armor","evolution":"FRIENDSHIP FOREVER!!!","legacy":false,"rarity":64},
	"sugar_crash": {"name":"SUGAR CRASH","short":"SC","description":"Periodic candy shockwave centered on Taffi. Hits everything nearby.","family":"area_pulse","passive":"strawberry_core","evolution":"SUGAR SUPERNOVA","legacy":false,"rarity":88},
	"strawberry_rain": {"name":"STRAWBERRY RAIN","short":"SR","description":"Marks enemies from above, then drops juicy area explosions on their heads.","family":"targeted_area","passive":"bigger_bow","evolution":"STRAWBERRY MONSOON","legacy":false,"rarity":72},
	"bunny_boomerang": {"name":"BUNNY BOOMERANG","short":"BB","description":"Fast bunny blades fly out, curve, then come home through the crowd.","family":"returning_projectile","passive":"fast_delivery","evolution":"BUNNY MÖBIUS","legacy":false,"rarity":76},
	"bubblegum_minefield": {"name":"BUBBLEGUM MINEFIELD","short":"BM","description":"Leaves sticky pink danger zones behind while you move.","family":"persistent_area","passive":"long_love","evolution":"BUBBLEGUM BLACK HOLE","legacy":false,"rarity":70},
	"lollipop_guillotine": {"name":"LOLLIPOP GUILLOTINE","short":"LG","description":"A giant candy blade spins through a deadly ring around Taffi.","family":"melee_ring","passive":"plush_armor","evolution":"CANDY CRESCENT","legacy":false,"rarity":68},
	"teddy_drop": {"name":"TEDDY DROP","short":"TD","description":"A giant plush friend falls from the sky onto the densest problem.","family":"heavy_area","passive":"honey_heart","evolution":"BEAR HUG EXTINCTION","legacy":false,"rarity":54},
	"friendship_laser": {"name":"FRIENDSHIP LASER","short":"FL","description":"A sweeping pink beam that paints a lane through the horde.","family":"beam","passive":"sugar_rush","evolution":"BESTIES FOREVER BEAM","legacy":false,"rarity":58},
	"star_tantrum": {"name":"STAR TANTRUM","short":"ST","description":"A radial burst of angry little stars that keep travelling through the garden.","family":"radial_projectile","passive":"charm_bracelet","evolution":"SUPERSTAR MELTDOWN","legacy":false,"rarity":74},
	"cupcake_mortar": {"name":"CUPCAKE MORTAR","short":"CM","description":"Lobs explosive cupcakes at priority targets.","family":"lobbed_area","passive":"bigger_bow","evolution":"BIRTHDAY MASSACRE","legacy":true,"rarity":78},
	"love_orbit": {"name":"LOVE ORBIT","short":"LO","description":"Large hearts orbit Taffi and grind through nearby enemies.","family":"orbit","passive":"charm_bracelet","evolution":"PLANETARY CRUSH ♡","legacy":true,"rarity":80},

	"love_letter_opener": {"name":"LOVE LETTER OPENER","short":"✂","description":"Giant cute scissors snap across the crowd in front of Taffi.","family":"cross_melee","passive":"lucky_ribbon","evolution":"DIVORCE PAPERS","legacy":false,"rarity":70},
	"honey_hazard": {"name":"HONEY HAZARD","short":"HH","description":"Drops sticky honey puddles that keep hurting anything standing inside.","family":"persistent_area","passive":"long_love","evolution":"STICKY SITUATION","legacy":false,"rarity":78},
	"bowling_besties": {"name":"BOWLING FOR BESTIES","short":"BF","description":"Rolls a huge smiling ball through the horde, growing as it hits.","family":"rolling_projectile","passive":"fast_delivery","evolution":"FRIENDSHIP STRIKE!!!","legacy":false,"rarity":62},
	"bunny_hopper": {"name":"BUNNY HOPPER","short":"BH","description":"A hopping spark jumps from enemy to enemy instead of travelling normally.","family":"chain_hit","passive":"charm_bracelet","evolution":"HOPSCOTCH HOMICIDE","legacy":false,"rarity":72},
	"tea_party": {"name":"TEA PARTY","short":"TEA","description":"Three tiny tea cups appear and fire politely in extremely impolite directions.","family":"radial_burst","passive":"extra_sprinkles","evolution":"TABLE FOR EVERYONE","legacy":false,"rarity":76},
	"cupid_bad_day": {"name":"CUPID'S BAD DAY","short":"CBD","description":"Diagonal lanes of heart-arrows rake across the screen.","family":"lane_sweep","passive":"bigger_bow","evolution":"LOVE IS CANCELLED","legacy":false,"rarity":66},
	"glitter_bomb": {"name":"GLITTER BOMB","short":"GB","description":"Plants a glitter charge on the densest problem, then detonates it later.","family":"delayed_bomb","passive":"lucky_ribbon","evolution":"TOO FABULOUS TO LIVE","legacy":false,"rarity":58},
	"marshmallow_hammer": {"name":"MARSHMALLOW HAMMER","short":"MH","description":"A very slow, very large, very pink BONK in front of Taffi.","family":"heavy_melee","passive":"plush_armor","evolution":"BONK EVER AFTER","legacy":false,"rarity":60},
	"kiss_of_death": {"name":"KISS OF DEATH","short":"KD","description":"A slow cruel kiss seeks the healthiest enemy and chunks its HP.","family":"priority_strike","passive":"strawberry_core","evolution":"FRENCH KISS FINALE","legacy":false,"rarity":52},
	"rainbow_roadkill": {"name":"RAINBOW ROADKILL","short":"RB","description":"Taffi paints a damaging rainbow path behind her movement.","family":"movement_trail","passive":"bubblegum_shoes","evolution":"TASTE THE RAINBOW","legacy":false,"rarity":64}
}

const PASSIVES: Dictionary = {
	"strawberry_core": {"name":"STRAWBERRY CORE","short":"DMG","description":"+10% Might per level.","stat":"might","rarity":100},
	"sugar_rush": {"name":"SUGAR RUSH","short":"CD","description":"All attacks recharge faster.","stat":"cooldown","rarity":100},
	"bigger_bow": {"name":"BIGGER BOW","short":"AOE","description":"Attacks and explosions grow larger.","stat":"area","rarity":92},
	"extra_sprinkles": {"name":"EXTRA SPRINKLES","short":"+1","description":"Adds projectiles / targets to attacks that support Amount.","stat":"amount","rarity":84},
	"fast_delivery": {"name":"FAST DELIVERY","short":"SPD","description":"Projectiles travel faster.","stat":"speed","rarity":90},
	"long_love": {"name":"LONG-LASTING LOVE","short":"DUR","description":"Persistent attacks last longer.","stat":"duration","rarity":86},
	"bubblegum_shoes": {"name":"BUBBLEGUM SHOES","short":"RUN","description":"+Movement speed.","stat":"move","rarity":100},
	"plush_armor": {"name":"PLUSH ARMOR","short":"DEF","description":"Take less contact and projectile damage.","stat":"armor","rarity":92},
	"honey_heart": {"name":"HONEY HEART","short":"HP","description":"+Maximum HP and a little instant healing.","stat":"health","rarity":96},
	"lucky_ribbon": {"name":"LUCKY RIBBON","short":"LCK","description":"More critical hits and slightly better chest rolls.","stat":"luck","rarity":72},
	"charm_bracelet": {"name":"CHARM BRACELET","short":"KB","description":"Attacks push enemies harder and improve orbiting attacks.","stat":"knockback","rarity":78}
}

static func get_weapon(id: String) -> Dictionary:
	return WEAPONS.get(id, {}) as Dictionary

static func get_passive(id: String) -> Dictionary:
	return PASSIVES.get(id, {}) as Dictionary

static func weapon_ids() -> Array[String]:
	var out: Array[String] = []
	for key: Variant in WEAPONS.keys():
		out.append(String(key))
	return out

static func passive_ids() -> Array[String]:
	var out: Array[String] = []
	for key: Variant in PASSIVES.keys():
		out.append(String(key))
	return out
