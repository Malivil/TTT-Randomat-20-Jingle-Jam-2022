local client = nil
local donationGoal = nil
local donationCurrent = 0
local donationMet = false

local function CreateDonateMenu(dsheet)
    local GetTranslation = LANG.GetTranslation
    local dform = vgui.Create("DForm", parent)
    dform:SetName(GetTranslation("donate_menutitle"))
    dform:StretchToParent(0, 0, 0, 0)
    dform:SetAutoSize(false)

    if client:GetCredits() <= 0 then
        dform:Help(GetTranslation("donate_no_credits"))
        return dform
    end

    local bw, bh = 100, 20
    local dsubmit = vgui.Create("DButton", dform)
    dsubmit:SetSize(bw, bh)
    dsubmit:SetText(GetTranslation("donate_send"))
    dsubmit:SetDisabled(true)

    -- Create control to select the number of credits
    local dslider = vgui.Create("DNumSlider", dform)
    dslider:SetPos(50, 50)
    dslider:SetSize(100, 100)
    dslider:SetText(GetTranslation("equip_donation_amount"))
    dslider:SetMinMax(0, client:GetCredits())
    dslider:SetDefaultValue(0)
    dslider:SetDecimals(0)

    dslider.OnValueChanged = function(slider, num)
        dsubmit:SetDisabled(num <= 0)
    end

    dsubmit.DoClick = function(s)
        local credits = dslider:GetValue()
        net.Start("RdmtJingleJam2022Donation")
        net.WriteUInt(credits, 8)
        net.SendToServer()
    end

    dform:AddItem(dslider)
    dform:AddItem(dsubmit)

    return dform
end

net.Receive("RdmtJingleJam2022Begin", function()
    local GetTranslation = LANG.GetTranslation
    LANG.AddToLanguage("english", "donate_name", "Donate")
    LANG.AddToLanguage("english", "donate_send", "Send Donation")
    LANG.AddToLanguage("english", "donate_menutitle", "Donate to charity")
    LANG.AddToLanguage("english", "donate_no_credits", "No credits available for donation")
    LANG.AddToLanguage("english", "equip_tooltip_donate", "Donate credits to charity")
    LANG.AddToLanguage("english", "equip_donation_amount", "Donate Amount")

    client = LocalPlayer()
    donationGoal = net.ReadUInt(8)
    donationCurrent = 0
    donationMet = false

    hook.Add("TTTEquipmentTabs", "RdmtJingleJam2022DonationTab", function(dsheet)
        local ddonate = CreateDonateMenu(dsheet)
        dsheet:AddSheet(GetTranslation("donate_name"), ddonate, "icon16/money_dollar.png", false, false, GetTranslation("equip_tooltip_donate"))
        return true
    end)

    local progressTexture = Material("vgui/ttt/Pattern_money.png")
    local completeTexture = Material("vgui/ttt/Pattern_money_gold.png")
    hook.Add("HUDPaint", "RdmtJingleJam2022HUDPaint", function()
        local percentFilled = donationCurrent / donationGoal
        if donationMet then
            percentFilled = 1
        end

        -- Draw the donation tracker
        local borderThickness = 2
        local margin = 20
        local barHeight = 780
        local barWidth = 98
        local barTop = (ScrH() - barHeight) / 2
        local barLeft = ScrW() - margin - barWidth - (borderThickness * 2)

        -- Draw border
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawOutlinedRect(barLeft, barTop, barWidth + (borderThickness * 2), barHeight + (borderThickness * 2), borderThickness)

        -- Draw texture
        local filledHeight = barHeight * percentFilled
        surface.SetMaterial(donationMet and completeTexture or progressTexture)
        -- Use a scissor rect to cut the texture off at the correct percent complete
        render.SetScissorRect(barLeft + borderThickness, ScrH() - barTop - filledHeight + borderThickness, barLeft + (borderThickness * 2) + barWidth, ScrH(), true)
            surface.DrawTexturedRect(barLeft + borderThickness, ScrH() - barTop - barHeight + borderThickness, barWidth, barHeight)
        render.SetScissorRect(0, 0, 0, 0, false)
        draw.NoTexture()
    end)
end)

net.Receive("RdmtJingleJam2022End", function()
    hook.Remove("TTTEquipmentTabs", "RdmtJingleJam2022DonationTab")
    hook.Remove("HUDPaint", "RdmtJingleJam2022HUDPaint")
end)

net.Receive("RdmtJingleJam2022Donation", function()
    local credits = net.ReadUInt(8)

    -- Save the donation amount
    donationCurrent = donationCurrent + credits
    -- Figure out if we're done
    donationMet = donationCurrent >= donationGoal
end)