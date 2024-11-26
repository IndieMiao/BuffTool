-- 定义一个表来存储光环名称与纹理路径、位置、透明度、以及大小等属性的对应关系
local auraTexturesByName = {
    ['Elemental Mastery'] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura179',
        x = 100, -- 假设的X坐标
        y = 200, -- 假设的Y坐标
        alpha = 0.5, -- 假设的透明度
        width = 64, -- 假设的宽度
        height = 64, -- 假设的高度
    },
    ['Water Shield'] = {
        texture = 'Interface\\AddOns\\BuffTool\\Images\\Aura176',
        x = 300, -- 另一个X坐标
        y = 400, -- 另一个Y坐标
        alpha = 0.75, -- 另一个透明度
        width = 128, -- 另一个宽度
        height = 128, -- 另一个高度
    },
    -- ... 可以继续添加更多光环名称和对应属性的映射
}
 
-- 创建一个框架来监听事件
local f = CreateFrame('FRAME')
f:RegisterEvent('PLAYER_AURA_APPLIED') -- 监听光环应用事件
f:RegisterEvent('PLAYER_AURA_REMOVED') -- 监听光环移除事件
 
-- 在HandleAuraByName函数中，更新纹理对象的大小
local function HandleAuraByName(spellName, isActive)
    local auraInfo = auraTexturesByName[spellName]
    if not auraInfo then return end -- 如果没有找到对应的光环信息，则不执行任何操作
 
    local textureObject = auraTexturesObjects[spellName]
    if not textureObject then
        -- 如果没有，则创建一个新的纹理对象
        textureObject = UIParent:CreateTexture(nil, 'ARTWORK')
        auraTexturesObjects[spellName] = textureObject -- 将纹理对象存储在表中以便后续使用
    end
 
    if isActive then
        textureObject:SetTexture(auraInfo.texture)
        textureObject:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', auraInfo.x, auraInfo.y) -- 设置位置
        textureObject:SetAlpha(auraInfo.alpha) -- 设置透明度
        textureObject:SetWidth(auraInfo.width) -- 设置宽度
        textureObject:SetHeight(auraInfo.height) -- 设置高度
        textureObject:Show()
        DEFAULT_CHAT_FRAME:AddMessage(spellName .. ' is active') -- 显示聊天消息（可选）
    else
        textureObject:Hide()
    end
end