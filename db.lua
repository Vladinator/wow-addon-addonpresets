---@class AddOnPresetsNS
local ns = select(2, ...)

---@class AddOnPresetsDBPreset
---@field public name string
---@field public addons string[]

---@class AddOnPresetsDBMinimap : LibDBIcon.button.DB
---@field public hide boolean `false`
---@field public lock boolean `false`
---@field public showInCompartment boolean `true`
---@field public minimapPos number `288`

---@class AddOnPresetsDB
---@field public presets AddOnPresetsDBPreset[]
---@field public minimap AddOnPresetsDBMinimap

---@class AddOnPresetsDB
local AddOnPresetsDefaults = {
    presets = {},
    minimap = { hide = false, lock = false, showInCompartment = true, minimapPos = 288 },
}

---@param preset AddOnPresetsDBPreset
---@return number total, number loaded, number unloaded
local function GetPresetStateInfo(preset)
    local total = #preset.addons
    if total == 0 then
        return 0, 0, 0
    end
    local loaded = 0
    local unloaded = 0
    for _, id in ipairs(preset.addons) do
        local state = ns.AddOns.GetStatus(id)
        if state == "MISSING" then
            total = total - 1
        elseif state == "LOADED" then
            loaded = loaded + 1
        else
            unloaded = unloaded + 1
        end
    end
    return total, loaded, unloaded
end

---@param preset AddOnPresetsDBPreset
---@return boolean?
local function IsPresetActive(preset)
    local total, loaded, unloaded = GetPresetStateInfo(preset)
    return total > 0 and total == loaded
end

---@param preset AddOnPresetsDBPreset
---@return boolean?
local function IsPresetInactive(preset)
    local total, loaded, unloaded = GetPresetStateInfo(preset)
    return total > 0 and total == unloaded
end

---@alias AddOnPresetsState "ACTIVE"|"INACTIVE"|"PARTIAL"

---@param preset AddOnPresetsDBPreset
---@return AddOnPresetsState state
local function GetPresetState(preset)
    local isActive = IsPresetActive(preset)
    local isInactive = IsPresetInactive(preset)
    if not isActive and not isInactive then
        return "PARTIAL"
    elseif isActive then
        return "ACTIVE"
    end
    return "INACTIVE"
end

---@type AddOnPresetsDB
local db

local function Initialize()
    db = AddOnPresetsDB
    if type(db) ~= "table" then
        db = AddOnPresetsDefaults
        AddOnPresetsDB = db
    end
end

---@return AddOnPresetsDBPreset[] presets
local function GetPresets()
    return db.presets
end

---@param name string
---@return AddOnPresetsDBPreset preset
local function CreatePreset(name)
    local presets = GetPresets()
    ---@type AddOnPresetsDBPreset
    local preset = {
        name = name,
        addons = {},
    }
    presets[#presets + 1] = preset
    ns.Sort.Presets(presets)
    return preset
end

---@param preset AddOnPresetsDBPreset
---@return boolean success
local function RemovePreset(preset)
    local presets = GetPresets()
    for index, dbPreset in ipairs(presets) do
        if dbPreset == preset then
            table.remove(presets, index)
            return true
        end
    end
    return false
end

---@return AddOnPresetsDBMinimap minimap
local function GetMinimap()
    return db.minimap
end

ns.DB = {
    Initialize = Initialize,
    GetPresets = GetPresets,
    GetPresetState = GetPresetState,
    CreatePreset = CreatePreset,
    RemovePreset = RemovePreset,
    GetMinimap = GetMinimap,
}
