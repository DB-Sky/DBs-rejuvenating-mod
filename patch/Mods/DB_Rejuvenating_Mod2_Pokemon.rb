# =============================================================================
# DB's Rejuvenating Settings — MODULE 2 : Pokémon (cadeaux uniques)
#
# Audit local V14 (689 cartes + événements communs + rencontres + tanières +
# Échange Miracle + pools XT + boutiques + mots de passe + évolutions) :
# les espèces ci-dessous n'ont AUCUNE source joueur en V14.
#
# A) 2e starter : Floette Fleur Éternelle, disponible dès le starter.
#    (Diancie n'est PAS donné : le jeu le donne déjà — sac de Karrina, Game Show,
#     Map478, niveau 80, $game_variables[756] >= 22.)
# B) Les autres (dont Rayquaza et Magearna) : débloquées par la PROGRESSION, en priorité "affronter le
#    dresseur / boss qui l'utilise" (= Pokémon vu au Pokédex, rétroactif),
#    sinon un lien logique (trio, forme liée) ou un nombre de badges.
# Niveau du cadeau = plafond d'obéissance actuel → il obéit toujours.
# Les formes sont résolues PAR NOM ; aucune donnée du jeu n'est écrasée.
# Aucun événement du scénario ne teste la possession de ces espèces
# (seul pbHasSpecies?(:SILVALLY) existe, Map433, et Silvally n'est pas donné ici).
# =============================================================================

if defined?(DBRejuvenating) && (DBRejuvenating.enabled?(:special_pokemon) || DBRejuvenating.enabled?(:progression_pokemon))
  module DBRejuvenating
    module SpecialPokemon
      remove_const(:STARTERS) if const_defined?(:STARTERS, false) # rechargement F12
      STARTERS = [
        { :key => :eternal_floette, :species => :FLOETTE, :form_name => "Eternal Flower",
          :label => "Eternal Flower Floette", :moves => [], :cond => [[:start]] },
        # v1.3.0 : Light of Ruin (140, Fée) n'est plus donnée d'emblée : Floette
        # l'apprend en atteignant le palier Confiant (module 8).
      ]

      # Déblocages par progression. :seen = dresseur/boss qui l'utilise (voir rapport).
      # Format : [espèce, conditions] ou [espèce, conditions, attaques signature]
      remove_const(:PROGRESSION) if const_defined?(:PROGRESSION, false)
      PROGRESSION = [
        # --- Kanto / Johto / Hoenn ---
        [:MEWTWO,     [[:seen, :MEWTWO]]],                                   # Madelis / Percival
        [:MEW,        [[:own, :MEWTWO]]],
        # v1.3.0 : aucun dresseur, boss ni événement n'utilise Lugia en V14 (condition
        # impossible). Lugia protège les oiseaux légendaires → posséder les trois.
        [:LUGIA,      [[:seen, :LUGIA], [:own_all, [:ARTICUNO, :ZAPDOS, :MOLTRES]]]],
        [:HOOH,       [[:own_all, [:RAIKOU, :ENTEI, :SUICUNE]]]],
        [:LATIAS,     [[:seen, :LATIAS], [:own, :LATIOS]]],
        [:KYOGRE,     [[:seen, :KYOGRE]]],                                   # boss BOSSKYOGRE
        [:GROUDON,    [[:seen, :GROUDON]]],                                  # boss BOSSGROUDON
        [:JIRACHI,    [[:badges, 5]]],
        # Rayquaza : aucun combat en V14. Lien trouvé dans les fichiers : la quête du
        # sculpteur (artiste de Goldenleaf Town → Directeur du Sapphire Museum,
        # Kristiline Town). $game_variables[48] = 4 : quête finie ; [570] = 1 : statue
        # de Rayquaza choisie (2 = Groudon, 3 = Kyogre). Autre statue choisie →
        # v1.2.5 : Rayquaza apaise le combat de Kyogre et Groudon → les avoir tous
        # deux rencontrés en combat, avec au moins 11 badges (v1.3.2 : 15 -> 11).
        [:RAYQUAZA,   [[:task, "finish the sculptor quest (Goldenleaf Town artist, then Sapphire Museum in Kristiline Town) and pick the Rayquaza statue",
                        [[:var_ge, 48, 4], [:var_eq, 570, 1]]],
                       [:all, [[:seen, :KYOGRE], [:seen, :GROUDON], [:badges, 11]]]],
                      [:DRAGONASCENT]],
        # --- Sinnoh ---
        [:DIALGA,     [[:seen, :DIALGA]]],                                   # boss Tiempa
        [:PALKIA,     [[:seen, :PALKIA]]],                                   # boss Spacea
        [:GIRATINA,   [[:seen, :GIRATINA]]],
        [:HEATRAN,    [[:seen, :HEATRAN]]],                                  # Percival
        [:REGIGIGAS,  [[:seen, :REGIGIGAS], [:own_all, [:REGIROCK, :REGICE, :REGISTEEL]]]],
        [:CRESSELIA,  [[:seen, :CRESSELIA]]],
        [:MANAPHY,    [[:seen, :MANAPHY]]],                                  # boss Sea Prince
        [:DARKRAI,    [[:seen, :DARKRAI]]],
        [:ARCEUS,     [[:seen, :ARCEUS], [:own_all, [:DIALGA, :PALKIA, :GIRATINA]]]],
        # --- Unys ---
        [:VICTINI,    [[:seen, :VICTINI]]],                                  # Eizen
        [:COBALION,   [[:own_all, [:TERRAKION, :VIRIZION]]]],
        [:KELDEO,     [[:own_all, [:COBALION, :TERRAKION, :VIRIZION]]]],
        [:TORNADUS,   [[:seen, :TORNADUS]]],                                 # Talon
        [:THUNDURUS,  [[:own, :TORNADUS]]],
        [:LANDORUS,   [[:own_all, [:TORNADUS, :THUNDURUS]]]],
        [:RESHIRAM,   [[:seen, :RESHIRAM]]],
        [:ZEKROM,     [[:seen, :ZEKROM]]],
        [:KYUREM,     [[:seen, :KYUREM]]],                                   # Angie
        # --- Kalos ---
        [:XERNEAS,    [[:seen, :XERNEAS]]],
        [:HOOPA,      [[:badges, 7]]],
        [:VOLCANION,  [[:seen, :VOLCANION]]],
        [:MAGEARNA,   [[:beat, :LEADER_SAKI2, "Saki"], [:badges, 12]]],   # Pokémon-machine → badge de l'Axis Factory (Map111)
        # --- Alola ---
        [:TAPUKOKO,   [[:seen, :TAPUKOKO]]],
        [:TAPULELE,   [[:own, :TAPUKOKO]]],
        [:TAPUBULU,   [[:own, :TAPUKOKO]]],
        [:TAPUFINI,   [[:own, :TAPUKOKO]]],
        [:COSMOG,     [[:own, :NECROZMA]]],                                  # évolue en Solgaleo/Lunala
        [:MARSHADOW,  [[:seen, :MARSHADOW]]],
        [:ZERAORA,    [[:badges, 5]]],
        [:BUZZWOLE,   [[:own, :NIHILEGO]]],
        [:PHEROMOSA,  [[:seen, :PHEROMOSA], [:own, :NIHILEGO]]],
        [:XURKITREE,  [[:seen, :XURKITREE]]],
        [:CELESTEELA, [[:own, :NIHILEGO]]],
        [:KARTANA,    [[:own, :NIHILEGO]]],
        [:GUZZLORD,   [[:seen, :GUZZLORD]]],
        [:POIPOLE,    [[:own, :NIHILEGO]]],                                  # évolue en Naganadel
        [:STAKATAKA,  [[:seen, :STAKATAKA]]],
        [:BLACEPHALON,[[:seen, :BLACEPHALON]]],
        # --- Galar ---
        # v1.2.5 : chevaliers protecteurs de la royauté → battre la Princesse Alice /
        # le Prince Allen (Angelica's WonderTower). Minimum 8 badges (v1.3.2 ; 12 avant).
        # Secours à 13 badges (17 avant) : combat fait avant l'installation du mod (non enregistré).
        [:ZACIAN,     [[:all, [[:beat, :LEADER_ALICE, "Princess Alice"], [:badges, 8]]], [:badges, 13]]],
        [:ZAMAZENTA,  [[:all, [[:any, [[:beat, :LEADER_ALLEN, "Prince Allen"], [:beat, :LEADER_ALLEN2, "Allen"]]], [:badges, 8]]], [:badges, 13]]],
        [:ETERNATUS,  [[:seen, :ETERNATUS]]],                                # Kaina
        [:KUBFU,      [[:badges, 4]]],
        [:ZARUDE,     [[:badges, 5]]],
        [:REGIELEKI,  [[:seen, :REGIELEKI]]],
        [:REGIDRAGO,  [[:seen, :REGIDRAGO]]],
        # v1.2.5 : roi des récoltes → battre Flora et Florin (champions Plante).
        # Minimum 8 badges (v1.3.2 ; 12 avant). Secours à 11 badges (14 avant) (combat non enregistré).
        [:CALYREX,    [[:all, [[:any, [[:beat, :LEADER_FLORA, "Flora"], [:beat, :LEADER_RYLAND, "Flora"]]],
                               [:any, [[:beat, :LEADER_FLORIN, "Florin"], [:beat, :LEADER_FLORIN2, "Florin"]]],
                               [:badges, 8]]], [:badges, 11]]],
        [:GLASTRIER,  [[:own, :CALYREX]]],
        [:SPECTRIER,  [[:own, :CALYREX]]],
        # --- Hisui / Paldea ---
        [:ENAMORUS,   [[:seen, :ENAMORUS]]],
        [:CHIENPAO,   [[:seen, :CHIENPAO]]],
        [:TINGLU,     [[:seen, :TINGLU]]],
        [:CHIYU,      [[:seen, :CHIYU]]],
        # v1.2.5 : Koraidon = Paradoxe du passé, Miraidon = Paradoxe du futur →
        # posséder un Paradoxe de la même époque. Minimum 11 badges (v1.3.2 ; 15 avant).
        [:KORAIDON,   [[:all, [[:own_any, [:GREATTUSK, :SCREAMTAIL, :BRUTEBONNET, :FLUTTERMANE, :SLITHERWING,
                                           :SANDYSHOCKS, :ROARINGMOON, :WALKINGWAKE, :GOUGINGFIRE, :RAGINGBOLT]],
                               [:badges, 11]]]]],
        [:MIRAIDON,   [[:all, [[:own_any, [:IRONTREADS, :IRONBUNDLE, :IRONHANDS, :IRONJUGULIS, :IRONMOTH,
                                           :IRONTHORNS, :IRONVALIANT, :IRONLEAVES, :IRONBOULDER, :IRONCROWN]],
                               [:badges, 11]]]]],
        [:PECHARUNT,  [[:seen, :PECHARUNT]]],                                # Shayda
        [:OKIDOGI,    [[:seen, :PECHARUNT]]],
        [:MUNKIDORI,  [[:seen, :PECHARUNT]]],
        [:FEZANDIPITI,[[:seen, :PECHARUNT]]],
        [:OGERPON,    [[:badges, 7]]],
        [:TERAPAGOS,  [[:seen, :TERAPAGOS]]],                                # Eizen
        # --- Paradoxes introuvables ---
        [:GREATTUSK,  [[:seen, :GREATTUSK]]],
        [:IRONBUNDLE, [[:seen, :IRONBUNDLE]]],
        [:IRONHANDS,  [[:seen, :IRONHANDS]]],
        [:ROARINGMOON,[[:seen, :ROARINGMOON]]],
        [:IRONCROWN,  [[:seen, :IRONCROWN]]],
        [:IRONLEAVES, [[:own, :VIRIZION]]],
        [:IRONBOULDER,[[:own, :TERRAKION]]],
      ]

      # Légendaires que le JEU donne (événements uniques : combats sauvages, cadeaux,
      # routes du chapitre 16). Relevé v1.2.4 sur les 690 cartes + événements communs.
      # Proposés seulement s'ils ont été ratés (voir DBRejuvenating.missedMet?).
      remove_const(:MISSED) if const_defined?(:MISSED, false)
      MISSED = [
        :ARTICUNO, :ZAPDOS, :MOLTRES, :RAIKOU, :ENTEI, :SUICUNE, :CELEBI,
        :REGIROCK, :REGICE, :REGISTEEL, :LATIOS, :DEOXYS,
        :UXIE, :MESPRIT, :AZELF, :PHIONE, :SHAYMIN,
        :TERRAKION, :VIRIZION, :MELOETTA, :GENESECT,
        :DIANCIE, :TYPENULL, :ZYGARDE, :NECROZMA, :MELTAN,
        :NIHILEGO, :WOCHIEN,
        :SCREAMTAIL, :BRUTEBONNET, :FLUTTERMANE, :SLITHERWING, :SANDYSHOCKS,
        :WALKINGWAKE, :GOUGINGFIRE, :RAGINGBOLT,
        :IRONTREADS, :IRONMOTH, :IRONTHORNS, :IRONJUGULIS, :IRONVALIANT,
      ]

      def self.missedGifts
        return MISSED.select { |sp| ($cache.pkmn.key?(sp) rescue false) }.map do |sp|
          { :key => ("miss_" + sp.to_s.downcase).to_sym, :species => sp, :moves => [], :cond => [[:missed, sp]] }
        end
      end

      # Minimum de badges selon la catégorie (CONFIG min_badges_*), v1.3.0
      # Total des stats de base (forme 0), lu dans les données du jeu
      def self.basePower(sp)
        return ($cache.pkmn[sp][0].BaseStats.sum rescue 600).to_i
      end

      # v1.3.3 : minimum de badges selon la puissance (voir CONFIG min_badges_by_power).
      # Les Restreints (Cosmog, Calyrex, Terapagos compris : ils deviennent aussi forts
      # que les autres) et Arceus ont leur propre minimum.
      def self.minBadges(sp)
        return DBRejuvenating.cfg(:min_badges_arceus).to_i if DBRejuvenating::HEAVY_LEGENDS.include?(sp)
        return DBRejuvenating.cfg(:min_badges_restricted).to_i if DBRejuvenating.restricted?(sp)
        pw = basePower(sp)
        step = (DBRejuvenating.cfg(:min_badges_by_power) || []).find { |min, _| pw >= min.to_i }
        return step ? step[1].to_i : 0
      end

      # Chaque condition d'origine reçoit le minimum de badges (jamais plus tôt que le jeu).
      # v1.3.2 : on FUSIONNE avec les badges déjà demandés par la condition (on garde le
      # plus grand nombre) au lieu d'ajouter une 2e exigence : "15 badges" et non
      # "15 badges ET 11 badges". Même effet en jeu, texte cohérent.
      def self.withFloor(sp, cond)
        n = minBadges(sp)
        return cond if n <= 0
        return cond.map do |c|
          parts = c[0] == :all ? c[1].dup : [c]
          need = ([n] + parts.select { |x| x[0] == :badges }.map { |x| x[1].to_i }).max
          parts = parts.reject { |x| x[0] == :badges } + [[:badges, need]]
          parts.length == 1 ? parts[0] : [:all, parts]
        end
      end

      def self.progressionGifts
        return PROGRESSION.map do |sp, cond, moves|
          { :key => ("prog_" + sp.to_s.downcase).to_sym, :species => sp, :moves => (moves || []), :cond => withFloor(sp, cond) }
        end
      end

      def self.label(g)
        return g[:label] || DBRejuvenating.monName(g[:species])
      end

      # Résout l'index de forme à partir du nom (nil = forme 0)
      def self.resolveForm(species, form_name)
        return nil unless ($cache.pkmn.key?(species) rescue false)
        return 0 if form_name.nil?
        return $cache.pkmn[species].forms.invert[form_name]
      end

      def self.give(g)
        key = g[:key]
        return false if DBRejuvenating.claimed?(key)
        unless DBRejuvenating.unlocked?(g[:cond])
          Kernel.pbMessage(_INTL("Locked.\nHow to unlock it:\n{1}", DBRejuvenating.hint(g[:cond])))
          return false
        end
        # Double vérification (épreuve et ticket), même si le menu l'a déjà fait
        if needsTrial?(g) && !trialWon?(g)
          Kernel.pbMessage(_INTL("You must first win the Guardian Trial of {1}.\nGo to Trials > Guardian Trials.", label(g)))
          return false
        end
        if costsTicket?(g) && DBRejuvenating.ticketsAvailable <= 0
          Kernel.pbMessage(_INTL("You have no ticket left.\nYou earn tickets from badges, Chapter Trials, Rift bosses, the Virtual League champion and Ultimate Trial victories."))
          return false
        end
        # Mots de passe "Just Budew / Just Vulpix" : le constructeur changerait l'espèce
        if $game_switches[:Just_Budew] || $game_switches[:Just_Vulpix]
          Kernel.pbMessage(_INTL("A password that changes Pokémon species is active (for example a randomizer).\nThe gift was cancelled so it is not wasted."))
          return false
        end
        if pbBoxesFull?
          Kernel.pbMessage(_INTL("Your party and your PC boxes are full.\nMake some room first."))
          return false
        end
        form = resolveForm(g[:species], g[:form_name])
        if form.nil?
          Kernel.pbMessage(_INTL("{1} does not exist in this version of the game.\nNothing was given.", label(g)))
          DBRejuvenating.log("ERREUR forme introuvable : #{g[:species]} / #{g[:form_name]}")
          return false
        end
        level = DBRejuvenating.levelCap
        pkmn = PokeBattle_Pokemon.new(g[:species], level, $Trainer, true, form)
        if pkmn.species != g[:species] || pkmn.form != form
          Kernel.pbMessage(_INTL("Something (probably a password) changed this Pokémon while it was being created.\nThe gift was cancelled so it is not wasted."))
          DBRejuvenating.log("ERREUR création : attendu #{g[:species]}/#{form}, obtenu #{pkmn.species}/#{pkmn.form}")
          return false
        end
        if DBRejuvenating.enabled?(:gift_signature_moves)
          (g[:moves] || []).each do |mv|
            next unless ($cache.moves.key?(mv) rescue false)
            pkmn.pbLearnMove(mv)
          end
        end
        pkmn.obtainText = DBRejuvenating::PATCH_NAME
        pkmn.instance_variable_set(:@dbrGift, true)   # compte dans le budget d'équipe (module 8)
        pkmn.calcStats
        pkmn.hp = pkmn.totalhp
        # pbAddPokemon : message, surnom, équipe ou PC, Pokédex (Utilities.rb)
        ok = pbAddPokemon(pkmn)
        if ok == true
          DBRejuvenating.markClaimed(key)
          (DBRejuvenating::Bond.refresh(pkmn) rescue nil)
          return true
        end
        return false
      end

      # Épreuve du Gardien exigée ? (légendaires "Restreints" des déblocages)
      def self.needsTrial?(g)
        return false unless g[:key].to_s.start_with?("prog_")
        return false unless DBRejuvenating.enabled?(:guardian_trials)
        return DBRejuvenating.restricted?(g[:species])
      end

      def self.trialWon?(g)
        st = DBRejuvenating.state
        return st && st[:trials_won][g[:species]] == true
      end

      def self.costsTicket?(g)
        k = g[:key].to_s
        return DBRejuvenating.enabled?(:tickets) && (k.start_with?("prog_") || k.start_with?("miss_"))
      end

      # :received / :locked / :story / :trial / :noticket / :ready
      def self.status(g)
        return :received if DBRejuvenating.claimed?(g[:key])
        return :caught if g[:key].to_s.start_with?("miss_") && DBRejuvenating.dexOwned?(g[:species])
        return :locked unless DBRejuvenating.unlocked?(g[:cond])
        if needsTrial?(g) && !trialWon?(g)
          return :story if DBRejuvenating.storyMode?
          return :trial
        end
        return :noticket if costsTicket?(g) && DBRejuvenating.ticketsAvailable <= 0
        return :ready
      end

      STATUS_TAGS = {
        :received => "[received] ", :locked => "[locked] ", :story => "[not in Story mode] ",
        :trial => "[TRIAL] ", :noticket => "[no ticket] ", :ready => "[READY] ",
        :caught => "[caught] "
      } unless const_defined?(:STATUS_TAGS, false)
      STATUS_TAGS[:caught] = "[caught] " unless STATUS_TAGS.key?(:caught) || STATUS_TAGS.frozen?

      def self.menu(list, title)
        loop do
          labels = list.map { |g| _INTL(STATUS_TAGS[status(g)]) + label(g) }
          head = _INTL("{1}\nThey arrive at level {2} (your level cap).", title, DBRejuvenating.levelCap)
          head += _INTL("\nTickets available: {1}", DBRejuvenating.ticketsAvailable) if DBRejuvenating.enabled?(:tickets) && list.any? { |g| costsTicket?(g) }
          cmd = DBRejuvenating.chooseFromList(head, labels)
          break if cmd < 0
          g = list[cmd]
          case status(g)
            when :received
              Kernel.pbMessage(_INTL("You already received {1}.", label(g)))
            when :caught
              Kernel.pbMessage(_INTL("You already caught {1} in the game, so the mod does not offer it again.", label(g)))
            when :locked
              Kernel.pbMessage(_INTL("{1} is locked.\nHow to unlock it:\n{2}", label(g), DBRejuvenating.hint(g[:cond])))
            when :story
              Kernel.pbMessage(_INTL("{1} is a Restricted legendary: it can only be earned by winning its Guardian Trial.\nGuardian Trials are not available in Story mode, so it cannot be claimed while you play in Story mode.", label(g)))
            when :trial
              if defined?(DBRejuvenating::Trials)
                DBRejuvenating::Trials.guardianPrompt(g[:species])
              else
                Kernel.pbMessage(_INTL("The trials file of the mod (DB_Rejuvenating_Mod9_Trials.rb) is not installed."))
              end
            when :noticket
              Kernel.pbMessage(_INTL("You need 1 ticket to claim {1}, and you have none.\nYou earn tickets from badges, Chapter Trials, Rift bosses, the Virtual League champion and Ultimate Trial victories.", label(g)))
            when :ready
              if costsTicket?(g)
                next unless Kernel.pbConfirmMessage(_INTL("Spend 1 ticket to claim {1}?\nTickets left after this: {2}", label(g), DBRejuvenating.ticketsAvailable - 1))
              end
              give(g)
          end
        end
      end
    end

    if DBRejuvenating.enabled?(:special_pokemon)
      registerEntry(:special_pokemon,
        order: 10, group: :pokemon,
        name: proc { _INTL("Second starter") },
        effect: proc { DBRejuvenating::SpecialPokemon.menu(DBRejuvenating::SpecialPokemon::STARTERS, _INTL("Your second starter (free).")) }
      )
    end

    if DBRejuvenating.enabled?(:progression_pokemon)
      registerEntry(:missed_pokemon,
        order: 25, group: :pokemon,
        name: proc { _INTL("Missed legendaries") },
        effect: proc { DBRejuvenating::SpecialPokemon.menu(DBRejuvenating::SpecialPokemon.missedGifts, _INTL("Legendaries from the game that you missed for good.")) }
      )
      registerEntry(:progression_pokemon,
        order: 20, group: :pokemon,
        name: proc { _INTL("Legendary unlocks") },
        effect: proc { DBRejuvenating::SpecialPokemon.menu(DBRejuvenating::SpecialPokemon.progressionGifts, _INTL("Legendaries unlocked by your progress.")) }
      )
    end
  end
end

# -----------------------------------------------------------------------------
# Combat sauvage d'un légendaire du jeu terminé SANS capture (K.O. ou fuite) :
# on le note (voir DBRejuvenating.recordMissed). Enveloppe pbWildBattleObject,
# utilisée par pbWildBattle et les combats sauvages scriptés.
# -----------------------------------------------------------------------------
if defined?(DBRejuvenating::SpecialPokemon) && DBRejuvenating.enabled?(:progression_pokemon) && defined?(pbWildBattleObject)
  unless defined?(dbRejuvenating_orig_pbWildBattleObject)
    alias dbRejuvenating_orig_pbWildBattleObject pbWildBattleObject
  end

  def pbWildBattleObject(pokemon, *args)
    sp = (pokemon.is_a?(Hash) ? pokemon[:species] : (pokemon.species rescue nil)) rescue nil
    ret = dbRejuvenating_orig_pbWildBattleObject(pokemon, *args)
    begin
      if sp && DBRejuvenating::SpecialPokemon::MISSED.include?(sp) && !DBRejuvenating.dexOwned?(sp)
        DBRejuvenating.recordMissed(sp)
      end
    rescue StandardError => e
      DBRejuvenating.log("ERREUR suivi des légendaires ratés : #{e.message}")
    end
    return ret
  end
end
