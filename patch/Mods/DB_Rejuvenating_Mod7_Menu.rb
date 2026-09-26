# =============================================================================
# DB's Rejuvenating Settings — MODULE 7 : Entrée "DB Rejuv Settings" du menu Pause
#
# Utilise le registre officiel du jeu (MenuHandlers.rb) prévu pour les mods :
# aucun fichier de menu n'est remplacé. Placé entre "Controls" (80) et "Debug" (90).
# Le menu ne s'ouvre que depuis le menu Pause (donc jamais pendant un événement),
# et n'agit que si DBRejuvenating.safeState le permet.
#
# Organisation (v1.2.3) :
#   Guide           (en jaune + "NEW" tant qu'il n'a pas été ouvert dans cette version)
#   Pokémon >       Second starter, Legendary unlocks, Bonds & team budget
#   Items >         Candy shop, Mega/Giga Stones, Z-Crystals, Form items
#   Trials >        Guardian Trials, Ultimate Trial, Trial record
#   My progress     (chiffres actuels : chapitre, plafond, tickets, objets adverses)
#   Close
# "My progress" = VOS chiffres en ce moment ; "Guide" = COMMENT marchent les règles.
# v1.2.4 : textes réécrits (phrases plus claires, retours à la ligne). Le menu Pause
# du jeu n'interprète PAS les balises de couleur : l'entrée y affiche "(NEW)" en texte.
# =============================================================================

if defined?(DBRejuvenating) && defined?(MenuHandlers)
  module DBRejuvenating
    module Menu
      GROUPS = [
        [:pokemon, proc { _INTL("Pokémon") }],
        [:items,   proc { _INTL("Items") }],
        [:trials,  proc { _INTL("Trials") }],
      ] unless const_defined?(:GROUPS, false)

      # Balise de couleur du jeu (jaune), uniquement pour NOS fenêtres de choix
      # (le menu Pause du jeu ne l'interprète pas)
      def self.glowTag
        tags = (isCurrentWindowskinDark ? ColorTags : LightColorTags) rescue nil
        return "" unless tags.is_a?(Hash)
        return (tags[:ShardYellow] || tags[:Blue] || "").to_s
      end

      def self.visibleEntries(group)
        return DBRejuvenating.entries.select { |e| e[:group] == group && (e[:condition].nil? || e[:condition].call) }
      end

      def self.groupName(group)
        g = GROUPS.find { |x| x[0] == group }
        return g ? g[1].call : group.to_s
      end

      # Menu principal : [libellé, action]
      def self.topItems
        list = [[Guide.menuLabel, :guide]]
        GROUPS.each do |g, _|
          list.push([_INTL("{1} >", groupName(g)), g]) unless visibleEntries(g).empty?
        end
        # Entrées sans groupe (ajoutées par un autre mod) : au premier niveau
        visibleEntries(nil).each { |e| list.push([e[:name].call, e]) }
        list.push([_INTL("My progress"), :progress])
        list.push([_INTL("Close"), :close])
        return list
      end

      def self.open
        begin
          DBRejuvenating::BattleLog.checkBadge(false) if defined?(DBRejuvenating::BattleLog)
          DBRejuvenating::Bond.refreshAll if defined?(DBRejuvenating::Bond)
          DBRejuvenating::Bond.runPendingCeremonies if defined?(DBRejuvenating::Bond)
        rescue StandardError => e
          DBRejuvenating.log("ERREUR ouverture menu : #{e.message}")
        end
        loop do
          ok, reason = DBRejuvenating.safeState
          unless ok
            Kernel.pbMessage(reason)
            return
          end
          items = topItems
          cmd = Kernel.pbMessage(_INTL("{1} v{2} ({3})", DBRejuvenating::PATCH_NAME, DBRejuvenating::PATCH_VERSION, DBRejuvenating::RELEASE_STATUS), items.map { |x| x[0] }, -1)
          break if cmd.nil? || cmd < 0 || cmd >= items.length
          action = items[cmd][1]
          break if action == :close
          safely do
            case action
            when :guide    then Guide.open
            when :progress then showProgress
            when Hash      then action[:effect].call
            else                openGroup(action)
            end
          end
        end
      end

      def self.openGroup(group)
        loop do
          es = visibleEntries(group)
          break if es.empty?
          cmd = DBRejuvenating.chooseFromList(groupName(group), es.map { |e| e[:name].call })
          break if cmd < 0
          safely { es[cmd][:effect].call }
        end
      end

      # Une erreur n'interrompt jamais le jeu : journal + message
      def self.safely
        yield
      rescue StandardError => e
        DBRejuvenating.log("ERREUR menu : #{e.class}: #{e.message}\n#{(e.backtrace || [])[0, 8].join("\n")}")
        Kernel.pbMessage(_INTL("Something went wrong, so this action was cancelled.\nDetails are in DB_Rejuvenating_log.txt (in your save folder)."))
      end

      def self.modeName
        return _INTL("Story (easy)") if DBRejuvenating.storyMode?
        return _INTL("Normal")
      end

      # ---------------------------------------------------------------------
      # My progress : vos chiffres actuels (pas les règles : voir le Guide)
      # ---------------------------------------------------------------------
      def self.showProgress
        st = DBRejuvenating.state
        ch = DBRejuvenating.chapter
        cap = DBRejuvenating.levelCap
        Kernel.pbMessage(_INTL("Chapter: {1}\nDifficulty: {2}\nBadges: {3}\nLevel cap: {4}\n(your Pokémon cannot go above level {4} until you earn more badges)",
          DBRejuvenating.chapterName(ch), modeName, DBRejuvenating.numBadges, cap))
        if DBRejuvenating.enabled?(:tickets)
          won = st[:chapter_trials].values.count { |v| v == :won }
          Kernel.pbMessage(_INTL("Tickets: {1} available\n({2} earned in total, {3} already spent)\nTickets are spent to claim legendaries.",
            DBRejuvenating.ticketsAvailable, DBRejuvenating.ticketsEarned, DBRejuvenating.ticketsSpent))
          Kernel.pbMessage(_INTL("Where your tickets came from:\nBadges: {1}\nChapter Trials won: {2}\nRift bosses defeated: {3}\nVirtual League champion: {4}\nUltimate Trial victories: {5}",
            DBRejuvenating.numBadges, won, st[:rifts].keys.length, st[:league_won] ? 1 : 0, DBRejuvenating.ultimateWins))
        end
        if defined?(DBRejuvenating::RareCandy)
          rc = DBRejuvenating::RareCandy
          if rc.free?
            Kernel.pbMessage(_INTL("Candy shop: everything is free and unlimited now."))
          else
            fmt = proc { |k| p = rc.currentPrice(k); p ? _INTL("${1} each ({2} left before the next reset)", p, rc.left(k)) : _INTL("sold out until the next reset") }
            txt = _INTL("Candy shop prices right now:\nRare Candy: {1}", fmt.call(:rare))
            txt += _INTL("\nReverse Candy: {1}", fmt.call(:reverse)) if rc.available?(:reverse)
            txt += _INTL("\n(A reset happens at each new chapter or new badge.)")
            Kernel.pbMessage(txt)
          end
        end
        if defined?(DBRejuvenating::Bond)
          if DBRejuvenating.storyMode?
            Kernel.pbMessage(_INTL("Extra battle items for enemy trainers: off (Story mode)."))
          elsif !DBRejuvenating::Bond.enemyItemsActive? || DBRejuvenating::Bond.bonusItems.empty?
            Kernel.pbMessage(_INTL("Extra battle items for enemy trainers: none right now.\nEnemies only get them in Normal mode, when Pokémon from this mod (legendaries or Eternal Floette) are in your party."))
          else
            n = DBRejuvenating::Bond.bonusItems.length
            Kernel.pbMessage(_INTL("Extra battle items for enemy trainers: {1} per battle right now (never more than 3; bosses 5 at most, boss kit included).\nThe more Pokémon from this mod you have in your party (and the stronger they are), the more items enemies get.", n))
            early = ($Trainer.party rescue []).compact.count { |p| DBRejuvenating::Bond.earlyPower?(p) }
            Kernel.pbMessage(_INTL("Legendaries in your party with 600+ total stats before 12 badges: {1}\n(the game itself gives such Pokémon later). Each counts as 1 extra point for enemy items.", early)) if early > 0
            Kernel.pbMessage(_INTL("To see which of your Pokémon count, how much they cost and their bond, open:\nPokémon > Bonds & team budget"))
          end
        end
      end

      # ---------------------------------------------------------------------
      # Bonds & team budget : légendaires du mod dans l'équipe
      # ---------------------------------------------------------------------
      def self.nextTierText(p)
        t = DBRejuvenating::Bond.tier(p)
        return _INTL("Highest bond tier reached.") if t >= DBRejuvenating::BONDED_TIER
        h, pts, sp = DBRejuvenating::Bond::THRESHOLDS[t + 1]
        txt = _INTL("Next tier ({1}): friendship {2} and {3} bond points", DBRejuvenating::Bond.tierName(t + 1), h, pts)
        txt += _INTL(" and 1 special point") if sp.to_i > 0
        return txt + "."
      end

      def self.showBonds
        return unless defined?(DBRejuvenating::Bond)
        used, over = DBRejuvenating::Bond.teamUsage
        txt = _INTL("Team budget: {1} of {2} points used.\nLegendaries from this mod cost points while they are in your party. Your budget grows as the story goes on.", used, DBRejuvenating.teamBudget)
        txt += _INTL("\nOver budget! These will NOT obey in battle:\n{1}", over.map { |p| p.name }.join(", ")) unless over.empty?
        Kernel.pbMessage(txt)
        shown = false
        ($Trainer.party rescue []).each do |p|
          next unless p && DBRejuvenating.bondable?(p)
          shown = true
          d = DBRejuvenating::Bond.data(p)
          t = DBRejuvenating::Bond.tier(p)
          Kernel.pbMessage(_INTL("{1}\nBond tier: {2}\nFriendship: {3} / 255\nBond points: {4} / {5}\n(from knockouts: {6}, special points: {7})\nTeam budget cost: {8}",
            p.name, DBRejuvenating::Bond.tierName(t), p.happiness, DBRejuvenating::Bond.points(p), DBRejuvenating::Bond::MAX_POINTS,
            d[:pts], d[:special], DBRejuvenating.teamCost(p)))
          Kernel.pbMessage(_INTL("{1}\n{2}", p.name, nextTierText(p)))
        end
        Kernel.pbMessage(_INTL("There is no legendary from this mod in your party right now.")) unless shown
      end

      # ---------------------------------------------------------------------
      # Trial record : résultats des épreuves (chapitres, Gardiens, ultime)
      # ---------------------------------------------------------------------
      CHAPTER_RESULT = {
        :won => proc { _INTL("won") }, :lost => proc { _INTL("lost") }, :declined => proc { _INTL("declined") },
        :missed => proc { _INTL("missed (not taken in time)") }, :started => proc { _INTL("in progress") },
        :story => proc { _INTL("not available (Story mode)") }, :pending => proc { _INTL("waiting (offered at the next safe moment)") },
      } unless const_defined?(:CHAPTER_RESULT, false)

      def self.showTrialRecord
        st = DBRejuvenating.state
        if DBRejuvenating.enabled?(:chapter_trials)
          last = [DBRejuvenating.chapter, 16].min
          if last < 2
            Kernel.pbMessage(_INTL("Chapter Trials:\nthe first one is offered when Chapter 2 starts."))
          else
            lines = (2..last).map do |c|
              r = st[:chapter_trials][c]
              _INTL("Chapter {1}: {2}", c, r && CHAPTER_RESULT[r] ? CHAPTER_RESULT[r].call : _INTL("not offered yet"))
            end
            lines.each_slice(4).with_index do |sl, i|
              Kernel.pbMessage((i == 0 ? _INTL("Chapter Trials:") + "\n" : "") + sl.join("\n"))
            end
          end
        end
        if DBRejuvenating.enabled?(:guardian_trials)
          if DBRejuvenating.storyMode?
            Kernel.pbMessage(_INTL("Guardian Trials: not available in Story mode."))
          else
            won = st[:trials_won].keys.map { |s| DBRejuvenating.monName(s) }
            Kernel.pbMessage(_INTL("Guardian Trials won:\n{1}", won.empty? ? _INTL("none yet") : won.join(", ")))
          end
        end
        if DBRejuvenating.enabled?(:ultimate_trial) && defined?(DBRejuvenating::Trials)
          wins = DBRejuvenating.ultimateWins
          yes = _INTL("yes"); no = _INTL("not yet")
          if DBRejuvenating.storyMode?
            Kernel.pbMessage(_INTL("Ultimate Trial: not available in Story mode."))
          elsif st[:ultimate_failed]
            Kernel.pbMessage(_INTL("Ultimate Trial: closed for this save (you lost once).\nVictories: {1}", wins))
          elsif DBRejuvenating::Trials.ultimateUnlocked?
            Kernel.pbMessage(_INTL("Ultimate Trial: open!\nVictories: {1}", wins))
          else
            chapters, badges, league = DBRejuvenating::Trials.ultimateRequirements
            Kernel.pbMessage(_INTL("Ultimate Trial: locked. It opens when:\n- every Chapter Trial (2 to 16) is won: {1}\n- you own all 18 badges: {2}\n- you beat the Virtual League champion: {3}",
              chapters ? yes : no, badges ? yes : no, league ? yes : no))
          end
        end
      end
    end

    # Entrées intégrées au menu, rangées dans leurs groupes
    registerEntry(:bonds, order: 30, group: :pokemon, name: proc { _INTL("Bonds & team budget") },
      condition: proc { defined?(DBRejuvenating::Bond) ? true : false },
      effect: proc { DBRejuvenating::Menu.showBonds })
    registerEntry(:trial_record, order: 30, group: :trials, name: proc { _INTL("Trial record") },
      condition: proc { DBRejuvenating.enabled?(:chapter_trials) || DBRejuvenating.enabled?(:guardian_trials) || DBRejuvenating.enabled?(:ultimate_trial) },
      effect: proc { DBRejuvenating::Menu.showTrialRecord })

    # -------------------------------------------------------------------------
    # Guide intégré : explique les RÈGLES, rangé comme le menu.
    # v1.2.5 : chaque page non lue est en jaune ; le Guide (et l'entrée du menu
    # Pause) restent signalés tant qu'une page n'a pas été lue. Une page dont le
    # texte change dans une mise à jour redevient "non lue" (empreinte du texte).
    # Mémorisé dans la sauvegarde : st[:guide_read] = { id de page => empreinte }.
    # Le Changelog est à la fin.
    # -------------------------------------------------------------------------
    module Guide
      # Empreinte stable du texte (String#hash change à chaque lancement : inutilisable)
      def self.fingerprint(lines)
        v = 7
        lines.join("\n").each_byte { |b| v = (v * 31 + b) % 2_147_483_647 }
        return v
      end

      def self.readState
        st = DBRejuvenating.state
        return nil unless st
        st[:guide_read] = {} unless st[:guide_read].is_a?(Hash)
        return st[:guide_read]
      end

      def self.pageRead?(page)
        rs = readState
        return true unless rs
        return rs[page[0]] == fingerprint(page[2])
      end

      def self.markRead(page)
        rs = readState
        rs[page[0]] = fingerprint(page[2]) if rs
      end

      def self.unseen?
        return false unless DBRejuvenating.state
        return pages.any? { |pg| !pageRead?(pg) }
      end

      def self.unreadCount
        return pages.count { |pg| !pageRead?(pg) }
      end

      def self.menuLabel
        return unseen? ? DBRejuvenating::Menu.glowTag + _INTL("Guide (NEW)") : _INTL("Guide")
      end

      # Chaque page : [identifiant stable, titre, lignes]
      def self.pages
        pct = DBRejuvenating.cfg(:wild_disobey_percent).to_i
        return [
          [:menu, _INTL("How this menu works"), [
            _INTL("Guide: explains how every rule of the mod works.\nMy progress: shows YOUR numbers right now (chapter, level cap, tickets, candy prices, enemy battle items)."),
            _INTL("Pokémon: get your second starter, claim legendaries (new ones or ones you missed), and check their bond and team budget.\nItems: candy shop, Mega/Giga Stones, Z-Crystals and form items.\nTrials: Guardian Trials, Ultimate Trial, and the record of all your trials."),
            _INTL("Guide pages you have not read yet are shown in yellow. The Guide stays marked (NEW) until you have read all of them.\nWhen an update changes a page, it turns yellow again. The Changelog (at the end) lists what changed."),
            _INTL("Nothing in this mod can block the story: every rule only affects what the mod itself gives you.\nThis menu only opens from the Pause menu, never during an event."),
            _INTL("Words used in this Guide:\n- Level cap: the highest level your Pokémon can reach with your current badges.\n- Story mode: the game's easy difficulty. The other one is Normal."),
          ]],
          [:starter, _INTL("Pokémon: second starter"), [
            _INTL("Eternal Flower Floette is your second starter.\nYou can take it for free as soon as you have your first Pokémon.\nIt arrives at your current level cap."),
            _INTL("It learns its signature move, Light of Ruin, when it reaches the Trusting bond tier (friendship 70 + 5 bond points).\nIf you refuse, it offers again after your next badge."),
            _INTL("It has a bond with you like the mod's legendaries (see Pokémon: bond).\nAt the Loyal tier, it unlocks its Mega Stone (Items > Mega/Giga Stones).\nIt always costs 1 point in your team budget."),
          ]],
          [:unlocks, _INTL("Pokémon: legendary unlocks"), [
            _INTL("Pokémon > Legendary unlocks lists the legendaries, mythicals, Ultra Beasts and Paradox Pokémon that the base game never lets you get."),
            _INTL("Each one has a tag:\n[locked] its condition is not met yet (select it to see the condition)\n[TRIAL] win its Guardian Trial first\n[no ticket] you need a ticket\n[READY] you can claim it now\n[received] already claimed"),
            _INTL("Conditions follow each legendary's story: meeting it in a battle, owning related Pokémon, beating a related trainer, or finishing a special quest."),
            _INTL("Every legendary also needs a minimum number of badges, matched to when the game itself gives legendaries:\n- Restricted legendaries and Arceus: 11 badges\n- other legendaries and mythicals: 6 badges\n- Ultra Beasts and Paradox Pokémon: 8 badges"),
            _INTL("Claiming a legendary costs 1 ticket.\nIt arrives at your current level cap, so it follows the normal level rules."),
          ]],
          [:missed, _INTL("Pokémon: missed legendaries"), [
            _INTL("Pokémon > Missed legendaries is a second chance for legendaries that the GAME gives you (wild encounters, gifts, story routes), when you missed them for good."),
            _INTL("If you battled one in the wild and it fainted or fled without being caught, it becomes available when the next chapter starts (the story has moved on)."),
            _INTL("If you never met it, the mod cannot know whether you can still find it, so it only becomes available at the end: all 18 badges and the Virtual League champion beaten."),
            _INTL("It costs 1 ticket, like any legendary, and arrives at your level cap.\nIf you catch it normally in the game, it is marked [caught] and is not offered again: you can never get it twice."),
          ]],
          [:tickets, _INTL("Pokémon: tickets"), [
            _INTL("You earn 1 ticket for each:\n- badge\n- Chapter Trial won\n- Rift boss defeated\n- Ultimate Trial victory\n...and 1 for beating the Virtual League champion."),
            _INTL("Each legendary you claim costs 1 ticket.\nThere are far more legendaries than tickets, so choose carefully!\nYour ticket count is shown in My progress."),
          ]],
          [:bond, _INTL("Pokémon: bond"), [
            _INTL("Legendaries from this mod (and Eternal Floette) have a bond with you, in 5 tiers:\nWild > Trusting > Loyal > Devoted > Bonded\nA tier, once reached, is never lost."),
            _INTL("To reach a tier you need BOTH friendship and bond points.\nFriendship rises the normal way (walking, berries, vitamins, Soothe Bell...)."),
            _INTL("Bond points (30 max):\n- +1 each time THIS Pokémon knocks out an opponent in a trainer battle (max 1 per battle, 29 in total)\n- +1 for each special point"),
            _INTL("Special point: earn a Gym badge right after a battle where it was in your party, or beat the Virtual League champion with it in your party.\nSwapping it in from the PC after the battle does not count."),
            _INTL("Trusting: friendship 70 + 5 points (it always obeys)\nLoyal: friendship 150 + 12 points (unlocks its Mega Stone or Z-Crystal)\nDevoted: friendship 190 + 20 points (you may change its nature)\nBonded: friendship 220 + 30 points, including 1 special point"),
            _INTL("Bonded: you may change its ability, and it costs 1 point less in your team budget (Restricted and other legendaries).\nWhen you change its nature, you see which stat each nature raises and lowers."),
            _INTL("Wild legendaries from this mod ignore your orders {1}% of the time, until they reach Trusting.\nYou can see every bond in Pokémon > Bonds & team budget.", pct),
          ]],
          [:budget, _INTL("Pokémon: team budget"), [
            _INTL("Legendaries from this mod cost points while they are in your party:\n- Restricted legendaries and Arceus: 3 points (2 when Bonded)\n- other legendaries and mythicals: 2 points (1 when Bonded)\n- Ultra Beasts and Paradox Pokémon: 1 point\n- Eternal Floette: 1 point"),
            _INTL("Restricted legendaries are the big \"box\" legendaries, such as Kyogre, Rayquaza or Zacian."),
            _INTL("Your budget grows with the story:\nChapters 1-2: 2 points\nChapters 3-5: 3\nChapters 6-8: 4\nChapters 9-11: 5\nChapters 12-14: 6\nChapters 15-16: 7"),
            _INTL("If your party is over budget, the extra legendaries (the last ones in party order) will not obey in battle.\nThey are never taken away from you.\nSee your usage in Pokémon > Bonds & team budget."),
          ]],
          [:candy, _INTL("Items: candy shop"), [
            _INTL("Rare Candy:\n10 at $100 each, then 10 at $200, and so on up to 10 at $1000 each (100 candies in total).\nAfter that it is sold out until the next reset."),
            _INTL("Reverse Candy (lowers a Pokémon's level by 1):\n10 at $10 each, then 10 at $20, and so on up to 10 at $100 each (100 candies in total).\nAfter that it is sold out until the next reset."),
            _INTL("Reset: at each new chapter or new badge, prices go back to the start and the stock refills.\nA badge and a new chapter at the same moment count as one reset.\nCurrent prices are shown in My progress."),
            _INTL("Once you own all 18 badges AND beat the Virtual League champion, both candies become free and unlimited."),
            _INTL("Rare Candy never raises a Pokémon above your level cap, even when free.\nAt the cap it only triggers an evolution that is already waiting."),
            _INTL("Candies from this shop (bought or free) cannot be sold to other shops, so they cannot be used to make money.\nCandies you find during the game can still be sold normally."),
          ]],
          [:items, _INTL("Items: stones, crystals, form items"), [
            _INTL("Mega/Giga Stones, Z-Crystals and form items that the base game never gives you can be taken here once unlocked.\nSelect a [locked] item to see its condition."),
            _INTL("Usual condition:\n- own the Pokémon that uses it, and\n- if a trainer in the game uses that item, beat that trainer.\nA legendary's stone or crystal also needs that legendary at the Loyal bond tier."),
            _INTL("Items that make a legendary even stronger also need it at the Loyal bond tier:\nRed Orb, Blue Orb, Rusted Sword, Rusted Shield and Prison Bottle."),
            _INTL("To use Mega Evolution or Z-Moves you still need the ring or bracelet that the story gives you.\nThis mod never gives one."),
          ]],
          [:chapter_trials, _INTL("Trials: Chapter Trials"), [
            _INTL("From Chapter 2 on, each time a new chapter starts, a Chapter Trial is offered at the first safe moment.\nYou can save your game first."),
            _INTL("You fight your own reflection: a copy of your team with 10% more EXP (no evolution, no new move) and better held items.\nWinning gives 1 ticket."),
            _INTL("Each Chapter Trial is offered ONCE per save file.\nYour choice is recorded for good, and the game saves right after.\nReloading an older save does not bring it back."),
            _INTL("Chapter Trials are not available in Story mode.\nYour results are in Trials > Trial record."),
          ]],
          [:guardian, _INTL("Trials: Guardian Trials"), [
            _INTL("Restricted legendaries (the big \"box\" legendaries such as Kyogre or Zacian) must be won in a Guardian Trial before you can claim them with a ticket.\nTrials > Guardian Trials lists only those."),
            _INTL("You face a Guardian Spectre with a real competitive team built around that legendary, all at your level cap.\nNo stat boosts: it is hard because the team is good."),
            _INTL("You cannot bring legendaries from this mod.\nLosing costs nothing and you can retry as often as you want.\nNo EXP is gained."),
            _INTL("Guardian Trials are not available in Story mode."),
          ]],
          [:ultimate, _INTL("Trials: Ultimate Trial"), [
            _INTL("End-game challenge. It opens when:\n- every Chapter Trial (Chapters 2 to 16) was WON\n- you own all 18 badges\n- you beat the Virtual League champion\nA lost, declined or missed Chapter Trial closes it for this save."),
            _INTL("Three rounds in a row against your reflection, which uses healing items and X items:\nRound 1: 1 vs 1\nRound 2: 2 vs 2 (double battle)\nRound 3: 3 vs 3\nYou pick your Pokémon before each round, with no substitutes."),
            _INTL("A Pokémon fights in only ONE round.\nOnce it has fought in the Ultimate Trial, it can never enter it again (your reflection follows the same rule)."),
            _INTL("Each victory gives 1 ticket, and you may go again as long as you keep winning, with 6 new Pokémon each time.\nYour first defeat (or quitting or closing the game after the first battle) closes it for this save."),
            _INTL("The Ultimate Trial is not available in Story mode."),
          ]],
          [:battles, _INTL("Battles: enemy items"), [
            _INTL("Normal mode only: when Pokémon from this mod (legendaries or Eternal Floette) are in your party, every enemy trainer gets a few extra battle items, in this order:\n1. a potion (Super, Hyper, Max Potion or Full Restore, depending on your level cap)\n2. a Full Heal\n3. an X Defense (if your legendaries attack physically) or X Sp. Def (if they attack specially)"),
            _INTL("How many: 1 item per 2 points of their team cost (full cost, Bonded discount not counted, rounded up).\nA trainer never gets more than 3, a boss never more than 5 in total. No stat or level boosts.\nThe game's own AI decides when an item is worth using: it never uses a Full Heal without a status, for example."),
            _INTL("A legendary from this mod with 600+ total stats, used before 12 badges, counts as 1 extra point (the game itself gives no such Pokémon before about 12 badges).\nYou can still use it freely: this only adds enemy items."),
            _INTL("This is off in Story mode and with the \"noitems\" password.\nThe current number is shown in My progress."),
            _INTL("Boss kit (Normal mode): a Gym Leader, Elite Four member or Champion who has NO healing item in the base game gets 2 healing items, a Full Heal and 2 X items (X Speed, plus X Attack or X Sp. Atk, matching its team).\nFrom 15 badges, these X items are the game's stronger \"3\" versions (+3 stages).\nThis is off in Story mode and with \"noitems\"."),
          ]],
          [:changelog, _INTL("Changelog (v{1})", DBRejuvenating::PATCH_VERSION), [
            _INTL("v1.3.1 (stable, ready to share):\n- Arceus costs 3 points (2 when Bonded) and needs 11 badges, like a Restricted legendary.\n- Red/Blue Orb, Rusted Sword/Shield and Prison Bottle need that legendary at the Loyal bond tier, like its Mega Stone."),
            _INTL("v1.3.1 (battles):\n- Enemy extra items are more varied (potion, Full Heal, X Defense or X Sp. Def) and capped: 3 per trainer, 5 per boss.\n- A 600+ stat legendary used before 12 badges counts 1 extra point for enemy items.\n- Boss kit: + Full Heal; from 15 badges its X items are the \"3\" versions."),
            _INTL("v1.3.0:\n- Legendaries now come at the same pace as in the game: minimum 11 badges for Restricted ones, 6 for other legendaries and mythicals, 8 for Ultra Beasts and Paradox.\n- Lugia can now be unlocked (own Articuno, Zapdos and Moltres).\n- Eternal Floette learns Light of Ruin at the Trusting bond tier instead of knowing it from the start."),
            _INTL("v1.2.5:\n- New bond tier: Devoted (nature change). Bond points now go up to 30, and special points count as bond points.\n- Restricted legendaries unlocked only by badges now follow their story (never earlier than before).\n- Each Guide page shows in yellow until you read it. This Changelog moved to the end.\n- Intense mode (removed from the game in V13.5) is no longer mentioned."),
            _INTL("v1.2.4:\n- Ultra Beasts and Paradox Pokémon now cost only 1 point in your team budget (Bonded or not).\n- New: Pokémon > Missed legendaries, a second chance for legendaries of the game that you missed.\n- Candies from the mod's candy shop can no longer be sold to other shops (candies you find stay sellable).\n- All texts of the mod were rewritten to be clearer."),
            _INTL("v1.2.3:\n- The menu is sorted into groups: Pokémon, Items and Trials.\n- \"Status\" became \"My progress\" (your current numbers).\n- \"Team & bonds\" became \"Bonds & team budget\" (in Pokémon).\n- New: Trial record and a Guardian Trials shortcut."),
            _INTL("v1.2.2:\n- The mod is now called DB's Rejuvenating Settings.\n- The free Rare Candy pack was replaced by a candy shop, with Reverse Candy too (see Items: candy shop)."),
          ]],
        ]
      end

      def self.open
        loop do
          pg = pages
          glow = DBRejuvenating::Menu.glowTag
          labels = pg.map { |x| pageRead?(x) ? x[1] : glow + x[1] }
          n = pg.count { |x| !pageRead?(x) }
          head = n > 0 ? _INTL("Guide: pick a topic.\nYellow = not read yet ({1} left).", n) : _INTL("Guide: pick a topic.\nYou have read every page.")
          cmd = DBRejuvenating.chooseFromList(head, labels)
          break if cmd < 0
          pg[cmd][2].each { |line| Kernel.pbMessage(line) }
          markRead(pg[cmd])
        end
      end
    end
  end

  MenuHandlers.add(:pause_menu, :db_rejuvenating,
    # Le menu Pause du jeu n'interprète pas les balises de couleur : "(NEW)" en texte
    name:      proc { (DBRejuvenating::Guide.unseen? rescue false) ? _INTL("DB Rejuv Settings (NEW)") : _INTL("DB Rejuv Settings") },
    order:     85,
    condition: proc { |scene, screen|
      $Trainer && $Trainer.party && $Trainer.party.length > 0 &&
        !($game_switches && $game_switches[:NotPlayerCharacter])
    },
    effect:    proc { |scene, screen|
      # On ferme le menu Pause avant d'ouvrir nos fenêtres (même schéma que "Sac" → objet clé)
      scene.pbEndScene
      DBRejuvenating::Menu.open
      next :break
    }
  )
end
