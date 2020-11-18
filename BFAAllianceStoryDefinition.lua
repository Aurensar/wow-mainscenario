local addonName, MS = ...

MS.StoryData["Alliance08"] = 
{
    Title = "Battle for Azeroth - Alliance",
    Parts = {
        [80101]={
            DisplayNumber = "1",
            Name = "The Story So Far",
            RequirementsMet = function() return true end,
            RecommendationsMet = function() return true end,
            Chapters = {               
                { type = "recap", name="Battle for Azeroth: The Story So Far", title="Click here for a recap of the events leading up to Battle for Azeroth",
                  Sections = {
                      {title="Removed Content",text ="This part of the story was available to play during the Battle for Azeroth pre-patch and was "..
                      " removed when the expansion launched."},
                      {title="The War of Thorns", text ="Seeking a decisive end to the ongoing war with the Alliance, Sylvanas Windrunner, Warchief of the Horde, "..
                      " prepares an attack on Darkshore. Legendary Orc hero High Overlord Varok Saurfang leads the Warchief's armies across Ashenvale.",},
                      {title="The Attack Continues", text ="As the attack progressed into Darkshore, the Horde forces were pushed back time and again by Archdruid Malfurion Stormrage."..
                      "\n\nFinally, Saurfang struck down Malfurion as his back was turned. Considering his attack dishonourable, Saurfang allows Tyrande to carry the "..
                      "injured Malfurion to safety."},
                      {title="The Fate of Teldrassil", text ="The Alliance defenders defeated, Sylvanas approaches the World Tree, Teldrassil...", cinematic="853"},
                      {title="Full Playthrough", text ="Watch the linked video for a full playthrough of the War of Thorns story from the Alliance point of view.", link="123"},
                  }
                }
            },
            IsComplete = function() return MS:IsChapterSkipped(80101, 3) or MS:IsQuestCompleted(47189)  end,
        },
        [80102]={
            DisplayNumber = "2",
            Name = "The Battle of Lordaeron",
            RequirementsMet = function() return true end,
            RecommendationsMet = function() return true end,
            Chapters = {
                
                { type = "recap", text = "Lorem ipsum\nSomething else", name="Recap", }
                --{ type = "external-cinematic", id = 1, url = "https://www.youtube.com/watch?v=aW_h0qf9vpA", name = "Old Soldier"},
                --{ type = "external-cinematic", id = 2, url = "https://www.youtube.com/watch?v=aW_h0qf9vpA", name = "Battle for Azeroth Intro"},
               -- { type = "ingame-cinematic", id = 856, name="Battle for Lordaeron: Turn the Tide"},
               -- { type = "ingame-cinematic", id = 854, name="Lordaeron Throne Room Confrontation - Alliance"},
            },
            IsComplete = function() return MS:IsChapterSkipped(80101, 3) or MS:IsQuestCompleted(47189)  end,
        },
        [80102]={
            DisplayNumber = "2",
            Name = "Come Sail Away",
            RequirementsMet = function() return MS.StoryData["Alliance08"].Parts[80101]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {
                { type = "level", level = 10 },
                { type = "quest", id = 46727, hint="From Hero's Herald in the Stormwind Trade District" },
                { type = "quest", id = 46728 },
                { type = "quest", id = 51341 },
                { type = "quest", id = 47098 },
                { type = "quest", id = 47099 },
                { type = "quest", id = 46729 },
                { type = "quest", id = 47186 },
                { type = "quest", id = 47189 },
                { type = "text", name="Select any zone on the map in the Harbormaster's Office in Boralus Harbor to progress"},
            },
            IsComplete = function() return MS:IsQuestCompleted(47960) or MS:IsQuestCompleted(47961) or MS:IsQuestCompleted(47962) end,
        },
        [80105]={
            DisplayNumber = "3",
            Name = "A Sound Plan",
            RequirementsMet = function() return MS:IsQuestCompleted(47960) end,
            RecommendationsMet = function() return true end,
            Chapters = {
                -- Norwington Festival
                { type = "quest", id = 48070 },
                { type = "quest", id = 48077 },
                { type = "quest", id = 48616 },
                { type = "quest", id = 48080 },
                { type = "quest", id = 48670 },
                { type = "quest", id = 48196 },
                { type = "quest", id = 48195 },
                { type = "quest", id = 48597 },
                { type = "quest", id = 48003 },
                { type = "quest", id = 48005 },
                { type = "quest", id = 48004 },
                { type = "quest", id = 48939 },
                { type = "quest", id = 48087 },
                { type = "quest", id = 48088 },
                { type = "quest", id = 48089 },

            },
            IsComplete = function() return MS:IsQuestCompleted(48089) end,
        },
        [80106]={
            DisplayNumber = "4",
            Name = "Drustvar",
            RequirementsMet = function() return MS:IsQuestCompleted(47961) end,
            RecommendationsMet = function() return true end,
            Chapters = {
                { type = "quest", id = 48 },
            },
            IsComplete = function() return true end,
        },
        [80107]={
            DisplayNumber = "5",
            Name = "Stormsong Valley",
            RequirementsMet = function() return MS:IsQuestCompleted(47962) end,
            RecommendationsMet = function() return true end,
            Chapters = {
                { type = "quest", id = 48 },
            },
            IsComplete = function() return true end,
        },




        [82010]={
            DisplayNumber = "100",
            Name = "The Eternal Palace",
            RequirementsMet = function() return true end,
            RecommendationsMet = function() return MS:IsQuestCompleted(56325) end,
            Chapters = {
                { type = "quest-accept", id = 56358 },
                { type = "raid", name = "The Eternal Palace", final="Queen Azshara", achId=13725 },
                { type = "quest", id = 56358 },
            },
            IsComplete = function() return MS:IsQuestCompleted(56358) end,
        },
        [82020]={
            DisplayNumber = "100",
            Name = "Empowering the Heart I",
            RequirementsMet = function() return true end,
            RecommendationsMet = function() return MS.StoryData["Alliance08"].Parts[82010]:IsComplete() end,
            Chapters = {
                { type = "quest", id = 55519 },
                { type = "quest", id = 55520 },
                { type = "quest", id = 55521 },
            },
            IsComplete = function() return MS:IsQuestCompleted(55521) end,
        },
        [82021]={
            DisplayNumber = "100",
            Name = "Empowering the Heart II",
            RequirementsMet = function() return MS.StoryData["Alliance08"].Parts[82020]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {
                { type = "quest", id = 55732 },
                { type = "quest", id = 55735 },
                { type = "quest", id = 55737 },
            },
            IsComplete = function() return MS:IsQuestCompleted(55737) end,
        },
        [82022]={
            DisplayNumber = "100",
            Name = "Empowering the Heart III",
            RequirementsMet = function() return MS.StoryData["Alliance08"].Parts[82021]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {
                { type = "quest", id = 56401 },
                { type = "quest", id = 55752 },
            },
            IsComplete = function() return MS:IsQuestCompleted(55752) end,
        },
        [82501]={
            DisplayNumber = "101",
            Name = "Breaking the Cycle",
            RequirementsMet = function() return true end,
            RecommendationsMet = function() return MS.StoryData["Alliance08"].Parts[82010]:IsComplete() end,
            Chapters = {
                { type = "quest", id = 56494 },
                { type = "ingame-cinematic", id = 903, name = "The Negotiation"},
                { type = "quest", id = 56719 },
                { type = "quest", id = 56979 },
                { type = "quest", id = 56980 },
                { type = "quest", id = 56981 },
                { type = "quest", id = 56982 },
                { type = "quest", id = 56993 },
                { type = "quest", id = 57002 },
                { type = "quest", id = 57126 },
            },
            IsComplete = function() return MS:IsQuestCompleted(57126) end,
        },
        [82502]={
            DisplayNumber = "102",
            Name = "On the Trail of the Black Prince",
            RequirementsMet = function() return true end,
            RecommendationsMet = function() return MS.StoryData["Alliance08"].Parts[82501]:IsComplete() end,
            Chapters = {
                { type = "removed-quest", id = 56185 },
                { type = "removed-quest", id = 56186 },
                { type = "removed-quest", id = 56187 },
                { type = "removed-quest", id = 56188 },
                { type = "removed-quest", id = 56189 },
                { type = "removed-quest", id = 56190 },
                { type = "removed-quest", id = 56504 },
                { type = "removed-content-recap", url = "https://www.youtube.com/watch?v=CaQPm-38Z-A", name = "On the Trail of the Black Prince"},
            },
            IsComplete = function() return MS:IsChapterSkipped(82502, 8) end,
        },
        [83001]={
            DisplayNumber = "103",
            Name = "Return of the Black Prince",
            RequirementsMet = function() return true end,
            RecommendationsMet = function() return MS.StoryData["Alliance08"].Parts[82502]:IsComplete() and
                                                   MS.StoryData["Alliance08"].Parts[82022]:IsComplete() end,
            Chapters = {
                { type = "quest", id = 58496 },
                { type = "quest", id = 58498 },
                { type = "quest", id = 58502 },
                { type = "quest", id = 58506 },
            },
            IsComplete = function() return MS:IsQuestCompleted(58506) end,
        },
        [83002]={
            DisplayNumber = "104",
            Name = "Sail with the Tide",
            RequirementsMet = function() return MS.StoryData["Alliance08"].Parts[82501]:IsComplete() end,
            RecommendationsMet = function() return MS.StoryData["Alliance08"].Parts[82502]:IsComplete() end,
            Chapters = {
                { type = "quest", id = 57324 },
            },
            IsComplete = function() return MS:IsQuestCompleted(57324) end,
        },
        [83003]={
            DisplayNumber = "105",
            Name = "The Forge of Origination",
            RequirementsMet = function() return MS.StoryData["Alliance08"].Parts[83001]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {
                { type = "quest", id = 56374 criteria="" },
                { type = "quest", id = 56209 },
                { type = "quest", id = 56375 },
                { type = "quest", id = 56472 },
                { type = "quest", id = 56376 },
                { type = "quest", id = 56377 },
            },
            IsComplete = function() return MS:IsQuestCompleted(56377) end,
        },
        [83004]={
            DisplayNumber = "106",
            Name = "The Engine of Nalak'sha",
            RequirementsMet = function() return MS.StoryData["Alliance08"].Parts[83003]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {
                { type = "quest", id = 56536 },
                { type = "quest", id = 56537 },
                { type = "quest", id = 56538 },
                { type = "quest", id = 56539 },
                { type = "quest", id = 56771 },
                { type = "quest", id = 56540 },
                { type = "quest", id = 56541 },
                { type = "quest", id = 56542 },
                { type = "quest", id = 58737 },
            },
            IsComplete = function() return MS:IsQuestCompleted(58737) end,
        },
        [83005]={
            DisplayNumber = "107",
            Name = "Through the Darkness",
            RequirementsMet = function() return MS.StoryData["Alliance08"].Parts[83004]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {
                { type = "quest", id = 57220 },
                { type = "quest", id = 57221 },
                { type = "quest", id = 57222 },
                { type = "quest", id = 57290 },
                { type = "quest", id = 57362 },
                { type = "quest", id = 57373 },
                { type = "quest", id = 58634 },
                { type = "quest", id = 57374 },
            },
            IsComplete = function() return MS:IsQuestCompleted(57374) end,
        },
        [83006]={
            DisplayNumber = "107",
            Name = "Whispers in the Dark",
            RequirementsMet = function() return MS.StoryData["Alliance08"].Parts[83005]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {
                { type = "quest", id = 58615 },
                { type = "quest", id = 58631 },           
            },
            IsComplete = function() return MS:IsQuestCompleted(58631) end,
        },
        [83007]={
            DisplayNumber = "108",
            Name = "Titanic Research",
            RequirementsMet = function() return MS.StoryData["Alliance08"].Parts[83006]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {
                { type = "quest", id = 57524 },           
            },
            IsComplete = function() return MS:IsQuestCompleted(57524) end,
        },
        [83008]={
            DisplayNumber = "109",
            Name = "Ny'alotha, the Waking City",
            RequirementsMet = function() return MS.StoryData["Alliance08"].Parts[83006]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {
                { type = "quest-accept", id = 58632 },
                { type = "raid", name = "Ny'alotha, the Waking City", final="N'Zoth the Corruptor", achId=14196 },
                { type = "quest", id = 58632 },         
            },
            IsComplete = function() return MS:IsQuestCompleted(58632) end,
        },
        -- [83009]={
        --     DisplayNumber = "108",
        --     Name = "Mystery of the Amathet",
        --     RequirementsMet = function() return MS.StoryData["Alliance08"].Parts[83006]:IsComplete() end,
        --     RecommendationsMet = function() return true end,
        --     Chapters = {
        --         { type = "quest", id = 58636 },
        --         { type = "quest", id = 58638 }, 
        --         { type = "quest", id = 58639 },   
        --         { type = "quest", id = 58646 },   
        --         { type = "quest", id = 58640 },   
        --         { type = "quest", id = 58641 },   
        --         { type = "quest", id = 58642 },   
        --         { type = "quest", id = 58643 },   
        --         { type = "quest", id = 58645 },                      
        --     },
        --     IsComplete = function() return MS:IsQuestCompleted(58645) end,
        -- },
        [83010]={
            DisplayNumber = "109",
            Name = "The Price of Peace",
            RequirementsMet = function() return true end,
            RecommendationsMet = function() return MS.StoryData["Alliance08"].Parts[83008]:IsComplete()  end,
            Chapters = {
                { type = "removed-content-recap", url = "https://www.youtube.com/watch?v=Jds8qXSKIP8", name = "The Price of Peace"},     
            },
            IsComplete = function() return MS:IsChapterSkipped(83010, 1) end,
        },
        [83701]={
            DisplayNumber = "150",
            Name = "Epilogue: An Uncertain Fate",
            RequirementsMet = function() return true end,
            RecommendationsMet = function() return MS.StoryData["Alliance08"].Parts[83008]:IsComplete() end,
            Chapters = {
                { type = "quest", id = 60113 },
                { type = "quest", id = 60116 },
                { type = "ingame-cinematic", id = 60117, name="Lich King update" },
                { type = "quest", id = 60117 },
                { type = "quest", id = 59876 },
                { type = "quest", id = 60766 },
                { type = "quest", id = 60767 },
                --{ type = "quest", id = 61486 }, --The Banshee's Champion
                { type = "quest", id = 59877 },
                { type = "quest", id = 60169 },
                { type = "quest", id = 60003 },
                { type = "quest", id = 62157 },
                { type = "quest", id = 60827 },
            },
            IsComplete = function() return MS:IsQuestCompleted(60827) end,
        },
    },
}