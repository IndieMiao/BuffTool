-- blend mode :DISABLE, BLEND, ALPHAKEY, ADD, MOD
local auraTexturesByName = {
    ['Elemental Mastery'] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura176',
        x = -50, -- 假设的X坐标
        y = -20, -- 假设的Y坐标
        alpha = 0.4, -- 假设的透明度
        width = 256, -- 假设的宽度
        height = 256, -- 假设的高度
        Blend = "ADD",
        Pos = "LEFT"
    },
    ['Water Shield'] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura179',
        x = 0, -- 另一个X坐标
        y = -30, -- 另一个Y坐标
        alpha = 0.75, -- 另一个透明度
        width = 360, -- 另一个宽度
        height = 360, -- 另一个高度
        Blend = "BLEND",
        Pos = "CENTER"
    }
}
local isDebug=true
local isDebugTexture= false
local auraTexturesObjects = {}

local buffToolFrame = CreateFrame('FRAME')
buffToolFrame:SetPoint('CENTER', UIParent)
buffToolFrame:SetWidth(200)
buffToolFrame:SetHeight(200)
buffToolFrame:RegisterEvent('COMBAT_TEXT_UPDATE') -- 监听光环应用事件

function DebugAllBuffTexture()
for spellName, auraInfo in pairs(auraTexturesByName) do
    local textureObject = buffToolFrame:CreateTexture(nil, 'ARTWORK')
    textureObject:SetTexture(auraInfo.texture)
    textureObject:SetPoint('CENTER', buffToolFrame, auraInfo.Pos, auraInfo.x, auraInfo.y)
    textureObject:SetAlpha(auraInfo.alpha)
    textureObject:SetWidth(auraInfo.width)
    textureObject:SetHeight(auraInfo.height)
    textureObject:SetBlendMode(auraInfo.Blend)
    textureObject:Show() -- 初始时隐藏
    auraTexturesObjects[spellName] = textureObject
end
end

local function HandleAuraByName(spellName, isActive)
    local auraInfo = auraTexturesByName[spellName]
    if not auraInfo then return end -- 如果没有找到对应的光环信息，则不执行任何操作
 
    local textureObject = auraTexturesObjects[spellName]
    if not textureObject then

        textureObject = buffToolFrame:CreateTexture(nil, 'ARTWORK')
        auraTexturesObjects[spellName] = textureObject -- 将纹理对象存储在表中以便后续使用
    end
 
    if isActive then
        textureObject:SetTexture(auraInfo.texture)
        textureObject:SetPoint('CENTER', buffToolFrame, auraInfo.Pos, auraInfo.x, auraInfo.y) -- 设置位置
        textureObject:SetAlpha(auraInfo.alpha) -- 设置透明度
        textureObject:SetWidth(auraInfo.width) -- 设置宽度
        textureObject:SetHeight(auraInfo.height) -- 设置高度
        textureObject:SetBlendMode(auraInfo.Blend) -- 设置高度
        textureObject:Show()
        if isDebug then DEFAULT_CHAT_FRAME:AddMessage(spellName .. ' is active') end-- 显示聊天消息（可选）
    else
        textureObject:Hide()
        if isDebug then DEFAULT_CHAT_FRAME:AddMessage(spellName .. ' is over') end-- 显示聊天消息（可选）
    end
end


buffToolFrame:SetScript('OnEvent', function()
    if auraTexturesByName[arg2] then 
        if arg1 == 'AURA_START' then
            if isDebug then DEFAULT_CHAT_FRAME:AddMessage("buffTool : "..arg2 .. " is start") end
            HandleAuraByName(arg2, true)
        elseif arg1 == 'AURA_END' then
            if isDebug then DEFAULT_CHAT_FRAME:AddMessage("buffTool : "..arg2 .. " is over") end
            HandleAuraByName(arg2, false)
        end
    end
end)

if isDebugTexture then DebugAllBuffTexture()end

