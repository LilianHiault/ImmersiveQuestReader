import "Turbine";
import "EsyIQR.ImmersiveQuestReader.QuestWindow"
import "EsyIQR.ImmersiveQuestReader.QuestManager"

local DEBUG_GLOBAL = false

if DEBUG_GLOBAL then Turbine.Shell.WriteLine("\nIQR> Starting Immersive Quest Reader...") end

QuestWindow = QuestWindow()
QuestManager = QuestManager()


-- Callback when a message is received
Turbine.Chat.Received = function (sender, args)
    if args.ChatType == Turbine.ChatType.Quest then

        -- New quest
        if QuestManager:IsNewQuest(args.Message) then
            local questName = QuestManager:GetNameFromChatMessageNewQuest(args.Message)
            local quest = QuestManager:GetQuestFromName(questName)
            if quest ~= nil then
                QuestManager:AddQuestStateText(quest, "new");
                QuestWindow:EnqueueQuest(quest);
            end

        -- Completed quest
        elseif QuestManager:IsCompletedQuest(args.Message) then
            if DEBUG_GLOBAL then Turbine.Shell.WriteLine("IQR> Completed " .. QuestManager:GetNameFromChatMessageCompletedQuest(args.Message)) end
        end

    end
end



-- local quest
-- quest  = QuestManager:GetQuestFromName("Fate of the Black Rider")
-- if quest ~= nil then
--     local questStateText = QuestManager:GetQuestTextFromState(quest, "new")
--     quest = QuestManager:AddQuestStateText(quest, "new", questStateText)
--     QuestWindow:EnqueueQuest(quest)
-- else
--     Turbine.Shell.WriteLine("IQR> New quest not found")
-- end

-- quest  = QuestManager:GetQuestTextFromName("Untangled Webs")
-- if quest ~= nil then
--     QuestManager:AddQuestState(quest, "new")
--     QuestWindow:EnqueueQuest(quest)
-- else
--     Turbine.Shell.WriteLine("IQR> New quest not found")
-- end


-- quest  = QuestManager:GetQuestFromName("Untangled Webs")
-- if quest ~= nil then
--     local questStateText = QuestManager:GetQuestTextFromState(quest, "completed")
--     quest = QuestManager:AddQuestStateText(quest, "completed", questStateText);
--     QuestWindow:EnqueueQuest(quest);
-- else
--     Turbine.Shell.WriteLine("IQR> Completed quest not found")
-- end
