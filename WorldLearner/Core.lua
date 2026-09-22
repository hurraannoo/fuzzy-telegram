local name, W = ...
W.name = name
W.Dictionary, W.Glossary = {}, {}
W.defaults = {
    enabled=true, npcs=true, items=true, combat=true, wordHover=true,
    chinese=true, pinyin=true, english=true, showMissing=true,
    sticky=true, locked=false, minimap=true, minimapLocked=false,
    modifier="SHIFT", anchor="CURSOR", theme="CLASSIC", fadeAfter="OFF", chineseSize=22, pinyinSize=16,
    englishSize=16, width=340, opacity=0.96, minimapAngle=220,
}
W.bounds = {chineseSize={12,32},pinyinSize={10,26},englishSize={10,26},
    width={260,540},opacity={0.4,1},minimapAngle={0,360},x={-4000,4000},y={-4000,4000}}
local choices = {modifier={SHIFT=true,ALT=true,CTRL=true,ALWAYS=true},anchor={CURSOR=true,FIXED=true,NAMEPLATE=true},
    theme={CLASSIC=true,MODERN=true},fadeAfter={OFF=true,["5"]=true,["10"]=true}}
function W.IsReadable(v)
    if type(issecretvalue)=="function" and issecretvalue(v) then return false end
    return type(v)=="string"
end
function W.Initialize()
    if type(WorldLearnerDB)~="table" then WorldLearnerDB={} end
    W.db=WorldLearnerDB
    for key,default in pairs(W.defaults) do
        local value=W.db[key]
        if type(value)~=type(default) then W.db[key]=default
        elseif W.bounds[key] then
            local b=W.bounds[key]
            W.db[key]=value==value and math.max(b[1],math.min(b[2],value)) or default
        elseif choices[key] and not choices[key][value] then W.db[key]=default end
    end
    for _,key in ipairs({"x","y"}) do
        local value=W.db[key]
        if type(value)~="number" or value~=value then W.db[key]=nil
        else W.db[key]=math.max(-4000,math.min(4000,value)) end
    end
    if not W.db.chinese and not W.db.pinyin and not W.db.english then W.db.chinese=true end
end
function W.SetOption(key,value)
    if W.defaults[key]==nil then return end
    if type(value)~=type(W.defaults[key]) then return end
    if choices[key] and not choices[key][value] then return end
    if W.bounds[key] then
        if value~=value then return end
        value=math.max(W.bounds[key][1],math.min(W.bounds[key][2],value))
    end
    W.db[key]=value
    if not W.db.chinese and not W.db.pinyin and not W.db.english then W.db.chinese=true end
    if W.OptionsChanged then W.OptionsChanged() end
end
function W.Reset()
    for k,v in pairs(W.defaults) do W.db[k]=v end
    W.db.x,W.db.y=nil,nil
    if W.OptionsChanged then W.OptionsChanged() end
end
function W.Active()
    if not W.db or not W.db.enabled then return false end
    if not W.db.combat and InCombatLockdown and InCombatLockdown() then return false end
    local modifier=W.db.modifier
    return modifier=="ALWAYS" or modifier=="SHIFT" and IsShiftKeyDown()
        or modifier=="ALT" and IsAltKeyDown() or modifier=="CTRL" and IsControlKeyDown()
end
function W.NpcID(guid)
    if not W.IsReadable(guid) then return end
    local kind,id=guid:match("^(%a+)%-[^-]*%-[^-]*%-[^-]*%-[^-]*%-(%d+)%-")
    if kind=="Creature" or kind=="Vehicle" then return tonumber(id) end
end
function W.ItemID(link)
    if W.IsReadable(link) then return tonumber(link:match("item:(%d+)")) end
end
function W.Resolve(kind,id,native)
    native=W.Clean(native)
    if native=="" then return end
    local record=W.Entities[kind] and W.Entities[kind][id]
    local cn,en,status
    -- Require the displayed name to agree with the old database. Custom servers
    -- can reuse IDs; never attach an unrelated English name to a renamed entity.
    if record and (native==record[1] or native==record[2]) then
        cn,en,status=record[1],record[2],"Classic database"
    else
        cn=W.HasHan(native) and native or ""
        en=not W.HasHan(native) and native or ""
        status=record and "Name differs from Classic data" or "Name missing from Classic data"
    end
    if not W.db.showMissing and (cn=="" or en=="") then return end
    return {kind=kind,id=id,native=native,cn=cn,en=en,status=status,
        key=kind..":"..tostring(id)..":"..native}
end
