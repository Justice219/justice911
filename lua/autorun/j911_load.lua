print("[Justice's 911 has Loaded!]")
print("---------------------------")
print("Version - 0.0.1")
print("Retail Version = false")
print("---------------------------")

if SERVER then
    include("j911_core/j911_init.lua")
    include("j911_core/j911_config.lua")
    AddCSLuaFile("j911_core/j911_config.lua")
    AddCSLuaFile("j911_core/j911_cl_init.lua")
elseif CLIENT then
    include("j911_core/j911_config.lua")
    include("j911_core/j911_cl_init.lua")
end

print("Justice's 911 Scripts Loaded!")