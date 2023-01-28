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
    dslider:SetSize(100, 25)
    dslider:SetText(GetTranslation("equip_donation_amount"))
    dslider:SetMinMax(0, client:GetCredits())
    dslider:SetDefaultValue(0)
    dslider:SetDecimals(0)

    dslider.OnValueChanged = function(slider, num)
        dsubmit:SetDisabled(num <= 0)
    end

    local dtextentry = vgui.Create("DTextEntry", dform)
    dtextentry:SetSize(100, 25)
    dtextentry:SetPlaceholderText(GetTranslation("equip_donation_message"))
    dtextentry.OnGetFocus = function() dsheet:GetParent():SetKeyboardInputEnabled(true) end
    dtextentry.OnLoseFocus = function() dsheet:GetParent():SetKeyboardInputEnabled(false) end

    local dcheckbox = vgui.Create("DCheckBoxLabel", dform)
    dcheckbox:SetSize(100, 25)
    dcheckbox:SetText(GetTranslation("equip_donation_anon"))

    dsubmit.DoClick = function(s)
        -- Get the value from the text area instead of the slider itself because the slider value is a float
        -- and rounding it is not accurate. We want the value shown to the user to be what gets sent to the server.
        local credits = dslider:GetTextArea():GetInt()
        net.Start("RdmtJingleJam2022Donation")
        net.WriteUInt(credits, 8)
        net.WriteString(dtextentry:GetValue())
        net.WriteBool(dcheckbox:GetChecked())
        net.SendToServer()
    end

    dform:AddItem(dslider)
    dform:AddItem(dtextentry)
    dform:AddItem(dcheckbox)
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
    LANG.AddToLanguage("english", "equip_donation_message", "Donate Message")
    LANG.AddToLanguage("english", "equip_donation_anon", "Donate Anonymously")

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
    local donationBoxColor = Color(195, 15, 68, 255)
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

        -- Draw the donation amounts
        local donationMargin = 20
        local donationInnerMargin = 4
        local donationHeight = 30
        local text = donationCurrent .. " / " .. donationGoal
        draw.RoundedBox(3, barLeft + borderThickness, barTop - donationMargin - donationHeight, barWidth, donationHeight, donationBoxColor)

        surface.SetFont("Trebuchet22")
        local textWidth, _ = surface.GetTextSize(text)
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(barLeft + ((barWidth - textWidth) / 2) + borderThickness, barTop - donationMargin + donationInnerMargin - donationHeight)
        surface.DrawText(text)
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