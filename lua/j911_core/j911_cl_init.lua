-- Includes
include( "j911_core/j911_config.lua" )
AddCSLuaFile("j911_core/imgui.lua")
include( "j911_core/imgui.lua" )

-- Tables
local Calls = {}

-- Fonts
surface.CreateFont( "J911Font1", {
	font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 50,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
} )


local function ChatHandler( color1, chat1, color2, chat2 ) 
    chat:AddText( color1, chat1, color2, chat2 )

end

local function BlipHandler(v)
    hook.Add( "PostDrawTranslucentRenderables", "J911DRAW", function( bDepth, bSkybox )

        cam.IgnoreZ(true)
        -- If we are drawing in the skybox, bail
        if ( bSkybox ) then return end
        
        -- Set the draw material to solid white
        render.SetColorMaterial()
        
        local pos = v.Player:GetPos()
        
        -- Draw the sphere!
        render.DrawSphere( pos, 500, 30, 30, Color( 0, 0, 0, 100) )
        
    end)
    hook.Add("PostDrawOpaqueRenderables", "J911DRAW2", function()
        -- Get the game's camera angles
        local angle = EyeAngles()
    
        -- Only use the Yaw component of the angle
        angle = Angle( 0, angle.y, 0 )
    
        -- Apply some animation to the angle
        angle.y = angle.y + math.sin( CurTime() ) * 10
    
        -- Correct the angle so it points at the camera
        -- This is usually done by trial and error using Up(), Right() and Forward() axes
        angle:RotateAroundAxis( angle:Up(), -90 )
        angle:RotateAroundAxis( angle:Forward(), 90 )
    
        -- A trace just for a position
        local pos = v.Player:GetPos()

    
        -- Raise the hitpos off the ground by 20 units and apply some animation
        pos = pos + Vector( 0, 0, math.cos( CurTime() / 2 ) + 20 )
    
        -- Notice the scale is small, so text looks crispier
        cam.Start3D2D( pos, angle, 5 )
            cam.IgnoreZ(true)
            -- Get the size of the text we are about to draw
            local text = "Testing"
            surface.SetFont( "Default" )
            local tW, tH = surface.GetTextSize( "911 Caller" )
    
            -- This defines amount of padding for the box around the text
            local pad = 5
    
            -- Draw a rectable. This has to be done before drawing the text, to prevent overlapping
            -- Notice how we start drawing in negative coordinates
            -- This is to make sure the 3d2d display rotates around our position by its center, not left corner
            surface.SetDrawColor( 0, 0, 0, 255 )
    
            -- Draw some text
            draw.SimpleText( "911 Caller", "Default", -tW / 2, 0, color_white )
        cam.End3D2D()
    end)
end


local function TicketPopup( Report )

    // Is Valid Check
    if IsValid(Menu) then return end

    // Frame Code
    local Menu = vgui.Create( "DFrame" )
    Menu:SetPos(ScrW()-500-10, 10)
    Menu:SetSize( 500*ScrW()/1920, 125*ScrH()/1080 )
    Menu:SetTitle( j911config.CallPanelName ) 
    Menu:SetVisible( true ) 
    Menu:SetDraggable( false ) 
    Menu:ShowCloseButton( false ) 
    Menu.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
        draw.RoundedBox( 4, 0, 0, w, h, Color( 49, 49, 49) ) -- Draw a red box instead of the frame
    end

    // Label
    local R12 = vgui.Create( "DLabel", Menu )
    R12:SetText("Call Creator  : " .. Report.Player:Nick())
    R12:Dock(TOP)
    R12:DockMargin(4*ScrW()/1920, 4*ScrH()/1080, 4*ScrW()/1920, 0)
    local R1 = vgui.Create( "DLabel", Menu )
    local pos = Report.Player:GetPos()
    local post = util.TypeToString(post)
    R1:SetText("Creator Health : " .. Report.Player:Health())
    R1:Dock(TOP)
    R1:DockMargin(4*ScrW()/1920, 4*ScrH()/1080, 4*ScrW()/1920, 0)

    local Close = vgui.Create( "DButton", Menu )
    Close:SetText("End Call")
    Close:Dock(TOP)
    Close:DockMargin(4*ScrW()/1920, 4*ScrH()/1080, 4*ScrW()/1920, 0)
    Close:SetIcon("icon16/cross.png")
    Close:SetTextColor(Color(255,255,255,255))
    Close.DoClick = function()
        Menu:Remove()
        hook.Remove("PostDrawTranslucentRenderables", "J911DRAW")
        hook.Remove("PostDrawOpaqueRenderables", "J911DRAW2")
        cam.IgnoreZ(false)
    end
    Close.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
        draw.RoundedBox( 1, 0, 0, w, h, Color( 41, 41, 41) ) -- Draw a red box instead of the frame
    end
end

local function CopPanel()
    -- Is Valid Check
    if IsValid(Menu) then return end

    -- Anim Locals
    local scrw, scrh = ScrW(), ScrH()
    local frameW, frameH, animTime, animDelay, animEase = scrw * .5, scrh * .5, 1, 0, -1

    -- Cop Frame
    local menu = vgui.Create( "DFrame" )
    menu:SetTitle( j911config.PanelName )
    menu:SetVisible( true )
    menu:SetDraggable( true )
    menu:ShowCloseButton( true )
    menu:MakePopup()
    local isAnimating = true -- Animation Stuff
    menu:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
        isAnimating = true
    end)
    menu.Paint = function( self, w, h ) --Paint our frame grey!
        draw.RoundedBox( 0, 0, 0, w, h, Color( 49, 49, 49 ) )
    end

    -- Panel with our calls!
    callPanel = vgui.Create( "DPanel", menu )
    callPanel:Dock(FILL)
    callPanel:DockMargin( 10*ScrW()/1920, 5*ScrH()/1080, 10*ScrW()/1920, 10*ScrH()/1080 )
    callPanel:SetSize( 900*ScrW()/1920, 475*ScrH()/1080 )
    callPanel.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
        draw.RoundedBox( 10, 0, 0, w, h, Color( 41, 41, 41) ) -- Draw a red box instead of the frame
    end
    for k, v in ipairs( Calls ) do -- LOOP OUR CALLS
        local name = vgui.Create("DLabel", callPanel )
        name:Dock(TOP)
        name:DockMargin(4*ScrW()/1920, 4*ScrH()/1080, 4*ScrW()/1920, 0)
        name:SetText(v.Player:Nick())
        -- Description of call!
        local title = vgui.Create("DLabel", callPanel )
        title:Dock(TOP)
        title:DockMargin(4*ScrW()/1920, 4*ScrH()/1080, 4*ScrW()/1920, 0)
        title:SetText(v.CallDescription)

        -- Claim Our Call Button!
        local button = vgui.Create( "DButton", callPanel )
        button:Dock(TOP)
        button:DockMargin(4*ScrW()/1920, 4*ScrH()/1080, 4*ScrW()/1920, 0)
        button:SetText("Claim Call")
        button:SetTextColor(Color(255,255,255,255))
        button:SetIcon("icon16/accept.png")
        button.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
            draw.RoundedBox( 10, 0, 0, w, h, Color( 49, 49, 49) ) -- Draw a red box instead of the frame
        end
        button.DoClick = function()
            net.Start("J911RemoveCall")
            net.WriteUInt(k, 10)
            net.SendToServer()

            menu:Remove()

            BlipHandler(v)
            TicketPopup(v)

            v.Player:PrintMessage(HUD_PRINTTALK, "Your 911 report was claimed! They should be arriving shortly!")
        end
    end

    
    -- Center Menu
    // Animation
    menu.OnSizeChanged = function(me,w,h)
        if isAnimating then
            me:Center()
        end
    end
end
-- Networking
net.Receive( "J911Sync", function()
    Calls = net.ReadTable()
end )
net.Receive( "JOpen911", function()
    CopPanel()
    
end )
net.Receive( "J911SendChat", function()
    local string = net.ReadString()
    ChatHandler( Color( 252, 252, 3 ), "[Justice 911]", Color( 255,255,255 ), " Your call - " .. string .. " : Has been sent!")
end )