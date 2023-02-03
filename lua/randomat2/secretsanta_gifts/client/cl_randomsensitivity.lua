local sensitivity = nil

net.Receive("RdmtSecretSantaRandomSensitivityValue", function()
    local value = net.ReadFloat()
    if value > 0 then
        sensitivity = value
    else
        sensitivity = nil
    end
end)

hook.Add("AdjustMouseSensitivity", "RdmtSecretSantaRandomSensitivity_AdjustMouseSensitivity", function(default_sensitivity)
    return sensitivity
end)