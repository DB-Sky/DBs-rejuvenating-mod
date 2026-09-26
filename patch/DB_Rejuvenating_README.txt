DB's Rejuvenating Settings v1.3.3 — mod for Pokémon Rejuvenation V14 (checked against 14.0.24)
==============================================================================================
*** STABLE RELEASE — READY TO SHARE ***
Share only the "patch" folder (see INSTALL). Tested against the game's own data:
1789 automated checks + a real save. Legendaries unlock step by step, by power
(see LEGENDARY PACING).
(formerly "DB's Rejuvenating", and before that "DB's Rejuthingy Patch")

The full rules are also explained in game: Pause menu > DB Rejuv Settings > Guide.

IN-GAME MENU (Pause > DB Rejuv Settings)
  Guide            how every rule works (unread pages in yellow; "NEW" until all are read)
  Pokémon >        Second starter | Legendary unlocks | Missed legendaries |
                   Bonds & team budget
  Items >          Candy shop | Mega/Giga Stones | Z-Crystals | Form items
  Trials >         Guardian Trials | Ultimate Trial | Trial record
  Hidden stats     values the game keeps hidden (read only): Karma, relationships,
                   Grand Dream City reputation, exact friendship, Hidden Power type
  My progress      your numbers right now: chapter, level cap, tickets, candy prices,
                   extra enemy battle items

WHAT IT DOES
  - Second starter: Eternal Flower Floette (learns Light of Ruin at the Trusting bond tier).
  - Legendaries, mythicals, Ultra Beasts and Paradox Pokémon that V14 never lets you obtain
    become claimable through story progress, with TICKETS, GUARDIAN TRIALS and BOND.
  - Missed legendaries: a second chance (1 ticket) for legendaries the game gives,
    if you missed them for good. Never a duplicate of one you caught.
  - Trials: Chapter Trials (fight your own reflection), Guardian Trials (competitive
    teams) and an end-game Ultimate Trial. All earn tickets or legendaries.
  - Balance: bond tiers, a team budget, and extra items for enemy trainers when you
    use the mod's legendaries (Normal mode only).
  - Mega/Giga stones, Z-Crystals and form items with no V14 source become claimable
    (own the species; beat the trainer who uses the item; legendaries must be Loyal).
  - Candy shop (Rare Candy + Reverse Candy) with rising prices that reset at each chapter
    and badge; Rare Candy can NEVER raise a Pokémon above the badge level cap.
  - Data fixes: Darkranite and Garchompite Z, Tatsugirinite, Reins of Unity effect,
    Mega Floette icon, "Floette-Eternal" export name.

CANDY SHOP (Pause > DB Rejuv Settings > Items > Candy shop)
  Rare Candy:    10 at $100 each, then 10 at $200 ... then 10 at $1000 each (100 candies),
                 then sold out.
  Reverse Candy: 10 at $10 each, then 10 at $20 ... then 10 at $100 each (100 candies),
                 then sold out. (Game item: -1 level per use.)
  Prices go back to the start and the stock refills at each NEW CHAPTER or NEW BADGE
  (both at the same moment = one reset). Stored in the save.
  With all 18 badges AND the Virtual League champion beaten: both free and unlimited.
  Rare Candy still never goes above the badge level cap, even when free.
  Candies from this shop (bought or free) cannot be sold to other shops; candies found
  in the game stay sellable. (Moving them to the PC or a held item does not change that.)

MISSED LEGENDARIES (Pause > DB Rejuv Settings > Pokémon > Missed legendaries)
  A second chance for the ~40 legendaries the GAME gives (one-time wild battles, gifts,
  Chapter 16 routes) when you missed them for good. 1 ticket each, at your level cap.
  - Battled in the wild but fainted/fled without capture (recorded since 1.2.4):
    available from the next chapter.
  - Never met (or before 1.2.4): available only after 18 badges + Virtual League champion.
  - Caught normally in the game: never offered (no duplicates).

LEGENDARY PACING (v1.3.3, CONFIG min_badges_by_power / _restricted / _arceus)
  No legendary from this mod can be claimed before a minimum number of badges,
  based on its POWER (total base stats), so the weaker ones come first and the
  strong ones later (no legendary rush in the middle of the game):
    under 570 (Loyal Three, Kubfu, Poipole)                 4 badges
    570-579 (Tapus, Ruinous quartet, Ultra Beasts...)       6 badges
    580-599 (Swords of Justice, Regieleki/Regidrago...)     7 badges
    600-669 (Mew, Darkrai, Jirachi, Heatran...)             8 badges
    670+ (Regigigas) and all Restricted legendaries        10 badges
    Arceus                                                 12 badges
  This is only a MINIMUM: some legendaries ask for more (e.g. Koraidon/Miraidon 11).
  The condition shown in game is always the full requirement (minimum included).
  Missed legendaries (given by the game itself) keep their own rules.

TICKETS
  Earned: 1 per badge, 1 per Chapter Trial won, 1 per Rift boss defeated (13),
  1 for the Virtual League champion, 1 per Ultimate Trial victory. Each legendary
  claimed costs 1 ticket (76 legendaries): choose!

ULTIMATE TRIAL (end game; Pause > DB Rejuv Settings > Trials > Ultimate Trial)
  Opens when ALL Chapter Trials 2-16 were WON, you own all 18 badges and you beat the
  Virtual League champion. A lost/declined/missed Chapter Trial closes it for that save.
  3 rounds in a row vs your reflection (your team +10% EXP) with 2 healing items + X Speed,
  X Attack, X Sp. Atk: 1 vs 1 (single), 2 vs 2 (double), 3 vs 3 (single battle with
  3 Pokémon each: Rejuvenation has no triple battles). You pick your Pokémon each round,
  no substitutes. A Pokémon (unique ID) fights in only ONE round, and once it has fought
  in the Ultimate Trial it can NEVER enter it again (the reflection follows the same rule).
  Repeatable as long as you keep winning: 1 ticket per victory, 6 new Pokémon each time.
  Your first defeat (or quitting / closing the game after the first battle) closes it
  for this save; recorded in the save AND DB_Rejuvenating_trials.dat, then auto-save.
  Not in Story mode.

GUARDIAN TRIALS (Restricted legendaries only: Mewtwo, Lugia, Ho-Oh, Kyogre, Groudon,
  Rayquaza, Dialga, Palkia, Giratina, Reshiram, Zekrom, Kyurem, Xerneas, Cosmog, Zacian,
  Zamazenta, Eternatus, Calyrex, Koraidon, Miraidon, Terapagos)
  A Guardian Spectre fields a real competitive team built around that legendary, all at
  your level cap. No stat boosts. You cannot bring legendaries from this mod. Losing costs
  nothing; retry anytime. No EXP. Not available in Story (easy) mode.

CHAPTER TRIALS (from Chapter 2)
  At the first safe moment after a new chapter starts: optional save, then the offer.
  You fight your own reflection (dark sprite): your team +10% EXP (no evolution, no new
  move) with upgraded held items. Win = 1 ticket. ONCE per chapter and per save: the choice
  is written in your save AND in DB_Rejuvenating_trials.dat (save folder), then the game
  auto-saves. Reloading an older save does not bring it back. Not in Story mode.

BOND (legendaries + Eternal Floette)
  Tiers (never lost):
    Trusting  friendship 70  +  5 bond points   always obeys
    Loyal     friendship 150 + 12 bond points   unlocks its Mega Stone / Z-Crystal
    Devoted   friendship 190 + 20 bond points   optional new nature (stat changes shown)
    Bonded    friendship 220 + 30 bond points (incl. 1 special point): optional new
              ability, permanent "Bonded with <you>" mark, 1 point cheaper in the budget
  Bond points (30 max): +1 when THIS Pokémon KOs a foe in a trainer battle (1 per
  battle, 29 max from KOs), +1 per special point.
  Special point: a Gym badge earned right after a battle it fought in, or the Virtual
  League champion beaten with it in the team (swapping it in from the PC afterwards
  does not count).
  Saves from 1.2.4 or older: Bonded Pokémon stay Bonded.
  Legendaries received from this mod ignore orders 25% of the time while still at the
  Wild tier (CONFIG wild_disobey_percent).

TEAM BUDGET (legendaries received from this mod only)
  Cost: Restricted and Arceus 3 (Bonded 2), other legendary/mythical 2 (Bonded 1),
  Ultra Beast/Paradox 1 (Bonded or not), Eternal Floette 1.
  Budget by chapter: 1-2: 2 | 3-5: 3 | 6-8: 4 | 9-11: 5 | 12-14: 6 | 15-16: 7.
  Over budget: the extra ones (last in party order) will not obey. Never removed, never
  blocking a battle.

BOSS KIT (Normal mode; off in Story and with "noitems")
  A Gym Leader, Elite or Champion (incl. Virtual League Elite/Champion) with NO healing
  item in the base game gets 2 healing items (same tier as below) + a Full Heal + X Speed
  + X Attack or X Sp. Atk (whichever fits its team); from 15 badges the X items are the
  game's "3" versions (+3 stages). 62 of the 94 leader/elite teams in V14 had none.
  Never more than 5 items added to a boss in total.

ENEMY ITEMS (Normal mode only; off in Story and with "noitems")
  With Pokémon from this mod in your party (legendaries or Eternal Floette), each
  enemy trainer gets extra battle items, in this order: potion (by level cap), Full
  Heal, X Defense or X Sp. Def (against the side your legendaries attack with).
  How many: 1 item per 2 points of their full team cost (Bonded discount not counted,
  rounded up), at most 3 per trainer and 5 per boss in total (no item spam).
  A 600+ stat legendary used before 12 badges counts as 1 extra point.
  The game's own AI decides when an item is worth using. No stat or level boosts.

SPECIAL UNLOCKS (found in the game files)
  Rayquaza  sculptor quest (Goldenleaf Town artist -> Sapphire Museum, Kristiline Town),
            pick the Rayquaza statue (+ 10 badges); other statue: battle both Kyogre
            and Groudon (+ 11 badges). Then its Guardian Trial.
  Zacian    beat Princess Alice (+ 10 badges; or 13 badges if fought before installing).
  Zamazenta beat Prince Allen (+ 10 badges; or 13 badges if fought before installing).
  Calyrex   beat Flora and Florin (+ 10 badges; or 11 badges if fought before installing).
  Koraidon  own an Ancient Paradox Pokémon (+ 11 badges).
  Miraidon  own a Future Paradox Pokémon (+ 11 badges).
            (Restricted legendaries: Guardian Trial required.)
  Magearna  beat Saki at the Axis Factory gym (+ 8 badges), or 12 badges.
  Others    Jirachi, Zeraora, Zarude, Hoopa 8 badges; Ogerpon 7; Kubfu 4.
  Diancie   given by the story (Karrina's bag, Game Show). Diancite: own Diancie, beat
            Karrina, Diancie Loyal.

INSTALL
  Copy the "patch" folder into the game folder (merge).
  Result: <game>\patch\Mods\DB_Rejuvenating_*.rb (12 files)
          <game>\patch\Graphics\Icons\Pokemon\icon670.png
          <game>\patch\Graphics\Characters\trainer9101.png ... trainer9107.png
  UPGRADING FROM 1.2.x ("DB's Rejuvenating"): just copy the new files over the old ones.
  File names and save data did not change; Pokémon received from older versions are
  still recognised (bond, team budget).
  UPGRADING FROM "DB's Rejuthingy Patch": delete every patch\Mods\DB_Rejuthingy_*.rb.
  Play on several devices? Put the SAME version on all of them.

FILES
  Mods\DB_Rejuvenating_Core.rb             config, save state, rules, tickets (REQUIRED)
  Mods\DB_Rejuvenating_Data_Guardians.rb   Guardian Trial teams (sources listed inside)
  Mods\DB_Rejuvenating_Mod1_RareCandy.rb   candy shop (Rare + Reverse Candy) + strict level cap
  Mods\DB_Rejuvenating_Mod2_Pokemon.rb     second starter, legendary unlocks, missed legendaries
  Mods\DB_Rejuvenating_Mod3_Items.rb       stones, Z-Crystals, form items
  Mods\DB_Rejuvenating_Mod4_Fixes.rb       "Floette-Eternal" export name
  Mods\DB_Rejuvenating_Mod5_DataFixes.rb   Darkranite, Garchompite Z, Tatsugirinite, Reins of Unity
  Mods\DB_Rejuvenating_Mod6_BattleLog.rb   trainers/Rift bosses/league beaten, badge special points
  Mods\DB_Rejuvenating_Mod7_Menu.rb        Pause menu, groups, My progress, Bonds, Trial record, Guide
  Mods\DB_Rejuvenating_Mod8_Bond.rb        bond, team budget, obedience, enemy items, boss kit
  Mods\DB_Rejuvenating_Mod9_Trials.rb      Guardian, Chapter and Ultimate Trials
  Mods\DB_Rejuvenating_Mod10_HiddenStats.rb Hidden stats menu (read only)

CONFIG
  Edit the CONFIG block at the top of DB_Rejuvenating_Core.rb, then restart the game.
  Every rule has its own switch (tickets, bond, team_budget, enemy_items, boss_kit,
  guardian_trials, chapter_trials, chapter_trial_autosave, ultimate_trial,
  wild_disobey_percent...).
  Never disable the Core while other modules are active.

UNINSTALL
  1. First sell/toss any Darkranite or Garchompite Z (bag and held items).
  2. Unfuse any Calyrex fused with the Reins of Unity.
  3. Delete patch\Mods\DB_Rejuvenating_*, patch\Graphics\Icons\Pokemon\icon670.png and
     patch\Graphics\Characters\trainer9101-9107.png.
  Nothing in the base game is modified; saves stay loadable (bond data stays harmlessly
  on the Pokémon).

LOG
  DB_Rejuvenating_log.txt in your save folder (or the game folder). It is created on
  each player's own computer: do NOT include it (or DB_Rejuvenating_trials.dat, or any
  save) when sharing the mod. Share only the "patch" folder.

HIDDEN STATS (Pause > DB Rejuv Settings > Hidden stats) — read only, never changes anything
  Karma (game variable 129), relationship points with ~50 characters (only non-zero
  ones shown), Grand Dream City reputation, Espurr/Growlithe sidequest friendship,
  and for each party Pokémon: exact friendship (0-255) and Hidden Power type (in
  Rejuvenation it comes from a hidden ID, not from IVs). IVs/EVs are already on the
  game's Summary screen, so they are not repeated.

CHANGELOG
  1.3.3  Legendaries unlock step by step by POWER: 4 / 6 / 7 / 8 / 10 badges
         (under 570 / 570 / 580 / 600 / 670+ stats), Restricted 10, Arceus 12.
         Weaker ones early, strong ones later: no legendary rush mid-game.
  1.3.2  Badge minimums lowered: 4 / 5 / 8 (was 6 / 8 / 11); story-based unlocks
         3-4 badges earlier too (Koraidon/Miraidon 11, Zacian/Zamazenta/Calyrex 8...).
         New "Hidden stats" menu. Unlock conditions show ONE badge number (the real
         requirement) instead of two ("15 badges AND 11 badges"); duplicate trainer
         names removed from conditions; clearer "one of (...)" lists.
  1.3.1  Texts proofread (enemy "battle items", Eternal Floette counts for enemy
         items, menu paths). Arceus (720 total stats) costs 3 points (2 when Bonded) and needs 11 badges,
         like a Restricted legendary (no extra trial). Red/Blue Orb, Rusted
         Sword/Shield and Prison Bottle need that legendary at the Loyal bond tier,
         like its Mega Stone. Enemy extra items varied (potion / Full Heal / defensive
         X item) and capped (3 per trainer, 5 per boss). 600+ stat legendary before 12
         badges: +1 point for enemy items. Boss kit: + Full Heal, "3" X items from 15
         badges.
  1.3.0  STABLE RELEASE, ready to share. Legendaries paced like the base game (minimum
         badges per category). Lugia fixed (its condition was impossible in V14: now
         own Articuno + Zapdos + Moltres). Eternal Floette learns Light of Ruin at the
         Trusting tier instead of from the start (it was stronger than a fully
         evolved starter at 0 badges).
  1.2.5  New bond tier "Devoted" (nature change; ability stays at Bonded). Bond points
         up to 30; special points count as bond points. Restricted legendaries that
         only needed badges now follow their story (never earlier than before).
         Guide: each unread page shown in yellow, Guide marked until all are read;
         "What's new" is now "Changelog", at the end. Intense mode no longer mentioned.
  1.2.4  Ultra Beasts and Paradox Pokémon cost 1 point in the team budget (Bonded or
         not). Candies from the candy shop can no longer be sold to other shops.
         New "Missed legendaries": second chance for legendaries the game gives,
         when missed for good (no duplicates with what you caught).
         All in-game texts rewritten (clearer, line breaks); "(NEW)" now shown as plain
         text in the Pause menu (the Pause menu cannot show colours).
  1.2.3  Menu reorganised into groups (Pokémon / Items / Trials). "Status" became
         "My progress", "Team & bonds" became "Bonds & team budget" (with the team
         budget), new "Trial record" and "Guardian Trials" shortcut. Guide rewritten
         to match the menu, with a "What's new" page; shown on top in yellow with
         "NEW" until opened after each update.
  1.2.2  Renamed "DB's Rejuvenating Settings" (display name only; pause menu entry
         "DB Rejuv Settings"). Rare Candy: free pack removed, new tiered candy shop
         ($100 -> $1000, 10 per tier, sold out after 100) + Reverse Candy shop ($10 -> $100),
         prices reset at each chapter or badge, free and unlimited after 18 badges +
         Virtual League champion.
  1.2.1  All 21 Guardian teams (real competitive teams, sources in
         DB_Rejuvenating_Data_Guardians.rb); Ultimate Trial: 1 ticket per victory,
         repeatable until the first defeat, a Pokémon that fought in it never returns;
         missing items replaced by an equivalent (or Sitrus Berry); boss kit; old
         "Rejuthingy" saves keep their progress; Mega Rayquaza guardian gets its ring;
         safer PC scan.
  1.2.0  Tickets, Guardian Trials, Chapter Trials (mirror), Ultimate Trial, bond tiers +
         ceremony, team budget, enemy healing items, boss kit, in-game Guide; legendary
         stones need Loyal bond.
  1.1.2  Renamed to "DB's Rejuvenating" (files, menu, log, save key). Public release.
  1.1.1  Only Eternal Floette is a start gift. Rayquaza (sculptor quest) and Magearna
         (Axis Factory) unlock by progression; Diancie gift removed (the story gives it);
         Diancite/Magearnite tied to their Pokémon; 12-badge shortcut off by default.
  1.1.0  Progression unlocks, strict Rare Candy cap, early Mega Ring removed,
         missing items/forms added.
  1.0.0  First full version (gifts, stones, Rare Candy, fixes, menu).
  0.1.0  Original stub.
