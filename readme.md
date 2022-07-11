# Frostpunkd

Frostpunk is a great game. Really, it is - though it has some pain points, it's a fantastic citybuilder and resource management game that is relentless in its difficulty. 

I didn't expect to beat it on my first, or second, or third try - but what I *did* expect was to be able to foresee trends and events to some degree. Apparently the game developers were of a different mindset, because without either participating in or watching a previous playthrough, there are major events that are unfathomably impactful - and you will have had no opportunity to prepare for it.

The biggest hurdle for my playthroughs of both the original campaign scenario and the extended gamemodes is the fact that you will often find yourself staring at a dead end. And with a game as rapid as this, save scumming is difficult to remember to do - not to mention, there's little chance you'll save *right before* a major event occurs.

Instead of setting yourself a timer to save again every few minutes, may I introduce to you a feature that so many games have available by default - **multiple autosaves**. 

That's right. All this script does is quietly back up your last autosaves so you can return to several-days-ago (in game), instead of midnight of the night before. This becomes especially useful when you find yourself at the end-game in the early mornings, as the autosave effectively gives you mere seconds to correct your trajectory.

## How to Backup

There's no requirement as to *when* you start the script. You can run it mid-run, mid-campaign, and before you start playing. Just open up Powershell and kick off the script and you'll soon find yourself collecting a number of autosaves.

> By default, Frostpunk on Steam will save to the steam cloud location, or STEAM_INSTALL_FOLDER/userdata/###/323190/remote/saves. You'll see the `autosave.save` file in there.

When running the script, there are a few parameters you can enable.

Parameter | Description
--- | ---
$SaveLocation = "" | The aforementioned save location. Leave blank and the script will try to autodetect the right location.
[int]$NumberToKeep = 5 | The number of autosaves to keep, including the 'current' one. (The `autosave.save` file will match the most recent backup so you can start a new game without losing it.)
$SessionName = "auto" | A custom name (any file-compatible chars except the *period* `.`) to group autosaves by. I suggest using the same name as your town if you're doing parallel playthroughs.
[int]$Period = 30 | The number of seconds between checks for a new autosave. It's unlikely you'll need to go faster than 30 seconds.
[switch]$Verbose | Print some extra info.

**Example:**

    PS> Frostpunkd.ps1 -NumberToKeep 10 -SessionName 'Effincold' -Period 60 -Verbose`

Your autosaves will be backed up with the following naming convention: "`SessionName.EpochSeconds.save`". The greater the numerical value, the more recent the save. (You can also use the file's timestamp to gauge which one you want.)

> When you exit the game, make sure you let the script tick over one more time before exiting it to preserve your most recent autosave.

## How to Restore

It isn't the cleanest solution, but you'll have to do this manually. Go to the aforementioned save location and locate your backups - simply rename the save you want to `autosave.save` (or make a copy first). The game is too smart for you just to load in any `.save` you want, so you'll have to replace the current autosave.