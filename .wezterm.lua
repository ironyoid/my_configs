-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action
-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Batman'
config.window_background_opacity = 1.0
--config.window_background_image = '/home/nikitapichugin/wezterm_back.jpeg'
config.window_background_image_hsb = {
    -- Darken the background image by reducing it to 1/3rd
    brightness = 0.1,

    -- You can adjust the hue by scaling its value.
    -- a multiplier of 1.0 leaves the value unchanged.
    hue = 1.0,

    -- You can adjust the saturation also.
    saturation = 1.0,
}

config.keys = {

    { key = 'UpArrow',   mods = 'CTRL|SUPER', action = act.ScrollByLine(-5) },
    { key = 'DownArrow', mods = 'CTRL|SUPER', action = act.ScrollByLine(5) },

}

config.key_tables = {
    copy_mode = {
        { key = 'Tab', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
        {
            key = 'LeftArrow',
            mods = 'CTRL',
            action = act.CopyMode 'MoveBackwardWord',
        },
        {
            key = 'Enter',
            mods = 'NONE',
            action = act.CopyMode 'MoveToStartOfNextLine',
        },
        {
            key = 'Escape',
            mods = 'NONE',
            action = act.Multiple {
                { CopyMode = 'Close' },
            },
        },
        {
            key = 'Space',
            mods = 'NONE',
            action = act.CopyMode { SetSelectionMode = 'Cell' },
        },
        {
            key = '$',
            mods = 'NONE',
            action = act.CopyMode 'MoveToEndOfLineContent',
        },
        {
            key = '$',
            mods = 'SHIFT',
            action = act.CopyMode 'MoveToEndOfLineContent',
        },
        { key = ',',   mods = 'NONE', action = act.CopyMode 'JumpReverse' },
        { key = '0',   mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
        { key = ';',   mods = 'NONE', action = act.CopyMode 'JumpAgain' },
        {
            key = 'F',
            mods = 'NONE',
            action = act.CopyMode { JumpBackward = { prev_char = false } },
        },
        {
            key = 'F',
            mods = 'SHIFT',
            action = act.CopyMode { JumpBackward = { prev_char = false } },
        },
        {
            key = 'G',
            mods = 'NONE',
            action = act.CopyMode 'MoveToScrollbackBottom',
        },
        {
            key = 'G',
            mods = 'SHIFT',
            action = act.CopyMode 'MoveToScrollbackBottom',
        },
        { key = 'H', mods = 'NONE', action = act.CopyMode 'MoveToViewportTop' },
        {
            key = 'H',
            mods = 'SHIFT',
            action = act.CopyMode 'MoveToViewportTop',
        },
        {
            key = 'L',
            mods = 'NONE',
            action = act.CopyMode 'MoveToViewportBottom',
        },
        {
            key = 'L',
            mods = 'SHIFT',
            action = act.CopyMode 'MoveToViewportBottom',
        },
        {
            key = 'M',
            mods = 'NONE',
            action = act.CopyMode 'MoveToViewportMiddle',
        },
        {
            key = 'M',
            mods = 'SHIFT',
            action = act.CopyMode 'MoveToViewportMiddle',
        },
        {
            key = 'O',
            mods = 'NONE',
            action = act.CopyMode 'MoveToSelectionOtherEndHoriz',
        },
        {
            key = 'O',
            mods = 'SHIFT',
            action = act.CopyMode 'MoveToSelectionOtherEndHoriz',
        },
        {
            key = 'T',
            mods = 'NONE',
            action = act.CopyMode { JumpBackward = { prev_char = true } },
        },
        {
            key = 'T',
            mods = 'SHIFT',
            action = act.CopyMode { JumpBackward = { prev_char = true } },
        },
        {
            key = 'V',
            mods = 'NONE',
            action = act.CopyMode { SetSelectionMode = 'Line' },
        },
        {
            key = 'V',
            mods = 'SHIFT',
            action = act.CopyMode { SetSelectionMode = 'Line' },
        },
        {
            key = '^',
            mods = 'NONE',
            action = act.CopyMode 'MoveToStartOfLineContent',
        },
        {
            key = '^',
            mods = 'SHIFT',
            action = act.CopyMode 'MoveToStartOfLineContent',
        },
        { key = 'b', mods = 'NONE', action = act.CopyMode 'MoveBackwardWord' },
        { key = 'b', mods = 'ALT',  action = act.CopyMode 'MoveBackwardWord' },
        { key = 'b', mods = 'CTRL', action = act.CopyMode 'PageUp' },
        {
            key = 'c',
            mods = 'CTRL',
            action = act.Multiple {

                { CopyMode = 'Close' },
            },
        },
        {
            key = 'DownArrow',
            mods = 'CTRL|SUPER',
            action = act.CopyMode { MoveByPage = 0.5 },
        },
        {
            key = 'RightArrow',
            mods = 'CTRL',
            action = act.CopyMode 'MoveForwardWordEnd',
        },
        {
            key = 'f',
            mods = 'NONE',
            action = act.CopyMode { JumpForward = { prev_char = false } },
        },
        { key = 'f', mods = 'ALT',  action = act.CopyMode 'MoveForwardWord' },
        { key = 'f', mods = 'CTRL', action = act.CopyMode 'PageDown' },
        {
            key = 'g',
            mods = 'NONE',
            action = act.CopyMode 'MoveToScrollbackTop',
        },
        {
            key = 'g',
            mods = 'CTRL',
            action = act.Multiple {

                { CopyMode = 'Close' },
            },
        },
        { key = 'h', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
        { key = 'j', mods = 'NONE', action = act.CopyMode 'MoveDown' },
        { key = 'k', mods = 'NONE', action = act.CopyMode 'MoveUp' },
        { key = 'l', mods = 'NONE', action = act.CopyMode 'MoveRight' },
        {
            key = 'm',
            mods = 'ALT',
            action = act.CopyMode 'MoveToStartOfLineContent',
        },
        {
            key = 'o',
            mods = 'NONE',
            action = act.CopyMode 'MoveToSelectionOtherEnd',
        },
        {
            key = 'q',
            mods = 'NONE',
            action = act.Multiple {

                { CopyMode = 'Close' },
            },
        },
        {
            key = 't',
            mods = 'NONE',
            action = act.CopyMode { JumpForward = { prev_char = true } },
        },
        {
            key = 'UpArrow',
            mods = 'CTRL|SUPER',
            action = act.CopyMode { MoveByPage = -0.5 },
        },
        {
            key = 'v',
            mods = 'NONE',
            action = act.CopyMode { SetSelectionMode = 'Cell' },
        },
        {
            key = 'v',
            mods = 'CTRL',
            action = act.CopyMode { SetSelectionMode = 'Block' },
        },
        { key = 'w',        mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
        {
            key = 'y',
            mods = 'NONE',
            action = act.Multiple {
                { CopyTo = 'ClipboardAndPrimarySelection' },

                { CopyMode = 'Close' },
            },
        },
        { key = 'PageUp',   mods = 'NONE', action = act.CopyMode 'PageUp' },
        { key = 'PageDown', mods = 'NONE', action = act.CopyMode 'PageDown' },
        {
            key = 'End',
            mods = 'NONE',
            action = act.CopyMode 'MoveToEndOfLineContent',
        },
        {
            key = 'Home',
            mods = 'NONE',
            action = act.CopyMode 'MoveToStartOfLine',
        },
        { key = 'LeftArrow', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
        {
            key = 'LeftArrow',
            mods = 'ALT',
            action = act.CopyMode 'MoveBackwardWord',
        },
        {
            key = 'RightArrow',
            mods = 'NONE',
            action = act.CopyMode 'MoveRight',
        },
        {
            key = 'RightArrow',
            mods = 'ALT',
            action = act.CopyMode 'MoveForwardWord',
        },
        { key = 'UpArrow',   mods = 'NONE', action = act.CopyMode 'MoveUp' },
        { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'MoveDown' },
    }

}
config.quick_select_patterns = {
    -- match things that look like sha1 hashes
    -- (this is actually one of the default patterns)
    -- '[0-9a-f]{7,40}',
}
-- and finally, return the configuration to wezterm
return config
