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
    hidden = "boolean",  -- Determines if MapBlip is shown on Map
    alwaysVisibleToOwner = "boolean" -- Determines if MapBlip is shown to owner
                                     -- Even if hidden = true
}

function HideableMapBlip:OnCreate()
    MapBlip.OnCreate(self)
    self.hidden = false
    self.alwaysVisibleToOwner = true
    self.localClient = nil
end

if Client then
    function HideableMapBlip:UpdateMinimapActivity(minimap, item)

        local blipTeam = self:GetMapBlipTeam(minimap)
        local blipColor = item.blipColor
        -- For some reason self.clientIndex is not being setup correctly.
        -- Not sure how PlayerMapBlip has its working (but perhaps it is not)
        if not self.localClient then
            self.localClient = Client.GetLocalPlayer():GetClientIndex()
        end
        local sameTeam = self.OnSameMinimapBlipTeam(minimap.playerTeam, blipTeam) or minimap.spectating
        -- If MapBlip is hidden and not sighted by Enemy.
        if self.hidden or (not sameTeam and self:GetIsSighted()) then
            -- If the client is the owner and we don't need to alwaysVisibleToOwner
            -- display to the owner, hide the MapBlip
            local owner = Shared.GetEntity(self:GetOwnerEntityId())
            if self.localClient ~= minimap.clientIndex or not self.alwaysVisibleToOwner then
                return nil
            end
        end
        return MapBlip.UpdateMinimapActivity(self, minimap, item)
    end
end

Shared.LinkClassToMap("HideableMapBlip", HideableMapBlip.kMapName, hideableNetworkVarsNetworkVars)
