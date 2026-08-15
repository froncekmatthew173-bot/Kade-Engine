package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenType;

/**
 * Corrupted stickers visual effect overlay.
 * Displays glitchy/corrupted sticker-like graphics.
 */
class StickersCorrupted extends FlxSprite
{
	public function new(x:Float, y:Float, ?difficulty:Int = 0)
	{
		super(x, y);
		frames = Paths.getSparrowAtlas('effects/stickersCorrupted');
		animation.addByPrefix('idle', 'idle', 24, false);
		animation.play('idle');
		antialiasing = FlxG.save.data.antialiasing;
		visible = false;
		alpha = 0.8;
	}

	public function show():Void
	{
		visible = true;
		alpha = 0;
		FlxTween.tween(this, {alpha: 0.8}, 0.5, {type: FlxTweenType.ONESHOT});
	}

	public function hide():Void
	{
		visible = false;
	}
}
