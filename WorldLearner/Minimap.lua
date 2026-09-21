local _, W = ...
function W.UpdateMinimap()
    local b=W.minimapButton
    if not b then return end
    local radians=math.rad(W.db.minimapAngle)
    local radius=Minimap:GetWidth()/2+9
    b:ClearAllPoints()
    b:SetPoint("CENTER",Minimap,"CENTER",math.cos(radians)*radius,math.sin(radians)*radius)
    b.icon:SetDesaturated(not W.db.enabled)
    b:SetShown(W.db.minimap)
end
function W.CreateMinimap()
    if not Minimap then return end
    local b=CreateFrame("Button","WorldLearnerMinimapButton",Minimap)
    W.minimapButton=b
    b:SetSize(32,32); b:SetFrameStrata("MEDIUM"); b:SetFrameLevel(Minimap:GetFrameLevel()+8)
    b:RegisterForClicks("LeftButtonUp","RightButtonUp"); b:RegisterForDrag("LeftButton")
    local background=b:CreateTexture(nil,"BACKGROUND")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background"); background:SetAllPoints()
    local icon=b:CreateTexture(nil,"ARTWORK"); b.icon=icon
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    icon:SetSize(20,20); icon:SetPoint("CENTER",0,0); icon:SetTexCoord(0.08,0.92,0.08,0.92)
    if icon.SetMask then icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask") end
    local border=b:CreateTexture(nil,"OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54,54); border:SetPoint("TOPLEFT",0,0)
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    b:SetScript("OnClick",function(_,button)
        if b.dragging or (b.dragStopped and GetTime()-b.dragStopped<0.15) then return end
        if button=="RightButton" then W.SetOption("enabled",not W.db.enabled)
        else W.ToggleSettings() end
    end)
    b:SetScript("OnDragStart",function()
        if W.db.minimapLocked then return end
        b.dragging=true
        b:SetScript("OnUpdate",function()
            local x,y=GetCursorPosition(); local scale=Minimap:GetEffectiveScale()
            local cx,cy=Minimap:GetCenter()
            W.db.minimapAngle=(math.deg(math.atan2(y/scale-cy,x/scale-cx))+360)%360
            W.UpdateMinimap()
        end)
    end)
    b:SetScript("OnDragStop",function()
        b:SetScript("OnUpdate",nil); b.dragging=false; b.dragStopped=GetTime(); W.RefreshSettings()
    end)
    b:SetScript("OnEnter",function()
        GameTooltip:SetOwner(b,"ANCHOR_LEFT"); GameTooltip:ClearLines()
        GameTooltip:AddLine("WorldLearner",1,0.82,0)
        GameTooltip:AddLine(W.db.enabled and "Enabled" or "Disabled",1,1,1)
        GameTooltip:AddLine("Left-click: settings\nRight-click: toggle\nDrag: move button",0.8,0.8,0.8)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave",function() GameTooltip:Hide() end)
    W.UpdateMinimap()
end
