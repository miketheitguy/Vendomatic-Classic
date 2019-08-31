# Vendomatic

## Description

Vendomatic is a WoW Addon that manages automatic item restocking, automatic repairing, and automatic selling of items whenever you speak to an appropriate vendor.

## Functions

### Auto-Repair

Every time you open a window with an NPC that has the ability to repair, the addon will repair automatically for you. The default variable is set for it to repair regardless of the cost. If you want to be prompted on every repair, or want to set a threshold above which the addon needs to prompt you for repairs, you can do this from the options menu. This will also use the guild bank if you have the option available.

### Auto-Restock

It will keep your stocks of food/water/reagents/whatever up to a set amount. Whenever you visit a vendor that sells the item; Vendomatic will check the amount you already have, and buy the amount you need.

## Limitations

### Green Items

This is an option that can be toggled on and off. The addon will NOT sell any item that is NON equippable. That means it will only sell green armor. It will also not sell any green item that you have equipped on your character. Green items that are in your bags (quest rewards) will be sold. Frost Lotus, Titanium Ore etc will NOT be sold.

### White, Epic, or Blue Items

Automatically sell white, blue or epic items you don't use. We cannot know who will use what so you'll have to sell those yourself.

## Slash Commands

The following slash commands are available for the Vend-o-matic addon:

* Opening config screen: **/vm config**
* Show/hide minimap button: **/vm show**
* Reset all option (cannot be restored) **/vm reset**