local _, F = ...
local punctuation = { ["，"] = ",", ["。"] = ".", ["！"] = "!", ["？"] = "?",
    ["；"] = ";", ["："] = ":", ["、"] = ",", ["（"] = "(", ["）"] = ")",
    ["“"] = '"', ["”"] = '"', ["「"] = '"', ["」"] = '"', ["…"] = "..." }

function F.Characters(text)
    local result = {}
    for char in string.gmatch(text, "[%z\1-\127\194-\244][\128-\191]*") do
        result[#result + 1] = char
    end
    return result
end
function F.IsHan(char)
    local a, b, c, d = string.byte(char, 1, 4)
    if not a then return false end
    local cp = a
    if a >= 240 and d then cp = (a-240)*262144 + (b-128)*4096 + (c-128)*64 + d-128
    elseif a >= 224 and c then cp = (a-224)*4096 + (b-128)*64 + c-128
    elseif a >= 192 and b then cp = (a-192)*64 + b-128 end
    return (cp >= 0x3400 and cp <= 0x9FFF) or (cp >= 0xF900 and cp <= 0xFAFF)
        or (cp >= 0x20000 and cp <= 0x323AF)
end
function F.HasHan(text)
    if not F.IsReadable(text) then return false end
    for _, char in ipairs(F.Characters(text)) do if F.IsHan(char) then return true end end
    return false
end

function F.Clean(text)
    if not F.IsReadable(text) then return "" end
    -- Keep visible link labels, never interpret player-provided links in our reader.
    text = text:gsub("|H.-|h(.-)|h", "%1"):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("|T.-|t", ""):gsub("|A.-|a", ""):gsub("|n", "\n")
    text = text:gsub("|", ""):gsub("\r", ""):gsub("[%z\1-\8\11\12\14-\31]", "")
    return text
end

function F.Lookup(word)
    if F.Glossary[word] then return F.Glossary[word] end
    local name = F.DatabaseNames and F.DatabaseNames[word]
    if name then
        local py = {}
        for _, char in ipairs(F.Characters(word)) do
            local entry = F.Dictionary[char]
            py[#py+1] = entry and entry[1]:match("^[^/]+") or char
        end
        local entry = {table.concat(py," "),name,name.." — named NPC (Classic database). Pinyin is a reading aid.","name"}
        F.Glossary[word] = entry
        return entry
    end
    return F.Dictionary[word]
end

function F.Tokenize(text)
    local chars, result = F.Characters(F.Clean(text)), {}
    local i = 1
    while i <= #chars do
        local found, span, word
        if F.IsHan(chars[i]) then
            for length = math.min(32, #chars-i+1), 1, -1 do
                local candidate = table.concat(chars, "", i, i+length-1)
                local entry = F.Lookup(candidate)
                if entry then found, span, word = entry, length, candidate; break end
            end
        end
        if found then
            result[#result+1] = {text=word, pinyin=found[1], gloss=found[2],
                definition=found[3], kind=found[4], known=true}
            i = i + span
        elseif F.IsHan(chars[i]) then
            result[#result+1] = {text=chars[i], pinyin=chars[i], gloss="["..chars[i].."]", kind="unknown"}
            i = i + 1
        else
            -- Keep Latin words and numbers together, without swallowing following Chinese.
            local j = i
            if chars[i]:match("[%w_]") then
                while j < #chars and chars[j+1]:match("[%w_'-]") and j-i < 32 do j=j+1 end
            end
            word = table.concat(chars, "", i, j)
            result[#result+1] = {text=word, pinyin=word, gloss=punctuation[word] or word, kind="literal"}
            i = j+1
        end
    end
    return result
end

function F.Layers(tokens)
    local py = ""
    for _, token in ipairs(tokens) do
        if not token.text:match("^%s+$") then
            local isPunctuation = token.kind == "literal"
                and (punctuation[token.text] or token.text:match("^[%p]+$"))
            if isPunctuation then
                py = py .. token.pinyin
            else
                local reading = token.pinyin:match("^%s*([^/]+)") or token.pinyin
                reading = reading:gsub("%s+$", "")
                py = py .. (py ~= "" and " " or "") .. reading
            end
        end
    end
    return py
end

-- Short Chinese blocks keep word wrapping manageable; all blocks remain visible by scrolling.
function F.Blocks(text)
    local blocks, pending = {}, {}
    for _, char in ipairs(F.Characters(F.Clean(text))) do
        if char == "\n" or #pending >= 180 then
            if #pending > 0 then blocks[#blocks+1] = table.concat(pending); pending = {} end
        end
        if char ~= "\n" then pending[#pending+1] = char end
        if char == "。" or char == "！" or char == "？" then
            blocks[#blocks+1] = table.concat(pending); pending = {}
        end
    end
    if #pending > 0 then blocks[#blocks+1] = table.concat(pending) end
    return blocks
end

function F.Document(title, text, source)
    title, text = F.Clean(title), F.Clean(text)
    return {title=title, text=text, source=source or "manual"}
end
F.demo = {
    title = "Offline reader demo / 离线阅读示例",
    text = "请前往暴风城，寻找你的朋友。\n不要半途而废。\n组我，副本来奶！",
    source = "demo",
}
