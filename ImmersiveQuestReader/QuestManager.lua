-- Quest Manager

import "EsyIQR.ImmersiveQuestReader.QuestDatabase"


QuestManager = class();

function QuestManager:Constructor()
    self.DEBUG = true;
    
    self.questsByLevel = QUEST_DATABASE
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
    -- local firstCharacter = string.sub(questName, 1, 1);
    for _, database in pairs(self.questsByLevel) do
        for _, quest in pairs(database) do
            if quest.name == questName then
                if self.DEBUG then Turbine.Shell.WriteLine("IQR.QuestManager> Quest found: '" .. quest.name .. "'") end
                return quest -- Return the quest if the name matches
            end
        end
    end
    return nil -- Return nil if the quest is not found
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
