# =============================================================================
# DB's Rejuvenating Settings — NOYAU (Core)  v1.3.1 (version stable, prête à partager)
# (anciennement "DB's Rejuthingy Patch" puis "DB's Rejuvenating" :
#  0.1.0 → 1.0.0 → 1.1.0 → 1.1.1 → 1.1.2 → 1.2.0 → 1.2.1 → 1.2.2 → 1.2.3 → 1.2.4 → 1.2.5 → 1.3.0 → 1.3.1)
# Les noms de fichiers (DB_Rejuvenating_*.rb) et la clé de sauvegarde ne changent pas.
# Cible : Pokémon Rejuvenation V14 (vérifié contre GAME_VERSION '14.0.24')
#
# Ce fichier DOIT rester chargé : tous les autres modules en dépendent.
# ScriptLoader charge Dir["./patch/Mods/*.rb"] trié par nom :
# "DB_Rejuvenating_Core.rb" passe avant "..._Data_*.rb" puis "..._Mod*.rb".
#
# État du patch = simple Hash (symboles, chaînes, nombres, booléens) rangée
# dans $PokemonGlobal : la sauvegarde reste chargeable si le patch est retiré.
# =============================================================================

module DBRejuvenating
  # Redéfinit une constante sans avertissement (F12 = rechargement des scripts)
  def self.setc(name, value)
    remove_const(name) if const_defined?(name, false)
    const_set(name, value)
  end

  setc(:PATCH_NAME, "DB's Rejuvenating Settings")
  # Anciens noms : les Pokémon donnés par une version précédente restent reconnus
  setc(:OLD_PATCH_NAMES, ["DB's Rejuvenating", "DB's Rejuthingy"])
  setc(:PATCH_VERSION, "1.3.1")
  setc(:RELEASE_STATUS, "stable")   # 1.3.0 : première version stable, prête à être partagée
  setc(:BONDED_TIER, 4)   # palier "Bonded" (v1.2.5 : 5 paliers, Devoted ajouté en 3)
  setc(:TESTED_GAME_VERSION, "14.0.24")

  # ---------------------------------------------------------------------------
  # CONFIGURATION — modifiez uniquement les valeurs à droite.
  # Désactiver un module : false ici, OU renommer son fichier en .rb.off
  # ---------------------------------------------------------------------------
  setc(:CONFIG, {
    # --- Module 1 : Rare Candy ---
    rare_candy:                 true,   # boutique de bonbons (Rare Candy + Reverse Candy)
    candy_tier_size:            10,     # nombre de bonbons vendus à chaque palier de prix
    rare_candy_prices:          [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000],
    reverse_candy_shop:         true,   # vend aussi des Reverse Candy (-1 niveau)
    reverse_candy_prices:       [10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
                                        # après le dernier palier : épuisé jusqu'à la remise à zéro
                                        # remise à zéro : à chaque nouveau chapitre ou badge
    candy_free_after_league:    true,   # 18 badges + champion de la Ligue Virtuelle : gratuit, illimité
    rare_candy_respect_cap:     true,   # le Rare Candy ne dépasse JAMAIS le plafond de badges

    # --- Module 2 : Pokémon ---
    special_pokemon:            true,   # 2e starter : Floette Fleur Éternelle, disponible dès le starter
    progression_pokemon:        true,   # légendaires/fabuleux/UC/paradoxes introuvables, débloqués par la progression
    # Rythme (v1.3.0) : nombre MINIMUM de badges avant qu'un légendaire du mod soit
    # réclamable, calé sur le jeu de base (1er légendaire "boîte" du jeu : Necrozma,
    # chapitre 11 ; 1er fabuleux : Meltan, ~6 badges). S'ajoute aux conditions.
    min_badges_restricted:      11,     # légendaires Restreints (Mewtwo, Kyogre, Zacian...)
    min_badges_legendary:       6,      # autres légendaires et fabuleux
    min_badges_ub_paradox:      8,      # Ultra-Chimères et Paradoxes
    gift_signature_moves:       true,   # Floette : Light of Ruin / Rayquaza : Dragon Ascent (requis pour Méga-Rayquaza)
    tickets:                    true,   # chaque légendaire réclamé coûte 1 ticket

    # --- Module 3 : Objets (méga-gemmes, cristaux Z, objets de forme) ---
    progression_items:          true,
    badge_fallback:             false,  # true = 12 badges remplacent la victoire contre le dresseur (utile seulement
                                        # pour une sauvegarde où ce dresseur était battu AVANT l'installation)

    # --- Modules 4/5 : Correctifs de données ---
    fix_floette_export_name:    true,
    data_fixes:                 true,   # Darkranite + Garchompite Z, Tatsugirinite, Reins of Unity

    # --- Module 8 : Lien (bond), budget d'équipe, objets de soin adverses ---
    bond:                       true,   # paliers Sauvage / Confiant / Loyal / Lié
    wild_disobey_percent:       25,     # palier Sauvage : % de chances d'ignorer un ordre (cadeaux du patch)
    team_budget:                true,   # budget de points selon le chapitre ; au-delà, désobéissance
    over_budget_disobey:        true,
    enemy_items:                true,   # mode Normal : soins supplémentaires aux dresseurs adverses
    boss_kit:                   true,   # mode Normal : un chef (Champion d'Arène, Conseil, Ligue) SANS objet de
                                        # soin dans le jeu de base reçoit 2 soins + 2 objets X (Vitesse + Attaque/Spéciale)

    # --- Module 9 : Épreuves ---
    guardian_trials:            true,   # épreuve du Gardien pour chaque légendaire "Restreint"
    chapter_trials:             true,   # épreuve du Miroir à chaque nouveau chapitre (une seule chance)
    chapter_trial_autosave:     true,   # sauvegarde automatique juste après le choix (anti-rechargement)
    ultimate_trial:             true,   # épreuve ultime (fin de jeu) : 1v1, 2v2, 3 contre 3 ; rejouable tant qu'on gagne,
                                        # 1 ticket par victoire, un Pokémon engagé ne revient jamais, 1 défaite = fermée
  })

  def self.cfg(key)
    return CONFIG[key]
  end

  def self.enabled?(key)
    return CONFIG[key] == true
  end

  # ---------------------------------------------------------------------------
  # Journal (dossier de sauvegarde, sinon dossier du jeu)
  # ---------------------------------------------------------------------------
  def self.log(msg)
    begin
      path = (RTP.getSaveFileName("DB_Rejuvenating_log.txt") rescue "DB_Rejuvenating_log.txt")
      File.open(path, "ab") { |f| f.write("[#{Time.now}] #{msg}\n") }
    rescue
      # Le journal ne doit jamais faire planter le jeu
    end
  end

  # ---------------------------------------------------------------------------
  # État persistant (dans la sauvegarde, via $PokemonGlobal)
  # ---------------------------------------------------------------------------
  def self.state
    return nil unless $PokemonGlobal
    st = $PokemonGlobal.instance_variable_get(:@dbRejuvenating)
    unless st.is_a?(Hash)
      st = { :version => 3 }
      # Reprise d'une sauvegarde de l'ancien nom ("DB's Rejuthingy Patch")
      old = $PokemonGlobal.instance_variable_get(:@dbRejuthingy)
      if old.is_a?(Hash)
        st[:claimed] = (old[:claimed] || {}).dup
        st[:beaten] = (old[:beaten] || {}).dup
      end
      $PokemonGlobal.instance_variable_set(:@dbRejuvenating, st)
    end
    [:claimed, :beaten, :trials_won, :chapter_trials, :rifts, :bond_best].each do |k|
      st[k] = {} unless st[k].is_a?(Hash)
    end
    st[:ceremony_queue] = [] unless st[:ceremony_queue].is_a?(Array)
    st[:battle_counter] = 0 unless st[:battle_counter].is_a?(Integer)
    # Identifiant unique de CETTE partie (sert au fichier anti-rechargement des épreuves)
    st[:save_uid] ||= "#{($Trainer.id rescue 0)}-#{rand(2**30)}-#{Time.now.to_i}"
    return st
  end

  def self.claimed?(key)
    st = state
    return false unless st
    return st[:claimed][key] == true
  end

  def self.markClaimed(key)
    st = state
    return unless st
    st[:claimed][key] = true
    log("Réclamé : #{key}")
  end

  # Dresseurs battus (rempli par le module 6, clé "TYPE|Nom")
  def self.beatKey(type, name)
    return "#{type}|#{name}"
  end

  def self.recordBeat(type, name)
    st = state
    return unless st && type && name
    k = beatKey(type, name)
    return if st[:beaten][k]
    st[:beaten][k] = true
    log("Dresseur battu : #{k}")
  end

  def self.beaten?(type, name)
    st = state
    return false unless st
    return st[:beaten][beatKey(type, name)] == true
  end

  # ---------------------------------------------------------------------------
  # Garde-fous : le menu n'agit que dans un état de jeu "normal"
  # ---------------------------------------------------------------------------
  def self.safeState
    return [false, _INTL("Game data not loaded.")] unless $Trainer && $PokemonGlobal && $game_switches && $PokemonBag
    return [false, _INTL("This menu opens once you have your first Pokémon.")] if $Trainer.party.nil? || $Trainer.party.length == 0
    # Segments où l'on joue un autre personnage : équipe/sac temporaires (CharacterSwitch.rb)
    return [false, _INTL("This is not available while you play as another character.")] if $game_switches[:NotPlayerCharacter]
    # Mode spécial "Angelica Tower" (plafonds de niveau différents, refreshLevelCaps)
    return [false, _INTL("This is not available during this part of the story.")] if $game_switches[:AngelicaTower]
    if defined?(pbInSafari?) && pbInSafari?
      return [false, _INTL("This is not available in the Safari Zone.")]
    end
    interp = ($game_system.map_interpreter rescue nil)
    return [false, _INTL("This is not available during an event. Try again once it is over.")] if interp && interp.running?
    return [true, nil]
  end

  # Plafond EXACT utilisé par Rejuvenation (Pokemon#obedient, Battle.rb gain d'EXP)
  def self.levelCap
    caps = (LEVELCAPS rescue nil)
    return MAXIMUMLEVEL unless caps.is_a?(Array) && !caps.empty?
    nb = numBadges
    return (caps[nb] || caps.last).to_i
  end

  def self.numBadges
    return ($Trainer.numbadges rescue 0).to_i
  end

  # ---------------------------------------------------------------------------
  # Difficulté du jeu : $game_variables[:DifficultyModes] (variable 200)
  #   0 = Normal, 1 = Story (facile). 2 = Intense : supprimé du jeu depuis la V13.5
  #   (la variable 200 n'est plus jamais mise à 2 ; le code reste inoffensif)
  # ---------------------------------------------------------------------------
  def self.difficulty
    v = ($game_variables[:DifficultyModes] rescue 0)
    return v.is_a?(Integer) ? v : 0
  end

  def self.storyMode?
    return difficulty == 1
  end

  def self.intenseMode?
    return difficulty == 2
  end

  # ---------------------------------------------------------------------------
  # Chapitres : quêtes :Chapter1 … :Chapter16 (Rejuv/Quest). Chapitre actuel =
  # le plus grand numéro activé ou terminé.
  # ---------------------------------------------------------------------------
  def self.chapter
    q = ($PokemonGlobal.quests rescue nil)
    return 1 unless q
    best = 1
    (q.active_quests + q.completed_quests + q.failed_quests).each do |quest|
      id = (quest.id rescue nil).to_s
      next unless id =~ /\AChapter(\d+)\z/
      best = $1.to_i if $1.to_i > best
    end
    return best
  end

  def self.chapterName(n)
    begin
      return QuestModule.const_get("Chapter#{n}".to_sym)[:Name].to_s
    rescue
      return "Chapter #{n}"
    end
  end

  # ---------------------------------------------------------------------------
  # Catégories de légendaires (budget d'équipe, lien, épreuves)
  # ---------------------------------------------------------------------------
  setc(:RESTRICTED, [
    :MEWTWO, :LUGIA, :HOOH, :KYOGRE, :GROUDON, :RAYQUAZA, :DIALGA, :PALKIA, :GIRATINA,
    :RESHIRAM, :ZEKROM, :KYUREM, :XERNEAS, :YVELTAL, :ZYGARDE, :COSMOG, :COSMOEM,
    :SOLGALEO, :LUNALA, :NECROZMA, :ZACIAN, :ZAMAZENTA, :ETERNATUS, :CALYREX,
    :KORAIDON, :MIRAIDON, :TERAPAGOS,
  ])
  # Légendaires, fabuleux, Ultra-Chimères et Paradoxes (même traitement : coût 2)
  setc(:OTHER_LEGENDS, [
    :ARTICUNO, :ZAPDOS, :MOLTRES, :MEW, :RAIKOU, :ENTEI, :SUICUNE, :CELEBI,
    :REGIROCK, :REGICE, :REGISTEEL, :LATIAS, :LATIOS, :JIRACHI, :DEOXYS,
    :UXIE, :MESPRIT, :AZELF, :HEATRAN, :REGIGIGAS, :CRESSELIA, :PHIONE, :MANAPHY,
    :DARKRAI, :SHAYMIN, :ARCEUS, :VICTINI, :COBALION, :TERRAKION, :VIRIZION,
    :TORNADUS, :THUNDURUS, :LANDORUS, :KELDEO, :MELOETTA, :GENESECT,
    :DIANCIE, :HOOPA, :VOLCANION, :TYPENULL, :SILVALLY, :TAPUKOKO, :TAPULELE,
    :TAPUBULU, :TAPUFINI, :MAGEARNA, :MARSHADOW, :ZERAORA, :MELTAN, :MELMETAL,
    :NIHILEGO, :BUZZWOLE, :PHEROMOSA, :XURKITREE, :CELESTEELA, :KARTANA,
    :GUZZLORD, :POIPOLE, :NAGANADEL, :STAKATAKA, :BLACEPHALON,
    :ZARUDE, :KUBFU, :URSHIFU, :REGIELEKI, :REGIDRAGO, :GLASTRIER, :SPECTRIER,
    :ENAMORUS, :WOCHIEN, :CHIENPAO, :TINGLU, :CHIYU, :OKIDOGI, :MUNKIDORI,
    :FEZANDIPITI, :OGERPON, :PECHARUNT,
    :GREATTUSK, :SCREAMTAIL, :BRUTEBONNET, :FLUTTERMANE, :SLITHERWING, :SANDYSHOCKS,
    :ROARINGMOON, :WALKINGWAKE, :GOUGINGFIRE, :RAGINGBOLT,
    :IRONTREADS, :IRONBUNDLE, :IRONHANDS, :IRONJUGULIS, :IRONMOTH, :IRONTHORNS,
    :IRONVALIANT, :IRONLEAVES, :IRONBOULDER, :IRONCROWN,
  ])
  # v1.3.1 : légendaires non Restreints mais aussi puissants (Arceus, 720) :
  # coût et minimum de badges d'un Restreint, sans Épreuve du Gardien (sa
  # condition exige déjà Dialga + Palkia + Giratina, qui en demandent une chacun).
  setc(:HEAVY_LEGENDS, [:ARCEUS])
  # Ultra-Chimères et Paradoxes : coût 1 dans le budget, Lié ou non (v1.2.4)
  setc(:ONE_POINT_LEGENDS, [
    :NIHILEGO, :BUZZWOLE, :PHEROMOSA, :XURKITREE, :CELESTEELA, :KARTANA,
    :GUZZLORD, :POIPOLE, :NAGANADEL, :STAKATAKA, :BLACEPHALON,
    :GREATTUSK, :SCREAMTAIL, :BRUTEBONNET, :FLUTTERMANE, :SLITHERWING, :SANDYSHOCKS,
    :ROARINGMOON, :WALKINGWAKE, :GOUGINGFIRE, :RAGINGBOLT,
    :IRONTREADS, :IRONBUNDLE, :IRONHANDS, :IRONJUGULIS, :IRONMOTH, :IRONTHORNS,
    :IRONVALIANT, :IRONLEAVES, :IRONBOULDER, :IRONCROWN,
  ])

  # Floette Fleur Éternelle : 2e starter, traité comme un "légendaire" de coût 1
  def self.eternalFloette?(pkmn)
    return false unless pkmn && pkmn.species == :FLOETTE
    name = ($cache.pkmn[:FLOETTE].forms[pkmn.form] rescue nil)
    return name == "Eternal Flower" || name == "Mega Form" || name == "Mega Eternal Flower"
  end

  def self.restricted?(species)
    return RESTRICTED.include?(species)
  end

  def self.legendSpecies?(species)
    return RESTRICTED.include?(species) || OTHER_LEGENDS.include?(species)
  end

  # Pokémon concerné par le lien (bond) : tout légendaire + Floette Éternelle
  def self.bondable?(pkmn)
    return false unless pkmn && !(pkmn.isEgg? rescue true)
    return true if legendSpecies?(pkmn.species)
    return eternalFloette?(pkmn)
  end

  # Cadeau du patch (seuls eux comptent dans le budget et le palier Sauvage)
  def self.patchGift?(pkmn)
    return false unless pkmn
    return true if pkmn.instance_variable_get(:@dbrGift) == true
    txt = (pkmn.obtainText rescue nil).to_s
    return txt == PATCH_NAME || OLD_PATCH_NAMES.include?(txt)
  end

  # Coût "d'origine" (pour les soins adverses) et coût actuel (budget)
  def self.baseCost(pkmn)
    return 0 unless patchGift?(pkmn)
    return 1 if eternalFloette?(pkmn)
    return 1 if ONE_POINT_LEGENDS.include?(pkmn.species)
    return 3 if restricted?(pkmn.species) || HEAVY_LEGENDS.include?(pkmn.species)
    return 2 if legendSpecies?(pkmn.species)
    return 0
  end

  def self.teamCost(pkmn)
    base = baseCost(pkmn)
    return 0 if base == 0
    return base if eternalFloette?(pkmn) || ONE_POINT_LEGENDS.include?(pkmn.species)
    tier = (DBRejuvenating::Bond.tier(pkmn) rescue 0)
    return tier >= BONDED_TIER ? base - 1 : base
  end

  # Budget selon le chapitre (Ch1-2:2, 3-5:3, 6-8:4, 9-11:5, 12-14:6, 15-16:7)
  def self.teamBudget
    ch = chapter
    return 2 if ch <= 2
    return 3 if ch <= 5
    return 4 if ch <= 8
    return 5 if ch <= 11
    return 6 if ch <= 14
    return 7
  end

  # ---------------------------------------------------------------------------
  # Tickets : gagnés = badges + épreuves de chapitre réussies + boss des Failles
  # + champion de la Virtual League ; dépensés = légendaires réclamés.
  # ---------------------------------------------------------------------------
  setc(:RIFT_BOSSES, [
    :RIFTGYARADOS1, :RIFTGYARADOS2, :RIFTCHANDELURE, :RIFTGALVANTULA, :RIFTVOLCANION,
    :RIFTCARNIVINE, :RIFTGARBODOR, :RIFTFERROTHORN, :RIFTAELITA, :RIFTHIPPOWDON,
    :RIFTTALON, :ARCHRIFTGALVANTULA, :ARCHRIFTVOLCANION,
  ])
  setc(:LEAGUE_CHAMPION, [:JOHTO_13, "Lance"])   # Virtual League (West Gearen, Map266)

  def self.ticketsEarned
    st = state
    return 0 unless st
    n = numBadges
    n += st[:chapter_trials].values.count { |v| v == :won }
    n += st[:rifts].keys.length
    n += 1 if st[:league_won]
    n += ultimateWins
    return n
  end

  def self.ticketsSpent
    st = state
    return 0 unless st
    return st[:claimed].keys.count { |k| (k.to_s.start_with?("prog_") || k.to_s.start_with?("miss_")) && st[:claimed][k] == true }
  end

  # Épreuve ultime : nombre de victoires (1 ticket chacune)
  def self.ultimateWins
    st = state
    return 0 unless st
    return st[:ultimate_wins].to_i if st.key?(:ultimate_wins)
    return st[:ultimate_won] ? 1 : 0   # compatibilité 1.2.0
  end

  def self.ticketsAvailable
    return 999 unless enabled?(:tickets)
    return [ticketsEarned - ticketsSpent, 0].max
  end

  # ---------------------------------------------------------------------------
  # Conditions de déblocage (toutes vérifiables en lecture seule)
  #   [:start]                    disponible dès le starter
  #   [:seen, :SP]                SP vu au Pokédex (vous l'avez affronté)
  #   [:own, :SP]                 SP capturé/obtenu (Pokédex "possédé")
  #   [:own_all, [:A,:B]]         tous possédés
  #   [:own_any, [:A,:B]]         au moins un possédé
  #   [:badges, n]                au moins n badges
  #   [:beat, :TYPE, "Nom"]       dresseur battu (depuis l'installation du patch)
  #   [:var_ge, id, n]            variable du jeu $game_variables[id] >= n
  #   [:var_eq, id, n]            variable du jeu $game_variables[id] == n
  #   [:task, "texte", [c, ...]]  quête : toutes les sous-conditions, affichée avec "texte"
  #   [:bond, :SP, palier]        un SP possédé a atteint ce palier de lien (2 = Loyal)
  #   [:all, [cond, ...]]         toutes les sous-conditions
  #   [:any, [cond, ...]]         au moins une sous-condition
  # Une entrée est débloquée si AU MOINS UNE de ses conditions est vraie.
  # ---------------------------------------------------------------------------
  def self.dexSeen?(sp)
    return ($Trainer.pokedex.seen?(sp) rescue false) == true
  end

  def self.dexOwned?(sp)
    return ($Trainer.pokedex.owned?(sp) rescue false) == true
  end

  # ---------------------------------------------------------------------------
  # Légendaires ratés (v1.2.4) : légendaires que le JEU donne, mais qu'on a ratés.
  #  - combat sauvage fini sans capture (K.O. ou fuite) : noté avec le chapitre ;
  #    disponible dès le chapitre SUIVANT (l'histoire est passée à autre chose) ;
  #  - jamais rencontré : disponible seulement en fin de jeu (18 badges + champion
  #    de la Ligue Virtuelle), car on ne peut pas savoir s'il est encore accessible.
  #  - déjà possédé (capturé normalement) : jamais proposé (pas de doublon).
  # ---------------------------------------------------------------------------
  def self.missedLog
    st = state
    return {} unless st
    st[:missed_wild] = {} unless st[:missed_wild].is_a?(Hash)
    return st[:missed_wild]
  end

  def self.recordMissed(sp)
    return if dexOwned?(sp)
    ml = missedLog
    return if ml[sp]
    ml[sp] = chapter
    log("Légendaire raté (combat sans capture) : #{sp}, chapitre #{chapter}")
  end

  def self.missedMet?(sp)
    return false if dexOwned?(sp)
    ch = missedLog[sp]
    return true if ch && chapter > ch.to_i
    st = state
    return numBadges >= 18 && st && st[:league_won] == true
  end

  def self.missedText(sp)
    return _INTL("you already own {1} (caught in the game), so the mod does not offer it", monName(sp)) if dexOwned?(sp)
    ch = missedLog[sp]
    if ch
      return _INTL("you battled {1} in Chapter {2} without catching it.\nIt becomes available when the next chapter starts", monName(sp), ch)
    end
    return _INTL("you never battled it (or not since this mod was installed).\nThe mod cannot tell if you can still find it in the game, so it becomes available only at the end: all 18 badges and the Virtual League champion beaten.\nIf you can still catch it in the game, do that instead")
  end

  # Variable du jeu en lecture seule (0 si absente ou non numérique)
  def self.gameVar(id)
    v = ($game_variables[id] rescue 0)
    return v.is_a?(Numeric) ? v.to_i : 0
  end

  def self.bondBest(sp)
    st = state
    return 0 unless st
    return st[:bond_best][sp].to_i
  end

  def self.condMet?(c)
    case c[0]
      when :start   then return true
      when :seen    then return dexSeen?(c[1])
      when :own     then return dexOwned?(c[1])
      when :own_all then return c[1].all? { |s| dexOwned?(s) }
      when :own_any then return c[1].any? { |s| dexOwned?(s) }
      when :badges  then return numBadges >= c[1].to_i
      when :beat    then return beaten?(c[1], c[2])
      when :var_ge  then return gameVar(c[1]) >= c[2].to_i
      when :var_eq  then return gameVar(c[1]) == c[2].to_i
      when :task    then return c[2].all? { |x| condMet?(x) }
      when :missed  then return missedMet?(c[1])
      when :bond    then return !enabled?(:bond) || bondBest(c[1]) >= c[2].to_i
      when :all     then return c[1].all? { |x| condMet?(x) }
      when :any     then return c[1].any? { |x| condMet?(x) }
    end
    return false
  end

  def self.unlocked?(conds)
    return conds.any? { |c| condMet?(c) }
  end

  def self.monName(sp)
    return (getMonName(sp) rescue sp.to_s.capitalize)
  end

  setc(:TIER_NAMES, ["Wild", "Trusting", "Loyal", "Devoted", "Bonded"])   # v1.2.5 : + Devoted

  def self.condText(c)
    case c[0]
      when :start   then return _INTL("available now")
      when :seen    then return _INTL("meet {1} in a battle (for example a trainer or boss using it)", monName(c[1]))
      when :own     then return _INTL("own {1}", monName(c[1]))
      when :own_all then return _INTL("own {1}", c[1].map { |s| monName(s) }.join(" + "))
      when :own_any then return _INTL("own {1}", c[1].map { |s| monName(s) }.join(" or "))
      when :badges  then return _INTL("own {1} badges", c[1])
      when :beat    then return _INTL("defeat {1}", c[2])
      when :var_ge, :var_eq then return _INTL("progress further in the story")
      when :task    then return _INTL(c[1])
      when :missed  then return missedText(c[1])
      when :bond    then return _INTL("{1} reaches the {2} bond tier (see Pokémon > Bonds & team budget)", monName(c[1]), TIER_NAMES[c[2].to_i] || "?")
      when :all     then return c[1].map { |x| condText(x) }.join(_INTL(" AND "))
      when :any     then return "(" + c[1].map { |x| condText(x) }.join(_INTL(" or ")) + ")"
    end
    return "?"
  end

  def self.hint(conds)
    return conds.map { |c| condText(c) }.join(_INTL("\nOR\n"))
  end

  # ---------------------------------------------------------------------------
  # Parcours de tous les Pokémon du joueur (équipe + PC)
  # ---------------------------------------------------------------------------
  def self.eachOwnedPokemon
    ($Trainer.party rescue []).each { |p| yield p if p }
    st = $PokemonStorage rescue nil
    return unless st
    begin
      boxes = st.maxBoxes
      return unless boxes.is_a?(Integer) && boxes > 0 && boxes < 1000   # garde-fou : jamais de boucle sans fin
      (0...boxes).each do |b|
        slots = st.maxPokemon(b)
        next unless slots.is_a?(Integer) && slots > 0 && slots < 1000
        (0...slots).each do |s|
          p = st[b, s]
          yield p if p
        end
      end
    rescue StandardError => e
      log("ERREUR parcours PC : #{e.message}")
    end
  end

  # ---------------------------------------------------------------------------
  # Registre des entrées du menu du patch (rempli par chaque module)
  # ---------------------------------------------------------------------------
  @entries = {}

  # group : :pokemon, :items ou :trials (sous-menus du menu du mod, v1.2.3)
  def self.registerEntry(id, order:, name:, condition: nil, effect:, group: nil)
    @entries[id] = { :id => id, :order => order, :name => name, :condition => condition, :effect => effect, :group => group }
  end

  def self.entries
    return @entries.sort_by { |_, v| v[:order] }.map { |_, v| v }
  end

  # Donne un objet ; ne marque réclamé qu'en cas de succès
  def self.giveItemOnce(key, item, qty = 1)
    return false if claimed?(key)
    unless $cache.items[item]
      Kernel.pbMessage(_INTL("The item {1} does not exist in this version of the game.\nNothing was given.", item.to_s))
      log("ERREUR objet inexistant : #{item}")
      return false
    end
    if Kernel.pbReceiveItem(item, qty)
      markClaimed(key)
      return true
    end
    return false
  end

  # Liste à défilement avec entrées verrouillées : renvoie l'index choisi ou -1
  def self.chooseFromList(title, labels)
    commands = labels + [_INTL("Back")]
    cmd = Kernel.pbMessage(title, commands, -1)
    return -1 if cmd < 0 || cmd >= labels.length
    return cmd
  end
end

DBRejuvenating.log("#{DBRejuvenating::PATCH_NAME} v#{DBRejuvenating::PATCH_VERSION} chargé (jeu #{GAME_VERSION rescue '?'})")
