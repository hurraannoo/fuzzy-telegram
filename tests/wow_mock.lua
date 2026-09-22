-- Deliberately limited doubles: unknown UI methods cause errors.
W={}; frames={}; SlashCmdList={}; UISpecialFrames={}; tinsert=table.insert
shift,alt,ctrl,combat=false,false,false,false
function IsShiftKeyDown() return shift end
function IsAltKeyDown() return alt end
function IsControlKeyDown() return ctrl end
function InCombatLockdown() return combat end
function UnitIsPlayer() return player or false end
function UnitGUID(unit) return unitGuids and unitGuids[unit] or guid end
function GetCursorPosition() return 500,600 end
function GetTime() return now or 100 end
local M={}
function M:SetSize(w,h) self.width,self.height=w,h end
function M:SetWidth(w) self.width=w end
function M:SetHeight(h) self.height=h end
function M:GetWidth() return self.width or 140 end
function M:GetHeight() return self.height or 140 end
function M:SetPoint(...) self.point={...} end
function M:ClearAllPoints() self.point=nil end
function M:GetCenter() return 960,540 end
function M:GetEffectiveScale() return 1 end
function M:SetFont(path,size) self.font,self.size=path,size end
function M:SetText(text) self.text=text end
function M:SetTextColor(...) self.color={...} end
function M:SetTexture(path) self.texture=path end
function M:GetStringWidth()
    local n=0
    for c in (self.text or ""):gmatch("[%z\1-\127\194-\244][\128-\191]*") do n=n+(#c>1 and 1 or .55) end
    return n*(self.size or 14)
end
function M:GetStringHeight()
    local width=self.width or 100000
    if width<=0 then width=100000 end
    return math.max(1,math.ceil(self:GetStringWidth()/width))*(self.size or 14)*1.2
end
function M:SetScript(event,fn) self.scripts[event]=fn end
function M:RegisterEvent(event) self.events[event]=true end
function M:Show() self.shown=true end
function M:Hide()
    local shown=self.shown; self.shown=false
    if shown and self.scripts.OnHide then self.scripts.OnHide(self) end
end
function M:IsShown() return self.shown end
function M:SetShown(v) if v then self:Show() else self:Hide() end end
function M:IsMouseOver() return self.mouseOver or false end
function M:SetChecked(v) self.checked=v end
function M:GetChecked() return self.checked end
function M:SetEnabled(v) self.enabled=v end
function M:GetFrameLevel() return 1 end
function M:GetItem() return self.itemName,self.itemLink end
function M:GetUnit() return self.unitName,self.unit end
function M:ClearLines() self.lines={} end
function M:AddLine(text) self.lines=self.lines or {}; table.insert(self.lines,text) end
function M:NumLines() return #(self.lines or {}) end
function M:SetAlpha(value) self.alpha=value end
function M:SetBackdrop(value) self.backdrop=value end
for _,key in ipairs({"SetAllPoints","SetJustifyH","SetFrameStrata","SetClampedToScreen",
    "EnableMouse","SetMovable","RegisterForDrag","RegisterForClicks","StartMoving",
    "StopMovingOrSizing","SetOwner","SetBackdropColor","SetBackdropBorderColor",
    "SetFrameLevel","SetDesaturated","SetTexCoord","SetMask","SetHighlightTexture"}) do
    M[key]=function() end
end
function CreateFrame(kind,name,parent,template)
    local f=setmetatable({kind=kind,name=name,parent=parent,template=template,scripts={},events={},shown=true},{__index=M})
    table.insert(frames,f); if name then _G[name]=f end; return f
end
function M:CreateTexture() return CreateFrame("Texture",nil,self) end
function M:CreateFontString() return CreateFrame("FontString",nil,self) end
UIParent=CreateFrame("Frame"); Minimap=CreateFrame("Frame")
GameTooltip=CreateFrame("GameTooltip"); GameTooltip:Hide()
