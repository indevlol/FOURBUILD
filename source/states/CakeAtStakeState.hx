package states;

import backend.Highscore;
import backend.StageData;
import backend.WeekData;
import backend.Song;
import backend.Section;
import backend.Rating;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.animation.FlxAnimationController;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import openfl.events.KeyboardEvent;
import haxe.Json;

import cutscenes.CutsceneHandler;
import cutscenes.DialogueBoxPsych;

import states.StoryMenuState;
import states.FreeplayState;
import states.editors.ChartingState;
import states.editors.CharacterEditorState;

import substates.PauseSubState;
import substates.GameOverSubstate;

#if !flash
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as VideoHandler;
#elseif (hxCodec == "2.6.0") import VideoHandler;
#else import vlc.MP4Handler as VideoHandler; #end
#end

import objects.Note.EventNote;
import objects.*;
import states.stages.objects.*;

#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.LuaUtils;
import psychlua.HScript;
#end

#if SScript
import tea.SScript;
#end


import flixel.tweens.FlxTween;

class CakeAtStakeState extends MusicBeatState {

    private var vote:Array<Int> = [];
    private var limitMisses:Int = 10;
    public static var limitStaticMisses:Int = 10;
    var placed:Bool = false;
    private var load:Bool = false;
    private var participants:Array<String> = [
      "8-Ball", "Balloon", "Barf Bag", "Basketball", "Bell", "Black Hole", "Blocky", 
      "Bomby", "Book", "Bottle", "Bracelety", "Bubble", "Cake", "Clock", "Cloudy", 
      "Coiny", "David", "Donut", "Dora", "Eggy", "Eraser", "Fanny", "Firey", "Firey Jr.", 
      "Flower", "Foldy", "Fries", "Gaty", "Gelatin", "Golf Ball", "Grassy", "Ice Cube", 
      "Leafy", "Liy", "Lightning", "Lollipop", "Loser", "Marker", "Match", "Naily", 
      "Needle", "Nickel", "Nonexisty", "Pen", "Pie", "Pillow", "Pin", "Price Tag", 
      "Puffball", "Remote", "Robot Flower", "Roboty", "Rocky", "Ruby", "Saw", "Snowball", 
      "Spongy", "Stapy", "Taco", "Teardrop", "Tennis Ball", "Tree", "TV", "Woody", "Yellow Face"
      ];
    var sortedVotes:Array<Int> = [];
    private var elTexto:FlxText;
    var bfVotes:Int;
    var playerPlace:Int;

    override function create() {
        super.create();
        cakeAtStake();
        elTexto = new FlxText(0, 0, 2000, "3", 40);
        elTexto.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        elTexto.screenCenter(XY);
        add(elTexto);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        // Ensure the text updates conditionally based on game state
            if (PlayState.staticMisses > limitMisses) {
                if (!load) {
                    if (playerPlace == sortedVotes.length) {
                        elTexto.text = "Boyfriend Has lost";
                        MusicBeatState.switchState(new MainMenuState());
                    } else {
                        elTexto.text = participants[FlxG.random.int(0, participants.length - 1)] + " Has lost";
                        endCakeArStake();
                    }
                    load = true;
                }
                
                  
            }
    }


    private function endCakeArStake() {
        if (PlayState.isStoryMode)
			{
				if (PlayState.storyPlaylist.length <= 0)
				{
					Mods.loadTopMod();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end


                    MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[PlayState.storyWeek], true);
						Highscore.saveWeekScore(WeekData.getWeekFileName(), PlayState.campaignScore, PlayState.storyDifficulty);

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					PlayState.changedDifficulty = false;
				}
				else
				{
					var difficulty:String = Difficulty.getFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.PlayState.storyPlaylist[0]) + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					PlayState.PlayState.SONG = Song.loadFromJson(PlayState.PlayState.storyPlaylist[0] + difficulty, PlayState.PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

                    LoadingState.loadAndSwitchState(new PlayState());
				}
        } else {
            
            trace('WENT BACK TO FREEPLAY??');
            Mods.loadTopMod();
            #if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
            MusicBeatState.switchState(new FreeplayState());
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
            PlayState.changedDifficulty = false;
        }
    }

    private function cakeAtStake() {
        // Clear the vote array to avoid accumulating votes from previous calls
        vote = [];
        trace("Static Misses: " + PlayState.staticMisses);
    
        if (PlayState.staticMisses > limitMisses) {
            // Inverse relationship: more misses, lower votes
            bfVotes = FlxG.random.int(Math.floor(900 / PlayState.staticMisses), 1000 - PlayState.staticMisses * 5);

            trace("Player Votes (bfVotes): " + bfVotes);
    
            // Populate votes for each participant  
            for (i in 0...participants.length) {
                var objectVotes:Int = FlxG.random.int(1, 1000);
                vote.push(objectVotes);
            }
    
            // Create a sorted copy of the votes array
            sortedVotes = vote.copy();
            sortedVotes.sort(function(a, b) return b - a); // Correct sorting function

    
            // Determine the player's rank based on votes
            placed = false;
            playerPlace = sortedVotes.length; // Default to last place
    
            for (i in 0...sortedVotes.length) {
                if (bfVotes >= sortedVotes[i]) {
                    playerPlace = i + 1;
                    placed = true;
                    break;
                }
            }
    
            
    
            trace("Sorted Votes: " + sortedVotes);
            trace("Your Votes: " + bfVotes);
        }
    }
    
    
}
