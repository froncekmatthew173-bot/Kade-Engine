package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
 * ScreenPiu - PIU screen display element.
 * Shows the PIU machine screen with animated content.
 */
class ScreenPiu extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);
		frames = Paths.getSparrowAtlas('bgs/chortle/piuScreen');
		animation.addByPrefix('idle', 'idle', 24, false);
		animation.addByPrefix('singing', 'singing', 24, false);
		animation.play('idle');
		antialiasing = FlxG.save.data.antialiasing;
		scrollFactor.set(0.6, 0.6);
	}

	public function playSinging():Void
	{
		animation.play('singing');
	}

	public function playIdle():Void
	{
		animation.play('idle');
	}
}
