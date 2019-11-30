-- Wrapper around awful keybindings
--
-- First, this module allows shorter keybing descriptions.
-- A binding of Super+Control+A can be written as `M-C-a`
--
-- Second it automatically converts key symbols to the
-- corresponding key codes, for example `A` to `#38`.
-- This allows keybings to work and remain the same when
-- the keyboard layout is switched to a different language.

local awful = require('awful')

-- Use `Super` as the modifier key
local modkey = 'Mod4'

-- Key codes corresponding to key symbol names.
-- TODO: this mapping most likely changes between hardware, it might
-- be better to generate it dynamically (for example with `xmodmap`).
local KEYSYM_TO_KEYCODE = {
    ['Escape'] = 9,
    ['1'] = 10,
    ['2'] = 11,
    ['3'] = 12,
    ['4'] = 13,
    ['5'] = 14,
    ['6'] = 15,
    ['7'] = 16,
    ['8'] = 17,
    ['9'] = 18,
    ['0'] = 19,
    ['minus'] = 20,
    ['equal'] = 21,
    ['BackSpace'] = 22,
    ['Tab'] = 23,
    ['q'] = 24,
    ['w'] = 25,
    ['e'] = 26,
    ['r'] = 27,
    ['t'] = 28,
    ['y'] = 29,
    ['u'] = 30,
    ['i'] = 31,
    ['o'] = 32,
    ['p'] = 33,
    ['['] = 34,     -- bracketleft
    [']'] = 35,     -- bracketright
    ['Return'] = 36,
    ['Control_L'] = 37,
    ['a'] = 38,
    ['s'] = 39,
    ['d'] = 40,
    ['f'] = 41,
    ['g'] = 42,
    ['h'] = 43,
    ['j'] = 44,
    ['k'] = 45,
    ['l'] = 46,
    [';'] = 47,     -- semicolon
    ['\''] = 48,    -- apostrophe
    ['`'] = 49,     -- grave
    ['Shift_L'] = 50,
    ['\\'] = 51,    -- backslash
    ['z'] = 52,
    ['x'] = 53,
    ['c'] = 54,
    ['v'] = 55,
    ['b'] = 56,
    ['n'] = 57,
    ['m'] = 58,
    [','] = 59,     -- comma
    ['.'] = 60,     -- period
    ['/'] = 61,     -- slash
    ['Shift_R'] = 62,
    ['KP_Multiply'] = 63,
    ['Alt_L'] = 64,
    ['space'] = 65,
    ['Caps_Lock'] = 66,
    ['F1'] = 67,
    ['F2'] = 68,
    ['F3'] = 69,
    ['F4'] = 70,
    ['F5'] = 71,
    ['F6'] = 72,
    ['F7'] = 73,
    ['F8'] = 74,
    ['F9'] = 75,
    ['F10'] = 76,
    ['Num_Lock'] = 77,
    ['Scroll_Lock'] = 78,
    ['KP_Home'] = 79,
    ['KP_Up'] = 80,
    ['KP_Prior'] = 81,
    ['KP_Subtract'] = 82,
    ['KP_Left'] = 83,
    ['KP_Begin'] = 84,
    ['KP_Right'] = 85,
    ['KP_Add'] = 86,
    ['KP_End'] = 87,
    ['KP_Down'] = 88,
    ['KP_Next'] = 89,
    ['KP_Insert'] = 90,
    ['KP_Delete'] = 91,
    ['ISO_Level3_Shift'] = 92,
    ['less'] = 94,
    ['F11'] = 95,
    ['F12'] = 96,
    ['KP_Enter'] = 104,
    ['Control_R'] = 105,
    ['KP_Divide'] = 106,
    ['Print'] = 107,
    ['Alt_R'] = 108,
    ['Linefeed'] = 109,
    ['Home'] = 110,
    ['Up'] = 111,
    ['Prior'] = 112,
    ['Left'] = 113,
    ['Right'] = 114,
    ['End'] = 115,
    ['Down'] = 116,
    ['Next'] = 117,
    ['Insert'] = 118,
    ['Delete'] = 119,
    ['XF86AudioMute'] = 121,
    ['XF86AudioLowerVolume'] = 122,
    ['XF86AudioRaiseVolume'] = 123,
    ['XF86PowerOff'] = 124,
    ['KP_Equal'] = 125,
    ['plusminus'] = 126,
    ['Pause'] = 127,
    ['XF86LaunchA'] = 128,
    ['KP_Decimal'] = 129,
    ['Super_L'] = 133,
    ['Super_R'] = 134,
    ['Menu'] = 135,
    ['Cancel'] = 136,
    ['Redo'] = 137,
    ['SunProps'] = 138,
    ['Undo'] = 139,
    ['SunFront'] = 140,
    ['XF86Copy'] = 141,
    ['XF86Open'] = 142,
    ['XF86Paste'] = 143,
    ['Find'] = 144,
    ['XF86Cut'] = 145,
    ['Help'] = 146,
    ['XF86MenuKB'] = 147,
    ['XF86Calculator'] = 148,
    ['XF86Sleep'] = 150,
    ['XF86WakeUp'] = 151,
    ['XF86Explorer'] = 152,
    ['XF86Send'] = 153,
    ['XF86Xfer'] = 155,
    ['XF86Launch1'] = 156,
    ['XF86Launch2'] = 157,
    ['XF86WWW'] = 158,
    ['XF86DOS'] = 159,
    ['XF86ScreenSaver'] = 160,
    ['XF86RotateWindows'] = 161,
    ['XF86TaskPane'] = 162,
    ['XF86Mail'] = 163,
    ['XF86Favorites'] = 164,
    ['XF86MyComputer'] = 165,
    ['XF86Back'] = 166,
    ['XF86Forward'] = 167,
    ['XF86Eject'] = 169,
    ['XF86Eject'] = 170,
    ['XF86AudioNext'] = 171,
    ['XF86AudioPlay'] = 172,
    ['XF86AudioPrev'] = 173,
    ['XF86AudioStop'] = 174,
    ['XF86AudioRecord'] = 175,
    ['XF86AudioRewind'] = 176,
    ['XF86Phone'] = 177,
    ['XF86Tools'] = 179,
    ['XF86HomePage'] = 180,
    ['XF86Reload'] = 181,
    ['XF86Close'] = 182,
    ['XF86ScrollUp'] = 185,
    ['XF86ScrollDown'] = 186,
    ['parenleft'] = 187,
    ['parenright'] = 188,
    ['XF86New'] = 189,
    ['Redo'] = 190,
    ['XF86Tools'] = 191,
    ['XF86Launch5'] = 192,
    ['XF86Launch6'] = 193,
    ['XF86Launch7'] = 194,
    ['XF86Launch8'] = 195,
    ['XF86Launch9'] = 196,
    ['XF86AudioMicMute'] = 198,
    ['XF86TouchpadToggle'] = 199,
    ['XF86TouchpadOn'] = 200,
    ['XF86TouchpadOff'] = 201,
    ['Mode_switch'] = 203,
    ['XF86AudioPlay'] = 208,
    ['XF86AudioPause'] = 209,
    ['XF86Launch3'] = 210,
    ['XF86Launch4'] = 211,
    ['XF86LaunchB'] = 212,
    ['XF86Suspend'] = 213,
    ['XF86Close'] = 214,
    ['XF86AudioPlay'] = 215,
    ['XF86AudioForward'] = 216,
    ['Print'] = 218,
    ['XF86WebCam'] = 220,
    ['XF86Mail'] = 223,
    ['XF86Messenger'] = 224,
    ['XF86Search'] = 225,
    ['XF86Go'] = 226,
    ['XF86Finance'] = 227,
    ['XF86Game'] = 228,
    ['XF86Shop'] = 229,
    ['Cancel'] = 231,
    ['XF86MonBrightnessDown'] = 232,
    ['XF86MonBrightnessUp'] = 233,
    ['XF86AudioMedia'] = 234,
    ['XF86Display'] = 235,
    ['XF86KbdLightOnOff'] = 236,
    ['XF86KbdBrightnessDown'] = 237,
    ['XF86KbdBrightnessUp'] = 238,
    ['XF86Send'] = 239,
    ['XF86Reply'] = 240,
    ['XF86MailForward'] = 241,
    ['XF86Save'] = 242,
    ['XF86Documents'] = 243,
    ['XF86Battery'] = 244,
    ['XF86Bluetooth'] = 245,
    ['XF86WLAN'] = 246,
    ['XF86WWAN'] = 254,
    ['XF86RFKill'] = 255,
}

-- Human readeable names of the keys
local KEYSYM_TO_KEYNAME = {
    ['Escape'] = 'Esc',
    ['1'] = '1',
    ['2'] = '2',
    ['3'] = '3',
    ['4'] = '4',
    ['5'] = '5',
    ['6'] = '6',
    ['7'] = '7',
    ['8'] = '8',
    ['9'] = '9',
    ['0'] = '0',
    ['minus'] = '-',
    ['equal'] = '=',
    ['BackSpace'] = 'BackSpc',
    ['Tab'] = 'Tab',
    ['q'] = 'q',
    ['w'] = 'w',
    ['e'] = 'e',
    ['r'] = 'r',
    ['t'] = 't',
    ['y'] = 'y',
    ['u'] = 'u',
    ['i'] = 'i',
    ['o'] = 'o',
    ['p'] = 'p',
    ['['] = '[',
    [']'] = ']',
    ['Return'] = 'Enter',
    ['a'] = 'a',
    ['s'] = 's',
    ['d'] = 'd',
    ['f'] = 'f',
    ['g'] = 'g',
    ['h'] = 'h',
    ['j'] = 'j',
    ['k'] = 'k',
    ['l'] = 'l',
    [';'] = ';',
    ['\''] = '\'',
    ['`'] = '`',
    ['\\'] = '\\',
    ['z'] = 'z',
    ['x'] = 'x',
    ['c'] = 'c',
    ['v'] = 'v',
    ['b'] = 'b',
    ['n'] = 'n',
    ['m'] = 'm',
    [','] = ',',
    ['.'] = '.',
    ['/'] = '/',
    ['space'] = 'Space',
    ['F1'] = 'F1',
    ['F2'] = 'F2',
    ['F3'] = 'F3',
    ['F4'] = 'F4',
    ['F5'] = 'F5',
    ['F6'] = 'F6',
    ['F7'] = 'F7',
    ['F8'] = 'F8',
    ['F9'] = 'F9',
    ['F10'] = 'F10',
    ['F11'] = 'F11',
    ['F12'] = 'F12',
    ['Home'] = 'Home',
    ['End'] = 'End',
    ['Prior'] = 'PgUp',
    ['Next'] = 'PgDn',
    ['Insert'] = 'Ins',
    ['Delete'] = 'Del',
    ['Up'] = '↑',
    ['Left'] = '←',
    ['Right'] = '→',
    ['Down'] = '↓',
    ['KP_Enter'] = 'KP Enter',
    ['KP_Multiply'] = 'KP *',
    ['KP_Divide'] = 'KP /',
    ['KP_Subtract'] = 'KP -',
    ['KP_Add'] = 'KP +',
    ['KP_Equal'] = 'Kp =',
    ['KP_Decimal'] = 'KP .',
    ['KP_Home'] = 'KP Home',
    ['KP_End'] = 'KP End',
    ['KP_Begin'] = 'KP Begin',
    ['KP_Prior'] = 'KP PgUp',
    ['KP_Next'] = 'KP PgDn',
    ['KP_Insert'] = 'KP Ins',
    ['KP_Delete'] = 'KP Del',
    ['KP_Up'] = 'KP ↑',
    ['KP_Left'] = 'KP ←',
    ['KP_Right'] = 'KP →',
    ['KP_Down'] = 'KP ↓',
}

-- Human readeable names for the help widget
local AWFUL_LABELS = (function()
    local t = {
        Mod4='M',       -- Super
        Mod1='A',       -- Alt
        Control='C',    -- Ctrl
        Shift='S'       -- Shift
    }

    for k, v in pairs(KEYSYM_TO_KEYNAME) do
        t['#' .. KEYSYM_TO_KEYCODE[k]] = v
    end

    return t
end)()

local split_mods = function(keys)
    local mods = {}
    local key_name = nil

    for _, part in ipairs(string.split(keys, '-')) do
        if     part == 'M' then table.insert(mods, modkey)
        elseif part == 'C' then table.insert(mods, 'Control')
        elseif part == 'S' then table.insert(mods, 'Shift')
        elseif part == 'A' then table.insert(mods, 'Mod1')
        else   key_name = part end
    end

    return mods, key_name
end

local translate_key_name = function(key_name)
    local key_code = KEYSYM_TO_KEYCODE[key_name]

    if key_code then
        return '#' .. tostring(key_code)
    else
        return key_name
    end
end

local key = function(keys, action, desc)
    local mods, key_name = split_mods(keys)
    local key = translate_key_name(key_name)

    return awful.key(mods, key, action, desc)
end

return {
    AWFUL_LABELS = AWFUL_LABELS,
    key = key,
}
