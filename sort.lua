---@class AddOnPresetsNS
local ns = select(2, ...)

---@param name1 string
---@param name2 string
---@return boolean
local function CompareAddOnNames(name1, name2)
    return strcmputf8i(name1, name2) < 0
end

---@param preset1 AddOnPresetsDBPreset
---@param preset2 AddOnPresetsDBPreset
---@return boolean
local function ComparePresets(preset1, preset2)
    return CompareAddOnNames(preset1.name, preset2.name)
end

---@param presets AddOnPresetsDBPreset[]
local function SortPresets(presets)
    table.sort(presets, ComparePresets)
end

---@param pending1 AddOnPresetsPending
---@param pending2 AddOnPresetsPending
---@return boolean
local function ComparePendingPresets(pending1, pending2)
    return ComparePresets(pending1.preset, pending2.preset)
end

---@param pending AddOnPresetsPending[]
local function SortPending(pending)
    table.sort(pending, ComparePendingPresets)
end

---@param addon1 AddOnPresetsAddOnListItem
---@param addon2 AddOnPresetsAddOnListItem
---@return boolean
local function CompareAddOns(addon1, addon2)
    return CompareAddOnNames(addon1.title, addon2.title)
end

---@param addons AddOnPresetsAddOnListItem[]
local function SortAddOns(addons)
    table.sort(addons, CompareAddOns)
end

---@param names string[]
local function SortAddOnNames(names)
    table.sort(names, CompareAddOnNames)
end

---@param group1 AddOnPresetsAddOnListGroup
---@param group2 AddOnPresetsAddOnListGroup
---@return boolean
local function CompareAddonGroups(group1, group2)
    local d = strcmputf8i(group1.name, group2.name)
    if d == 0 then
        return (group1.page or 1) < (group2.page or 1)
    end
    return d < 0
end

---@param groups AddOnPresetsAddOnListGroup[]
local function SortAddOnGroups(groups)
    table.sort(groups, CompareAddonGroups)
end

ns.Sort = {
    Presets = SortPresets,
    Pending = SortPending,
    AddOns = SortAddOns,
    AddOnNames = SortAddOnNames,
    AddOnGroups = SortAddOnGroups,
}
