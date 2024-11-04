---@class AddOnPresetsNS
local ns = select(2, ...)

local Locale = GetLocale()

---@class AddOnPresetsLocale
local L = setmetatable({}, { __index = function (_, key) return format("[%s] %s", Locale, key) end })

L.YOU_HAVE_NO_PRESETS = "You have no presets."
L.OPEN = "Open"
L.CONFIGURE = "Configure"
L.PARTIALLY_LOADED = "Some AddOns are loaded."
L.YOU_ARE_IN_COMBAT = "You are in combat. Type |cffFFFF55/reload|r when convenient."
L.YOU_HAVE_TOO_MANY_POPUPS_OPEN = "You have too many popups open. Please close some, then try again."
L.DO_YOU_WANT_TO_APPLY_THESE_CHANGES = "Do you want to apply these changes?"
L.CLICKING_SS_WILL_RELOAD_YOUR_INTERFACE = "Clicking |cffFFFF55%s|r will reload your interface."
L.DO_YOU_WANT_TO_CREATE_THIS_PRESET = "Do you want to save this preset?"
L.ENTER_PRESET_NAME_AND_CLICK_SS = "Enter your preset name and click |cffFFFF55%s|r to save it."
L.EDIT_PRESET_SS = "Edit preset |cffFFFF55%s|r"
L.ENTER_NEW_NAME_OR_DELETE = "Enter new preset name, or delete it."
L.CREATE_PRESET = "Create preset"
L.CREATE_PRESET_INFO = "Check all relevant AddOns, then once finished, close the menu to continue."
L.UNTITLED_PRESET = "Untitled preset"
L.LOCK_MINIMAP = "Lock minimap"
L.TOGGLE = "Toggle"

ns.L = L
