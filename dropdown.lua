---@class AddOnPresetsNS
local ns = select(2, ...)

---@alias AddOnPresetsDropdownOnOpen fun(self: AddOnPresetsDropdown, rootDescription: BlizzardMenuRootDescriptionPolyfill)

---@alias AddOnPresetsDropdownOnClose fun(self: AddOnPresetsDropdown)

---@type AddOnPresetsDropdownOnOpen?
local OnOpen

---@type AddOnPresetsDropdownOnClose?
local OnClose

---@class AddOnPresetsDropdown : BlizzardMenuRootDescriptionPolyfill, Button
local dropdown = CreateFrame("DropdownButton", nil, UIParent, "WowStyle1DropdownTemplate") ---@diagnostic disable-line: assign-type-mismatch

---@param dropdown AddOnPresetsDropdown
---@type BlizzardMenuGeneratorPolyfill
local function GeneratorFunction(dropdown, rootDescription)
    if OnOpen then
        OnOpen(dropdown, rootDescription)
    end
    if not OnClose then
        return
    end
    local function onClose()
        dropdown:UnregisterCallback("OnMenuClose", dropdown)
        if OnClose then
            OnClose(dropdown)
        end
    end
	dropdown:RegisterCallback("OnMenuClose", onClose, dropdown)
end

---@param onOpen? AddOnPresetsDropdownOnOpen
---@param onClose? AddOnPresetsDropdownOnClose
local function Initialize(onOpen, onClose)
    OnOpen = onOpen
    OnClose = onClose
    dropdown:SetupMenu(GeneratorFunction)
end

---@param point FramePoint
---@param relativeTo Region
---@param relativePoint FramePoint
---@param offsetX? uiUnit
---@param offsetY? uiUnit
local function Open(point, relativeTo, relativePoint, offsetX, offsetY)
    local anchor = AnchorUtil.CreateAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
    dropdown:SetMenuAnchor(anchor)
    dropdown:OpenMenu()
end

local function Close()
    dropdown:CloseMenu()
end

ns.Dropdown = {
    Initialize = Initialize,
    Open = Open,
    Close = Close,
}
