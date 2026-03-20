-- blend mode :DISABLE, BLEND, ALPHAKEY, ADD, MOD
BuffTool = CreateFrame('FRAME')
BuffTool:SetPoint('CENTER', UIParent, 'CENTER', 0, -30)
BuffTool:SetWidth(300)
BuffTool:SetHeight(300)
BuffTool:RegisterEvent('COMBAT_TEXT_UPDATE')
BuffTool:RegisterEvent('PLAYER_DEAD')
BuffTool:RegisterEvent('CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS')
BuffTool:RegisterEvent('CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS')
BuffTool:RegisterEvent('CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS')
BuffTool:RegisterEvent('CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS')
BuffTool:RegisterEvent('CHAT_MSG_SPELL_SELF_DAMAGE')
BuffTool:RegisterEvent('CHAT_MSG_COMBAT_SELF_HITS')
-- For windfury weapon and rockbiter weapon
BuffTool:RegisterEvent('CHAT_MSG_SPELL_ITEM_ENCHANTMENTS')
-- For water shield for shaman 
BuffTool:RegisterEvent('CHAT_MSG_SPELL_SELF_BUFF')
BuffTool:RegisterEvent('CHAT_MSG_SPELL_AURA_GONE_OTHER')
BuffTool:RegisterEvent('CHAT_MSG_SPELL_AURA_GONE_PARTY')
BuffTool:RegisterEvent('CHAT_MSG_SPELL_AURA_GONE_SELF')
BuffTool:RegisterEvent('PLAYER_ENTERING_WORLD')
BuffTool:RegisterEvent('UNIT_AURA')
BuffTool:RegisterEvent('UNIT_PET')

BuffTool:RegisterEvent('BIND_ENCHANT')

local isDebug = false
local isDebugTexture = false

local auraTexturesObjects = {}
local auraTimersObjects = {}
local auraTimers = {}
local petAuraStates = {}
local petAuraScanElapsed = 0
local PET_AURA_SCAN_INTERVAL = 0.5

local L = {}
local _,PlayerClass = UnitClass("player")

local ArcaneSurgeTimer = nil
local BuffToolPetScanTooltip = CreateFrame('GameTooltip', 'BuffToolPetScanTooltip', nil, 'GameTooltipTemplate')
BuffToolPetScanTooltip:SetOwner(BuffTool, 'ANCHOR_NONE')

L["Electrified"] = "Electrified"
L["Clearcasting"] = "Clearcasting"
L["Berserking"] = "Berserking"
L["Elemental Mastery"] = "Elemental Mastery"
L["Ancestral Swiftness"] = "Ancestral Swiftness"
L["Shadow Trance"] = "Shadow Trance"
L["Improved Soul Fire"] = "Improved Soul Fire"
L["Purifying Flames"] = "Purifying Flames"
L["Lightning Bolt"] = "Lightning Bolt"
L["Chain Lightning"] = "Chain Lightning"
L["resisted"] = "was resisted by"
L["Stormstrike"] = "Stormstrike"
L["Elemental Devastation"] = "Elemental Devastation"
L["Flurry"] = "Flurry"
L["Enlightened"] = "Enlightened"
L["Searing Light"] = "Searing Light"
L["Seeking Thunder"] = "Seeking Thunder"
L["Water Shield"] = "Water Shield"
L["Power Overwhelming"] = "Power Overwhelming"
L["Unleashed Potential"] = "Unleashed Potential"

-- Mage
L["Hot Streak"] = "Hot Streak"
L["Flash Freeze"] = "Flash Freeze"
L["Temporal Convergence"] = "Temporal Convergence"
L["Arcane Power"] = "Arcane Power"
L["Arcane Surge"] = "Arcane Surge"

L["Surge_Casted_Token"] = "Your Arcane Surge"

-- Rogue
L["Relentless Strikes"] = "Relentless Strikes"

L["ARUAGET_TOKEN"] = "You gain "
L["You crit"] = "You crit "
L["SpellCrit_Token"] = "You crit "
L["AURASTACK_TOKEN"] = "%((%d+)%)"
L["resisted"] = "resisted"

-- Trinkles
L["The Eye of Diminution"] = "The Eye of Diminution"
L["The Eye of the Dead"] = "The Eye of the Dead"
L["Fever Dream"] = "Fever Dream"
L["Essence of Sapphiron"] = "Essence of Sapphiron"
L["Spell Blasting"] = "Spell Blasting"
L["Sulfuron Blaze"] = "Sulfuron Blaze"
L["Elune's Wrath"] = "Elune's Wrath"
L["Uncontained Magic"] = "Uncontained Magic"


-- Remove Elune resist for arc mage
L["Elune"] = "Your Elune"

local SFilter= {
    ["Elune"] = "Elune",
    ["Ancient Accord"] = "Ancient Accord",
    ["Shoot"] = "Shoot",
}


if (GetLocale() == "zhCN") then
    L["Electrified"] = "充电"
    L["Clearcasting"] = "节能施法"
    L["Berserking"] = "狂暴"
    L["Elemental Mastery"] = "元素掌握"
    L["Ancestral Swiftness"] = "自然迅捷"
    L["Shadow Trance"] = "暗影冥思"
    L["Improved Soul Fire"] = "强化灵魂之火"
    L["Purifying Flames"] = "纯净火焰"
    L["Lightning Bolt"] = "闪电箭"
    L["Chain Lightning"] = "闪电链"
    L["resisted"] = "抵抗了"
    L["Stormstrike"] = "风暴打击"
    L["Elemental Devastation"] = "元素浩劫"
    L["Flurry"] = "乱舞"
    L["Enlightened"] = "启发"
    L["Searing Light"] = "灼热之光"
    L["Seeking Thunder"] = "Seeking Thunder"
    L["Water Shield"] = "Water Shield"
    L["Power Overwhelming"] = "Power Overwhelming"
    L["Unleashed Potential"] = "Unleashed Potential"

    -- 法师
    L["Hot Streak"] = "法术连击"
    L["Flash Freeze"] = "冰霜速冻"
    L["Temporal Convergence"] = "时间融合"
    L["Arcane Power"] = "奥术强化"
    L["Arcane Surge"] = "奥术涌动"

    L["Surge_Casted_Token"] = "你得奥术涌动"


    -- 盗贼
    L["Relentless Strikes"] = "无情打击"

    L["ARUAGET_TOKEN"] = "你获得了"
    L["You crit"] = "致命一击伤害"
    L["SpellCrit_Token"] = "致命一击对"
    L["AURASTACK_TOKEN"] = "（(%d+)）"
    L["resisted"] = "抵抗"

    L["Fever Dream"] = "狂热梦想"
    L["The Eye of Diminution"] = "衰落之眼"
    L["Essence of Sapphiron"] = "萨菲隆的精华"
    L["The Eye of the Dead"] = "亡者之眼"
    L["Uncontained Magic"] = "Uncontained Magic"

-- Remove Elune resist for arc mage
    L["Elune"] = "Your Elune"

end
local iconSize = 16;

local REFRESH_BUFF_BY_SPELL =
{
    [L["Stormstrike"]] = L["Stormstrike"],
    [L["Chain Lightning"]] = L["Electrified"],
    [L["Lightning Bolt"]] = L["Electrified"],
}
local REFRESH_BUFF_BY_HIT = {
    [L["You crit"]] = {
        L["Elemental Devastation"],
        L["Flurry"],
        L["Clearcasting"],
    }
}
local PET_BUFF_ALIASES = {
    [L["Power Overwhelming"]] = {
        L["Power Overwhelming"],
    },
    [L["Unleashed Potential"]] = {
        L["Unleashed Potential"],
    },
}
local PET_BUFF_GAIN_EVENTS = {
    ['CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS'] = true,
    ['CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS'] = true,
    ['CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS'] = true,
    ['CHAT_MSG_SPELL_SELF_BUFF'] = true,
}
local PET_BUFF_FADE_EVENTS = {
    ['CHAT_MSG_SPELL_AURA_GONE_OTHER'] = true,
    ['CHAT_MSG_SPELL_AURA_GONE_PARTY'] = true,
    ['CHAT_MSG_SPELL_AURA_GONE_SELF'] = true,
}
local REFRESH_BUFF_BY_SPELL_CRIT = {
    [L["SpellCrit_Token"]] = {
        L["Elemental Devastation"],
        L["Flurry"],
        L["Clearcasting"],
        L["Searing Light"] 
    }
}
--local REFRESH_BUFF_BY_SPELL_RESISTED = {
--    [L["resisted"]] = {
--        L["Arcane Surge"],
--    }
--}

local BUFFTOOLTABLE = {
    -- Trinkles
        [L["Essence of Sapphiron"]] = {
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\SapphironEssence2'},
        x = 0,
        y = 0,
        alpha = .3,
        width = 260,
        height = 130,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "CENTER",
        duration = 20,-- Example duration in seconds
        resistedfresh = false, -- This buff can be refreshed by resisted hits
    },
        [L["Uncontained Magic"]] = {
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\UncontainedMagic'},
        x = -100,
        y = 0,
        alpha = .8,
        width = 80,
        height = 160,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "CENTER",
        duration = 6,-- Example duration in seconds
        resistedfresh = false, -- This buff can be refreshed by resisted hits
    },
        [L["Spell Blasting"]] = {
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\SpellBlasting'},
        x = 80,
        y = 0,
        alpha = .6,
        width = 60,
        height = 120,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "CENTER",
        duration = 10,-- Example duration in seconds
        resistedfresh = false, -- This buff can be refreshed by resisted hits
        mirror = false
    },
        [L["Sulfuron Blaze"]] = {
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\SulfuronBlaze'},
        x = -80,
        y = 0,
        alpha = .6,
        width = 60,
        height = 120,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "CENTER",
        duration = 6,-- Example duration in seconds
        resistedfresh = false, -- This buff can be refreshed by resisted hits
        mirror = false
    },
    -- Shaman buffs
    [L["The Eye of Diminution"]] = {
        canRefresh = false,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\Aura71'},
        x = 0,
        y = 20,
        alpha = 0.5,
        width = 300,
        height = 150,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "CENTER",
        duration = 20,-- Example duration in seconds
        resistedfresh = false, -- This buff can be refreshed by resisted hits
    },
    [L["Electrified"]] = {
        canRefresh = true,
        texture = {
            'Interface\\AddOns\\BuffTool\\Images\\auraLighting',
            'Interface\\AddOns\\BuffTool\\Images\\auraLighting5',
        },
        x = -30,
        y = -30,
        alpha = 0.9,
        width = 130,
        height = 130,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "LEFT",
        stack=true,
        duration = 15,-- Example duration in seconds
        resistedfresh = false, -- This buff can be refreshed by resisted hits
    },
    [L["Seeking Thunder"]] = {
        canRefresh = true,
        texture = {
            'Interface\\AddOns\\BuffTool\\Images\\SeekingThunder',
        },
        x = -30,
        y = -60,
        alpha = 1.0,
        width = 100,
        height = 50,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOPLEFT",
        duration = 10,-- Example duration in seconds
        resistedfresh = false, -- This buff can be refreshed by resisted hits
    },
    [L["Clearcasting"]] = {
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\Lightning2'},
        --x = 30,
        --y = -30,
        --alpha = 0.4,
        --width = 48,
        --height = 48,
        --Blend = "ADD",
        --Color = {1,1,1},
        --Pos = "TOPLEFT",
        x = 0,
        y = 90,
        alpha = 0.8,
        width = 64,
        height = 64,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "LEFT",
        duration = 15,-- Example duration in seconds
        resistedfresh = false, -- This buff can be refreshed by resisted hits
    },
    [L["Berserking"]] = {
        canRefresh = ture,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\Aura226M'},
        x = 40,
        y = 0,
        alpha = 0.6,
        width = 100,
        height = 200,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "RIGHT",
        duration = 10,-- Example duration in seconds
        resistedfresh = false, -- This buff can be refreshed by resisted hits
    },
    [L["Elemental Mastery"]] = {
        canRefresh = false,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\AuroCrys'},
        x = 0,
        y = -20,
        alpha = 0.7,
        width = 96,
        height = 96,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOP",
        duration = nil,-- Example duration in seconds
        resistedfresh = false, -- This buff can be refreshed by resisted hits
    },
    [L["Ancestral Swiftness"]] = {
        canRefresh = false,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\AuroCrys'},
        x = 0,
        y = -20,
        alpha = 0.8,
        width = 96,
        height = 96,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOP",
        duration = nil-- Example duration in seconds
    },
    [L["The Eye of the Dead"]] = {
        canRefresh = false,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\AuraWing'},
        x = 0,
        y = 20, 
        alpha = 0.4,
        width = 300,
        height = 150,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "CENTER",
        duration = 30 -- Example duration in seconds
    },
    [L["Fever Dream"]] = {
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\Aura198'},
        x = -20,
        y = 20,
        alpha = 0.6,
        width = 48,
        height = 48,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "LEFT",
        duration = 20 -- Example duration in seconds
    },
    [L["Stormstrike"]] = {
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\Stormstrike'},
        x = 30,
        y = -30,
        alpha = 0.4,
        width = 48,
        height = 48,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOPLEFT",
        duration = 12 -- Example duration in seconds
    },
    [L["Elemental Devastation"]] = {
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\ElementalDevastation'},
        x = -35,
        y = -30,
        alpha = 0.4,
        width = 48,
        height = 48,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOPRIGHT",
        duration = 10 -- Example duration in seconds
    },
    [L["Water Shield"]] = {
        canRefresh = false,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\WaterShield'},
        x = -50,
        y = -30,
        alpha = 0.6,
        width = 48,
        height = 48,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "RIGHT",
        duration = 10 -- Example duration in seconds
    },
    [L["Power Overwhelming"]] = {
        canRefresh = false,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\WaterShield'},
        x = -36,
        y = 34,
        alpha = 0.8,
        width = 52,
        height = 52,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "BOTTOMLEFT",
        duration = 10,
        resistedfresh = false,
    },
    [L["Unleashed Potential"]] = {
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\WaterShield'},
        x = 36,
        y = 34,
        alpha = 0.8,
        width = 52,
        height = 52,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "BOTTOMRIGHT",
        duration = 20,
        resistedfresh = false,
    },
    
    --[L["Flurry"]] = {
    --    id = 12319,
    --    canRefresh = false,
    --    texture = 'Interface\\AddOns\\BuffTool\\Images\\Flurry',
    --    x = -40,
    --    y = -30,
    --    alpha = 1.0,
    --    width = 64,
    --    height = 64,
    --    Blend = "ADD",
    --    Color = {1,1,1},
    --    Pos = "TOPRIGHT",
    --    rotation = math.rad(180),
    --    duration = 15 -- Example duration in seconds
    --}, 
    
    
    
    -- -- warlock 
    [L["Shadow Trance"]] = {
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\AruaUni'},
        x = -30,
        y = 20,
        alpha = 0.9,
        width = 150,
        height = 150,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "LEFT",
        duration = 10 -- Example duration in seconds
    },
    [L["Improved Soul Fire"]] = {
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\FlameDragon'},
        x = -30,
        y = 20,
        alpha = 0.9,
        width = 100,
        height = 100,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "LEFT",
        duration = 30 -- Example duration in seconds
    },
    
    
    
    -- priest
    [L["Purifying Flames"]] = {
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\InnerFire'},
        x = -40,
        y = 0,
        alpha = 0.8,
        width = 80,
        height =160, 
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "LEFT",
        duration = 10 -- Example duration in seconds
    },
    [L["Enlightened"]] = {
        canRefresh = false,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\AuraCrys2'},
        x = 20,
        y = -30,
        alpha = 1.0,
        width = 80,
        height = 80,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOPLEFT",
        duration = 8 -- Example duration in seconds
    },
    [L["Searing Light"]] = {
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\AuroCrys'},
        x = 0,
        y = 20,
        alpha = 0.8,
        width = 120,
        height =120, 
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOP",
        duration = 8 -- Example duration in seconds
    },
    
    
    
--    Mage
    [L["Hot Streak"]] = {
        canRefresh = false,
        texture = {
            'Interface\\AddOns\\BuffTool\\Images\\HotStreak1',
            'Interface\\AddOns\\BuffTool\\Images\\HotStreak2',
            'Interface\\AddOns\\BuffTool\\Images\\HotStreak3',
            'Interface\\AddOns\\BuffTool\\Images\\HotStreak4',
            'Interface\\AddOns\\BuffTool\\Images\\HotStreak5',
        },
        x = -30,
        y = 20,
        alpha = 0.9,
        width = 130,
        height = 130,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "LEFT",
        stack = true,
        duration = 20 -- Example duration in seconds
    },
    [L["Flash Freeze"]] = {
        id = 28862,
        canRefresh = true,
        texture = {
            'Interface\\AddOns\\BuffTool\\Images\\FlashFreeze',
        },
        x = -30,
        y = 20,
        alpha = 0.9,
        width = 100,
        height = 200,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "LEFT",
        stack = true,
        duration = 10 -- Example duration in seconds
    },
    [L["Temporal Convergence"]] = {
        id = 51395,
        canRefresh = true,
        texture = {
            'Interface\\AddOns\\BuffTool\\Images\\auraLighting3',
        },
        x = 40,
        y = -90,
        alpha = 0.8,
        width = 64,
        height = 128,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOPRIGHT",
        stack=true,
        duration = 12 -- Example duration in seconds
    },
    [L["Arcane Surge"]] = {
        id = 51395,
        canRefresh = true,
        texture = {
            'Interface\\AddOns\\BuffTool\\Images\\ArcaneSurge2',
        },
        x = -10,
        y = -20,
        alpha = 0.8,
        width = 52,
        height = 52,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOPRIGHT",
        --x = 10,
        --y = 10,
        --alpha = .8,
        --width = 64,
        --height = 64,
        --Blend = "ADD",
        --Color = {1,1,1},
        --Pos = "TOPLEFT",
        stack=false,
        duration = 4, -- Example duration in seconds
        resistedfresh = true,
    },

    [L["Arcane Power"]] = {
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\LightningBlue'},
        x = 0,
        y = 0,
        alpha = 0.9,
        width = 150,
        height = 75,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOP",
        stack=false,
        duration = 20-- Example duration in seconds
    },

    --    Rogu
    [L["Relentless Strikes"]] = {
        id = 14179,
        canRefresh = false,
        texture = {
            'Interface\\AddOns\\BuffTool\\Images\\Relentless Strikes1',
            'Interface\\AddOns\\BuffTool\\Images\\Relentless Strikes2',
            'Interface\\AddOns\\BuffTool\\Images\\Relentless Strikes3',
            'Interface\\AddOns\\BuffTool\\Images\\Relentless Strikes4',
            'Interface\\AddOns\\BuffTool\\Images\\Relentless Strikes5',
        },
        x = -10,
        y = 20,
        alpha = 0.9,
        width = 80,
        height = 80,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "LEFT",
        stack = true,
        duration = 30 -- Example duration in seconds
    },
    
    
--    Enlightened 8s
--    flash freeze
}


local function DebugAllBuffTexture()
    for spellName, auraInfo in pairs(BUFFTOOLTABLE) do
        if not auraTexturesObjects[spellName] then
            local textureObject = BuffTool:CreateTexture(nil, 'ARTWORK')
            textureObject:SetTexture(auraInfo.texture)
            textureObject:SetPoint('CENTER', BuffTool, auraInfo.Pos, auraInfo.x, auraInfo.y)
            textureObject:SetAlpha(auraInfo.alpha)
            textureObject:SetWidth(auraInfo.width)
            textureObject:SetHeight(auraInfo.height)
            textureObject:SetBlendMode(auraInfo.Blend)
            textureObject:SetVertexColor(auraInfo.Color[1], auraInfo.Color[2], auraInfo.Color[3])
            textureObject:Show()
            auraTexturesObjects[spellName] = textureObject

            local timerText = BuffTool:CreateFontString(nil, 'OVERLAY', 'SubZoneTextFont')
            timerText:SetPoint('CENTER', textureObject)
            auraTimersObjects[spellName] = timerText
        end
    end
end


local function ShowTimer(spellName, duration, timerText)
    if auraTimers[spellName] then
        auraTimers[spellName]:SetScript('OnUpdate', nil)
        auraTimers[spellName] = nil
    end

    local timer = CreateFrame('FRAME')
    timer.expiresAt = GetTime() + duration
    timer.lastShown = nil
    timer:SetScript('OnUpdate', function()
        local remaining = timer.expiresAt - GetTime()
        if remaining <= 0 then
            timerText:Hide()
            timer:SetScript('OnUpdate', nil)
            auraTimers[spellName] = nil
            return
        end

        local displayText = nil
        if remaining >= 3 then
            displayText = tostring(math.ceil(remaining))
        else
            displayText = string.format("%.1f", remaining)
        end

        if displayText ~= timer.lastShown then
            timer.lastShown = displayText
            timerText:SetText(displayText)
        end
    end)
    timerText:SetText(duration)
    timerText:Show()
    auraTimers[spellName] = timer
end




local function HandleAuraByName(spellName, isActive, updateOnlyTimer, stack)
    local auraInfo = BUFFTOOLTABLE[spellName]
    if not auraInfo then return end

    local textureObject = auraTexturesObjects[spellName]
    local timerText = auraTimersObjects[spellName]

    if not updateOnlyTimer then
        if not textureObject then
            textureObject = BuffTool:CreateTexture(nil, 'ARTWORK')
            textureObject:SetPoint('CENTER', BuffTool, auraInfo.Pos, auraInfo.x, auraInfo.y)
            textureObject:SetAlpha(auraInfo.alpha)
            textureObject:SetWidth(auraInfo.width)
            textureObject:SetHeight(auraInfo.height)
            textureObject:SetBlendMode(auraInfo.Blend)
            textureObject:SetVertexColor(auraInfo.Color[1], auraInfo.Color[2], auraInfo.Color[3])
            textureObject:Show()
            auraTexturesObjects[spellName] = textureObject
        end

        if auraInfo.stack and stack then
            local textureIndex = math.min(stack, table.getn(auraInfo.texture))
            textureObject:SetTexture(auraInfo.texture[textureIndex])
        else
            textureObject:SetTexture(auraInfo.texture[1])
        end

        -- Create mirrored texture if `mirror` is true
        if auraInfo.mirror and not auraTexturesObjects[spellName .. "_mirror"] then
            local mirrorTexture = BuffTool:CreateTexture(nil, 'ARTWORK')
            local mirrorPos = auraInfo.Pos
            if mirrorPos == "LEFT" then mirrorPos = "RIGHT"
            elseif mirrorPos == "RIGHT" then mirrorPos = "LEFT"
            elseif mirrorPos == "TOPLEFT" then mirrorPos = "TOPRIGHT"
            elseif mirrorPos == "TOPRIGHT" then mirrorPos = "TOPLEFT"
            elseif mirrorPos == "BOTTOMLEFT" then mirrorPos = "BOTTOMRIGHT"
            elseif mirrorPos == "BOTTOMRIGHT" then mirrorPos = "BOTTOMLEFT"
            elseif mirrorPos == "CENTER" then mirrorPos = "CENTER"
            end

            mirrorTexture:SetPoint('CENTER', BuffTool, mirrorPos, -auraInfo.x, auraInfo.y)
            mirrorTexture:SetAlpha(auraInfo.alpha)
            mirrorTexture:SetWidth(auraInfo.width)
            mirrorTexture:SetHeight(auraInfo.height)
            mirrorTexture:SetBlendMode(auraInfo.Blend)
            mirrorTexture:SetVertexColor(auraInfo.Color[1], auraInfo.Color[2], auraInfo.Color[3])
            mirrorTexture:SetTexture(auraInfo.texture[1])

            -- Flip the texture horizontally
            mirrorTexture:SetTexCoord(1, 0, 0, 1)
            mirrorTexture:Show()
            auraTexturesObjects[spellName .. "_mirror"] = mirrorTexture
        end
    end

    if not timerText then
        timerText = BuffTool:CreateFontString(nil, 'OVERLAY', 'SubZoneTextFont')
        timerText:SetPoint('CENTER', textureObject)
        auraTimersObjects[spellName] = timerText
    end

    if isActive then
        if not updateOnlyTimer then
            textureObject:Show()
            if auraTexturesObjects[spellName .. "_mirror"] then
                auraTexturesObjects[spellName .. "_mirror"]:Show()
            end
        end
        if timerText and auraInfo.duration and auraInfo.canRefresh then
            ShowTimer(spellName, auraInfo.duration, timerText)
        end

        if isDebug then DEFAULT_CHAT_FRAME:AddMessage(spellName .. ' is active') end
    else
        if not updateOnlyTimer then
            textureObject:Hide()
            if auraTexturesObjects[spellName .. "_mirror"] then
                auraTexturesObjects[spellName .. "_mirror"]:Hide()
            end
        end
        if timerText then
            timerText:Hide()
        end
        if isDebug then DEFAULT_CHAT_FRAME:AddMessage(spellName .. ' is over') end
    end
end

local function HideAllTextures()
    for spellName, textureObject in pairs(auraTexturesObjects) do
        textureObject:Hide()
        local timerText = auraTimersObjects[spellName]
        if timerText then
            timerText:Hide()
        end
            if auraTimers[spellName] then
            auraTimers[spellName]:SetScript('OnUpdate', nil)
            auraTimers[spellName] = nil
        end
    end
    if isDebug then DEFAULT_CHAT_FRAME:AddMessage("All textures hidden due to player death") end
end

local GetActiveTrackedPetAuras

local function SyncTrackedPetAuras()
    local activeAuras = GetActiveTrackedPetAuras()

    for auraName, _ in pairs(PET_BUFF_ALIASES) do
        local isActive = activeAuras[auraName] == true
        if petAuraStates[auraName] ~= isActive then
            petAuraStates[auraName] = isActive
            if isDebug then DEFAULT_CHAT_FRAME:AddMessage("BUFFTOOL: pet_scan: " .. auraName .. " active=" .. tostring(isActive)) end
            HandleAuraByName(auraName, isActive, false)
        end
    end
end

local function GetAuraStacks(message)
    if not message then return  nil end
    local stackStart, stackStop, stack= string.find(message, L["AURASTACK_TOKEN"])
    if stack then return tonumber(stack) end
    return nil
end

local function IsAuraActived(message)
    for spellName, _ in pairs(BUFFTOOLTABLE) do
        if string.find(message, L["ARUAGET_TOKEN"]..spellName) then
            return spellName, true 
        end
    end
    return nil, false
end

local function GetTrackedPetAura(message, requireOwnPet, sourceEvent)
    if not message then return nil end

    local matchedAura = nil

    for auraName, aliases in pairs(PET_BUFF_ALIASES) do
        for _, alias in pairs(aliases) do
            if string.find(message, alias, 1, true) then
                matchedAura = auraName
                break
            end
        end

        if matchedAura then
            break
        end
    end

    if not matchedAura then
        return nil
    end

    if not requireOwnPet then
        return matchedAura
    end

    local petName = UnitName("pet")
    if petName and string.find(message, petName, 1, true) then
        return matchedAura
    end

    if string.find(message, "Your pet", 1, true) or string.find(message, "your pet", 1, true) then
        return matchedAura
    end

    if sourceEvent == 'CHAT_MSG_SPELL_SELF_BUFF' or sourceEvent == 'CHAT_MSG_SPELL_AURA_GONE_SELF' then
        return matchedAura
    end

    return nil
end

local function GetPetAuraName(index, isDebuff)
    if not UnitExists("pet") then
        return nil
    end

    BuffToolPetScanTooltip:ClearLines()
    if isDebuff then
        BuffToolPetScanTooltip:SetUnitDebuff("pet", index)
    else
        BuffToolPetScanTooltip:SetUnitBuff("pet", index)
    end

    local textLeft = getglobal("BuffToolPetScanTooltipTextLeft1")
    if not textLeft then
        return nil
    end

    local buffName = textLeft:GetText()
    if buffName and buffName ~= "" then
        return buffName
    end

    return nil
end

GetActiveTrackedPetAuras = function()
    local activeAuras = {}

    if not UnitExists("pet") then
        return activeAuras
    end

    local function TrackPetAuraName(auraNameText)
        if not auraNameText then
            return
        end

        for auraName, aliases in pairs(PET_BUFF_ALIASES) do
            for _, alias in pairs(aliases) do
                if string.find(auraNameText, alias, 1, true) then
                    activeAuras[auraName] = true
                    break
                end
            end

            if activeAuras[auraName] then
                break
            end
        end
    end

    local index = 1
    while true do
        local buffTexture = UnitBuff("pet", index)
        if not buffTexture then
            break
        end

        TrackPetAuraName(GetPetAuraName(index, false))

        index = index + 1
    end

    index = 1
    while true do
        local debuffTexture = UnitDebuff("pet", index)
        if not debuffTexture then
            break
        end

        TrackPetAuraName(GetPetAuraName(index, true))

        index = index + 1
    end

    return activeAuras
end

local function RefreshTimeBySpell(CombatText)
    for spellName, auraName in pairs(REFRESH_BUFF_BY_SPELL) do
        if string.find(CombatText, spellName) then
            if not (string.find(CombatText, L["resisted"])) then
                local ttt = auraTimersObjects[auraName]
                if not ttt then return end
                HandleAuraByName(auraName, true, true)
            end
        end
    end
end

local function RefreshBuffByHit(CombatText,CheckTable)
    for HitToken, auraNames in pairs(CheckTable) do
        if HitToken then
            --print(HitToken.." " .. CombatText)
            if string.find(CombatText, HitToken) then
                if isDebug then print(HitToken.." " .. CombatText) end
                for _, auraName in auraNames do
                    if isDebug then print(auraName.." getted" ) end
                    local auraTimerIns = auraTimersObjects[auraName]
                    if auraTimerIns then
                        HandleAuraByName(auraName, true, true)
                    else
                        if isDebug then print(auraName.." not found cannot refresh" )
                        end
                    end
                end
            end
        end
    end
end

local function DebugLog(message)  
    DEFAULT_CHAT_FRAME:AddMessage("BUFFTOOL: "..message)
end

local function HandleAutoDestroyAura(spellName, delay)
    if not spellName or not delay then return end
    if ArcaneSurgeTimer then
        ArcaneSurgeTimer:SetScript('OnUpdate', nil)
        ArcaneSurgeTimer = nil
    end
    --if auraTimersObjects[spellName] then
        HandleAuraByName(spellName,true,false)
        
    --end
    --else
    --    HandleAuraByName(spellName,true,false)
    --end

    local timer = CreateFrame('FRAME')
    timer.expiresAt = GetTime() + delay
    ArcaneSurgeTimer = timer
    timer:SetScript('OnUpdate', function()
        if GetTime() >= timer.expiresAt then
            HandleAuraByName(spellName, false, false)
            timer:SetScript('OnUpdate', nil)
            ArcaneSurgeTimer = nil
        end
    end)
end


BuffTool:SetScript('OnEvent', function()
    if event == 'PLAYER_DEAD' then
        petAuraStates = {}
        HideAllTextures()
    end
    if event == 'PLAYER_ENTERING_WORLD' then
        SyncTrackedPetAuras()
    end
    if event == 'UNIT_PET' and arg1 == 'player' then
        petAuraStates = {}
        SyncTrackedPetAuras()
    end
    if event == 'UNIT_AURA' and arg1 == 'pet' then
        SyncTrackedPetAuras()
    end
    if event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" then
        if arg1 then
            local auraName, _ = IsAuraActived(arg1)
            local stack = GetAuraStacks(arg1)
            if auraName then
                if stack and isDebug then DebugLog("buffTool : " .. auraName .. " ".. stack) end
                HandleAuraByName(auraName, true, false ,stack)
            end
        end
    end
    if PET_BUFF_GAIN_EVENTS[event] then
        if arg1 then
            if isDebug then DebugLog("pet_gain_event(" .. event .. "): " .. arg1) end
            local auraName = GetTrackedPetAura(arg1, true, event)
            if auraName then
                if isDebug then DebugLog("pet_buff: " .. arg1) end
                HandleAuraByName(auraName, true, false)
            elseif isDebug then
                DebugLog("pet_gain_no_match: " .. arg1)
            end
        end
    end
    -- melee hit or crit
    if event =='CHAT_MSG_COMBAT_SELF_HITS' then
        if arg1 then
            if isDebug then  DEFAULT_CHAT_FRAME:AddMessage(arg1) end
            RefreshBuffByHit(arg1, REFRESH_BUFF_BY_HIT)
        end
    end
    -- item CHAT_MSG_SPELL_ITEM_ENCHANTMENTS
    if event == 'BIND_ENCHANT' then
        if isDebug then DebugLog("buffTool : " .. arg1) end
        if arg1 then
            if isDebug then  DEFAULT_CHAT_FRAME:AddMessage(arg1) end
            --RefreshBuffByHit(arg1, REFRESH_BUFF_BY_HIT)
        end
    end
    -- water shield
    if event == 'CHAT_MSG_SPELL_SELF_BUFF' then
        if arg1 then
            if isDebug then
                DebugLog("self_buff: "..arg1)
            end
        end
    end
    if PET_BUFF_FADE_EVENTS[event] then
        if arg1 then
            if isDebug then DebugLog("pet_fade_event(" .. event .. "): " .. arg1) end
            local auraName = GetTrackedPetAura(arg1, true, event)
            if auraName then
                if isDebug then DebugLog("pet_buff_over: " .. arg1) end
                HandleAuraByName(auraName, false, false)
            elseif isDebug then
                DebugLog("pet_fade_no_match: " .. arg1)
            end
        end
    end

    --   spell hit  and Arcane surge
    if event=='CHAT_MSG_SPELL_SELF_DAMAGE' then
        if arg1 then
            if isDebug then  DEFAULT_CHAT_FRAME:AddMessage(arg1) end
            RefreshTimeBySpell(arg1)
            RefreshBuffByHit(arg1, REFRESH_BUFF_BY_SPELL_CRIT)

            if(PlayerClass == "MAGE") then
                local isSurgeAvailable = true

                if string.find(arg1,L["resisted"]) then
                    for key, _ in pairs(SFilter) do
                        if string.find(arg1, SFilter[key]) then
                            isSurgeAvailable = false
                            if isDebug then DEFAULT_CHAT_FRAME:AddMessage("Filtered by ".. key) end
                            break
                        end
                    end
                    if isSurgeAvailable==true  then
                        HandleAutoDestroyAura(L["Arcane Surge"], 4)
                    end
                end
                if string.find(arg1,L["Surge_Casted_Token"]) then
                            --if isDebug then DEFAULT_CHAT_FRAME:AddMessage("Arcane Surge Casted") end
                        HandleAuraByName(L["Arcane Surge"], false, false)
                end
            end
        end
    end
    
    --   buff over  
    if event == 'COMBAT_TEXT_UPDATE' then
        if BUFFTOOLTABLE[arg2] then
            if arg1 == 'AURA_END' then
                if isDebug then DEFAULT_CHAT_FRAME:AddMessage("buffTool : " .. arg2 .. " is over") end
                HandleAuraByName(arg2, false, false)
            end
        end
    end
end)

BuffTool:SetScript('OnUpdate', function()
    petAuraScanElapsed = petAuraScanElapsed + arg1
    if petAuraScanElapsed >= PET_AURA_SCAN_INTERVAL then
        petAuraScanElapsed = 0
        SyncTrackedPetAuras()
    end
end)

if isDebugTexture then DebugAllBuffTexture() end

-- Slash command handler
SLASH_BUFFTOOL1 = '/bufftool'
SlashCmdList['BUFFTOOL'] = function(msg)
    if msg == 'debug' then
        isDebug = not isDebug
        DEFAULT_CHAT_FRAME:AddMessage('isDebug set to ' .. tostring(isDebug))
    elseif msg == 'debugtexture' then
        isDebugTexture = not isDebugTexture
        DEFAULT_CHAT_FRAME:AddMessage('isDebugTexture set to ' .. tostring(isDebugTexture))
        if isDebugTexture then
            DebugAllBuffTexture()
        else
            HideAllTextures()
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage('Usage: /bufftool [debug|debugtexture]')
    end
end