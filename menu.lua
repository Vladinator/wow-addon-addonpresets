---@class AddOnPresetsNS
local ns = select(2, ...)

---@enum MenuConstantsPolyfill
local MenuConstants = MenuConstants or {
	VerticalLinearDirection = 1,
	VerticalGridDirection = 2,
	HorizontalGridDirection = 3,
	AutoCalculateColumns = nil,
	ElementPollFrequencySeconds = 0.2,
	PrintSecure = false,
}

---@enum MenuResponsePolyfill
local MenuResponse = MenuResponse or {
	Open = 1,
	Refresh = 2,
	Close = 3,
	CloseAll = 4,
}

---@alias BlizzardMenuGeneratorPolyfill fun(menu: BlizzardMenuRootDescriptionPolyfill, rootDescription: BlizzardMenuRootDescriptionPolyfill)

---@class BlizzardMenuInputDataPolyfill
---@field public context 2
---@field public buttonName mouseButton

---@alias AddonCompartmentOnClickPolyfill fun(data: any, menuInputData: BlizzardMenuInputDataPolyfill, menu: BlizzardMenuRootDescriptionPolyfill)

---@alias BlizzardMenuElementDescriptionSetResponderPolyfill fun(data: any, menuInputData: BlizzardMenuInputDataPolyfill, menu: BlizzardMenuRootDescriptionPolyfill)

---@alias BlizzardMenuElementDescriptionSetTooltipPolyfill fun(tooltip: GameTooltip, elementDescription: BlizzardMenuElementDescriptionPolyfill)

---@alias BlizzardMenuRootDescriptionCreateButtonPolyfill fun(data: any, menuInputData: BlizzardMenuInputDataPolyfill, menu: BlizzardMenuElementDescriptionPolyfill)

---@alias BlizzardMenuRootDescriptionAddInitializerPolyfill fun(button: Button, description: BlizzardMenuElementDescriptionPolyfill, menu: BlizzardMenuRootDescriptionPolyfill): number, number

---@class BlizzardMenuSharedDescriptionPolyfill
---@field public SetTag fun(self: BlizzardMenuSharedDescriptionPolyfill, tag: BlizzardMenuTagPolyfill|string)
---@field public ClearQueuedDescription function
---@field public AddQueuedDescription function
---@field public Insert function

---@class BlizzardMenuElementDescriptionPolyfill : BlizzardMenuSharedDescriptionPolyfill, BlizzardMenuRootDescriptionPolyfill, Frame
---@field public SetRadio function
---@field public IsSelected function
---@field public SetIsSelected function
---@field public SetSelectionIgnored function
---@field public SetSoundKit function
---@field public SetOnEnter function
---@field public SetOnLeave function
---@field public SetEnabled function
---@field public IsEnabled function
---@field public SetData function
---@field public SetResponder fun(self: BlizzardMenuElementDescriptionPolyfill, func: BlizzardMenuElementDescriptionSetResponderPolyfill)
---@field public SetResponse function
---@field public SetTooltip fun(self: BlizzardMenuRootDescriptionPolyfill, func: BlizzardMenuElementDescriptionSetTooltipPolyfill): BlizzardMenuElementDescriptionPolyfill
---@field public Pick function

---@class BlizzardMenuFrameButtonPolyfill : Button
---@field public fontString FontString
---@field public leftTexture1 Texture
---@field public leftTexture2 Texture

---@class BlizzardMenuFramePolyfill : Frame
---@field public GetChildren fun(self: BlizzardMenuFramePolyfill): ...: BlizzardMenuFrameButtonPolyfill

---@class BlizzardMenuRootDescriptionPolyfill : BlizzardMenuSharedDescriptionPolyfill
---@field public menu? BlizzardMenuFramePolyfill
---@field public CreateButton fun(self: BlizzardMenuRootDescriptionPolyfill, title: string, func?: BlizzardMenuRootDescriptionCreateButtonPolyfill, ...: any): BlizzardMenuElementDescriptionPolyfill
---@field public CreateCheckbox fun(self: BlizzardMenuRootDescriptionPolyfill, title: string, isSelected: BlizzardMenuIsSelectedPolyfill, toggleSelected: BlizzardMenuToggleSelectedPolyfill): BlizzardMenuElementDescriptionPolyfill
---@field public CreateColorSwatch function
---@field public CreateDivider fun(self: BlizzardMenuRootDescriptionPolyfill): BlizzardMenuElementDescriptionPolyfill
---@field public CreateFrame function
---@field public CreateRadio function
---@field public CreateSpacer function
---@field public CreateTemplate fun(self: BlizzardMenuRootDescriptionPolyfill, title: string, data: any): BlizzardMenuElementDescriptionPolyfill
---@field public CreateTitle fun(self: BlizzardMenuRootDescriptionPolyfill, title: string): BlizzardMenuElementDescriptionPolyfill
---@field public AddInitializer fun(self: BlizzardMenuElementDescriptionPolyfill, func: BlizzardMenuRootDescriptionAddInitializerPolyfill)
---@field public SetGridMode fun(self: BlizzardMenuRootDescriptionPolyfill, extend: number): BlizzardMenuElementDescriptionPolyfill
---@field public SetScrollMode fun(self: BlizzardMenuRootDescriptionPolyfill, mode: MenuConstantsPolyfill, columns: number): BlizzardMenuElementDescriptionPolyfill
---@field public SetSelectionTranslator function
---@field public SetSelectionText function
---@field public OverrideText function
---@field public SetDefaultText function
---@field public SetupMenu fun(self: BlizzardMenuRootDescriptionPolyfill, generator: BlizzardMenuGeneratorPolyfill)
---@field public SetMenuAnchor fun(self: BlizzardMenuRootDescriptionPolyfill, anchor: AnchorBinding)
---@field public OpenMenu fun(self: BlizzardMenuRootDescriptionPolyfill)
---@field public CloseMenu fun(self: BlizzardMenuRootDescriptionPolyfill)
---@field public IsMenuOpen fun(self: BlizzardMenuRootDescriptionPolyfill): boolean
---@field public RegisterCallback fun(self: BlizzardMenuRootDescriptionPolyfill, event: "OnUpdate"|"OnMenuOpen"|"OnMenuClose", callback: BlizzardMenuGeneratorPolyfill, handle?: table)
---@field public UnregisterCallback fun(self: BlizzardMenuRootDescriptionPolyfill, event: "OnUpdate"|"OnMenuOpen"|"OnMenuClose", handle?: table)

---@alias BlizzardMenuButtonInfoPolyfill table<string | function | number>

---@alias BlizzardMenuCheckboxInfoPolyfill table<string | number>

---@alias BlizzardMenuTagPolyfill
---| "MENU_ADDON_COMPARTMENT"
---| "MENU_MINIMAP_TRACKING"
---| "MENU_UNIT_ARENAENEMY"
---| "MENU_UNIT_BATTLEPET"
---| "MENU_UNIT_BN_FRIEND"
---| "MENU_UNIT_BN_FRIEND_OFFLINE"
---| "MENU_UNIT_BOSS"
---| "MENU_UNIT_CHAT_ROSTER"
---| "MENU_UNIT_COMMUNITIES_COMMUNITY"
---| "MENU_UNIT_COMMUNITIES_GUILD_MEMBER"
---| "MENU_UNIT_COMMUNITIES_MEMBER"
---| "MENU_UNIT_COMMUNITIES_WOW_MEMBER"
---| "MENU_UNIT_ENEMY_PLAYER"
---| "MENU_UNIT_FOCUS"
---| "MENU_UNIT_FRIEND"
---| "MENU_UNIT_FRIEND_OFFLINE"
---| "MENU_UNIT_GLUE_FRIEND"
---| "MENU_UNIT_GLUE_FRIEND_OFFLINE"
---| "MENU_UNIT_GLUE_PARTY_MEMBER"
---| "MENU_UNIT_GUILD"
---| "MENU_UNIT_GUILD_OFFLINE"
---| "MENU_UNIT_GUILDS_GUILD"
---| "MENU_UNIT_OTHERBATTLEPET"
---| "MENU_UNIT_OTHERPET"
---| "MENU_UNIT_PARTY"
---| "MENU_UNIT_PET"
---| "MENU_UNIT_PLAYER"
---| "MENU_UNIT_PVP_SCOREBOARD"
---| "MENU_UNIT_RAID"
---| "MENU_UNIT_RAID_PLAYER"
---| "MENU_UNIT_RAID_TARGET_ICON"
---| "MENU_UNIT_SELF"
---| "MENU_UNIT_TARGET"
---| "MENU_UNIT_VEHICLE"
---| "MENU_UNIT_WORLD_STATE_SCORE"

---@alias BlizzardMenuModifyMenuFuncPolyfill fun(owner: Region, rootDescription: BlizzardMenuRootDescriptionPolyfill, contextData: any)

---@class BlizzardMenuPolyfill
---@field public PrintOpenMenuTags fun()
---@field public GetOpenMenuTags fun(): BlizzardMenuTagPolyfill[]
---@field public ModifyMenu fun(tag: BlizzardMenuTagPolyfill|string, func: BlizzardMenuModifyMenuFuncPolyfill)

---@alias BlizzardMenuIsSelectedPolyfill fun(index: number): boolean?

---@alias BlizzardMenuToggleSelectedPolyfill fun(index: number)

---@class BlizzardMenuUtilPolyfill
---@field public CreateContextMenu fun(owner: BlizzardMenuRootDescriptionPolyfill, generator: BlizzardMenuGeneratorPolyfill)
---@field public CreateButtonMenu fun(owner: BlizzardMenuRootDescriptionPolyfill, ...: BlizzardMenuButtonInfoPolyfill): BlizzardMenuElementDescriptionPolyfill
---@field public CreateButtonContextMenu fun(owner: BlizzardMenuRootDescriptionPolyfill, ...: BlizzardMenuButtonInfoPolyfill): BlizzardMenuElementDescriptionPolyfill
---@field public CreateCheckboxMenu fun(owner: BlizzardMenuRootDescriptionPolyfill, isSelected: BlizzardMenuIsSelectedPolyfill, toggleSelected: BlizzardMenuToggleSelectedPolyfill, ...: BlizzardMenuCheckboxInfoPolyfill): BlizzardMenuElementDescriptionPolyfill
---@field public CreateCheckboxContextMenu fun(owner: BlizzardMenuRootDescriptionPolyfill, isSelected: BlizzardMenuIsSelectedPolyfill, toggleSelected: BlizzardMenuToggleSelectedPolyfill, ...: BlizzardMenuCheckboxInfoPolyfill): BlizzardMenuElementDescriptionPolyfill
---@field public CreateEnumRadioMenu fun(owner: BlizzardMenuRootDescriptionPolyfill, title: string, isSelected: BlizzardMenuIsSelectedPolyfill, toggleSelected: BlizzardMenuToggleSelectedPolyfill, contextData: any): BlizzardMenuElementDescriptionPolyfill
---@field public CreateEnumRadioContextMenu fun(owner: BlizzardMenuRootDescriptionPolyfill, title: string, isSelected: BlizzardMenuIsSelectedPolyfill, toggleSelected: BlizzardMenuToggleSelectedPolyfill, contextData: any): BlizzardMenuElementDescriptionPolyfill
---@field public CreateRadioMenu fun(owner: BlizzardMenuRootDescriptionPolyfill, title: string, isSelected: BlizzardMenuIsSelectedPolyfill, toggleSelected: BlizzardMenuToggleSelectedPolyfill, contextData: any): BlizzardMenuElementDescriptionPolyfill
---@field public CreateRadioContextMenu fun(owner: BlizzardMenuRootDescriptionPolyfill, title: string, isSelected: BlizzardMenuIsSelectedPolyfill, toggleSelected: BlizzardMenuToggleSelectedPolyfill, contextData: any): BlizzardMenuElementDescriptionPolyfill
---@field public GetElementText fun(elementDescription: BlizzardMenuElementDescriptionPolyfill): string?

ns.MenuConstants = MenuConstants

ns.MenuResponse = MenuResponse

---@type BlizzardMenuPolyfill
ns.Menu = Menu

---@type BlizzardMenuUtilPolyfill
ns.MenuUtil = MenuUtil

---@param tag BlizzardMenuTagPolyfill
local function IsMenuOpenByTag(tag)
	for _, openTag in pairs(ns.Menu.GetOpenMenuTags()) do
		if openTag == tag then
			return true
		end
	end
	return false
end

ns.IsMenuOpenByTag = IsMenuOpenByTag
