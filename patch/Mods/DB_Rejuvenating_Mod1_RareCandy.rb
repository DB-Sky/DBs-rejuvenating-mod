# =============================================================================
# DB's Rejuvenating Settings — MODULE 1 : boutique de bonbons + plafond strict
#
# Boutique (menu Pause > DB Rejuv Settings > Candy shop) :
#   - Rare Candy    : 10 à 100, puis 10 à 200 ... 10 à 1000 (100 bonbons), puis épuisé
#   - Reverse Candy : 10 à 10,  puis 10 à 20  ... 10 à 100  (100 bonbons), puis épuisé
#     (objet du jeu :REVERSECANDY, -1 niveau par utilisation)
#   - Les prix repartent du début à chaque nouveau chapitre OU nouveau badge
#     (s'ils arrivent au même moment, c'est une seule remise à zéro).
#   - 18 badges + champion de la Ligue Virtuelle battu : gratuit et illimité.
#   Le compteur est dans la sauvegarde (recharger une vieille sauvegarde rend
#   aussi l'argent de cette sauvegarde : pas d'abus possible).
#   v1.2.4 : les bonbons ACHETÉS (ou reçus gratuitement) ici ne peuvent pas être
#   revendus en boutique (le jeu rachète un Rare Candy 2400 !). On compte les
#   bonbons "verrouillés" ; en boutique, seuls ceux au-delà de ce nombre se vendent.
#   Les bonbons trouvés dans le jeu restent vendables. Le compteur baisse tout seul
#   quand les bonbons sont utilisés ou jetés (plafonné à ce que vous possédez :
#   Sac + PC + objets tenus), donc déposer au PC ou faire tenir ne contourne rien.
#
# Constat local : Rejuvenation plafonne DÉJÀ au niveau LEVELCAPS[badges]
#   - l'EXP de combat (Battle.rb, "Rejuv-style Level Cap"),
#   - les Bonbons EXP (Utilities.rb, LevelLimitExpGain),
#   - la Pension (DayCare.rb).
# Seul le Rare Candy vanilla (ItemEffects.rb) ignore ce plafond. Ce module
# remplace son gestionnaire par une copie identique qui respecte le plafond.
# Le plafond s'applique aussi quand les bonbons deviennent gratuits.
# =============================================================================

if defined?(DBRejuvenating) && DBRejuvenating.enabled?(:rare_candy)
  module DBRejuvenating
    module RareCandy
      KINDS = {
        :rare    => { :item => :RARECANDY,    :prices => :rare_candy_prices },
        :reverse => { :item => :REVERSECANDY, :prices => :reverse_candy_prices },
      }

      def self.available?(kind)
        return false if kind == :reverse && !DBRejuvenating.enabled?(:reverse_candy_shop)
        return ($cache.items[KINDS[kind][:item]] rescue nil) != nil
      end

      def self.itemName(kind)
        return (getItemName(KINDS[kind][:item]) rescue KINDS[kind][:item].to_s)
      end

      def self.tierSize
        n = DBRejuvenating.cfg(:candy_tier_size).to_i
        return n > 0 ? n : 10
      end

      def self.prices(kind)
        p = DBRejuvenating.cfg(KINDS[kind][:prices])
        return p.is_a?(Array) ? p.map { |x| [x.to_i, 0].max } : []
      end

      def self.stock(kind)
        return prices(kind).length * tierSize
      end

      # Gratuit et illimité : 18 badges ET champion de la Ligue Virtuelle battu
      def self.free?
        return false unless DBRejuvenating.enabled?(:candy_free_after_league)
        st = DBRejuvenating.state
        return false unless st
        return DBRejuvenating.numBadges >= 18 && st[:league_won] == true
      end

      # Période actuelle = [chapitre, nombre de badges] ; tout changement = remise à zéro
      def self.period
        return [DBRejuvenating.chapter, DBRejuvenating.numBadges]
      end

      def self.shopState
        st = DBRejuvenating.state
        return nil unless st
        cs = st[:candy_shop]
        cur = period
        if !cs.is_a?(Hash) || cs[:period] != cur
          cs = { :period => cur, :rare => 0, :reverse => 0 }
          st[:candy_shop] = cs
        end
        return cs
      end

      def self.bought(kind)
        cs = shopState
        return cs ? cs[kind].to_i : 0
      end

      def self.left(kind)
        return [stock(kind) - bought(kind), 0].max
      end

      # Prix du prochain bonbon (nil = épuisé)
      def self.currentPrice(kind)
        b = bought(kind)
        return nil if b >= stock(kind)
        return prices(kind)[b / tierSize]
      end

      # Restant au prix actuel
      def self.leftAtPrice(kind)
        b = bought(kind)
        return 0 if b >= stock(kind)
        return tierSize - (b % tierSize)
      end

      # Coût total de qty bonbons à partir de l'état actuel
      def self.cost(kind, qty)
        b = bought(kind)
        ps = prices(kind)
        total = 0
        qty.times { |i| total += ps[(b + i) / tierSize].to_i }
        return total
      end

      # Quantité maximale achetable : stock restant, argent, place dans le sac
      def self.maxBuyable(kind)
        money = ($Trainer.money rescue 0).to_i
        room = [BAGMAXPERSLOT - $PokemonBag.pbQuantity(KINDS[kind][:item]).to_i, 0].max rescue 999
        n = 0
        total = 0
        b = bought(kind)
        ps = prices(kind)
        limit = [left(kind), room].min
        while n < limit
          p = ps[(b + n) / tierSize].to_i
          break if total + p > money
          total += p
          n += 1
        end
        return n
      end

      def self.label(kind)
        name = itemName(kind)
        return _INTL("{1}: FREE", name) if free?
        price = currentPrice(kind)
        return _INTL("{1}: sold out", name) unless price
        return _INTL("{1}: ${2} ({3} left at this price)", name, price, leftAtPrice(kind))
      end

      def self.chooseQty(text, max)
        return 0 if max < 1
        params = ChooseNumberParams.new
        params.setRange(1, max)
        params.setInitialValue(1)
        params.setCancelValue(0)
        return Kernel.pbMessageChooseNumber(text, params).to_i
      end

      def self.buy(kind)
        item = KINDS[kind][:item]
        name = itemName(kind)
        if free?
          room = [BAGMAXPERSLOT - $PokemonBag.pbQuantity(item).to_i, 0].max rescue 99
          qty = chooseQty(_INTL("How many {1} do you want? (free)", name), [room, 99].min)
          return if qty <= 0
          unless $PokemonBag.pbCanStore?(item, qty)
            Kernel.pbMessage(_INTL("Your Bag has no room for that many."))
            return
          end
          $PokemonBag.pbStoreItem(item, qty)
          addLocked(item, qty)
          Kernel.pbMessage(_INTL("You received {1} x{2}.\nCandies from this shop cannot be sold to other shops.", name, qty))
          DBRejuvenating.log("Boutique : #{item} x#{qty} (gratuit)")
          return
        end
        price = currentPrice(kind)
        unless price
          Kernel.pbMessage(_INTL("{1} is sold out.\nThe stock refills (and prices go back down) at your next new chapter or new badge.", name))
          return
        end
        max = maxBuyable(kind)
        if max < 1
          Kernel.pbMessage(_INTL("You don't have enough money.\nThe next one costs ${1}.", price))
          return
        end
        qty = chooseQty(_INTL("How many {1}?\nPrice now: ${2} each ({3} left at this price, {4} left in total).",
                              name, price, leftAtPrice(kind), left(kind)), max)
        return if qty <= 0
        total = cost(kind, qty)
        return unless Kernel.pbConfirmMessage(_INTL("Buy {1} x{2} for ${3}?", name, qty, total))
        # Revérification juste avant le paiement
        if total > $Trainer.money.to_i || !$PokemonBag.pbCanStore?(item, qty)
          Kernel.pbMessage(_INTL("The purchase was cancelled: not enough money or no room in your Bag.\nNothing was charged."))
          return
        end
        $Trainer.money -= total
        $PokemonBag.pbStoreItem(item, qty)
        addLocked(item, qty)
        shopState[kind] = bought(kind) + qty
        Kernel.pbMessage(_INTL("You bought {1} x{2} for ${3}.\nCandies from this shop cannot be sold to other shops.", name, qty, total))
        DBRejuvenating.log("Boutique : #{item} x#{qty} pour $#{total} (achetés cette période : #{bought(kind)})")
      end

      def self.shop
        loop do
          kinds = KINDS.keys.select { |k| available?(k) }
          cmds = kinds.map { |k| label(k) } + [_INTL("Exit")]
          head = if free?
            _INTL("Candy shop\nYou beat the Virtual League champion with all 18 badges: everything here is free!")
          else
            _INTL("Candy shop (your money: ${1})\nPrices go back down and the stock refills at each new chapter or new badge.", $Trainer.money.to_i)
          end
          choice = Kernel.pbMessage(head, cmds, cmds.length)
          break if choice.nil? || choice < 0 || choice >= kinds.length
          buy(kinds[choice])
        end
      end

      # --- Bonbons verrouillés (non revendables) --------------------------------
      LOCKABLE = [:RARECANDY, :REVERSECANDY] unless const_defined?(:LOCKABLE, false)

      def self.lockState
        st = DBRejuvenating.state
        return nil unless st
        st[:candy_locked] = {} unless st[:candy_locked].is_a?(Hash)
        return st[:candy_locked]
      end

      # Tous les exemplaires possédés : Sac + PC + objets tenus (équipe et boîtes)
      def self.totalOwned(item)
        n = ($PokemonBag.pbQuantity(item) rescue 0).to_i
        n += ($PokemonGlobal.pcItemStorage.pbQuantity(item) rescue 0).to_i
        ($Trainer.party rescue []).each { |p| n += 1 if p && p.item == item }
        begin
          st = $PokemonStorage
          if st
            (0...st.maxBoxes).each do |b|
              (0...st.maxPokemon(b)).each { |i| p = st[b, i]; n += 1 if p && p.item == item }
            end
          end
        rescue StandardError
        end
        return n
      end

      # Nombre verrouillé, jamais plus que ce qu'on possède (utilisés/jetés = libérés)
      def self.locked(item)
        ls = lockState
        return 0 unless ls
        n = [ls[item].to_i, totalOwned(item)].min
        ls[item] = n
        return n
      end

      def self.addLocked(item, qty)
        ls = lockState
        return unless ls && LOCKABLE.include?(item)
        ls[item] = ls[item].to_i + qty.to_i
      end

      # Quantité vendable depuis le Sac (on suppose les verrouillés dans le Sac : prudent)
      def self.sellable(item)
        return ($PokemonBag.pbQuantity(item) rescue 0).to_i unless LOCKABLE.include?(item)
        return [($PokemonBag.pbQuantity(item) rescue 0).to_i - locked(item), 0].max
      end

      # Plafond effectif : badges, puis limite absolue du jeu (100 + Extended_Max_Level)
      def self.effectiveCap
        absolute = [MAXIMUMLEVEL, 100 + ($game_variables[:Extended_Max_Level] rescue 0).to_i].min
        return [DBRejuvenating.levelCap, absolute].min
      end
    end

    registerEntry(:rare_candy_shop,
      order: 10, group: :items,
      name: proc { _INTL("Candy shop") },
      effect: proc { DBRejuvenating::RareCandy.shop }
    )
  end

  # ---------------------------------------------------------------------------
  # Vente en boutique : les bonbons verrouillés ne sont pas proposés
  # (PokemonMartScreen#pbSellScreen utilise PokemonMartAdapter#getQuantity/canSell?)
  # ---------------------------------------------------------------------------
  if defined?(PokemonMartScreen) && defined?(PokemonMartAdapter)
    class PokemonMartScreen
      unless method_defined?(:dbRejuvenating_orig_pbSellScreen)
        alias_method :dbRejuvenating_orig_pbSellScreen, :pbSellScreen
      end

      def pbSellScreen
        $dbRejuvenating_selling = true
        return dbRejuvenating_orig_pbSellScreen
      ensure
        $dbRejuvenating_selling = false
      end
    end

    class PokemonMartAdapter
      unless method_defined?(:dbRejuvenating_orig_getQuantity)
        alias_method :dbRejuvenating_orig_getQuantity, :getQuantity
        alias_method :dbRejuvenating_orig_canSell?, :canSell?
      end

      def getQuantity(item)
        if $dbRejuvenating_selling && DBRejuvenating::RareCandy::LOCKABLE.include?(item)
          return DBRejuvenating::RareCandy.sellable(item)
        end
        return dbRejuvenating_orig_getQuantity(item)
      end

      def canSell?(item)
        if $dbRejuvenating_selling && DBRejuvenating::RareCandy::LOCKABLE.include?(item) &&
           DBRejuvenating::RareCandy.sellable(item) <= 0
          return false
        end
        return dbRejuvenating_orig_canSell?(item)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Rare Candy respectant le plafond (même structure que ItemEffects.rb:780)
  # ---------------------------------------------------------------------------
  if DBRejuvenating.enabled?(:rare_candy_respect_cap)
    ItemHandlers::UseOnPokemon.add(:RARECANDY, proc { |item, pokemon, scene, amount = 1|
      cap = DBRejuvenating::RareCandy.effectiveCap
      if (pokemon.isShadow? rescue false) || noExp?
        scene.pbDisplay(_INTL("It won't have any effect."))
        next false, 0
      elsif pokemon.level >= cap
        # Comme en vanilla au niveau max : permet une évolution en attente, sans gagner de niveau
        newspecies = checkEvolution(pokemon)
        if newspecies
          pbFadeOutInWithMusic(99999) {
            pbCarryOutEvolution(pokemon, newspecies)
          }
          next true, 1
        end
        scene.pbDisplay(_INTL("{1} is already at the level cap (level {2}).\nEarn more badges to raise the cap.", pokemon.name, cap))
        next false, 0
      else
        amount = 1 if amount.nil? || amount < 1
        amount = cap - pokemon.level if cap - pokemon.level < amount
        pbChangeLevel(pokemon, pokemon.level + amount, scene)
        scene.pbHardRefresh
        next true, amount
      end
    })

    # -------------------------------------------------------------------------
    # Correctif d'un bug VANILLA (Items.rb:957 + ItemHandlers.triggerUseOnPokemon) :
    # via Équipe > Objet > Utiliser, le gestionnaire renvoie [false, 0] ; un
    # tableau est "vrai" en Ruby, donc le jeu SUPPRIMAIT le bonbon même sans effet.
    # Avec le plafond, ce cas devient fréquent : on ne garde que le booléen,
    # uniquement pour le Rare Candy (les autres objets restent intacts).
    # -------------------------------------------------------------------------
    class << ItemHandlers
      unless method_defined?(:dbRejuvenating_orig_triggerUseOnPokemon)
        alias_method :dbRejuvenating_orig_triggerUseOnPokemon, :triggerUseOnPokemon
      end

      def triggerUseOnPokemon(item, pokemon, scene)
        ret = dbRejuvenating_orig_triggerUseOnPokemon(item, pokemon, scene)
        ret = ret[0] if item == :RARECANDY && ret.is_a?(Array)
        return ret
      end
    end
  end
end
