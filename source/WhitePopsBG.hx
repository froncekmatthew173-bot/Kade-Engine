package;

import flixel.FlxSprite;
import flixel.FlxG;

/**
 * White popup background effect.
 * Flashes white on screen for impact effects.
 */
class WhitePopsBG extends FlxSprite
{
	public function new(x:Float, y:Float, ?width:Float, ?height:Float)
	{
		super(x, y);
		var w = width != null ? width : FlxG.width;
		var h = height != null ? height : FlxG.height;
		makeGraphic(Std.int(w), Std.int(h), 0xFFFFFFFF);
		antialiasing = FlxG.save.data.antialiasing;
		alpha = 0;
		scrollFactor.set(0, 0);
	}

	public function flash(duration:Float = 0.3):Void
	{
		alpha = 1.0;
		flixel.tweens.FlxTween.tween(this, {alpha: 0}, duration, {type: flixel.tweens.FlxTweenType.ONESHOT});
	}

	public function pop():Void
	{
		alpha = 0.8;
		flixel.tweens.FlxTween.tween(this, {alpha: 0}, 0.15, {type: flixel.tweens.FlxTweenType.ONESHOT});
	}
}
