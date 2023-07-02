-- Quest Window

import "Turbine.UI.Lotro";
import "Turbine.Gameplay";
import "EsyIQR.ImmersiveQuestReader.Utils";

QuestWindow = class(Turbine.UI.Lotro.Window);

function QuestWindow:Constructor()
    Turbine.UI.Lotro.Window.Constructor(self);

    local windowWidth = 800;
    local windowHeight = 300;
    local footerHeight = 20;
    local xMargin = 20;
    local yMargin = 20;
    local topMargin = 40;

    self:SetSize(windowWidth, windowHeight);
    
    local screenWidth, screenHeight = Turbine.UI.Display.GetSize();
    local x = (screenWidth - windowWidth) / 2;
    local y = (screenHeight - windowHeight) / 2;
    self:SetPosition(x, y);
    self:SetMouseVisible(true);
    self:SetText("Quest name");
    self:SetVisible(false); -- Hidden by default

    -- ***** Quest information on the left *****
    local questInfoWidth = 200;
    self.questInfo = Turbine.UI.Control();
    self.questInfo:SetParent(self);
    self.questInfo:SetSize(questInfoWidth, windowHeight - topMargin - 2*yMargin - footerHeight);
    self.questInfo:SetPosition(xMargin, topMargin);
    if DEBUG then self.questInfo:SetBackColor(Turbine.UI.Color(0.74,0.29,0.29,0.11)) end;
    self.questInfo:SetVisible(true);
    
    -- Experience
    self.xpLabel = Turbine.UI.Label();
    self.xpLabel:SetParent(self.questInfo);
    self.xpLabel:SetSize(questInfoWidth, self.questInfo:GetHeight()/5);
    self.xpLabel:SetPosition(0, 0);
    if DEBUG then self.xpLabel:SetBackColor(Turbine.UI.Color(0.74,0.22,0.52,0.56)) end;
    self.xpLabel:SetFont(Turbine.UI.Lotro.Font.TrajanPro16);
    self.xpLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
    self.xpLabel:SetText("0 XP");

    -- Gold
    self.rewardsLabel = Turbine.UI.Label();
    self.rewardsLabel:SetParent(self.questInfo);
    self.rewardsLabel:SetSize(questInfoWidth, self.questInfo:GetHeight()/5);
    self.rewardsLabel:SetPosition(0, self.xpLabel:GetTop() + self.xpLabel:GetHeight());
    if DEBUG then self.rewardsLabel:SetBackColor(Turbine.UI.Color(0.74,0.56,0.22,0.24)) end;
    self.rewardsLabel:SetFont(Turbine.UI.Lotro.Font.TrajanPro16);
    self.rewardsLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
    self.rewardsLabel:SetText("0 Gold 0 Silver 0 Copper");


    -- Objects
    self.objectsControl = Turbine.UI.Control();
    self.objectsControl:SetParent(self.questInfo);
    self.objectsControl:SetSize(questInfoWidth, self.questInfo:GetHeight()*3/5);
    self.objectsControl:SetPosition(0, self.rewardsLabel:GetTop() + self.rewardsLabel:GetHeight());
    if DEBUG then self.objectsControl:SetBackColor(Turbine.UI.Color(0.74,0.21,0.27,0.57)) end;


    -- Object reward label
    self.itemRewardLabel = Turbine.UI.Label();
    self.itemRewardLabel:SetParent(self.objectsControl);
    self.itemRewardLabel:SetSize(questInfoWidth, self.objectsControl:GetHeight()/8);
    self.itemRewardLabel:SetPosition(0, 0);
    self.itemRewardLabel:SetFont(Turbine.UI.Lotro.Font.TrajanPro16);
    self.itemRewardLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
    self.itemRewardLabel:SetText("Rewards: ");
    if DEBUG then self.itemRewardLabel:SetBackColor(Turbine.UI.Color(0.74,0.27,0.34,0.12)) end;

    -- Object reward control
    self.itemRewardControl = Turbine.UI.Control();
    self.itemRewardControl:SetParent(self.objectsControl);
    self.itemRewardControl:SetSize(questInfoWidth, self.objectsControl:GetHeight()*3/8);
    self.itemRewardControl:SetPosition(0, self.itemRewardLabel:GetTop() + self.itemRewardLabel:GetHeight());
    if DEBUG then self.itemRewardControl:SetBackColor(Turbine.UI.Color(0.74,0.57,0.21,0.49)) end;


    -- Object choice label
    self.choiceLabel = Turbine.UI.Label();
    self.choiceLabel:SetParent(self.objectsControl);
    self.choiceLabel:SetSize(questInfoWidth, self.objectsControl:GetHeight()/8);
    self.choiceLabel:SetPosition(0, self.itemRewardControl:GetTop() + self.itemRewardControl:GetHeight());
    self.choiceLabel:SetFont(Turbine.UI.Lotro.Font.TrajanPro16);
    self.choiceLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
    self.choiceLabel:SetText("Choice: ");
    if DEBUG then self.choiceLabel:SetBackColor(Turbine.UI.Color(0.74,0.37,0.2,0.2)) end;

    -- Object choice control
    self.itemChoiceControl = Turbine.UI.Control();
    self.itemChoiceControl:SetParent(self.objectsControl);
    self.itemChoiceControl:SetSize(questInfoWidth, self.objectsControl:GetHeight()*3/8);
    self.itemChoiceControl:SetPosition(0, self.choiceLabel:GetTop() + self.choiceLabel:GetHeight());
    if DEBUG then self.itemChoiceControl:SetBackColor(Turbine.UI.Color(0.74,0.29,0.77,0.63)) end;



    -- *** Text of the quest ***
    self.titleLabel = Turbine.UI.Label();
    self.titleLabel:SetParent(self);
    self.titleLabel:SetSize(windowWidth - self.questInfo:GetLeft() - self.questInfo:GetWidth() - 2*xMargin, windowHeight - footerHeight - topMargin - 2*yMargin);
    self.titleLabel:SetPosition(self.questInfo:GetLeft() + self.questInfo:GetWidth() + xMargin, topMargin);
    self.titleLabel:SetFont(Turbine.UI.Lotro.Font.BookAntiqua24);
    self.titleLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
    if DEBUG then self.titleLabel:SetBackColor(Turbine.UI.Color(0.74,0.11,0.17,0.29)) end;
    self.titleLabel:SetText("0 - Quest Name (1/1)");
    self.titleLabel:SetVisible(true);
    

    -- Player (needed for their name)
    self.player = Turbine.Gameplay.LocalPlayer:GetInstance();
    
    self.questQueue = {};
    self.questQueueIndex = 1;
    -- Current quest displayed
    self.quest = nil;
    -- Table of lines of the quest text
    self.questPages = {};
    -- Current index in the table of lines
    self.currentPage = 1;
    
    
    -- Can click on the text to advance
    self.titleLabel.MouseUp = function(sender, args)
        if self.currentPage < #self.questPages then
            -- Display next page
            self.currentPage = self.currentPage + 1;
            self:UpdateQuestText();
            self:UpdateFooterText();
        else
            self.questPages = {};
            self.currentPage = 1;
            self:ShowNextQuestInQueueIfExists();
        end    
    end


    -- ***** Footer *****
    self.footer = Turbine.UI.Control();
    self.footer:SetParent(self);
    self.footer:SetSize(windowWidth - 2*xMargin, footerHeight);
    self.footer:SetPosition(xMargin, windowHeight - footerHeight - yMargin);
    if DEBUG then self.footer:SetBackColor(Turbine.UI.Color(0.95,0.05,0,0.05)) end;

    -- Number of pages
    self.pageNumber = Turbine.UI.Label();
    self.pageNumber:SetParent(self.footer);
    self.pageNumber:SetSize(self.footer:GetWidth()/2, footerHeight);
    self.pageNumber:SetPosition(self.footer:GetWidth()/2, 0);
    if DEBUG then self.pageNumber:SetBackColor(Turbine.UI.Color(0.74,0.11,0.29,0.16)) end;
    self.pageNumber:SetFont(Turbine.UI.Lotro.Font.BookAntiqua18);
    self.pageNumber:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight);
    self.pageNumber:SetText("Quest Name - 1/1");

    -- NPC bestower name
    self.npcLabel = Turbine.UI.Label();
    self.npcLabel:SetParent(self.footer);
    self.npcLabel:SetSize(self.footer:GetWidth()/2, footerHeight);
    self.npcLabel:SetPosition(0, 0);
    if DEBUG then self.npcLabel:SetBackColor(Turbine.UI.Color(0.74,0.32,0.22,0.56)) end;
    self.npcLabel:SetFont(Turbine.UI.Lotro.Font.BookAntiqua18);
    self.npcLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
    self.npcLabel:SetText("From NPC Name");
    




    -- Hide the window when the UI is hidden    
    self:SetWantsKeyEvents(true);
    self.KeyDown = function(sender, args)
        if (args.Action == Turbine.UI.Lotro.Action.Escape) then
            self:SetVisible(false);
        elseif (args.Action == 268435635) then
            self:SetVisible(not self:IsVisible());
        end
    end

end

function QuestWindow:EnqueueQuest(quest, state)
    self.questQueue[#self.questQueue + 1] = {quest, state};
    Turbine.Shell.WriteLine("IQR.QuestWindow> Quest " .. quest.name .." added to the queue");
    
    if not self:IsVisible() then
        self.quest = quest;
        self:ShowQuest();
    end
    self:UpdateWindowTitle(); -- To update the number of quests in the queue
end

function QuestWindow:ShowQuest()

    local state = self.questQueue[self.questQueueIndex].state;
    local questText = "";
    if state ~= nil and state == "completed" then
        if DEBUG then Turbine.Shell.WriteLine("IQR> Quest completed") end;
    else
        if self.quest.bestower.text ~= nil and type(self.quest.bestower.text) == "string" then
            questText = self.quest.bestower.text;
        else
            questText = self.quest.bestower[1].text;
        end

    end        
    questText = self:ComputeQuestText(questText);

    -- Split the text in a table of lines
    for line in string.gmatch(questText, "[^ '\n][^.!?\n]+[.!?]*") do
        -- [^\n]+ Matches everything except new line 
        -- [^ '\n][^.!?\n]+[.!?]* Does not start with a space or a quote then match any character except .!? and new line one or more times then match .!? zero or more times to include them at the end of the line.
        if line ~= "" then
            table.insert(self.questPages, line);
        end
    end


    self:SetVisible(true);
    self:UpdateWindow();
end

function QuestWindow:UpdateWindowTitle()
    if #self.questQueue > 1 then
        self:SetText(self.quest.level .. " - " .. self.quest.name .. " (" .. self.questQueueIndex .. "/" .. #self.questQueue .. ")");
    else
        self:SetText(self.quest.level .. " - " .. self.quest.name);
    end
end


function QuestWindow:UpdateQuestText()
    self.titleLabel:SetText(self.questPages[self.currentPage]);
end

function QuestWindow:ComputeQuestText(questText)
    local questTextComputed = string.gsub(questText, "${PLAYER}", self.player:GetName());
    questTextComputed = string.gsub(questTextComputed, "${RACE}", self.player:GetRace()); --outputs a number :c
    return questTextComputed;
end


function QuestWindow:UpdateFooterText()
    self.pageNumber:SetText(self.quest.name .. " - " .. self.currentPage .. "/" .. #self.questPages);
    self.npcLabel:SetText("From " .. self.quest.bestower.npcName);
end

function QuestWindow:UpdateInfo()
    Turbine.Shell.WriteLine("IQR.QuestWindow> UpdateInfo " .. self.quest.name);
    self.xpLabel:SetText(tostring(self.quest.rewards.XP.quantity) .. " XP");
    if self.quest.rewards.money then
        self.rewardsLabel:SetText(tostring(self.quest.rewards.money.gold) .. " Gold " .. tostring(self.quest.rewards.money.silver) .. " Silver " .. tostring(self.quest.rewards.money.copper) .. " Copper");
    else
        self.rewardsLabel:SetText("0 Gold 0 Silver 0 Copper");
    end
    
    if self.quest.rewards.object then
        -- if DEBUG then Turbine.Shell.WriteLine("IQR.QuestWindow> Item Reward") end;
        self:AddItemsToControl(self.quest.rewards.object, self.itemRewardControl)
    end;
    if self.quest.rewards.selectOneOf and self.quest.rewards.selectOneOf.object then
        -- if DEBUG then Turbine.Shell.WriteLine("IQR.QuestWindow> Item Choice Rewards") end;
        self:AddItemsToControl(self.quest.rewards.selectOneOf.object, self.itemChoiceControl) 
    end;
        
end

function QuestWindow:UpdateWindow()
    self:UpdateWindowTitle();
    self:UpdateQuestText();
    self:UpdateFooterText();
    self:UpdateInfo();
end
    

function QuestWindow:AddItemsToControl(items, control)
    -- Loop through all quest rewards
    local xItem = 0;
    local yItem = 0;

    if items.id and items.name then
        items = {items};
    end
    for key, item in pairs(items) do
        itemInfoControl = NewItemInfo(tonumber(item.id));
        if itemInfoControl then
            itemInfoControl:SetParent(control);
            itemInfoControl:SetPosition(xItem, yItem);
            if item.quantity then 
                Turbine.Shell.WriteLine("IQR.QuestWindow> Item Quantity");
                itemInfoControl:SetQuantity(tonumber(item.quantity)) 
            end
            itemInfoControl:SetVisible(true);
            xItem = xItem + itemInfoControl:GetWidth();
        end
    end
end

function QuestWindow:ShowNextQuestInQueueIfExists()
    if self.questQueueIndex < #self.questQueue then
        -- Display next quest
        self.questQueueIndex = self.questQueueIndex + 1;
        self.quest = self.questQueue[self.questQueueIndex][1];
        Turbine.Shell.WriteLine("IQR.QuestWindow> Next quest in queue : " .. self.quest.name);
        self:ShowQuest(); 
    else
        self:SetVisible(false);
        self.questQueue = {};
        self.questQueueIndex = 1;
    end
end