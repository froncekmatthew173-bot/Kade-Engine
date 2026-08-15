package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxCamera;
import flixel.input.keyboard.FlxKey;

/**
 * PiuGameOverSubstate - Custom PIU-style game over screen.
 * Features Primo character and themed game over display.
 */
class PiuGameOverSubstate extends FlxSubState
{
	private var screenOverlay:FlxSprite;
	private var textOverlay:FlxSprite;
	private var primoSprite:FlxSprite;
	private var blackOverlay:FlxSprite;
	private var gameOverText:FlxText;

	private var difficulty:String = "normal";

	public function new(?diff:String = "normal")
	{
		super();
		this.difficulty = diff;
	}

	override public function create():Void
	{
		super.create();

		// Camera setup
		var cam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		FlxG.cameras.add(cam);
		cam.bgColor = 0xFF000000;

		// Black overlay
		blackOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		blackOverlay.alpha = 0;
		add(blackOverlay);

		// Screen overlay
		screenOverlay = new FlxSprite(0, -182);
		screenOverlay.loadGraphic(Paths.loadImage('gameOver/primoGameOver/screen'));
		screenOverlay.antialiasing = FlxG.save.data.antialiasing;
		screenOverlay.alpha = 0;
		add(screenOverlay);

		// Text overlay
		textOverlay = new FlxSprite(0, 631);
		textOverlay.loadGraphic(Paths.loadImage('gameOver/primoGameOver/text'));
		textOverlay.antialiasing = FlxG.save.data.antialiasing;
		textOverlay.scale.set(0.8, 0.8);
		textOverlay.alpha = 0;
		add(textOverlay);

		// Primo character sprite
		primoSprite = new FlxSprite(0, 125);
		primoSprite.frames = Paths.getSparrowAtlas('gameOver/primoGameOver/primo');
		primoSprite.animation.addByPrefix('idle', 'idle', 24, false);
		primoSprite.animation.addByPrefix('talk', 'talk', 24, false);
		primoSprite.animation.play('idle');
		primoSprite.antialiasing = FlxG.save.data.antialiasing;
		primoSprite.scale.set(1.3, 1.3);
		primoSprite.alpha = 0;
		add(primoSprite);

		// Game over text
		gameOverText = new FlxText(0, 200, FlxG.width, "GAME OVER", 80);
		gameOverText.setFormat(Paths.font("vcr.ttf"), 80, 0xFFFF0000, CENTER);
		gameOverText.antialiasing = FlxG.save.data.antialiasing;
		gameOverText.alpha = 0;
		add(gameOverText);

		// Animate in
		FlxTween.tween(blackOverlay, {alpha: 0.8}, 0.5);
		FlxTween.tween(screenOverlay, {alpha: 1}, 0.8, {startDelay: 0.2});
		FlxTween.tween(textOverlay, {alpha: 1}, 0.8, {startDelay: 0.4, ease: FlxEase.quadOut});
		FlxTween.tween(primoSprite, {alpha: 1}, 0.8, {startDelay: 0.6});
		FlxTween.tween(gameOverText, {alpha: 1}, 0.5, {startDelay: 0.3});

		// Primo talk animation
		new flixel.util.FlxTimer().start(1.0, function(tmr:flixel.util.FlxTimer) {
			if (primoSprite != null)
				primoSprite.animation.play('talk');
		});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// Press R to restart
		if (FlxG.keys.anyJustPressed([FlxKey.R, FlxKey.SPACE, FlxKey.ENTER]))
		{
			FlxG.resetState();
		}

		// Press ESC to go back to menu
		if (FlxG.keys.anyJustPressed([FlxKey.ESCAPE]))
		{
			FlxG.switchState(new MainMenuState());
		}
	}
}
