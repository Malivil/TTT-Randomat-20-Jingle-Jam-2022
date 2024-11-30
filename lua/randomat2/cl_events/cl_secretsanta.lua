local EVENT = {}
EVENT.id = "secretsanta"

local secretSantaFrame = nil
function EVENT:End()
    if IsValid(secretSantaFrame) then
        secretSantaFrame:Close()
        secretSantaFrame = nil
    end

    hook.Remove("TTTBodySearchPopulate", "RdmtSecretSantaSearchPopulate")
end

Randomat:register(EVENT)

local choiceName = nil
net.Receive("RdmtSecretSantaBegin", function()
    local ply = LocalPlayer()
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
        if not raw.owner then return end

        local targetName = raw.owner:GetNWString("RdmtSecretSantaTarget", "")
        if #targetName == 0 then return end

        local message = "Secret Santa\n\tRecipient: " .. targetName
        local targetChoice = raw.owner:GetNWString("RdmtSecretSantaChoice", "")
        if #targetChoice > 0 then
            message = message .. "\n\tGift: " .. targetChoice
        end
        search["rdmtsecretsanta"] = {
            text = message,
            img = "vgui/ttt/icon_secretsanta",
            p = 3
        }
    end)
end)