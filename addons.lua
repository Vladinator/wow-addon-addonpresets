---@class AddOnPresetsNS
local ns = select(2, ...)

---@alias AddOnPresetsAddOnStatus "LOADED"|"LOADABLE"|"MISSING"|"DISABLED"

---@class AddOnPresetsAddOnListItem
---@field public name string
---@field public title string
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
        local name, title = C_AddOns.GetAddOnInfo(i)
        addons[#addons + 1] = {
            name = name,
            title = title,
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

---@param first string
local function IsFirstGlyphLetter(first)
    if first:find("[A-Za-z]") then
        return true -- ASCII letters
    end
    if first:byte(1) >= 194 then
        -- if first:find("[\195][\128-\191]") then
        --     return true -- Latin-1 Supplement (U+00C0 to U+00FF)
        -- end
        if first:find("[\208-\211][\128-\191]") then
            return true -- Cyrillic (U+0400 to U+04FF)
        end
        if first:find("[\234][\128-\191][\128-\191]") or first:find("[\235][\128-\191][\128-\191]") or first:find("[\236][\128-\191][\128-\191]") or first:find("[\237][\128-\158][\128-\191]") then
            return true -- Hangul Syllables (U+AC00 to U+D7AF)
        end
        if first:find("[\228][\128-\191][\128-\191]") or first:find("[\229-\232][\128-\191][\128-\191]") or first:find("[\233][\128-\191][\128-\191]") then
            return true -- CJK Unified Ideographs (U+4E00 to U+9FFF)
        end
    end
    return false
end

---@param addon AddOnPresetsAddOnListItem
local function GetFirstGlyph(addon)
    local name = addon.title
    if StripHyperlinks then
        name = StripHyperlinks(name, false, false, true, false)
    end
    local first = name:match("[\1-\127\194-\244][\128-\191]*") ---@type string?
    if not first or not IsFirstGlyphLetter(first) then
        first = "#"
    end
    return first
end

---@return AddOnPresetsAddOnListGroup[] addonGroups
local function GetListGrouped()
    local groups = {} ---@type AddOnPresetsAddOnListGroup[]
    local addons = GetList()
    for _, addon in ipairs(addons) do
        local first = GetFirstGlyph(addon)
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
