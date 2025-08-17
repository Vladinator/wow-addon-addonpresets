---@class StaticPopupPolyfill : Frame
---@field public which string
---@field public Text FontString
---@field public Button1 Button
---@field public Button2 Button
---@field public Button3 Button
---@field public EditBox EditBox
---@field public Resize? fun(self: StaticPopupPolyfill)
---@field public GetButton? fun(self: StaticPopupPolyfill, index: number): Button
---@field public text? FontString
---@field public button1? Button
---@field public button2? Button
---@field public button3? Button
---@field public editBox? EditBox

---@alias StaticPopupInfoPolyfillOnAccept fun(self: StaticPopupPolyfill)

---@class StaticPopupInfoPolyfill
---@field public text string
---@field public button1 string
---@field public button2 string
---@field public button3? string
---@field public OnButton1? fun(self: StaticPopupPolyfill)
---@field public OnButton2? fun(self: StaticPopupPolyfill)
---@field public OnButton3? fun(self: StaticPopupPolyfill)
---@field public selectCallbackByIndex? boolean
---@field public OnAccept StaticPopupInfoPolyfillOnAccept
---@field public OnCancel fun(self: StaticPopupPolyfill)
---@field public OnShow fun(self: StaticPopupPolyfill)
---@field public OnHide fun(self: StaticPopupPolyfill)
---@field public OnUpdate fun(self: StaticPopupPolyfill, elapsed: number)
---@field public EditBoxOnEnterPressed fun(self: EditBox)
---@field public EditBoxOnEscapePressed fun(self: EditBox)
---@field public EditBoxOnTextChanged fun(self: EditBox)
---@field public timeout number
---@field public whileDead number
---@field public exclusive number
---@field public showAlert number
---@field public hideOnEscape number
---@field public hasEditBox? number
---@field public maxLetters? number

local StaticPopup_Show = StaticPopup_Show ---@type fun(which: string, text_arg1?: string, text_arg2?: string, data?: any, insertedFrame?: Region): StaticPopupPolyfill?
local StaticPopup_FindVisible = StaticPopup_FindVisible ---@type fun(which: string, data?: any): StaticPopupPolyfill?
local StaticPopup_Resize = StaticPopup_Resize or function(frame) frame:Resize() end ---@type fun(frame: StaticPopupPolyfill, which: string)

---@param frame StaticPopupPolyfill
local function StaticPopup_GetTextFontString(frame)
    return frame.Text or frame.text
end

---@param frame StaticPopupPolyfill
local function StaticPopup_GetEditBox(frame)
    return frame.EditBox or frame.editBox
end

---@param frame StaticPopupPolyfill
---@param index number
local function StaticPopup_GetButton(frame, index)
    return frame[format("Button%d", index)] or frame[format("button%d", index)] or frame:GetButton(index)
end

---@type string
local addonName = ...

---@class AddOnPresetsNS
local ns = select(2, ...)
local L = ns.L

local ATLAS_ENABLED_MARKUP = ns.Atlas.ATLAS_ENABLED_MARKUP
local ATLAS_DISABLED_MARKUP = ns.Atlas.ATLAS_DISABLED_MARKUP

local StaticPopupNamePending = format("%sPending", addonName)
local StaticPopupNameNew = format("%sNew", addonName)
local StaticPopupNameEdit = format("%sEdit", addonName)

local noop = function() end

---@param self EditBox
---@return StaticPopupPolyfill frame
local function GetEditBoxParent(self)
    return self:GetParent() ---@diagnostic disable-line: return-type-mismatch
end

---@param self EditBox
---@return string? text
local function GetEditBoxText(self)
    local text = self:GetText()
    if not text then
        return
    end
    text = text:trim()
    if strlenutf8(text) > 0 then
        return text
    end
end

---@param frame StaticPopupPolyfill
---@return string? text
local function GetFrameEditBoxText(frame)
    local editBox = StaticPopup_GetEditBox(frame)
    return GetEditBoxText(editBox)
end

---@param self EditBox
local function OnTextChanged(self)
    local frame = GetEditBoxParent(self)
    local canAccept = GetEditBoxText(self) and true or false
    local button1 = StaticPopup_GetButton(frame, 1)
    button1:SetEnabled(canAccept)
end

---@param self EditBox
local function OnEnterPressed(self)
    local text = GetEditBoxText(self)
    if not text then
        return
    end
    local frame = GetEditBoxParent(self)
    local info = StaticPopupDialogs[frame.which] ---@type StaticPopupInfoPolyfill
    info.OnAccept(frame)
    frame:Hide()
end

---@param self EditBox
local function OnEscapePressed(self)
    self:ClearFocus()
end

---@param self StaticPopupPolyfill
local function OnShow(self)
    local editBox = StaticPopup_GetEditBox(self)
    editBox:SetAutoFocus(false)
    editBox:ClearFocus()
    if not InCombatLockdown() then
        editBox:SetFocus()
        C_Timer.After(0.5, function() if not InCombatLockdown() then editBox:SetFocus() end end)
    end
    OnTextChanged(editBox)
end

---@type StaticPopupInfoPolyfill
local StaticPopupPending = {
    text = "",
    button1 = YES,
    button2 = NO,
    OnAccept = noop,
    OnCancel = noop,
    OnShow = noop,
    OnHide = noop,
    OnUpdate = function(self)
        local button1 = StaticPopup_GetButton(self, 1)
        button1:SetEnabled(not InCombatLockdown())
    end,
    EditBoxOnEnterPressed = noop,
    EditBoxOnEscapePressed = noop,
    EditBoxOnTextChanged = noop,
    timeout = 0,
    whileDead = 1,
    exclusive = 1,
    showAlert = 1,
    hideOnEscape = 1,
}

---@type StaticPopupInfoPolyfill
local StaticPopupNew = {
    text = "",
    button1 = SAVE,
    button2 = CANCEL,
    OnAccept = noop,
    OnCancel = noop,
    OnShow = OnShow,
    OnHide = noop,
    OnUpdate = noop,
    EditBoxOnEnterPressed = OnEnterPressed,
    EditBoxOnEscapePressed = OnEscapePressed,
    EditBoxOnTextChanged = OnTextChanged,
    timeout = 0,
    whileDead = 1,
    exclusive = 1,
    showAlert = 1,
    hideOnEscape = 1,
    hasEditBox = 1,
    maxLetters = 32,
}

---@type StaticPopupInfoPolyfill
local StaticPopupEdit = {
    text = "",
    button1 = PET_RENAME,
    button2 = CANCEL,
    button3 = format("%s %s", ns.Atlas.ATLAS_REMOVE_MARKUP, DELETE),
    OnButton3 = noop,
    selectCallbackByIndex = true,
    OnAccept = noop,
    OnCancel = noop,
    OnShow = OnShow,
    OnHide = noop,
    OnUpdate = noop,
    EditBoxOnEnterPressed = OnEnterPressed,
    EditBoxOnEscapePressed = OnEscapePressed,
    EditBoxOnTextChanged = OnTextChanged,
    timeout = 0,
    whileDead = 1,
    exclusive = 1,
    showAlert = 1,
    hideOnEscape = 1,
    hasEditBox = 1,
    maxLetters = 32,
}

---@param name string
---@param template StaticPopupInfoPolyfill
---@param canShow fun(): boolean?
---@param onAccept? function
---@param onButton3? function
---@return StaticPopupPolyfill? frame
local function GetStaticPopup(name, template, canShow, onAccept, onButton3)
    local info = StaticPopupDialogs[name] ---@type StaticPopupInfoPolyfill?
    if not info then
        info = template
        StaticPopupDialogs[name] = info
    end
    info.OnAccept = onAccept or noop
    info.OnButton3 = onButton3 or noop
    local frame = StaticPopup_FindVisible(name)
    if not canShow() then
        if frame then
            frame:Hide()
        end
        return
    end
    if not frame then
        frame = StaticPopup_Show(name, nil, nil, info)
    end
    if not frame then
        print(L.YOU_HAVE_TOO_MANY_POPUPS_OPEN)
        return
    end
    return frame
end

---@param presets AddOnPresetsPendingMap
---@return string[] lines
local function GetPresetsTextLines(presets)
    local pending = {} ---@type AddOnPresetsPending[]
    local index = 0
    for preset, enable in pairs(presets) do
        index = index + 1
        pending[index] = { preset = preset, enable = enable }
    end
    ns.Sort.Pending(pending)
    local lines = {} ---@type string[]
    index = 0
    for _, info in ipairs(pending) do
        local preset = info.preset
        local count = #preset.addons
        index = index + 1
        lines[index] = count > 0 and format(
            "%s %s (%s %s)",
            info.enable and ATLAS_ENABLED_MARKUP or ATLAS_DISABLED_MARKUP,
            preset.name,
            count,
            ADDONS
        ) or format(
            "%s %s (%s)",
            info.enable and ATLAS_ENABLED_MARKUP or ATLAS_DISABLED_MARKUP,
            preset.name,
            EMPTY
        )
    end
    return lines
end

---@param presets AddOnPresetsPendingMap
---@param onAccept StaticPopupInfoPolyfillOnAccept
---@return boolean? visible
local function ShowPending(presets, onAccept)
    local lines = GetPresetsTextLines(presets)
    local frame = GetStaticPopup(StaticPopupNamePending, StaticPopupPending, function() return #lines > 0 end, onAccept)
    if not frame then
        return
    end
    local text = format(
        "%s\n\n%s\n\n%s",
        L.DO_YOU_WANT_TO_APPLY_THESE_CHANGES,
        table.concat(lines, "\n"),
        format(L.CLICKING_SS_WILL_RELOAD_YOUR_INTERFACE, YES)
    )
    local frameText = StaticPopup_GetTextFontString(frame)
    frameText:SetText(text)
    StaticPopup_Resize(frame, StaticPopupNamePending)
    return true
end

---@param preset AddOnPresetsDBPreset
---@param onAccept StaticPopupInfoPolyfillOnAccept
---@return boolean? visible
local function ShowNewPreset(preset, onAccept)
    local lines = preset.addons
    local frame = GetStaticPopup(StaticPopupNameNew, StaticPopupNew, function() return #lines > 0 end, onAccept)
    if not frame then
        return
    end
    local text = format(
        "%s\n\n%s\n\n%s",
        L.DO_YOU_WANT_TO_CREATE_THIS_PRESET,
        table.concat(lines, "\n"),
        format(L.ENTER_PRESET_NAME_AND_CLICK_SS, SAVE)
    )
    local frameText = StaticPopup_GetTextFontString(frame)
    frameText:SetText(text)
    StaticPopup_Resize(frame, StaticPopupNameNew)
    local editBox = StaticPopup_GetEditBox(frame)
    editBox:SetFocus()
    return true
end

---@param preset? AddOnPresetsDBPreset
---@param onAccept? StaticPopupInfoPolyfillOnAccept
---@param onDelete? StaticPopupInfoPolyfillOnAccept
---@return boolean? visible
local function ShowEditPreset(preset, onAccept, onDelete)
    local frame = GetStaticPopup(StaticPopupNameEdit, StaticPopupEdit, function() return preset ~= nil end, onAccept, onDelete)
    if not frame or not preset then
        return
    end
    local text = format(
        "%s\n\n%s",
        format(L.EDIT_PRESET_SS, preset.name),
        L.ENTER_NEW_NAME_OR_DELETE
    )
    local frameText = StaticPopup_GetTextFontString(frame)
    frameText:SetText(text)
    StaticPopup_Resize(frame, StaticPopupNameEdit)
    local editBox = StaticPopup_GetEditBox(frame)
    editBox:SetText(preset.name)
    editBox:SetFocus()
    return true
end

ns.StaticPopup = {
    GetFrameEditBoxText = GetFrameEditBoxText,
    ShowPending = ShowPending,
    ShowNewPreset = ShowNewPreset,
    ShowEditPreset = ShowEditPreset,
}
