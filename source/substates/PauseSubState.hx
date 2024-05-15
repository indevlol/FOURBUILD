package substates;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import states.PlayState;
import flixel.FlxObject;
import backend.Section;
import flixel.group.FlxContainer;

import flixel.addons.transition.FlxTransitionableState;

import flixel.util.FlxStringUtil;

import states.StoryMenuState;
import states.FreeplayState;
import options.OptionsState;

class PauseSubState extends MusicBeatSubstate
{

	var menuItemsOG:Array<String> = ['Play', 'Restart Song', 'Options', 'Exit to menu'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);

	var Y = 100;
	var menuItems:FlxTypedGroup<FlxSprite>;
	var pauseCam:FlxCamera;

	public static var songName:String = null;

	override function create()
	{
	
		pauseCam = new FlxCamera();
		pauseCam.bgColor.alphaFloat = 0.5;
		FlxG.cameras.add(pauseCam, false);
		menuItems = new FlxTypedGroup<FlxSprite>();
		menuItems.cameras = [pauseCam];
		add(menuItems);
		for (i in 0...menuItemsOG.length) {
			Y += 100;
			var menuItem:FlxSprite = new FlxSprite(500, Y);
			menuItem.frames = Paths.getSparrowAtlas('uipause/PauseMenuButtons');
			menuItem.animation.addByPrefix('idle', menuItemsOG[i] + 'Idle');
			menuItem.animation.addByPrefix('selected', menuItemsOG[i] + 'Selected');
			menuItems.add(menuItem);
			menuItem.animation.play('idle');
			
		}
		super.create();
	}
	
	function getPauseSong()
	{
		var formattedSongName:String = (songName != null ? Paths.formatToSongPath(songName) : '');
		var formattedPauseMusic:String = Paths.formatToSongPath(ClientPrefs.data.pauseMusic);
		if(formattedSongName == 'none' || (formattedSongName != 'none' && formattedPauseMusic == 'none')) return null;

		return (formattedSongName != '') ? formattedSongName : formattedPauseMusic;
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		mouse();
		super.update(elapsed);

		if(controls.BACK)
		{
			close();
			pauseCam.bgColor.alphaFloat = 0;
			return;
		}

		updateSkipTextStuff();
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		var daSelected:String = menuItemsOG[curSelected];

		if (controls.ACCEPT || FlxG.mouse.justPressed && (cantUnpause <= 0 || !controls.controllerMode))
		{
			
			switch (daSelected)
			{
				case "Play":
					close();
					pauseCam.bgColor.alphaFloat = 0;

				case "Restart Song":
					restartSong();
				case 'Options':
					PlayState.instance.paused = true; // For lua
					PlayState.instance.vocals.volume = 0;
					MusicBeatState.switchState(new OptionsState());
					OptionsState.onPlayState = true;
				case "Exit to menu":
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					Mods.loadTopMod();
					if(PlayState.isStoryMode)
						MusicBeatState.switchState(new StoryMenuState());
					else 
						MusicBeatState.switchState(new FreeplayState());

					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
					FlxG.camera.followLerp = 0;
			}
		}
	}


	function mouse() {
		var hovering:Bool = false; // Flag to track if the mouse is hovering over any menu item
		
		if(FlxG.mouse.justMoved) {
			// Iterate through each menu item
			for (i in 0...menuItems.length)
				{
					menuItems.members[i].updateHitbox();
				if (i != curSelected)
				{
					if (FlxG.mouse.overlaps(menuItems.members[i]))
					{
						hovering = true;
						changeSelection(i, "mouse");
					}
				}

				
			}
		}

		if(FlxG.mouse.justPressedRight) {
			close();
			pauseCam.bgColor.alphaFloat = 0;
		}
		
	}

	function deleteSkipTimeText()
	{
		if(skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		MusicBeatState.resetState();
	}


	function changeSelection(change:Int = 0, mode:String = "default"):Void
	{
		menuItems.members[curSelected].animation.play('idle');
		if(mode == "default")
			curSelected += change;
		else if (mode == "mouse")
			curSelected = change;
		else
			mode = "default";
		
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;
		menuItems.members[curSelected].animation.play('selected');
	}

	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}
