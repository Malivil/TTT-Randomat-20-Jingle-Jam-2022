
local secretSantaFrame = nil
local targetPlayer = nil
local choiceName = nil

net.Receive("RdmtSecretSantaBegin", function()
    local ply = LocalPlayer()

    targetPlayer = net.ReadString()
    local choices = net.ReadTable()

    secretSantaFrame = vgui.Create("DFrame")
    secretSantaFrame:SetPos(10, ScrH() - 800)
    secretSantaFrame:SetSize(200, 50 + (18 * #choices))
    secretSantaFrame:SetTitle("Choose Your Gift (Hold " .. Key("+showscores", "tab"):lower() .. ")")
    secretSantaFrame:SetDraggable(false)
    secretSantaFrame:ShowCloseButton(false)
    secretSantaFrame:SetVisible(true)
    secretSantaFrame:SetDeleteOnClose(true)

    --Player List
    local list = vgui.Create("DListView", secretSantaFrame)
    list:Dock(FILL)
    list:SetMultiSelect(false)
    list:AddColumn("Present")
    for _, v in ipairs(choices) do
        list:AddLine(v.name, v.id)
    end

    list.OnRowSelected = function(lst, index, pnl)
        choiceName = pnl:GetColumnText(1)
        local choice = pnl:GetColumnText(2)
        net.Start("RdmtSecretSantaChoose")
        net.WriteString(choice)
        net.SendToServer()
        ply:PrintMessage(HUD_PRINTTALK, "You chose: " .. choiceName)

        secretSantaFrame:Close()
        secretSantaFrame = nil
    end

    hook.Add("TTTBodySearchPopulate", "RdmtSecretSantaSearchPopulate", function(search, raw)
        local message = "Secret Santa\n\tRecipient: " .. targetPlayer
        if choiceName ~= nil then
            message = message .. "\n\tGift: " .. choiceName
        end
        search["rdmtsecretsanta"] = {
            text = message,
            img = "vgui/ttt/icon_secretsanta",
            p = 3
        }
    end)
end)

net.Receive("RdmtSecretSantaEnd", function()
    if IsValid(secretSantaFrame) then
        secretSantaFrame:Close()
        secretSantaFrame = nil
    end

    hook.Remove("TTTBodySearchEquipment", "RdmtTTTBodySearchEquipment")
    hook.Remove("TTTBodySearchPopulate", "RdmtSecretSantaSearchPopulate")
    targetPlayer = nil
end)