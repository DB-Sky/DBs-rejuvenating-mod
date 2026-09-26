# =============================================================================
# DB's Rejuvenating Settings — MODULE 4 : Correctifs de support partiel
#
# 1) Nom technique de Floette Fleur Éternelle (export d'équipe / Showdown)
#    Utilities.rb#getMonFormName : pour FLABEBE/FLOETTE/FLORGES seuls les
#    index 0-4 ont une couleur → la forme "Eternal Flower" sortait "Floette-".
#    On renvoie "Floette-Eternal" (nom Showdown). Aucun autre cas n'est touché.
#
# 2) Icône de Méga-Floette : correctif GRAPHIQUE (pas de code), fourni dans
#    patch/Graphics/Icons/Pokemon/icon670.png (ligne 6 de la planche vide en V14).
# =============================================================================

if defined?(DBRejuvenating) && DBRejuvenating.enabled?(:fix_floette_export_name)
  unless defined?(dbRejuvenating_orig_getMonFormName)
    alias dbRejuvenating_orig_getMonFormName getMonFormName
  end

  def getMonFormName(mon, form = 0, gender = nil, returncustom: false)
    if mon == :FLOETTE
      begin
        f = form
        f = f.to_a[0] if f.is_a?(Range)
        f = $cache.pkmn[:FLOETTE].forms.invert[f] if f.is_a?(String)
        if f.is_a?(Numeric) && $cache.pkmn[:FLOETTE].forms[f] == "Eternal Flower"
          return "Floette-Eternal"
        end
      rescue
        # En cas de doute, comportement d'origine
      end
    end
    return dbRejuvenating_orig_getMonFormName(mon, form, gender, returncustom: returncustom)
  end
end
