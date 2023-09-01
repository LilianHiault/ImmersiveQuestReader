-- Quest Manager

import "EsyIQR.ImmersiveQuestReader.QuestDatabase"


QuestManager = class();

function QuestManager:Constructor()
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
        if DEBUG then Turbine.Shell.WriteLine("IQR.QuestManager> New quest found") end
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
function QuestManager:GetQuestTextFromName(questName)
    for _, database in pairs(self.questsByLevel) do
        for _, quest in pairs(database) do
            -- if quest.name then Turbine.Shell.WriteLine("IQR.QuestManager> Quest searched: '" .. quest.name .. "'") end
            if quest.name == questName then
                if DEBUG then Turbine.Shell.WriteLine("IQR.QuestManager> Quest found: '" .. quest.name .. "'") end
                return quest -- Retourne la quête si le nom correspond
            end
        end
    end
    return nil -- Retourne nil si la quête n'est pas trouvée
end
