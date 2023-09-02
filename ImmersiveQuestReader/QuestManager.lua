-- Quest Manager

import "EsyIQR.ImmersiveQuestReader.QuestDatabase"


QuestManager = class();

function QuestManager:Constructor()
    self.DEBUG = false;
    
    -- if QUESTS then self.questsByLevel = QUESTS.quest end -- For testing purposes
    self.questsByLevel = {
        QUESTS_A.quest,
        QUESTS_B.quest,
        QUESTS_C.quest,
        QUESTS_D.quest,
        QUESTS_E.quest,
        QUESTS_F.quest,
        QUESTS_G.quest,
        QUESTS_H.quest,
        QUESTS_I.quest,
        QUESTS_J.quest,
        QUESTS_K.quest,
        QUESTS_L.quest,
        QUESTS_M.quest,
        QUESTS_N.quest,
        QUESTS_O.quest,
        QUESTS_P.quest,
        QUESTS_Q.quest,
        QUESTS_R.quest,
        QUESTS_S.quest,
        QUESTS_T.quest,
        QUESTS_U.quest,
        QUESTS_V.quest,
        QUESTS_W.quest,
        QUESTS_X.quest,
        QUESTS_Y.quest,
        QUESTS_Z.quest,
        QUESTS_OTHER.quest
    }
end

function QuestManager:IsNewQuest(chatMessage)
    if string.find(chatMessage, "New Quest: ") then
        if self.DEBUG then Turbine.Shell.WriteLine("IQR.QuestManager> New quest found") end
        return true
    else
        return false
    end
end

function QuestManager:IsCompletedQuest(chatMessage)
    if string.find(chatMessage, "Completed:") then
        return true
    else
        return false
    end
end

function QuestManager:GetNameFromChatMessageNewQuest(chatMessage)
    return string.sub(chatMessage, 12);
end

function QuestManager:GetNameFromChatMessageCompletedQuest(chatMessage)
    return string.sub(chatMessage, 12);
end

-- Returns the quest text for a given quest name
function QuestManager:GetQuestFromName(questName)
    for _, database in pairs(self.questsByLevel) do
        for _, quest in pairs(database) do
            -- if quest.name then Turbine.Shell.WriteLine("IQR.QuestManager> Quest searched: '" .. quest.name .. "'") end
            if quest.name == questName then
                if self.DEBUG then Turbine.Shell.WriteLine("IQR.QuestManager> Quest found: '" .. quest.name .. "'") end
                return quest -- Retourne la quête si le nom correspond
            end
        end
    end
    return nil -- Retourne nil si la quête n'est pas trouvée
end

-- Add the quest text and state to the quest as _text and _state
-- @param quest: a quest table
-- @param state: "new" or "completed"
-- @param questText: the quest text
function QuestManager:AddQuestStateText(quest, state, questText)
    if state == "new" or state == "completed" then
        quest._state = state
    else
        quest._state = nil
    end

    if questText then
        quest._text = questText;
    end

    return quest;
end

function QuestManager:GetQuestTextFromState(quest, state)
    local questText = "";
    if self.DEBUG then Turbine.Shell.WriteLine("IQR.QuestManager> Showing quest " .. quest.name .. " (" .. state .. ")") end;

    if state ~= nil and state == "completed" then
        local objectives = quest.objectives;
        if objectives.objective.dialog then
            questText = objectives.objective.dialog.text;
        elseif objectives.objective[#objectives.objective].dialog.text then
            questText = objectives.objective[#objectives.objective].dialog.text;
        elseif objectives.objective[#objectives.objective].dialog[#objectives.objective[#objectives.objective].dialog] then
            questText = objectives.objective[#objectives.objective].dialog[#objectives.objective[#objectives.objective].dialog].text;
        else
            questText = "Could not retrieve quest text";
            if self.DEBUG then Turbine.Shell.WriteLine("IQR.QuestWindow> Can't find quest text") end;
        end

    elseif state ~= nil and state == "new" then
        if quest.bestower.text ~= nil and type(quest.bestower.text) == "string" then
            questText = quest.bestower.text;
        else
            questText = quest.bestower[1].text;
        end
    else
        if self.DEBUG then Turbine.Shell.WriteLine("IQR.QuestWindow> Quest state is " .. state) end;
        questText = "Could not retrieve quest text";
    end
   
    if self.DEBUG then Turbine.Shell.WriteLine("IQR.QuestManager> Quest text: " .. questText) end
    return questText;
end
