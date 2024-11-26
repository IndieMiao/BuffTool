local auraTexturesByName = {
    ['Elemental Mastery'] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura176',
        x = -50, -- 假设的X坐标
        y = 0, -- 假设的Y坐标
        alpha = 0.5, -- 假设的透明度
        width = 256, -- 假设的宽度
        height = 256, -- 假设的高度
    },
    ['Water Shield'] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura179',
        x = 0, -- 另一个X坐标
        y = -30, -- 另一个Y坐标
        alpha = 0.75, -- 另一个透明度
        width = 300, -- 另一个宽度
        height = 300, -- 另一个高度
    }
}


local auraTexturesObjects = {}

local buffToolFrame = CreateFrame('FRAME')
buffToolFrame:SetPoint('CENTER', UIParent)
buffToolFrame:SetWidth(200)
buffToolFrame:SetHeight(200)
buffToolFrame:RegisterEvent('COMBAT_TEXT_UPDATE') -- 监听光环应用事件
 

local function HandleAuraByName(spellName, isActive)
    local auraInfo = auraTexturesByName[spellName]
    if not auraInfo then return end -- 如果没有找到对应的光环信息，则不执行任何操作
 
    local textureObject = auraTexturesObjects[spellName]
    if not textureObject then

        textureObject = UIParent:CreateTexture(nil, 'ARTWORK')
        auraTexturesObjects[spellName] = textureObject -- 将纹理对象存储在表中以便后续使用
    end
 
    if isActive then
        textureObject:SetTexture(auraInfo.texture)
        textureObject:SetPoint('CENTER', UIParent, 'CENTER', auraInfo.x, auraInfo.y) -- 设置位置
        textureObject:SetAlpha(auraInfo.alpha) -- 设置透明度
        textureObject:SetWidth(auraInfo.width) -- 设置宽度
        textureObject:SetHeight(auraInfo.height) -- 设置高度
        textureObject:Show()
        DEFAULT_CHAT_FRAME:AddMessage(spellName .. ' is active') -- 显示聊天消息（可选）
    else
        textureObject:Hide()
        DEFAULT_CHAT_FRAME:AddMessage(spellName .. ' is over') -- 显示聊天消息（可选）
    end
end


buffToolFrame:SetScript('OnEvent', function()
    if auraTexturesByName[arg2] then 
        if arg1 == 'AURA_START' then
            DEFAULT_CHAT_FRAME:AddMessage("buffTool : "..arg2 .. " is start")
            HandleAuraByName(spellName, true)
        elseif arg1 == 'AURA_END' then
            DEFAULT_CHAT_FRAME:AddMessage("buffTool : "..arg2 .. " is over")
            HandleAuraByName(spellName, false)
        end
    end
end)

