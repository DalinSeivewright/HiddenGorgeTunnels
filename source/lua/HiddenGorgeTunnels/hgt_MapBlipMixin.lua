--[[
    hgt_MapBlipMixin.lua
    Overrides the original MapBlipMixin to allow for better control over what
    type of MapBlip is created.

    We override __initmixin that will end up calling a new Function hook
    "GetMapBlipMapName" that, if overriden in any class that uses this Mixin
    will allow to use custom MapBlip.

    if no Hooked function is present, the regular NS2 code is used to determine
    what kMapName to use.

--]]

--[[
    Modified version of original NS2 local function to allow Map Name overriding.
    It accepts a mapName now.
--]]
local function CreateMapBlip(self, mapName, blipType, blipTeam, isInCombat)
    local mapBlip = Server.CreateEntity(mapName)
    if mapBlip then
        mapBlip:SetOwner(self:GetId(), blipType, blipTeam)
        self.mapBlipId = mapBlip:GetId()
    end
end

--[[
   Overriden __initmixin fuction.  We do not call the original function anymore.
   We will check to see if the Hook is implemented.  If so, we call it for
   the custom map name.  If not we use the default Map Name as per original code.
--]]
function MapBlipMixin:__initmixin()
    assert(Server)
    local mapBlipMapName = nil
    -- Check to see if Hook is implemented
    if self.GetMapBlipMapName then
        -- If so, get our custom Map Name
        mapBlipMapName = self:GetMapBlipMapName()
    else
        -- Otherwise, do what the original did.
        mapBlipMapName = self:isa("Player") and PlayerMapBlip.kMapName or MapBlip.kMapName
    end
    -- Check if the new entity should have a map blip to represent it.
    local success, blipType, blipTeam, isInCombat = self:GetMapBlipInfo()
    if success then
        CreateMapBlip(self, mapBlipMapName, blipType, blipTeam, isInCombat)
    end

end
