# =============================================================================
# DB's Rejuvenating Settings — MODULE 10 : "Hidden stats" (v1.3.2)
#
# Affiche des valeurs que le jeu garde cachées. LECTURE SEULE : ce module ne
# modifie JAMAIS une variable, un interrupteur ou un Pokémon.
#
# Sources (vérifiées dans les fichiers du jeu V14, Data/System.rxdata + événements) :
#   - Variable 129 "Karma" : +1 à chaque bonne action (92 événements), -1/-5/-100
#     pour les mauvaises. L'histoire la teste (ex. carte 374 : >= 20).
#   - Variables 377-400 (bloc "##Relationships##") et 477-499 (bloc
#     "RELATIONSHIPS#2###") : points de relation avec les personnages.
#     491 "CUSTOMWEATHER" est dans le bloc mais n'est PAS une relation : exclue.
#   - Variables 300, 749, 895, 941, 963, 976 : autres relations nommées par le jeu.
#     751 "NymieraRel" exclue : valeur spéciale (-999), sens incertain.
#   - Variable 745 "GDCReputation" : réputation à Grand Dream City (paliers 100-800).
#   - Variables 532 / 538 : amitié d'Espurr et de Growlithe (quêtes, paliers 0-1000).
#   - Pokémon : bonheur exact (0-255 ; l'écran Résumé n'affiche qu'un %) et type de
#     Puissance Cachée. Dans Rejuvenation ce type vient de l'ID personnel, PAS des IV
#     (Battle_MoveEffects.rb#pbHiddenPower). On refait le calcul SANS l'enregistrer,
#     car la fonction du jeu écrit pkmn.hptype.
# Les IV/EV ne sont pas répétés ici : l'écran Résumé du jeu les montre déjà.
# =============================================================================

if defined?(DBRejuvenating)
  module DBRejuvenating
    module HiddenStats
      KARMA_VAR = 129 unless const_defined?(:KARMA_VAR, false)
      GDC_VAR   = 745 unless const_defined?(:GDC_VAR, false)

      # [variable, nom affiché] — noms tels que le jeu les écrit (rendus lisibles)
      RELATIONSHIPS = [
        [377, "Melia"], [378, "Ren"], [379, "Venam"], [380, "Tesla"], [381, "Madelis"],
        [382, "Karrina"], [383, "Aelita"], [384, "Keta"], [385, "Mosely"], [386, "Narcissa"],
        [387, "Marianette"], [388, "Crawli"], [389, "Angie"], [390, "RorimB"], [391, "Valarie"],
        [392, "Braixen"], [393, "Adam"], [394, "Amber"], [395, "Reina"], [396, "Crescent"],
        [397, "Anathea"], [398, "Karen"], [399, "Erin"], [400, "Damien"],
        [477, "Vivian"], [478, "Saki"], [479, "Alexandra"], [480, "Ryland"], [481, "Huey"],
        [482, "Erick"], [483, "Ben"], [484, "Beth"], [485, "Goomink"], [486, "Lavender"],
        [487, "Allen"], [488, "Alice"], [489, "Nim"], [490, "Piano Lady"], [492, "Kanon"],
        [493, "Mom"], [494, "Florin"], [495, "Talon"], [496, "Flora"], [497, "Kreiss"],
        [498, "Eizen"], [499, "Particia"],
        [300, "Beth (side story)"], [749, "Hazuki"], [895, "Hazel"], [941, "Kaina"],
        [963, "Volta"], [976, "Cera"],
      ] unless const_defined?(:RELATIONSHIPS, false)

      COMPANIONS = [[532, "Espurr"], [538, "Growlithe"]] unless const_defined?(:COMPANIONS, false)

      # Lecture sûre d'une variable du jeu (jamais d'écriture)
      def self.var(id)
        v = ($game_variables[id] rescue nil)
        return v.is_a?(Numeric) ? v.to_i : 0
      end

      def self.karmaText
        k = var(KARMA_VAR)
        mood = if k > 0 then _INTL("mostly good choices so far")
               elsif k < 0 then _INTL("mostly bad choices so far")
               else _INTL("neutral")
               end
        return _INTL("Karma: {1}\n({2})\nGood actions raise it, bad ones lower it. Some story scenes check it.", k, mood)
      end

      def self.showKarma
        Kernel.pbMessage(karmaText)
        gdc = var(GDC_VAR)
        Kernel.pbMessage(_INTL("Grand Dream City reputation: {1}\nIt rises when you help people there. Some events need a high enough reputation.", gdc))
        comp = COMPANIONS.map { |id, name| _INTL("{1}: {2}", name, var(id)) }
        Kernel.pbMessage(_INTL("Sidequest companions' friendship:\n{1}", comp.join("\n")))
      end

      def self.showRelationships
        rows = RELATIONSHIPS.map { |id, name| [name, var(id)] }.reject { |_, v| v == 0 }
        if rows.empty?
          Kernel.pbMessage(_INTL("Relationships: all at 0 for now.\nThey change with your choices in conversations."))
          return
        end
        rows = rows.sort_by { |n, v| [-v, n] }
        Kernel.pbMessage(_INTL("Relationships ({1} characters, from highest to lowest).\nHigher = closer. Your choices in conversations change them; some scenes check them.", rows.length))
        rows.each_slice(6) { |sl| Kernel.pbMessage(sl.map { |n, v| _INTL("{1}: {2}", n, v) }.join("\n")) }
      end

      # Même calcul que pbHiddenPower du jeu, mais sans enregistrer le résultat
      def self.hiddenPowerType(p)
        return p.hptype if (p.hptype rescue nil)
        types = ($cache.types.keys rescue []).reject { |t| [:NORMAL, :QMARKS, :SHADOW, :STELLAR].include?(t) }
        return nil if types.empty?
        return types[p.personalID.to_i % types.length]
      rescue StandardError
        return nil
      end

      def self.typeName(t)
        return _INTL("unknown") unless t
        return (getTypeName(t) rescue t.to_s.capitalize)
      end

      def self.showParty
        party = ($Trainer.party rescue []).compact.reject { |p| (p.isEgg? rescue false) }
        if party.empty?
          Kernel.pbMessage(_INTL("No Pokémon in your party."))
          return
        end
        Kernel.pbMessage(_INTL("Friendship goes from 0 to 255 (the Summary screen only shows a %).\nHidden Power type in Rejuvenation comes from each Pokémon's hidden ID, not from its IVs."))
        party.each_slice(3) do |sl|
          Kernel.pbMessage(sl.map { |p| _INTL("{1}: friendship {2}/255, Hidden Power {3}", p.name, p.happiness.to_i, typeName(hiddenPowerType(p))) }.join("\n"))
        end
      end

      def self.menu
        loop do
          cmd = DBRejuvenating.chooseFromList(_INTL("Hidden stats\nValues the game keeps hidden (read only: nothing is changed)."),
            [_INTL("Karma & reputation"), _INTL("Relationships"), _INTL("Party: friendship & Hidden Power")])
          break if cmd < 0
          case cmd
            when 0 then showKarma
            when 1 then showRelationships
            when 2 then showParty
          end
        end
      end
    end

    # Au premier niveau du menu (sans groupe), après les groupes
    registerEntry(:hidden_stats, order: 50, name: proc { _INTL("Hidden stats") },
      condition: proc { DBRejuvenating.enabled?(:hidden_stats) },
      effect: proc { DBRejuvenating::HiddenStats.menu })
  end
end
