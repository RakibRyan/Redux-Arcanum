-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--            TAGS
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

SMODS.Tag { -- Elemental
    key = 'elemental',
    -- loc_txt = {
    --     name = 'Elemental Tag',
    --     text = {
    --         "Gives a free",
    --         "{C:alchemical}Mega Alchemy Pack"
    --     }
    -- },

    config = { type = 'new_blind_choice' },

    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.ORANGE, function()
                local key = 'p_ReduxArcanum_alchemy_7'
                
                -- Queue the pack opening safely inside an event
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    blockable = true,
                    blocking = true,
                    func = function()
                        -- If the game is currently showing ANY booster pack screen, wait!
                        if G.STATE == G.STATES.TAROT_PACK or 
                           G.STATE == G.STATES.PLANET_PACK or 
                           G.STATE == G.STATES.SPECTRAL_PACK or
                           G.STATE == G.STATES.STANDARD_PACK or
                           G.STATE == G.STATES.BUFFOON_PACK then
                            return false -- Tells the event manager to try again next frame
                        end
                        
                        -- Safe to spawn now that the screen is clear
                        local card = Card(G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2,
                            G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2, G.CARD_W * 1.27, G.CARD_H * 1.27, G.P_CARDS.empty,
                            G.P_CENTERS[key], { bypass_discovery_center = true, bypass_discovery_ui = true })
                        card.cost = 0
                        card.from_tag = true
                        G.FUNCS.use_card({ config = { ref_table = card } })
                        card:start_materialize()
                        return true
                    end
                }))
                
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end,

    pos = { x = 0, y = 0 },
    min_ante = 2,
    atlas = 'ca_tag_elemental'
}

--  Bunco makes its own change to the boss tag, which this patch would break.
if (not SMODS.Mods["Bunco"] or not SMODS.Mods["Bunco"].can_load) then
    SMODS.Tag:take_ownership('boss', {
        config = {},
        apply = function(self, tag, context)
            if context.type == 'new_blind_choice' and G.STATE == G.STATES.BLIND_SELECT then
                -- local lock = self.ID
                -- G.CONTROLLER.locks[lock] = true
                tag:yep('+', G.C.GREEN,function() 
                    G.from_boss_tag = true
                    G.FUNCS.reroll_boss()
                    
                    -- G.E_MANAGER:add_event(Event({func = function()
                    --     G.E_MANAGER:add_event(Event({func = function()
                    --         G.CONTROLLER.locks[lock] = nil
                    --     return true; end}))
                    -- return true; end}))

                    return true
                end)
                self.triggered = true
            end
        end
    }, true)
end
