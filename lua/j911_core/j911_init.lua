AddCSLuaFile("j911_core/imgui.lua")
include( "j911_core/j911_config.lua" )

-- Tables
local Calls = {}
local delay = 60
local ranks = j911config.ranks
local jobArray = {"TEAM_MAYOR", "TEAM_POLICE",}

-- Networking

util.AddNetworkString( "J911SendChat" )
util.AddNetworkString( "J911Sync" )
util.AddNetworkString( "JOpen911" )
util.AddNetworkString( "J911RemoveCall" )

-- Initalize Hooks
local jobID = {}

hook.Add("Initialize", "loadDarkrpJob", function()
  for index, teamStr in ipairs(jobArray) do
    local id = _G[teamStr]

    if id then
        jobID[id] = true
    end
  end
end)

hook.Add("PlayerSay", "MakeCall", function( ply, text )
    if string.StartWith(  text, "!911" ) then
        if (ply.next911) and ( CurTime() <= ply.next911 ) then
            ply:PrintMessage(HUD_PRINTTALK, "[Justice 911] You need to wait before making another 911 call!")
        return end
        -- Locals
        local msg = string.Trim( text, "!911" )
        local fmsg = string.TrimLeft( msg, "!911" )
        if (fmsg == "1") then 
            ply:PrintMessage(HUD_PRINTTALK, "[Justice 911] You need to type a reason for your call!")
        return end
        -- Print Check

        print( fmsg )

        -- Run our net shit
        table.insert( Calls, {
            Player = ply,
            CallDescription = fmsg,
        })
        print("table inserted!")
        print(Calls)

        -- Client Chat Message
        net.Start( "J911SendChat" )
        net.WriteString( fmsg )
        net.Send( ply )
        print("net message started!")

        -- Add delay
        ply.next911 = CurTime() + delay
        return ""
    end
end )
hook.Add("PlayerSay", "OpenCopMenu", function( ply, text)
    if jobID[ply:Team()] then
        print("Menu opened cause your a cop!")
        if string.lower( text ) == "!calls911" then
            net.Start( "JOpen911" )
            net.Send( ply )
        end
    elseif ranks[ply:GetUserGroup()] then
        print("911 Menu Opened Cause your staff!")
        if string.lower( text ) == "!calls911" then
            net.Start( "JOpen911" )
            net.Send( ply )
        end
    end
end)

net.Receive( "J911RemoveCall", function(len, ply)
    if jobID[ply:Team()] or ranks[ply:GetUserGroup()] then
        if len >= 100 then return end
        local k = net.ReadUInt( 10 )
        table.remove( Calls, k)
    end
end)

timer.Create( "CallSyncTimer", 5, 0, function()
    for k, v in ipairs( player.GetAll()) do
        if not v:IsAdmin() then continue end
        net.Start( "J911Sync" )
          net.WriteTable( Calls )
        net.Send( v ) 
    end
end )