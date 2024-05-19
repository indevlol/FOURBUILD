package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;
import objects.MusicPlayer;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import flixel.math.FlxMath;


class FreePlaySongState extends MusicBeatState{
      public static var curModSelected:Int = 0;
      var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
      private var grpSongsSpr:FlxTypedGroup<FlxSprite>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var player:MusicPlayer;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
      var songText:FlxText;
      var leftArrow:FlxSprite;
      var rightArrow:FlxSprite;

      var leftSpikyThing:FlxSprite;
      var rightSpikyThing:FlxSprite;

      override function create()
      {
            FlxG.mouse.visible = true;
		
            bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();
           
            scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
            
            
		add(scoreBG);
            add(scoreText);

            
		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);



            missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);


            bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		bottomString = leText;
		var size:Int = 16;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);


            
            songText = new FlxText(0, 550, FlxG.width, "", 32);
            songText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            songText.borderSize = 1.50;
            add(songText);


		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);
            grpSongs = new FlxTypedGroup<Alphabet>();
            add(grpSongs);

            grpSongsSpr = new FlxTypedGroup<FlxSprite>();
            add(grpSongsSpr);



            #if DISCORD_ALLOWED
      		DiscordClient.changePresence("Free Playing", null);
		#end


      

            //public function new(song:String, week:Int, songCharacter:String, color:Int)
            switch(curModSelected) {
                  case 0:
                        songs = [];
                        
                        if(!weekIsLocked("week1")) {
                              addSong("Four", 1, "Four", FlxColor.BLUE);
                              addSong("Rushed", 1, "Four", FlxColor.BLUE);
                              addSong("Eliminated", 1, "Four", FlxColor.BLUE);
                              addSong("Freefall", 1, "Four", FlxColor.BLUE);
                        }
                        if(!weekIsLocked("week2")) {
                              addSong("Projection", 2, "Two", FlxColor.BLUE);
                              addSong("Cheese Cake", 2, "Two", FlxColor.BLUE);
                              addSong("Quality", 2, "Two", FlxColor.BLUE);
                        }
                        if(!weekIsLocked("week3")) {
                              addSong("Tie Breaker", 3, "Announcer", FlxColor.BLUE);
                              addSong("Budget Cuts", 3, "Announcer", FlxColor.BLUE);
                              addSong("Take The Plunge", 3, "Announcer", FlxColor.BLUE);     
                        }

                  case 1:
                        songs = [];

            }
            
            var XPos:Int = 400;



            

            for(i in 0...songs.length) {
                  XPos += 1000;
                  
                  var songSpr:FlxSprite;
                  songSpr = new FlxSprite(XPos, 50).loadGraphic(Paths.image('menus/freeplay/iconshit/PLACEHOLDER'));
                  grpSongsSpr.add(songSpr);
            }

            leftArrow = new FlxSprite(300, 300);
            leftArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
            leftArrow.animation.addByPrefix('idle', 'arrow left');
            leftArrow.animation.addByPrefix('pressed', 'arrow push left');
            add(leftArrow);
            leftArrow.animation.play('idle');

            rightArrow = new FlxSprite(900, 300);
            rightArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
            rightArrow.animation.addByPrefix('idle', 'arrow right');
            rightArrow.animation.addByPrefix('pressed', 'arrow push right');
            add(rightArrow);
            rightArrow.animation.play('idle');

            leftSpikyThing = new FlxSprite(-100, -190);
            leftSpikyThing.loadGraphic(Paths.image('menus/freeplay/spikething'));
            leftSpikyThing.scale.x = .7;
            leftSpikyThing.scale.y = .7;
            add(leftSpikyThing);

            rightSpikyThing = new FlxSprite(1000, -190);
            rightSpikyThing.loadGraphic(Paths.image('menus/freeplay/spikething'));
            rightSpikyThing.scale.x = .7;
            rightSpikyThing.scale.y = .7;
            rightSpikyThing.angle = 180;
            add(rightSpikyThing);


            if(curSelected >= songs.length) curSelected = 0;
            curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
            changeSelection();
      }

      override function update(elapsed:Float) {

            

            lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

            if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}


            scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
            positionHighscore();

            mouseControls();

            if (controls.UI_LEFT_P) {
                  changeSelection(-1);
            }
            if (controls.UI_RIGHT_P) {
                  changeSelection(1);
            }

           
            if(FlxG.keys.justPressed.ESCAPE) {
                  MusicBeatState.switchState(new FreeplayState());
            }

            if (controls.UI_DOWN_P)
            {
                  changeDiff(-1);
                  _updateSongLastDifficulty();
            }
            else if (controls.UI_UP_P)
            {
                  changeDiff(1);
                  _updateSongLastDifficulty();
            }

            songText.text = songs[curSelected].songName;

            if (controls.ACCEPT)
            {
                  enter();
                  super.update(elapsed);

            }


      }

      var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
      

      function mouseControls() {
		
		for (i in 0...grpSongsSpr.length) {
                  var hovering:Bool = FlxG.mouse.overlaps(grpSongsSpr.members[i]);
			if(FlxG.mouse.justPressed && hovering) {
				enter();
			}
	
			if(FlxG.mouse.justPressedRight) {
				MusicBeatState.switchState(new FreeplayState());
			}
		}

            if(FlxG.mouse.overlaps(rightArrow)) {
                  if(FlxG.mouse.justPressed) {
                        FlxTween.tween(rightArrow,
                        {"scale.x": 0.6, "scale.y": .6}, 0.2, {
                              type: FlxTweenType.ONESHOT,
                              ease: FlxEase.cubeOut,
                              onComplete: function(twn:FlxTween)
                              {
                                    FlxTween.tween(rightArrow,
                                    {"scale.x": 1, "scale.y": 1}, 0.2, {
                                          type: FlxTweenType.ONESHOT,
                                          ease: FlxEase.cubeOut
            
                                    });
                              }
                        });
                        changeSelection(1);
                  }

            }
            else if (FlxG.mouse.overlaps(leftArrow)) {
                  if(FlxG.mouse.justPressed) {
                        FlxTween.tween(leftArrow,
                        {"scale.x": 0.6, "scale.y": .6}, 0.2, {
                              type: FlxTweenType.ONESHOT,
                              ease: FlxEase.cubeOut,
                              onComplete: function(twn:FlxTween)
                              {
                                    FlxTween.tween(leftArrow,
                                    {"scale.x": 1, "scale.y": 1}, 0.2, {
                                          type: FlxTweenType.ONESHOT,
                                          ease: FlxEase.cubeOut
            
                                    });
                              }

                        });
                        changeSelection(-1);
                  }
            }
		
	}


      function enter() {
            var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
            var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
            /*#if MODS_ALLOWED
            if(!FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
            #else
            if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
            #end
                  poop = songLowercase;
                  curDifficulty = 1;
                  trace('Couldnt find file');
            }*/
            trace(poop);

            try
            {
                  PlayState.SONG = Song.loadFromJson(poop, songLowercase);
                  PlayState.isStoryMode = false;
                  PlayState.storyDifficulty = curDifficulty;
            }
            catch(e:Dynamic)
            {
                  trace('ERROR! $e');

                  var errorStr:String = e.toString();
                  if(errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length-1); //Missing chart
                  missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
                  missingText.screenCenter(Y);
                  missingText.visible = true;
                  missingTextBG.visible = true;
                  FlxG.sound.play(Paths.sound('cancelMenu'));
                  return;
            }
            LoadingState.loadAndSwitchState(new PlayState());

            FlxG.sound.music.volume = 0;
                        
            destroyFreeplayVocals();
            #if (MODS_ALLOWED && DISCORD_ALLOWED)
            DiscordClient.loadModRPC();
            #end
      }

	function changeDiff(change:Int = 0)
      {

            curDifficulty += change;

            if (curDifficulty < 0)
                  curDifficulty = Difficulty.list.length - 1;
            if (curDifficulty >= Difficulty.list.length)
                  curDifficulty = 0;

            #if !switch
                  intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
                  intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
            #end

            lastDifficultyName = Difficulty.getString(curDifficulty);
            if (Difficulty.list.length > 1)
                  diffText.text = '< ' + lastDifficultyName.toUpperCase() + ' >';
            else
                  diffText.text = lastDifficultyName.toUpperCase();

            positionHighscore();
            missingText.visible = false;
            missingTextBG.visible = false;
      }


      function changeSelection(change:Int = 0) {
            _updateSongLastDifficulty();
            
            FlxTween.tween(grpSongsSpr.members[curSelected],
            {"scale.x": 1, "scale.y": 1}, 0.2, {
                  type: FlxTweenType.ONESHOT,
                  ease: FlxEase.cubeOut
            });
            grpSongsSpr.members[curSelected].x = 1300;


            curSelected += change;


            var lastList:Array<String> = Difficulty.list;
            curSelected += change;

            if (curSelected < 0)
                  curSelected = songs.length - 1;
            if (curSelected >= songs.length)
                  curSelected = 0;
            


            var bullShit:Int = 0;

            for (item in grpSongs.members)
            {
                  bullShit++;
                  item.alpha = 0.6;
                  if (item.targetY == curSelected)
                        item.alpha = 1;
            }


            grpSongsSpr.members[curSelected].screenCenter(X);
            grpSongsSpr.members[curSelected].y = 0;


            FlxTween.tween(grpSongsSpr.members[curSelected],
            {"scale.x": .7, "scale.y": .7}, 0.2,  {
                  type: FlxTweenType.ONESHOT,
                  ease: FlxEase.cubeOut
            });

            
            Difficulty.loadFromWeek();
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		changeDiff();
		_updateSongLastDifficulty();
      }

      

      inline private function _updateSongLastDifficulty()
      {
            songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);
      }
      
      private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 400;
		scoreBG.scale.x = FlxG.width - scoreText.x + 400;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}


      function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}


      public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
      {
            songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
      }
      

      public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}
}


class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}