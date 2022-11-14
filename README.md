# Random Zombies Full

A mod for Project Zomboid that I started thinking "this will be easy" after forgetting that despite being a software engineer, I haven't touched LUA since the times in which World of Warcraft raiding was Molten Core and never really worked with LUA.

## Mod's Scope

Provide a way to randomize zombies' behaviour given some percentage set up by the user, supporting a night/day schedule.

## Mod's Options

- Start/End time for "night" in different seasons
- Percentage of Zombies being
    - Crawlers
    - Shamblers
    - Fast Shamblers
    - Runners
- Percentage of Zombies being
    - Fragile
    - Average
    - Though
- Percentage of Zombies being smarter (can open doors and have better hearing and sight)
- Ability to specify different percentages for day and night
- Ability to specify the interval at which these checks are run by the mod (increase/decrease CPU load)

## Mod's Logic

- Read/Store options' values on Game/Server start
- Check every X time for Zombies in the scene and apply the ratio

## Server Configuration Block

`[...]` stands for other configuration blocks from other mods or the core values of the game.

In your `serverconfiguration_SandboxVars.lua`:

```
SandboxVars = {
    [...],
    RandomZombiesFull = {
        Frequency = 7500,
        Enable_Day = true,
        Enable_Night = true,
        Enable_Rain = false,
        Summer_Night_Start = 23,
        Summer_Night_End = 6,
        Autumn_Night_Start = 22,
        Autumn_Night_End = 6,
        Winter_Night_Start = 20,
        Winter_Night_End = 6,
        Spring_Night_Start = 22,
        Spring_Night_End = 6,
        Crawler_Day = 5,
        Shambler_Day = 65,
        FastShambler_Day = 25,
        Sprinter_Day = 5,
        Fragile_Day = 30,
        Normal_Day = 50,
        Tough_Day = 20,
        Smart_Day = 5,
        Crawler_Night = 5,
        Shambler_Night = 25,
        FastShambler_Night = 65,
        Sprinter_Night = 5,
        Fragile_Night = 30,
        Normal_Night = 50,
        Tough_Night = 20,
        Smart_Night = 5,
        Crawler_Rain = 5,
        Shambler_Rain = 5,
        FastShambler_Rain = 25,
        Sprinter_Rain = 65,
        Fragile_Rain = 30,
        Normal_Rain = 50,
        Tough_Rain = 20,
        Smart_Rain = 5
    },
    [...]
}
```

## Credits

- [Project Zomboid Tutorials](https://theindiestone.com/forums/index.php?/forum/53-tutorials-resources/)
- [Project Zomboid Wiki - Modding](https://pzwiki.net/wiki/Modding)
- Random Zombies by "belette" - used to understand how to properly distribute the ratio of zombies
- Night Sprinters by "The Illuminati" - used to understand how to manage the time and switch between the different presets