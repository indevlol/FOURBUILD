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
import openfl.ui.Mouse;

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
	var videosLabel:FlxTypedGroup<FlxText>;
	var ct:Int = 0;
	var allowedDif:Bool = false;
	var videosLabels:Array<String> = [
	"                      Tutorial \n     The Left Right Song You Know It",
	"                        Vs Four \n          Versus The Number Four",
	"                        Vs Two \n               The Power Of Two",
	"                    Vs Annoucer \n The Mystrious Talking Box Thingie"
	];
	var sub:FlxSprite;
	var canClick:Bool = true;
	var options:Array<String> = [
		"Home",
		"Videos"
	];
	var optionsGrp:FlxTypedGroup<FlxSprite>;
	var videosXPositions:Int = -1100;
	var optionsXPositions:Int = 120;
	var curSelected:Int = 0;
	var isHovering:Bool = false;
	var inHome:Bool = true;
	var randomVideo:FlxSprite;
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
		FlxG.mouse.useSystemCursor = true;
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
		
		videos = new FlxTypedGroup<FlxSprite>();
		add(videos);
		
		videosLabel = new FlxTypedGroup<FlxText>();
		add(videosLabel);

		optionsGrp = new FlxTypedGroup<FlxSprite>();
		add(optionsGrp);

		sub = new FlxSprite(250, 330);
		sub.frames = Paths.getSparrowAtlas('menus/story/Subscribe');
		sub.animation.addByPrefix('unsub', 'unSubed');
		sub.animation.addByPrefix('sub', 'Subed');
		sub.animation.play('unsub');
		sub.scale.x = 0.7;
		sub.scale.y = 0.7;
		add(sub);

		for(i in 0...options.length) {
			optionsXPositions += 130;
			var option:FlxSprite = new FlxSprite(optionsXPositions, 410);
			option.scale.x = .7;
			option.scale.y = .7;
			option.frames = Paths.getSparrowAtlas('menus/story/' + options[i]);
			option.animation.addByPrefix('idle', options[i] );
			option.animation.addByPrefix('selected', 'Selected' + options[i]);
			option.animation.play('idle');
			optionsGrp.add(option);
		}

		optionsGrp.members[0].animation.play('selected');


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
			videosXPositions += 500;
			var video:FlxSprite = new FlxSprite(videosXPositions, 50).loadGraphic(Paths.image('menus/story/thumbnails/PLACEHOLDER'));
			video.scale.x = 0.2;
			video.scale.y = 0.2;
			videos.add(video);
			
			
		}
		var xPos:Int = -1100;
		for (i in 0...videosLabels.length) {
			xPos += 500;
			var videoText:FlxText =  new FlxText(xPos + 780, 710, videos.members[0].width, videosLabels[i], 15);
			videosLabel.add(videoText);
		}

		for(i in 0...videos.length) {
			if(i % 2 == 0 && i != 0) {
				var newIndex = 0;
				newIndex = i + 1;
				// DON'T TOUCH I SWEAR TO GOD !
				for(j in newIndex - 1...newIndex + 1) {
					/**
					 * It looks fanacy right ?
					 * well took 1:30 hour :D *Help*
					 */

					for(k in 0...j - 1) {
						videos.members[j].x = (videos.members[0].x + (500 * k)) ;
					}
					videos.members[j].y = (videos.members[0].y + 75) * newIndex;
					trace(" V(x) -> " + videos.members[j].x + " V(y) -> " + videos.members[j].y);
				}
			}
		}


		for(i in 0...videosLabel.length) {
			if(i % 2 == 0 && i != 0) {
				var newIndex = 0;
				newIndex = i + 1;
				for(j in newIndex - 1...newIndex + 1) {

					for(k in 0...j - 1) {
						videosLabel.members[j].x = (videosLabel.members[0].x + (500 * k)) ;
					}
					videosLabel.members[j].y = videosLabel.members[0].y + (110 * newIndex);
					trace(" L(x) -> " + videosLabel.members[j].x + " L(y) -> " + videosLabel.members[j].y);
				}
			}
		}

		randomVideo = new FlxSprite(-300, 50).loadGraphic(Paths.image('menus/story/thumbnails/randomVideo'));
		randomVideo.scale.x = 0.2;
		randomVideo.scale.y = 0.2;
		randomVideo.active = randomVideo.visible = false;
		add(randomVideo);
		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		var charArray:Array<String> = loadedWeeks[0].weekCharacters;


		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(500, 500);
		leftArrow.scale.x = 1.3;
		leftArrow.scale.y = 1.3;
		leftArrow.angle = 90;
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
		rightArrow.scale.x = 1.3;
		rightArrow.scale.y = 1.3;
		rightArrow.angle = 90;
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		leftArrow.alpha = rightArrow.alpha = sprDifficulty.alpha = 0;

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
		leftArrow.x = camFollow.x - 50;
		leftArrow.y = camFollow.y - 150;
		rightArrow.x = leftArrow.x;
		rightArrow.y = leftArrow.y + 180;
		if(curDifficulty == 1){
			sprDifficulty.x = leftArrow.x - 125;
		} else {
			sprDifficulty.x = leftArrow.x - 75;
		}
		sprDifficulty.y = leftArrow.y + 100;
		
		leftArrow.visible = rightArrow.visible = sprDifficulty.visible = allowedDif;
		
		switch(options[curSelected]) {
			case "Home":
				inHome = true;
			case "Videos":
				inHome = false;
				curWeek = 0;
				
		}


		if (!movedBack && !selectedWeek)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			

			// < 359.5
			// > 859.5
			// my code sucks i know but eh I don't have the energy to care :D
			if (!allowedDif) {
				if (upP)
				{
					changeWeek(-1, "vertically");
					camFollow.setPosition(camFollow.x, videos.members[curWeek].y + 450);
					
				}
	
				if (downP)
				{
					changeWeek(1, "vertically");
					camFollow.setPosition(camFollow.x, videos.members[curWeek].y + 450);
					
				}
				if(FlxG.mouse.wheel > 0)
				{
					if(camFollow.y > 500) {
						camFollow.setPosition(camFollow.x, camFollow.y - 350);
					}
				}
				if(FlxG.mouse.wheel < 0) {
					if(camFollow.y < 600) {
						camFollow.setPosition(camFollow.x, camFollow.y + 350);
					}
					
				}
				if (controls.UI_RIGHT_P)
					changeWeek(1);
				else if (controls.UI_LEFT_P)
					changeWeek(-1);
			}
			if(allowedDif) {
				if (controls.UI_UP)
					leftArrow.animation.play('press')
				else
					leftArrow.animation.play('idle');
	
				if (controls.UI_DOWN)
					rightArrow.animation.play('press');
				else
					rightArrow.animation.play('idle');
	
				if (controls.UI_UP_P)
					changeDifficulty(1);
				else if (controls.UI_DOWN_P)
					changeDifficulty(-1);
				else if (upP || downP)
					changeDifficulty();
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
				if(inHome) {
					ct ++;
				} else {
					curDifficulty = 2;
					selectWeek(FlxG.random.int(1, WeekData.weeksList.length - 1));
				}
			}
			
			switch (ct) {
				case 0:
					allowedDif = false;
				case 1:
					allowedDif = true;
					FlxTween.tween(leftArrow, {alpha: 1}, 0.3);
					FlxTween.tween(rightArrow, {alpha: 1}, 0.3);
					FlxTween.tween(sprDifficulty, {alpha: 1}, 0.3);
				case 2:
					selectWeek(curWeek);
			}

		}

		for(i in 0...WeekData.weeksList.length) {
			videos.members[i].visible = videosLabel.members[i].visible = inHome;
			videos.members[i].active = videosLabel.members[i].active = inHome;
		}
		randomVideo.visible = !inHome;
		randomVideo.active = !inHome;

		if (controls.BACK || FlxG.mouse.justPressedRight && !movedBack && !selectedWeek)
		{
			ct --;
			if(allowedDif) {
				FlxTween.tween(leftArrow, {alpha: 0}, 0.3);
				FlxTween.tween(rightArrow, {alpha: 0}, 0.3);
				FlxTween.tween(sprDifficulty, {alpha: 0}, 0.3);
			}
			if(!allowedDif) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				movedBack = true;
				MusicBeatState.switchState(new MainMenuState());
			}
		}

	

		mouseControls();
		super.update(elapsed);
		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.visible = (lock.y > FlxG.height / 2);
		});

	}
	


	function mouseControls() {
		if(FlxG.mouse.overlaps(sub)) {
			isHovering = true;
			if(FlxG.mouse.justPressed) {
				if(canClick) {
					CoolUtil.browserLoad('https://www.youtube.com/@BFDI');
					canClick = false;
				}
			}
			sub.animation.play('sub');
		} else {
			isHovering = false;
			canClick = true;
			sub.animation.play('unsub');
		}

		for (i in 0...optionsGrp.length) {
			if(!weekIsLocked("week1") && !weekIsLocked("week2") && !weekIsLocked("week3")) {
				var hovering = FlxG.mouse.overlaps(optionsGrp.members[i]);
				if(hovering) {
					if(FlxG.mouse.justPressed) {
						
						optionsGrp.members[curSelected].animation.play('idle');
						curSelected = i;
						optionsGrp.members[curSelected].animation.play('selected');
					}
					isHovering = true;
				} else {
					isHovering = false;
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

	function changeWeek(change:Int = 0, mode:String = "default"):Void
	{
		FlxTween.tween(videos.members[curWeek],
			{"scale.x": 0.2, "scale.y": 0.2}, 0.2, {
				type: FlxTweenType.ONESHOT,
				ease: FlxEase.cubeOut
			});
			videos.members[curWeek].shader = null;
		

		switch (mode) {
			case "default":
				curWeek += change;
				if (curWeek >= loadedWeeks.length)
					curWeek = 0;
					
				if (curWeek < 0)
					curWeek = loadedWeeks.length - 1;
			
			case "vertically":
				curWeek += change + (1 * change);
				if(curWeek >= loadedWeeks.length) {
					curWeek = 0;
				}
				if(curWeek > loadedWeeks.length - 1) {
					curWeek = 1;
				}

				if(curWeek < 0) {
					if(Math.abs(curWeek) % 2 == 0) {
						curWeek = loadedWeeks.length - 2;
					} else {
						curWeek = loadedWeeks.length - 1;
					}
				}

			case "mouse":
				curWeek = change;
				if (curWeek >= loadedWeeks.length)
					curWeek = 0;
					
				if (curWeek < 0)
					curWeek = loadedWeeks.length - 1;
		}
		
		


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
