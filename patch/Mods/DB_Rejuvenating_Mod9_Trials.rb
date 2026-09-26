# =============================================================================
# DB's Rejuvenating Settings — MODULE 9 : Épreuves
#
# A) ÉPREUVE DU GARDIEN (légendaires "Restreints", une par Pokémon)
#    Combat contre le "Guardian Spectre" (type :GAUNTLET, sprite du jeu) qui
#    aligne le légendaire et une équipe de stratégie réelle (fichier
#    DB_Rejuvenating_Data_Guardians.rb, sources citées). Tous au plafond de
#    niveau actuel : difficulté = qualité de l'équipe, pas de bonus de stats.
#    Interdit : amener un cadeau légendaire du patch. Défaite = aucune perte
#    (équipe soignée, on peut réessayer). Pas d'EXP. Indisponible en mode Story.
#
# B) ÉPREUVE DU MIROIR (chaque nouveau chapitre à partir du 2)
#    Au premier moment sûr après le changement de chapitre (aucun événement en
#    cours, sauvegarde autorisée) : proposition de sauvegarder, puis de lancer
#    l'épreuve. UNE SEULE chance par chapitre et par partie : le choix est
#    enregistré dans la sauvegarde ET dans un fichier à part
#    (DB_Rejuvenating_trials.dat, dossier des sauvegardes), puis la partie est
#    sauvegardée automatiquement. Recharger une ancienne sauvegarde ne rend pas
#    l'épreuve : le fichier à part la marque déjà comme utilisée.
#    Adversaire : votre double (sprite assombri), avec VOTRE équipe copiée,
#    +10 % d'EXP (sans évolution ni nouvelle attaque) et des objets améliorés.
#    Victoire = 1 ticket. Indisponible en mode Story.
# =============================================================================

if defined?(DBRejuvenating)
  module DBRejuvenating
    module Trials
      MIRROR_BASE_ID = 9100 unless const_defined?(:MIRROR_BASE_ID, false)

      # -----------------------------------------------------------------------
      # Types de dresseur "Miroir" (sprites assombris du joueur, patch/Graphics)
      # -----------------------------------------------------------------------
      def self.mirrorType
        type = ($Trainer.trainertype rescue nil)
        id = (($cache.trainertypes[type].checkFlag?(:ID)) rescue nil).to_i
        sym = "DBR_MIRROR_#{id}".to_sym
        return sym if ($cache.trainertypes.key?(sym) rescue false)
        return :UNKNOWN_1
      end

      def self.injectTrainerTypes
        return unless $cache && $cache.trainertypes
        (1..7).each do |id|
          sym = "DBR_MIRROR_#{id}".to_sym
          next if $cache.trainertypes.key?(sym)
          $cache.trainertypes[sym] = TrainerData.new(sym, {
            :ID => MIRROR_BASE_ID + id, :title => "Mirror", :skill => 100, :moneymult => 0,
            :battleBGM => "Battle - Mysterious Figures.mp3",
          })
        end
      rescue StandardError => e
        DBRejuvenating.log("ERREUR types Miroir : #{e.message}")
      end

      # -----------------------------------------------------------------------
      # Outils communs
      # -----------------------------------------------------------------------
      def self.available?
        return false if DBRejuvenating.storyMode?
        ok, reason = DBRejuvenating.safeState
        unless ok
          Kernel.pbMessage(reason)
          return false
        end
        return true
      end

      def self.giftLegendsInParty
        return ($Trainer.party rescue []).compact.select { |p| DBRejuvenating.patchGift?(p) && DBRejuvenating.baseCost(p) > 0 }
      end

      def self.battle(type, name, team, items, endspeech, double = false)
        opp = PokeBattle_Trainer.new(name, type)
        opp.setForeignID($Trainer) rescue nil
        $PokemonTemp.instance_variable_set(:@dbrInTrial, true)
        begin
          ret = pbTrainerBattle(type, name, endspeech, double, 0, true,
                                opponent_overwrite: [opp, items, team], noexp: true)
        ensure
          $PokemonTemp.instance_variable_set(:@dbrInTrial, false)
        end
        return ret == true
      end

      def self.healParty
        ($Trainer.party rescue []).each { |p| p.heal if p && !(p.isEgg? rescue false) }
      end

      def self.needsRing?(party)
        return party.any? do |p|
          # Méga-Rayquaza : pas de gemme, mais Dragon Ascent + anneau
          next true if p.species == :RAYQUAZA && p.moves.any? { |m| m && m.move == :DRAGONASCENT }
          it = p.item
          next false unless it
          (pbIsMegaStone?(it) rescue false) || (pbIsZCrystal?(it) rescue false) || it.to_s.end_with?("IUMZ")
        end
      end

      # -----------------------------------------------------------------------
      # A) Gardien
      # -----------------------------------------------------------------------
      # Objet absent de Rejuvenation V14 : équivalent proche, sinon baie de soin
      ITEM_SUBSTITUTES = {
        :ELECTRICSEED => :ELEMENTALSEED, :GRASSYSEED => :ELEMENTALSEED,
        :MISTYSEED => :MAGICALSEED, :PSYCHICSEED => :MAGICALSEED,
        :CLEARAMULET => :WHITEHERB, :COVERTCLOAK => :SAFETYGOGGLES,
        :FAIRYFEATHER => :PIXIEPLATE, :PUNCHINGGLOVE => :MUSCLEBAND,
        :MIRRORHERB => :WHITEHERB, :ABILITYSHIELD => :LUMBERRY,
      } unless const_defined?(:ITEM_SUBSTITUTES, false)

      def self.itemOrSubstitute(item)
        return nil if item.nil?
        return item if ($cache.items.key?(item) rescue false)
        sub = ITEM_SUBSTITUTES[item]
        sub = :SITRUSBERRY unless sub && ($cache.items.key?(sub) rescue false)
        DBRejuvenating.log("Objet #{item} absent : remplacé par #{sub}")
        return sub
      end

      def self.guardianTeam(species)
        data = (DBRejuvenating::GUARDIAN_TEAMS[species] rescue nil)
        return nil unless data && data[:team].is_a?(Array) && !data[:team].empty?
        level = DBRejuvenating.levelCap
        hashes = data[:team].select { |h| ($cache.pkmn.key?(h[:species]) rescue false) }.map do |h|
          x = h.dup
          # Garde-fous : aucun objet/attaque/talent inconnu ne doit faire planter le jeu
          x[:item] = itemOrSubstitute(x[:item])
          x[:moves] = (x[:moves] || []).select { |m| ($cache.moves.key?(m) rescue false) }
          x.delete(:ability) unless ($cache.abil.key?(x[:ability]) rescue false)
          x[:level] = level
          x[:iv] ||= 31
          x
        end
        opp = PokeBattle_Trainer.new("Guardian", :GAUNTLET)
        party = getTrainerPartyFromTrainerHash(hashes, opp, :GAUNTLET, source: :trainer)
        party.each { |p| p.calcStats; p.hp = p.totalhp }
        return [party, data]
      end

      def self.guardianPrompt(species)
        return Kernel.pbMessage(_INTL("Guardian Trials are turned off in the mod settings (CONFIG in DB_Rejuvenating_Core.rb).")) unless DBRejuvenating.enabled?(:guardian_trials)
        if DBRejuvenating.storyMode?
          return Kernel.pbMessage(_INTL("Guardian Trials are not available in Story mode."))
        end
        return unless available?
        name = DBRejuvenating.monName(species)
        built = guardianTeam(species)
        unless built
          Kernel.pbMessage(_INTL("There is no Guardian team for {1} yet.\n(Teams are listed in DB_Rejuvenating_Data_Guardians.rb.)", name))
          return
        end
        party, data = built
        Kernel.pbMessage(_INTL("A Guardian Spectre watches over {1}.\nTo earn the right to claim it, defeat the Guardian's team.", name))
        Kernel.pbMessage(_INTL("Rules:\n- 6 opponents at level {1} (your level cap), a real competitive team ({2}).\n- You cannot bring legendaries received from this mod.\n- Losing costs nothing: you can retry as often as you want.\n- No EXP is gained.", DBRejuvenating.levelCap, data[:source].to_s))
        blocked = giftLegendsInParty
        unless blocked.empty?
          Kernel.pbMessage(_INTL("Put these Pokémon in the PC first (legendaries from this mod are not allowed):\n{1}", blocked.map { |p| p.name }.join(", ")))
          return
        end
        return unless Kernel.pbConfirmMessage(_INTL("Face the Guardian of {1} now?", name))
        items = needsRing?(party) ? [:MEGARING] : []
        won = battle(:GAUNTLET, _INTL("of {1}", name), team_copy(party), items, _INTL("...You have proven yourself worthy."))
        healParty
        if won
          DBRejuvenating.state[:trials_won][species] = true
          DBRejuvenating.log("Épreuve du Gardien réussie : #{species}")
          Kernel.pbMessage(_INTL("The Guardian bows.\nYou can now claim {1} with 1 ticket in Pokémon > Legendary unlocks.", name))
        else
          Kernel.pbMessage(_INTL("The Guardian remains.\nTrain, rethink your team and try again whenever you want."))
        end
      end

      def self.team_copy(party)
        return party.map { |p| Marshal.load(Marshal.dump(p)) }
      end

      # -----------------------------------------------------------------------
      # B) Miroir (chapitres)
      # -----------------------------------------------------------------------
      MARKER_FILE = "DB_Rejuvenating_trials.dat" unless const_defined?(:MARKER_FILE, false)

      def self.markerPath
        return (RTP.getSaveFileName(MARKER_FILE) rescue MARKER_FILE)
      end

      def self.readMarker
        begin
          return {} unless File.exist?(markerPath)
          data = File.open(markerPath, "rb") { |f| Marshal.load(f) }
          return data.is_a?(Hash) ? data : {}
        rescue StandardError
          return {}
        end
      end

      def self.writeMarker(chapter, result)
        data = readMarker
        uid = DBRejuvenating.state[:save_uid]
        data[uid] ||= {}
        data[uid][chapter] = result
        File.open(markerPath, "wb") { |f| Marshal.dump(data, f) }
      rescue StandardError => e
        DBRejuvenating.log("ERREUR fichier des épreuves : #{e.message}")
      end

      # Le fichier à part a priorité : une épreuve déjà utilisée le reste
      def self.syncMarker(force = false)
        st = DBRejuvenating.state
        return unless st
        # Lecture du fichier une seule fois par partie chargée (pas à chaque pas)
        return if !force && $dbrMarkerSyncedFor.equal?($PokemonGlobal)
        $dbrMarkerSyncedFor = $PokemonGlobal
        rec = readMarker[st[:save_uid]]
        return unless rec.is_a?(Hash)
        # Épreuve ultime : le fichier à part fait foi (victoires, échec, Pokémon déjà engagés)
        u = rec[:ultimate]
        if u.is_a?(Hash)
          st[:ultimate_wins] = [st[:ultimate_wins].to_i, u[:wins].to_i].max
          st[:ultimate_failed] = true if u[:failed] || u[:in_progress]   # jeu fermé pendant l'épreuve = échec
          st[:ultimate_used] = ((st[:ultimate_used] || []) | (u[:used] || []))
        end
        rec.each do |ch, res|
          next unless ch.is_a?(Integer)
          res = :lost if res == :started   # jeu fermé pendant l'épreuve = échec
          st[:chapter_trials][ch] = res if st[:chapter_trials][ch].nil? || (res == :won && st[:chapter_trials][ch] != :won)
        end
      end

      # Détection du changement de chapitre (appelée à chaque pas)
      def self.checkChapter
        return unless DBRejuvenating.enabled?(:chapter_trials)
        st = DBRejuvenating.state
        return unless st
        ch = DBRejuvenating.chapter
        if st[:last_chapter].nil?
          # Première exécution : pas d'épreuve rétroactive pour les chapitres passés
          st[:last_chapter] = ch
          return
        end
        if ch > st[:last_chapter].to_i
          ((st[:last_chapter].to_i + 1)..ch).each do |n|
            next if n < 2
            st[:chapter_trials][n] ||= :pending
          end
          st[:from_chapter] = st[:last_chapter]
          st[:last_chapter] = ch
        end
      end

      def self.pendingChapter
        st = DBRejuvenating.state
        return nil unless st
        pend = st[:chapter_trials].select { |_, v| v == :pending }.keys.sort
        return pend.last
      end

      # Moment sûr ? (pas d'événement, sauvegarde autorisée, pas en déplacement forcé)
      def self.safeMoment?
        ok, = DBRejuvenating.safeState
        return false unless ok
        return false if ($game_temp.in_battle rescue true)
        return false if ($game_temp.player_transferring rescue false)
        return false if ($game_system.save_disabled rescue false)
        return false if ($game_player.move_route_forcing rescue false)
        return true
      end

      def self.offerChapterTrial
        return unless DBRejuvenating.enabled?(:chapter_trials)
        ch = pendingChapter
        return unless ch
        st = DBRejuvenating.state
        if DBRejuvenating.storyMode?
          # Mode Story : pas d'épreuve ; on la marque "indisponible" une fois pour toutes
          st[:chapter_trials].each_key { |k| st[:chapter_trials][k] = :story if st[:chapter_trials][k] == :pending }
          return
        end
        return unless safeMoment?
        # Si plusieurs chapitres ont été sautés d'un coup, seuls les plus anciens sont perdus
        st[:chapter_trials].each_key { |k| st[:chapter_trials][k] = :missed if st[:chapter_trials][k] == :pending && k != ch }
        from = DBRejuvenating.chapterName(ch - 1)
        to = DBRejuvenating.chapterName(ch)
        if Kernel.pbConfirmMessage(_INTL("A new chapter begins!\nDo you want to save your game first?"))
          pbSaveScreen(cancancel: true) rescue (pbSave rescue nil)
        end
        Kernel.pbMessage(_INTL("You moved from\n\"{1}\"\nto\n\"{2}\".", from, to))
        Kernel.pbMessage(_INTL("A Chapter Trial is available!\nYou fight your own reflection: a copy of your current team.\nWinning gives you 1 ticket (tickets are spent to claim legendaries)."))
        Kernel.pbMessage(_INTL("WARNING: this trial is offered only ONCE for this save file.\nWhatever you choose (fight or decline) is recorded for good, and the game saves automatically right after.\nReloading an older save will not bring it back."))
        start = Kernel.pbConfirmMessage(_INTL("Start the Chapter Trial now?"))
        unless start
          st[:chapter_trials][ch] = :declined
          writeMarker(ch, :declined)
          autosave
          Kernel.pbMessage(_INTL("You declined the trial of {1}.\nIt will not be offered again.", to))
          return
        end
        st[:chapter_trials][ch] = :started
        writeMarker(ch, :started)
        healParty
        team = mirrorTeam
        items = needsRing?(team) ? [:MEGARING] : []
        won = battle(mirrorType, $Trainer.name, team, items, _INTL("...So this is what I look like from the other side."))
        result = won ? :won : :lost
        st[:chapter_trials][ch] = result
        writeMarker(ch, result)
        healParty
        if won
          Kernel.pbMessage(_INTL("You overcame your reflection!\nYou earned 1 ticket."))
        else
          Kernel.pbMessage(_INTL("Your reflection won.\nThis chapter's trial is over (no ticket)."))
        end
        autosave
      end

      def self.autosave
        return unless DBRejuvenating.enabled?(:chapter_trial_autosave)
        begin
          pbSave
          DBRejuvenating.log("Sauvegarde automatique après l'épreuve de chapitre")
        rescue StandardError => e
          DBRejuvenating.log("ERREUR sauvegarde auto : #{e.message}")
        end
      end

      # --- Équipe du Miroir ---
      ITEM_UPGRADES = {
        :ORANBERRY => :SITRUSBERRY, :BERRYJUICE => :SITRUSBERRY,
        :CHERIBERRY => :LUMBERRY, :CHESTOBERRY => :LUMBERRY, :PECHABERRY => :LUMBERRY,
        :RAWSTBERRY => :LUMBERRY, :ASPEARBERRY => :LUMBERRY, :PERSIMBERRY => :LUMBERRY,
        :SHELLBELL => :LEFTOVERS, :EXPERTBELT => :LIFEORB,
        :MUSCLEBAND => :LIFEORB, :WISEGLASSES => :LIFEORB,
      } unless const_defined?(:ITEM_UPGRADES, false)

      USELESS_ITEMS = [
        :EVERSTONE, :EXPSHARE, :LUCKYEGG, :AMULETCOIN, :SOOTHEBELL, :SMOKEBALL, :CLEANSETAG,
        :MACHOBRACE, :POWERBRACER, :POWERBELT, :POWERLENS, :POWERBAND, :POWERANKLET, :POWERWEIGHT,
        :FIRESTONE, :WATERSTONE, :THUNDERSTONE, :LEAFSTONE, :MOONSTONE, :SUNSTONE, :SHINYSTONE,
        :DUSKSTONE, :DAWNSTONE, :ICESTONE, :OVALSTONE, :LINKINGCORD,
      ] unless const_defined?(:USELESS_ITEMS, false)

      def self.bestItemFor(p)
        stones = (p.getCacheData.MegaEvolutions.keys rescue []).select { |s| ($cache.items.key?(s) rescue false) }
        return stones[0] if stones[0]
        return :SITRUSBERRY
      end

      def self.mirrorTeam
        team = ($Trainer.party rescue []).compact.reject { |p| (p.isEgg? rescue false) }.map { |p| Marshal.load(Marshal.dump(p)) }
        team.each do |p|
          growth = p.growthrate
          maxexp = (PBExp.maxExperience(growth) rescue p.exp)
          p.exp = [(p.exp * 1.1).floor, maxexp].min
          p.level = PBExp.levelFromExperience(p.exp, growth)      # aucune évolution, aucune attaque apprise
          it = p.item
          if it && ITEM_UPGRADES[it] && ($cache.items.key?(ITEM_UPGRADES[it]) rescue false)
            p.setItem(ITEM_UPGRADES[it])
          elsif it.nil? || USELESS_ITEMS.include?(it)
            p.setItem(bestItemFor(p))
          end
          p.instance_variable_set(:@dbrBond, nil)
          p.instance_variable_set(:@dbrGift, nil)
          p.calcStats
          p.heal
        end
        return team
      end
    end
  end

  # ---------------------------------------------------------------------------
  # C) ÉPREUVE ULTIME (fin de jeu)
  #    Débloquée quand : les 15 épreuves de chapitre (2 à 16) ont été RÉUSSIES,
  #    les 18 badges sont obtenus et le champion de la Virtual League est battu.
  #    3 manches contre votre reflet (équipe copiée, +10 % d'EXP) qui utilise
  #    des objets de soin et des objets X :
  #      1) 1 contre 1 (combat simple, 1 Pokémon chacun, aucun remplaçant)
  #      2) 2 contre 2 (combat double, 2 Pokémon chacun, aucun remplaçant)
  #      3) 3 contre 3 (Rejuvenation n'a pas de combat triple : combat simple
  #         avec 3 Pokémon chacun)
  #    Toutes les manches à la suite. Chaque Pokémon (identifiant unique
  #    personalID) ne combat que dans UNE manche et, une fois engagé, ne peut
  #    plus JAMAIS revenir dans l'épreuve ultime (6 nouveaux Pokémon à chaque
  #    tentative ; le reflet suit la même règle). Rejouable tant qu'on gagne :
  #    1 ticket par victoire. La première défaite (ou quitter après le 1er
  #    combat, ou fermer le jeu) ferme l'épreuve pour cette partie, noté aussi
  #    dans le fichier à part + sauvegarde auto. Indisponible en mode Story.
  # ---------------------------------------------------------------------------
  module DBRejuvenating
    module Trials
      ROUNDS = [[1, false, "1 vs 1"], [2, true, "2 vs 2 (double battle)"], [3, false, "3 vs 3"]] unless const_defined?(:ROUNDS, false)

      def self.ultimateRequirements
        st = DBRejuvenating.state
        chapters = (2..16).all? { |c| st[:chapter_trials][c] == :won }
        badges = DBRejuvenating.numBadges >= ((BADGECOUNT rescue 18) || 18)
        league = st[:league_won] == true
        return [chapters, badges, league]
      end

      def self.ultimateUnlocked?
        return false unless DBRejuvenating.enabled?(:ultimate_trial)
        return ultimateRequirements.all?
      end

      def self.ultimateKit
        heal = DBRejuvenating::Bond.healItemFor(DBRejuvenating.levelCap) rescue :FULLRESTORE
        kit = [heal, heal, :XSPEED, :XATTACK, :XSPECIAL]
        return kit.select { |i| ($cache.items.key?(i) rescue false) }
      end

      # Le reflet choisit ses N Pokémon les plus forts (niveau, puis total des stats)
      def self.strongest(team, n)
        return team.sort_by { |p| [-p.level, -(p.totalhp + p.attack + p.defense + p.spatk + p.spdef + p.speed)] }.first(n)
      end

      def self.eligible
        return ($Trainer.party rescue []).compact.reject { |p| (p.isEgg? rescue false) }
      end

      # Le joueur choisit N Pokémon jamais utilisés dans cette tentative
      # (identifiant unique personalID) ; nil si annulé
      def self.pickTeam(n, used = [])
        pool = eligible.reject { |p| used.include?(p.personalID) }
        return nil if pool.length < n
        chosen = []
        n.times do |k|
          left = pool - chosen
          labels = left.map { |p| _INTL("{1} Lv.{2}", p.name, p.level) }
          cmd = DBRejuvenating.chooseFromList(_INTL("Choose Pokémon {1} of {2}.", k + 1, n), labels)
          return nil if cmd < 0
          chosen.push(left[cmd])
        end
        return chosen
      end

      # Enregistre l'état de l'épreuve ultime dans la sauvegarde ET dans le fichier à part
      def self.saveUltimate(st, in_progress)
        data = readMarker
        uid = st[:save_uid]
        data[uid] ||= {}
        data[uid][:ultimate] = { :wins => st[:ultimate_wins].to_i, :failed => st[:ultimate_failed] == true,
                                 :used => (st[:ultimate_used] || []).dup, :in_progress => in_progress }
        File.open(markerPath, "wb") { |f| Marshal.dump(data, f) }
      rescue StandardError => e
        DBRejuvenating.log("ERREUR fichier des épreuves (ultime) : #{e.message}")
      end

      def self.ultimatePrompt
        st = DBRejuvenating.state
        syncMarker(true)
        st[:ultimate_wins] = DBRejuvenating.ultimateWins
        st[:ultimate_used] ||= []
        if st[:ultimate_failed]
          return Kernel.pbMessage(_INTL("You already lost the Ultimate Trial once, so it is closed for this save.\nVictories: {1}", st[:ultimate_wins]))
        end
        if DBRejuvenating.storyMode?
          return Kernel.pbMessage(_INTL("The Ultimate Trial is not available in Story mode."))
        end
        chapters, badges, league = ultimateRequirements
        unless chapters && badges && league
          Kernel.pbMessage(_INTL("The Ultimate Trial opens when:\n- every Chapter Trial (Chapters 2 to 16) was WON: {1}\n- you own all 18 badges: {2}\n- you beat the Virtual League champion: {3}",
            chapters ? _INTL("done") : _INTL("not yet"), badges ? _INTL("done") : _INTL("not yet"), league ? _INTL("done") : _INTL("not yet")))
          return
        end
        return unless available?
        Kernel.pbMessage(_INTL("Ultimate Trial: three rounds in a row against your reflection, which uses healing items and X items.\nRound 1: 1 vs 1\nRound 2: 2 vs 2 (double battle)\nRound 3: 3 vs 3"))
        Kernel.pbMessage(_INTL("You choose your Pokémon before each round, with no substitutes.\nA Pokémon fights in only ONE round, and once it has fought in the Ultimate Trial it can NEVER enter it again.\nYour reflection follows the same rule."))
        Kernel.pbMessage(_INTL("Each victory gives 1 ticket, and you may go again as long as you keep winning.\nYour first defeat closes the Ultimate Trial for good.\nVictories so far: {1}", st[:ultimate_wins]))
        needed = ROUNDS.sum { |r| r[0] }
        fresh = eligible.reject { |p| st[:ultimate_used].include?(p.personalID) }
        if fresh.map(&:personalID).uniq.length < needed
          return Kernel.pbMessage(_INTL("You need {1} Pokémon in your party that never fought in the Ultimate Trial.\nYou have {2}.", needed, fresh.length))
        end
        return unless Kernel.pbConfirmMessage(_INTL("Begin the Ultimate Trial?\nOnce the first battle starts, quitting or closing the game counts as a defeat."))
        used = st[:ultimate_used].dup   # interdits : déjà engagés (toutes tentatives)
        foeUsed = st[:ultimate_used].dup
        started = false
        ROUNDS.each_with_index do |(n, double, label), i|
          healParty
          Kernel.pbMessage(_INTL("Round {1}: {2}\nPokémon already used cannot fight again.", i + 1, label))
          chosen = pickTeam(n, used)
          unless chosen
            if started
              st[:ultimate_failed] = true
              saveUltimate(st, false)
              autosave
              Kernel.pbMessage(_INTL("You left the Ultimate Trial after it began, so it counts as a defeat.\nThe Ultimate Trial is now closed."))
            else
              Kernel.pbMessage(_INTL("You stopped before the first battle.\nNothing changed."))
            end
            return
          end
          used.concat(chosen.map(&:personalID))
          st[:ultimate_used] = (st[:ultimate_used] | chosen.map(&:personalID))   # engagés pour toujours
          foes = strongest(mirrorTeam.reject { |p| foeUsed.include?(p.personalID) }, n)
          foeUsed.concat(foes.map(&:personalID))
          started = true
          saveUltimate(st, true)         # fermer le jeu maintenant = défaite
          fullParty = $Trainer.party
          won = false
          begin
            $Trainer.party = chosen          # seuls les Pokémon choisis combattent : aucun remplaçant
            won = battle(mirrorType, $Trainer.name, foes, ultimateKit, _INTL("...Again."), double)
          ensure
            $Trainer.party = fullParty       # l'équipe complète est TOUJOURS restaurée
          end
          healParty
          unless won
            st[:ultimate_failed] = true
            saveUltimate(st, false)
            autosave
            Kernel.pbMessage(_INTL("Your reflection wins round {1}.\nThe Ultimate Trial is now closed for this save.\nVictories: {2}", i + 1, st[:ultimate_wins]))
            return
          end
        end
        st[:ultimate_wins] = st[:ultimate_wins].to_i + 1
        saveUltimate(st, false)
        autosave
        DBRejuvenating.log("Épreuve ultime réussie (#{st[:ultimate_wins]})")
        Kernel.pbMessage(_INTL("\\se[itemlevel]You conquered the Ultimate Trial!\nYou earned 1 ticket (victories: {1}).\nYou may go again with 6 other Pokémon.", st[:ultimate_wins]))
      end
    end

    # Raccourci : uniquement les légendaires Restreints (Épreuves du Gardien)
    if defined?(DBRejuvenating::SpecialPokemon) && DBRejuvenating.enabled?(:progression_pokemon)
      registerEntry(:guardian_trials, order: 10, group: :trials, name: proc { _INTL("Guardian Trials") },
        condition: proc { DBRejuvenating.enabled?(:guardian_trials) },
        effect: proc {
          sp = DBRejuvenating::SpecialPokemon
          list = sp.progressionGifts.select { |g| sp.needsTrial?(g) }
          sp.menu(list, _INTL("Guardian Trials\nWin one to be allowed to claim that legendary."))
        })
    end

    registerEntry(:ultimate_trial, order: 20, group: :trials, name: proc { _INTL("Ultimate Trial") },
      condition: proc { DBRejuvenating.enabled?(:ultimate_trial) },
      effect: proc { DBRejuvenating::Trials.ultimatePrompt })
  end

  # Types "Miroir" injectés au chargement des données (et au F12)
  class Cache_Game
    unless method_defined?(:dbRejuvenating_orig_cacheTrainerTypes)
      alias_method :dbRejuvenating_orig_cacheTrainerTypes, :cacheTrainerTypes
    end

    def cacheTrainerTypes
      ret = dbRejuvenating_orig_cacheTrainerTypes
      DBRejuvenating::Trials.injectTrainerTypes rescue nil
      return ret
    end
  end
  DBRejuvenating::Trials.injectTrainerTypes if $cache

  # Détection des chapitres et proposition au premier moment sûr
  module DBRejuvenating
    module Trials
      def self.onStep
        syncMarker
        checkChapter
        offerChapterTrial
      rescue StandardError => ex
        DBRejuvenating.log("ERREUR pas (épreuves) : #{ex.class}: #{ex.message}")
      end
    end
  end

  unless $dbrTrialStepHooked
    Events.onStepTaken += proc { |sender, e| DBRejuvenating::Trials.onStep }
    $dbrTrialStepHooked = true
  end
end
