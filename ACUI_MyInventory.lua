-- -----------------------------------------------------------------
-- File: ACUI_MyInventory.lua
--
-- Purpose: Functions for ACUI_MyInventory WoW Window.
-- Version 3.1.0.1 for WOW/WOTLK 3.1
-- TOC - bumped
-- 
-- Version 3.0.2.2 for WOW 30000 and TBC/pre-WOTLK
-- TOC - bumped
-- Fixed error with pressing BagButtons
-- Fixed error from FrameXML in Options.xml
--
-- Version 2.3.0.0 for WOW 20300 and TBC
-- TOC - bumped and testing started
-- 
-- Version 2.0.1.0 for WOW 20000 and TBC
-- TOC - bumped and testing started
-- 
-- Version 2.0.1.1 for WOW 20000 and TBC
-- Added new ContainerFrameItemButtonTemplate code
-- Added code better loading and in future unloading of hooks
-- Updated usage code.
--
-- Beta - NOT stable
-- Version 2.0.0.0 for WOW 20000 and TBC
-- Updated with new bags, fixed new bagslots, added new features from blizzard
-- Beta - NOT stable
-- Version 1.12.0.1 for WOW 11200
-- Updated with bags and loads ok
-- Version 1.11.0.1 for WOW 11100
-- Updated with bags and loads ok
--
-- Version 1.9.2 for WOW 10900
-- Updated by Arnvid Karstad
-- 
-- Author: Arnvid Karstad - ievil - Asys @ Turalyon_EU
-- 
-- Credits: 
--   Sarf, for the original concept.
--   Svarten and Ramble for bringing the original MyInventory to life
--   Roger V, for the updated ContainerFrameItemButtonTemplate fix
-- Thanks to:
--   Kyzac, Roger V, 
-- -----------------------------------------------------------------
ACUI_MyInventoryDEBUG                = 0;
-- Global declarations {{{
-----------------------
-- Saved Configuration  
-----------------------
ACUI_MyInventoryProfile = {}
local PlayerName = nil;
-----------------------
-- Local Configuration
-----------------------
-- Constants {{{
MYINVENTORY_MAX_ID              = 128; -- Backpack (16) + 4* 28 (Core Soulbags thingies)
MYINVENTORY_COLUMNS_MIN         =   2;
MYINVENTORY_COLUMNS_MAX         =  18;

MYINVENTORY_TOP_HEIGHT          =  20;
MYINVENTORY_BOTTOM_HEIGHT       =  16;

MYINVENTORY_FIRST_ITEM_OFFSET_X =   8;
MYINVENTORY_FIRST_ITEM_OFFSET_Y = -28;
MYINVENTORY_ITEM_OFFSET_X       =  39;
MYINVENTORY_ITEM_OFFSET_Y       = -39;

ACUI_MyInventory_Loaded              = nil;
ACUI_MyInventory_Initialized         = nil;
--}}}
-- Saved Between sessions:These are also the defaults
ACUI_MyInventoryColumns              = 8; -- EMERALD-UI ... changed default

ACUI_MyInventoryReplaceBags          = 1; -- EMERALD-UI ... changed default
ACUI_MyInventoryBags                 = "11111";
ACUI_MyInventoryGraphics             = 0; -- EMERALD-UI
ACUI_MyInventoryHighlightItems       = 0; -- EMERALD-UI (temporary 1700 fix)
ACUI_MyInventoryHighlightBags        = 0; -- EMERALD-UI (temporary 1700 fix)
ACUI_MyInventoryFreeze               = 0;
-- Keep the window from closing with Close
-- These options are on the MI Window itself.
ACUI_MyInventoryLock                 = 0; -- Lock the window in place
ACUI_MyInventoryBagView              = 0;
--Visibility
ACUI_MyInventoryCount                = 1;
ACUI_MyInventoryBackground           = 1; -- EMERALD-UI ... changed default
ACUI_MyInventoryShowTitle            = 1;
ACUI_MyInventoryCash                 = 1;
ACUI_MyInventoryButtons              = 1;
ACUI_MyInventoryScale                = 1;
ACUI_MyInventoryAIOIStyle            = 0;
ACUI_MyInventoryBagBorder            = 0;

-- Hooked functions {{{
ACUI_MyInventory_Saved_ToggleBag                        = nil;
ACUI_MyInventory_Saved_OpenBag                          = nil;
ACUI_MyInventory_Saved_CloseBag                         = nil;
ACUI_MyInventory_Saved_ToggleBackpack                   = nil;
ACUI_MyInventory_Saved_CloseBackpack                    = nil;
ACUI_MyInventory_Saved_OpenBackpack                     = nil;
ACUI_MyInventory_Saved_OpenAllBags                      = nil;
ACUI_MyInventory_Saved_CloseAllBags                     = nil;
ACUI_MyInventory_Saved_BagSlotButton_OnClick            = nil;
ACUI_MyInventory_Saved_BagSlotButton_OnDrag             = nil;
ACUI_MyInventory_Saved_BackpackButton_OnClick           = nil;
ACUI_MyInventory_Saved_LootFrame_OnShow                 = nil;
-- ACUI_MyInventory_Saved_UseContainerItem                 = nil;
-- }}}
-- }}}

-- Loading {{{
function ACUI_MyInventory_InitializeProfile() --{{{
	if ACUI_MyInventory_Initialized == true then
		return
	end
	if ( UnitName('player') ) then
		PlayerName = UnitName('player').."|"..ACUI_MyInventory_Trim(GetCVar("realmName"));
		ACUI_MyInventory_LoadSettings();
		ACUI_MyInventory_Print(format(MYINVENTORY_MSG_INIT_s,PlayerName));
		ACUI_MyInventory_Initialized = true;
		ACUI_MyInventoryFrame_UpdateLook();
		ACUI_MyInventory_SetFreeze();
	end
end --}}}
function ACUI_MyInventory_LoadSettings() --{{{
	if ( ACUI_MyInventoryProfile[PlayerName] == nil ) then
		ACUI_MyInventoryProfile[PlayerName] = {};
		ACUI_MyInventory_Print(format(MYINVENTORY_MSG_CREATE_s,PlayerName));
	end
	ACUI_MyInventoryColumns        = ACUI_MyInventory_SavedOrDefault("Columns");
	ACUI_MyInventoryReplaceBags    = ACUI_MyInventory_SavedOrDefault("ReplaceBags");
	ACUI_MyInventoryFreeze         = ACUI_MyInventory_SavedOrDefault("Freeze");
	ACUI_MyInventoryLock           = ACUI_MyInventory_SavedOrDefault("Lock");
	ACUI_MyInventoryHighlightItems = ACUI_MyInventory_SavedOrDefault("HighlightItems");
	ACUI_MyInventoryHighlightBags  = ACUI_MyInventory_SavedOrDefault("HighlightBags");
	ACUI_MyInventoryBagView        = ACUI_MyInventory_SavedOrDefault("BagView");
	ACUI_MyInventoryGraphics       = ACUI_MyInventory_SavedOrDefault("Graphics");
	ACUI_MyInventoryBackground     = ACUI_MyInventory_SavedOrDefault("Background");
	ACUI_MyInventoryCount          = ACUI_MyInventory_SavedOrDefault("Count");
	ACUI_MyInventoryShowTitle      = ACUI_MyInventory_SavedOrDefault("ShowTitle");
	ACUI_MyInventoryCash           = ACUI_MyInventory_SavedOrDefault("Cash");
	ACUI_MyInventoryButtons        = ACUI_MyInventory_SavedOrDefault("Buttons");
	ACUI_MyInventoryScale          = ACUI_MyInventory_SavedOrDefault("Scale");
	ACUI_MyInventoryBags           = ACUI_MyInventory_SavedOrDefault("Bags");
	ACUI_MyInventoryAIOIStyle      = ACUI_MyInventory_SavedOrDefault("AIOIStyle");

	ACUI_MyInventory_SetScale(tonumber(ACUI_MyInventoryScale));
end -- }}}
function ACUI_MyInventory_SavedOrDefault(varname) -- {{{
	if PlayerName == nil or varname == nil then
		ACUI_MyInventory_DEBUG("ERR: nil value");
		return nil;
	end
	if ACUI_MyInventoryProfile[PlayerName][varname] == nil then -- Setting not set
		ACUI_MyInventoryProfile[PlayerName][varname] = getglobal("ACUI_MyInventory"..varname); -- Load Default
	end
	return ACUI_MyInventoryProfile[PlayerName][varname];  -- Return Setting.
end -- }}}
-- }}}
function ACUI_MyInventory_Toggle_Option(option, value, quiet, updateLook) -- {{{
	if value == nil then
		if getglobal("ACUI_MyInventory"..option) == 1 then
			value = 0;
		else
			value = 1;
		end
	end
	setglobal("ACUI_MyInventory"..option, value);
	ACUI_MyInventoryProfile[PlayerName][option] = value;
	if not quiet or  quiet ~= 1 then
		local chat_message;
		local globalName = "MYINVENTORY_CHAT_"..string.upper(option);
		if value == 0 then
			globalName = globalName.."OFF";
		else
			globalName = globalName.."ON";
		end
		chat_message = getglobal(globalName);
		if ( chat_message ) then
			ACUI_MyInventory_Print(MYINVENTORY_CHAT_PREFIX..chat_message);
		else
			ACUI_MyInventory_DEBUG("ERROR: No global "..globalName);
		end
	end
	if ACUI_MyInventoryBagView == 1 and ACUI_MyInventoryColumns < 5 then
		ACUI_MyInventoryFrame_SetColumns(5);
	end
	if updateLook and updateLook == 1 then
		ACUI_MyInventoryFrame_UpdateLook();
	end
	if option=="Freeze" then
		ACUI_MyInventory_SetFreeze()
	end
end
function ACUI_MyInventory_SetFreeze()
	if ACUI_MyInventoryFreeze == 0 then
		tinsert(UISpecialFrames, "ACUI_MyInventoryFrame"); -- Esc Closes Inventory 
	else
		for key, value in pairs(UISpecialFrames) do
			if value == "ACUI_MyInventoryFrame" then
				table.remove(UISpecialFrames, key);
			end
		end
	end
end
-- }}}
-- Slash commands {{{
function ACUI_MyInventory_ChatCommandHandler(msg) -- {{{

	if ( ( not msg ) or ( strlen(msg) <= 0 ) ) then
		ACUI_MyInventory_Print(MYINVENTORY_CHAT_COMMAND_USAGE);
		return;
	end
	
	local commandName, params = ACUI_MyInventory_Extract_NextParameter(msg);
  
	if ( ( commandName ) and ( strlen(commandName) > 0 ) ) then
		commandName = string.lower(commandName);
	else
		commandName = "";
	end
 
	if ( (strfind(commandName, "show")) or (strfind(commandName, "toggle")) ) then
		ToggleACUI_MyInventoryFrame();
	elseif ( strfind(commandName, "config") or strfind(commandName, "option") ) then
		ACUI_MyInventoryOptionsFrame:Show();
	elseif ( strfind(commandName, "replace") ) then
		ACUI_MyInventory_Toggle_Option("ReplaceBags");
	elseif ( strfind(commandName, "freeze") ) then
		ACUI_MyInventory_Toggle_Option("Freeze");
	elseif ( strfind(commandName, "aioi") ) then
		ACUI_MyInventory_Toggle_Option("AIOIStyle", nil, nil, 1);
	elseif ( strfind(commandName, "lock") ) then
		ACUI_MyInventory_Toggle_Option("Lock",nil,nil,1);
	elseif ( strfind(commandName, "cash") or strfind(commandName, "money")) then
		ACUI_MyInventory_Toggle_Option("Cash",nil,nil,1);
	elseif ( strfind(commandName, "button") ) then
		ACUI_MyInventory_Toggle_Option("Buttons",nil,nil,1);
	elseif ( strfind(commandName, "title") ) then
		ACUI_MyInventory_Toggle_Option("ShowTitle",nil,nil,1);
	elseif ( strfind(commandName, "count") or strfind(commandName, "slot")) then
		ACUI_MyInventory_Toggle_Option("Count",nil,nil,1);
	elseif ( strfind(commandName, "graphic") or strfind(commandName, "art") ) then
		ACUI_MyInventory_Toggle_Option("Graphics",nil,nil,1);
	elseif ( strfind(commandName, "back") ) then
		ACUI_MyInventory_Toggle_Option("Background",nil,nil,1);
	elseif ( strfind(commandName, "bagview") ) then
		ACUI_MyInventory_Toggle_Option("BagView",nil,nil,1);
	elseif ( strfind(commandName, "col") ) then
		cols, params = ACUI_MyInventory_Extract_NextParameter(params);
		if cols then
			ACUI_MyInventoryFrame_SetColumns(cols);
		end
	elseif ( strfind(commandName, "scale") ) then
		scale, params = ACUI_MyInventory_Extract_NextParameter(params);
		if tonumber(scale) and tonumber(scale) >= 0.5 and tonumber(scale) <= 1.5 then
			ACUI_MyInventory_SetScale(scale);
		else
			ACUI_MyInventory_Print("ACUI_MyInventory: Scale is at "..ACUI_MyInventoryScale);
		end
	elseif ( strfind(commandName, "resetpos") ) then
		ACUI_MyInventoryAnchorFrame:ClearAllPoints();
		ACUI_MyInventoryAnchorFrame:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", 0, 50);
		ACUI_MyInventoryFrame:ClearAllPoints();
		ACUI_MyInventoryFrame:SetPoint("BOTTOMRIGHT", "ACUI_MyInventoryAnchorFrame", "BOTTOMRIGHT");
	else
		ACUI_MyInventory_Print(MYINVENTORY_CHAT_COMMAND_USAGE);
		return;
	end
end -- }}}
function ACUI_MyInventory_Extract_NextParameter(msg) -- {{{
	local params = msg;
	local command = params;
	local index = strfind(command, " ");
	if ( index ) then
		command = strsub(command, 1, index-1);
		params = strsub(params, index+1);
	else
		params = "";
	end
	return command, params;
end -- }}}
-- }}}
function ACUI_MyInventory_SetScale(scale) -- {{{
	local pScale = tonumber(ACUI_MyInventoryFrame:GetParent():GetScale());
	if ( pScale == nil ) then
		pScale = tonumber(GetCVar("uiscale"));
		if not pScale then
			pScale = 1;
			ACUI_MyInventory_DEBUG("Scale Error")
		end
	end

	ACUI_MyInventoryFrame:SetScale(pScale * tonumber(scale));
	ACUI_MyInventory_Toggle_Option("Scale", scale, 1);
end -- }}}
function ACUI_MyInventoryFrame_SetColumns(col) -- {{{
	if ( type(col) ~= "number" ) then
		col = tonumber(col);
	end
	if (type(col) ~= "number" or col == 0) then
		return
	end
	if ACUI_MyInventoryBagView == 1 and col < 5 then
		col = 5;
	end
	if ( ( col >= MYINVENTORY_COLUMNS_MIN ) and ( col <= MYINVENTORY_COLUMNS_MAX ) ) then
		ACUI_MyInventoryColumns = col;
		ACUI_MyInventoryProfile[PlayerName].Columns = ACUI_MyInventoryColumns;
		ACUI_MyInventoryFrame_UpdateLook();
	end
end -- }}}

-- Get Bag Slots {{{
function ACUI_MyInventory_GetBagsTotalSlots() -- {{{
	local slots = 0;
	for bag = 0, 4 do
		slots = slots + GetContainerNumSlots(bag);
	end
	return slots;
end -- }}}
function ACUI_MyInventory_GetBagsReplacingSlots() -- {{{
	local slots = 0;
	for bag = 0, 4 do
		if ACUI_MyInventory_ShouldOverrideBag(bag) then
			slots = slots + GetContainerNumSlots(bag);
		end
	end
	return slots;
end  -- }}}
function ACUI_MyInventory_GetIdAsBagSlot(id) -- {{{
	-- depreciated
	local button = getglobal("ACUI_MyInventoryFrameItem"..id);
	if button.bagIndex then
		return button.bagIndex, button.itemIndex;
	end
	return -1,-1;
end -- }}}
-- }}}

-- Loading {{{
function ACUI_MyInventoryFrame_OnLoad() -- {{{
	this:RegisterEvent("BAG_UPDATE");
	this:RegisterEvent("BAG_UPDATE_COOLDOWN");
	this:RegisterEvent("ITEM_LOCK_CHANGED");
	this:RegisterEvent("UPDATE_INVENTORY_ALERTS");
	ACUI_MyInventory_Register();
	ACUI_MyInventory_Print(MYINVENTORY_MSG_LOADED);
	local pScale = ACUI_MyInventoryFrame:GetParent():GetScale();
	if ( not pScale ) then pScale = 1; end
	if ACUI_MyInventoryFrame:GetScale() ~= pScale * tonumber(ACUI_MyInventoryScale) then
		ACUI_MyInventoryFrame:SetScale(ACUI_MyInventoryScale);
	end
end -- }}}
function ACUI_MyInventory_Register() -- {{{
	SlashCmdList["MYINVENTORYSLASHMAIN"] = ACUI_MyInventory_ChatCommandHandler;
	SLASH_MYINVENTORYSLASHMAIN1 = "/myinventory";
	SLASH_MYINVENTORYSLASHMAIN2 = "/mi";
	this:RegisterEvent("UNIT_NAME_UPDATE");
	this:RegisterEvent("VARIABLES_LOADED");
end -- }}}
function ACUI_MyInventory_MyAddonsRegister() -- {{{
	if (myAddOnsFrame) then
		myAddOnsList.ACUI_MyInventory = {
			name = MYINVENTORY_MYADDON_NAME,
			description = MYINVENTORY_MYADDON_DESCRIPTION,
			version = MYINVENTORY_MYADDON_VERSION,
			category = MYADDONS_CATEGORY_INVENTORY,
			frame = "ACUI_MyInventoryFrame",
			optionsframe = "ACUI_MyInventoryOptionsFrame"
		};
	end
end -- }}}
-- }}}
-- Hooks functions. {{{
--  Hooking functions mean that you replace them with your own functions and then call the 
--  original function at your leisure.
function ACUI_MyInventory_Setup_Hooks(toggle) -- {{{
	if (toggle == 1) then
		if ( ( ToggleBag ~= ACUI_MyInventory_Saved_ToggleBag ) and (ACUI_MyInventory_Saved_ToggleBag == nil) ) then
			ACUI_MyInventory_Saved_ToggleBag = ToggleBag;
			ToggleBag = ACUI_MyInventory_ToggleBag;
		end
		if ( ( OpenBag ~= ACUI_MyInventory_Saved_OpenBag ) and (ACUI_MyInventory_Saved_OpenBag == nil) ) then
			ACUI_MyInventory_Saved_CloseBag = CloseBag;
			CloseBag = ACUI_MyInventory_CloseBag;
		end
		if ( ( OpenBag ~= ACUI_MyInventory_Saved_OpenBag ) and ( ACUI_MyInventory_Saved_OpenBag == nil) ) then
			ACUI_MyInventory_Saved_OpenBag = OpenBag;
			OpenBag = ACUI_MyInventory_OpenBag;
		end
		if ( ( OpenAllBags ~= ACUI_MyInventory_Saved_OpenAllBags ) and (ACUI_MyInventory_Saved_OpenAllBags == nil) ) then
			ACUI_MyInventory_Saved_OpenAllBags = OpenAllBags;
			OpenAllBags = ACUI_MyInventory_OpenAllBags;
		end
		if ( ( CloseAllBags ~= ACUI_MyInventory_Saved_CloseAllBags ) and (ACUI_MyInventory_Saved_CloseAllBags == nil) ) then
			ACUI_MyInventory_Saved_CloseAllBags = CloseAllBags;
			CloseAllBags = ACUI_MyInventory_CloseAllBags;
		end
		if ( ( ToggleBackpack ~= ACUI_MyInventory_Saved_ToggleBackpack ) and ( ACUI_MyInventory_Saved_ToggleBackpack == nil) ) then
			ACUI_MyInventory_Saved_ToggleBackpack = ToggleBackpack;
			ToggleBackpack = ACUI_MyInventory_ToggleBackpack;
		end
		if ( ( CloseBackpack ~= ACUI_MyInventory_Saved_CloseBackpack ) and (ACUI_MyInventory_Saved_CloseBackpack == nil) ) then
			ACUI_MyInventory_Saved_CloseBackpack = CloseBackpack;
			CloseBackpack = ACUI_MyInventory_CloseBackpack;
		end
		if ( (OpenBackpack ~= ACUI_MyInventory_Saved_OpenBackpack ) and (ACUI_MyInventory_Saved_OpenBackpack == nil) ) then
			ACUI_MyInventory_Saved_OpenBackpack = OpenBackpack;
			OpenBackpack = ACUI_MyInventory_OpenBackpack;
		end
		if ( (BagSlotButton_OnClick  ~= ACUI_MyInventory_Saved_BagSlotButton_OnClick ) and (ACUI_MyInventory_Saved_BagSlotButton_OnClick == nil) ) then
			ACUI_MyInventory_Saved_BagSlotButton_OnClick = BagSlotButton_OnClick;
			BagSlotButton_OnClick = ACUI_MyInventory_BagSlotButton_OnClick;
		end
		if ( (BagSlotButton_OnDrag  ~= ACUI_MyInventory_Saved_BagSlotButton_OnDrag ) and (ACUI_MyInventory_Saved_BagSlotButton_OnDrag == nil) ) then
			ACUI_MyInventory_Saved_BagSlotButton_OnDrag = BagSlotButton_OnDrag;
			BagSlotButton_OnDrag = ACUI_MyInventory_BagSlotButton_OnDrag;
		end
		if ( (BackpackButton_OnClick  ~=  ACUI_MyInventory_Saved_BackpackButton_OnClick) and (ACUI_MyInventory_Saved_BackpackButton_OnClick == nil) ) then
			ACUI_MyInventory_Saved_BackpackButton_OnClick = BackpackButton_OnClick;
			BackpackButton_OnClick = ACUI_MyInventory_BackpackButton_OnClick;
		end
--		if ( (LootFrame_OnShow  ~= ACUI_MyInventory_Saved_LootFrame_OnShow ) and (ACUI_MyInventory_Saved_LootFrame_OnShow == nil) ) then
--			ACUI_MyInventory_Saved_LootFrame_OnShow = LootFrame_OnShow;
--			LootFrame_OnShow = ACUI_MyInventory_LootFrame_OnShow;
--		end
--		if ( (UseContainerItem ~= ACUI_MyInventory_Saved_UseContainerItem ) and (ACUI_MyInventory_Saved_UseContainerItem == nil) ) then
--			ACUI_MyInventory_DEBUG("hooking UseContainerItem");
--			ACUI_MyInventory_Saved_UseContainerItem = UseContainerItem;
--			UseContainerItem = ACUI_MyInventory_UseContainerItem;
--		end
--		if ( (  ~=  ) and ( == nil) ) then
--		end
--		if ( (  ~=  ) and ( == nil) ) then
--		end
	else
	end
end -- }}}

-- Does things with the hooked function -- {{{
function ACUI_MyInventory_LootFrame_OnShow()
	ACUI_MyInventory_Saved_LootFrame_OnShow();
	LootFrame:Raise();
end

function ACUI_MyInventory_BagSlotButton_OnClick(self,button)
	ACUI_MyInventory_Saved_BagSlotButton_OnClick(self,button)
	ACUI_MyInventory_UpdateBagState();
end

function ACUI_MyInventory_BagSlotButton_OnDrag()
	ACUI_MyInventory_Saved_BagSlotButton_OnDrag()
	ACUI_MyInventory_UpdateBagState();
end

function ACUI_MyInventory_BackpackButton_OnClick(self, button)
	ACUI_MyInventory_Saved_BackpackButton_OnClick(self, button)
	ACUI_MyInventory_UpdateBagState();
end -- }}}
-- Toggling Bags/Backpack {{{
function ACUI_MyInventory_ShouldOverrideBag(bag)
	if (  (bag >= 0) and (bag <= 4) ) then
		if strsub(ACUI_MyInventoryBags,(1+bag),(1+bag)) == "1" then
			return true;
		else
			return false
		end
	else
		return false;
	end
end

function ACUI_MyInventory_ToggleBackpack()
	ACUI_MyInventory_DEBUG("ToggleBackpack called");
	if ((ACUI_MyInventoryReplaceBags == 1) and ACUI_MyInventory_ShouldOverrideBag(0)) then
		ToggleACUI_MyInventoryFrame();
		return;
	end
	ACUI_MyInventory_Saved_ToggleBackpack()
	ACUI_MyInventory_UpdateBagState();
end

function ACUI_MyInventory_ToggleBag(bag)
	ACUI_MyInventory_DEBUG("ToggleBag"..bag.." called");
	if ((ACUI_MyInventoryReplaceBags == 1) and ACUI_MyInventory_ShouldOverrideBag(bag)) then
		ToggleACUI_MyInventoryFrame();
		return;
	else
		ACUI_MyInventory_Saved_ToggleBag(bag);
		ACUI_MyInventory_UpdateBagState();
	end
end

function ACUI_MyInventory_OpenBackpack()
	ACUI_MyInventory_DEBUG("Open Backpack called");
	if ( ACUI_MyInventoryReplaceBags == 1 ) then  
		OpenACUI_MyInventoryFrame();
		return;
	end
	ACUI_MyInventory_Saved_OpenBackpack()
	ACUI_MyInventory_UpdateBagState();
end

function ACUI_MyInventory_CloseBackpack()
	ACUI_MyInventory_DEBUG("Close Backpack called");
	if ( ACUI_MyInventoryReplaceBags == 1 ) then
		if ( ACUI_MyInventoryFreeze == 0) then
			CloseACUI_MyInventoryFrame();
		end
		return;
	end
	ACUI_MyInventory_DEBUG("Default close");
	ACUI_MyInventory_Saved_CloseBackpack()
	ACUI_MyInventory_UpdateBagState();
end

function ACUI_MyInventory_CloseBag(bag)
	ACUI_MyInventory_DEBUG("Close Bag"..bag.." called");
	if ((ACUI_MyInventoryReplaceBags == 1) and ACUI_MyInventory_ShouldOverrideBag(bag)) then
		return;
	else
		ACUI_MyInventory_Saved_CloseBag(bag);
		ACUI_MyInventory_UpdateBagState(); 
	end
end

function ACUI_MyInventory_OpenBag(bag)
	if ((ACUI_MyInventoryReplaceBags == 1) and ACUI_MyInventory_ShouldOverrideBag(bag)) then
		return;
	else
		ACUI_MyInventory_Saved_OpenBag(bag)
		ACUI_MyInventory_UpdateBagState();
	end
end
function ACUI_MyInventory_OpenAllBags(arg)
	ACUI_MyInventory_DEBUG("Open All Bags Called");
	if ((ACUI_MyInventoryReplaceBags == 1)) then
		ACUI_MyInventory_DEBUG("Replacing function");
		OpenACUI_MyInventoryFrame();
		return;
	else
		ACUI_MyInventory_Saved_OpenAllBags(arg);
	end
end
function ACUI_MyInventory_CloseAllBags(arg)
	ACUI_MyInventory_DEBUG("Close All Bags Called");
	if ((ACUI_MyInventoryReplaceBags == 1) and ACUI_MyInventory_Freeze == 1) then
		ACUI_MyInventory_DEBUG("Replacing function");
		return
	else
		ACUI_MyInventory_Saved_CloseAllBags(arg);
	end
end

function ACUI_MyInventory_UseContainerItem(bag, slot)
	ACUI_MyInventory_DEBUG("UseContainerItem called");
	if ( not slot ) then
		local b,s = ACUI_MyInventory_GetIdAsBagSlot(bag);
		if ( ( b > -1 ) and ( s > -1 ) ) then
			return ACUI_MyInventory_Saved_UseContainerItem(b, s);
		end
	end
	return ACUI_MyInventory_Saved_UseContainerItem(bag, slot);
end


-- }}}
-- }}}
-- Text related functions. {{{
function ACUI_MyInventory_Trim (s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"));
end

function ACUI_MyInventory_Print(msg,r,g,b,frame,id,unknown4th)
	--if ( Print ) then
	--	Print(msg, r, g, b, frame, id, unknown4th);
	--	return;
	--end
	if(unknown4th) then
		local temp = id;
		id = unknown4th;
		unknown4th = id;
	end
	
	if (not r) then r = 1.0; end
	if (not g) then g = 1.0; end
	if (not b) then b = 1.0; end
	if not frame then
		if DEFAULT_CHAT_FRAME then
			frame = DEFAULT_CHAT_FRAME
		else
			ACUI_MyInventory_DEBUG("quitting print");
			return
		end
	end
	if type(msg) == "table" then
		for key, value in pairs(msg) do
			frame:AddMessage(value, r, g, b,id,unknown4th);
		end
	else
		frame:AddMessage(msg, r, g, b,id,unknown4th);
	end
end

function ACUI_MyInventory_DEBUG(msg)
	-- If Debug is not set, just skip it.
	if ( not ACUI_MyInventoryDEBUG or ACUI_MyInventoryDEBUG == 0 ) then
		return;
	end
	
	msg = "*** DEBUG(ACUI_MyInventory): "..msg;
	if ( DEFAULT_CHAT_FRAME ) then 
		DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 1.0, 0.0);
	end
end
-- }}}
-- Toggle Frame {{{
function ToggleACUI_MyInventoryFrame() -- {{{
	if ( ACUI_MyInventoryFrame:IsVisible() ) then
		CloseACUI_MyInventoryFrame();
	else
		OpenACUI_MyInventoryFrame();
	end
	ACUI_MyInventory_UpdateBagState();
end -- }}}
function CloseACUI_MyInventoryFrame() -- {{{
	if ( ACUI_MyInventoryFrame:IsVisible() ) then
		ACUI_MyInventoryFrame:Hide();
	end
	ACUI_MyInventory_UpdateBagState();
end --}}}

function OpenACUI_MyInventoryFrame() -- {{{
	ACUI_MyInventoryFrame_UpdateLookIfNeeded();
	ACUI_MyInventoryFrame:Show();
	ACUI_MyInventory_UpdateBagState();
end --}}}
-- }}}
-- Update Bag State: Setting Checks {{{
function ACUI_MyInventory_IsBagOpen(id)
	local formatStr = "ContainerFrame%d";
	local frame = nil;
	for i = 1, NUM_CONTAINER_FRAMES do
		frame = getglobal(format(formatStr, i));
		if ( ( frame ) and ( frame:IsVisible() ) and ( frame:GetID() == id ) ) then
			return true;
		end
	end
	return false;
end
function ACUI_MyInventory_GetBagState(toggle)
	if ( ( toggle == true ) or ( toggle == 1 ) ) then
		return 1;
	else
		return 0;
	end
end
function ACUI_MyInventory_UpdateBagState()
	local visible = ACUI_MyInventoryFrame:IsVisible();
	local val = strsub(ACUI_MyInventoryBags, 1,1);
	MainMenuBarBackpackButton:SetChecked(ACUI_MyInventory_GetBagState((val=="1" and visible) or ACUI_MyInventory_IsBagOpen(0)));
	ACUI_MyInventoryBackpackButton:SetChecked(ACUI_MyInventory_GetBagState((val=="1" and visible)));
	local bagButton = nil;
	local mibagButton = nil
	local formatStr = "CharacterBag%dSlot";
	local formatStr2= "MyInventoBag%dSlot";
	for i = 0, 3 do 
		local val = strsub(ACUI_MyInventoryBags, i+2,i+2);
		bagButton   = getglobal(format(formatStr, i));
		mibagButton = getglobal(format(formatStr2, i)); 
		if ( bagButton ) then
			bagButton:SetChecked(ACUI_MyInventory_GetBagState((val=="1" and visible) or ACUI_MyInventory_IsBagOpen(i+1)));
			mibagButton:SetChecked(ACUI_MyInventory_GetBagState((val=="1" and visible) ));
		end
	end
end
-- }}}
-- Frame Events {{{
function ACUI_MyInventoryFrame_OnEvent(event)
	if ( event == "VARIABLES_LOADED" ) then
		ACUI_MyInventory_Setup_Hooks(1);
		ACUI_MyInventory_DEBUG("Variables Loaded...");
		ACUI_MyInventory_Loaded = true;
		ACUI_MyInventory_MyAddonsRegister();
		ACUI_MyInventory_InitializeProfile();
	end
	if not ACUI_MyInventory_Loaded then
		return
	end
	--if ( event == "UNIT_NAME_UPDATE" and arg1 == "player" and UnitName("player") ~= UNKNOWNOBJECT) then
		--ACUI_MyInventory_InitializeProfile();
	--end
	if PlayerName == nil then 
		return
	end
	if ( event == "BAG_UPDATE" ) then
		if ( this:IsVisible() ) then
			ACUI_MyInventory_DEBUG("BAG_UPDATE Event fired.");
			ACUI_MyInventoryFrame_Update(ACUI_MyInventoryFrame);
		end
	elseif ( event == "ITEM_LOCK_CHANGED" or event == "BAG_UPDATE_COOLDOWN" or event == "UPDATE_INVENTORY_ALERTS" ) then
		if ( this:IsVisible() ) then
			ACUI_MyInventoryFrame_Update(ACUI_MyInventoryFrame);
		end
	end
end

function ACUI_MyInventoryFrame_OnHide()
	PlaySound("igBackPackClose");
	ACUI_MyInventory_UpdateBagState();
end

function ACUI_MyInventoryFrame_OnShow()
	if ACUI_MyInventory_Initialized == false then
		ACUI_MyInventoryFrame:Hide();
		return;
	end
	ACUI_MyInventoryFrame_Update(ACUI_MyInventoryFrame);
	PlaySound("igBackPackOpen");
	ACUI_MyInventoryFrame:ClearAllPoints();
	ACUI_MyInventoryFrame:SetPoint("BOTTOMRIGHT", "ACUI_MyInventoryAnchorFrame", "BOTTOMRIGHT");
	local pScale = ACUI_MyInventoryFrame:GetParent():GetScale();
	if ( not pScale ) then pScale = 1; end
	if ACUI_MyInventoryFrame:GetScale() ~= pScale * tonumber(ACUI_MyInventoryScale) then
		ACUI_MyInventoryFrame:SetScale(ACUI_MyInventoryScale);
	end
end
function ACUI_MyInventoryFrame_OnMouseDown(arg1)
	if ( arg1 == "LeftButton" ) then
		if ( ACUI_MyInventoryLock == 0 ) then
			-- this:StartMoving();
			ACUI_MyInventoryAnchorFrame:StartMoving();
		else
			ACUI_MyInventory_Print("ACUI_MyInventory is locked and can not move...");
		end
	end
end
function ACUI_MyInventoryFrame_OnMouseUp(arg1)
	if ( arg1 == "LeftButton" ) then
		this:StopMovingOrSizing();
		ACUI_MyInventoryAnchorFrame:StopMovingOrSizing();
	end
end
-- }}}
-- Item Button Events {{{
function ACUI_MyInventoryFrameItemButton_OnLoad()
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	this:RegisterForDrag("LeftButton");
 	this:RegisterEvent("CURSOR_UPDATE");
 	this:RegisterEvent("BAG_UPDATE_COOLDOWN");
 		
	this.SplitStack = function(button, split)
		SplitContainerItem(button:GetParent():GetID(), button:GetID(), split);
	end
	getglobal(this:GetName().."NormalTexture"):SetTexture("Interface\\AddOns\\ACUI_MyInventory\\Skin\\Button");
end

-- EMERALD: Add DressingRoom code here
function ACUI_MyInventoryFrameItemButton_OnClick(button, ignoreShift)
	local bag, slot = this.bagIndex, this.itemIndex;
	if ( button == "LeftButton" ) then
		if ( IsShiftKeyDown() and not ignoreShift ) then
			if ( ChatFrameEditBox:IsVisible() ) then
				ChatFrameEditBox:Insert(GetContainerItemLink(bag, slot));
			else
				local texture, itemCount, locked = GetContainerItemInfo(bag, slot);
				if ( not locked ) then
					this.SplitStack = function(button, split)
						SplitContainerItem(bag, slot, split);
					end
					OpenStackSplitFrame(this.count, this, "BOTTOMRIGHT", "TOPRIGHT");
				end
			end
		elseif ( IsControlKeyDown() ) then -- EMERALD: DressingRoom
			DressUpItemLink(GetContainerItemLink(bag, slot));
		else
			PickupContainerItem(bag, slot);
		end
	elseif ( button == "RightButton" ) then
		if ( IsShiftKeyDown() and MerchantFrame:IsVisible() and not ignoreShift ) then
			this.SplitStack = function(button, split)
				SplitContainerItem(button:GetParent():GetID(), button:GetID(), split);
				MerchantItemButton_OnClick("LeftButton");
			end
			OpenStackSplitFrame(this.count, this, "BOTTOMRIGHT", "TOPRIGHT");
		elseif ( MerchantFrame:IsVisible() and MerchantFrame.selectedTab == 2 ) then
			-- Don't sell the item if the buyback tab is selected
			return;			
		else
			UseContainerItem(bag, slot);
			StackSplitFrame:Hide();
		end
	end
end

function ACUI_MyInventory_ContainerFrameItemButton_OnEnter()
	ACUI_MyInventoryFrameItemButton_OnEnter()
end
function ACUI_MyInventoryFrameItemButton_OnEnter()
	local bag, slot = this.bagIndex, this.itemIndex;
	this:GetParent():SetID(this.bagIndex);
	this:SetID(this.itemIndex);
	ContainerFrameItemButton_OnEnter()
	ACUI_MyInventory_HighlightItemBag(bag);
	if true then
		return
	end
	--  Mimiking: ContainerFrameItemButton_OnEnter() - BEGIN
	GameTooltip:SetOwner(this, "ANCHOR_LEFT");
	local hasCooldown, repairCost = GameTooltip:SetBagItem(bag, slot);
	if ( hasCooldown ) then
		this.updateTooltip = TOOLTIP_UPDATE_TIME;
	else
		this.updateTooltip = nil;
	end
	if ( InRepairMode() and (repairCost and repairCost > 0) ) then
		GameTooltip:AddLine(TEXT(REPAIR_COST), "", 1, 1, 1);
		SetTooltipMoney(GameTooltip, repairCost);
		GameTooltip:Show();
	elseif ( MerchantFrame:IsVisible() ) then
		ShowContainerSellCursor(bag, slot);
	elseif ( this.readable ) then
		ShowInspectCursor();
	end
	--  Mimiking: ContainerFrameItemButton_OnEnter() - END
		
end
function ACUI_MyInventoryFrameItemButton_OnLeave()
	ACUI_MyInventory_HighlightItemBag(this.bagIndex, 1);
	this.updateTooltip = nil;
	GameTooltip:Hide();
	ResetCursor();
end

function ACUI_MyInventoryFrameItemButton_OnUpdate(elapsed)
	if ( not this.updateTooltip ) then
		return;
	end
	
	this.updateTooltip = this.updateTooltip - elapsed;
	if ( this.updateTooltip > 0 ) then
		return;
	end
	
	if ( GameTooltip:IsOwned(this) ) then
		ACUI_MyInventoryFrameItemButton_OnEnter();
	else
		this.updateTooltip = nil;
	end
end
-- }}}

-- Bag Button Events {{{
function ACUI_MyInventory_Backpack_OnEnter()
	GameTooltip:SetOwner(this,"ANCHOR_LEFT");
	GameTooltip:SetText(TEXT(BACKPACK_TOOLTIP),1.0,1.0,1.0);
	local keyBinding = GetBindingKey("TOGGLEBACKPACK");
	if ( keyBinding ) then
	  GameTooltip:AppendText(" "..NORMAL_FONT_COLOR_CODE.."("..keyBinding..")"..FONT_COLOR_CODE_CLOSE);
	end
	ACUI_MyInventory_HighlightBagItems(0);
end
function ACUI_MyInventory_Backpack_OnLeave()
	GameTooltip:Hide();
	ACUI_MyInventory_HighlightBagItems(0,1);
end
function ACUI_MyInventory_BagButton_OnEnter()
	GameTooltip:SetOwner(this,"ANCHOR_RIGHT");
	local hasCooldown, repairCost = GameTooltip:SetInventoryItem("player", this:GetID());
	ACUI_MyInventory_HighlightBagItems(1+this:GetID()-MyInventoBag0Slot:GetID());
end
function ACUI_MyInventory_BagButton_OnLeave()
   this.updateTooltip = nil;
   GameTooltip:Hide();
   ResetCursor();
	local bagID = 1+this:GetID()-MyInventoBag0Slot:GetID();
	ACUI_MyInventory_HighlightBagItems(bagID, 1);
end

function ACUI_MyInventory_BagButton_OnClick()
	local index = tonumber(strsub(this:GetName(), 13, 13))+2;
	local val = strsub(ACUI_MyInventoryBags, index, index);
	if not PutItemInBag(this:GetID()) then
		local bagID = 1+this:GetID()-MyInventoBag0Slot:GetID();
		ACUI_MyInventory_HighlightBagItems(bagID, 1);
		if val == "1" then
			val = "0"
		else
			val = "1"
		end
		ACUI_MyInventoryBags = strsub(ACUI_MyInventoryBags, 1, index-1)..val..strsub(ACUI_MyInventoryBags, index+1);
		ACUI_MyInventory_Toggle_Option("Bags", ACUI_MyInventoryBags);
		ACUI_MyInventory_UpdateBagState();
		ACUI_MyInventoryFrame_UpdateLook();
		ACUI_MyInventoryFrame_Update();
	end
end
function ACUI_MyInventory_Backpack_OnClick()
	local val = strsub(ACUI_MyInventoryBags, 1, 1);
	if not PutItemInBackpack() then
		ACUI_MyInventory_HighlightBagItems(0,1);
		if val == "1" then
			val = "0"
		else
			val = "1"
		end
		ACUI_MyInventoryBags = val..strsub(ACUI_MyInventoryBags, 2);
		ACUI_MyInventory_UpdateBagState();
		ACUI_MyInventoryFrame_UpdateLook();
		ACUI_MyInventoryFrame_Update();
		ACUI_MyInventory_Toggle_Option("Bags", ACUI_MyInventoryBags);
	end
end
function ACUI_MyInventory_BagButton_OnDragStart()
	--BagSlotButton_OnDrag();
	PickupBagFromSlot(this:GetID());
	PlaySound("BAGMENUBUTTONPRESS");
end
function ACUI_MyInventory_BagButton_OnReceiveDrag()
	PutItemInBag(this:GetID());
end
-- }}}
-- Highlighting {{{
function ACUI_MyInventory_HighlightBagItems(bagID, off)
	if ACUI_MyInventoryHighlightItems == 0 then
		return
	end
	local found;
	local itemButton;
	for i = 1,MYINVENTORY_MAX_ID do
		local bag, slot;
		itemButton = getglobal("ACUI_MyInventoryFrameItem"..i);
		bag = itemButton.bagIndex;
		if bag == bagID then
			found = true;
			if off and off == 1 then
				itemButton:UnlockHighlight();
			else
				itemButton:LockHighlight();
			end
		else
			if found then 
				break;
			end
		end
	end
end
function ACUI_MyInventory_HighlightItemBag(bagID, off)
	if ACUI_MyInventoryHighlightBags == 0 then
		return
	end
	local BagButton;
	if bagID == 0 then
		BagButton= getglobal("ACUI_MyInventoryBackpackButton");
	else
		BagButton= getglobal("MyInventoBag"..(bagID-1).."Slot");
	end
	if off then
		BagButton:UnlockHighlight();
	else
		BagButton:LockHighlight();
	end
end
-- }}}
-- Update Visuals, toggled options {{{
function ACUI_MyInventoryTitle_Update()
	if ACUI_MyInventoryCash == 1 then
		ACUI_MyInventoryFrameMoneyFrame:Show();
	else
		ACUI_MyInventoryFrameMoneyFrame:Hide();
	end
	ACUI_MyInventorySlots_Update();
	if ACUI_MyInventoryShowTitle == 0 and ACUI_MyInventoryGraphics == 0 then
		ACUI_MyInventoryFrameName:Hide();
		return;
	end
	ACUI_MyInventoryFrameName:Show();
	if ( UnitName('player') ) then
		local player, realm = UnitName('player'),ACUI_MyInventory_Trim(GetCVar("realmName")); 
		if (ACUI_MyInventoryColumns < 5 ) or (ACUI_MyInventoryGraphics == 1 and ACUI_MyInventoryColumns < 7) then 
			ACUI_MyInventoryFrameName:SetText(MYINVENTORY_TITLE);
		elseif (ACUI_MyInventoryColumns < 7 ) or (ACUI_MyInventoryGraphics == 1 and ACUI_MyInventoryColumns < 9) then
			ACUI_MyInventoryFrameName:SetText(format(MYINVENTORY_TITLE_S, player));
		else
			ACUI_MyInventoryFrameName:SetText(format(MYINVENTORY_TITLE_SS,player, realm));
		end
		ACUI_MyInventoryFrameName:SetTextColor(1.0, 1.0, 1.0);
			
	end
end

function ACUI_MyInventorySlots_Update()
	local i, j, totalSlots= 0, 0, 0;
	local takenSlots = 0;
	
	for i = 0, 4 do
		local slots = GetContainerNumSlots(i)
		if ACUI_MyInventory_ShouldOverrideBag(i) then 
			totalSlots = totalSlots + slots;
			for j = 1, slots do
				if GetContainerItemInfo(i,j) then
					takenSlots=takenSlots + 1;
				end
			end
		end
	end
	if ACUI_MyInventoryCount == 0 then
		ACUI_MyInventoryFrameSlots:Show();
		ACUI_MyInventoryFrameSlots:SetText(format(MYINVENTORY_SLOTS_DD, (totalSlots-takenSlots),totalSlots));
	elseif ACUI_MyInventoryCount == 1 then
		ACUI_MyInventoryFrameSlots:Show();
		ACUI_MyInventoryFrameSlots:SetText(format(MYINVENTORY_SLOTS_DD, (takenSlots),totalSlots));
	else
		ACUI_MyInventoryFrameSlots:Hide();
	end
end

function ACUI_MyInventory_SetLock()
	if ACUI_MyInventoryLock == 1 then
		MILockNormalTexture:SetTexture("Interface\\AddOns\\ACUI_MyInventory\\Skin\\LockButton-Locked-Up");
	else
		MILockNormalTexture:SetTexture("Interface\\AddOns\\ACUI_MyInventory\\Skin\\LockButton-Unlocked-Up");
	end
	ACUI_MyInventoryFrame:EnableMouse(1-ACUI_MyInventoryLock);
end

function ACUI_MyInventory_ShowButtons()
	if ACUI_MyInventoryButtons == 1 or ACUI_MyInventoryGraphics == 1 then
		ACUI_MyInventoryFrameCloseButton:Show();
		ACUI_MyInventoryFrameLockButton:Show();
		ACUI_MyInventoryFrameHideBagsButton:Show();
	else
		ACUI_MyInventoryFrameCloseButton:Hide();
		ACUI_MyInventoryFrameLockButton:Hide();
		ACUI_MyInventoryFrameHideBagsButton:Hide();
	end
end

function ACUI_MyInventory_SetGraphics()
	if ACUI_MyInventoryGraphics == 1 then
		ACUI_MyInventoryFrame:SetBackdropColor(0,0,0,0);
		ACUI_MyInventoryFrame:SetBackdropBorderColor(0,0,0,0);
		
		ACUI_MyInventoryFramePortrait:Show();
		ACUI_MyInventoryFrameTextureTopLeft:Show();
		ACUI_MyInventoryFrameTextureTopCenter:Show();
		ACUI_MyInventoryFrameTextureTopRight:Show();
		ACUI_MyInventoryFrameTextureLeft:Show();
		ACUI_MyInventoryFrameTextureCenter:Show();
		ACUI_MyInventoryFrameTextureRight:Show();
		ACUI_MyInventoryFrameTextureBottomLeft:Show();
		ACUI_MyInventoryFrameTextureBottomCenter:Show();
		ACUI_MyInventoryFrameTextureBottomRight:Show();
		ACUI_MyInventoryFrameName:ClearAllPoints();
		ACUI_MyInventoryFrameName:SetPoint("TOPLEFT", "ACUI_MyInventoryFrame", "TOPLEFT", 70, -8);
		ACUI_MyInventoryFrameCloseButton:ClearAllPoints();
		ACUI_MyInventoryFrameCloseButton:SetPoint("TOPRIGHT", "ACUI_MyInventoryFrame", "TOPRIGHT", 10, 0);
	else
		if ACUI_MyInventoryBackground==1 then
			ACUI_MyInventoryFrame:SetBackdropColor(0,0,0,1.0);
			ACUI_MyInventoryFrame:SetBackdropBorderColor(1,1,1,1.0);
		else
			ACUI_MyInventoryFrame:SetBackdropColor(0,0,0,0);
			ACUI_MyInventoryFrame:SetBackdropBorderColor(1,1,1,0);
		end
			
		ACUI_MyInventoryFramePortrait:Hide();
		ACUI_MyInventoryFrameTextureTopLeft:Hide();
		ACUI_MyInventoryFrameTextureTopCenter:Hide();
		ACUI_MyInventoryFrameTextureTopRight:Hide();
		ACUI_MyInventoryFrameTextureLeft:Hide();
		ACUI_MyInventoryFrameTextureCenter:Hide();
		ACUI_MyInventoryFrameTextureRight:Hide();
		ACUI_MyInventoryFrameTextureBottomLeft:Hide();
		ACUI_MyInventoryFrameTextureBottomCenter:Hide();
		ACUI_MyInventoryFrameTextureBottomRight:Hide();
		ACUI_MyInventoryFrameName:ClearAllPoints();
		ACUI_MyInventoryFrameName:SetPoint("TOPLEFT", "ACUI_MyInventoryFrame", "TOPLEFT", 5, -6);
		ACUI_MyInventoryFrameCloseButton:ClearAllPoints();
		ACUI_MyInventoryFrameCloseButton:SetPoint("TOPRIGHT", "ACUI_MyInventoryFrame", "TOPRIGHT", 2, 2);
	end
end
-- }}}
-- Get Height and Width {{{
function ACUI_MyInventoryFrame_GetAppropriateHeight(rows)
	-- Border 6 on top, 6 on bottom
	-- First row is 28 pixels down.
	-- BASE_HEIGHT = 44
	if ACUI_MyInventoryGraphics == 1 then
		rows = rows+1;
	end
	if ACUI_MyInventoryBagView == 1 then
		if ACUI_MyInventoryGraphics == 0 or ACUI_MyInventoryColumns == 5 then
			rows = rows+1;
		end
	end
	local height = 12;
	if ACUI_MyInventoryButtons==1 or ACUI_MyInventoryShowTitle==1 or ACUI_MyInventoryGraphics == 1 then
		height = height + MYINVENTORY_TOP_HEIGHT;
	end
	if (ACUI_MyInventoryCash==1) or (ACUI_MyInventoryCount > -1)  then
		height = height + MYINVENTORY_BOTTOM_HEIGHT;
	end
	height = height + (-MYINVENTORY_ITEM_OFFSET_Y) * rows;
  return height;
end

function ACUI_MyInventoryFrame_GetAppropriateWidth(cols)
	return 12 + ( MYINVENTORY_ITEM_OFFSET_X * cols );
end
-- }}}
-- Update Look {{{
function ACUI_MyInventoryFrame_UpdateLookIfNeeded()
	local slots = ACUI_MyInventory_GetBagsTotalSlots();
	if ( ( not ACUI_MyInventoryFrame.size ) or ( slots ~= ACUI_MyInventoryFrame.size ) ) then
		ACUI_MyInventoryFrame_UpdateLook();
	end
end
function ACUI_MyInventoryFrame_UpdateLook()
	--local frameSize = ACUI_MyInventory_GetBagsTotalSlots();
	local frameSize = ACUI_MyInventory_GetBagsReplacingSlots();
	ACUI_MyInventoryTitle_Update(); -- Update Title
	ACUI_MyInventory_SetLock();		-- Set Lock Icon
	ACUI_MyInventory_ShowButtons(); -- Show or Hide Buttons
	
	ACUI_MyInventoryFrame.size = frameSize;
	
	local name = ACUI_MyInventoryFrame:GetName();
	-- Update Size Anchor to bottom right
	local columns, rows = ACUI_MyInventoryColumns, ceil(frameSize / ACUI_MyInventoryColumns);

	local height, width = ACUI_MyInventoryFrame_GetAppropriateHeight(rows), ACUI_MyInventoryFrame_GetAppropriateWidth(columns);

	ACUI_MyInventoryFrame:SetHeight(height);
	ACUI_MyInventoryFrame:SetWidth(width);
	
	ACUI_MyInventory_SetGraphics(); -- Turn on or Off Blizzard Graphics
	-- Border	
	local First_Y = -6 ;
	-- Title
	if ACUI_MyInventoryShowTitle==1 or ACUI_MyInventoryButtons == 1 or ACUI_MyInventoryGraphics == 1 then
		First_Y = First_Y - MYINVENTORY_TOP_HEIGHT;
	end
	-- BagButtons
	ACUI_MyInventoryBagButtonsBar:ClearAllPoints();
	if ACUI_MyInventoryGraphics == 1 then
		if ACUI_MyInventoryColumns == 5 then
			First_Y = First_Y + MYINVENTORY_ITEM_OFFSET_Y;
			ACUI_MyInventoryBagButtonsBar:SetPoint("TOP", "ACUI_MyInventoryFrame", "TOP", 0, First_Y);
		else
			ACUI_MyInventoryBagButtonsBar:SetPoint("TOP", "ACUI_MyInventoryFrame", "TOP", 20, First_Y);
			First_Y = First_Y + MYINVENTORY_ITEM_OFFSET_Y;
		end
	else
		ACUI_MyInventoryBagButtonsBar:SetPoint("TOP", "ACUI_MyInventoryFrame", "TOP", 0, First_Y);
	end
	
	if ACUI_MyInventoryBagView == 1 then
		if ACUI_MyInventoryGraphics == 0 or ACUI_MyInventoryColumns == 5 then
			First_Y = First_Y + MYINVENTORY_ITEM_OFFSET_Y;
		end
		ACUI_MyInventoryBagButtonsBar:Show();
	else
		ACUI_MyInventoryBagButtonsBar:Hide();
	end
	local curCol;
	if ACUI_MyInventoryAIOIStyle==1 then
		curCol=columns-mod(frameSize, columns)+1;
	else
		curCol=1;
	end
	local curRow=1;
	for j=1, frameSize, 1 do
		local itemButton = getglobal(name.."Item"..j);
		-- itemButton:SetID(j);
		-- Set first button
		itemButton:ClearAllPoints();
		local dx, dy, baseframe;
		if ( j == 1 ) then
			baseframe = name;
			if ACUI_MyInventoryAIOIStyle == 1 then
				dx = (curCol-1)*MYINVENTORY_ITEM_OFFSET_X + MYINVENTORY_FIRST_ITEM_OFFSET_X;
				dy =    First_Y;
			else
				dx = MYINVENTORY_FIRST_ITEM_OFFSET_X;
				dy = First_Y;
			end
		else
			if ( mod((curCol+j-2), columns) == 0 ) then
				baseframe = "ACUI_MyInventoryFrame";
				dx = MYINVENTORY_FIRST_ITEM_OFFSET_X;
				dy = First_Y + MYINVENTORY_ITEM_OFFSET_Y*curRow;
				curRow=curRow+1;
			else
				baseframe = name.."Item"..(j - 1);
				dy = 0;
				dx = MYINVENTORY_ITEM_OFFSET_X;
			end
		end
		itemButton:SetPoint("TOPLEFT", baseframe, "TOPLEFT", dx, dy);
		
		itemButton:Show();
	end
	local button = nil;
	for i = frameSize+1, MYINVENTORY_MAX_ID do
		button = getglobal("ACUI_MyInventoryFrameItem"..i);
		if ( button ) then
			button:Hide();
		end
	end
end
-- }}}
function ACUI_MyInventoryFrame_Update(frame) --- {{{
	local frame = getglobal("ACUI_MyInventoryFrame");
	ACUI_MyInventoryFrame_UpdateLookIfNeeded();
	local name = frame:GetName();
	local index = 0;
	ACUI_MyInventorySlots_Update();
	local altbag=0;
	for bag=0, 4 do
		if ACUI_MyInventory_ShouldOverrideBag(bag) and GetContainerNumSlots(bag)>0 then 
			altbag=math.abs(altbag-1);
			local slotid = 1;
			for slot=1, GetContainerNumSlots(bag) do

				index = index + 1;
				local itemButton = getglobal(name.."Item"..index);
				local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot);
				itemButton.bagIndex = bag; itemButton.itemIndex = slot; -- Save the slot and bag, MUCH easier then looking it up every time.
				local dummybag = getglobal(name.."Bag"..bag);
				itemButton:SetParent(dummybag);
				itemButton:SetID(slotid);
				slotid = slotid + 1;
				SetItemButtonTexture(itemButton, texture);
				SetItemButtonCount(itemButton, itemCount);
				SetItemButtonDesaturated(itemButton, locked, 0.5, 0.5, 0.5);
				local a;
				if (ACUI_MyInventoryBagBorder==1) then
					a = (1*(altbag));
					SetItemButtonNormalTextureVertexColor(itemButton, a, a, a);
				else
					if ( quality and quality >= 2 ) then    
            -- 0 = grey, 1 = white, 2 = green, 3 = blue, 4 = purple?
            if ( quality == 2 ) then
              SetItemButtonNormalTextureVertexColor(itemButton, 0, 1.0, 0);
            elseif ( quality == 3 ) then
              SetItemButtonNormalTextureVertexColor(itemButton, 0, 0, 1.0);
            elseif ( quality == 4 ) then
              SetItemButtonNormalTextureVertexColor(itemButton, 1.0, 0, 1.0);
            else
              SetItemButtonNormalTextureVertexColor(itemButton, 1.0, 0.7, 0);
            end
					else
						SetItemButtonNormalTextureVertexColor(itemButton, 0.5, 0.5, 0.5);
					end
				end
				 -- If it is a Quiver/AmmoBag -- Added Soulshard bags from kyzac
				if ( string.find(GetBagName(bag), "Quiver") or string.find(GetBagName(bag), "Ammo")) then
					SetItemButtonNormalTextureVertexColor(itemButton, 1.0, 1.0, 0);
				elseif (string.find(GetBagName(bag), "Soul") or string.find(GetBagName(bag), "Felcloth")) then
					SetItemButtonNormalTextureVertexColor(itemButton, 1.0, 0, 0);
				elseif (string.find(GetBagName(bag), "Herb")) then
					SetItemButtonNormalTextureVertexColor(itemButton, 0, 1.0, 0);
				elseif (string.find(GetBagName(bag), "Enchanted")) then
					SetItemButtonNormalTextureVertexColor(itemButton, 0, 0, 1.0);
				end				
				if ( texture ) then
					local cooldown = getglobal(itemButton:GetName().."Cooldown");
					local start, duration, enable = GetContainerItemCooldown(bag, slot);
					CooldownFrame_SetTimer(cooldown, start, duration, enable);
					if ( duration > 0 and enable == 0 ) then
						SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4);
					end
				else
					getglobal(name.."Item"..index.."Cooldown"):Hide();
				end

				itemButton.readable = readable;
				local showSell = nil;
				if ( GameTooltip:IsOwned(itemButton) ) then
					if ( texture ) then
						local hasCooldown, repairCost = GameTooltip:SetBagItem(bag, slot);
						if ( hasCooldown ) then
							itemButton.updateTooltip = TOOLTIP_UPDATE_TIME;
						else
							itemButton.updateTooltip = nil;
						end
						if ( InRepairMode() and (repairCost > 0) ) then
							GameTooltip:AddLine(TEXT(REPAIR_COST), "", 1, 1, 1);
							SetTooltipMoney(GameTooltip, repairCost);
							GameTooltip:Show();
						elseif ( MerchantFrame:IsVisible() and not locked) then
							showSell = 1;
						end
					else
						GameTooltip:Hide();    
					end
					if ( showSell ) then
						ShowContainerSellCursor(bag, slot);
					elseif ( readable ) then    
						ShowInspectCursor();
					else      
						ResetCursor();
					end 
				end
			end
		end
	end
end -- }}}
