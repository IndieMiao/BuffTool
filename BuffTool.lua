-- blend mode :DISABLE, BLEND, ALPHAKEY, ADD, MOD
local iconSize = 16;
local auraTexturesByName = {
    -- Shaman buffs
    ["The Eye of Diminution"] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura71',
        x = 0,
        y = 0,
        alpha = 0.95,
        width = 200,
        height = 200,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "CENTER",
        rotation = 0
    },
    ['Electrified'] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\auraLighting',
        x = -30,
        y = 0,
        alpha = 0.9,
        width = 160,
        height = 160,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "LEFT",
        rotation = 0
    },
    ['Clearcasting'] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura224',
        x = 0,
        y = 0,
        alpha = 0.85,
        width = 168,
        height = 64,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOP",
        rotation = 0
    },
    ['Berserking'] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura226M',
        x = 0,
        y = 0,
        alpha = 0.6,
        width = 80,
        height = 200,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "RIGHT",
        rotation = math.rad(180)
    },
    ['Elemental Mastery'] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\AuroCrys',
        x = 0,
        y = -20,
        alpha = 0.7,
        width = 96,
        height = 96,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "TOP",
        rotation = math.rad(180)
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
        rotation = math.rad(180)
    },
    ["The Eye of the Dead"] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\AuraWing',
        x = 0,
        y = 20, 
        alpha = 0.6,
        width = 300,
        height = 150,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "CENTER",
        rotation = math.rad(180)
    },
    ["Fever Dream"] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura198',
        x = 0,
        y = 20,
        alpha = 0.7,
        width = 100,
        height = 100,
        Blend = "ADD",
        Color = {1,1,1},
        Pos = "LEFT",
        rotation = math.rad(180)
    },
    -- -- warlock 
    ["Shadow Trance"] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura229',
        x = -30,
        y = 20,
        alpha = 0.9,
        width = 100,
        height = 200,
        Blend = "BLEND",
        Color = {1,1,1},
        Pos = "LEFT",
        rotation = math.rad(180)
    },
    ["Improved Soul Fire"] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura216',
        x = -30,
        y = 20,
        alpha = 0.9,
        width = 100,
        height = 200,
        Blend = "BLEND",
        Color = {1,1,1},
        Pos = "LEFT",
        rotation = math.rad(180)
    }
}


local isDebug = false 
local isDebugTexture = false

local auraTexturesObjects = {}

local buffToolFrame = CreateFrame('FRAME')
buffToolFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, -30)
buffToolFrame:SetWidth(256)
buffToolFrame:SetHeight(256)
buffToolFrame:RegisterEvent('COMBAT_TEXT_UPDATE')
buffToolFrame:RegisterEvent('PLAYER_DEAD')

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
        end
    end
end

local function HandleAuraByName(spellName, isActive)
    local auraInfo = auraTexturesByName[spellName]
    if not auraInfo then return end

    local textureObject = auraTexturesObjects[spellName]
    if not textureObject then
        textureObject = buffToolFrame:CreateTexture(nil, 'ARTWORK')
        auraTexturesObjects[spellName] = textureObject
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
        if isDebug then DEFAULT_CHAT_FRAME:AddMessage(spellName .. ' is active') end
    else
        textureObject:Hide()
        if isDebug then DEFAULT_CHAT_FRAME:AddMessage(spellName .. ' is over') end
    end
end

local function HideAllTextures()
    for spellName, textureObject in pairs(auraTexturesObjects) do
        textureObject:Hide()
    end
    if isDebug then DEFAULT_CHAT_FRAME:AddMessage("All textures hidden due to player death") end
end

buffToolFrame:SetScript('OnEvent', function()
    if event == 'PLAYER_DEAD' then
        HideAllTextures()
    elseif event == 'COMBAT_TEXT_UPDATE' and auraTexturesByName[arg2] then
        if arg1 == 'AURA_START' then
            if isDebug then DEFAULT_CHAT_FRAME:AddMessage("buffTool : " .. arg2 .. " is start") end
            HandleAuraByName(arg2, true)
        elseif arg1 == 'AURA_END' then
            if isDebug then DEFAULT_CHAT_FAME:AddMessage("buffTool : " .. arg2 .. " is over") end
            HandleAuraByName(arg2, false)
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
            HideAllTextures() --  
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage('Usage: /bufftool [debug|debugtexture]')
    end
end
