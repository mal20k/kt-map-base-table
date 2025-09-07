rOfB = 0.984 -- radius of the Base 25mm
toggleMeasure = -1;
selfpc = White;

cm_label = self.createButton({
    label="25mm", click_function="none", position = {0, 7.7, 0}, rotation={0,0,0}, height=0, width=0, font_size=200,
    font_color={255,0,0},
    alignment=2
})

function onObjectPickUp(playerCol, self)
    selfpc = playerCol;
end

function onUpdate()
    pointA = self.getPosition();

    if toggleMeasure == -1 then
        self.setVectorLines({})
    end

    if selfpc != nil then
        function onObjectPickUp(selfpc, targetObj)
            if targetObj == self then
                toggleMeasure = 1;
            end

            if targetObj != nil and targetObj != self then
                toggleMeasure = -1;
                o_target = targetObj;
            end
        end

        if o_target != nil then
            pointB = o_target.getPosition();
        end

        if toggleMeasure == 1 then
            if pointB != nil then

                newStartPoint = self.positionToLocal(pointA)
                newEndPoint = self.positionToLocal(pointB+ Vector(0, 0.05, 0))

                middle = newStartPoint + newEndPoint
                middle = middle:scale(0.5)

                --calaculating the intercetion of 2 circles in 2D (from above)
                rEnd = (rOfB-0.1)/2
                rM = math.sqrt( (newEndPoint[1]-middle[1])^2 + (newEndPoint[3]-middle[3])^2 )
                r = rM

                Ahelp = (rM^2 - rEnd^2)/(2*r^2)
                A1 = (middle[1]+newEndPoint[1])/2 + Ahelp*(newEndPoint[1]-middle[1])
                A3 = (middle[3]+newEndPoint[3])/2 + Ahelp*(newEndPoint[3]-middle[3])

                Bhelp = 0.5*math.sqrt(2*(rM^2+rEnd^2)/r^2 - (rM^2 -rEnd^2)^2/r^4 -1)
                B1 =Bhelp*(newEndPoint[3]-middle[3])
                B3 =Bhelp*(newEndPoint[1]-middle[1])

                intersection1 = Vector( A1 - B1, newEndPoint[2], A3 + B3)
                intersection2 = Vector( A1 + B1, newEndPoint[2], A3 - B3)

                self.setVectorLines({
                  {
                    points    = { newStartPoint, intersection1 },
                    color     = self.getColorTint(),
                    thickness = 0.1,
                    rotation  = {0,0,0},
                  },
                  {
                    points    = { newStartPoint, intersection2 },
                    color     = self.getColorTint(),
                    thickness = 0.1,
                    rotation  = {0,0,0},
                  },
                })
            end
        end
    end
end