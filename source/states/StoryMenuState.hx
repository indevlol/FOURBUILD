package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import flixel.FlxObject;

import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;

import objects.MenuItem;
import objects.MenuCharacter;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();


	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;


	private static var curWeek:Int = 0;



	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var loadedWeeks:Array<WeekData> = [];
	var youtube:FlxSprite;
	var videos:FlxTypedGroup<FlxSprite>;
	var camFollow:FlxObject;
	override function create()
	{
		FlxG.camera.bgColor = FlxColor.fromRGB(15, 15, 15);
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;
		
		FlxG.mouse.visible = true;
		youtube = new FlxSprite().loadGraphic(Paths.image('menus/story/Youtube'));
		youtube.antialiasing = ClientPrefs.data.antialiasing;
		youtube.scale.x = 1.13;
		youtube.scale.y = 1.13;
		youtube.setGraphicSize(Std.int(youtube.width * 1.175));
		youtube.updateHitbox();
		add(youtube);
		youtube.screenCenter();
		
		
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();
		add(camFollow);


		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');




		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);


		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Selecting The Video", null);
		#end

		var num:Int = 0;
		var x:Int = -1000;
		videos = new FlxTypedGroup<FlxSprite>();
		add(videos);
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);


				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite(10, 10);
					lock.antialiasing = ClientPrefs.data.antialiasing;
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					grpLocks.add(lock);
				}
				num++;
			}
			
			trace(weekFile.weekName);
			x += 500;
			var video:FlxSprite = new FlxSprite(x, 50).loadGraphic(Paths.image('menus/story/thumbnails/PLACEHOLDER'));
			video.scale.x = 0.2;
			video.scale.y = 0.2;
			videos.add(video);
		
		}

		for(i in 0...videos.length) {
			if(i % 2 == 0 && i != 0) {
				var newIndex = 0;
				newIndex = i + 1;
	
				for(j in newIndex - 1...newIndex + 1) {
					

					/**
					 *	so I need to hmm huh..
					 	2 - x = 0 / 1
						2 - 2 = 0
						2 - 1 = 1
						j - 
					 	j - (j - j)
						for(k in 0...j) {
							trace(k);
							if j == 2
								0
								1
							if j == 3
								0
								1
								2
						}
						 
					 */


					/**
					 * if j == 2
					 * 2 - 1
					 * huh...
					 * OMG I hate this *Cries*
					 * **I hate myself**
					 * Whoever is reading this have a good day/night/afternoon/
					 * 
					 * LEETTS GOOOO 
					*/
					for(k in 0...j - 1) {
						trace(k);
						videos.members[j].x = (videos.members[0].x + (500 * k)) ;
					}
					videos.members[j].y = (videos.members[0].y + 50) * newIndex;
					trace(" x -> " + videos.members[j].x + " y -> " + videos.members[j].y);
				}
			}
		}
		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		var charArray:Array<String> = loadedWeeks[0].weekCharacters;


		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(0, 0);
		leftArrow.scale.x = (FlxG.width / 2) - (leftArrow.width / 2);
		leftArrow.scale.y = 100;
		leftArrow.angle = 45;
		leftArrow.antialiasing = ClientPrefs.data.antialiasing;
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		Difficulty.resetList();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = Difficulty.getDefault();
		}
		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
		
		sprDifficulty = new FlxSprite(leftArrow.x, leftArrow.y + 30);
		sprDifficulty.antialiasing = ClientPrefs.data.antialiasing;
		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(leftArrow.x, leftArrow.y + 70);
		rightArrow.antialiasing = ClientPrefs.data.antialiasing;
		rightArrow.angle = -45;
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);


		// add(rankText);

		changeWeek();
		changeDifficulty();

		super.create();
		FlxG.camera.follow(camFollow, null, 9);
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 30)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

	
		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			var allowedDif:Bool = false;

			// < 359.5
			// > 859.5
			if (upP)
			{
				if(camFollow.y > 359.5) {
					camFollow.setPosition(camFollow.x, camFollow.y - 500);
				}
			}

			if (downP)
			{
				if(camFollow.y < 859.5) {
					camFollow.setPosition(camFollow.x, camFollow.y + 500);
				}
				
			}
			if(FlxG.mouse.wheel > 0)
			{
				if(camFollow.y > 359.5) {
					camFollow.setPosition(camFollow.x, camFollow.y - 500);
				}
			}
			if(FlxG.mouse.wheel < 0) {
				if(camFollow.y < 859.5) {
					camFollow.setPosition(camFollow.x, camFollow.y + 500);
				}
				
			}
			if(allowedDif) {
				if (controls.UI_RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');
	
				if (controls.UI_LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');
	
				if (controls.UI_RIGHT_P)
					changeDifficulty(1);
				else if (controls.UI_LEFT_P)
					changeDifficulty(-1);
				else if (upP || downP)
					changeDifficulty();
			} else {
				if (controls.UI_RIGHT_P)
					changeWeek(1);
				else if (controls.UI_LEFT_P)
					changeWeek(-1);
			}

			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				selectWeek(curWeek);
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.visible = (lock.y > FlxG.height / 2);
		});

	}


	function mouseControls() {
		if (FlxG.mouse.justMoved)
			{
				for (i in 0...videos.length)
				{
					if (i != curWeek)
					{
						if (FlxG.mouse.overlaps(videos.members[i]) && !FlxG.mouse.overlaps(videos.members[curWeek]))
						{
							changeWeekOnMouse(i);
						}
					}
				}
			}

	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek(week:Int)
	{
		if (!weekIsLocked(loadedWeeks[week].fileName))
		{
			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[week].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			try
			{
				PlayState.storyPlaylist = songArray;
				PlayState.isStoryMode = true;
				selectedWeek = true;
	
				var diffic = Difficulty.getFilePath(curDifficulty);
				if(diffic == null) diffic = '';
	
				PlayState.storyDifficulty = curDifficulty;
	
				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');
				return;
			}
			
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				
				stopspamming = true;
			}

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreePlaySongState.destroyFreeplayVocals();
			});
			
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		}
		else FlxG.sound.play(Paths.sound('cancelMenu'));
	}

	var tweenDifficulty:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = Difficulty.getString(curDifficulty);
		var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));
		//trace(Mods.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.x = leftArrow.x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = leftArrow.y - 15;

			if(tweenDifficulty != null) tweenDifficulty.cancel();
			tweenDifficulty = FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07, {onComplete: function(twn:FlxTween)
			{
				tweenDifficulty = null;
			}});
		}
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;


	function changeWeekOnMouse(change:Int = 0):Void {
		FlxTween.tween(videos.members[curWeek],
		{"scale.x": 0.21, "scale.y": 0.21}, 0.2, {
			type: FlxTweenType.ONESHOT,
			ease: FlxEase.cubeOut
		});
		curWeek += change;
		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
			
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;
	}

	function changeWeek(change:Int = 0):Void
	{
		FlxTween.tween(videos.members[curWeek],
		{"scale.x": 0.2, "scale.y": 0.2}, 0.2, {
			type: FlxTweenType.ONESHOT,
			ease: FlxEase.cubeOut
		});

		curWeek += change;
		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
			
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;



		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;



		var unlocked:Bool = !weekIsLocked(leWeek.fileName);

		PlayState.storyWeek = curWeek;
		FlxTween.tween(videos.members[curWeek],
		{"scale.x": .21, "scale.y": .21}, 0.2,  {
			type: FlxTweenType.ONESHOT,
			ease: FlxEase.cubeOut
		});
		Difficulty.loadFromWeek();
		difficultySelectors.visible = unlocked;

		if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}
