---
--- Created by Benjamin Foo
--- DateTime: 04.03.2020 23:09
---
--- The GeneratorEntity is the common parent type for constructions which generate some kind of resource.
---
--- For example: TODO :)
---
-- Script.ReloadScript("scripts/Utils/EntityUtils.lua")

GeneratorEntity = {
    Client = {},
    Server = {},
    Properties = {

        --[[
            Physics = {
                bPhysicalize = 1,
                bRigidBody = 0,
                bPushableByPlayers = 0,

                Density = -1,
                Mass = -1,
            },

            MultiplayerOptions = {
                bNetworked = 0,
            },
        ]]

        MaxSpeed = 1,
        fHealth = 100,
        bTurnedOn = 1,
        bExcludeCover = 0,
        bSaved_by_game = 1,
        Saved_by_game = 1,
        bSerialize = 1,
        fUsabilityDistance = 100,

        class = "Bed",
        sSittingTagGlobal = "sittingNoTable",

        Script = {
            esBedTypes = "ground",
            Misc = ""
        },
        Physics = {
            CollisionFiltering = {
                collisionType = { },
                collisionIgnore = {}
            }
        },

        Body = {
            guidClothingPresetId = "0",
            guidBodyPrestId = "0"
        },

        Bed = {
            esSleepQuality = "low",
            esReadingQuality = "bed_ground"
        },

        soclasses_SmartObjectHelpers = "CampBed",
        soclasses_SmartObjectClass = "",

        UseMessage = "",
        sWH_AI_EntityCategory = "Bed",
        bInteractiveCollisionClass = 1,
        object_Model = "objects/buildings/refugee_camp/bad_straw.cgf",
        guidSmartObjectType = "39012413-1895-4828-b202-b3835a78984d",
        esFaction = "",
        MultiplayerOptions = {},

        -- soclasses_SmartObjectClass = "",
        sWH_AI_EntityCategory = "",
        bMissionCritical = 0,
        bCanTriggerAreas = 0,
        DmgFactorWhenCollidingAI = 1,
    },

    Editor = {
        Icon = "physicsobject.bmp",
        IconOnTop = 1,
    },

    Script = {
    }
}

local Physics_DX9MP_Simple = {
    bPhysicalize = 1,
    bPushableByPlayers = 0,

    Density = 0,
    Mass = 0,

}
function GeneratorEntity:OnSpawn()
    if (self.Properties.MultiplayerOptions.bNetworked == 0) then
        self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
    end

    self.bRigidBodyActive = 1;

    self:SetFromProperties();
end
function GeneratorEntity:SetFromProperties()
    local Properties = self.Properties;

    if (Properties.object_Model == "") then
        do
            return
        end ;
    end

    self.freezable = (tonumber(Properties.bFreezable) ~= 0);

    self:SetupModel();
    if (Properties.bAutoGenAIHidePts == 1) then
        self:SetFlags(ENTITY_FLAG_AI_HIDEABLE, 0);
    else
        self:SetFlags(ENTITY_FLAG_AI_HIDEABLE, 2);
    end

    if (self.Properties.bCanTriggerAreas == 1) then
        self:SetFlags(ENTITY_FLAG_TRIGGER_AREAS, 0);
    else
        self:SetFlags(ENTITY_FLAG_TRIGGER_AREAS, 2);
    end
end
function GeneratorEntity:SetupModel()

    local Properties = self.Properties;

    System.LogAlways("SetupModel")
    System.LogAlways("self.Properties.object_model: " .. Properties.object_Model)
    -- System.LogAlways("self.Properties.object_model: " .. Properties.object_Model)

    self:LoadObject(0, Properties.object_Model);

    self:PhysicalizeThis();

    -- disable near fade-out by default
    self:SetViewDistUnlimited()
end

function GeneratorEntity:OnLoad(table)
    self.health = table.health;
    self.dead = table.dead;
    self.object_Model = table.object_Model;

    local Properties = self.Properties;
    Properties.object_Model = table.object_Model;

    System.LogAlways("Loading")
    System.LogAlways("Persisted_Entity.object_model: " .. table.object_Model)

    -- load the persisted model path from the save file
    self:LoadObject(0, table.object_Model)

    -- initialize the physical parameter of this entity (like size, shape, etc)
    self:PhysicalizeThis()

    -- disable near fade-out by default
    self:SetViewDistUnlimited()

end

function GeneratorEntity:OnSave(table)
    table.health = self.health;
    table.dead = self.dead;
    table.object_Model = self.Properties.object_Model;

    System.LogAlways("Saving")
    System.LogAlways("Persisting Entity.object_model: " .. table.object_Model)

end
function GeneratorEntity:IsRigidBody()
    local Properties = self.Properties;
    local Mass = Properties.Mass;
    local Density = Properties.Density;
    if (Mass == 0 or Density == 0 or Properties.bPhysicalize ~= 1) then
        return false;
    end
    return true;
end
function GeneratorEntity:PhysicalizeThis()
    local Physics = self.Properties.Physics;
    if (CryAction.IsImmersivenessEnabled() == 0) then
        Physics = Physics_DX9MP_Simple;
    end
    EntityCommon.PhysicalizeRigid(self, 0, Physics, self.bRigidBodyActive);
end
function GeneratorEntity:OnPropertyChange()
    if (self.__usable) then
        if (self.__origUsable ~= self.Properties.bUsable or self.__origPickable ~= self.Properties.bPickable) then
            self.__usable = nil;
        end
    end
    self:SetFromProperties();
end
function GeneratorEntity:OnReset()
    System.LogAlways("OnReset entity ...")

    self:ResetOnUsed();
    self:DrawSlot(0, 1);

    local PhysProps = self.Properties.Physics;
    if (PhysProps.bPhysicalize == 1) then
        self:PhysicalizeThis();
        self:AwakePhysics(0);
    end
end
function GeneratorEntity:Event_Remove()
    System.LogAlways("Removing entity ...")

    self:DrawSlot(0, 0);
    self:DestroyPhysics();
    self:ActivateOutput("Remove", true);
end
function GeneratorEntity:Event_Hide()
    System.LogAlways("Hiding entity ...")
    self:Hide(1);
    self:ActivateOutput("Hide", true);
    if CurrentCinematicName then
        Log("%.3f %s %s : Event_Hide", _time, CurrentCinematicName, self:GetName());
    end
end
function GeneratorEntity:Event_UnHide()
    System.LogAlways("Unhiding entity ...")
    self:Hide(0);
    self:ActivateOutput("UnHide", true);
    if CurrentCinematicName then
        Log("%.3f %s %s : Event_UnHide", _time, CurrentCinematicName, self:GetName());
    end
end
function GeneratorEntity:Event_Ragdollize()
    self:RagDollize(0);
    self:ActivateOutput("Ragdollized", true);
    if (self.Event_RagdollizeDerived) then
        self:Event_RagdollizeDerived();
    end
end
function GeneratorEntity.Client:OnPhysicsBreak(vPos, nPartId, nOtherPartId)
    self:ActivateOutput("Break", nPartId + 1);
end

function GeneratorEntity:IsUsable(user)
    local ret = nil
    if not self.__usable then
        self.__usable = self.Properties.bUsable
    end

    local mp = System.IsMultiplayer();
    if (mp and mp ~= 0) then
        return 0;
    end

    if (self.__usable == 1) then
        ret = 2
    else
        local PhysProps = self.Properties.Physics;
        if (self:IsRigidBody() == true and user and user.CanGrabObject) then
            ret = user:CanGrabObject(self)
        end
    end

    return ret or 0
end

function GeneratorEntity:IsUsableByPlayer(user)

    local myDirection = g_Vectors.temp_v1;
    local vecToPlayer = g_Vectors.temp_v2;
    local myPos = g_Vectors.temp_v3;

    myDirection = self:GetDirectionVector(0);

    user:GetWorldPos(vecToPlayer);
    self:GetWorldPos(myPos);

    FastDifferenceVectors(vecToPlayer, myPos, vecToPlayer);
    local len = LengthVector(vecToPlayer);

    if (len <= self.Properties.fUsabilityDistance) then
        return true;
    end
    return false;
end

function GeneratorEntity:GetActions(user, firstFast)
    output = {}
    local sleepPrompt = EntityModule.WillSleepingOnThisBedSave(self.id) and "@ui_hud_sleep_and_save" or "@ui_hud_sleep";
    if (self:IsUsableByPlayer(user)) then
        if (self.Properties.Script.esBedTypes == 'normal' or self.Properties.Script.esBedTypes == 'bench') then
            AddInteractorAction(output, firstFast, Action():hint("@ui_hud_sit"):action("use_bed"):func(Bed.OnUsed):interaction(inr_bedSit):enabled(not self.usedByNPC))
            if Variables.GetGlobal('bed_disable_direct_sleep') == 0 then
                AddInteractorAction(output, firstFast, Action():hint(sleepPrompt):action("use_bed"):hintType(AHT_HOLD):func(Bed.OnUsedHold):interaction(inr_bedSit):enabled(not self.usedByNPC))
            end
        else
            AddInteractorAction(output, firstFast, Action():hint(sleepPrompt):action("use_bed"):func(Bed.OnUsed):interaction(inr_bedSleep):enabled(not self.usedByNPC))
        end
    end
    return output
end

function GeneratorEntity:OnUsed(user)
    if (self.Properties.Script.esBedTypes == 'normal' or self.Properties.Script.esBedTypes == 'bench' or (user.player and user.player.CanSleepAndReportProblem())) then
        XGenAIModule.SendMessageToEntity(player.this.id, "player:request", "target(" .. Framework.WUIDToMsg(XGenAIModule.GetMyWUID(self)) .. "), mode ('use')")
    end
end

function GeneratorEntity:OnUsedHold(user)
    if (user.player and user.player.CanSleepAndReportProblem()) then
        XGenAIModule.SendMessageToEntity(player.this.id, "player:request", "target(" .. Framework.WUIDToMsg(XGenAIModule.GetMyWUID(self)) .. "), mode ('use'), behavior('player_use_sleep')")
    end
end

function GeneratorEntity:GetReadingQuality()

    local str = self.Properties.Bed.esReadingQuality;

    if str == "none" then
        return 0;
    elseif str == "bed_ground" then
        return 1;
    elseif str == "bed" then
        return 3;
    elseif str == "bed_exceptional" then
        return 4;
    elseif str == "bench_table" then
        return 5;
    elseif str == "bench_notable" then
        return 6;
    else
        return 0;
    end
end

function GeneratorEntity:GetSleepQuality()

    local str = self.Properties.Bed.esSleepQuality;

    if str == "low" then
        return 2;
    elseif str == "medium" then
        return 3;
    elseif str == "high" then
        return 1;
    elseif str == "exceptional" then
        return 0;
    else
        return 2;
    end
end

GeneratorEntity.FlowEvents = {
    Inputs = {
        Used = { GeneratorEntity.Event_Used, "bool" },
        EnableUsable = { GeneratorEntity.Event_EnableUsable, "bool" },
        DisableUsable = { GeneratorEntity.Event_DisableUsable, "bool" },

        Hide = { GeneratorEntity.Event_Hide, "bool" },
        UnHide = { GeneratorEntity.Event_UnHide, "bool" },
        Remove = { GeneratorEntity.Event_Remove, "bool" },
        Ragdollize = { GeneratorEntity.Event_Ragdollize, "bool" },
    },
    Outputs = {
        Used = "bool",
        EnableUsable = "bool",
        DisableUsable = "bool",
        Activate = "bool",
        Hide = "bool",
        UnHide = "bool",
        Remove = "bool",
        Ragdollized = "bool",
        Break = "int",
    },
}

MakeUsable(GeneratorEntity);
MakePickable(GeneratorEntity);
AddHeavyObjectProperty(GeneratorEntity);
AddInteractLargeObjectProperty(GeneratorEntity);
SetupCollisionFiltering(GeneratorEntity);




--[[
function Bed:GetReadingQuality()

   local str = self.Properties.Bed.esReadingQuality;

   if str=="none" then
       return 0;
   elseif str=="bed_ground" then
       return 1;
   elseif str=="bed" then
       return 3;
   elseif str=="bed_exceptional" then
       return 4;
   elseif str=="bench_table" then
       return 5;
   elseif str=="bench_notable" then
       return 6;
   else
       return 0;
   end
end
function Bed.Client:OnInit()
   self:SetFlags(ENTITY_FLAG_CLIENT_ONLY,0);
end

function Bed.Server:OnInit()
   self:SetFlags(ENTITY_FLAG_CLIENT_ONLY,0);
end
function Bed.Client:OnPhysicsBreak( vPos,nPartId,nOtherPartId )
   self:ActivateOutput("Break",nPartId+1 );
end
function Bed:Event_Remove()
   self:DrawSlot(0,0);
   self:DestroyPhysics();
   self:ActivateOutput( "Remove", true );
end
function Bed:Event_Hide()
   self:Hide(1);
   self:ActivateOutput( "Hide", true );
end
function Bed:Event_UnHide()
   self:Hide(0);
   self:ActivateOutput( "UnHide", true );
end

function Bed:OnLoad(table)
   self.health = table.health;
   self.dead = table.dead;
   if(table.bAnimateOffScreenShadow) then
       self.bAnimateOffScreenShadow = table.bAnimateOffScreenShadow;
   else
       self.bAnimateOffScreenShadow = false;
   end
   self.usedByNPC = nil
end

function Bed:OnSave(table)
   table.health = self.health;
   table.dead = self.dead;
   if(self.bAnimateOffScreenShadow) then
       table.bAnimateOffScreenShadow = self.bAnimateOffScreenShadow;
   else
       table.bAnimateOffScreenShadow = false;
   end
end

function Bed.Client:OnLevelLoaded()
   self:SetInteractiveCollisionType();
end

function Bed:OnEnablePhysics()
   self:SetInteractiveCollisionType();
end
function Bed:OnPropertyChange()
   BasicEntity.OnPropertyChange( self );
   self:SetInteractiveCollisionType();
end
function Bed:MarkUsedByNPC( used )
   self.usedByNPC = used
end


function Bed:IsUsableByPlayer(user)

   local myDirection = g_Vectors.temp_v1;
   local vecToPlayer = g_Vectors.temp_v2;
   local myPos = g_Vectors.temp_v3;

   myDirection = self:GetDirectionVector(0);

   user:GetWorldPos(vecToPlayer);
   self:GetWorldPos(myPos);

   FastDifferenceVectors(vecToPlayer,myPos,vecToPlayer);
   local len = LengthVector(vecToPlayer);

   if(len <= self.Properties.fUsabilityDistance) then
       return true;
   end
   return false;
end

function Bed:GetActions(user,firstFast)
   output = {}
   local sleepPrompt = EntityModule.WillSleepingOnThisBedSave( self.id ) and "@ui_hud_sleep_and_save" or "@ui_hud_sleep";
   if( self:IsUsableByPlayer(user) ) then
       if ( self.Properties.Script.esBedTypes == 'normal' or self.Properties.Script.esBedTypes == 'bench' ) then
           AddInteractorAction( output, firstFast, Action():hint("@ui_hud_sit"):action("use_bed"):func(Bed.OnUsed):interaction(inr_bedSit):enabled(not self.usedByNPC) )
           if Variables.GetGlobal('bed_disable_direct_sleep') == 0 then
               AddInteractorAction( output, firstFast, Action():hint( sleepPrompt ):action("use_bed"):hintType( AHT_HOLD ):func(Bed.OnUsedHold):interaction(inr_bedSit):enabled(not self.usedByNPC) )
           end
       else
           AddInteractorAction( output, firstFast, Action():hint( sleepPrompt ):action("use_bed"):func(Bed.OnUsed):interaction(inr_bedSleep ):enabled(not self.usedByNPC) )
       end
   end
   return output
end

function Bed:OnUsed(user)
   if( self.Properties.Script.esBedTypes == 'normal' or self.Properties.Script.esBedTypes == 'bench' or ( user.player and user.player.CanSleepAndReportProblem() ) ) then
       XGenAIModule.SendMessageToEntity( player.this.id, "player:request", "target("..Framework.WUIDToMsg( XGenAIModule.GetMyWUID(self) ).."), mode ('use')" )
   end
end

function Bed:OnUsedHold(user)
   if( user.player and user.player.CanSleepAndReportProblem() ) then
       XGenAIModule.SendMessageToEntity( player.this.id, "player:request", "target("..Framework.WUIDToMsg( XGenAIModule.GetMyWUID(self) ).."), mode ('use'), behavior('player_use_sleep')" )
   end
end

function Bed:SetInteractiveCollisionType()
   local filtering = {}

   if(self.Properties.bInteractiveCollisionClass == 1) then
       filtering.collisionClass = 262144;
   else
       filtering.collisionClassUNSET = 262144;
   end

   self:SetPhysicParams(PHYSICPARAM_COLLISION_CLASS, filtering );
end

Bed.FlowEvents =
{
   Inputs =
   {
       Hide = { Bed.Event_Hide, "bool" },
       UnHide = { Bed.Event_UnHide, "bool" },
       Remove = { Bed.Event_Remove, "bool" },
   },
   Outputs =
   {
       Hide = "bool",
       UnHide = "bool",
       Remove = "bool",
       Break = "int",
   },
}

MakeDerivedEntityOverride( Bed, BasicEntity )
]] --