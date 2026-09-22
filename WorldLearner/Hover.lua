local _, W = ...
local elapsed=0
local function overCard()
    return W.card and W.card:IsShown() and W.card:IsMouseOver()
end
function W.Candidate()
    local tip=GameTooltip
    if not tip or not tip:IsShown() then return end
    if W.db.items and tip.GetItem then
        local ok,native,link=pcall(tip.GetItem,tip)
        local id=ok and W.ItemID(link)
        if id then return W.Resolve("item",id,native) end
    end
    if W.db.npcs and tip.GetUnit then
        local ok,native,unit=pcall(tip.GetUnit,tip)
        if ok and W.IsReadable(unit) and not UnitIsPlayer(unit) then
            local id=W.NpcID(UnitGUID(unit))
            if id then
                local record=W.Resolve("npc",id,native)
                if record then
                    record.unit,record.guid=unit,UnitGUID(unit)
                    record.key=record.key..":"..record.guid
                end
                return record
            end
        end
    end
end
function W.HideCard()
    W.current,W.pinned,W.preview=nil,false,false
    if W.card then W.card:Hide() end
    if W.wordTip then W.wordTip:Hide() end
end
function W.Tick()
    local now=GetTime()
    local dt=W.lastTick and math.max(0,now-W.lastTick) or 0
    W.lastTick=now
    if not W.db.enabled or (not W.db.combat and InCombatLockdown and InCombatLockdown()) then
        W.HideCard(); return
    end
    if W.preview or W.pinned then
        W.shownAt=now
        if W.card then W.card:SetAlpha(W.db.opacity) end
        return
    end
    if not W.Active() then W.HideCard(); return end
    if overCard() then
        W.shownAt=(W.shownAt or now)+dt
        W.card:SetAlpha(W.db.opacity); W.FreezePosition(); return
    end
    local candidate=W.Candidate()
    if not candidate or candidate.key~=W.expiredKey then W.expiredKey=nil end
    if candidate and candidate.key==W.expiredKey then return end
    if candidate then
        if not W.current or W.current.key~=candidate.key then
            W.current=candidate
            W.shownAt=now
            W.Render(candidate,true)
        end
    elseif not W.db.sticky then W.HideCard() end
    if W.current then
        W.TrackPlate()
        local delay=W.db.modifier=="ALWAYS" and tonumber(W.db.fadeAfter)
        if delay then
            local progress=math.max(0,(now-(W.shownAt or now)-delay)/0.6)
            W.card:SetAlpha(W.db.opacity*(1-math.min(1,progress)))
            if progress>=1 then
                W.expiredKey=candidate and candidate.key or nil
                W.HideCard()
            end
        end
    end
end
function W.OptionsChanged()
    W.expiredKey=nil; W.shownAt=GetTime()
    if W.UpdateMinimap then W.UpdateMinimap() end
    if W.RefreshSettings then W.RefreshSettings() end
    if not W.db.enabled or (W.current and ((W.current.kind=="npc" and not W.db.npcs)
        or (W.current.kind=="item" and not W.db.items))) then W.HideCard(); return end
    if W.current then
        local record=W.Resolve(W.current.kind,W.current.id,W.current.native)
        if record then
            record.unit,record.guid,record.key=W.current.unit,W.current.guid,W.current.key
            W.current=record; W.Render(record,true)
        else W.HideCard() end
    end
end
local driver=CreateFrame("Frame")
driver:RegisterEvent("ADDON_LOADED")
driver:RegisterEvent("MODIFIER_STATE_CHANGED")
driver:RegisterEvent("PLAYER_REGEN_DISABLED")
driver:SetScript("OnEvent",function(_,event,addon)
    if event=="ADDON_LOADED" and addon==W.name then
        W.Initialize(); W.CreateUI(); W.CreateSettings(); W.CreateMinimap()
        SLASH_WORLDLEARNER1="/wl"
        SLASH_WORLDLEARNER2="/worldlearner"
        SlashCmdList.WORLDLEARNER=function(msg)
            msg=(msg or ""):lower():match("^%s*(.-)%s*$")
            if msg=="preview" then W.Preview()
            elseif msg=="hide" then W.HideCard()
            elseif msg=="minimap" then W.SetOption("minimap",not W.db.minimap)
            else W.ToggleSettings() end
        end
    elseif W.db then W.Tick() end
end)
-- Poll only while the activation key is held (or Always is selected). This also
-- handles holding Shift after an existing tooltip has already opened, without
-- replacing native scripts or relying on a particular tooltip event generation.
driver:SetScript("OnUpdate",function(_,dt)
    elapsed=elapsed+dt
    if elapsed<0.08 then return end
    elapsed=0
    if W.db then W.Tick() end
end)
