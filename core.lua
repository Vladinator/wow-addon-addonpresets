---@type string
local addonName = ...

---@class AddOnPresetsNS
local ns = select(2, ...)
local L = ns.L
local db = ns.DB

local ATLAS_LEFTBUTTON_MARKUP = ns.Atlas.ATLAS_LEFTBUTTON_MARKUP
local ATLAS_RIGHTBUTTON_MARKUP = ns.Atlas.ATLAS_RIGHTBUTTON_MARKUP
local ATLAS_WARNING_MARKUP = ns.Atlas.ATLAS_WARNING_MARKUP
local ATLAS_CREATE_MARKUP = ns.Atlas.ATLAS_CREATE_MARKUP
local ATLAS_PENCIL_MARKUP = ns.Atlas.ATLAS_PENCIL_MARKUP
local ATLAS_ENABLED_MARKUP = ns.Atlas.ATLAS_ENABLED_MARKUP
local ATLAS_DISABLED_MARKUP = ns.Atlas.ATLAS_DISABLED_MARKUP
local ATLAS_PARTIAL_MARKUP = ns.Atlas.ATLAS_PARTIAL_MARKUP

local LOCALE_OPEN = format("%s %s", ATLAS_LEFTBUTTON_MARKUP, L.OPEN)
local LOCALE_CONFIGURE = format("%s %s", ATLAS_RIGHTBUTTON_MARKUP, L.CONFIGURE)
local LOCALE_PARTIALLY_LOADED = format("%s %s", ATLAS_WARNING_MARKUP, L.PARTIALLY_LOADED)
local LOCALE_EDIT = format("%s %s", ATLAS_LEFTBUTTON_MARKUP, EDIT)
local LOCALE_CREATE_PRESET = format("%s %s", ATLAS_CREATE_MARKUP, L.CREATE_PRESET)
local LOCALE_TOGGLE = format("%s %s", ATLAS_LEFTBUTTON_MARKUP, L.TOGGLE)

---@class AddOnPresetsPending
---@field public preset AddOnPresetsDBPreset
---@field public enable boolean

---@alias AddOnPresetsPendingMap table<AddOnPresetsDBPreset, boolean?>

---@type AddOnPresetsPendingMap
local pendingPresets = {}

---@type boolean?
local inConfigMode

---@type AddOnPresetsDBPreset
local newPreset = { name = "", addons = {} }

local addonGroups = ns.AddOns.GetListGrouped()

---@param addons string[]|AddOnPresetsAddOnListItem[]
---@param name string
---@return number? index
local function HasAddOn(addons, name)
    for index, addon in ipairs(addons) do
        if type(addon) == "string" then
            if addon == name then
                return index
            end
        elseif addon.name == name then
            return index
        end
    end
end

---@param menu BlizzardMenuElementDescriptionPolyfill
---@param preset AddOnPresetsDBPreset
local function AppendPresetConfigureAddOnsMenu(menu, preset)
    local addons = preset.addons
    for _, group in ipairs(addonGroups) do
        local count = 0
        for _, addon in ipairs(group.addons) do
            if HasAddOn(addons, addon.name) ~= nil then
                count = count + 1
            end
        end
        local title = group.name:upper()
        local page = group.page
        if page then
            title = format("%s-%d", title, page)
        end
        title = count > 0 and
            format("%s (%d)", title, count) or
            format("%s", title)
        local subMenu = menu:CreateButton(title)
        for _, addon in ipairs(group.addons) do
            subMenu:CreateCheckbox(
                addon.name,
                function()
                    return HasAddOn(addons, addon.name) ~= nil
                end,
                function()
                    local index = HasAddOn(addons, addon.name)
                    if index then
                        table.remove(addons, index)
                    else
                        addons[#addons + 1] = addon.name
                        ns.Sort.AddOnNames(addons)
                    end
                end
            )
        end
    end
end

---@param rootDescription BlizzardMenuRootDescriptionPolyfill
---@param preset AddOnPresetsDBPreset
local function AppendPresetConfigureMenu(rootDescription, preset)
    local title = format("%s %s", ATLAS_PENCIL_MARKUP, preset.name)
    local count = #preset.addons
    if count > 0 then
        title = format("%s (%s)", title, count)
    end
    local menu = rootDescription:CreateButton(
        title,
        function()
            local visible = ns.StaticPopup.ShowEditPreset(
                preset,
                function(self)
                    local text = ns.StaticPopup.GetEditBoxText(self.editBox)
                    if text then
                        preset.name = text
                    end
                end,
                function()
                    db.RemovePreset(preset)
                end
            )
            if visible then
                ns.Dropdown:Close()
            end
        end
    )
    menu:SetTooltip(function(tooltip)
        tooltip:AddLine(LOCALE_EDIT, 1, 1, 1, false)
    end)
    AppendPresetConfigureAddOnsMenu(menu, preset)
end

---@param rootDescription BlizzardMenuRootDescriptionPolyfill
local function AppendNewPresetConfigureMenu(rootDescription)
    local menu = rootDescription:CreateButton(
        LOCALE_CREATE_PRESET,
        function() ns.StaticPopup.ShowEditPreset() end
    )
    menu:SetTooltip(function(tooltip)
        tooltip:AddLine(L.CREATE_PRESET_INFO, 1, 1, 1, true)
    end)
    AppendPresetConfigureAddOnsMenu(menu, newPreset)
end

local function ConfirmPendingPresets()
    local names = {} ---@type table<string, boolean>
    for preset, enable in pairs(pendingPresets) do
        for _, name in pairs(preset.addons) do
            names[name] = enable
        end
    end
    ---@type StaticPopupInfoPolyfillOnAccept
    local function onAccept()
        if InCombatLockdown() then
            print(L.YOU_ARE_IN_COMBAT)
            return
        end
        local load = {} ---@type string[]
        local unload = {} ---@type string[]
        for name, enable in pairs(names) do
            if enable then
                load[#load + 1] = name
            else
                unload[#unload + 1] = name
            end
        end
        local pending = 0
        pending = pending + ns.AddOns.Load(load)
        pending = pending + ns.AddOns.Unload(unload)
        if pending == 0 then
            return
        end
        C_UI.Reload()
    end
    ns.StaticPopup.ShowPending(pendingPresets, onAccept)
    table.wipe(pendingPresets)
end

local function ConfirmNewPreset()
    local tempPreset = { name = newPreset.name, addons = {} } ---@type AddOnPresetsDBPreset
    for k, v in ipairs(newPreset.addons) do
        tempPreset.addons[k] = v
    end
    ---@type StaticPopupInfoPolyfillOnAccept
    local function onAccept(self)
        local text = ns.StaticPopup.GetEditBoxText(self.editBox) or L.UNTITLED_PRESET
        local preset = db.CreatePreset(text)
        preset.addons = tempPreset.addons
    end
    ns.StaticPopup.ShowNewPreset(tempPreset, onAccept)
    newPreset.name = ""
    table.wipe(newPreset.addons)
end

---@type AddOnPresetsBrokerOnEnter
local function onEnter(frame)
    local presets = db.GetPresets()
    GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMLEFT", 0, 0)
    GameTooltip:AddLine(addonName, 1, 1, 1, false)
    if #presets == 0 then
        GameTooltip:AddLine(L.YOU_HAVE_NO_PRESETS, 1, 1, 1, false)
        GameTooltip:AddLine(LOCALE_CONFIGURE, 1, 1, 1, false)
        GameTooltip:Show()
        return
    end
    for _, preset in ipairs(presets) do
        if #preset.addons > 0 then
            local state = db.GetPresetState(preset)
            if state == "ACTIVE" then
                GameTooltip:AddLine(format("%s %s", ATLAS_ENABLED_MARKUP, preset.name), 1, 1, 1, false)
            elseif state == "INACTIVE" then
                GameTooltip:AddLine(format("%s %s", ATLAS_DISABLED_MARKUP, preset.name), 1, 1, 1, false)
            else
                GameTooltip:AddLine(format("%s %s", ATLAS_PARTIAL_MARKUP, preset.name), 1, 1, 1, false)
            end
        end
    end
    GameTooltip:AddLine(LOCALE_OPEN, 1, 1, 1, false)
    GameTooltip:AddLine(LOCALE_CONFIGURE, 1, 1, 1, false)
    GameTooltip:Show()
end

---@type AddOnPresetsBrokerOnLeave
local function onLeave(frame)
    if GameTooltip:GetOwner() == frame then
        GameTooltip:Hide()
    end
end

---@type AddOnPresetsBrokerOnClick
local function onClick(frame, button)
    local presets = db.GetPresets()
    inConfigMode = #presets == 0 or button == "RightButton"
    local anchorFrame = ns.IsMenuOpenByTag("MENU_ADDON_COMPARTMENT") and AddonCompartmentFrame or frame
    ns.Dropdown.Open("TOPRIGHT", anchorFrame, "BOTTOMLEFT", 0, 0)
    onLeave(frame)
end

---@type AddOnPresetsDropdownOnOpen
local function onOpen(dropdown, rootDescription)
    local presets = db.GetPresets()
    for _, preset in ipairs(presets) do
        local state = db.GetPresetState(preset)
        local isPartial = state == "PARTIAL"
        local isActive = isPartial or state == "ACTIVE"
        if inConfigMode then
            AppendPresetConfigureMenu(rootDescription, preset)
        elseif #preset.addons > 0 then
            local button = rootDescription:CreateCheckbox(
                preset.name,
                function()
                    local pending = pendingPresets[preset]
                    if pending ~= nil then
                        return pending
                    end
                    return isActive
                end,
                function()
                    if isPartial then
                        pendingPresets[preset] = pendingPresets[preset] ~= nil and not pendingPresets[preset]
                    elseif pendingPresets[preset] == nil then
                        pendingPresets[preset] = not isActive
                    else
                        pendingPresets[preset] = nil
                    end
                end
            )
            if isPartial then
                button:SetTooltip(function(tooltip)
                    tooltip:AddLine(LOCALE_PARTIALLY_LOADED, 1, 1, 1, false)
                end)
                -- [[ TODO: ugly hack to make the initial visuals for a tri-state checkbox
                local function onClose()
                    dropdown:UnregisterCallback("OnUpdate", preset)
                    dropdown:UnregisterCallback("OnMenuOpen", preset)
                    dropdown:UnregisterCallback("OnMenuClose", preset)
                end
                local function onUpdate()
                    if pendingPresets[preset] ~= nil then
                        onClose()
                        return
                    end
                    local menu = dropdown.menu
                    if not menu or not menu:IsVisible() then
                        return
                    end
                    for _, widget in ipairs({menu:GetChildren()}) do
                        if widget.fontString and widget.leftTexture1 and widget.leftTexture2 and widget:IsVisible() and widget:GetObjectType() == "Button" then
                            if widget.fontString:GetText() == preset.name then
                                widget.leftTexture1:SetDesaturated(true)
                                widget.leftTexture2:SetDesaturated(true)
                                break
                            end
                        end
                    end
                end
                dropdown:RegisterCallback("OnUpdate", onUpdate, preset)
                dropdown:RegisterCallback("OnMenuOpen", onUpdate, preset)
                dropdown:RegisterCallback("OnMenuClose", onClose, preset)
                --]]
            end
        else
            local button = rootDescription:CreateCheckbox(
                preset.name,
                function() return false end,
                function() end
            )
            button:SetEnabled(false)
        end
    end
    if inConfigMode then
        AppendNewPresetConfigureMenu(rootDescription)
        local minimap = db.GetMinimap()
        local toggle = rootDescription:CreateCheckbox(
            L.LOCK_MINIMAP,
            function() return minimap.lock end,
            function() ns.Broker.LockIcon(not minimap.lock) end
        )
        toggle:SetTooltip(function(tooltip)
            tooltip:AddLine(LOCALE_TOGGLE, 1, 1, 1, false)
        end)
    end
end

---@type AddOnPresetsDropdownOnClose
local function onClose(dropdown)
    ConfirmPendingPresets()
    ConfirmNewPreset()
end

---@param addon AddOnPresetsFrame
---@param event WowEvent
---@param ... any
local function OnEvent(addon, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == addonName then
            db.Initialize()
            ns.Broker.Initialize(onClick, onEnter, onLeave)
            ns.Dropdown.Initialize(onOpen, onClose)
        end
        ns.Broker.UpdateIcon()
    end
end

---@class AddOnPresetsFrame : Frame
local addon = CreateFrame("Frame")
addon:SetScript("OnEvent", OnEvent)
addon:RegisterEvent("ADDON_LOADED")
