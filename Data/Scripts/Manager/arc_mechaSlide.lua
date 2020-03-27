currentSpeed = 0
maxSpeed = 5
minSpeed = 0.1

incSpeed = 1

function onUpPressed()
    System.LogAlways("OnUP aa")

    if (currentSpeed < maxSpeed) then
        currentSpeed = currentSpeed + incSpeed
    end

    System.LogAlways("Current speed: " .. tostring(currentSpeed))
end

System.AddCCommand('onUpPressed', 'onUpPressed()', "onUpPressed!")
System.ExecuteCommand("bind 'w' onUpPressed ")

function onDownPressed()
    System.LogAlways("OnDown")

    if (currentSpeed > 0) then
        currentSpeed = currentSpeed - incSpeed
    end

    System.LogAlways("Current speed: " .. tostring(currentSpeed))
end

System.AddCCommand('onDownPressed', 'onDownPressed()', "onDownPressed!")
System.ExecuteCommand("bind 's' onDownPressed ")

mechaSlideActive = false

function onSlideUpdate()

    if not mechaSlideActive then
        return
    end

    local from = player:GetPos();
    from.z = from.z + 1.615;

    local hitData = {};
    local hits = Physics.RayWorldIntersection(
            from,
            vecScale(System.GetViewCameraDir(), 250),
            10,
            ent_all,
            player.id,
            nil,
            hitData
    );

    if hits > 0 then
        -- dump(hitData[1])

        firstHit = hitData[1]

        p = player:GetPos()

        c = System.GetViewCameraDir()

        local from = player:GetPos();
        from.z = from.z + 1.615;

        local hitDownToBottom = {};
        local hitsDownToBottom = Physics.RayWorldIntersection(from, { x = 0, y = 0, z = -5 }, 10, ent_all, player.id, nil, hitDownToBottom);

        local frontData = {};
        camView = vecScale(System.GetViewCameraDir(), 10)
        newCamView = {
            camView.x,
            camView.y,
            camView.z
        }
        local frontHits = Physics.RayWorldIntersection(from, newCamView, 10, ent_all, player.id, nil, frontData);

        if (frontHits <= 0) then
            return
        end

        up = {
            p.x + c.x * (0.1 * currentSpeed),
            p.y + c.y * (0.1 * currentSpeed),
            -- p.z + c.z * 0
            hitDownToBottom[1].pos.z + 0.1
        }

        player:SetPos(up)

    end

end
