
-- hgt_TunnelEntrance.lua
--
-- This overrides the OnCreate and OnUpdate functions of the original
-- TunnelEntrance.lua
-- This implements the new function hook GetMapBlipMapName so it can return
-- the new HideableMapBlip class
--
-- When the Tunnel is Unconnected, it will set its MapBlip to hidden.  When
-- the Tunnel becomes Connected, the MapBlip will become visible.  The
-- MapBLip is always active for the owner of the TunnelEntrance.  Team mates
-- will only be able to see Connected tunnels on the map.
--
-- Enemies will be able to see the MapBlip regardless of connection when
-- the TunnelEntrance is spotted.
local ns2_OnCreate = TunnelEntrance.OnCreate
function TunnelEntrance:OnCreate()
    -- Call original OnCreate
    ns2_OnCreate(self)
    -- Forces at least one update.
    self.mapBlipActive = true
end

-- Overridden Hook Function in MapBlipMixin.
-- Allows us to setup our own MapBlip classes
function TunnelEntrance:GetMapBlipMapName()
    return HideableMapBlip.kMapName
end

if Server then
    local ns2_OnUpdate = TunnelEntrance.OnUpdate
    function TunnelEntrance:OnUpdate(deltaTime)
        -- Call original OnUpdate
        ns2_OnUpdate(self, deltaTime)
        -- We don't want to fetch the MapBlip entity if we do not need to
        -- There is a performance penalty with this so we only do it if
        -- the Connected status has changed.
        if self:GetIsConnected() ~= self.mapBlipActive then
            self.mapBlipActive = self:GetIsConnected()
            if self.mapBlipId then
                -- Fetch MapBlip entity and update its hidden flag
                local mapBlip = Shared.GetEntity(self.mapBlipId)
                mapBlip.hidden = not self:GetIsConnected()
                if Server and self:GetOwner() then
                    mapBlip.playerEntityId = self:GetOwner():GetId()
                end
            end
        end
    end
end
