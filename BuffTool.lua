-- blend mode :DISABLE, BLEND, ALPHAKEY, ADD, MOD
local iconSize = 16;
local auraTexturesByName = {
    -- Shaman buffs
    ["The Eye of Diminution"] = {
        id = 28862,
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura71',
        x = 0,
        y = 0,
        alpha = 0.95,
        width = 200,
        height = 200,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "CENTER",
        rotation = 0,
        duration = 30 -- Example duration in seconds
    },
    ['Electrified'] = {
        id = 51395,
        texture = 'Interface\\AddOns\\BuffTool\\Images\\auraLighting',
        x = -30,
        y = 0,
        alpha = 0.9,
        width = 160,
        height = 160,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "LEFT",
        rotation = 0,
        duration = 20 -- Example duration in seconds
    },
    ['Clearcasting'] = {
        id = 45542,
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura224',
        x = 0,
        y = 0,
        alpha = 0.85,
        width = 168,
        height = 64,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOP",
        rotation = 0,
        duration = 15 -- Example duration in seconds
    },
    ['Berserking'] = {
        id= 26635,
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura226M',
        x = 0,
        y = 0,
        alpha = 0.6,
        width = 80,
        height = 200,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "RIGHT",
        rotation = math.rad(180),
        duration = 10 -- Example duration in seconds
    },
    ['Elemental Mastery'] = {
        id = 16166,
        texture = 'Interface\\AddOns\\BuffTool\\Images\\AuroCrys',
        x = 0,
        y = -20,
        alpha = 0.7,
        width = 96,
        height = 96,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOP",
        rotation = math.rad(180),
        duration = nil-- Example duration in seconds
    },
    ["Nature's Swiftness"] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\AuroCrys',
        x = 0,
        y = -20,
        alpha = 0.8,
        width = 96,
        height = 96,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOP",
        rotation = math.rad(180),
        duration = 25 -- Example duration in seconds
    },
    ["The Eye of the Dead"] = {
        id=28780,
        texture = 'Interface\\AddOns\\BuffTool\\Images\\AuraWing',
        x = 0,
        y = 20, 
        alpha = 0.6,
        width = 300,
        height = 150,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "CENTER",
        rotation = math.rad(180),
        duration = 25 -- Example duration in seconds
    },
    ["Fever Dream"] = {
        id = 45858,
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura198',
        x = 0,
        y = 20,
        alpha = 0.7,
        width = 100,
        height = 100,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "LEFT",
        rotation = math.rad(180),
        duration = 25 -- Example duration in seconds
    },
    -- -- warlock 
    ["Shadow Trance"] = {
        id=17941,
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura229',
        x = -30,
        y = 20,
        alpha = 0.9,
        width = 100,
        height = 200,
        Blend = "BLEND",
        Color = {1,1,1},
        Pos = "LEFT",
        rotation = math.rad(180),
        duration = 25 -- Example duration in seconds
    },
    ["Improved Soul Fire"] = {
        id=51735,
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura216',
        x = -30,
        y = 20,
        alpha = 0.9,
        width = 100,
        height = 200,
        Blend = "BLEND",
        Color = {1,1,1},
        Pos = "LEFT",
        rotation = math.rad(180),
        duration = 25 -- Example duration in seconds
    },
    -- priest
    ["Purifying Flames"] = {
        id=51469,
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura216',
        x = -30,
        y = 20,
        alpha = 0.9,
        width = 100,
        height = 200,
        Blend = "BLEND",
        Color = {1,1,1},
        Pos = "LEFT",
        rotation = math.rad(180),
        duration = 25 -- Example duration in seconds
    }
}


local isDebug = false 
local isDebugTexture = false

local auraTexturesObjects = {}
local auraTimersObjects = {}
local auraTimers = {}


local buffToolFrame = CreateFrame('FRAME')
buffToolFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, -30)
buffToolFrame:SetWidth(256)
buffToolFrame:SetHeight(256)
buffToolFrame:RegisterEvent('COMBAT_TEXT_UPDATE')
buffToolFrame:RegisterEvent('PLAYER_DEAD')
buffToolFrame:RegisterEvent('UNIT_AURA')

local function DebugAllBuffTexture()
    for spellName, auraInfo in pairs(auraTexturesByName) do
        if not auraTexturesObjects[spellName] then
            local textureObject = buffToolFrame:CreateTexture(nil, 'ARTWORK')
            textureObject:SetTexture(auraInfo.texture)
            textureObject:SetPoint('CENTER', buffToolFrame, auraInfo.Pos, auraInfo.x, auraInfo.y)
            textureObject:SetAlpha(auraInfo.alpha)
            textureObject:SetWidth(auraInfo.width)
            textureObject:SetHeight(auraInfo.height)
            textureObject:SetBlendMode(auraInfo.Blend)
            textureObject:SetVertexColor(auraInfo.Color[1], auraInfo.Color[2], auraInfo.Color[3])
            textureObject:Show()
            auraTexturesObjects[spellName] = textureObject

            local timerText = buffToolFrame:CreateFontString(nil, 'OVERLAY', 'SubZoneTextFont')
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
    timer.duration = duration+1
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


local function HandleAuraByName(spellName, isActive)
    local auraInfo = auraTexturesByName[spellName]
    if not auraInfo then return end

    local textureObject = auraTexturesObjects[spellName]
    local timerText = auraTimersObjects[spellName]

    if not textureObject then
        textureObject = buffToolFrame:CreateTexture(nil, 'ARTWORK')
        auraTexturesObjects[spellName] = textureObject

        local timerText = buffToolFrame:CreateFontString(nil, 'OVERLAY', 'SubZoneTextFont')
        timerText:SetPoint('CENTER', textureObject)
        auraTimersObjects[spellName] = timerText
    end

    if isActive then
        textureObject:SetTexture(auraInfo.texture)
        textureObject:SetPoint('CENTER', buffToolFrame, auraInfo.Pos, auraInfo.x, auraInfo.y)
        textureObject:SetAlpha(auraInfo.alpha)
        textureObject:SetWidth(auraInfo.width)
        textureObject:SetHeight(auraInfo.height)
        textureObject:SetBlendMode(auraInfo.Blend)
        textureObject:SetVertexColor(auraInfo.Color[1], auraInfo.Color[2], auraInfo.Color[3])
        textureObject:Show()
        auraTexturesObjects[spellName] = textureObject
    end

    -- if not timerText then
    --     timerText = buffToolFrame:CreateFontString(nil, 'OVERLAY', 'SubZoneTextFont')
    --     timerText:SetPoint('CENTER', textureObject)
    --     auraTimersObjects[spellName] = timerText
    -- end

    if isActive then
        textureObject:Show()
        if timerText and auraInfo.duration then
            ShowTimer(spellName, auraInfo.duration, timerText)
        end

        if isDebug then DEFAULT_CHAT_FRAME:AddMessage(spellName .. ' is active') end
    else
        textureObject:Hide()
        local timerText = auraTimersObjects[spellName]
        if timerText then
            timerText:Hide()
        end
        if isDebug then DEFAULT_CHAT_FRAME:AddMessage(spellName .. ' is over') end
    end
end
local function GetAuraNameById(id)
    for spellName, auraInfo in pairs(auraTexturesByName) do
        if auraInfo.id == id then
            return spellName 
        end
    end
    return nil -- Return nil if no match is found
end

local function IsAuraActive(spellName) 
    for i = 1,40 do
        local icon, count,spellid = UnitBuff('player', i)
        if(icon) then
            print (icon..", ".. count..", "..spellid)
            local name = GetAuraNameById(spellid)
            if name == spellName then
                return true
            end
        end
    end
    return false
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

buffToolFrame:SetScript('OnEvent', function()
    if event == 'PLAYER_DEAD' then
        HideAllTextures()
    -- elseif event == 'COMBAT_TEXT_UPDATE' and auraTexturesByName[arg2] then
    --     if arg1 == 'AURA_START' then
    --         if isDebug then DEFAULT_CHAT_FRAME:AddMessage("buffTool : " .. arg2 .. " is start") end
    --         HandleAuraByName(arg2, true) -- Use duration from auraTexturesByName
    --     elseif arg1 == 'AURA_END' then
    --         if isDebug then DEFAULT_CHAT_FRAME:AddMessage("buffTool : " .. arg2 .. " is over") end
    --         HandleAuraByName(arg2, false)
    --     end
    elseif event == 'UNIT_AURA' and arg1 == 'player' then
        for spellName, auraInfo in pairs(auraTexturesByName) do
            if IsAuraActive(spellName) then
                -- print (spellName .. " is active")
                HandleAuraByName(spellName, true) -- Use duration from auraTexturesByName
            else
                -- print (spellName .. " is not active")
                HandleAuraByName(spellName, false)
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
