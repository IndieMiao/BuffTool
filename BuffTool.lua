-- blend mode :DISABLE, BLEND, ALPHAKEY, ADD, MOD
BuffTool = CreateFrame('FRAME')
BuffTool:SetPoint('CENTER', UIParent, 'CENTER', 0, -30)
BuffTool:SetWidth(300)
BuffTool:SetHeight(300)
BuffTool:RegisterEvent('COMBAT_TEXT_UPDATE')
BuffTool:RegisterEvent('PLAYER_DEAD')
BuffTool:RegisterEvent('CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS')
BuffTool:RegisterEvent('CHAT_MSG_SPELL_SELF_DAMAGE')
BuffTool:RegisterEvent('CHAT_MSG_COMBAT_SELF_HITS')
-- For windfury weapon and rockbiter weapon
BuffTool:RegisterEvent('CHAT_MSG_SPELL_ITEM_ENCHANTMENTS')
-- For water shield for shaman 
BuffTool:RegisterEvent('CHAT_MSG_SPELL_SELF_BUFF')

BuffTool:RegisterEvent('BIND_ENCHANT')

local isDebug = false
local isDebugTexture = false

local auraTexturesObjects = {}
local auraTimersObjects = {}
local auraTimers = {}

local L = {}

L["The Eye of Diminution"] = "The Eye of Diminution"
L["Electrified"] = "Electrified"
L["Clearcasting"] = "Clearcasting"
L["Berserking"] = "Berserking"
L["Elemental Mastery"] = "Elemental Mastery"
L["Nature's Swiftness"] = "Nature's Swiftness"
L["The Eye of the Dead"] = "The Eye of the Dead"
L["Fever Dream"] = "Fever Dream"
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

-- Mage
L["Hot Streak"] = "Hot Streak"
L["Flash Freeze"] = "Flash Freeze"

-- Rogue
L["Relentless Strikes"] = "Relentless Strikes"

L["ARUAGET_TOKEN"] = "You gain "
L["You crit"] = "You crit "
L["SpellCrit_Token"] = "You crit "
L["AURASTACK_TOKEN"] = "%((%d+)%)"

if (GetLocale() == "zhCN") then
    L["The Eye of Diminution"] = "衰落之眼"
    L["Electrified"] = "充电"
    L["Clearcasting"] = "节能施法"
    L["Berserking"] = "狂暴"
    L["Elemental Mastery"] = "元素掌握"
    L["Nature's Swiftness"] = "自然迅捷"
    L["The Eye of the Dead"] = "亡者之眼"
    L["Fever Dream"] = "狂热梦想"
    L["Shadow Trance"] = "暗影冥思"
    L["Improved Soul Fire"] = "Localized Name for Improved Soul Fire"
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

    -- 法师
    L["Hot Streak"] = "法术连击"
    L["Flash Freeze"] = "冰霜速冻"

    -- 盗贼
    L["Relentless Strikes"] = "无情打击"

    L["ARUAGET_TOKEN"] = "你获得了"
    L["You crit"] = "致命一击伤害"
    L["SpellCrit_Token"] = "致命一击对"
    L["AURASTACK_TOKEN"] = "（(%d+)）"
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
local REFRESH_BUFF_BY_SPELL_CRIT = {
    [L["SpellCrit_Token"]] = {
        L["Elemental Devastation"],
        L["Flurry"],
        L["Clearcasting"],
        L["Searing Light"] 
    }
}
local BUFFTOOLTABLE = {
    -- Shaman buffs
    [L["The Eye of Diminution"]] = {
        id = 28862,
        canRefresh = false,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\Aura71'},
        x = 0,
        y = 20,
        alpha = 0.75,
        width = 300,
        height = 150,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "CENTER",
        duration = 20 -- Example duration in seconds
    },
    [L["Electrified"]] = {
        id = 51395,
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
        duration = 15 -- Example duration in seconds
    },
    [L["Seeking Thunder"]] = {
        id = 28861,
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
        duration = 10 -- Example duration in seconds
    },
    [L["Clearcasting"]] = {
        id = 45542,
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\Lightning2'},
        x = 0,
        y = 10,
        alpha = 0.95,
        width = 100,
        height = 100,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOP",
        duration = 15 -- Example duration in seconds
    },
    [L["Berserking"]] = {
        id= 26635,
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
        duration = 10 -- Example duration in seconds
    },
    [L["Elemental Mastery"]] = {
        id = 16166,
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
        duration = nil-- Example duration in seconds
    },
    [L["Nature's Swiftness"]] = {
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
        id=28780,
        canRefresh = false,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\AuraWing'},
        x = 0,
        y = 20, 
        alpha = 0.6,
        width = 300,
        height = 150,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "CENTER",
        duration = 30 -- Example duration in seconds
    },
    [L["Fever Dream"]] = {
        id = 45858,
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\Aura198'},
        x = -20,
        y = 20,
        alpha = 0.8,
        width = 68,
        height = 68,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "LEFT",
        duration = 20 -- Example duration in seconds
    },
    [L["Stormstrike"]] = {
        id = 45521,
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\Stormstrike'},
        x = 30,
        y = -30,
        alpha = 1.0,
        width = 50,
        height = 50,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOPLEFT",
        duration = 12 -- Example duration in seconds
    },
    [L["Elemental Devastation"]] = {
        id = 29180,
        canRefresh = true,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\ElementalDevastation'},
        x = -35,
        y = -30,
        alpha = 0.8,
        width = 50,
        height = 50,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOPRIGHT",
        duration = 10 -- Example duration in seconds
    },
    [L["Water Shield"]] = {
        id = 29180,
        canRefresh = false,
        texture = {'Interface\\AddOns\\BuffTool\\Images\\WaterShield'},
        x = -20,
        y = -30,
        alpha = 0.9,
        width = 48,
        height = 48,
        Blend = "BLEND",
        Color = {1,1,1},
        Pos = "RIGHT",
        duration = 10 -- Example duration in seconds
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
        id=17941,
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
        id=51735,
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
        id=51469,
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
        id=51469,
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
        id=51469,
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
        id = 28862,
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
        duration = 8 -- Example duration in seconds
    },

    --    Rogue
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
    timer.start = GetTime()
    timer.duration = duration
    timer.sec = 0
    timer:SetScript('OnUpdate', function()
        if GetTime() >= (this.start + this.sec) then
            this.sec = this.sec + 1
            if this.sec <= duration then
                timerText:SetText(this.duration - this.sec)
                return
            end
            timerText:Hide()
            this:SetScript('OnUpdate', nil)
        end
    end)
    timerText:SetText(duration)
    timerText:Show()
    auraTimers[spellName] = timer
end




local function HandleAuraByName(spellName, isActive, updateOnlyTimer,stack)
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
    end

    if not timerText then
        timerText = BuffTool:CreateFontString(nil, 'OVERLAY', 'SubZoneTextFont')
        timerText:SetPoint('CENTER', textureObject)
        auraTimersObjects[spellName] = timerText
    end

    if isActive then
        if not updateOnlyTimer then
            textureObject:Show()
        end
        if timerText and auraInfo.duration and auraInfo.canRefresh then
            ShowTimer(spellName, auraInfo.duration, timerText)
        end

        if isDebug then DEFAULT_CHAT_FRAME:AddMessage(spellName .. ' is active') end
    else
        if not updateOnlyTimer then
            textureObject:Hide()
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


BuffTool:SetScript('OnEvent', function()
    if event == 'PLAYER_DEAD' then
        HideAllTextures()
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

    --   spell hit 
    if event=='CHAT_MSG_SPELL_SELF_DAMAGE' then
        if arg1 then
            if isDebug then  DEFAULT_CHAT_FRAME:AddMessage(arg1) end
            RefreshTimeBySpell(arg1)
            RefreshBuffByHit(arg1, REFRESH_BUFF_BY_SPELL_CRIT)
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