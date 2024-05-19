package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;
import states.FreePlaySongState;
import flixel.math.FlxMath;

class FreeplayState extends MusicBeatState
{

	private var iconArray:Array<HealthIcon> = [];
	private var curSelected:Int = 0;
	var bg:FlxSprite;

	// --------------- new Stuff ------------------ (I hate myself);
	public var freePlayMods:Array<String> = [
		"Main",
		"Bonus"
	];

	public var freePlayModsGroup:FlxTypedGroup<FlxSprite>;
	

	
	override function create()
	{
		#if DISCORD_ALLOWED
			DiscordClient.changePresence("Selecting Free Play Mode", null);
		#end
		
		FlxG.mouse.visible = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();
		

		freePlayModsGroup = new FlxTypedGroup<FlxSprite>();
		add(freePlayModsGroup);
		for (i in 0...freePlayMods.length) {
			var mod:FlxSprite = new FlxSprite(0, -50);
			mod.frames = Paths.getSparrowAtlas('menus/freeplay/FreePlay');
			mod.animation.addByPrefix('idle', freePlayMods[i] + 'Idle');
			mod.animation.addByPrefix('selected', freePlayMods[i] + "Selected");
			mod.scale.x = .6;
			mod.scale.y = .6;
			mod.animation.play('idle');
			switch(freePlayMods[i]) {
				case "Main":
					mod.x = 100;
				
				case "Bonus":
					mod.x = 700;
			}
			freePlayModsGroup.add(mod);
		}


		super.create();
	}


	override function update(elapsed:Float)
	{
		
		mouseControls();
		if (controls.UI_LEFT_P) {
			changeSelection(1);
		}
		else if (controls.UI_RIGHT_P) {
			changeSelection(-1);
		}

		if(controls.ACCEPT) {
			enter();
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if(FlxG.keys.justPressed.CONTROL)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}

		super.update(elapsed);
	}


	function changeSelection(change:Int = 0, mod:String = "default")
	{
		var scaleIn:FlxTween;
		var scaleOut:FlxTween;
		scaleOut = FlxTween.tween(freePlayModsGroup.members[curSelected],
		{"scale.x": .6, "scale.y": .6}, 0.2, 
		{
			type: FlxTweenType.ONESHOT,
			ease: FlxEase.cubeOut
		});
		freePlayModsGroup.members[curSelected].animation.play('idle');
		
		if(mod == "default")
			curSelected += change;
		if(mod == "mouse")
			curSelected = change;

		if (curSelected < 0)
			curSelected = freePlayMods.length - 1;
		if (curSelected >= freePlayMods.length)
			curSelected = 0;
		
		scaleIn = FlxTween.tween(freePlayModsGroup.members[curSelected],
		{"scale.x": .7, "scale.y": .7}, 0.2, 
		{
			type: FlxTweenType.ONESHOT,
			ease: FlxEase.cubeOut
		});
		freePlayModsGroup.members[curSelected].animation.play('selected');
	}


		


	function mouseControls() {
		
		for (i in 0...freePlayModsGroup.length) {
			var hovering:Bool = FlxG.mouse.overlaps(freePlayModsGroup.members[i]);
			if(FlxG.mouse.justMoved) {
				if (i != curSelected) {
					if (hovering)
					{
						changeSelection(i, "mouse");
					}
				}

				
			}
			if(FlxG.mouse.justPressed && hovering) {
				enter();
			}
	
			if(FlxG.mouse.justPressedRight) {
				MusicBeatState.switchState(new MainMenuState());
			}
		}
		
	}


	function enter() {
		FreePlaySongState.curModSelected = curSelected;
		MusicBeatState.switchState(new FreePlaySongState());
	}

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}	
}
