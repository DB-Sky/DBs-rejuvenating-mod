# =============================================================================
# DB's Rejuvenating Settings — MODULE 5 : Correctifs de données (support partiel)
#
# 1) DARKRANITE et GARCHOMPITEZ : les formes Méga-Darkrai / Méga-Carchacrok Z,
#    leurs sprites, leurs icônes d'objet et PBStuff::POKEMONTOMEGASTONE existent,
#    mais les deux OBJETS manquent dans itemtext.rb → Méga impossible.
#    On les ajoute au cache d'objets (même format que DIANCITE).
# 2) TATSUGIRINITE : Tatsugiri "Curly" pointe vers une forme "Mega Form" qui
#    n'existe pas, et Droopy/Stretchy n'ont aucune Méga. Les formes
#    "Mega Curly/Droopy/Stretchy Form" et leurs sprites (3,4,5) existent :
#    on corrige seulement la table MegaEvolutions (index de formes inchangés).
# 3) REINSOFUNITY : les formes Cavalier Glace/Effroi de Sylveroy et leurs
#    talents (As One) existent, mais l'objet n'a aucun effet. On ajoute le
#    même mécanisme que les Pointeaux ADN (ItemEffects.rb, DNASPLICERS).
#
# Appliqué quand le jeu charge ses données (Cache_Game#loadRuntimeData),
# et aussi au rechargement F12. Aucune donnée existante n'est écrasée.
# =============================================================================

if defined?(DBRejuvenating) && DBRejuvenating.enabled?(:data_fixes)
  module DBRejuvenating
    module DataFixes
      remove_const(:NEW_ITEMS) if const_defined?(:NEW_ITEMS, false) # rechargement F12
      NEW_ITEMS = {
        :DARKRANITE => {
          :name => "Darkranite",
          :desc => "One variety of Mega Stone. Have Darkrai hold it, and this stone will enable it to Mega Evolve in battle.",
          :price => 999, :crystal => true, :noUseInBattle => true, :noUse => true,
        },
        :GARCHOMPITEZ => {
          :name => "Garchompite Z",
          :desc => "One variety of Mega Stone. Have Garchomp hold it, and this stone will enable it to Mega Evolve in battle.",
          :price => 999, :crystal => true, :noUseInBattle => true, :noUse => true,
        },
      }

      def self.applyItems
        return unless $cache && $cache.items.is_a?(Hash)
        NEW_ITEMS.each do |sym, data|
          next if $cache.items.key?(sym) # jamais d'écrasement (ex. future mise à jour officielle)
          $cache.items[sym] = ItemData.new(sym, data)
          DBRejuvenating.log("Objet ajouté : #{sym}")
        end
      end

      def self.applyTatsugiri
        return unless $cache && $cache.pkmn && ($cache.pkmn.key?(:TATSUGIRI) rescue false)
        w = $cache.pkmn[:TATSUGIRI]
        pairs = { "Curly Form" => "Mega Curly Form", "Droopy Form" => "Mega Droopy Form", "Stretchy Form" => "Mega Stretchy Form" }
        forms = w.forms.values
        return unless pairs.to_a.flatten.all? { |f| forms.include?(f) }
        pairs.each do |base, mega|
          data = w[base]
          next unless data
          current = data.MegaEvolutions
          next if current[:TATSUGIRINITE] == mega
          data.instance_variable_set(:@MegaEvolutions, current.merge({ :TATSUGIRINITE => mega }))
        end
      end

      def self.apply
        begin
          applyItems
          applyTatsugiri
        rescue StandardError => e
          DBRejuvenating.log("ERREUR DataFixes : #{e.class}: #{e.message}")
        end
      end
    end
  end

  # Se déclenche à chaque (re)chargement des données du jeu
  class Cache_Game
    unless method_defined?(:dbRejuvenating_orig_loadRuntimeData)
      alias_method :dbRejuvenating_orig_loadRuntimeData, :loadRuntimeData
    end

    def loadRuntimeData
      ret = dbRejuvenating_orig_loadRuntimeData
      DBRejuvenating::DataFixes.apply
      return ret
    end

    unless method_defined?(:dbRejuvenating_orig_cacheItems)
      alias_method :dbRejuvenating_orig_cacheItems, :cacheItems
    end

    def cacheItems
      ret = dbRejuvenating_orig_cacheItems
      DBRejuvenating::DataFixes.applyItems rescue nil
      return ret
    end

    unless method_defined?(:dbRejuvenating_orig_cacheDex)
      alias_method :dbRejuvenating_orig_cacheDex, :cacheDex
    end

    def cacheDex
      ret = dbRejuvenating_orig_cacheDex
      DBRejuvenating::DataFixes.applyTatsugiri rescue nil
      return ret
    end
  end

  # Rechargement F12 : les données sont déjà en mémoire
  DBRejuvenating::DataFixes.apply if $cache

  # ---------------------------------------------------------------------------
  # Reins of Unity : Sylveroy + Blizzeval / Spectreval (calqué sur DNASPLICERS)
  # ---------------------------------------------------------------------------
  unless (ItemHandlers::UseOnPokemon[:REINSOFUNITY] rescue nil)
    ItemHandlers::UseOnPokemon.add(:REINSOFUNITY, proc { |item, pokemon, scene|
      if pokemon.species == :CALYREX && pokemon.hp >= 0
        riders = { :GLASTRIER => "Ice Rider", :SPECTRIER => "Shadow Rider" }
        signature = { "Ice Rider" => :GLACIALLANCE, "Shadow Rider" => :ASTRALBARRAGE }
        forms = $cache.pkmn[:CALYREX].forms
        if pokemon.fused != nil
          if $Trainer.party.length >= 6
            scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.", pokemon.name))
            next false
          end
          oldname = forms[pokemon.form]
          # Retire l'attaque signature (comme le jeu officiel) et la remplace par Confusion
          sig = signature[oldname]
          (0...pokemon.moves.length).each do |i|
            pokemon.pbLearnMoveAtIndex(:CONFUSION, i) if pokemon.moves[i] && pokemon.moves[i].move == sig
          end
          $Trainer.party[$Trainer.party.length] = pokemon.fused
          pokemon.fused = nil
          pokemon.changeForm(0)
          pokemon.initAbility
          pokemon.calcStats
          scene.pbHardRefresh
          scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
          next true
        else
          chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
          next false if chosen < 0
          poke2 = $Trainer.party[chosen]
          target = riders[poke2.species]
          if pokemon == poke2
            scene.pbDisplay(_INTL("{1} can't be fused with itself!", pokemon.name))
            next false
          elsif target.nil? || (poke2.isEgg? rescue false)
            scene.pbDisplay(_INTL("{1} can't be fused with {2}.", poke2.name, pokemon.name))
            next false
          end
          newform = forms.invert[target]
          if newform.nil?
            scene.pbDisplay(_INTL("It had no effect."))
            next false
          end
          pokemon.changeForm(newform)
          pokemon.initAbility
          pokemon.calcStats
          pokemon.fused = poke2
          pbRemovePokemonAt(chosen)
          # Apprend l'attaque signature s'il reste une place (sinon : Maître des Capacités)
          sig = signature[target]
          if sig && pokemon.moves.compact.length < 4 && !pokemon.knowsMove?(sig)
            pokemon.pbLearnMove(sig)
          end
          scene.pbHardRefresh
          scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
          next true
        end
      else
        scene.pbDisplay(_INTL("It had no effect."))
        next false
      end
    })
  end
end
