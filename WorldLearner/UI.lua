local _, W = ...
W.font="Interface\\AddOns\\"..W.name.."\\Fonts\\ForeverLearnerSans.ttf"
local template=BackdropTemplateMixin and "BackdropTemplate" or nil
function W.Skin(frame)
    frame:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=24,
        insets={left=6,right=6,top=6,bottom=6}})
    frame:SetBackdropColor(0.12,0.10,0.07,1)
end
function W.Label(parent,text,size)
    local label=parent:CreateFontString(nil,"OVERLAY")
    label:SetFont(W.font,size or 14)
    label:SetTextColor(1,0.91,0.7)
    label:SetJustifyH("LEFT")
    label:SetText(text or "")
    return label
end
function W.Button(parent,text,width,click)
    local b=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
    b:SetSize(width or 110,24); b:SetText(text); b:SetScript("OnClick",click)
    return b
end
function W.CreateUI()
    local f=CreateFrame("Frame","WorldLearnerCard",UIParent,template)
    W.card=f; W.Skin(f)
    f:SetFrameStrata("DIALOG"); f:SetClampedToScreen(true); f:EnableMouse(true)
    f:SetMovable(true); f:SetSize(340,180); f:Hide()
    local drag=CreateFrame("Frame",nil,f)
    drag:SetPoint("TOPLEFT",8,-4); drag:SetPoint("TOPRIGHT",-100,-4); drag:SetHeight(28)
    drag:EnableMouse(true); drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart",function()
        if not W.db.locked then W.FreezePosition(); f:StartMoving() end
    end)
    drag:SetScript("OnDragStop",function()
        f:StopMovingOrSizing()
        if not W.db.locked then
            local x,y=f:GetCenter(); local cx,cy=UIParent:GetCenter()
            W.db.x,W.db.y=x-cx,y-cy; W.db.anchor="FIXED"
            if W.RefreshSettings then W.RefreshSettings() end
        end
    end)
    local function togglePin()
        W.pinned=not W.pinned; W.preview=false
        W.shownAt=GetTime()
        if W.pinned then W.FreezePosition(); f:SetAlpha(W.db.opacity) end
        W.pin:SetText(W.pinned and "Unpin" or "Pin")
        W.modernPin.label:SetText(W.pinned and "Unpin" or "Pin")
    end
    W.pin=W.Button(f,"Pin",48,togglePin)
    W.pin:SetPoint("TOPRIGHT",-32,-7)
    local close=CreateFrame("Button",nil,f,"UIPanelCloseButton")
    W.close=close
    close:SetPoint("TOPRIGHT",2,2); close:SetScript("OnClick",W.HideCard)
    W.modernPin=CreateFrame("Button",nil,f)
    W.modernPin:SetSize(48,24); W.modernPin:SetPoint("TOPRIGHT",-30,-5)
    W.modernPin.label=W.Label(W.modernPin,"Pin",12); W.modernPin.label:SetPoint("CENTER")
    W.modernPin:SetScript("OnClick",togglePin)
    W.modernClose=CreateFrame("Button",nil,f)
    W.modernClose:SetSize(24,24); W.modernClose:SetPoint("TOPRIGHT",-5,-5)
    local cross=W.Label(W.modernClose,"×",17); cross:SetPoint("CENTER")
    W.modernClose:SetScript("OnClick",W.HideCard)
    W.wordTip=CreateFrame("GameTooltip","WorldLearnerWordTooltip",UIParent,"GameTooltipTemplate")
    W.tokens={}
    W.py=W.Label(f,"",16); W.py:SetTextColor(0.7,0.86,0.7)
    W.en=W.Label(f,"",16); W.en:SetTextColor(1,0.96,0.86)
    W.status=W.Label(f,"",11); W.status:SetTextColor(0.65,0.62,0.54)
    tinsert(UISpecialFrames,"WorldLearnerCard")
    f:SetScript("OnHide",function()
        W.current,W.pinned,W.preview=nil,false,false
        W.followPlate=nil
        W.wordTip:Hide()
    end)
end
function W.ApplyCardTheme()
    local modern=W.db.theme=="MODERN"
    W.pin:SetShown(not modern); W.close:SetShown(not modern)
    W.modernPin:SetShown(modern); W.modernClose:SetShown(modern)
    if W.db.theme=="MODERN" then
        W.card:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",
            edgeSize=1,insets={left=1,right=1,top=1,bottom=1}})
        W.card:SetBackdropColor(0.035,0.055,0.075,1)
        W.card:SetBackdropBorderColor(0.27,0.31,0.35,1)
    else W.Skin(W.card); W.card:SetBackdropBorderColor(1,1,1,1) end
end
function W.FreezePosition()
    if not W.followPlate then return end
    local x,y=W.card:GetCenter()
    W.card:ClearAllPoints()
    if x and y then W.card:SetPoint("CENTER",UIParent,"BOTTOMLEFT",x,y) end
    W.followPlate=nil
end
function W.FindPlate(record)
    if not record or not record.guid or not C_NamePlate then return end
    local function valid(plate)
        if not plate or (plate.IsForbidden and plate:IsForbidden()) or not plate:IsShown() then return end
        local unit=plate.namePlateUnitToken or (plate.GetUnit and plate:GetUnit())
        if unit and UnitGUID(unit)==record.guid then return plate end
    end
    if C_NamePlate.GetNamePlateForUnit and record.unit and UnitGUID(record.unit)==record.guid then
        local ok,plate=pcall(C_NamePlate.GetNamePlateForUnit,record.unit)
        if ok and valid(plate) then return plate end
    end
    if C_NamePlate.GetNamePlates then
        local ok,plates=pcall(C_NamePlate.GetNamePlates)
        if ok and type(plates)=="table" then for _,plate in ipairs(plates) do if valid(plate) then return plate end end end
    end
end
function W.TrackPlate()
    if W.db.anchor~="NAMEPLATE" or not W.current or W.pinned or W.preview then return end
    if W.card:IsMouseOver() then W.FreezePosition(); return end
    local plate=W.FindPlate(W.current)
    if plate then
        if W.followPlate~=plate then
            W.card:ClearAllPoints(); W.card:SetPoint("BOTTOM",plate,"TOP",0,14)
            W.followPlate=plate
        end
    else W.FreezePosition() end
end
function W.ShowWord(button)
    if not W.db.wordHover or not button.token then return end
    local t=button.token
    local tip=W.wordTip
    tip:SetOwner(button,"ANCHOR_BOTTOMRIGHT")
    tip:ClearLines()
    tip:AddLine(t.text,1,0.83,0.3)
    if t.known then
        tip:AddLine(t.pinyin,0.7,0.9,0.7,true)
        tip:AddLine(t.definition or t.gloss,1,1,1,true)
    else tip:AddLine("No dictionary entry",0.8,0.8,0.8,true) end
    -- Give the independent word tooltip the bundled CJK/tone-mark font too.
    for i=1,tip:NumLines() do
        local line=_G["WorldLearnerWordTooltipTextLeft"..i]
        if line then line:SetFont(W.font,i==1 and 20 or 15) end
    end
    tip:Show()
end
function W.Place()
    local f=W.card
    W.followPlate=nil
    f:ClearAllPoints()
    if W.db.anchor=="FIXED" then
        f:SetPoint("CENTER",UIParent,"CENTER",W.db.x or 240,W.db.y or 0)
    else
        local x,y=GetCursorPosition(); local scale=UIParent:GetEffectiveScale()
        f:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",x/scale+26,y/scale-24)
    end
    W.TrackPlate()
end
function W.Render(record,reposition)
    local f=W.card
    W.wordTip:Hide()
    f:SetWidth(W.db.width); f:SetAlpha(W.db.opacity)
    W.ApplyCardTheme()
    W.pin:SetText(W.pinned and "Unpin" or "Pin")
    W.modernPin.label:SetText(W.pinned and "Unpin" or "Pin")
    for _,button in ipairs(W.tokens) do button:Hide() end
    local width=W.db.width-32
    local y=40
    local tokens=W.Tokenize(record.cn)
    if W.db.chinese then
        if #tokens==0 then tokens={{text="Chinese unavailable",kind="literal"}} end
        local x,lineHeight=0,W.db.chineseSize+7
        for i,t in ipairs(tokens) do
            local b=W.tokens[i]
            if not b then
                b=CreateFrame("Button",nil,f); W.tokens[i]=b
                b.label=W.Label(b,"",W.db.chineseSize); b.label:SetPoint("LEFT")
                b:SetScript("OnEnter",W.ShowWord)
                b:SetScript("OnLeave",function() W.wordTip:Hide() end)
            end
            b.token=t
            b.label:SetFont(W.font,W.db.chineseSize); b.label:SetText(t.text)
            b.label:SetWidth(0)
            local tw=math.min(width,math.max(3,b.label:GetStringWidth()+2))
            if x>0 and x+tw>width then x=0; y=y+lineHeight; lineHeight=W.db.chineseSize+7 end
            b.label:SetWidth(tw)
            local tokenHeight=math.max(W.db.chineseSize+7,b.label:GetStringHeight()+4)
            lineHeight=math.max(lineHeight,tokenHeight)
            if W.db.theme=="MODERN" then b.label:SetTextColor(0.90,0.94,0.96)
            else b.label:SetTextColor(1,0.86,0.46) end
            b:SetSize(tw,tokenHeight); b:ClearAllPoints()
            b:SetPoint("TOPLEFT",16+x,-y); b:Show()
            x=x+tw
        end
        y=y+lineHeight+5
    end
    local function line(label,text,size,color)
        label:ClearAllPoints(); label:SetPoint("TOPLEFT",16,-y)
        label:SetFont(W.font,size); label:SetWidth(width); label:SetText(text)
        label:Show(); y=y+label:GetStringHeight()+8
    end
    W.py:Hide(); W.en:Hide()
    if W.db.pinyin then
        local py=record.cn~="" and W.Layers(W.Tokenize(record.cn)) or "Pinyin unavailable"
        line(W.py,py,W.db.pinyinSize)
    end
    if W.db.english then line(W.en,record.en~="" and record.en or "English unavailable",W.db.englishSize) end
    W.status:Hide()
    if record.status~="Classic database" then line(W.status,record.status,11) end
    f:SetHeight(math.max(80,y+8))
    if reposition or not f:IsShown() then W.Place() end
    f:Show()
end
function W.Preview()
    if not W.db.enabled then W.SetOption("enabled",true) end
    local r=W.Resolve("npc",68,"Stormwind City Guard")
    if not r then return end
    W.current=r; W.preview=true; W.pinned=true
    W.Render(r,true)
end
