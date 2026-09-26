# =============================================================================
# DB's Rejuvenating Settings — MODULE 8 : Lien (bond), budget d'équipe, soins adverses
#
# LIEN (légendaires, fabuleux, Ultra-Chimères, Paradoxes + Floette Éternelle)
#   Données rangées SUR le Pokémon (@dbrBond) : elles le suivent au PC.
#   - Points de lien : +1 quand CE Pokémon met K.O. un adversaire dans un combat
#     de dresseur (1 point maximum par combat). v1.2.5 : 29 maximum (le jeu a des
#     dresseurs qu'on peut recombattre), et les points spéciaux comptent aussi
#     comme points de lien : total = K.O. + spéciaux, 30 maximum.
#   - Point spécial : badge obtenu juste après un combat où il était dans
#     l'équipe, ou victoire contre le champion de la Virtual League (module 6).
#   - Amitié : le bonheur normal du jeu (Pokemon#happiness, 0 à 255 ; la
#     plupart des légendaires démarrent à 0 dans montext.rb).
#   Paliers (v1.2.5, points = total) :
#     0 Sauvage | 1 Confiant (amitié 70 + 5) | 2 Loyal (amitié 150 + 12, gemme/cristal)
#     3 Dévoué (amitié 190 + 20 : changement de nature)
#     4 Lié (amitié 220 + 30 dont au moins 1 spécial : talent, coût -1, marque)
#   Sauvegardes plus anciennes : l'ancien palier 3 "Lié" devient le palier 4.
#   Un palier atteint n'est jamais perdu.
#
# BUDGET D'ÉQUIPE (cadeaux du patch uniquement)
#   Coût : Restreint 3 (Lié : 2), autre légendaire 2 (Lié : 1), Floette 1.
#   Budget selon le chapitre (Core.teamBudget). Au-delà : désobéissance.
#   Palier Sauvage (cadeaux du patch) : % de chances d'ignorer un ordre.
#   Rien n'empêche jamais un combat : aucun blocage possible du scénario.
#
# SOINS ADVERSES (mode Normal uniquement, pas en Story (Intense n'existe plus depuis la V13.5), pas avec
#   le mot de passe "noitems") : si votre équipe contient des cadeaux du patch,
#   chaque dresseur adverse reçoit des objets de soin en plus, selon le coût
#   d'origine total (Events.onTrainerPartyLoad, Trainers.rb). Pas de bonus de
#   statistiques, pas de niveaux en plus.
# =============================================================================

if defined?(DBRejuvenating) && DBRejuvenating.enabled?(:bond)
  module DBRejuvenating
    module Bond
      remove_const(:THRESHOLDS) if const_defined?(:THRESHOLDS, false)
      # [amitié, points de lien (total K.O. + spéciaux), points spéciaux] par palier
      THRESHOLDS = [nil, [70, 5, 0], [150, 12, 0], [190, 20, 0], [220, 30, 1]]
      remove_const(:MAX_POINTS) if const_defined?(:MAX_POINTS, false)
      MAX_POINTS = 30      # total affiché / utile
      remove_const(:MAX_KO_POINTS) if const_defined?(:MAX_KO_POINTS, false)
      MAX_KO_POINTS = 29   # points gagnés par K.O. (le 30e vient d'un point spécial)
      DATA_VERSION = 2 unless const_defined?(:DATA_VERSION, false)

      def self.data(pkmn)
        d = pkmn.instance_variable_get(:@dbrBond)
        unless d.is_a?(Hash)
          d = { :pts => 0, :special => 0, :tier => 0, :last_battle => nil, :v => DATA_VERSION }
          pkmn.instance_variable_set(:@dbrBond, d)
        end
        # Migration 1.2.4 → 1.2.5 : ancien palier 3 (Lié) = nouveau palier 4
        if d[:v].to_i < DATA_VERSION
          if d[:tier].to_i >= 3
            d[:tier] = 4
            d[:ceremony_devoted] = true if d[:ceremony_done]
          end
          d[:v] = DATA_VERSION
        end
        return d
      end

      # Points de lien totaux : K.O. + points spéciaux (30 maximum)
      def self.points(pkmn)
        d = data(pkmn)
        return [d[:pts].to_i + d[:special].to_i, MAX_POINTS].min
      end

      def self.tier(pkmn)
        return 0 unless pkmn && DBRejuvenating.bondable?(pkmn)
        return data(pkmn)[:tier].to_i
      end

      def self.tierName(t)
        return DBRejuvenating::TIER_NAMES[t.to_i] || "?"
      end

      # Palier "mérité" selon les valeurs actuelles
      def self.earnedTier(pkmn)
        d = data(pkmn)
        happy = (pkmn.happiness rescue 0).to_i
        best = 0
        total = points(pkmn)
        (1...THRESHOLDS.length).each do |t|
          h, p, s = THRESHOLDS[t]
          best = t if happy >= h && total >= p && d[:special].to_i >= s
        end
        return best
      end

      # Recalcule le palier (jamais à la baisse) ; file la cérémonie si "Lié"
      def self.refresh(pkmn)
        return unless pkmn && DBRejuvenating.bondable?(pkmn)
        d = data(pkmn)
        t = earnedTier(pkmn)
        if t > d[:tier].to_i
          old = d[:tier].to_i
          d[:tier] = t
          DBRejuvenating.log("Lien : #{pkmn.species} passe au palier #{tierName(t)}")
          # Dévoué : nature ; Lié : talent (un saut direct file les deux, dans l'ordre)
          queueCeremony(pkmn, :devoted) if old < 3 && t >= 3
          queueCeremony(pkmn, :bonded) if t >= DBRejuvenating::BONDED_TIER
        end
        # v1.3.0 : Floette Éternelle apprend Light of Ruin au palier Confiant
        if d[:tier].to_i >= 1 && DBRejuvenating.eternalFloette?(pkmn) && !d[:bond_move_done] &&
           !(pkmn.knowsMove?(:LIGHTOFRUIN) rescue false) &&
           (d[:bond_move_refused].nil? || DBRejuvenating.numBadges > d[:bond_move_refused].to_i)
          queueCeremony(pkmn, :move)
        end
        st = DBRejuvenating.state
        sp = pkmn.species
        st[:bond_best][sp] = d[:tier] if st && d[:tier].to_i > st[:bond_best][sp].to_i
      end

      def self.refreshParty
        ($Trainer.party rescue []).each { |p| refresh(p) if p }
      end

      def self.refreshAll
        DBRejuvenating.eachOwnedPokemon { |p| refresh(p) }
      end

      # K.O. dans un combat de dresseur : 1 point par combat au maximum
      def self.creditKO(pkmn, battle)
        return unless pkmn && DBRejuvenating.bondable?(pkmn)
        token = battle.instance_variable_get(:@dbrToken)
        unless token
          st = DBRejuvenating.state
          st[:battle_counter] += 1
          token = st[:battle_counter]
          battle.instance_variable_set(:@dbrToken, token)
        end
        d = data(pkmn)
        return if d[:last_battle] == token
        return if d[:pts].to_i >= MAX_KO_POINTS || points(pkmn) >= MAX_POINTS
        d[:last_battle] = token
        d[:pts] = d[:pts].to_i + 1
      end

      def self.addSpecial(pkmn, reason = "")
        return unless pkmn && DBRejuvenating.bondable?(pkmn)
        d = data(pkmn)
        d[:special] = d[:special].to_i + 1
        DBRejuvenating.log("Lien : point spécial pour #{pkmn.species} (#{reason})")
        refresh(pkmn)
      end

      # ---------------------------------------------------------------------
      # Cérémonie du lien (au premier moment sûr, voir module 9 / pas du joueur)
      # ---------------------------------------------------------------------
      # File : [pid, :devoted] ou [pid, :bonded] (un simple pid = ancien format, :bonded)
      def self.queueCeremony(pkmn, kind = :bonded)
        st = DBRejuvenating.state
        return unless st
        d = data(pkmn)
        return if kind == :bonded && d[:ceremony_done]
        return if kind == :devoted && d[:ceremony_devoted]
        return if kind == :move && d[:bond_move_done]
        entry = [pkmn.personalID, kind]
        st[:ceremony_queue].push(entry) unless st[:ceremony_queue].include?(entry)
      end

      def self.findByPID(pid)
        found = nil
        DBRejuvenating.eachOwnedPokemon { |p| found ||= p if p.personalID == pid }
        return found
      end

      STAT_NAMES = ["HP", "Attack", "Defense", "Sp. Atk", "Sp. Def", "Speed"] unless const_defined?(:STAT_NAMES, false)

      # Données des natures du jeu ($cache.natures, Cache.rb)
      def self.natureList
        return ($cache.natures.keys rescue []) 
      end

      def self.natureLabel(sym)
        data = ($cache.natures[sym] rescue nil)
        name = (data.name rescue nil) || sym.to_s.capitalize
        inc = (data.incStat rescue nil)
        dec = (data.decStat rescue nil)
        return _INTL("{1} (no stat change)", name) if inc.nil? || dec.nil? || inc == dec
        return _INTL("{1} (+{2} / -{3})", name, STAT_NAMES[inc], STAT_NAMES[dec])
      end

      def self.runPendingCeremonies
        st = DBRejuvenating.state
        return unless st && !st[:ceremony_queue].empty?
        entry = st[:ceremony_queue].shift
        pid, kind = entry.is_a?(Array) ? entry : [entry, :bonded]
        pkmn = findByPID(pid)
        return unless pkmn
        case kind
        when :devoted then devotedCeremony(pkmn)
        when :move    then bondMoveLesson(pkmn)
        else               ceremony(pkmn)
        end
      end

      # Floette Éternelle (palier Confiant) : leçon de Light of Ruin
      def self.bondMoveLesson(pkmn)
        d = data(pkmn)
        return if d[:bond_move_done]
        if (pkmn.knowsMove?(:LIGHTOFRUIN) rescue false)
          d[:bond_move_done] = true
          return
        end
        Kernel.pbMessage(_INTL("{1} trusts you now.\nIt wants to learn its signature move, Light of Ruin!", pkmn.name))
        learned = (pbTryLearnMove(pkmn, :LIGHTOFRUIN) rescue false)
        if learned || (pkmn.knowsMove?(:LIGHTOFRUIN) rescue false)
          d[:bond_move_done] = true
          DBRejuvenating.log("Floette : Light of Ruin apprise")
        else
          d[:bond_move_refused] = DBRejuvenating.numBadges
          Kernel.pbMessage(_INTL("{1} did not learn Light of Ruin.\nIt will offer again after your next badge.", pkmn.name))
        end
      end

      # Palier Dévoué : changement de nature
      def self.devotedCeremony(pkmn)
        d = data(pkmn)
        return if d[:ceremony_devoted]
        d[:ceremony_devoted] = true
        name = pkmn.name
        Kernel.pbMessage(_INTL("\\se[itemlevel]{1} is now Devoted to you!", name))
        Kernel.pbMessage(_INTL("A legendary Pokémon lives by its own will and pride... yet {1} has chosen to follow you, the trainer who fought beside it and earned its trust.", name))
        natureChoice(pkmn)
        DBRejuvenating.log("Cérémonie Dévoué : #{pkmn.species}")
      end

      def self.natureChoice(pkmn)
        name = pkmn.name
        # --- Nature ---
        Kernel.pbMessage(_INTL("Through all the training you did together, {1}'s nature and behavior may have changed.", name))
        current = pkmn.nature
        if Kernel.pbConfirmMessage(_INTL("{1} is currently {2}. Let it take a new nature?", name, natureLabel(current)))
          natures = natureList
          labels = natures.map { |n| natureLabel(n) }
          cmd = DBRejuvenating.chooseFromList(_INTL("Which nature fits {1} now?\n(+ = stat raised, - = stat lowered)", name), labels)
          if cmd >= 0 && natures[cmd] != current
            pkmn.setNature(natures[cmd])
            pkmn.calcStats
            Kernel.pbMessage(_INTL("{1}'s nature became {2}!", name, natureLabel(natures[cmd])))
          else
            Kernel.pbMessage(_INTL("{1} kept its nature.", name))
          end
        end
      end

      # Palier Lié : talent, coût -1, marque permanente
      def self.ceremony(pkmn)
        d = data(pkmn)
        return if d[:ceremony_done]
        # La nature d'abord, si le palier Dévoué a été sauté
        devotedCeremony(pkmn) unless d[:ceremony_devoted]
        d[:ceremony_done] = true
        name = pkmn.name
        Kernel.pbMessage(_INTL("\\se[itemlevel]Congratulations, {1}!", $Trainer.name))
        Kernel.pbMessage(_INTL("You and {1} have formed a true bond.", name))
        # --- Talent ---
        abils = (pkmn.getAbilityList rescue []).compact.uniq
        if abils.length > 1
          Kernel.pbMessage(_INTL("It seems {1} has also learned to use a new ability.", name))
          labels = abils.map { |a| (getAbilityName(a) rescue a.to_s) + (a == pkmn.ability ? _INTL(" (current)") : "") }
          cmd = DBRejuvenating.chooseFromList(_INTL("Which ability should {1} use?", name), labels)
          if cmd >= 0 && abils[cmd] != pkmn.ability
            pkmn.setAbility(abils[cmd])
            Kernel.pbMessage(_INTL("{1}'s ability is now {2}!", name, (getAbilityName(abils[cmd]) rescue abils[cmd].to_s)))
          else
            Kernel.pbMessage(_INTL("{1} kept its ability.", name))
          end
        end
        # --- Marque permanente ---
        d[:bonded_with] = $Trainer.name
        pkmn.obtainText = _INTL("Bonded with {1}", $Trainer.name) if DBRejuvenating.patchGift?(pkmn)
        pkmn.instance_variable_set(:@dbrGift, true) if DBRejuvenating.patchGift?(pkmn)
        Kernel.pbMessage(DBRejuvenating.teamCost(pkmn) < DBRejuvenating.baseCost(pkmn) ? _INTL("{1} is now Bonded with you.\nIt now costs 1 point less in your team budget.", name) : _INTL("{1} is now Bonded with you.", name))
        DBRejuvenating.log("Cérémonie du lien : #{pkmn.species}")
      end

      # ---------------------------------------------------------------------
      # Budget d'équipe
      # ---------------------------------------------------------------------
      def self.teamUsage
        used = 0
        over = []
        ($Trainer.party rescue []).each do |p|
          next unless p
          c = DBRejuvenating.teamCost(p)
          next if c <= 0
          if used + c > DBRejuvenating.teamBudget
            over.push(p)
          end
          used += c
        end
        return [used, over]
      end

      # Mode d'obéissance d'un Pokémon du joueur dans CE combat
      def self.obedienceMode(pkmn, battle)
        return nil unless pkmn && DBRejuvenating.patchGift?(pkmn)
        over = battle.instance_variable_get(:@dbrOver)
        if over.nil?
          over = DBRejuvenating.enabled?(:team_budget) && DBRejuvenating.enabled?(:over_budget_disobey) ? teamUsage[1].map { |p| p.personalID } : []
          battle.instance_variable_set(:@dbrOver, over)
        end
        return :over if over.include?(pkmn.personalID)
        return :wild if tier(pkmn) == 0 && !DBRejuvenating.eternalFloette?(pkmn)
        return nil
      end

      # ---------------------------------------------------------------------
      # Soins adverses (mode Normal)
      # ---------------------------------------------------------------------
      def self.healItemFor(cap)
        return :SUPERPOTION if cap <= 30
        return :HYPERPOTION if cap <= 50
        return :MAXPOTION if cap <= 70
        return :FULLRESTORE
      end

      def self.enemyItemsActive?
        return false unless DBRejuvenating.enabled?(:enemy_items)
        return false unless DBRejuvenating.difficulty == 0
        return false if ($game_switches[:No_Items_Password] rescue false)
        return false if ($game_switches[:NotPlayerCharacter] rescue false)
        return false if $PokemonTemp && $PokemonTemp.instance_variable_get(:@dbrInTrial)
        return true
      end

      # -------------------------------------------------------------------
      # Kit des chefs (mode Normal) : Champions d'Arène, Conseil, Ligue
      # -------------------------------------------------------------------
      HEAL_ITEMS = [:POTION, :SUPERPOTION, :HYPERPOTION, :MAXPOTION, :FULLRESTORE, :FRESHWATER,
                    :SODAPOP, :LEMONADE, :MOOMOOMILK, :ENERGYPOWDER, :ENERGYROOT, :BERRYJUICE] unless const_defined?(:HEAL_ITEMS, false)

      def self.bossType?(type)
        return type.to_s =~ /\A(LEADER_|ELITE|CHAMPION|JOHTO_(9|1[0-3])\z)/ ? true : false
      end

      def self.bossKitActive?
        return false unless DBRejuvenating.enabled?(:boss_kit)
        return false if DBRejuvenating.storyMode?
        return false if ($game_switches[:No_Items_Password] rescue false)
        return false if ($game_switches[:NotPlayerCharacter] rescue false)
        return false if $PokemonTemp && $PokemonTemp.instance_variable_get(:@dbrInTrial)
        return true
      end

      # Objets X adaptés à l'équipe : Vitesse + Attaque ou Attaque Spéciale
      def self.xItemsFor(party)
        atk = party.compact.sum { |p| (p.attack rescue 0).to_i }
        spa = party.compact.sum { |p| (p.spatk rescue 0).to_i }
        return [:XSPEED, atk >= spa ? :XATTACK : :XSPECIAL]
      end

      # v1.3.1 : plafonds anti-abus (jamais de "spam" d'objets). Le jeu (Battle_AI.rb)
      # choisit lui-même QUAND utiliser un objet : soin si utile, Total Soin seulement
      # s'il a un statut, objet X seulement si la stat sert. Aucune IA modifiée.
      BONUS_CAP = 3 unless const_defined?(:BONUS_CAP, false)   # objets ajoutés à un dresseur normal
      BOSS_CAP  = 5 unless const_defined?(:BOSS_CAP, false)    # objets ajoutés à un chef, au total

      def self.itemOk?(i)
        return ($cache.items.key?(i) rescue false)
      end

      # À partir de 15 badges (adversaires entraînés à 54-89 %), les chefs utilisent
      # les versions "3" du jeu (+3 niveaux) quand elles existent
      def self.bossX(sym)
        strong = { :XSPEED => :XSPEED3, :XATTACK => :XATTACK3, :XSPECIAL => :XSPECIAL3 }
        return sym unless DBRejuvenating.numBadges >= 15 && strong[sym] && itemOk?(strong[sym])
        return strong[sym]
      end

      def self.bossKit(type, items, party)
        return [] unless bossKitActive? && bossType?(type)
        return [] if (items || []).any? { |i| HEAL_ITEMS.include?(i) }   # le jeu lui en donne déjà
        heal = healItemFor(DBRejuvenating.levelCap)
        kit = [heal, heal, :FULLHEAL] + xItemsFor(party || []).map { |x| bossX(x) }
        return kit.select { |i| itemOk?(i) }
      end

      # Menace de VOTRE équipe : coût d'origine des légendaires du mod, +1 pour chaque
      # légendaire de 600+ de stats utilisé avant 12 badges (le jeu n'en donne pas
      # avant ~12 badges : Diancie, Genesect). Aucune limite pour le joueur.
      def self.earlyPower?(p)
        return false unless p && DBRejuvenating.patchGift?(p)
        return false if DBRejuvenating.numBadges >= 12
        return ((p.baseStats rescue []) || []).sum >= 600
      end

      def self.threat
        party = ($Trainer.party rescue []).compact
        return party.sum { |p| DBRejuvenating.baseCost(p) } + party.count { |p| earlyPower?(p) }
      end

      # Objet X défensif adapté à VOS légendaires : Défense contre le physique,
      # Défense Spéciale contre le spécial
      def self.defenseXFor
        legs = ($Trainer.party rescue []).compact.select { |p| DBRejuvenating.patchGift?(p) }
        atk = legs.sum { |p| (p.attack rescue 0).to_i }
        spa = legs.sum { |p| (p.spatk rescue 0).to_i }
        return atk >= spa ? :XDEFEND : :XSPDEF
      end

      def self.bonusItems
        return [] unless enemyItemsActive?
        t = threat
        return [] if t <= 0
        # Objets variés, pas seulement des potions : soin, Total Soin, X défensif, ...
        rotation = [healItemFor(DBRejuvenating.levelCap), :FULLHEAL, defenseXFor].select { |i| itemOk?(i) }
        return [] if rotation.empty?
        n = [(t + 1) / 2, BONUS_CAP].min
        return Array.new(n) { |i| rotation[i % rotation.length] }
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Crédit du K.O. (PokeBattle_Battler#pbFaint, Battler.rb)
  # ---------------------------------------------------------------------------
  class PokeBattle_Battler
    unless method_defined?(:dbRejuvenating_orig_pbFaint)
      alias_method :dbRejuvenating_orig_pbFaint, :pbFaint
    end

    def pbFaint(*args)
      ret = dbRejuvenating_orig_pbFaint(*args)
      begin
        if ret == true && !@dbrKOCredited && self.isFainted? && @battle.opponent &&
           @battle.internalbattle && !@battle.pbOwnedByPlayer?(@index)
          @dbrKOCredited = true
          idx = self.lastAttacker
          if idx.is_a?(Integer) && idx >= 0 && @battle.battlers[idx] && @battle.pbOwnedByPlayer?(idx)
            DBRejuvenating::Bond.creditKO(@battle.battlers[idx].pokemon, @battle)
          end
        end
      rescue StandardError => e
        DBRejuvenating.log("ERREUR crédit K.O. : #{e.message}")
      end
      return ret
    end

    # -------------------------------------------------------------------------
    # Obéissance : palier Sauvage (%) et dépassement du budget (Battler.rb:5122)
    # -------------------------------------------------------------------------
    unless method_defined?(:dbRejuvenating_orig_pbObedienceCheck?)
      alias_method :dbRejuvenating_orig_pbObedienceCheck?, :pbObedienceCheck?
    end

    def pbObedienceCheck?(choice)
      mode = nil
      begin
        if @battle.internalbattle && @battle.pbOwnedByPlayer?(@index) && !($game_switches[:NotPlayerCharacter] rescue false)
          mode = DBRejuvenating::Bond.obedienceMode(self.pokemon, @battle)
          mode = nil if mode == :wild && @battle.pbRandom(100) >= DBRejuvenating.cfg(:wild_disobey_percent).to_i
        end
      rescue StandardError => e
        DBRejuvenating.log("ERREUR obéissance : #{e.message}")
        mode = nil
      end
      return dbRejuvenating_orig_pbObedienceCheck?(choice) unless mode
      # Force la désobéissance du jeu (même messages : "is loafing around!", etc.)
      oldPerm = self.permeffs[:Disobedient]
      oldFlag = self.pokemon.disobedient
      begin
        self.permeffs[:Disobedient] = true
        self.pokemon.disobedient = true
        return dbRejuvenating_orig_pbObedienceCheck?(choice)
      ensure
        self.permeffs[:Disobedient] = oldPerm
        self.pokemon.disobedient = oldFlag
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Soins adverses : chargement de l'équipe adverse (Trainers.rb, pbTrainerBattle)
  # et vérifications à chaque pas (badge obtenu ? cérémonies au moment sûr ?)
  # ---------------------------------------------------------------------------
  module DBRejuvenating
    module Bond
      def self.onTrainerPartyLoad(e)
        trainer = e.is_a?(Array) && e[0].is_a?(Array) ? e[0] : e
        return unless trainer.is_a?(Array) && trainer.length >= 3
        type = (trainer[0].trainertype rescue nil)
        kit = bossKit(type, trainer[1], trainer[2])
        extra = kit + bonusItems
        extra = extra.first(bossType?(type) ? BOSS_CAP : BONUS_CAP)
        trainer[1] = (trainer[1] || []).dup + extra unless extra.empty?
      rescue StandardError => ex
        DBRejuvenating.log("ERREUR soins adverses : #{ex.message}")
      end

      def self.onStep
        DBRejuvenating::BattleLog.checkBadge(true) if defined?(DBRejuvenating::BattleLog)
        $dbrStepCount = ($dbrStepCount || 0) + 1
        refreshParty if $dbrStepCount % 32 == 0
        ok, = DBRejuvenating.safeState
        runPendingCeremonies if ok && !($game_temp.in_battle rescue false)
      rescue StandardError => ex
        DBRejuvenating.log("ERREUR pas (lien) : #{ex.message}")
      end
    end
  end

  unless $dbrBondHooked
    Events.onTrainerPartyLoad += proc { |sender, e| DBRejuvenating::Bond.onTrainerPartyLoad(e) }
    Events.onStepTaken += proc { |sender, e| DBRejuvenating::Bond.onStep }
    $dbrBondHooked = true
  end
end
