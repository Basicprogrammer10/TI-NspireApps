-- Morse Code - 5/15/2021
-- By Connor Slade

-- Some Config Options
local version = "1.2.2"       -- Version Displayed under Info
local speed = 0.3             -- Default Speed
local looping = false         -- If looping is enabled by default
local defaultColor = 0xffffff -- Default Flash Color (0xrrggbb)
local text = "Hello World :P" -- Default Text

local presets = {             -- Preset Text
    "SOS",
    "Nose",
    "Hello World"
}

local morseCode = {           -- Text to Morse Code conversion
    ["A"] = ".-",
    ["B"] = "-...",
    ["C"] = "-.-.",
    ["D"] = "-..",
    ["E"] = ".",
    ["F"] = "..-",
    ["G"] = "--.",
    ["H"] = "....",
    ["I"] = "..",
    ["J"] = ".---",
    ["K"] = "-.-",
    ["L"] = ".-.",
    ["M"] = "--",
    ["N"] = "-.",
    ["O"] = "---",
    ["P"] = ".--.",
    ["Q"] = "--.-",
    ["R"] = ".-",
    ["S"] = "...",
    ["T"] = "-",
    ["U"] = "..-",
    ["V"] = "...-",
    ["W"] = ".--",
    ["X"] = "-..",
    ["Y"] = "-.--",
    ["Z"] = "--.",
    ["0"] = "-----",
    ["1"] = ".----",
    ["2"] = "..---",
    ["3"] = "...--",
    ["4"] = "....-",
    ["5"] = "....",
    ["6"] = "-....",
    ["7"] = "--...",
    ["8"] = "---..",
    ["9"] = "----",
    ["."] = ".-.-.-",
    [","] = "--..--",
    ["?"] = "..--..",
    ["'"] = ".----.",
    ["!"] = "-.-.--",
    ["/"] = "-..-",
    ["("] = "-.--.",
    [")"] = "-.--.-",
    ["&"] = ".-...",
    [":"] = "---...",
    [";"] = "-.-.-.",
    ["="] = "-...",
    ["+"] = ".-.-.",
    ["-"] = "-....-",
    ["_"] = "..--.-",
    ['"'] = ".-..-.",
    ["$"] = "...-..-",
    ["@"] = ".--.-",
    ["¿"] = "..-.-",
    ["¡"] = "--..."
}

-- Don't Change This
local time = 1
local timeWait = 1
local textIndex = 1
local charIndex = 1
local toFlash = {}
local nextChar = false
local running = false
local windowSize = {
    platform.window:width(),
    platform.window:height()
}

--- Convert a String to a Table
---@param str string
function stringToArray(str)
    local t = {}
    for i = 1, #str do
        local char = str:sub(i, i)
        table.insert(t, char)
    end
    return t
end

--- Safely Change value with min and max
---@param value number
---@param inc number
---@param min number
---@param max number
function safeCng(value, inc, min, max)
    value = value + inc
    if value >= max then
        return max
    end
    if value <= min then
        return min
    end
    return value
end

--- Does... Nothing!
function nullFunc()
end

--- Align text to Left, Right, Top or bottom (Or all)
---@param gc any
---@param text string
---@param l boolean
---@param r boolean
---@param t boolean
---@param b boolean
---@param padding table
function alignText(gc, text, l, r, t, b, padding)
    local xy = {0, 0}
    padding = padding or {0, 0}
    if r then xy[1] = windowSize[1] - gc:getStringWidth(text) end
    if l and r then xy[1] = windowSize[1]/2 - gc:getStringWidth(text)/2 end
    if b then xy[2] = windowSize[2] - gc:getStringHeight(text) end
    if t and b then xy[2] = windowSize[2]/2 - gc:getStringHeight(text)/2 end
    gc:drawString(text, xy[1] + padding[1], xy[2] + padding[2])
end

--- Add a ... to a string if it's too long
---@param gc any
---@param string string
---@param real string
function dotString(gc, string, real)
    if gc:getStringWidth(string) <= windowSize[1] - gc:getStringWidth("..."..real) then
        return string
    end
    for i = 1,#string do
        string = string:sub(1, #string - 1)
        if gc:getStringWidth(string) < windowSize[1] - gc:getStringWidth("..."..real) then
            return string.."..."
        end
    end
    return ""
end

--- Round a Number
---@param num number
---@param dps number
function round(num, dps)
  local mult = 10^(dps or 0)
  return math.floor(num * mult + 0.5) / mult
end

--- Random Hex number
---@param len number
function randHex(len)
    local hex = {1, 2, 3, 4, 5, 6, 7, 8, 9, 'a', 'b', 'c', 'd', 'e', 'f'}
    local working = ""
    for i = 1, len do
        working = working..hex[math.random(#hex)]
    end
    return working
end

--- Re render Window and Mark as changed
function docChanged()
    platform.window:invalidate()
    document.markChanged()
end



--- Toggle if Morse code is being shown
---@param value boolean
function toggleRunning(value)
    if value == nil then
        value = not running
    end
    if value then
        cursor.hide()
        timer.start(speed)
        running = true
        return
    end
    platform.window:setBackgroundColor(0x0000000)
    timer.stop(speed)
    time = 1
    timeWait = 1
    textIndex = 1
    charIndex = 1
    nextChar = false
    running = false
end

--- Change Timer Speed
---@param inc number
function changeSpeed(inc)
    speed = safeCng(speed, inc, 0.1, 1)
    timer.start(speed)
    menu[2][2][1] = "Speed = " .. tostring(speed)
    toolpalette.register(menu)
end

--- Loads a preset
---@param preset string
function loadPreset(preset)
    text = preset
    toFlash = stringToArray(preset)
    docChanged()
end

--- Change Flash Color
---@param color number (hex)
function loadColor(color)
    if color == nil then
        color = '0x'..randHex(2)..randHex(2)..randHex(2)
    end
    defaultColor = color
    docChanged()
end

--- Toggle if code should loop
---@param value boolean
function toggleLooping(value)
    if not not value then
        looping = not looping
    else
        looping = value
    end
    docChanged()
end

--- Reset all Vars
function resetAll()
    speed = 0.3
    looping = false
    defaultColor = 0xffffff
    text = "Hello World :P"
    time = 1
    timeWait = 1
    textIndex = 1
    charIndex = 1
    toFlash = {}
    nextChar = false
    running = false
    docChanged()
end



function on.activate()
    platform.window:setBackgroundColor(0x0000000)
    toFlash = stringToArray(text)
    
    menu = {
        {"State",
            {"Start", function() toggleRunning(true) end},
            {"Stop", function() toggleRunning(false) end},
            {"Tick", simTick},
            {"Loop", toggleLooping}
        },
        {"Speed",
            {"Speed = " .. tostring(speed), nullFunc},
            {"+", function() changeSpeed(0.1) end},
            {"-", function() changeSpeed(-0.1) end}
        },
        {"Presets"
        },
        {"Colors",
            {"Random", function() loadColor() end},
            "-",
            {"White", function() loadColor(0xffffff) end},
            {"Red", function() loadColor(0xff0000) end},
            {"Green", function() loadColor(0x00ff00) end},
            {"Blue", function() loadColor(0x0000ff) end},
            {"Purple", function() loadColor(0xff00ff) end}
        },
        {"Info",
            {"By: Connor Slade", nullFunc},
            {"Created: 5/15/2021", nullFunc},
            {"Version: "..version, nullFunc},
            {"Reset", resetAll}
        }
    }
    
    for i in ipairs(presets) do
        menu[3][i + 1] = {presets[i], function() loadPreset(presets[i]) end}
    end

    toolpalette.register(menu)
end

function on.paint(gc)
    if not running then
        gc:setColorRGB(240, 0, 0) 
        gc:fillRect(8, 5, 5, 20)
        gc:fillRect(16, 5, 5, 20)
        gc:setColorRGB(0xffffff)
        gc:setFont("sansserif", "r", 9)
        local speed = tostring(round(0.3 / speed, 1)) .. "x "
        alignText(gc, "Connor S ", false, true, true, false)
        gc:setColorRGB(defaultColor)
        alignText(gc, dotString(gc, " Text: " .. text, speed), true, false, false, true)
        gc:setColorRGB(26, 150, 255)
        alignText(gc, speed, false, true, false, true)
        gc:setColorRGB(240, 0, 0) 
        if looping then
            gc:setFont("sansserif", "r", 13)
            alignText(gc, "∞", false, true, false, true, {-1, -8})
            return
        end
        return
    end
    gc:setColorRGB(0, 240, 45)
    gc:fillPolygon({8, 5, 25, 15, 8, 25})
end

--- Simulate One tick
function simTick()
    time = time + 1

    if timeWait > time - 1 then return end

    if textIndex > #toFlash then
        platform.window:setBackgroundColor(0x000000)
        if looping then
            textIndex = 1
            timeWait = time + 9
            docChanged()
            return
        end
        toggleRunning(false)
        docChanged()
        return
    end

    local textChar = string.upper(toFlash[textIndex])
    local color = defaultColor

    if nextChar then
        platform.window:setBackgroundColor(0x000000)
        timeWait = time
        nextChar = false
        docChanged()
        return
    end

    if textChar == " " then
        timeWait = time + 6
        textIndex = textIndex + 1
        return
    end
    
    local currentChar = stringToArray(morseCode[textChar])[charIndex]
    charIndex = charIndex + 1
    nextChar = true

    if currentChar == "-" then timeWait = time + 2
    elseif currentChar == "." then timeWait = time
    elseif currentChar == nil then
        timeWait = time
        color = 0x000000
    end

    if charIndex > #morseCode[string.upper(toFlash[textIndex])] then
        charIndex = 0
        textIndex = textIndex + 1
    end

    platform.window:setBackgroundColor(color)
    docChanged()
end

function on.timer()
    if running then simTick() end
end

function on.resize(width, height)
    windowSize = {width, height}
end

function on.charIn(char)
    text = text..char
    toFlash = stringToArray(text)
    docChanged()
end

function on.backspaceKey()
    text = text:sub(1, #text-1)
    toFlash = stringToArray(text)
    docChanged()
end

function on.save()
    return {text, speed, looping, defaultColor}
end

function on.restore(state)
    if state[1] ~= nil then text = state[1] end
    if state[2] ~= nil then speed = state[2] end
    if state[3] ~= nil then looping = state[3] end
    if state[4] ~= nil then defaultColor = state[4] end
end

-- Keyboard Shortcuts

function on.enterKey()
    toggleRunning()
    docChanged()
end

function on.arrowUp()
    changeSpeed(-0.1)
    docChanged()
end

function on.arrowDown()
    changeSpeed(0.1)
    docChanged()
end