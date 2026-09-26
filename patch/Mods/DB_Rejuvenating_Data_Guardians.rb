# =============================================================================
# DB's Rejuvenating Settings — DONNÉES : équipes des Épreuves du Gardien
#
# Une équipe par légendaire "Restreint", reprise d'une équipe de stratégie
# RÉELLE (source indiquée). Seuls changements : le niveau (= plafond actuel du
# joueur, appliqué au lancement) et ce qui n'existe pas dans Rejuvenation V14
# (Téracristal ignoré, Gigamax ignoré). Aucune statistique augmentée.
# EVs dans l'ordre du jeu (PBStats) : PV, Attaque, Défense, Atq. Spé, Déf. Spé, Vitesse.
# Adaptations à Rejuvenation (aucune ne renforce l'équipe) :
#   - le légendaire concerné est placé en tête d'équipe ;
#   - Groudon/Kyogre "Primal" : forme de base + Orbe (Primo-Résurgence en combat,
#     talent Drought/Drizzle avant la transformation) ;
#   - Zygarde : "Power Construct" est volontairement retiré par Rejuvenation
#     (Rejuv/Battle/Battler.rb) -> Aura Break, son autre talent ;
#   - Electric Seed (absent de V14) -> Elemental Seed, son équivalent Rejuvenation ;
#   - Téracristal et niveau 50 des feuilles d'équipe ignorés.
# Une entrée absente ou vide = épreuve indisponible pour ce légendaire
# (le menu l'indique ; rien ne plante).
# =============================================================================

module DBRejuvenating
  module GuardianData
    # Petit constructeur lisible : un "set" au format du jeu (PokemonBuilder)
    def self.set(species, item, ability, nature, evs, moves, form: nil, iv: 31, gender: nil)
      h = { :species => species, :item => item, :ability => ability, :nature => nature,
            :ev => evs, :iv => iv, :moves => moves }
      h[:form] = form if form
      h[:gender] = gender if gender
      return h
    end
  end

  s = GuardianData.method(:set)
  teams = {}

  # --- Lugia — ORAS Ubers "Absolute Control Sun Balance" (Lord Outrage),
  #     Smogon "Sample Teams (ORAS | BW | DPP | ADV)" ---
  teams[:LUGIA] = { :source => "Smogon ORAS Ubers sample team 'Absolute Control Sun Balance'", :team => [
    s.call(:LUGIA,   :LEFTOVERS,   :MULTISCALE,  :BOLD,    [248, 0, 124, 0, 0, 136], [:TOXIC, :ICEBEAM, :ROOST, :WHIRLWIND]),
    s.call(:SABLEYE, :SABLENITE,   :PRANKSTER,   :IMPISH,  [252, 0, 252, 0, 4, 0],   [:FAKEOUT, :WILLOWISP, :FOULPLAY, :RECOVER], gender: :F),
    s.call(:HOOH,    :LIFEORB,     :REGENERATOR, :ADAMANT, [0, 252, 4, 0, 0, 252],   [:BRAVEBIRD, :SACREDFIRE, :EARTHQUAKE, :SLEEPTALK]),
    s.call(:KLEFKI,  :LEFTOVERS,   :PRANKSTER,   :CAREFUL, [252, 0, 4, 0, 252, 0],   [:TOXIC, :THUNDERWAVE, :PLAYROUGH, :SPIKES], gender: :M),
    s.call(:ARCEUS,  :SPLASHPLATE, :MULTITYPE,   :BOLD,    [248, 0, 244, 0, 0, 16],  [:JUDGMENT, :DEFOG, :TOXIC, :RECOVER], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:GROUDON, :REDORB,      :DROUGHT,     :CAREFUL, [248, 0, 0, 0, 252, 8],   [:STEALTHROCK, :PRECIPICEBLADES, :STONEEDGE, :REST]),
  ] }

  # --- Reshiram — Alex Dellapasqua, Europe Internationals 2022 Top 8
  #     (Victory Road team report, VGC 2022 Series 12) ---
  teams[:RESHIRAM] = { :source => "VGC 2022 EUIC Top 8 (Alex Dellapasqua, Victory Road)", :team => [
    s.call(:RESHIRAM,   :ASSAULTVEST,    :TURBOBLAZE, :MODEST, [124, 0, 12, 252, 12, 108], [:BLUEFLARE, :DRACOMETEOR, :EARTHPOWER, :HEATWAVE], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:CALYREX,    :WEAKNESSPOLICY, :ASONECHILLING, :BRAVE, [244, 252, 0, 0, 12, 0], [:PROTECT, :GLACIALLANCE, :HIGHHORSEPOWER, :TRICKROOM], form: "Ice Rider", iv: [31, 31, 31, 31, 31, 0]),
    s.call(:INCINEROAR, :EJECTBUTTON,    :INTIMIDATE, :ADAMANT, [236, 148, 20, 0, 4, 100], [:FLAREBLITZ, :THROATCHOP, :FAKEOUT, :PARTINGSHOT]),
    s.call(:AMOONGUSS,  :SITRUSBERRY,    :REGENERATOR, :SASSY, [252, 0, 172, 0, 84, 0], [:PROTECT, :SPORE, :RAGEPOWDER, :HEX], iv: [31, 0, 31, 31, 31, 0]),
    s.call(:GASTRODON,  :SOFTSAND,       :STORMDRAIN, :QUIET,  [172, 0, 220, 4, 108, 0], [:PROTECT, :SCALD, :EARTHPOWER, :RECOVER], iv: [31, 0, 31, 31, 31, 0]),
    s.call(:MIMIKYU,    :SAFETYGOGGLES,  :DISGUISE,   :SASSY,  [228, 0, 108, 0, 172, 0], [:SHADOWSNEAK, :WILLOWISP, :TAUNT, :TRICKROOM]),
  ] }

  # --- MEWTWO : Smogon SS Ubers sample team 'Stalltwo + Offensive Groudon BO' (pokepast.es/e07c67b9ac5c02cc) ---
  teams[:MEWTWO] = { :source => "Smogon SS Ubers sample team 'Stalltwo + Offensive Groudon BO' (pokepast.es/e07c67b9ac5c02cc)", :team => [
    s.call(:MEWTWO, :LEFTOVERS, :PRESSURE, :TIMID, [248, 0, 0, 8, 0, 252], [:PSYSTRIKE, :WILLOWISP, :TAUNT, :RECOVER], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:GROUDON, :LEFTOVERS, :DROUGHT, :ADAMANT, [248, 108, 0, 0, 0, 152], [:SWORDSDANCE, :EARTHQUAKE, :HEATCRASH, :ROCKTOMB]),
    s.call(:MARSHADOW, :LIFEORB, :TECHNICIAN, :JOLLY, [0, 252, 0, 0, 4, 252], [:SPECTRALTHIEF, :LOWKICK, :SHADOWSNEAK, :ICEPUNCH]),
    s.call(:NECROZMA, :LEFTOVERS, :PRISMARMOR, :CAREFUL, [252, 0, 0, 0, 216, 40], [:IRONHEAD, :STEALTHROCK, :KNOCKOFF, :MOONLIGHT], form: "Dusk Mane"),
    s.call(:ETERNATUS, :POWERHERB, :PRESSURE, :TIMID, [252, 0, 0, 0, 40, 216], [:COSMICPOWER, :DRAGONPULSE, :METEORBEAM, :RECOVER], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:YVELTAL, :HEAVYDUTYBOOTS, :DARKAURA, :CAREFUL, [248, 0, 72, 0, 188, 0], [:UTURN, :ROOST, :KNOCKOFF, :DEFOG]),
  ] }

  # --- HOOH : Smogon SS Ubers sample team 'LO Marshadow + Offensive Ho-Oh Balance' (pokepast.es/455812bf537d8353) ---
  teams[:HOOH] = { :source => "Smogon SS Ubers sample team 'LO Marshadow + Offensive Ho-Oh Balance' (pokepast.es/455812bf537d8353)", :team => [
    s.call(:HOOH, :HEAVYDUTYBOOTS, :REGENERATOR, :ADAMANT, [248, 192, 0, 0, 52, 16], [:SACREDFIRE, :BRAVEBIRD, :THUNDERWAVE, :WHIRLWIND]),
    s.call(:GROUDON, :LEFTOVERS, :DROUGHT, :IMPISH, [252, 0, 240, 0, 0, 16], [:PRECIPICEBLADES, :TOXIC, :STEALTHROCK, :STONEEDGE]),
    s.call(:MARSHADOW, :LIFEORB, :TECHNICIAN, :JOLLY, [0, 252, 4, 0, 0, 252], [:SPECTRALTHIEF, :LOWKICK, :ICEPUNCH, :SHADOWSNEAK]),
    s.call(:NECROZMA, :LEFTOVERS, :PRISMARMOR, :CAREFUL, [136, 0, 0, 0, 252, 120], [:SUNSTEELSTRIKE, :KNOCKOFF, :DRAGONDANCE, :MOONLIGHT], form: "Dusk Mane"),
    s.call(:ETERNATUS, :SHUCABERRY, :PRESSURE, :TIMID, [40, 0, 0, 0, 252, 216], [:DYNAMAXCANNON, :MYSTICALFIRE, :TOXIC, :RECOVER], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:YVELTAL, :HEAVYDUTYBOOTS, :DARKAURA, :TIMID, [16, 0, 0, 0, 240, 252], [:KNOCKOFF, :UTURN, :DEFOG, :ROOST]),
  ] }

  # --- KYOGRE : Smogon SV Ubers sample team 'Double Water Lu Hatt BO' (pokepast.es/663dc11a51cee85e) ---
  teams[:KYOGRE] = { :source => "Smogon SV Ubers sample team 'Double Water Lu Hatt BO' (pokepast.es/663dc11a51cee85e)", :team => [
    s.call(:KYOGRE, :CHOICESCARF, :DRIZZLE, :TIMID, [0, 0, 4, 252, 0, 252], [:WATERSPOUT, :ICEBEAM, :THUNDER, :ORIGINPULSE], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:KORAIDON, :LOADEDDICE, :ORICHALCUMPULSE, :JOLLY, [0, 252, 4, 0, 0, 252], [:SCALESHOT, :IRONHEAD, :LOWKICK, :SWORDSDANCE]),
    s.call(:ARCEUS, :SPLASHPLATE, :MULTITYPE, :BOLD, [248, 0, 164, 0, 0, 96], [:JUDGMENT, :THUNDERWAVE, :CALMMIND, :RECOVER], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:TINGLU, :CHOPLEBERRY, :VESSELOFRUIN, :SASSY, [248, 0, 8, 0, 252, 0], [:EARTHQUAKE, :STEALTHROCK, :WHIRLWIND, :SPIKES], iv: [31, 31, 31, 31, 31, 9]),
    s.call(:HATTERENE, :ROCKYHELMET, :MAGICBOUNCE, :BOLD, [248, 0, 252, 0, 8, 0], [:DRAININGKISS, :NUZZLE, :PAINSPLIT, :HEALINGWISH], iv: [31, 31, 31, 31, 31, 30]),
    s.call(:ETERNATUS, :SITRUSBERRY, :PRESSURE, :TIMID, [80, 0, 248, 4, 0, 176], [:DYNAMAXCANNON, :FLAMETHROWER, :TOXIC, :RECOVER], iv: [31, 0, 31, 31, 31, 31]),
  ] }

  # --- GROUDON : Smogon SS Ubers sample team 'Offensive Groudon + Specs Calyrex-S BO' (pokepast.es/ff732bf3f443426c) ---
  teams[:GROUDON] = { :source => "Smogon SS Ubers sample team 'Offensive Groudon + Specs Calyrex-S BO' (pokepast.es/ff732bf3f443426c)", :team => [
    s.call(:GROUDON, :LEFTOVERS, :DROUGHT, :ADAMANT, [248, 108, 0, 0, 0, 152], [:SWORDSDANCE, :PRECIPICEBLADES, :HEATCRASH, :ROCKTOMB]),
    s.call(:FERROTHORN, :LEFTOVERS, :IRONBARBS, :CAREFUL, [252, 0, 4, 0, 252, 0], [:STEALTHROCK, :KNOCKOFF, :CURSE, :LEECHSEED]),
    s.call(:CALYREX, :CHOICESPECS, :ASONEGRIM, :TIMID, [0, 0, 4, 252, 0, 252], [:ASTRALBARRAGE, :PSYSHOCK, :TRICK, :AROMATHERAPY], form: "Shadow Rider", iv: [31, 0, 31, 31, 31, 31]),
    s.call(:NECROZMA, :COLBURBERRY, :PRISMARMOR, :CAREFUL, [252, 0, 0, 0, 136, 120], [:DRAGONDANCE, :SUNSTEELSTRIKE, :KNOCKOFF, :MOONLIGHT], form: "Dusk Mane"),
    s.call(:ETERNATUS, :AIRBALLOON, :PRESSURE, :TIMID, [248, 0, 44, 0, 0, 216], [:DRACOMETEOR, :FLAMETHROWER, :TOXIC, :RECOVER], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:YVELTAL, :HEAVYDUTYBOOTS, :DARKAURA, :CAREFUL, [248, 0, 112, 0, 68, 80], [:KNOCKOFF, :FOULPLAY, :ROOST, :DEFOG]),
  ] }

  # --- RAYQUAZA : Smogon Anything Goes sample team 'DD Ray + CM Ultra Necrozma' (pokepast.es/80411b015ea77f14) ---
  teams[:RAYQUAZA] = { :source => "Smogon Anything Goes sample team 'DD Ray + CM Ultra Necrozma' (pokepast.es/80411b015ea77f14)", :team => [
    s.call(:RAYQUAZA, :LIFEORB, :AIRLOCK, :ADAMANT, [0, 252, 0, 0, 4, 252], [:DRAGONASCENT, :DRAGONDANCE, :EARTHQUAKE, :EXTREMESPEED]),
    s.call(:NECROZMA, :ULTRANECROZIUMZ, :PRISMARMOR, :TIMID, [0, 0, 4, 252, 0, 252], [:CALMMIND, :PHOTONGEYSER, :HEATWAVE, :DRAGONPULSE], form: "Dusk Mane", iv: [31, 0, 31, 31, 31, 31]),
    s.call(:ARCEUS, :DREADPLATE, :MULTITYPE, :BOLD, [252, 0, 168, 0, 0, 88], [:DEFOG, :JUDGMENT, :RECOVER, :TOXIC], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:ARCEUS, :EARTHPLATE, :MULTITYPE, :BOLD, [248, 0, 224, 0, 0, 36], [:JUDGMENT, :TOXIC, :ICEBEAM, :RECOVER], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:GROUDON, :REDORB, :DROUGHT, :SASSY, [252, 0, 4, 0, 252, 0], [:STEALTHROCK, :PRECIPICEBLADES, :DRAGONTAIL, :TOXIC], iv: [31, 31, 31, 31, 31, 0]),
    s.call(:HOOH, :LEFTOVERS, :REGENERATOR, :IMPISH, [252, 0, 204, 0, 52, 0], [:TOXIC, :SACREDFIRE, :WHIRLWIND, :DEFOG]),
  ] }

  # --- DIALGA : VGC 2022 Worlds Top 16 team (Smogon VGC 2022 sample teams, pokepast.es/26349828a2819969) ---
  teams[:DIALGA] = { :source => "VGC 2022 Worlds Top 16 team (Smogon VGC 2022 sample teams, pokepast.es/26349828a2819969)", :team => [
    s.call(:DIALGA, :LIFEORB, :TELEPATHY, :MODEST, [20, 0, 92, 252, 4, 140], [:POWERGEM, :FLASHCANNON, :EARTHPOWER, :ROAROFTIME], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:YVELTAL, :ASSAULTVEST, :DARKAURA, :SERIOUS, [252, 4, 76, 68, 60, 44], [:SNARL, :SUCKERPUNCH, :OBLIVIONWING, :FOULPLAY]),
    s.call(:GYARADOS, :CHARTIBERRY, :INTIMIDATE, :ADAMANT, [4, 244, 4, 0, 4, 252], [:WATERFALL, :POWERWHIP, :PROTECT, :STONEEDGE]),
    s.call(:THUNDURUS, :SITRUSBERRY, :PRANKSTER, :CALM, [252, 0, 140, 4, 84, 28], [:THUNDERBOLT, :SCARYFACE, :EERIEIMPULSE, :TAUNT], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:FERROTHORN, :LEFTOVERS, :IRONBARBS, :RELAXED, [252, 0, 156, 0, 100, 0], [:BODYPRESS, :IRONDEFENSE, :LEECHSEED, :PROTECT], iv: [31, 0, 31, 31, 31, 0]),
    s.call(:LANDORUS, :CHOICEBAND, :INTIMIDATE, :ADAMANT, [4, 212, 4, 0, 36, 252], [:EARTHQUAKE, :ROCKSLIDE, :STONEEDGE, :UTURN], form: "Therian Forme"),
  ] }

  # --- PALKIA : VGC Regulation G Palkia-Origin team (DevonCorp, pokepast.es/8d4a61258cc8cc20) ---
  teams[:PALKIA] = { :source => "VGC Regulation G Palkia-Origin team (DevonCorp, pokepast.es/8d4a61258cc8cc20)", :team => [
    s.call(:PALKIA, :LUSTROUSGLOBE, :TELEPATHY, :MODEST, [60, 0, 4, 252, 4, 188], [:SPACIALREND, :SURF, :TRICKROOM, :PROTECT], form: "Origin Forme", iv: [31, 0, 31, 31, 31, 31]),
    s.call(:PELIPPER, :FOCUSSASH, :DRIZZLE, :MODEST, [108, 0, 36, 132, 4, 228], [:HURRICANE, :WEATHERBALL, :TAILWIND, :WIDEGUARD], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:OGERPON, :WELLSPRINGMASK, :WATERABSORB, :ADAMANT, [252, 100, 52, 0, 4, 100], [:IVYCUDGEL, :HORNLEECH, :FOLLOWME, :SPIKYSHIELD], form: "Wellspring Mask", gender: :F),
    s.call(:TOXICROAK, :ASSAULTVEST, :DRYSKIN, :ADAMANT, [84, 252, 4, 0, 4, 164], [:POISONJAB, :LOWKICK, :ACIDSPRAY, :FAKEOUT]),
    s.call(:URSHIFU, :CHOICESCARF, :UNSEENFIST, :ADAMANT, [0, 252, 4, 0, 0, 252], [:SURGINGSTRIKES, :CLOSECOMBAT, :ICESPINNER, :UTURN], form: "Rapid Strike Style"),
    s.call(:URSALUNA, :FLAMEORB, :GUTS, :BRAVE, [252, 252, 4, 0, 0, 0], [:EARTHQUAKE, :FACADE, :HEADLONGRUSH, :PROTECT], iv: [31, 31, 31, 31, 31, 0]),
  ] }

  # --- GIRATINA : Smogon National Dex Ubers sample team 'Double Ghost Bulky Offense' (pokepast.es/8573cad11f7cb795) ---
  teams[:GIRATINA] = { :source => "Smogon National Dex Ubers sample team 'Double Ghost Bulky Offense' (pokepast.es/8573cad11f7cb795)", :team => [
    s.call(:GIRATINA, :GRISEOUSCORE, :LEVITATE, :MODEST, [248, 0, 152, 8, 100, 0], [:DRACOMETEOR, :HEX, :DEFOG, :WILLOWISP], form: "Origin Forme", iv: [31, 0, 31, 31, 31, 31]),
    s.call(:GROUDON, :REDORB, :DROUGHT, :RELAXED, [248, 0, 140, 0, 120, 0], [:PRECIPICEBLADES, :STEALTHROCK, :TOXIC, :OVERHEAT], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:ARCEUS, :PIXIEPLATE, :MULTITYPE, :TIMID, [248, 0, 4, 16, 104, 136], [:TAUNT, :CALMMIND, :RECOVER, :JUDGMENT], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:ZYGARDE, :LEFTOVERS, :AURABREAK, :ADAMANT, [12, 216, 0, 0, 48, 232], [:DRAGONDANCE, :THOUSANDARROWS, :SUBSTITUTE, :DRAGONTAIL]),
    s.call(:MARSHADOW, :CHOICEBAND, :TECHNICIAN, :JOLLY, [0, 252, 4, 0, 0, 252], [:POLTERGEIST, :SPECTRALTHIEF, :SHADOWSNEAK, :LOWKICK]),
    s.call(:KYOGRE, :BLUEORB, :DRIZZLE, :BOLD, [248, 0, 236, 0, 24, 0], [:CALMMIND, :SCALD, :ICEBEAM, :REST], iv: [31, 0, 31, 31, 31, 31]),
  ] }

  # --- ZEKROM : Smogon SS Ubers sample team 'Zekrom + Encore Calyrex-S HO' (pokepast.es/f3a45acd4beae9d3) ---
  teams[:ZEKROM] = { :source => "Smogon SS Ubers sample team 'Zekrom + Encore Calyrex-S HO' (pokepast.es/f3a45acd4beae9d3)", :team => [
    s.call(:ZEKROM, :LIFEORB, :TERAVOLT, :JOLLY, [0, 252, 0, 0, 4, 252], [:DRAGONDANCE, :BOLTSTRIKE, :DRAGONCLAW, :DRACOMETEOR]),
    s.call(:AERODACTYL, :FOCUSSASH, :UNNERVE, :JOLLY, [4, 252, 0, 0, 0, 252], [:STEALTHROCK, :TAUNT, :ROCKTOMB, :TAILWIND]),
    s.call(:CALYREX, :FOCUSSASH, :ASONEGRIM, :TIMID, [0, 0, 0, 252, 4, 252], [:ASTRALBARRAGE, :ENCORE, :NASTYPLOT, :DRAININGKISS], form: "Shadow Rider", iv: [31, 0, 31, 31, 31, 31]),
    s.call(:NECROZMA, :LUMBERRY, :PRISMARMOR, :ADAMANT, [80, 252, 0, 0, 0, 176], [:SUNSTEELSTRIKE, :STONEEDGE, :KNOCKOFF, :DRAGONDANCE], form: "Dusk Mane"),
    s.call(:ETERNATUS, :POWERHERB, :PRESSURE, :TIMID, [4, 0, 0, 252, 0, 252], [:SLUDGEBOMB, :FLAMETHROWER, :METEORBEAM, :DYNAMAXCANNON]),
    s.call(:YVELTAL, :LIFEORB, :DARKAURA, :HASTY, [0, 4, 0, 252, 0, 252], [:DARKPULSE, :OBLIVIONWING, :TAUNT, :SUCKERPUNCH]),
  ] }

  # --- KYUREM : Smogon National Dex Ubers sample team 'Mega Diancie Hyper Offense' (pokepast.es/34924cc6e54ad5ce) ---
  teams[:KYUREM] = { :source => "Smogon National Dex Ubers sample team 'Mega Diancie Hyper Offense' (pokepast.es/34924cc6e54ad5ce)", :team => [
    s.call(:KYUREM, :LOADEDDICE, :TERAVOLT, :JOLLY, [40, 252, 0, 0, 0, 216], [:DRAGONDANCE, :SCALESHOT, :ICICLESPEAR, :FUSIONBOLT], form: "Black Kyurem"),
    s.call(:DIANCIE, :DIANCITE, :CLEARBODY, :HASTY, [0, 28, 0, 232, 32, 216], [:DIAMONDSTORM, :MOONBLAST, :EARTHPOWER, :STEALTHROCK]),
    s.call(:YVELTAL, :LIFEORB, :DARKAURA, :NAIVE, [0, 4, 0, 252, 0, 252], [:DARKPULSE, :OBLIVIONWING, :TAUNT, :SUCKERPUNCH]),
    s.call(:ARCEUS, :EARTHPLATE, :MULTITYPE, :ADAMANT, [24, 252, 16, 0, 0, 216], [:DRAGONDANCE, :EARTHQUAKE, :STONEEDGE, :TAUNT]),
    s.call(:ZACIAN, :RUSTEDSWORD, :INTREPIDSWORD, :JOLLY, [0, 252, 0, 0, 4, 252], [:SWORDSDANCE, :PLAYROUGH, :CLOSECOMBAT, :WILDCHARGE], form: "Crowned Sword"),
    s.call(:NECROZMA, :ULTRANECROZIUMZ, :PRISMARMOR, :ADAMANT, [40, 236, 80, 0, 0, 152], [:DRAGONDANCE, :PHOTONGEYSER, :STONEEDGE, :EARTHQUAKE], form: "Dusk Mane"),
  ] }

  # --- XERNEAS : Smogon SS Ubers sample team 'Xerneas + Darmanitan-G Magnezone Balance' (pokepast.es/d2134456ef5d5897) ---
  teams[:XERNEAS] = { :source => "Smogon SS Ubers sample team 'Xerneas + Darmanitan-G Magnezone Balance' (pokepast.es/d2134456ef5d5897)", :team => [
    s.call(:XERNEAS, :POWERHERB, :FAIRYAURA, :MODEST, [0, 0, 168, 252, 0, 88], [:GEOMANCY, :MOONBLAST, :THUNDER, :FOCUSBLAST], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:DARMANITAN, :CHOICESCARF, :GORILLATACTICS, :JOLLY, [0, 252, 4, 0, 0, 252], [:ICICLECRASH, :UTURN, :EARTHQUAKE, :ROCKSLIDE], form: "Galarian Standard Mode"),
    s.call(:MAGNEZONE, :AIRBALLOON, :MAGNETPULL, :TIMID, [4, 0, 252, 0, 0, 252], [:BODYPRESS, :MAGNETRISE, :IRONDEFENSE, :THUNDERWAVE], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:NECROZMA, :LEFTOVERS, :PRISMARMOR, :CAREFUL, [252, 0, 0, 0, 216, 40], [:STEALTHROCK, :SUNSTEELSTRIKE, :THUNDERWAVE, :MORNINGSUN], form: "Dusk Mane"),
    s.call(:ETERNATUS, :HEAVYDUTYBOOTS, :PRESSURE, :TIMID, [164, 0, 0, 0, 252, 92], [:DYNAMAXCANNON, :MYSTICALFIRE, :TOXIC, :RECOVER]),
    s.call(:YVELTAL, :HEAVYDUTYBOOTS, :DARKAURA, :JOLLY, [72, 0, 0, 0, 252, 184], [:FOULPLAY, :ROOST, :DEFOG, :UTURN]),
  ] }

  # --- COSMOG : Smogon SV Ubers sample team 'Lead Groundceus Offense', led by Lunala (pokepast.es/41dbaaa379c6a138) ---
  teams[:COSMOG] = { :source => "Smogon SV Ubers sample team 'Lead Groundceus Offense', led by Lunala (pokepast.es/41dbaaa379c6a138)", :team => [
    s.call(:LUNALA, :POWERHERB, :SHADOWSHIELD, :TIMID, [0, 0, 4, 252, 0, 252], [:MOONGEISTBEAM, :METEORBEAM, :FOCUSBLAST, :AGILITY], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:KORAIDON, :LOADEDDICE, :ORICHALCUMPULSE, :JOLLY, [0, 252, 4, 0, 0, 252], [:SCALESHOT, :FLAREBLITZ, :LOWKICK, :SWORDSDANCE]),
    s.call(:ARCEUS, :EARTHPLATE, :MULTITYPE, :MODEST, [64, 0, 0, 252, 0, 192], [:JUDGMENT, :ICEBEAM, :THUNDERWAVE, :STEALTHROCK], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:KYOGRE, :SITRUSBERRY, :DRIZZLE, :MODEST, [248, 0, 76, 96, 0, 88], [:ORIGINPULSE, :THUNDER, :ICEBEAM, :THUNDERWAVE], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:ZACIAN, :RUSTEDSWORD, :INTREPIDSWORD, :JOLLY, [0, 252, 0, 0, 4, 252], [:BEHEMOTHBLADE, :WILDCHARGE, :CRUNCH, :SWORDSDANCE], form: "Crowned Sword"),
    s.call(:NECROZMA, :LIFEORB, :PRISMARMOR, :ADAMANT, [248, 252, 0, 0, 8, 0], [:SUNSTEELSTRIKE, :PHOTONGEYSER, :SWORDSDANCE, :TRICKROOM], form: "Dusk Mane", iv: [31, 31, 31, 31, 31, 30]),
  ] }

  # --- ZACIAN : Smogon SV Ubers sample team 'Double Prio HO' (pokepast.es/131586150f8888d1) ---
  teams[:ZACIAN] = { :source => "Smogon SV Ubers sample team 'Double Prio HO' (pokepast.es/131586150f8888d1)", :team => [
    s.call(:ZACIAN, :RUSTEDSWORD, :INTREPIDSWORD, :JOLLY, [0, 252, 4, 0, 0, 252], [:SWORDSDANCE, :BEHEMOTHBLADE, :CLOSECOMBAT, :WILDCHARGE], form: "Crowned Sword"),
    s.call(:DEOXYS, :MENTALHERB, :PRESSURE, :TIMID, [248, 0, 144, 0, 0, 116], [:SPIKES, :TAUNT, :THUNDERWAVE, :SKILLSWAP], form: "Speed Forme", iv: [31, 0, 31, 31, 31, 31]),
    s.call(:KORAIDON, :LOADEDDICE, :ORICHALCUMPULSE, :JOLLY, [0, 252, 4, 0, 0, 252], [:SWORDSDANCE, :FLAREBLITZ, :SCALESHOT, :TAUNT]),
    s.call(:ARCEUS, :LIFEORB, :MULTITYPE, :ADAMANT, [68, 252, 0, 0, 0, 188], [:SWORDSDANCE, :EXTREMESPEED, :SHADOWCLAW, :DOUBLEEDGE]),
    s.call(:LUNALA, :POWERHERB, :SHADOWSHIELD, :TIMID, [0, 0, 4, 252, 0, 252], [:AGILITY, :MOONGEISTBEAM, :PSYSHOCK, :METEORBEAM], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:KINGAMBIT, :BLACKGLASSES, :SUPREMEOVERLORD, :ADAMANT, [240, 252, 0, 0, 0, 16], [:SWORDSDANCE, :SUCKERPUNCH, :KOWTOWCLEAVE, :IRONHEAD]),
  ] }

  # --- ZAMAZENTA : Rafe Osborne, VGC 2025 Europe International Championships (pokepast.es/1111c2924c3839c9) ---
  teams[:ZAMAZENTA] = { :source => "Rafe Osborne, VGC 2025 Europe International Championships (pokepast.es/1111c2924c3839c9)", :team => [
    s.call(:ZAMAZENTA, :RUSTEDSHIELD, :DAUNTLESSSHIELD, :IMPISH, [92, 4, 156, 0, 4, 252], [:BODYPRESS, :WIDEGUARD, :IRONHEAD, :PROTECT], form: "Crowned Shield"),
    s.call(:CHIENPAO, :FOCUSSASH, :SWORDOFRUIN, :JOLLY, [0, 252, 4, 0, 0, 252], [:PROTECT, :ICICLECRASH, :SUCKERPUNCH, :CRUNCH]),
    s.call(:TINGLU, :ROCKYHELMET, :VESSELOFRUIN, :IMPISH, [228, 4, 36, 0, 236, 4], [:PROTECT, :TAUNT, :RUINATION, :SANDTOMB]),
    s.call(:OGERPON, :HEARTHFLAMEMASK, :MOLDBREAKER, :ADAMANT, [252, 20, 76, 0, 4, 156], [:HORNLEECH, :IVYCUDGEL, :SPIKYSHIELD, :FOLLOWME], form: "Hearthflame Mask", gender: :F),
    s.call(:DONDOZO, :LEFTOVERS, :UNAWARE, :RELAXED, [244, 12, 0, 0, 252, 0], [:PROTECT, :WAVECRASH, :FISSURE, :YAWN], iv: [31, 31, 31, 31, 31, 27]),
    s.call(:RAGINGBOLT, :BOOSTERENERGY, :PROTOSYNTHESIS, :MODEST, [188, 0, 0, 180, 0, 140], [:ELECTROWEB, :THUNDERCLAP, :PROTECT, :DRACOMETEOR], iv: [31, 20, 31, 31, 31, 31]),
  ] }

  # --- ETERNATUS : Smogon SS Ubers sample team 'RestTalk Kyogre + Marshadow Spikes' (pokepast.es/255d04ac0d3b5752) ---
  teams[:ETERNATUS] = { :source => "Smogon SS Ubers sample team 'RestTalk Kyogre + Marshadow Spikes' (pokepast.es/255d04ac0d3b5752)", :team => [
    s.call(:ETERNATUS, :HEAVYDUTYBOOTS, :PRESSURE, :TIMID, [40, 0, 0, 0, 252, 216], [:DYNAMAXCANNON, :FLAMETHROWER, :SLUDGEBOMB, :RECOVER], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:FERROTHORN, :LEFTOVERS, :IRONBARBS, :BOLD, [252, 0, 252, 0, 4, 0], [:LEECHSEED, :SPIKES, :IRONDEFENSE, :BODYPRESS], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:KYOGRE, :LEFTOVERS, :DRIZZLE, :BOLD, [252, 0, 240, 0, 0, 16], [:CALMMIND, :SCALD, :REST, :SLEEPTALK], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:MARSHADOW, :LIFEORB, :TECHNICIAN, :JOLLY, [0, 252, 0, 0, 4, 252], [:LOWKICK, :SPECTRALTHIEF, :ICEPUNCH, :SHADOWSNEAK]),
    s.call(:NECROZMA, :LEFTOVERS, :PRISMARMOR, :CAREFUL, [252, 0, 0, 0, 136, 120], [:STEALTHROCK, :THUNDERWAVE, :IRONHEAD, :MOONLIGHT], form: "Dusk Mane"),
    s.call(:YVELTAL, :HEAVYDUTYBOOTS, :DARKAURA, :JOLLY, [16, 0, 0, 0, 240, 252], [:KNOCKOFF, :TAUNT, :SUCKERPUNCH, :ROOST]),
  ] }

  # --- CALYREX : Smogon SS Ubers sample team 'Groudon + Trick NP Calyrex-S Balance' (pokepast.es/80d97f2b313b7ae8) ---
  teams[:CALYREX] = { :source => "Smogon SS Ubers sample team 'Groudon + Trick NP Calyrex-S Balance' (pokepast.es/80d97f2b313b7ae8)", :team => [
    s.call(:CALYREX, :CHOICESPECS, :ASONEGRIM, :TIMID, [0, 0, 4, 252, 0, 252], [:TRICK, :NASTYPLOT, :ASTRALBARRAGE, :PSYSHOCK], form: "Shadow Rider", iv: [31, 0, 31, 31, 31, 31]),
    s.call(:XERNEAS, :AIRBALLOON, :FAIRYAURA, :BOLD, [192, 0, 252, 0, 0, 64], [:MOONBLAST, :SLEEPTALK, :REST, :AROMATHERAPY], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:GROUDON, :LEFTOVERS, :DROUGHT, :ADAMANT, [104, 252, 0, 0, 0, 152], [:SWORDSDANCE, :PRECIPICEBLADES, :STONEEDGE, :HEATCRASH]),
    s.call(:NECROZMA, :LEFTOVERS, :PRISMARMOR, :CAREFUL, [252, 0, 0, 0, 136, 120], [:STEALTHROCK, :IRONHEAD, :THUNDERWAVE, :MORNINGSUN], form: "Dusk Mane"),
    s.call(:ETERNATUS, :HEAVYDUTYBOOTS, :PRESSURE, :TIMID, [40, 0, 0, 0, 252, 216], [:DYNAMAXCANNON, :MYSTICALFIRE, :TOXIC, :RECOVER], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:YVELTAL, :HEAVYDUTYBOOTS, :DARKAURA, :JOLLY, [72, 0, 0, 0, 252, 184], [:KNOCKOFF, :ROOST, :DEFOG, :SUCKERPUNCH]),
  ] }

  # --- KORAIDON : Smogon SV Ubers sample team 'Kingambit Deo-S HO' (pokepast.es/bed373f0e82997a6) ---
  teams[:KORAIDON] = { :source => "Smogon SV Ubers sample team 'Kingambit Deo-S HO' (pokepast.es/bed373f0e82997a6)", :team => [
    s.call(:KORAIDON, :LIFEORB, :ORICHALCUMPULSE, :JOLLY, [8, 248, 0, 0, 0, 252], [:SWORDSDANCE, :SCALESHOT, :FLAMECHARGE, :CLOSECOMBAT]),
    s.call(:DEOXYS, :FOCUSSASH, :PRESSURE, :TIMID, [248, 0, 0, 8, 0, 252], [:THUNDERWAVE, :SPIKES, :TAUNT, :PSYCHOBOOST], form: "Speed Forme", iv: [31, 0, 31, 31, 31, 31]),
    s.call(:KINGAMBIT, :DREADPLATE, :SUPREMEOVERLORD, :ADAMANT, [56, 252, 0, 0, 0, 200], [:SWORDSDANCE, :KOWTOWCLEAVE, :IRONHEAD, :SUCKERPUNCH]),
    s.call(:ZACIAN, :RUSTEDSWORD, :INTREPIDSWORD, :JOLLY, [0, 252, 0, 0, 4, 252], [:SWORDSDANCE, :BEHEMOTHBLADE, :CLOSECOMBAT, :WILDCHARGE], form: "Crowned Sword"),
    s.call(:ARCEUS, :PIXIEPLATE, :MULTITYPE, :BOLD, [248, 0, 72, 0, 0, 188], [:CALMMIND, :JUDGMENT, :TAUNT, :RECOVER], iv: [31, 0, 31, 31, 31, 31]),
    s.call(:ETERNATUS, :POWERHERB, :PRESSURE, :MODEST, [124, 0, 0, 252, 0, 132], [:AGILITY, :METEORBEAM, :DYNAMAXCANNON, :FIREBLAST], iv: [31, 0, 31, 31, 31, 31]),
  ] }

  # --- MIRAIDON : Smogon SV Ubers sample team 'Screens Hyper Offense' (pokepast.es/00d65a0880db3420) ---
  teams[:MIRAIDON] = { :source => "Smogon SV Ubers sample team 'Screens Hyper Offense' (pokepast.es/00d65a0880db3420)", :team => [
    s.call(:MIRAIDON, :ELEMENTALSEED,   # Electric Seed n'existe pas en V14 : son équivalent Rejuvenation (Champs "élémentaux")
           :HADRONENGINE, :MODEST, [240, 0, 0, 252, 0, 16], [:CALMMIND, :AGILITY, :DRAGONPULSE, :ELECTRODRIFT]),
    s.call(:GRIMMSNARL, :LIGHTCLAY, :PRANKSTER, :CAREFUL, [248, 0, 128, 0, 124, 8], [:PLAYROUGH, :TAUNT, :REFLECT, :LIGHTSCREEN]),
    s.call(:KORAIDON, :LOADEDDICE, :ORICHALCUMPULSE, :JOLLY, [0, 252, 4, 0, 0, 252], [:SUBSTITUTE, :SWORDSDANCE, :SCALESHOT, :FLAREBLITZ]),
    s.call(:ARCEUS, :SILKSCARF, :MULTITYPE, :ADAMANT, [120, 252, 0, 0, 0, 136], [:SWORDSDANCE, :TAUNT, :EXTREMESPEED, :SHADOWCLAW]),
    s.call(:NECROZMA, :WEAKNESSPOLICY, :PRISMARMOR, :BRAVE, [248, 252, 8, 0, 0, 0], [:SWORDSDANCE, :TRICKROOM, :PHOTONGEYSER, :EARTHQUAKE], form: "Dusk Mane", iv: [31, 31, 31, 31, 31, 0]),
    s.call(:CALYREX, :HEAVYDUTYBOOTS, :ASONECHILLING, :BRAVE, [248, 252, 8, 0, 0, 0], [:SWORDSDANCE, :TRICKROOM, :GLACIALLANCE, :HIGHHORSEPOWER], form: "Ice Rider", iv: [31, 31, 31, 31, 31, 0]),
  ] }

  # --- TERAPAGOS : Francesco Pio Pero, VGC 2025 Europe International Championships (pokepast.es/223b82bec7a3aa33) ---
  teams[:TERAPAGOS] = { :source => "Francesco Pio Pero, VGC 2025 Europe International Championships (pokepast.es/223b82bec7a3aa33)", :team => [
    s.call(:TERAPAGOS, :LEFTOVERS, :TERASHIFT, :MODEST, [172, 0, 4, 204, 12, 116], [:TERASTARSTORM, :CALMMIND, :SUBSTITUTE, :PROTECT], iv: [31, 15, 31, 31, 31, 31]),
    s.call(:OGERPON, :CORNERSTONEMASK, :STURDY, :ADAMANT, [0, 252, 0, 0, 4, 252], [:IVYCUDGEL, :POWERWHIP, :FOLLOWME, :SPIKYSHIELD], form: "Cornerstone Mask"),
    s.call(:HEATRAN, :SITRUSBERRY, :FLASHFIRE, :QUIET, [204, 4, 68, 84, 148, 0], [:MAGMASTORM, :HEAVYSLAM, :TERABLAST, :PROTECT]),
    s.call(:SCREAMTAIL, :BOOSTERENERGY, :PROTOSYNTHESIS, :TIMID, [228, 0, 148, 4, 28, 100], [:DAZZLINGGLEAM, :ENCORE, :DISABLE, :PROTECT]),
    s.call(:INCINEROAR, :ROCKYHELMET, :INTIMIDATE, :IMPISH, [244, 4, 156, 0, 84, 20], [:KNOCKOFF, :WILLOWISP, :PARTINGSHOT, :FAKEOUT]),
    s.call(:RILLABOOM, :ASSAULTVEST, :GRASSYSURGE, :ADAMANT, [252, 132, 20, 0, 28, 76], [:FAKEOUT, :WOODHAMMER, :GRASSYGLIDE, :UTURN]),
  ] }

  setc(:GUARDIAN_TEAMS, teams)
end
