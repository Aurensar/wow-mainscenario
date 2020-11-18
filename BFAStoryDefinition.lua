local addonName, MS = ...

local S = MS:GetStringsTable()
MS:Log("Strings table", S)

MS.StoryData["08"] = 
{
    Title = "Battle for Azeroth - Alliance",
    Parts = {
        [10]={
            DisplayNumber = "1",
            Name = "The Story So Far",
            RequirementsMet = function() return true end,
            RecommendationsMet = function() return true end,
            Chapters = {               
                { type = "recap", title=S["bfa-10-title"], button=S["bfa-10-button"],
                  Sections = {
                      {title=S["bfa-10-10-title"],text =S["bfa-10-10-copy"]},
                      {title=S["bfa-10-20-title"],text =S["bfa-10-20-copy"]},
                      --{title=S["bfa-10-30-title"],text =S["bfa-10-30-copy"]},
                      {title=S["bfa-10-40-title"],text =S["bfa-10-40-copy"], cinematic=853},
                      {title=S["bfa-10-50-title"],text =S["bfa-10-50-copy"], link="123"},
                      {title=S["bfa-10-60-title"],text =S["bfa-10-60-copy"], link="465"},
                  }
                }
            },
            IsComplete = function() return MS:IsChapterSkipped(10, 1) end,
        },
        [20]={
            DisplayNumber = "2",
            Name = "The Battle for Lordaeron",
            RequirementsMet = function() return MS.StoryData["08"].Parts[10]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {                
                { type = "recap", name="The Battle of Lordaeron", title="Click here for a recap of the Alliance retaliation against Lordaeron",
                Sections = {
                    {title="Removed Content",text ="This part of the story was available to play during Battle for Azeroth and was "..
                    " removed in patch 9.0.1, the Shadowlands pre-expansion patch."},

                    {title="The Alliance Strikes Back",text ="This part of the story was available to play during Battle for Azeroth and was "..
                    " removed in patch 9.0.1, the Shadowlands pre-expansion patch."},

                    {title="Battle for Azeroth Cinematic Introduction",text ="This part of the story was available to play during Battle for Azeroth and was "..
                    " removed in patch 9.0.1, the Shadowlands pre-expansion patch."},
                   
                }
              }
            },
            IsComplete = function() return MS:IsChapterSkipped(20, 1)end,
        },
    },
}