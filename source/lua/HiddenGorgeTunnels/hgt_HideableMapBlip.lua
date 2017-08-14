---------------------------------------
-- hgt_HideableMapBlip.lua
--
-- This class allows the MapBlip to be hidden for a given circumstance.
-- In this case, it will be used by TunnelEntrance entities.
--
-- By default, the HideableMapBlip is always seen by its owner but this can be toggled
-- with alwaysVisibleToOwner.
--
-- Currently, the MapBlips hidden status is overriden if the other team
-- has the owning object in sight i.e.  due to an Observation Scan.
---------------------------------------
class 'HideableMapBlip' (MapBlip)

HideableMapBlip.kMapName = "HideableMapBlip"

local hideableNetworkVarsNetworkVars =
{
    playerEntityId = "entityid",
    hidden = "boolean",  -- Determines if MapBlip is shown on Map
    alwaysVisibleToOwner = "boolean" -- Determines if MapBlip is shown to owner
                                     -- Even if hidden = true

}

function HideableMapBlip:OnCreate()
    MapBlip.OnCreate(self)
    self.hidden = false
    self.alwaysVisibleToOwner = true
    self.playerEntityId = Entity.invalidId
end

if Client then
    function HideableMapBlip:UpdateMinimapActivity(minimap, item)
        local blipTeamNumber = self:GetMapBlipTeam(minimap)
        local sameTeam = blipTeamNumber == minimap.playerTeam or minimap.spectating
        -- If MapBlip is hidden and not sighted by Enemy.
        if self.hidden then
            if  not sameTeam and self:GetIsSighted() then
                return MapBlip.UpdateMinimapActivity(self, minimap, item)
            end

            if self.playerEntityId ~= Entity.invalidId and Client.GetLocalPlayer():GetId() == self.playerEntityId and self.alwaysVisibleToOwner then
                return MapBlip.UpdateMinimapActivity(self, minimap, item)
            else
                return nil
            end
        end
        return MapBlip.UpdateMinimapActivity(self, minimap, item)
    end
end

Shared.LinkClassToMap("HideableMapBlip", HideableMapBlip.kMapName, hideableNetworkVarsNetworkVars)
