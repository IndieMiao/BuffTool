local t = UIParent:CreateTexture(nil, 'ARTWORK')
t:SetTexture('Interface\\AddOns\\BuffTool\\Images\\Aura179')
t:SetPoint('CENTER', UIParent, 0, 0) -- or t:SetPoint('CENTER', 0, 70)
t:SetWidth(512)
t:SetHeight(512)
t:Hide()

local f = CreateFrame('FRAME')
f:RegisterEvent('COMBAT_TEXT_UPDATE')
f:SetScript('OnEvent', function()
    if arg2 == 'Water Shield' then
            -- if arg2 == 'Elemental Mastery' then
        if arg1 == 'AURA_START' then
            t:Show()
            DEFAULT_CHAT_FRAME:AddMessage('Elemental Mastery  is begin')
        elseif arg1 == 'AURA_END' then
            t:Hide()
            DEFAULT_CHAT_FRAME:AddMessage('Elemental Mastery  is over')
        end
    end
end)

