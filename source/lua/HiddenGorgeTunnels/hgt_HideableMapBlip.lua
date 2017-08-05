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
    self.alwaysVisibleToOwner = false
end

if Client then
    function HideableMapBlip:UpdateMinimapActivity(minimap, item)
        -- If MapBlip is hidden and not sighted by Enemy.
        if self.hidden and not self:GetIsSighted() then
            -- If the client is the owner and we don't need to alwaysVisibleToOwner
            -- display to the owner, hide the MapBlip
            if self.clientIndex ~= minimap.clientIndex or not self.alwaysVisibleToOwner then
                return nil
            end
        end
        return MapBlip.UpdateMinimapActivity(self, minimap, item)
    end
end

Shared.LinkClassToMap("HideableMapBlip", HideableMapBlip.kMapName, hideableNetworkVarsNetworkVars)
