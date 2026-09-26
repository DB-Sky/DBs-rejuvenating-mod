# =============================================================================
# DB's Rejuvenating Settings — MODULE 6 : Journal des combats
#
# Enveloppe (sans les modifier) pbTrainerBattle, pbDoubleTrainerBattle
# (Trainers.rb) et pbWildBattle (Field.rb) :
#   - dresseurs battus "TYPE|Nom" (déblocages "battre le dresseur", module 3) ;
#   - boss des Failles battus (1 ticket chacun) ;
#   - champion de la Virtual League (1 ticket + point spécial de lien) ;
#   - photo de l'équipe AU DÉBUT du combat : si un badge est obtenu juste après
#     la victoire, les légendaires présents pendant CE combat reçoivent le point
#     spécial de lien (module 8). Échanger un Pokémon via le PC après le combat
#     ne sert donc à rien : seule compte l'équipe qui a combattu.
# Aucun effet sur le combat lui-même.
# =============================================================================

if defined?(DBRejuvenating)
  module DBRejuvenating
    module BattleLog
      # Pokémon "liables" présents dans l'équipe au début du combat
      def self.snapshot
        return ($Trainer.party rescue []).select { |p| p && DBRejuvenating.bondable?(p) }
      end

      # Victoire : on retient l'équipe et le nombre de badges d'avant
      def self.recordWin(snap, badgesBefore)
        $PokemonTemp.instance_variable_set(:@dbrPendingWin, { :mons => snap, :badges => badgesBefore }) if $PokemonTemp
      end

      # Un badge a-t-il été obtenu depuis la dernière victoire ? (appelé au pas
      # suivant, à l'ouverture du menu et au début du combat suivant)
      def self.checkBadge(clear = false)
        return unless $PokemonTemp
        pend = $PokemonTemp.instance_variable_get(:@dbrPendingWin)
        return unless pend
        if DBRejuvenating.numBadges > pend[:badges].to_i
          pend[:mons].each { |p| (DBRejuvenating::Bond.addSpecial(p, _INTL("earning a Gym badge together")) rescue nil) }
          $PokemonTemp.instance_variable_set(:@dbrPendingWin, nil)
        elsif clear
          $PokemonTemp.instance_variable_set(:@dbrPendingWin, nil)
        end
      end

      def self.afterTrainerWin(pairs, snap)
        pairs.each do |type, name|
          next unless type && name
          DBRejuvenating.recordBeat(type, name)
          if [type, name] == DBRejuvenating::LEAGUE_CHAMPION
            st = DBRejuvenating.state
            unless st[:league_won]
              st[:league_won] = true
              DBRejuvenating.log("Champion de la Virtual League battu : +1 ticket")
            end
            snap.each { |p| (DBRejuvenating::Bond.addSpecial(p, _INTL("becoming Virtual League champion together")) rescue nil) }
          end
        end
      end
    end
  end

  unless defined?(dbRejuvenating_orig_pbTrainerBattle)
    alias dbRejuvenating_orig_pbTrainerBattle pbTrainerBattle
  end

  def pbTrainerBattle(*args, **kwargs, &block)
    DBRejuvenating::BattleLog.checkBadge(true) rescue nil
    # Cas "deux dresseurs vous voient" : le premier est mis en attente et
    # combattu en même temps que le second (voir $PokemonTemp.waitingTrainer)
    waiting = ($PokemonTemp.waitingTrainer rescue nil)
    snap = (DBRejuvenating::BattleLog.snapshot rescue [])
    badges = DBRejuvenating.numBadges
    ret = dbRejuvenating_orig_pbTrainerBattle(*args, **kwargs, &block)
    if ret == true
      begin
        pairs = [[args[0], args[1]]]
        if waiting && waiting[0] && waiting[0][0]
          pairs.push([waiting[0][0].trainertype, waiting[0][0].name])
        end
        DBRejuvenating::BattleLog.afterTrainerWin(pairs, snap)
        DBRejuvenating::BattleLog.recordWin(snap, badges)
      rescue StandardError => e
        DBRejuvenating.log("ERREUR BattleLog : #{e.message}")
      end
    end
    (DBRejuvenating::Bond.refreshParty rescue nil)
    return ret
  end

  unless defined?(dbRejuvenating_orig_pbDoubleTrainerBattle)
    alias dbRejuvenating_orig_pbDoubleTrainerBattle pbDoubleTrainerBattle
  end

  def pbDoubleTrainerBattle(*args, **kwargs, &block)
    DBRejuvenating::BattleLog.checkBadge(true) rescue nil
    snap = (DBRejuvenating::BattleLog.snapshot rescue [])
    badges = DBRejuvenating.numBadges
    ret = dbRejuvenating_orig_pbDoubleTrainerBattle(*args, **kwargs, &block)
    if ret == true
      begin
        DBRejuvenating::BattleLog.afterTrainerWin([[args[0], args[1]], [args[4], args[5]]], snap)
        DBRejuvenating::BattleLog.recordWin(snap, badges)
      rescue StandardError => e
        DBRejuvenating.log("ERREUR BattleLog : #{e.message}")
      end
    end
    (DBRejuvenating::Bond.refreshParty rescue nil)
    return ret
  end

  # Boss "sauvages" (Failles, etc.) : pbWildBattle(:IDBOSS, niveau, variable, ...)
  unless defined?(dbRejuvenating_orig_pbWildBattle)
    alias dbRejuvenating_orig_pbWildBattle pbWildBattle
  end

  def pbWildBattle(*args, **kwargs, &block)
    DBRejuvenating::BattleLog.checkBadge(true) rescue nil
    snap = (DBRejuvenating::BattleLog.snapshot rescue [])
    badges = DBRejuvenating.numBadges
    ret = dbRejuvenating_orig_pbWildBattle(*args, **kwargs, &block)
    begin
      var = args[2] || (Variables[:BattleResult] rescue nil)
      decision = var ? pbGet(var) : nil
      if decision == 1
        species = args[0]
        if DBRejuvenating::RIFT_BOSSES.include?(species)
          st = DBRejuvenating.state
          unless st[:rifts][species]
            st[:rifts][species] = true
            DBRejuvenating.log("Boss des Failles battu : #{species} (+1 ticket)")
          end
        end
        DBRejuvenating::BattleLog.recordWin(snap, badges)
      end
    rescue StandardError => e
      DBRejuvenating.log("ERREUR BattleLog (sauvage) : #{e.message}")
    end
    (DBRejuvenating::Bond.refreshParty rescue nil)
    return ret
  end
end
