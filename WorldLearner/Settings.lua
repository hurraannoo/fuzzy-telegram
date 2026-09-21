local _, W = ...
local template=BackdropTemplateMixin and "BackdropTemplate" or nil
W.controls={}
local function checkbox(parent,key,label,y)
    local b=CreateFrame("CheckButton",nil,parent,"UICheckButtonTemplate")
    b:SetSize(26,26); b:SetPoint("TOPLEFT",20,-y)
    local text=W.Label(b,label,14); text:SetPoint("LEFT",b,"RIGHT",4,0)
    b:SetScript("OnClick",function(self) W.SetOption(key,self:GetChecked() and true or false) end)
    W.controls[#W.controls+1]=function() b:SetChecked(W.db[key]) end
end
local function cycle(parent,key,label,values,y)
    local caption=W.Label(parent,label,14); caption:SetPoint("TOPLEFT",22,-y-5)
    local b=W.Button(parent,"",190,function()
        local index=1
        for i,v in ipairs(values) do if v[1]==W.db[key] then index=i; break end end
        W.SetOption(key,values[index % #values+1][1])
    end)
    b:SetPoint("TOPRIGHT",-24,-y)
    W.controls[#W.controls+1]=function()
        for _,v in ipairs(values) do if v[1]==W.db[key] then b:SetText(v[2]) end end
    end
end
local function stepper(parent,key,label,step,y,format)
    local caption=W.Label(parent,label,14); caption:SetPoint("TOPLEFT",22,-y-5)
    local value=W.Label(parent,"",14); value:SetPoint("TOPRIGHT",-66,-y-5)
    local minus=W.Button(parent,"-",28,function() W.SetOption(key,W.db[key]-step) end)
    minus:SetPoint("TOPRIGHT",-130,-y)
    local plus=W.Button(parent,"+",28,function() W.SetOption(key,W.db[key]+step) end)
    plus:SetPoint("TOPRIGHT",-24,-y)
    W.controls[#W.controls+1]=function()
        value:SetText(format and format(W.db[key]) or tostring(W.db[key]))
        minus:SetEnabled(W.db[key]>W.bounds[key][1])
        plus:SetEnabled(W.db[key]<W.bounds[key][2])
    end
end
local function note(parent,text,y)
    local label=W.Label(parent,text,12)
    label:SetPoint("TOPLEFT",24,-y); label:SetWidth(442)
    label:SetTextColor(0.76,0.72,0.62)
end
function W.RefreshSettings()
    for _,refresh in ipairs(W.controls) do refresh() end
end
function W.CreateSettings()
    local f=CreateFrame("Frame","WorldLearnerSettings",UIParent,template)
    W.settings=f; W.Skin(f)
    f:SetSize(510,510); f:SetPoint("CENTER"); f:SetFrameStrata("DIALOG")
    f:EnableMouse(true); f:SetClampedToScreen(true); f:SetMovable(true)
    local title=W.Label(f,"WorldLearner",24); title:SetPoint("TOPLEFT",24,-18)
    local subtitle=W.Label(f,"Learn the world, one name at a time",12)
    subtitle:SetPoint("TOPLEFT",25,-48)
    local drag=CreateFrame("Frame",nil,f)
    drag:SetPoint("TOPLEFT",0,0); drag:SetPoint("TOPRIGHT",-40,0); drag:SetHeight(65)
    drag:EnableMouse(true); drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart",function() f:StartMoving() end)
    drag:SetScript("OnDragStop",function() f:StopMovingOrSizing() end)
    local close=CreateFrame("Button",nil,f,"UIPanelCloseButton")
    close:SetPoint("TOPRIGHT",0,0); close:SetScript("OnClick",function() f:Hide() end)
    local pages,tabs={},{}
    local function selectPage(index)
        for i,p in ipairs(pages) do p:SetShown(i==index); tabs[i]:SetEnabled(i~=index) end
    end
    for i,name in ipairs({"Hover","Languages","Panel","Minimap"}) do
        local p=CreateFrame("Frame",nil,f)
        p:SetPoint("TOPLEFT",0,-108); p:SetPoint("BOTTOMRIGHT",0,60)
        pages[i]=p
        local index=i
        tabs[i]=W.Button(f,name,110,function() selectPage(index) end)
        tabs[i]:SetPoint("TOPLEFT",24+(i-1)*117,-76)
    end
    local p=pages[1]
    checkbox(p,"enabled","Enable WorldLearner",0)
    checkbox(p,"npcs","Creatures and NPCs",34)
    checkbox(p,"items","Inventory and other item tooltips",68)
    checkbox(p,"combat","Show during combat",102)
    checkbox(p,"sticky","Keep panel while activation key is held",136)
    cycle(p,"modifier","Activation",{{"SHIFT","Hold Shift"},{"ALT","Hold Alt"},{"CTRL","Hold Ctrl"},{"ALWAYS","Always"}},182)
    note(p,"Move onto the panel to hover words. Pin keeps it open after releasing the key. With Always, a sticky panel stays until replaced or closed. Player names are excluded.",229)
    p=pages[2]
    checkbox(p,"chinese","Show Chinese name",0)
    checkbox(p,"pinyin","Show pinyin underneath",34)
    checkbox(p,"english","Show English underneath",68)
    checkbox(p,"wordHover","Word-hover pronunciation and definitions",102)
    checkbox(p,"showMissing","Show names with incomplete translations",136)
    note(p,"English names come from the Classic database. Pinyin uses ForeverLearner's dictionary and may need corrections for proper names. At least one language stays enabled.",192)
    p=pages[3]
    stepper(p,"chineseSize","Chinese text size",1,0)
    stepper(p,"pinyinSize","Pinyin text size",1,36)
    stepper(p,"englishSize","English text size",1,72)
    stepper(p,"width","Panel width",20,108)
    stepper(p,"opacity","Panel opacity",0.05,144,function(v) return math.floor(v*100+0.5).."%" end)
    cycle(p,"anchor","Position",{{"CURSOR","Near initial cursor"},{"FIXED","Fixed position"}},182)
    checkbox(p,"locked","Lock reading panel position",220)
    note(p,"Drag the reading panel's title bar to choose a fixed position. Cursor mode places it once so it stays still while you read.",264)
    p=pages[4]
    checkbox(p,"minimap","Show minimap button",0)
    checkbox(p,"minimapLocked","Lock minimap button position",34)
    stepper(p,"minimapAngle","Position around minimap",15,82,function(v) return tostring(math.floor(v)).." deg" end)
    note(p,"Left-click: open this menu\nRight-click: enable / disable\nDrag: move around the minimap\n\n/wl opens settings even if the button is hidden.\n/wl minimap restores a hidden button.",132)
    note(p,"WorldLearner 0.1.0\nIndependent companion to ForeverLearner. No network connection is used in game.",256)
    local preview=W.Button(f,"Preview",100,W.Preview); preview:SetPoint("BOTTOMLEFT",24,20)
    local reset=W.Button(f,"Reset settings",130,W.Reset); reset:SetPoint("BOTTOM",0,20)
    local done=W.Button(f,"Done",100,function() f:Hide() end); done:SetPoint("BOTTOMRIGHT",-24,20)
    W.RefreshSettings(); selectPage(1); f:Hide()
    tinsert(UISpecialFrames,"WorldLearnerSettings")
end
function W.ToggleSettings()
    W.RefreshSettings(); W.settings:SetShown(not W.settings:IsShown())
end
