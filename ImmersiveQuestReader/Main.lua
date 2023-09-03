import "Turbine";
import "EsyIQR.ImmersiveQuestReader.QuestWindow"
import "EsyIQR.ImmersiveQuestReader.QuestManager"

local DEBUG_GLOBAL = false

if DEBUG_GLOBAL then Turbine.Shell.WriteLine("\nIQR> Starting Immersive Quest Reader...") end

QuestWindow = QuestWindow()
QuestManager = QuestManager()


-- Callback when a message is received
Turbine.Chat.Received = function (sender, args)
    if (args.ChatType == Turbine.ChatType.Quest) or (args.ChatType == Turbine.ChatType.Standard) then

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
            local questName = QuestManager:GetNameFromChatMessageCompletedQuest(args.Message)
            if DEBUG_GLOBAL then Turbine.Shell.WriteLine("IQR> Completed '" .. questName .. "'") end
            local quest = QuestManager:GetQuestFromName(questName)
            if quest ~= nil then
                quest = QuestManager:AddQuestStateText(quest, "completed");
                QuestWindow:EnqueueQuest(quest);
                if DEBUG_GLOBAL then Turbine.Shell.WriteLine("IQR> Enqueued " .. quest.name) end
            else
                if DEBUG_GLOBAL then Turbine.Shell.WriteLine("IQR> Quest not found: " .. questName) end
            end
        end

    end
end


-- Turbine.Shell.WriteLine("New Quest: The Keeper Garthamendir")
-- Turbine.Shell.WriteLine("Completed:\nCanvas of Defiance")
