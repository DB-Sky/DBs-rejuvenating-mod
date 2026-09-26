# =============================================================================
# DB's Rejuvenating Settings — MODULE 3 : Objets introuvables (méga/giga-gemmes,
# cristaux Z, objets de forme), débloqués par la progression.
#
# Audit local V14 : chaque objet a été cherché dans les 689 cartes, les
# événements communs, les boutiques, les mots de passe, les objets tenus
# sauvages et tous les scripts ; seuls ceux SANS source joueur sont listés.
# Règles (compatibles avec l'équilibrage) :
#   - Floettite (2e starter) : Floette Éternelle au palier de lien "Loyal" ;
#   - toute gemme/cristal d'un LÉGENDAIRE exige en plus le palier "Loyal"
#     (module 8) : le légendaire doit d'abord vous faire confiance ;
#   - sinon il faut POSSÉDER l'espèce concernée ;
#   - si un dresseur du jeu utilise l'objet : le battre (raccourci "12 badges"
#     optionnel : CONFIG badge_fallback, désactivé par défaut).
# L'UTILISATION reste gérée par le jeu : Méga/Z exigent l'anneau que le
# scénario donne (et reprend) lui-même. Aucun anneau n'est donné ici.
# Exclus volontairement : ZYGARDITE (aucun sprite de Méga-Zygarde en V14),
# UNOWNCREST / INTERCEPTZ2 (aucun effet codé dans le jeu).
# =============================================================================

if defined?(DBRejuvenating) && DBRejuvenating.enabled?(:progression_items)
  module DBRejuvenating
    module ProgressionItems
      def self.withHolders(sp, holders)
        alts = holders.map { |t, n| [:beat, t, n] }
        # Raccourci "12 badges" seulement si activé dans CONFIG (désactivé par défaut)
        alts += [[:badges, 12]] if DBRejuvenating.enabled?(:badge_fallback)
        return [[:all, [[:own, sp], [:any, alts]]]]
      end

      # Ajoute l'exigence de lien "Loyal" (palier 2) à chaque condition
      def self.loyal(species_list, conds)
        bond = species_list.length == 1 ? [:bond, species_list[0], 2] : [:any, species_list.map { |sp| [:bond, sp, 2] }]
        return conds.map { |c| [:all, [c, bond]] }
      end

      def self.build
        own = lambda { |sp| [[:own, sp]] }
        stones = [
          # --- 2e starter ---
          [:FLOETTITE,    [[:bond, :FLOETTE, 2]]],
          [:MAGEARNITE,   loyal([:MAGEARNA], own.call(:MAGEARNA))],
          # --- Utilisées par des dresseurs du jeu ---
          [:ABSOLITEZ,    withHolders(:ABSOL, [[:CANDIDGIRL2, "Erin"]])],
          [:APPLETUNITE,  withHolders(:APPLETUN, [[:SPIRITJENNER, "Jenner"]])],
          [:DIANCITE,     loyal([:DIANCIE], withHolders(:DIANCIE, [[:GANGLEADER, "Karrina"]]))],
          [:CORVIKNITE,   withHolders(:CORVIKNIGHT, [[:LITTLEDEMON, "M31"], [:OUTCAST, "Ren"], [:ROGUEHERO, "Hazuki"], [:PROTECTOR_HAZUKI, "Hazuki"]])],
          [:EXCADRITE,    withHolders(:EXCADRILL, [[:XENPERCIVAL, "Percival"]])],
          [:GRIMMSNARLITE,withHolders(:GRIMMSNARL, [[:TRAINER_AXEL, "Axel"], [:LEADER_ALICE, "Princess Alice"]])],
          [:HATTERENITE,  withHolders(:HATTERENE, [[:XENDICTATOR, "Madame X"], [:MSHOGUN, "Madame Shogun"], [:MSHOGUN2, "Madame Shogun"], [:LEADER_PUPPET2, "Neon"]])],
          [:HEATRANITE,   loyal([:HEATRAN], withHolders(:HEATRAN, [[:XENPERCIVAL, "Percival"]]))],
          [:MELMETALITE,  loyal([:MELMETAL], withHolders(:MELMETAL, [[:XENPERCIVAL, "Percival"]]))],
          [:METAGROSSITE, withHolders(:METAGROSS, [[:INTERCEPTOR, "Crescent"], [:RUINEDWAR, "Tahar"]])],
          [:SALAMENCITE,  withHolders(:SALAMENCE, [[:TRAINER_AERO, "Aero"]])],
          [:SCRAFTINITE,  withHolders(:SCRAFTY, [[:TRAINER_ALAIN, "Alain"]])],
          [:SNORLAXITE,   withHolders(:SNORLAX, [[:CUEBALL, "Art"], [:ENIGMA_2, "Melia"], [:TREAT_03, "01001101"]])],
          [:STARMINITE,   withHolders(:STARMIE, [[:XENNASTASIA, "Nastasia"]])],
          # --- Personne ne les utilise : posséder l'espèce ---
          [:BAXCALIBRITE, own.call(:BAXCALIBUR)],
          [:CRABOMINITE,  own.call(:CRABOMINABLE)],
          [:EELEKTROSSITE,own.call(:EELEKTROSS)],
          [:FLAPPLETITE,  own.call(:FLAPPLE)],
          [:GOLISOPITE,   own.call(:GOLISOPOD)],
          [:HAWLUCHANITE, own.call(:HAWLUCHA)],
          [:LATIASITE,    loyal([:LATIAS], own.call(:LATIAS))],
          [:LATIOSITE,    loyal([:LATIOS], own.call(:LATIOS))],
          [:LUCARIONITEZ, own.call(:LUCARIO)],
          [:MEWTWONITEX,  loyal([:MEWTWO], own.call(:MEWTWO))],
          [:MEWTWONITEY,  loyal([:MEWTWO], own.call(:MEWTWO))],
          [:PYROARITE,    own.call(:PYROAR)],
          [:RAICHUNITEX,  own.call(:RAICHU)],
          [:RAICHUNITEY,  own.call(:RAICHU)],
          [:SCOVILLAINITE,own.call(:SCOVILLAIN)],
          [:TATSUGIRINITE,own.call(:TATSUGIRI)],   # nécessite le correctif du module 5
          [:URSHIFITE,    loyal([:URSHIFU], own.call(:URSHIFU))],
          [:ZERAORITE,    loyal([:ZERAORA], own.call(:ZERAORA))],
          [:DARKRANITE,   loyal([:DARKRAI], own.call(:DARKRAI))],      # objet ajouté par le module 5
          [:GARCHOMPITEZ, own.call(:GARCHOMP)],     # objet ajouté par le module 5
        ]
        zcrystals = [
          [:EEVIUMZ,        withHolders(:EEVEE, [[:LASS, "Alexa"]])],
          [:INCINIUMZ,      withHolders(:INCINEROAR, [[:TRAINER_AERO, "Aero"]])],
          [:KOMMONIUMZ,     withHolders(:KOMMOO, [[:SPIRITJENNER, "Jenner"], [:ASPECTVITUS, "Vitus"]])],
          [:MIMIKIUMZ,      withHolders(:MIMIKYU, [[:XENHORDE, "Squad 03"]])],
          [:PIKANIUMZ,      own.call(:PIKACHU)],
          [:SNORLIUMZ,      own.call(:SNORLAX)],
          [:MEWNIUMZ,       loyal([:MEW], own.call(:MEW))],
          [:MARSHADIUMZ,    loyal([:MARSHADOW], own.call(:MARSHADOW))],
          [:TAPUNIUMZ,      loyal([:TAPUKOKO, :TAPULELE, :TAPUBULU, :TAPUFINI], [[:own_any, [:TAPUKOKO, :TAPULELE, :TAPUBULU, :TAPUFINI]]])],
          [:SOLGANIUMZ,     loyal([:SOLGALEO], own.call(:SOLGALEO))],
          [:LUNALIUMZ,      loyal([:LUNALA], own.call(:LUNALA))],
          [:ULTRANECROZIUMZ,loyal([:NECROZMA], [[:all, [[:own, :NECROZMA], [:own_any, [:SOLGALEO, :LUNALA]]]]])],
        ]
        # v1.3.1 : Orbes Rouge/Bleu, Épée/Bouclier Rouillés et Vase Scellé exigent le
        # palier Loyal, comme la gemme du légendaire (choix du joueur ; fusions inchangées).
        formitems = [
          [:GRACIDEA,        own.call(:SHAYMIN)],
          [:REVEALGLASS,     [[:own_any, [:TORNADUS, :THUNDURUS, :LANDORUS, :ENAMORUS]]]],
          [:DNASPLICERS,     [[:all, [[:own, :KYUREM], [:own_any, [:RESHIRAM, :ZEKROM]]]]]],
          [:NSOLARIZER,      [[:own_all, [:NECROZMA, :SOLGALEO]]]],
          [:NLUNARIZER,      [[:own_all, [:NECROZMA, :LUNALA]]]],
          [:PRISONBOTTLE,    loyal([:HOOPA], own.call(:HOOPA))],
          [:GRISEOUSORB,     own.call(:GIRATINA)],
          [:GRISEOUSCORE,    own.call(:GIRATINA)],
          [:ADAMANTORB,      own.call(:DIALGA)],
          [:ADAMANTCRYSTAL,  own.call(:DIALGA)],
          [:LUSTROUSORB,     own.call(:PALKIA)],
          [:LUSTROUSGLOBE,   own.call(:PALKIA)],
          [:REDORB,          loyal([:GROUDON], own.call(:GROUDON))],
          [:BLUEORB,         loyal([:KYOGRE], own.call(:KYOGRE))],
          [:RUSTEDSWORD,     loyal([:ZACIAN], own.call(:ZACIAN))],
          [:RUSTEDSHIELD,    loyal([:ZAMAZENTA], own.call(:ZAMAZENTA))],
          [:SCROLLOFDARKNESS,own.call(:KUBFU)],
          [:SCROLLOFWATERS,  own.call(:KUBFU)],
          [:REINSOFUNITY,    [[:all, [[:own, :CALYREX], [:own_any, [:GLASTRIER, :SPECTRIER]]]]]], # effet ajouté par le module 5
          [:WELLSPRINGMASK,  own.call(:OGERPON)],
          [:HEARTHFLAMEMASK, own.call(:OGERPON)],
          [:CORNERSTONEMASK, own.call(:OGERPON)],
        ]
        return { :stones => stones, :z => zcrystals, :forms => formitems }
      end

      def self.key(item)
        return ("item_" + item.to_s.downcase).to_sym
      end

      # Compatibilité v1 (clés "stone_XXX")
      def self.taken?(it)
        return DBRejuvenating.claimed?(key(it)) || DBRejuvenating.claimed?(("stone_" + it.to_s).to_sym)
      end

      def self.available(list)
        # On ne garde que les objets réellement définis (ou ajoutés par le module 5)
        return list.select { |it, c| ($cache.items.key?(it) rescue false) }
      end

      def self.label(it, cond)
        name = (getItemName(it) rescue it.to_s)
        return _INTL("[taken] ") + name if taken?(it)
        return _INTL("[READY] ") + name if DBRejuvenating.unlocked?(cond)
        return _INTL("[locked] ") + name
      end

      def self.menu(list, title)
        loop do
          items = available(list)
          labels = items.map { |it, c| label(it, c) }
          ready = items.select { |it, c| !taken?(it) && DBRejuvenating.unlocked?(c) }
          labels.push(_INTL("Take all ready items ({1})", ready.length))
          cmd = DBRejuvenating.chooseFromList(title, labels)
          break if cmd < 0
          if cmd == items.length
            ready.each { |it, c| break unless DBRejuvenating.giveItemOnce(key(it), it, 1) }
            next
          end
          it, cond = items[cmd]
          if taken?(it)
            Kernel.pbMessage(_INTL("You already took this item."))
          elsif !DBRejuvenating.unlocked?(cond)
            Kernel.pbMessage(_INTL("Locked.\nHow to unlock it:\n{1}", DBRejuvenating.hint(cond)))
          else
            DBRejuvenating.giveItemOnce(key(it), it, 1)
          end
        end
      end
    end

    registerEntry(:mega_stones, order: 20, group: :items, name: proc { _INTL("Mega/Giga Stones") },
      effect: proc { DBRejuvenating::ProgressionItems.menu(DBRejuvenating::ProgressionItems.build[:stones], _INTL("Mega and Giga Stones the base game never gives you.")) })
    registerEntry(:z_crystals, order: 30, group: :items, name: proc { _INTL("Z-Crystals") },
      effect: proc { DBRejuvenating::ProgressionItems.menu(DBRejuvenating::ProgressionItems.build[:z], _INTL("Z-Crystals the base game never gives you.")) })
    registerEntry(:form_items, order: 40, group: :items, name: proc { _INTL("Form items") },
      effect: proc { DBRejuvenating::ProgressionItems.menu(DBRejuvenating::ProgressionItems.build[:forms], _INTL("Form-change items the base game never gives you.")) })
  end
end
