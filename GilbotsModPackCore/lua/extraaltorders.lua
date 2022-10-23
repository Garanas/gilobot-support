--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/extraaltorders.lua
--#**
--#**  Author   :  Gilbot-X
--#**
--#**  Summary  :  Allows units to handle more than 6 alt orders.
--#**
--#****************************************************************************

local GilbotUtils = 
    import('/mods/GilbotsModPackCore/lua/utils.lua')

--#*
--#*  Helper functions
--#** 
local function isToggleCap(orderString)
    return string.sub(orderString, 1, 7) == 'RULEUTC' 
end

local function isCommandCap(orderString)
    return string.sub(orderString, 1, 7) == 'RULEUCC' 
end

local function getCapTypeString(orderString)
    if isToggleCap(orderString) 
    then return 'ToggleCap' 
    else return 'CommandCap' 
    end
end


    
    
--#*
--#*  Gilbot-X says:  
--#*   
--#*  This function is called to create the class 
--#*  so this class can add its 
--#*  code to different base classes.
--#**
function MakeExtraAltOrdersUnit(baseClassArg, 
                                canPutOnPageTwoListArg,
                                startingAltOrdersListArg)

local BaseClass = baseClassArg
local resultClass = Class(BaseClass) {

    --# This flag gives us a quick way to test
    --# if a unit is inheriting this abstract class
    IsExtraAltOrdersUnit = true,
    
    CanPutOnPageTwoList = canPutOnPageTwoListArg,
    StartingAltOrdersList = startingAltOrdersListArg,

    
    --# Toggle on/off detailed logging
    DebugOrdersMenuCode = false,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  For debugging only.
    --#** 
    OrdersLog = function(self, messageArg)
        if self.DebugOrdersMenuCode then 
            if type(messageArg) == 'string' then
                LOG('Orders: a=' .. self.ArmyIdString .. ' ' .. messageArg)
            end
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I overrided OnCreate so I could 
    --#*  do variable initialization at this time.
    --#** 
    OnCreate = function(self)
        --# First define necessary instance variables
        --# These tables track what extra buttons are added.
        --# Each ACU normally has 2 free alt-order slots 
        --# when built (correct for FA 1.5.3599).
        --# When we get a third entry in one of these tables
        --# we need to remove a button.
        self.CommandCapsAddedSinceCreation = {}
        self.ToggleCapsAddedSinceCreation = {}
        
        --# Use these to restore original menu after a toggle is reset
        self.CommandCapsToRestoreTable = {}
        self.ToggleCapsToRestoreTable={}

        --# Consisitent for all ACUs, the engineer commands
        --# they use most are least important because 
        --# everyone will know keyboard commands
        --# for capture (C), repair (R), and reclaim (E)
        --# Don't hide overcharge as we need to see that 
        --# to know if it is enabled!!  Last one in list 
        --# is first to be replaced/shunted onto second page.
        if self.IsACU then
            self.CanPutOnPageTwoList = {
                'RULEUCC_Repair',
                'RULEUCC_Capture',
                'RULEUCC_Reclaim',
            }
        end
        
        --# This keeps track of which button we need to 
        --# remove/add next
        self.LastIndexAdded = 0
        self.LastIndexToAdd = table.getsize(self.CanPutOnPageTwoList)
        for kOrderString, vIsToggle in self.StartingAltOrdersList do
            --# Work out which table to add it to and add it
            if vIsToggle then 
                self.ToggleCapsAddedSinceCreation[kOrderString] =    {
                    EnabledForUnit=true,
                    VisibleInMenu=true,
                }
            else 
                self.CommandCapsAddedSinceCreation[kOrderString] = {
                    EnabledForUnit=true,
                    VisibleInMenu=true,
                }
            end
            --# If this is one we remove then note we added it already
            if GilbotUtils.IsValueInTable(self.CanPutOnPageTwoList, kOrderString) then 
                self.LastIndexAdded = self.LastIndexAdded + 1 
            end
        end
      
        --# Debugging only
        self:OrdersLog('Last Index Added=' .. self.LastIndexAdded 
        .. ' out of ' .. self.LastIndexToAdd)
      
        --# This records which set of alt-order buttons 
        --# are being displayed, the first 1-6 or 7-12
        self.ShowingPageOne = true
        if table.getsize(self.StartingAltOrdersList) > 6 then self.HasPage2 = true end
      
        --# Call code from original version after.
        BaseClass.OnCreate(self)
    end,
    
   
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to override this to make sure that ACU doesn't
    --#*  try to have more than 6 alt orders at the same time.
    --#*  These functions will remove AT button if too many other
    --#*  alt orders are added.
    --#*  When a new button is enabled we want to change to the page
    --#*  it is on.  If it is not flagged in the remove list
    --#*  then it must go in page one.
    --#**
    ChangePageIfNecessaryBeforeAdding = function(self, orderStringArg)
        self:OrdersLog('ChangePageIfNecessaryBeforeAdding: called with =' .. orderStringArg) 
        --# If this is one we remove then note we added it already
        local canPutOnPage2 = 
            GilbotUtils.IsValueInTable(self.CanPutOnPageTwoList, orderStringArg) 
        if canPutOnPage2 and self.HasPage2 and self.ShowingPageOne then   
            --# Make sure page 2 is showing
            self:OrdersLog('ChangePageIfNecessaryBeforeAdding: changing to page 2')
            self:ToggleAltOrderMenuPage()
        elseif (not canPutOnPage2) and (not self.ShowingPageOne) then
            --# Make sure page 1 is showing
            self:OrdersLog('ChangePageIfNecessaryBeforeAdding: changing to page 1')
            self:ToggleAltOrderMenuPage()
        end
    end,


    
  
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to override this to make sure that ACU doesn't
    --#*  try to have more than 6 alt orders at the same time.
    --#*  These functions will remove AT button if too many other
    --#*  alt orders are added.
    --#*  When a new button is enabled we want to change to the page
    --#*  it is on.  If it is not flagged in the remove list
    --#*  then it must go in page one.
    --#**
    AddCommandCap = function(self, commandCap, suppressPageChange)
        self:OrdersLog('AddCommandCap: Overrided version called with commandCap=' .. commandCap) 
        self:AddCap(commandCap, suppressPageChange, 'Command')
    end,
    AddToggleCap = function(self, toggleCap, suppressPageChange)
        self:OrdersLog('AddToggleCap: Overrided version called with toggleCap=' .. toggleCap) 
        self:AddCap(toggleCap, suppressPageChange, 'Toggle')
    end,      
    AddCap = function(self, orderString, suppressPageChange, capTypeString)
        self:OrdersLog('AddCap: called with orderString=' .. orderString) 
        if not suppressPageChange then self:ChangePageIfNecessaryBeforeAdding(orderString) end
        self:RemoveButtonFromViewIfNeedTo()
        BaseClass['Add' .. capTypeString .. 'Cap'](self, orderString)
        local orderTable = self[capTypeString .. 'CapsAddedSinceCreation']
        orderTable[orderString]={
            EnabledForUnit=true,
            VisibleInMenu=true,
        }
    end, 

    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to override this to make sure that ACU doesn't
    --#*  try to have more than 6 alt orders at the same time.
    --#*  These functions will remove AT button if too many other
    --#*  alt orders are added.
    --#**          
    RemoveCommandCap = function(self, commandCap)
        self:OrdersLog('RemoveCommandCap: Overrided version called with commandCap=' .. commandCap)
        self:RemoveCap(commandCap, 'Command')
    end,
    RemoveToggleCap = function(self, toggleCap)
        self:OrdersLog('RemoveToggleCap: Overrided version called with toggleCap=' .. toggleCap)
        self:RemoveCap(toggleCap, 'Toggle')
    end,
    RemoveCap = function(self, orderString, capTypeString)
        self:OrdersLog('RemoveCap: called with orderString=' .. orderString)
        --# Caught UEF ACU trying to remove Nuke button that was never enabled 
        --# when removing its tactical missile enhancement.
        local orderTable = self[capTypeString .. 'CapsAddedSinceCreation']
        if not orderTable[orderString] then
            self:OrdersLog('RemoveCommandCap:' 
              ..' Tried to remove button never enabled=' .. orderString)
            return
        end
        --# This can also be tripped by the UEF ACU when it removes an enhancement
        if not orderTable[orderString].EnabledForUnit then
            self:OrdersLog('RemoveCommandCap:' 
              ..' Tried to remove button that was already disabled=' .. orderString)
            return
        end
        --# We are actually removing a button so mark it disabled       
        orderTable[orderString].EnabledForUnit = false
        --# Remove it from menu if it is showing
        if orderTable[orderString].VisibleInMenu then
            BaseClass['Remove' .. capTypeString .. 'Cap'](self, orderString) 
        end
        orderTable[orderString].VisibleInMenu=false
        self:OnButtonRemoved()
    end,

    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Called from RemoveCommandCap and RemoveToggleCap
    --#**          
    OnButtonRemoved = function(self)
        local visibleCount, enabledCount = self:GetAltOrdersCount() 
        if enabledCount < 7 then self.HasPage2 = false end
        if visibleCount==0 and not self.ShowingPageOne then
            self:ToggleAltOrderMenuPage()
        elseif visibleCount==5 then
            self:AddButtonToViewIfCan()
        end
    end,

    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to override this to make sure that ACU doesn't
    --#*  try to have more than 6 alt orders at the same time.
    --#*  These functions will remove AT button if too many other
    --#*  alt orders are added.
    --#**          
    RemoveCommandCapFromViewOnly = function(self, commandCap)
        self:OrdersLog('RemoveCommandCapFromViewOnly: called with commandCap=' .. commandCap) 
        BaseClass.RemoveCommandCap(self, commandCap) 
        self.CommandCapsAddedSinceCreation[commandCap].VisibleInMenu = false
    end,
    RemoveToggleCapFromViewOnly = function(self, toggleCap)
        self:OrdersLog('RemoveToggleCapFromViewOnly: called with toggleCap=' .. toggleCap) 
        BaseClass.RemoveToggleCap(self, toggleCap) 
        self.ToggleCapsAddedSinceCreation[toggleCap].VisibleInMenu = false
    end,
    
    
        
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Return the number of Alt orders currently on display in the interface.
    --#*  It uses our own record of additions/removals rather than querying the interface.
    --#**        
    GetAltOrdersCount= function(self)
        local visibleCount, enabledCount = 0, 0
        for kOrderName, vTable in self.ToggleCapsAddedSinceCreation do
            if vTable.VisibleInMenu then visibleCount=visibleCount+1 end
            if vTable.EnabledForUnit then enabledCount=enabledCount+1 end
        end
        for kOrderName, vTable in self.CommandCapsAddedSinceCreation do
            if vTable.VisibleInMenu then visibleCount=visibleCount+1 end
            if vTable.EnabledForUnit then enabledCount=enabledCount+1 end
        end
        self:OrdersLog('GetAltOrdersCount: visibleCount=' .. visibleCount
          .. ' and enabledCount=' .. enabledCount)
        --self:OrdersLog('GetAltOrdersCount: ' .. repr(self.ToggleCapsAddedSinceCreation))
        --self:OrdersLog('GetAltOrdersCount: ' .. repr(self.CommandCapsAddedSinceCreation))
        return visibleCount, enabledCount
    end,
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Called before adding a new alt command.
    --#** 
    RemoveButtonFromViewIfNeedTo = function(self)
        local visibleCount, enabledCount = self:GetAltOrdersCount() 
        if visibleCount == 6 then
            --# We are going to move a button onto page two
            local indexToRemove = self.LastIndexAdded
            local orderToRemove = self.CanPutOnPageTwoList[indexToRemove]
            if indexToRemove < 1 then
              WARN('RemoveButtonFromViewIfNeedTo: Error: No more buttons to remove.')
            else
              self:OrdersLog('RemoveButtonFromViewIfNeedTo: Removing ' .. repr(orderToRemove))
                self.LastIndexAdded = indexToRemove -1
                local funcName = 'Remove' .. getCapTypeString(orderToRemove) .. 'FromViewOnly'
                self[funcName](self, orderToRemove)
                --# We definitely have a page 2 now if we didn't already
                self.HasPage2 = true
            end
        end
    end,
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Called after removing an alt command.
    --#** 
    AddButtonToViewIfCan = function(self)
        self:OrdersLog('AddButtonToViewIfCan : ' 
        .. ' called when LastIndexAdded=' .. repr(self.LastIndexAdded) 
        .. ' < ' .. repr(self.LastIndexToAdd)
        )
        if self.LastIndexAdded < self.LastIndexToAdd then
            local indexToAdd = self.LastIndexAdded + 1
            local orderToAdd = self.CanPutOnPageTwoList[indexToAdd]
            if indexToAdd > self.LastIndexToAdd then
              WARN('AddButtonToViewIfCan: No more buttons to add.')
            else
              self:OrdersLog('AddButtonToViewIfCan: Adding ' .. repr(orderToAdd))
                self.LastIndexAdded = indexToAdd
                local funcName = 'Add' .. getCapTypeString(orderToAdd)
                self[funcName](self, orderToAdd, true)
            end
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Responds to the SimCallback defined at the end of the file.
    --#*  Toggles display of extra alt-order buttons if there are more than 6.
    --#** 
    ToggleAltOrderMenuPage = function(self)
        if self.ShowingPageOne then
            local visibleCount, enabledCount = self:GetAltOrdersCount() 
            if enabledCount <= 6 then return 
            else
                --# Remove buttons 1-6 except for:
                --# drones (because we can't yet)
                --# and those that get removed when 
                --# there are more than 6.
                self:RemoveButtonsFromFirstSix()
                --# Update toggle state
                self.ShowingPageOne = false
            end
        else
            --# Add buttons 1-6 except drones (we can't yet
            self:RestoreRemovedButtons()
            --# Update toggle state
            self.ShowingPageOne = true
        end
    end,
        
      
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Called by ToggleAltOrderMenuPage to remove some of the buttons 
    --#*  from the first menu so that the ones normally removed
    --#*  when there are more than 6 can now be shown.
    --#** 
    RemoveButtonsFromFirstSix = function(self)
        --# Remove buttons 1-6 from menu (except drones, we can't yet)
        for kOrderName, vStatus in self.ToggleCapsAddedSinceCreation do
            --# If the button is enabled, showing in menu
            if vStatus.EnabledForUnit and vStatus.VisibleInMenu
              --# and not one of the ones that usually 
              --# gets removed from view when 6 or more are added
              and not GilbotUtils.IsValueInTable(self.CanPutOnPageTwoList, kOrderName) 
            then
                --# Make sure its not a UEF drone pod
                if isToggleCap(kOrderName) then
                    --# Remove it from view and replace it with another...
                    self:RemoveToggleCapFromViewOnly(kOrderName)
                    self:AddButtonToViewIfCan()
                    --# ..but keep a reference so we can restore it to view layer
                    table.insert(self.ToggleCapsToRestoreTable, kOrderName)
                end                        
            end
        end
        --# Now do the same for CommandCaps that we did for ToggleCaps
        for kOrderName, vStatus in self.CommandCapsAddedSinceCreation do
            --# If the button is enabled, showing in menu
            if vStatus.EnabledForUnit and vStatus.VisibleInMenu
              --# and not one of the ones that usually 
              --# gets removed from view when 6 or more are added
              and not GilbotUtils.IsValueInTable(self.CanPutOnPageTwoList, kOrderName) 
            then
                --# Make sure its not a UEF drone pod            
                if isCommandCap(kOrderName) then
                    --# Remove it from view ...
                    self:RemoveCommandCapFromViewOnly(kOrderName)
                    self:AddButtonToViewIfCan()
                    --# ..but keep a reference so we can restore it to view layer
                    table.insert(self.CommandCapsToRestoreTable, kOrderName)
                end 
            end
        end
    end,
    
      
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Called by ToggleAltOrderMenuPage to restore all the buttons 
    --#*  from the first menu that it removed.
    --#** 
    RestoreRemovedButtons = function(self)
        --# Add buttons 1-6 (except drones, because we can't yet)
        for kUnusedIndex, vOrderName in self.ToggleCapsToRestoreTable do
            --# The second argument true stops
            --# the menu page changing (when there are two pages) 
            --# to whatever page this button is set to be added to.
            --# This code is called onside the page-changing function,
            --# so we can't risk refering back to ourselves and creating a loop!
            self:AddToggleCap(vOrderName, true)
        end
        --# Now do the same for CommandCaps that we did for ToggleCaps
        for kUnusedIndex, vOrderName in self.CommandCapsToRestoreTable do
            --# The second argument true stops
            --# the menu page changing (when there are two pages) 
            --# to whatever page this button is set to be added to.
            --# This code is called onside the page-changing function,
            --# so we can't risk refering back to ourselves and creating a loop!
            self:AddCommandCap(vOrderName, true)
        end
        self.ToggleCapsToRestoreTable={}
        self.CommandCapsToRestoreTable = {}
    end,
    
}   
    

return resultClass

end



--#*
--#*  Gilbot-X says:  
--#*
--#*  This function gets the unit selected, checks if 
--#*  it is an AutoToggle unit, and if it is, it 
--#*  calls the ACU function to change its priority position 
--#*  in the ordered priority list.
--#**
function ToggleExtraAltOrderButtonsCallback(data)
    --# Try to get an autotoggle unit from the ID passed by UI side.
    local selectedUnit = GetEntityById(data.SelectedUnitEntityId)
   
    --# Only pass on call if this is an autotoggle unit.
    if selectedUnit.IsExtraAltOrdersUnit then
        selectedUnit:ToggleAltOrderMenuPage()
    end
end