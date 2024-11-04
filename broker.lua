---@type string
local addonName = ...

---@class AddOnPresetsNS
local ns = select(2, ...)
local db = ns.DB

local LDB = LibStub("LibDataBroker-1.1")
local LDBI = LibStub("LibDBIcon-1.0")

---@type LibDataBroker.QuickLauncher
local dataBroker

---@type boolean
local dbIcon

---@alias AddOnPresetsBrokerOnEnter fun(displayFrame: Frame)

---@alias AddOnPresetsBrokerOnLeave fun(displayFrame: Frame)

---@alias AddOnPresetsBrokerOnClick fun(displayFrame: Frame, buttonName: mouseButton)

---@type AddOnPresetsBrokerOnEnter?
local onEnter

---@type AddOnPresetsBrokerOnLeave?
local onLeave

---@type AddOnPresetsBrokerOnClick?
local onClick

local function InitializeDataBroker()
    if dataBroker then
        return
    end
    ---@diagnostic disable-next-line: cast-local-type
    dataBroker = LDB:NewDataObject(addonName, {
        type = "launcher",
        text = addonName,
        icon = C_AddOns.GetAddOnMetadata(addonName, "IconTexture") or C_AddOns.GetAddOnMetadata(addonName, "IconAtlas"),
        OnEnter = function(...) if onEnter then onEnter(...) end end,
        OnLeave = function(...) if onLeave then onLeave(...) end end,
        OnClick = function(...) if onClick then onClick(...) end end,
    })
end

local function InitializeDBIcon()
    if dbIcon or not dataBroker then
        return
    end
    local minimap = db.GetMinimap()
    LDBI:Register(addonName, dataBroker, minimap)
    dbIcon = LDBI:IsRegistered(addonName)
end

---@param click AddOnPresetsBrokerOnClick?
---@param enter AddOnPresetsBrokerOnEnter?
---@param leave AddOnPresetsBrokerOnLeave?
local function Initialize(click, enter, leave)
    InitializeDataBroker()
    InitializeDBIcon()
    onClick = click
    onEnter = enter
    onLeave = leave
end

local function ShowIcon()
    if not dbIcon then
        return
    end
    local minimap = db.GetMinimap()
    if minimap.showInCompartment then
        LDBI:AddButtonToCompartment(addonName)
    end
    if not minimap.hide then
        LDBI:Show(addonName)
    end
    if minimap.showInCompartment or not minimap.hide then
        LDBI:Refresh(addonName, minimap)
    end
end

local function HideIcon()
    if not dbIcon then
        return
    end
    local minimap = db.GetMinimap()
    if not minimap.showInCompartment then
        LDBI:RemoveButtonFromCompartment(addonName)
    end
    if minimap.hide then
        LDBI:Hide(addonName)
    end
end

local function UpdateIcon()
    if not dataBroker or not dbIcon then
        return
    end
    local minimap = db.GetMinimap()
    if minimap.hide and not minimap.showInCompartment then
        HideIcon()
        return
    end
    ShowIcon()
    if minimap.hide or not minimap.showInCompartment then
        HideIcon()
    end
end

---@param lock boolean
local function LockIcon(lock)
    local minimap = db.GetMinimap()
    minimap.lock = lock
    if lock then
        LDBI:Lock(addonName)
    else
        LDBI:Unlock(addonName)
    end
end

ns.Broker = {
    Initialize = Initialize,
    UpdateIcon = UpdateIcon,
    LockIcon = LockIcon,
}
