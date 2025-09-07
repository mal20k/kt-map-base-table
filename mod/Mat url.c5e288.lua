-- FTC-GUID: c5e288
keepForTerrainEditor = true

lightEquatorColor = {}
lightGroundColor = {}
lightSkyColor = {}
lightColor = {}
manageLighting=true
function refreshSurface()
    obj_surface = getObjectFromGUID("4ee1f2")
end

function onSave()
    local data =  {}
    if manageLighting then
        data={
                    link=url,
                    svlightEquatorColor = lightEquatorColor,
                    svlightGroundColor = lightGroundColor,
                    svlightSkyColor = lightSkyColor,
                    svlightColor = lightColor,
                    svlightAmbientType= lightAmbientType,
                    svlightAmbientIntensity = lightAmbientIntensity,
                    svlightLightIntensity = lightLightIntensity,
                    svlightReflectionIntesity = lightReflectionIntesity,
                    }
    else
        data={link=url}
    end

    saved_data = JSON.encode(data)
    --saved_data = ""
    return saved_data
end

function onLoad(saved_data)

    self.setInvisibleTo({})
    self.interactable=true
    if saved_data ~= "" then
         local loaded_data = JSON.decode(saved_data)
         url = loaded_data.link
         lightEquatorColor = loaded_data.svlightEquatorColor
         lightGroundColor = loaded_data.svlightGroundColor
         lightSkyColor = loaded_data.svlightSkyColor
         lightColor = loaded_data.svlightColor
         lightAmbientType= loaded_data.svlightAmbientType
         lightAmbientIntensity = loaded_data.svlightAmbientIntensity
         lightLightIntensity = loaded_data.svlightLightIntensity
         lightReflectionIntesity = loaded_data.svlightReflectionIntesity
    else
         url ='No url'
         lightEquatorColor = {}
         lightGroundColor = {}
         lightSkyColor = {}
         lightColor = {}
         lightAmbientType= nil
         lightAmbientIntensity = nil
         lightLightIntensity = nil
         lightReflectionIntesity = nil
    end

    flexControl = getObjectFromGUID('bd69bd')
    obj_surface = getObjectFromGUID("4ee1f2")
    Xoffset=2
    Yoffset=3
    if obj_surface ~= nil and obj_surface.getVar("version")>= 2.0 then
        Wait.frames(changeMat ,5)
    end
    Wait.frames(createUI, 30)

end

function createUI()
    createTitleButton()
    createDisplay()
    --createSetButton()
    createRewriteButton()
    createDeleteButton()
    createWarningButton()
    if obj_surface == nil then
        broadcastToAll("THIS TERRAIN IS MEANT TO BE USED WITH BCB BASE MAP V2.0+\nLoad BCB base map and additive load this one.", "Orange")
    end
end

function createWarningButton()
    button_parameters = {}
    button_parameters.click_function = 'none'
    button_parameters.function_owner = self
    button_parameters.label = "THIS TERRAIN IS MEANT TO BE USED WITH BCB BASE MAP V2.0+\nLoad BCB base map and additive load this one."
    button_parameters.position = {7.5+Xoffset,Yoffset,0}
    button_parameters.rotation = {0,270,0}
    button_parameters.width = 0
    button_parameters.height = 0
    button_parameters.font_size = 200
    button_parameters.color = 'Black'
    button_parameters.font_color = 'Orange'
    button_parameters.tooltip=""
    self.createButton(button_parameters)
end

function createTitleButton()
    button_parameters = {}
    button_parameters.click_function = 'none'
    button_parameters.function_owner = self
    button_parameters.label = "Copy/paste the link below to load the mat image \n (for BCB v2.0 template it's automatic)"
    button_parameters.position = {0+Xoffset,Yoffset,0}
    button_parameters.rotation = {0,270,0}
    button_parameters.width = 4400
    button_parameters.height = 800
    button_parameters.font_size = 200
    button_parameters.color = 'Black'
    button_parameters.font_color = 'White'
    button_parameters.tooltip=""
    self.createButton(button_parameters)
end

function createDisplay()
    self.createInput({
        label='', input_function="none", function_owner=self,
        alignment=3, position={1.5+Xoffset,Yoffset,0}, rotation = {0,270,0}, height=400, width= string.len(url)*160,
        font_size=300, tooltip="",
        value= url
    })
end

function createSetButton()
    button_parameters = {}
    button_parameters.click_function = 'changeMat'
    button_parameters.function_owner = self
    button_parameters.label = 'SET \n if autoset didnt worked \n (for BCB v2.0 template)'
    button_parameters.position = {3.2+Xoffset,Yoffset,3}
    button_parameters.rotation = {0,270,0}
    button_parameters.width = 3000
    button_parameters.height = 800
    button_parameters.font_size = 200
    button_parameters.tooltip="Auto set"
    self.createButton(button_parameters)
end

function createRewriteButton()
    button_parameters = {}
    button_parameters.click_function = 'rewriteUrl'
    button_parameters.function_owner = self
    button_parameters.label = 'SHOW AGAIN URL \n (in case things went wrong)'
    button_parameters.position = {3.2+Xoffset,Yoffset,0}
    button_parameters.rotation = {0,270,0}
    button_parameters.width = 2600
    button_parameters.height = 800
    button_parameters.font_size = 200
    button_parameters.tooltip="Show again"
    self.createButton(button_parameters)
end

function createDeleteButton()
    button_parameters = {}
    button_parameters.click_function = 'erease'
    button_parameters.function_owner = self
    button_parameters.label = 'Erease this tool \n when done \n (can not undo!)'
    button_parameters.position = {5.7+Xoffset,Yoffset,0}
    button_parameters.rotation = {0,270,0}
    button_parameters.width = 2000
    button_parameters.height = 1200
    button_parameters.font_size = 200
    button_parameters.color = 'Black'
    button_parameters.font_color = 'Red'
    button_parameters.tooltip="Erease"
    self.createButton(button_parameters)
end

function retriveUrl()
    obj_surface = getObjectFromGUID("4ee1f2")
    url = obj_surface.getCustomObject().diffuse
    rewriteUrl()
    lightEquatorColor = Lighting.getAmbientEquatorColor()
    lightEquatorColor= {r=lightEquatorColor.r, g=lightEquatorColor.g, b=lightEquatorColor.b}
    lightGroundColor = Lighting.getAmbientGroundColor()
    lightGroundColor= {r=lightGroundColor.r, g=lightGroundColor.g, b=lightGroundColor.b}
    lightSkyColor = Lighting.getAmbientSkyColor()
    lightSkyColor= {r=lightSkyColor.r, g=lightSkyColor.g, b=lightSkyColor.b}
    lightColor = Lighting.getLightColor()
    lightColor= {r=lightColor.r, g=lightColor.g, b=lightColor.b}
    lightAmbientType= Lighting.ambient_type
    lightAmbientIntensity = Lighting.ambient_intensity
    lightLightIntensity = Lighting.light_intensity
    lightReflectionIntesity = Lighting.reflection_intensity
end

function rewriteUrl()
    self.editInput({index=0, value=url})
    self.editInput({index=0, width= string.len(url)*160})
    self.setDescription("")
end

function changeMat(new)
    if url ~= "" and url ~= "No url" and flexControl ~= nil then
        closeMenu()
        flexControl.call('setControlF')
        Wait.frames(updateSurfaceMat, 5)
    else
        if self.getDescription()=="" then
            broadcastToAll("Invalid URL or no table", "Red")
        end
    end
    setLighting()
end

function setLighting()
    if manageLighting == false then
        return
    end
    if lightEquatorColor ~= nil then
        Lighting.setAmbientEquatorColor(lightEquatorColor)
    end
    if lightGroundColor ~= nil then
        Lighting.setAmbientGroundColor(lightGroundColor)
    end
    if lightSkyColor ~= nil then
        Lighting.setAmbientSkyColor(lightSkyColor)
    end
    if lightColor ~= nil then
        Lighting.setLightColor(lightColor)
    end
    if lightAmbientType ~= nil then
        Lighting.ambient_type = lightAmbientType
    end
    if lightAmbientIntensity ~= nil then
        Lighting.ambient_intensity = lightAmbientIntensity
    end
    if lightLightIntensity ~= nil then
        Lighting.light_intensity = lightLightIntensity
    end
    if lightReflectionIntesity ~= nil then
        Lighting.reflection_intensity = lightReflectionIntesity
    end
    Lighting.apply()
end


function setInputValues()
    flexControl.editInput( {index=0, value=""})
    flexControl.editInput( {index=1, value=url})
end

function updateSurfaceMat()
    local newUrl=url
    obj_surface = getObjectFromGUID("4ee1f2")
    local matDebugObject=nil
    for i,obj in ipairs(getAllObjects()) do
        if obj.getName()== "Mat url debug" then matDebugObject=obj end
    end
    if matDebugObject then
        local customInfoDebug = matDebugObject.getCustomObject()
        if customInfoDebug.diffuse ~= "" then
            newUrl= customInfoDebug.diffuse
            --print("USING DEBUUG MAT")
            matDebugObject.destroy()
        else
            --print("USING INTERNAL VARIABLE MAT")
        end
    end
    local customInfo = obj_surface.getCustomObject()
    customInfo.diffuse = newUrl
    obj_surface.setCustomObject(customInfo)
    obj_surface = obj_surface.reload()
    Wait.frames(erease, 5)
end

function closeMenu()
    flexControl.clearButtons()
    flexControl.clearInputs()
    flexControl.call('createOpenCloseButton')
end

function erease()
    if obj_surface then
        obj_surface.call("showMenu")
        obj_surface.interactable=false
    end
    self.destroy()
end

function none()
end