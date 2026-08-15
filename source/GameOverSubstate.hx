package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	// Custom game over character variants from decompiled binary
	private static var customGameOverChars:Map<String, String> = [
		'bf-pixel' => 'bf-pixel-dead',
		'bf-car' => 'bf',
		'bf-christmas' => 'bf',
		// Custom characters use their own game over variants
		'splingo' => 'bf',
		'theDerelict' => 'bf',
		'garretson' => 'bf',
		'vilbert' => 'bf',
		'maldo' => 'bf',
		'carl' => 'bf',
		'primo' => 'bf',
		'miya' => 'bf',
		'sarah' => 'bf',
		'atrocious' => 'bf',
		'davepizza' => 'bf'
	];

	// Game over character asset paths from decompiled binary
	private static var gameOverCharAssets:Map<String, String> = [
		'default' => 'gameOver/char/BF',
		'michel' => 'gameOver/char/BF_michel',
		'silly_bucket' => 'gameOver/char/silly_bucket',
		'jimbio' => 'gameOver/char/jimbio',
		'dave' => 'gameOver/char/dave',
		'miya' => 'gameOver/char/miya',
		'primo' => 'gameOver/primoGameOver/primo'
	];

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.Stage.curStage;
		var daBf:String = '';

		// Check for custom game over character
		var bfChar = PlayState.boyfriend.curCharacter;
		if (customGameOverChars.exists(bfChar))
		{
			daBf = customGameOverChars[bfChar];
		}
		else
		{
			switch (bfChar)
			{
				case 'bf-pixel':
					stageSuffix = '-pixel';
					daBf = 'bf-pixel-dead';
				default:
					daBf = 'bf';
			}
		}

		// Check for PIU/Chortle stage - use Primo game over
		if (daStage == 'chortle')
		{
			// Use PiuGameOverSubstate instead
			close();
			FlxG.state.openSubState(new PiuGameOverSubstate());
			return;
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	var startVibin:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (FlxG.save.data.InstantRespawn)
		{
			LoadingState.loadAndSwitchState(new PlayState());
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
			{
				GameplayCustomizeState.freeplayBf = 'bf';
				GameplayCustomizeState.freeplayDad = 'dad';
				GameplayCustomizeState.freeplayGf = 'gf';
				GameplayCustomizeState.freeplayNoteStyle = 'normal';
				GameplayCustomizeState.freeplayStage = 'stage';
				GameplayCustomizeState.freeplaySong = 'bopeebo';
				GameplayCustomizeState.freeplayWeek = 1;
				FlxG.switchState(new StoryMenuState());
			}
			else
				FlxG.switchState(new FreeplayState());
			PlayState.loadRep = false;
			PlayState.stageTesting = false;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			startVibin = true;
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (startVibin && !isEnding)
		{
			bf.playAnim('deathLoop', true);
		}
		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			PlayState.startTime = 0;
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
					PlayState.stageTesting = false;
				});
			});
		}
	}
}
