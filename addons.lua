---@class AddOnPresetsNS
local ns = select(2, ...)

---@alias AddOnPresetsAddOnStatus "LOADED"|"LOADABLE"|"MISSING"|"DISABLED"

---@class AddOnPresetsAddOnListItem
---@field public name string
---@field public status? AddOnPresetsAddOnStatus

---@class AddOnPresetsAddOnListGroup
---@field public name string
---@field public addons AddOnPresetsAddOnListItem[]
---@field public page? number

---@param id string|number
---@return AddOnPresetsAddOnStatus? state
local function GetStatus(id)
    local name, title, notes, loadable, reason, security, updateAvailable = C_AddOns.GetAddOnInfo(id)
    if loadable then
        if C_AddOns.IsAddOnLoaded(name) then
            return "LOADED"
        end
        return "LOADABLE"
    elseif reason == "MISSING" then
        return "MISSING"
    elseif reason == "DISABLED" or reason == "DEP_DISABLED" then
        return "DISABLED"
    end
end

---@return AddOnPresetsAddOnListItem[] addons
local function GetList()
    local addons = {} ---@type AddOnPresetsAddOnListItem[]
    for i = 1, C_AddOns.GetNumAddOns() do
        local name = C_AddOns.GetAddOnInfo(i)
        addons[#addons + 1] = {
            name = name,
            status = GetStatus(i),
        }
    end
    ns.Sort.AddOns(addons)
    return addons
end

local MAX_PER_GROUP = 30

---@param groups AddOnPresetsAddOnListGroup[]
---@param name string
---@return AddOnPresetsAddOnListGroup group
local function GetGroupFor(groups, name)
    local prevGroup ---@type AddOnPresetsAddOnListGroup?
    local page ---@type number?
    for _, group in ipairs(groups) do
        if strcmputf8i(group.name, name) == 0 then
            prevGroup = group
            page = (page or 1) + 1
            if #group.addons < MAX_PER_GROUP then
                return group
            end
        end
    end
    if prevGroup and page then
        prevGroup.page = page - 1
    end
    ---@type AddOnPresetsAddOnListGroup
    local group = { name = name, addons = {}, page = page }
    groups[#groups + 1] = group
    return group
end

---@return AddOnPresetsAddOnListGroup[] addonGroups
local function GetListGrouped()
    local groups = {} ---@type AddOnPresetsAddOnListGroup[]
    local addons = GetList()
    for _, addon in ipairs(addons) do
        local name = addon.name
        local first = name:sub(1, 1)
        if not first:find("%w+") then
            first = "#"
        end
        local group = GetGroupFor(groups, first)
        local index = #group.addons + 1
        group.addons[index] = addon
    end
    ns.Sort.AddOnGroups(groups)
    return groups
end

---@param names string[]
---@return number pending
local function Load(names)
    local pending = 0
    for _, name in ipairs(names) do
        C_AddOns.EnableAddOn(name)
        pending = pending + 1
    end
    return pending
end

---@param names string[]
---@return number pending
local function Unload(names)
    local pending = 0
    for _, name in ipairs(names) do
        C_AddOns.DisableAddOn(name)
        pending = pending + 1
    end
    return pending
end

ns.AddOns = {
    GetStatus = GetStatus,
    GetListGrouped = GetListGrouped,
    Load = Load,
    Unload = Unload,
}
