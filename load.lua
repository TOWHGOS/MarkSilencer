local add_on_name = "MarkSilencer"
local frame = CreateFrame "Frame"

local function event_handler(f, event, ...)
    local handler = f[event]
    if handler then
        handler(f, ...)
    end
end

local values = { 1, 2, 3, 4, 5, 6, 7, 8 }
local function shuffle(n)
    for i = 1, n do
        local j = math.random(i, #values)
        values[i], values[j] = values[j], values[i]
    end
end

function frame:RAID_TARGET_UPDATE()
    if GetRaidTargetIndex "player" and UnitInParty "player" then
        SetRaidTarget("player", 0)
        if MarkSilencerDB.mbea then
            local n = GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE)
            shuffle(n)
            for i = 1, n do
                SetRaidTarget("party" .. i, values[i])
            end
        end
    end
end

function frame:ADDON_LOADED(name)
    if name == add_on_name then
        self:InitOp()
    end
end

frame:SetScript("OnEvent", event_handler)
frame:RegisterEvent "RAID_TARGET_UPDATE"
frame:RegisterEvent "ADDON_LOADED"

function frame:InitOp()
    MarkSilencerDB = MarkSilencerDB or { mbea = false }
    self.panel = CreateFrame "Frame"
    self.panel.name = add_on_name

    local check_button = CreateFrame("CheckButton", nil, self.panel, "UICheckButtonTemplate")
    check_button:SetPoint("TOPLEFT", 20, -20)
    check_button:SetChecked(MarkSilencerDB.mbea)
    check_button.Text:SetText "Mark back'em all!"
    check_button:HookScript("OnClick", function()
        frame:EnableMBEA(check_button:GetChecked())
    end)

    local cat = Settings.RegisterCanvasLayoutCategory(self.panel, self.panel.name, self.panel.name)
    cat.ID = self.panel.name
    Settings.RegisterAddOnCategory(cat)
    self.panel.mbea = check_button
    self:Notify()
end

function frame:EnableMBEA(enabled)
    MarkSilencerDB.mbea = enabled
    self:RAID_TARGET_UPDATE()
    self:Notify()
end

function frame:Notify()
    print("Mark back'em all is now ", MarkSilencerDB.mbea and "enabled" or "disabled")
end

SLASH_MARKSILENCER1 = "/mb"
SLASH_MARKSILENCER2 = "/mbea"

function SlashCmdList.MARKSILENCER(v)
    frame:EnableMBEA(v ~= "" or not MarkSilencerDB.mbea)
    frame.panel.mbea:SetChecked(MarkSilencerDB.mbea)
end
