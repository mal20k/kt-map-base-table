--[[
	Gizmo's Chess Clock/Timer by Gizmo
	https://steamcommunity.com/sharedfiles/filedetails/?id=1541793481

	Keybind Addon by MoonkeyMod
	https://steamcommunity.com/sharedfiles/filedetails/?id=2310083136

	Color patch by Nyss AKA Liyarin
	https://steamcommunity.com/id/Liyarin/myworkshopfiles/?appid=286160
Host/Payed by Cratos
https://steamcommunity.com/id/GodCratos/myworkshopfiles?appid=286160
such Liyarin on Fiverr, he do good work.
]]

-- Liyarin's Vars

pColors = {
	pColor1 = "Blue",
	pColor2 = "Red"
}


-- Original Vars

TimerID  = ""     Colons      = true
holding  = false  holdTime    = 0
holding_1= false hold_1Time  = 0
holding_2= false hold_2Time  = 0

unColoredColor = {105/255,101/255,98/255}
holdColor_1 ="" holdColor_2 ="" holdColor=""
holdPlayer_1="" holdPlayer_2=""

data = {
	start_1  = 0      ,start_2     = 0,
	seconds_1= 0      ,seconds_2   = 0,
	bonus_1  = 0      ,bonus_2     = 0,
	delay_1  = 0      ,delay_2     = 0,
	selDigit = 6      ,delayed     = 0,
	state    = 11     ,storedState = 11,
	ended_1  = true   ,ended_2     = true,
DoTurns  = false  ,color_1="", color_2=""
}

HOLD = 1 RESOLUTION = 0.25
tmpDigits =  {0,0,0,0,0,0,0,0,0,0}
digitNames = {"Hr1_1","Mn1_10","Mn1_01","Sc1_10","Sc1_01","Hr2_1","Mn2_10","Mn2_01","Sc2_10","Sc2_01"}
states = {"increment_1","increment_2","decrement_1","decrement_2","adjustTime","setTime","setBonus","setDelay","doDelay_1","doDelay_2","Paused"}
--            1                2            3            4            5            6          7         8          9           10        11

function onSave()
	self.script_state = JSON.encode({
		data = data,
		colors = pColors
	})
--    return self.script_state
end

function onDestroy()
	onSave()
    Timer.destroy(TimerID)
    TimerID=""
end

function onLoad(json)

	if json~="" and json~=nil then
		local decoded = JSON.decode(json)
		data = decoded.data
		pColors = decoded.colors
	else
		data.seconds_1 = data.start_1 data.seconds_2 = data.start_2
	end

	Wait.condition(function()
		Wait.frames(function()
			changeButtonColors()
		end, 10)
	end, function()
		for _, obj in pairs(getAllObjects()) do
			if not obj.resting then
				return false
			end
		end
		return true
	end)

    DisplayClock(1, data.seconds_1)
    DisplayClock(2, data.seconds_2)
    TimerID = "Gizmo_ChessClock_"..os.time()
    Timer.create({identifier=TimerID, function_name="Tick", delay=RESOLUTION, repetitions=0})
	end


	function Tick()
	    self.call(states[data.state],{})
	    if holding==true then
			if holdColor == "Grey" or (data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black") then
	            return
	        end
	        holdTime = holdTime+RESOLUTION
	    end
	    if holding_1==true then
	        hold_1Time = hold_1Time+RESOLUTION
	    end
	    if holding_2==true then
	        hold_2Time = hold_2Time+RESOLUTION
	    end
	end
	--Allows script buuton to call Gizmo's click functions


function onScriptingButtonDown(index, color)
  	if index == 9 and color == "Blue" then
    	broadcastToAll("Time passed by "..Player[color].steam_name, {0,0,1})
		Click_1(Player[color],1,0)
	elseif index == 9 and color == "Red" then
		broadcastToAll("Use button 7 to pass time")
	end

	if index == 7 and color == "Red" then
		broadcastToAll("Time passed by "..Player[color].steam_name, {1,0,0})
  		Click_2(Player[color],1,0)
	elseif index == 7 and color == "Blue" then
		broadcastToAll("Use button 9 to pass time")
	end

	if index == 8 then
		broadcastToAll("Time Paused", Table)
		Click_C(Player[color],1,0)
	end
end





-- Gizmo's click functions
	function Click_1(player, _, _)
	    if hold_1Time<HOLD then
	        if data.ended_2==true and data.seconds_2==0 then
	            data.storedState=11 data.ended_2=false
	            data.seconds_2 = data.start_2
	        end
	        if player.color == "Grey" or (data.DoTurns == true and data.color_1 ~= player.color and data.color_2 ~= player.color and player.color ~= "Black") then
				holding_1=true
	            hold_1Time=0
	            return
	        end
	        if data.state==11 or data.state==1 or data.state==3 or data.state==9 then
				-- Start Liyarin's Color code
					self.setColorTint(pColors.pColor2)
					Global.UI.setAttribute("ChsStpPanel1", "scale", "0.9 0.9 0.9")
					Global.UI.setAttribute("ChsStpPanel2", "scale", "1.1 1.1 1.1")
				-- End Liyarin's Color code
				Resume()
	            if data.start_2==0 then
	                data.seconds_2 = data.seconds_2-data.bonus_2
	                if data.delay_2==0 then
	                    data.state = 2
	                else
	                    data.delayed = data.delay_2
	                    data.state = 10
	                end
	            else
	                data.seconds_2 = data.seconds_2+data.bonus_2
	                if data.delay_2==0 then
	                    data.state = 4
	                else
	                    data.delayed = data.delay_2
	                    data.state = 10
	                end
	            end
	            SetTurn()
	        elseif data.state==5 or data.state==6 then
	            tmpDigits[data.selDigit] = tmpDigits[data.selDigit]+1
	            if data.selDigit==1 or data.selDigit==3 or data.selDigit==5 or data.selDigit==6 or data.selDigit==8 or data.selDigit==10 then
	                if tmpDigits[data.selDigit] > 9 then
	                    tmpDigits[data.selDigit]=0
	                end
	            else
	                if tmpDigits[data.selDigit] > 5 then
	                    tmpDigits[data.selDigit]=0
	                end
	            end
	            self.UI.show(digitNames[data.selDigit])
	            self.UI.setAttribute(digitNames[data.selDigit] , "image", tmpDigits[data.selDigit])
	        elseif data.state==7 or data.state==8 then
	            tmpDigits[data.selDigit] = tmpDigits[data.selDigit]+1
	            if data.selDigit==5 or data.selDigit==10 then
	                if tmpDigits[data.selDigit] > 9 then
	                    tmpDigits[data.selDigit]=0
	                end
	            else
	                if tmpDigits[data.selDigit] > 5 then
	                    tmpDigits[data.selDigit]=0
	                end
	            end
	            self.UI.show(digitNames[data.selDigit])
	            self.UI.setAttribute(digitNames[data.selDigit] , "image", tmpDigits[data.selDigit])
	        end
	    end
	    holding_1=false
	    hold_1Time=0
	end
	function Click_2(player, _, _)
	    if hold_2Time<HOLD then
	        if data.ended_1==true and data.seconds_1==0 then
	            data.storedState=11 data.ended_1=false
	            data.seconds_1 = data.start_1
	        end
	        if player.color == "Grey" or (data.DoTurns == true and data.color_1 ~= player.color and data.color_2 ~= player.color and player.color ~= "Black") then
	            holding_2=true
	            hold_2Time=0
	            return
	        end
	        if data.state==11 or data.state==2 or data.state==4 or data.state==10 then
				-- Start Liyarin's Color code
					self.setColorTint(pColors.pColor1)
					Global.UI.setAttribute("ChsStpPanel1", "scale", "1.1 1.1 1.1")
					Global.UI.setAttribute("ChsStpPanel2", "scale", "0.9 0.9 0.9")
				-- End Liyarin's Color code
	            Resume()
	            if data.start_1==0 then
	                data.seconds_1 = data.seconds_1-data.bonus_1
	                if data.delay_1==0 then
	                    data.state = 1
	                else
	                    data.delayed = data.delay_1
	                    data.state = 9
	                end
	            else
	                data.seconds_1 = data.seconds_1+data.bonus_1
	                if data.delay_1==0 then
	                    data.state = 3
	                else
	                    data.delayed = data.delay_1
	                    data.state = 9
	                end
	            end
	            SetTurn()
	        elseif data.state==5 or data.state==6 then
	            tmpDigits[data.selDigit] = tmpDigits[data.selDigit]-1
	            if tmpDigits[data.selDigit] < 0 then
	                if data.selDigit==1 or data.selDigit==3 or data.selDigit==5 or data.selDigit==6 or data.selDigit==8 or data.selDigit==10 then
	                    tmpDigits[data.selDigit]=9
	                else
	                    tmpDigits[data.selDigit]=5
	                end
	            end
	            self.UI.show(digitNames[data.selDigit])
	            self.UI.setAttribute(digitNames[data.selDigit] , "image", tmpDigits[data.selDigit])
	        elseif data.state==7 or data.state==8 then
	            tmpDigits[data.selDigit] = tmpDigits[data.selDigit]-1
	            if tmpDigits[data.selDigit] < 0 then
	                if data.selDigit==5 or data.selDigit==10 then
	                    tmpDigits[data.selDigit]=9
	                else
	                    tmpDigits[data.selDigit]=5
	                end
	            end
	            self.UI.show(digitNames[data.selDigit])
	            self.UI.setAttribute(digitNames[data.selDigit] , "image", tmpDigits[data.selDigit])
	        end
	    end
	    holding_2=false
	    hold_2Time=0
	end
	function Click_C(player, _, _)
	    if holdTime<HOLD then
	        if player.color == "Grey" or (data.DoTurns == true and data.color_1 ~= player.color and data.color_2 ~= player.color and player.color ~= "Black") then
	            holding=false
	            holdTime=0
	            return
	        end
	        if data.state==1 or data.state==2 or data.state==3 or data.state==4 or data.state==9 or data.state==10 then
	            Pause()
	        elseif data.state==11 and data.storedState~=0 then
	            Resume()
	            SetTurn()
	        elseif data.state==5 or data.state==6 then
	            self.UI.show(digitNames[data.selDigit])
	            if data.selDigit==5 then
	                if data.state==6 then
	                    tmpToStartSec()
	                    secsToTmp(data.bonus_1, data.bonus_2)
	                    data.state = 7
	                    data.selDigit = 9
	                    HideColons()
	                    HideDigits()
	                    DisplayClock(2, data.bonus_2)
	                    self.UI.setAttribute("Hr2_1" , "image", "b")
	                else
	                    data.state = 11
	                    data.selDigit = 6
	                    adj = tmpToSecs()
	                    data.seconds_1 = adj[1] data.seconds_2 = adj[2]
	                    DisplayClock(1, data.seconds_1)
	                    DisplayClock(2, data.seconds_2)
	                    ShowDigits()
	                end
	            else
	                data.selDigit = data.selDigit+1
	                if data.selDigit>10 then
	                    if data.state==6 then
	                        tmpDigits[1]=tmpDigits[6]
	                        tmpDigits[2]=tmpDigits[7]
	                        tmpDigits[3]=tmpDigits[8]
	                        tmpDigits[4]=tmpDigits[9]
	                        tmpDigits[5]=tmpDigits[10]
	                        tmpToStartSec()
	                        DisplayClock(1, data.start_1)
	                    end
	                    data.selDigit=1
	                end
	            end
	        elseif data.state==7 then
	            self.UI.show(digitNames[data.selDigit])
	            if data.selDigit==5 then
	                bon = tmpToSecs() data.bonus_1 = bon[1] data.bonus_2 = bon[2]
	                secsToTmp(data.delay_1, data.delay_2)
	                data.state = 8
	                data.selDigit = 9
	                HideColons()
	                HideDigits()
	                DisplayClock(2, data.delay_2)
	                self.UI.setAttribute("Hr2_1" , "image", "d")
	            else
	                data.selDigit = data.selDigit+1
	                if data.selDigit>10 then
	                    tmpDigits[4]=tmpDigits[9]
	                    tmpDigits[5]=tmpDigits[10]
	                    bon = tmpToSecs()
	                    DisplayClock(1, bon[1])
	                    self.UI.setAttribute("Hr1_1" , "image", "b")
	                    data.selDigit=4
	                end
	            end
	        elseif data.state==8 then
	            self.UI.show(digitNames[data.selDigit])
	            if data.selDigit==5 then
	                del = tmpToSecs() data.delay_1 = del[1] data.delay_2 = del[2]
	                data.state = 11
	                data.selDigit = 6
	                data.seconds_1 = data.start_1 data.seconds_2 = data.start_2
	                DisplayClock(1, data.seconds_1)
	                DisplayClock(2, data.seconds_2)
	                ShowDigits()
	            else
	                data.selDigit = data.selDigit+1
	                if data.selDigit>10 then
	                    tmpDigits[4]=tmpDigits[9]
	                    tmpDigits[5]=tmpDigits[10]
	                    del = tmpToSecs()
	                    DisplayClock(1, del[1])
	                    self.UI.setAttribute("Hr1_1" , "image", "d")
	                    data.selDigit=4
	                end
	            end
	        end
	    end
	    holding=false
	    holdTime=0
	end
	function Hold_C(player, _, _)
		if player.color == "Grey" then
			return
		end
	    holding=true
	    holdColor = player.color
	end
	function Hold_1(player, _, _)
		if player.color == "Grey" then
			return
		end
	    holdColor_1 = player.color
	    holdPlayer_1 = player.steam_name
	    holding_1=true
	end
	function Hold_2(player, _, _)
		if player.color == "Grey" then
			return
		end
	    holdColor_2 = player.color
	    holdPlayer_2 = player.steam_name
	    holding_2=true
	end

	function Pause()
	    data.storedState=data.state
	    data.state=11
	    if data.DoTurns==true then
	        self.setColorTint(unColoredColor)
	        Turns.enable=false
	    end
	end
	function Resume()
	    data.state=data.storedState
	    data.storedState=11
	end
	function SetTurn()
	    if data.DoTurns==true then
	--      Turns.type=2
	--      Turns.pass_turns=false
	--      Turns.skip_empty_hands=false
	--      Turns.disable_interactations=true
	        if data.state==1 or data.state==3 or data.state==9 then
	            self.setColorTint(stringColorToRGB(data.color_1))
	--          Turns.order={data.color_1}
	--          Turns.turn_color=data.color_1
	        elseif data.state==2 or data.state==4 or data.state==10 then
	            self.setColorTint(stringColorToRGB(data.color_2))
	--          Turns.order={data.color_2}
	--          Turns.turn_color=data.color_2
	        end
	--      Turns.enable=true
	    end
	end

	function HideDigits()
	    for i=1,10,1 do
	        self.UI.hide(digitNames[i])
	    end
	end
	function ShowDigits()
	    for i=1,10,1 do
	        self.UI.show(digitNames[i])
	    end
	end
	function HideColons()
	    self.UI.hide("Cn1")
	    self.UI.hide("Cn2")
	    self.UI.hide("Cn3")
	    self.UI.hide("Cn4")
	end
	function ShowColons()
	    self.UI.show("Cn1")
	    self.UI.show("Cn2")
	    self.UI.show("Cn3")
	    self.UI.show("Cn4")
	end

	function Paused()
	    TurnCheck()
		    if data.storedState~=9 and data.storedState~=10 then
			        DisplayClock(1, data.seconds_1)
			        DisplayClock(2, data.seconds_2)
			        ShowDigits()
		    end
	    if holdTime==HOLD then
	        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
	            return
	        end
	        data.state=6
	        secsToTmp(data.start_1, data.start_2)
	        DisplayClock(1, data.start_1)
	        DisplayClock(2, data.start_2)
	    elseif Colons==true then
	        if data.storedState==11 then
	            HideColons()
	        elseif data.storedState==1 or data.storedState==3 then
	            self.UI.hide("Cn1")
	            self.UI.hide("Cn2")
			        elseif data.storedState==9 then
				            self.UI.hide("Cn1")
	            self.UI.hide("Cn2")
				            HideDigits()
				            self.UI.show(digitNames[4])
				            self.UI.show(digitNames[5])
				            DisplayClock(1, data.delayed)
	        elseif data.storedState==2 or data.storedState==4 then
	            self.UI.hide("Cn3")
	            self.UI.hide("Cn4")
			        elseif data.storedState==10 then
				            self.UI.hide("Cn3")
	            self.UI.hide("Cn4")
				            HideDigits()
				            self.UI.show(digitNames[9])
				            self.UI.show(digitNames[10])
				            DisplayClock(2, data.delayed)
	        end
	        Colons = false
	        return
	    end
	    ShowColons()
	    Colons = true
	end

	function DisplayClock(which, value)
	    secs = value
	    hours = secs/3600
	    secs = secs%3600
	    minutes = secs/60
	    secs = secs%60
	    self.UI.setAttribute("Hr"..which.."_1" , "image", math.floor(hours%10))
	    self.UI.setAttribute("Mn"..which.."_10", "image", math.floor(minutes/10))
	    self.UI.setAttribute("Mn"..which.."_01", "image", math.floor(minutes%10))
	    self.UI.setAttribute("Sc"..which.."_10", "image", math.floor(secs/10))
	    self.UI.setAttribute("Sc"..which.."_01", "image", math.floor(secs%10))
		DisplayUIClock(which)
	end

	function increment_1()
	    if holdTime==HOLD then
	        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
	            return
	        end
	        if data.DoTurns==true then
	            self.setColorTint(unColoredColor)
	            Turns.enable=false
	        end
	        data.storedState=data.state
	        data.state=5
	        secsToTmp(data.seconds_1, data.seconds_2)
	        DisplayClock(1, data.seconds_1)
	        DisplayClock(2, data.seconds_2)
	    elseif holdTime==0 then
	        ShowColons()
	        DisplayClock(1, data.seconds_1)
	        data.seconds_1=data.seconds_1+RESOLUTION

	    end
	end
	function increment_2()
	    if holdTime==HOLD then
	        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
	            return
	        end
	        if data.DoTurns==true then
	            self.setColorTint(unColoredColor)
	            Turns.enable=false
	        end
	        data.storedState=data.state
	        data.state=5
	        secsToTmp(data.seconds_1, data.seconds_2)
	        DisplayClock(1, data.seconds_1)
	        DisplayClock(2, data.seconds_2)
	    elseif holdTime==0 then
	        ShowColons()
	        DisplayClock(2, data.seconds_2)
	        data.seconds_2=data.seconds_2+RESOLUTION

	    end
	end
	function decrement_1()
	    if holdTime==HOLD then
	        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
	            return
	        end
	        if data.DoTurns==true then
	            self.setColorTint(unColoredColor)
	            Turns.enable=false
	        end
	        data.storedState=data.state
	        data.state=5
	        secsToTmp(data.seconds_1, data.seconds_2)
	        DisplayClock(1, data.seconds_1)
	        DisplayClock(2, data.seconds_2)
	    elseif holdTime==0 then
	        ShowColons()

	        DisplayClock(1, data.seconds_1)
	        data.seconds_1 = data.seconds_1-RESOLUTION
	        if data.seconds_1 < 0 then
	            Ding()
	            data.ended_1=true
	            data.state=11
	            data.storedState=data.state
	        end
	    end
	end
	function decrement_2()
	    if holdTime==HOLD then
	        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
	            return
	        end
	        if data.DoTurns==true then
	            self.setColorTint(unColoredColor)
	            Turns.enable=false
	        end
	        data.storedState=data.state
	        data.state=5
	        secsToTmp(data.seconds_1, data.seconds_2)
	        DisplayClock(1, data.seconds_1)
	        DisplayClock(2, data.seconds_2)
	    elseif holdTime==0 then
	        ShowColons()

	        DisplayClock(2, data.seconds_2)
	        data.seconds_2 = data.seconds_2-RESOLUTION
	        if data.seconds_2 < 0 then
	            Ding()
	            data.ended_2=true
	            data.state=11
	            data.storedState=data.state
	        end
	    end
	end

	function adjustTime()
	    if holdTime==HOLD then
	        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
	            return
	        end
	        data.state=11 data.storedState=11 data.selDigit=6
	        data.seconds_1 = data.start_1 data.seconds_2 = data.start_2
	        DisplayClock(1, data.start_1)
	        DisplayClock(2, data.start_2)
	    else
	        ShowColons()
	        for i=1,10,1 do
	            if i~=data.selDigit then
	                self.UI.show(digitNames[i])
	            end
	        end
	        if Colons==true then
	            self.UI.hide(digitNames[data.selDigit])
	            Colons = false
	        else
	            self.UI.show(digitNames[data.selDigit])
	            Colons = true
	        end
	    end
	end
	function setTime()
	    if holdTime==HOLD then
	        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
	            return
	        end
	        data.state=11 data.storedState=11 data.selDigit=6
			        tmpToStartSec()
	        data.seconds_1 = data.start_1 data.seconds_2 = data.start_2
	        DisplayClock(1, data.start_1)
	        DisplayClock(2, data.start_2)
	    else
			        ShowColons()
			        for i=1,10,1 do
				            if i~=data.selDigit then
					                self.UI.show(digitNames[i])
				            end
			        end
			        if Colons==true then
				            self.UI.hide(digitNames[data.selDigit])
				            HideColons()
				            Colons = false
			        else
				            self.UI.show(digitNames[data.selDigit])
				            ShowColons()
				            Colons = true
			        end
		    end
	end
	function setBonus()
	    if holdTime==HOLD then
	        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
	            return
	        end
	        data.state=11 data.storedState=11 data.selDigit=6
			        bon = tmpToSecs() data.bonus_1 = bon[1] data.bonus_2 = bon[2]
	        data.seconds_1 = data.start_1 data.seconds_2 = data.start_2
	        DisplayClock(1, data.start_1)
	        DisplayClock(2, data.start_2)
	    else
	        		count=2
			        if data.selDigit>5 then
				            self.UI.show("Hr2_1")
				            burp={9,10}
			        else
				            self.UI.show("Hr1_1")
				            burp={4,5,9,10}
				            count=4
			        end
			        HideColons()
			        for i=1,count,1 do
	    			        if burp[i]~=data.selDigit then
					                self.UI.show(digitNames[burp[i]])
				            end
			        end
			        if Colons==true then
	    			        self.UI.hide(digitNames[data.selDigit])
				            Colons = false
			        else
				            self.UI.show(digitNames[data.selDigit])
				            Colons = true
			        end
		    end
	end
	function setDelay()
	    if holdTime==HOLD then
	        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
	            return
	        end
	        data.state=11 data.storedState=11 data.selDigit=6
	        		del = tmpToSecs() data.delay_1 = del[1] data.delay_2 = del[2]
	        data.seconds_1 = data.start_1 data.seconds_2 = data.start_2
	        DisplayClock(1, data.start_1)
	        DisplayClock(2, data.start_2)
	    else
	        		count=2
			        if data.selDigit>5 then
				            self.UI.show("Hr2_1")
				            burp={9,10}
			        else
				            self.UI.show("Hr1_1")
				            burp={4,5,9,10}
				            count=4
			        end
			        HideColons()
			        for i=1,2,1 do
				            if burp[i]~=data.selDigit then
					                self.UI.show(digitNames[burp[i]])
				            end
			        end
			        if Colons==true then
				            self.UI.hide(digitNames[data.selDigit])
				            Colons = false
			        else
				            self.UI.show(digitNames[data.selDigit])
				            Colons = true
			        end
		    end
	end

	function doDelay_1()

	    if data.delayed==0 then
	        ShowColons()
	        ShowDigits()
	        DisplayClock(1, data.seconds_1)
	        DisplayClock(2, data.seconds_2)
	        if data.start_1==0 then
	            data.state = 1
	        else
	            data.state = 3
	        end
	    else
	        HideColons()
	        HideDigits()
	        self.UI.show(digitNames[4])
	        self.UI.show(digitNames[5])
	        DisplayClock(1, data.delayed)
	        data.delayed=data.delayed-RESOLUTION
	    end
	end

	function doDelay_2()

	    if data.delayed==0 then
	        ShowColons()
	        ShowDigits()
	        DisplayClock(1, data.seconds_1)
	        DisplayClock(2, data.seconds_2)
	        if data.start_2==0 then
	            data.state = 2
	        else
	            data.state = 4
	        end
	    else
	        HideColons()
	        HideDigits()
	        self.UI.show(digitNames[9])
	        self.UI.show(digitNames[10])
	        DisplayClock(2, data.delayed)
	        data.delayed=data.delayed-RESOLUTION
	    end
	end

	function secsToTmp(secs_1, secs_2)
	    secs = secs_1
	    hours = secs/3600
	    secs = secs%3600
	    minutes = secs/60
	    secs = secs%60
	    tmpDigits[1] = math.floor(hours%10)
	    tmpDigits[2] = math.floor(minutes/10)
	    tmpDigits[3] = math.floor(minutes%10)
	    tmpDigits[4] = math.floor(secs/10)
	    tmpDigits[5] = math.floor(secs%10)
	    secs = secs_2
	    hours = secs/3600
	    secs = secs%3600
	    minutes = secs/60
	    secs = secs%60
	    tmpDigits[6] = math.floor(hours%10)
	    tmpDigits[7] = math.floor(minutes/10)
	    tmpDigits[8] = math.floor(minutes%10)
	    tmpDigits[9] = math.floor(secs/10)
	    tmpDigits[10]= math.floor(secs%10)
	end
	function tmpToStartSec()
	    data.start_1=(tmpDigits[1]*3600)+(tmpDigits[2]*600)+(tmpDigits[3]*60)+(tmpDigits[4]*10)+tmpDigits[5]
	    data.start_2=(tmpDigits[6]*3600)+(tmpDigits[7]*600)+(tmpDigits[8]*60)+(tmpDigits[9]*10)+tmpDigits[10]
	end
	function tmpToSecs()
	    return {(tmpDigits[1]*3600)+(tmpDigits[2]*600)+(tmpDigits[3]*60)+(tmpDigits[4]*10)+tmpDigits[5], (tmpDigits[6]*3600)+(tmpDigits[7]*600)+(tmpDigits[8]*60)+(tmpDigits[9]*10)+tmpDigits[10]}
	end
	function Ding()
	    Timer.create({identifier=os.time(), function_name="Dong", delay=0.025, repetitions=50})
	end
	function Dong()
	    pos = self.getPosition()
	    pos.y = pos.y+0.125
	    self.setPosition(pos)
	    self.setVelocity({0,-200,0})
	end
	function TurnCheck()
	    if hold_1Time==HOLD then
	        if data.DoTurns==false then
	            data.color_1=holdColor_1
	            if data.color_2~="" then
	                broadcastToAll("Color-Mode Enabled.", {0,1,0})
	                data.DoTurns=true
	            else
	                broadcastToAll("Waiting For Player 2...", {1,1,1})
	            end
	            broadcastToAll("Set Player 1 to "..holdPlayer_1.." ("..holdColor_1..")", {0.5,0.5,1})
	        elseif holdColor_1==data.color_1 or holdColor_1==data.color_2 or holdColor_1=="Black" then
	            broadcastToAll("Color-Mode Disabled.", {1,0,0})
	            data.DoTurns=false
	            data.color_1=""
	            data.color_2=""
	            self.setColorTint(unColoredColor)
	        end
	    end
	    if hold_2Time==HOLD then
	        if data.DoTurns==false then
	            data.color_2=holdColor_2
	            if data.color_1~="" then
	                broadcastToAll("Color-Mode Enabled.", {0,1,0})
	                data.DoTurns=true
	            else
	                broadcastToAll("Waiting For Player 1...", {1,1,1})
	            end
	            broadcastToAll("Set Player 2 to "..holdPlayer_2.." ("..holdColor_2..")", {0.5,0.5,1})
	        elseif holdColor_2==data.color_1 or holdColor_2==data.color_2 or holdColor_2=="Black" then
	            broadcastToAll("Color-Mode Disabled.", {1,0,0})
	            data.DoTurns=false
	            data.color_1=""
	            data.color_2=""
	            self.setColorTint(unColoredColor)
	        end
	    end
	end

-- Liyarin's color functions

-- Changes the color of the UI buttons based on the set colors
function changeButtonColors()
	-- Stopwatch Buttons
	self.UI.setAttribute("pColor1", "color", pColors.pColor1)
	self.UI.setAttribute("pColor2", "color", pColors.pColor2)

	--UI Buttons
	local waitTime = 0
	if Global.UI.getAttribute("Chess Stopwatch", "id") == nil then
		local oldUI = Global.UI.getXml()
		if oldUI == nil then
			oldUI = ""
		end
		Global.UI.setXml(oldUI .. [[
			<Panel
				id = "Chess Stopwatch"
				scale = "1 1 1"
				width = "180"
				height = "120"
				rectAlignment = "UpperLeft"
				offsetXY = "430 0"
				allowDragging = "true"
				restrictDraggingToParentBounds = "false"
				returnToOriginalPositionWhenReleased = "false"
				>
				<VerticalLayout spacing = "5" padding = "5">
					<Panel id="ChsStpPanel1" color = "]]..pColors.pColor1..[[">
						<Button
						scale = "1 1 1"
						width = "180"
						height = "60"
						onClick="]]..self.getGUID()..[[/Click_1" color = "rgba(0,0,0,0)"/>
						<Text id="ChsStpWatch1" text="0:00:00" fontSize="40" color="White"/>
					</Panel>
					<Panel id="ChsStpPanel2" color = "]]..pColors.pColor2..[[">
						<Button
						scale = "1 1 1"
						width = "180"
						height = "60"
						onClick="]]..self.getGUID()..[[/Click_2" color = "rgba(0,0,0,0)"/>
						<Text id="ChsStpWatch2" text="0:00:00" fontSize="40" color="White"/>
					</Panel>
				</VerticalLayout>
			</Panel>
		]])
		waitTime = 10
	end

	Wait.frames(function()
		Global.UI.setAttribute("ChsStpPanel1", "color", pColors.pColor1)
		Global.UI.setAttribute("ChsStpPanel2", "color", pColors.pColor2)
	end, waitTime)
end

-- Changes the button of one side based on the player that clicked it
function changeColors(clickPlayer, clickBtn, buttonID)
	if buttonID == "pColor1" or buttonID == "pColor2" then
		pColors[buttonID] = clickPlayer.color

		changeButtonColors()
	end
end

-- Calculates numbers for UI clock
function DisplayUIClock(which) -- which 1,2
	local clockString = math.floor(hours%10) ..":".. math.floor(minutes/10) .. math.floor(minutes%10) ..":".. math.floor(secs/10) .. math.floor(secs%10)

	Global.UI.setAttribute("ChsStpWatch"..which, "text", clockString)
end