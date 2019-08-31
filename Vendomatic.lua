sellframestartindex = 1;
stockframestartindex = 1;

function Vendomatic_OnLoad(frame)
	frame:RegisterEvent("MERCHANT_SHOW");
	frame:RegisterEvent("ADDON_LOADED");
end

SLASH_VENDOMATIC1 = "/vm"
SLASH_VENDOMATIC2 = "/vendomatic"

SlashCmdList["VENDOMATIC"] = function(msg)
	if (msg == "config") then
		VendomaticFrame:Show();
	elseif (msg == "reset") then
		VendomaticFrame:Hide();
		Vendomatic_FirstRun();
		print("|cffffd200Vend-o-matic|r: full reset.");
	elseif (msg == "help" or msg=="") then
		print("|cffffd200Vend-o-matic|r Commands");
		print("/vm config - Open configuration window");
		print("/vm reset - Reset all configuration settings");
		print("/vm help -  Command list");
		print("/vm hide - Hide Minimap button");
		print("/vm show - Show Minimap button");
		print("/vm gmr - Toggle GM guild bank auto repair");
	elseif (msg == "hide") then
		VendomaticButtonFrame:Hide();
		VendomaticOptions.hideminimapicon = 1;
		print("|cffffd200Vend-o-matic|r: Minimap Button is now hidden");
	elseif (msg == "show") then
		VendomaticButtonFrame:Show();
		VendomaticOptions.hideminimapicon = 0;
	elseif (msg == "gmr") then
		if (VendomaticOptions.gmbankrepair == 0) then
			VendomaticOptions.gmbankrepair = 1;
			print("Vendomatic GM Bank Repair Toggled ON");
		else
		VendomaticOptions.gmbankrepair = 0;
		print("Vendomatic GM Bank Repair Toggled OFF");
		end
	else
		print("|cffffd200Vend-o-matic|r: Minimap Button is now visible");
	end
end 

function Vendomatic_OnEvent(frame, event, ...)
	if event == "ADDON_LOADED" then	
		if (VendomaticOptions == nil) then
			print("This seems to be your first time running |cffffd200Vend-o-matic|r. Please take the time to configure the addon.");
			VendomaticOptions = { };
			Vendomatic_FirstRun();
			VendomaticFrame:Show();
		end
		if VendomaticOptions.hideminimapicon == 1 then
			VendomaticButtonFrame:Hide();
		else
			VendomaticButtonFrame:Show();
		end
		startindex = 1;
		if VendomaticOptions.listtype == 0 then
			Vendomatic_OptionsSellFrameToggleButtonText:SetText("|cffff0000Retain|r these items");
		else
			Vendomatic_OptionsSellFrameToggleButtonText:SetText("|cff00ff00Sell|r these items");
		end
	end
	if event == "MERCHANT_SHOW" then
		local targetname = UnitName("target");		
		if CanMerchantRepair() then
			if (VendomaticOptions.autorepair == 1) then
				Vendomatic_AutoRepair();
			end
		end
		if (targetname ~= "Auto-Hammer") then
			--print (targetname);
			if (VendomaticOptions.autosell == 1) then
				Vendomatic_AutoSell();
			end
			if (VendomaticOptions.autorestock == 1) then
				Vendomatic_AutoRestock();
			end
		end
	end
end

function VendomaticButton_OnEnter(frame)
	GameTooltip:SetOwner(VendomaticButtonFrame, "ANCHOR_TOPRIGHT", 120, 4);
	GameTooltip:SetText("Vendomatic");
	GameTooltip:AddLine("Double-click: Show/hide options frame\nLeft-click: Drag this icon\nRight-click: Show durability info", 1, 1, 1);
	GameTooltip:Show();
end 

function Vendomatic_GreenSellHelp(frame)
	GameTooltip:SetOwner(Vendomatic_OptionsSellFrame_SellGreen, "ANCHOR_CURSOR");
	GameTooltip:SetText("Vendomatic");
	GameTooltip:AddLine("Automatic selling of |cff00ff00green|r EQUIPPABLE items in bags\nUse the exceptions list to prevent specific items from being sold", 1, 1, 1);
	GameTooltip:Show();
end

--Need to cleanup - WTF was I thinking with such a messy function?
function Vendomatic_AutoRepair()
	local repaircost = GetRepairAllCost();
	local withdrawLimit = GetGuildBankWithdrawMoney();
	if (repaircost == 0) then
		print("|cffffd200Vend-o-matic|r: No repair needed");
		end
	if (repaircost > 0) then
		if (VendomaticOptions.repairtype == 1) then
			if CanGuildBankRepair() and (VendomaticOptions.guildbankrepair == 1) and (repaircost <= withdrawLimit) then
				if IsGuildLeader() then
					if (VendomaticOptions.gmbankrepair == 1) then
						RepairAllItems(1);
						print("|cffffd200Vend-o-matic|r: Repaired All Items with Guild Bank: " .. GetCoinTextureString(repaircost));
					else
						RepairAllItems();
						print("|cffffd200Vend-o-matic|r: Repaired All Items: " .. GetCoinTextureString(repaircost));
					end
				else
					RepairAllItems(1);
					print("|cffffd200Vend-o-matic|r: Repaired All Items with Guild Bank: " .. GetCoinTextureString(repaircost));
				end
			else
				RepairAllItems();
				print("|cffffd200Vend-o-matic|r: Repaired All Items: " .. GetCoinTextureString(repaircost));
			end
		elseif (VendomaticOptions.repairtype == 2) then
			Vendomatic_RepairConfirmationTextGold:SetText(GetCoinTextureString(repaircost));
			Vendomatic_RepairConfirmation:Show();
		elseif (VendomaticOptions.repairtype == 3) then
			local repairdivide = (repaircost / GetMoney()) * 100;
			if repairdivide > VendomaticOptions.repairthreshold then
				Vendomatic_RepairConfirmationTextGold:SetText(GetCoinTextureString(repaircost));
				Vendomatic_RepairConfirmation:Show();
			else
				if CanGuildBankRepair() and (VendomaticOptions.guildbankrepair == 1) and (repaircost <= withdrawLimit) then
					if IsGuildLeader() then
						if (VendomaticOptions.gmbankrepair == 1) then
							RepairAllItems(1);
							print("|cffffd200Vend-o-matic|r: Repaired All Items with Guild Bank: " .. GetCoinTextureString(repaircost));
						else
							RepairAllItems();
							print("|cffffd200Vend-o-matic|r: Repaired All Items: " .. GetCoinTextureString(repaircost));
						end
					end
				else
					RepairAllItems();
					print("|cffffd200Vend-o-matic|r: Repaired All Items: " .. GetCoinTextureString(repaircost));
				end
			end
		end
		
	end
end

function VendoMatic_FrameDragSell()
	local typeinfo, datainfo, secondaryinfo = GetCursorInfo();
	-- Item out of the bag:
	if (typeinfo == "item") then
		local _,_,_,_,_,_,_,_,_,itemtexture = GetItemInfo(datainfo);
		local itemname = GetItemInfo(datainfo);
		local frametexture = getglobal("Vendomatic_OptionsSellFrame_DropBoxIconTexture");
		local framename = getglobal("Vendomatic_OptionsSellFrame_DropBoxText");
		frametexture:SetTexture(itemtexture);
		framename:SetWidth(180);
		framename:SetJustifyH("LEFT");
		framename:SetText(itemname);
		ClearCursor();
	-- Item from merchant window
	elseif (typeinfo == "merchant") then
		local _,itemtexture = GetMerchantItemInfo(datainfo);
		local itemname = GetMerchantItemInfo(datainfo);
		local frametexture = getglobal("Vendomatic_OptionsSellFrame_DropBoxIconTexture");
		local framename = getglobal("Vendomatic_OptionsSellFrame_DropBoxText");
		frametexture:SetTexture(itemtexture);
		framename:SetWidth(180);
		framename:SetJustifyH("LEFT");
		framename:SetText(itemname);
		ClearCursor();
	else
		print("|cffffd200Vend-o-matic|r: Invalid Item");
		ClearCursor();
	end
end

function VendoMatic_FrameDragStock()
	local typeinfo, datainfo, secondaryinfo = GetCursorInfo();
	-- Item out of the bag:
	if (typeinfo == "item") then
		local _,_,_,_,_,_,_,_,_,itemtexture = GetItemInfo(datainfo);
		local itemname = GetItemInfo(datainfo);
		local frametexture = getglobal("Vendomatic_OptionsStockFrame_DropBoxIconTexture");
		local framename = getglobal("Vendomatic_OptionsStockFrame_DropBoxText");
		frametexture:SetTexture(itemtexture);
		framename:SetWidth(180);
		framename:SetJustifyH("LEFT");
		framename:SetText(itemname);
		ClearCursor();
	-- Item from merchant window
	elseif (typeinfo == "merchant") then
		local _,itemtexture = GetMerchantItemInfo(datainfo);
		local itemname = GetMerchantItemInfo(datainfo);
		local frametexture = getglobal("Vendomatic_OptionsStockFrame_DropBoxIconTexture");
		local framename = getglobal("Vendomatic_OptionsStockFrame_DropBoxText");
		frametexture:SetTexture(itemtexture);
		framename:SetWidth(180);
		framename:SetJustifyH("LEFT");
		framename:SetText(itemname);
		ClearCursor();
	else
		print("|cffffd200Vend-o-matic|r: Invalid Item");
		ClearCursor();
	end
end

function Vendomatic_AutoSell()
	local grey_counter = 0;
	local grey_sellprice = 0;
	local grey_totalsale = 0;
	local grey_stackcount = 1;
	local green_sellprice = 0;
	local green_totalsale = 0;
	local green_counter = 0;
	local grey_individual_price = 0;
	for i=0, 4 do
		local MaxSlots = GetContainerNumSlots(i);		
		for n=0, MaxSlots do
			local itemid = GetContainerItemID(i,n);
			if (itemid) then
				local itemname,_,quality = GetItemInfo(itemid);
				if ((itemname ~= nil) and (quality == 0)) then
					--local itemname = GetItemInfo(itemid);
					if VendomaticOptions["listtype"] == 0 then
						if not Vendomatic_CheckExceptions(itemname) then
							_,grey_stackcount = GetContainerItemInfo(i,n);
							_,_,_,_,_,_,_,_,_,_,grey_individual_price = GetItemInfo(itemid);
							grey_sellprice = grey_individual_price * grey_stackcount;
							ShowContainerSellCursor(i,n);
							UseContainerItem(i,n);
							grey_counter = grey_counter + grey_stackcount;
							grey_totalsale = grey_totalsale + grey_sellprice;
						end
					else
						if Vendomatic_CheckExceptions(itemname) then
							_,grey_stackcount = GetContainerItemInfo(i,n);
							_,_,_,_,_,_,_,_,_,_,grey_individual_price = GetItemInfo(itemid);
							grey_sellprice = grey_individual_price * grey_stackcount;
							ShowContainerSellCursor(i,n);
							UseContainerItem(i,n);
							grey_counter = grey_counter + grey_stackcount;
							grey_totalsale = grey_totalsale + grey_sellprice;
						end
					end
				end
				if (VendomaticOptions.sellgreens == 1) then
					if ((itemname ~= nil) and (quality == 2) and IsEquippableItem(itemid)) then
						local itemname = GetItemInfo(itemid);
						if VendomaticOptions["listtype"] == 0 then
							if not Vendomatic_CheckExceptions(itemname) then
								_,_,_,_,_,_,_,_,_,_,green_sellprice = GetItemInfo(itemid);
								ShowContainerSellCursor(i,n);
								UseContainerItem(i,n);
								green_counter = green_counter + 1;
								green_totalsale = green_totalsale + green_sellprice;
							end
						elseif VendomaticOptions["listtype"] == 1 then
							if Vendomatic_CheckExceptions(itemname) then
								_,_,_,_,_,_,_,_,_,_,green_sellprice = GetItemInfo(itemid);
								ShowContainerSellCursor(i,n);
								UseContainerItem(i,n);
								green_counter = green_counter + 1;
								green_totalsale = green_totalsale + green_sellprice;
							end
						end
					end
				end
			end
		end
	end
	--[[if grey_totalsale == 0 then
		print("|cffffd200Vend-o-matic|r: No |cff808080grey|r items in bags");
	end--]]
	if grey_totalsale > 0 then
		print("|cffffd200Vend-o-matic|r: Sold "..grey_counter.." |cff808080grey|r items for: " .. GetCoinTextureString(grey_totalsale));
	end
	--[[if green_totalsale == 0 then
		print("|cffffd200Vend-o-matic|r: No |cff00ff00green|r items in bags");
	end--]]
	if green_totalsale > 0 then
		print("|cffffd200Vend-o-matic|r: Sold "..green_counter.." |cff00ff00green|r items for: " .. GetCoinTextureString(green_totalsale));
	end
end

function Vendomatic_CheckExceptions(name)
	if VendomaticOptions["exceptions"] then
		for i, v in ipairs(VendomaticOptions["exceptions"]) do
			if v == name then
				return true;
			end
		end
	end
	return false;
end

function Vendomatic_BuildEquipmentSetTable() -- This bit me while leveling in Cataclysm. Curse you, stupid greens! My character should automatically be equipped epics as soon as I level to the cap.
	if GetNumEquipmentSets() > 0 then
		local Vendomatic_EquipmentSetsTable = { };
		for i = 1, GetNumEquipmentSets() do
			local equipment_tablename = GetEquipmentSetInfo(i)
			Vendomatic_EquipmentSetsTable[equipment_tablename] = { };
			print(Vendomatic_EquipmentSetsTable[equipment_tablename]);
		end
	end
end

function Vendomatic_AutoRestock() -- It's not so complex anymore so I can't brag :( On the flipside, Blizzard did clean it up in-game themselves, for that, I am a happy panda.
	for i=1, GetMerchantNumItems() do
		local merchantitem_name = select(1, GetMerchantItemInfo(i));
		if Vendomatic_ReagentCountList(merchantitem_name) then
			local threshold = VendomaticOptions.reagentcount[merchantitem_name];
			local playercount = GetItemCount(merchantitem_name);		
			if playercount < threshold then
				local buyrepeat = 1;
				local remainder = 0;
				local buyamount = threshold - playercount;
				local itemstack = GetMerchantItemMaxStack(i);
				buyrepeat = floor(buyamount / itemstack);
				remainder = mod(buyamount,itemstack);
				for n=1, buyrepeat do
					BuyMerchantItem(i,itemstack);
				end
				if remainder > 0 then
						BuyMerchantItem(i,remainder);
				end
			end
		end	
	end
end

function Vendomatic_FirstRun()
	VendomaticOptions["autorepair"] = 0;
	VendomaticOptions["autosell"] = 0;
	VendomaticOptions["autorestock"] = 0;
	VendomaticOptions["overstock"] = 0;
	VendomaticOptions["repairtype"] = 1;
	VendomaticOptions["hideminimapicon"] = 0;
	VendomaticOptions["guildbankrepair"] = 1;
	VendomaticOptions["repairthreshold"] = 99;
	VendomaticOptions["reagents"] = { };
	VendomaticOptions["reagentcount"] = { };
	VendomaticOptions["exceptions"] = { };
	VendomaticOptions["sellgreens"] = 0;
	VendomaticOptions["listtype"] = 0;
	VendomaticOptions["gmbankrepair"] = 0;
end

function Vendomatic_ReagentCountList(item)
	if VendomaticOptions.reagentcount ~= nil then
		if VendomaticOptions.reagentcount[item] then
			return true;
		else
			return false;
		end
	end
end

function ExceptionDelete(name)
	for i,v in ipairs(VendomaticOptions.exceptions) do
		if v == name then
			tremove(VendomaticOptions.exceptions, i);
		end
	end
end

function ReagentDelete(name)
	for i,v in ipairs(VendomaticOptions.reagents) do
		if v == name then
			tremove(VendomaticOptions.reagents, i);
			VendomaticOptions.reagentcount[name] = nil;
		end
	end
end

function Vendomatic_SellFrameUpdate(index)
	Vendomatic_sellstart = 1;
	if index ~= nil then
		Vendomatic_sellstart = index;	
	end
	local counter = 1;
	local Vendomatic_sellend = Vendomatic_sellstart + 4;
	for i=Vendomatic_sellstart, Vendomatic_sellend do
		local button = getglobal("SellItemButton"..counter);
		local buttontext = VendomaticOptions.exceptions[i];
		button:SetText(buttontext);
		button:Show();
		counter = counter + 1;
	end
	for n=1, 5 do
		local button = getglobal("SellItemButton"..n);
		local gettext = button:GetText();
		if gettext == nil then
			button:Hide();
		end
	end
end

function Vendomatic_StockFrameUpdate(index)
	Vendomatic_stockstart = 1;
	if index ~= nil then
		Vendomatic_stockstart = index;	
	end
	local counter = 1;
	local Vendomatic_stockend = Vendomatic_stockstart + 4;
	for i=Vendomatic_stockstart, Vendomatic_stockend do
		local button = getglobal("StockItemButton"..counter);
		local buttontext = VendomaticOptions.reagents[i];
		button:SetText(buttontext);
		button:Show();
		counter = counter + 1;
	end
	for n=1, 5 do
		local button = getglobal("StockItemButton"..n);
		local gettext = button:GetText();
		if gettext == nil then
			button:Hide();
		end
	end
end

function Vendomatic_HighlightFrame(name)
	VendomaticHighlightFrame:SetPoint("TOPLEFT", name, "TOPLEFT", -5, -3);
	VendomaticHighlightFrame:Show();
end

function Vendomatic_Getsellrows()
	Vendomatic_Exceptions_MaxRows = 0;
	for i,v in ipairs(VendomaticOptions.exceptions) do
		Vendomatic_Exceptions_MaxRows = Vendomatic_Exceptions_MaxRows + 1;
	end
	return Vendomatic_Exceptions_MaxRows - 4;
end

function Vendomatic_Getstockrows()
	Vendomatic_Reagents_MaxRows = 0;
	for i,v in ipairs(VendomaticOptions.reagents) do
		Vendomatic_Reagents_MaxRows = Vendomatic_Reagents_MaxRows + 1;
	end
	return Vendomatic_Reagents_MaxRows - 4;
end

function Vendomatic_SellFrameMoveDown()
	local maxrows = Vendomatic_Getsellrows();
	if ((sellframestartindex < maxrows) and (maxrows > 0)) then
		sellframestartindex = sellframestartindex + 1;
		Vendomatic_SellFrameUpdate(sellframestartindex);
	end
end

function Vendomatic_SellFrameMoveUp()
	if (sellframestartindex > 1) then
		sellframestartindex = sellframestartindex - 1;
		Vendomatic_SellFrameUpdate(sellframestartindex);
	end
end

function Vendomatic_StockFrameMoveDown()
	local maxrows = Vendomatic_Getstockrows();
	if ((stockframestartindex < maxrows) and (maxrows > 0)) then
		stockframestartindex = stockframestartindex + 1;
		Vendomatic_StockFrameUpdate(stockframestartindex);
	end
end

function Vendomatic_StockFrameMoveUp()
	if (stockframestartindex > 1) then
		stockframestartindex = stockframestartindex - 1;
		Vendomatic_StockFrameUpdate(stockframestartindex);
	end
end

function Vendomatic_Durability()
	local mydurability = 0;
	local mymaxdurability = 0;
	local percentdurabilitystring;
	for i=1, 24 do
		itemdurability, itemmaxdurability = GetInventoryItemDurability(i);
		if (itemdurability) and (itemmaxdurability) then
			mydurability = mydurability + itemdurability;
			mymaxdurability = mymaxdurability + itemmaxdurability;
		end
	end
	local percentdurability = floor((100 * (mydurability / mymaxdurability)));
	if percentdurability >= 66 then
		percentdurabilitystring = "|cff00ff00" .. percentdurability .. "% Durability Remaining|r";
	elseif percentdurability < 66 and percentdurability > 33 then
		percentdurabilitystring = "|cffffff00" .. percentdurability .. "% Durability Remaining|r";
	elseif percentdurability <= 33 then
		percentdurabilitystring = "|cffff0000" .. percentdurability .. "% Durability Remaining|r";
	end
	print("|cffffd200Vend-o-matic|r: " .. percentdurabilitystring);
end
	