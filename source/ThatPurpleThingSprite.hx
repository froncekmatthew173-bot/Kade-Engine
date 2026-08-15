package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenType;

/**
 * Purple background/decoration effect sprite.
 */
class ThatPurpleThingSprite extends FlxSprite
{
	public function new(x:Float, y:Float, ?width:Float, ?height:Float)
	{
		super(x, y);
		var w = width != null ? width : FlxG.width;
		var h = height != null ? height : FlxG.height;
		makeGraphic(Std.int(w), Std.int(h), 0xFF800080);
		antialiasing = FlxG.save.data.antialiasing;
		alpha = 0.5;
		scrollFactor.set(0.6, 0.6);
		visible = false;
	}

	public function show():Void
	{
		visible = true;
		alpha = 0;
		FlxTween.tween(this, {alpha: 0.5}, 0.5, {type: FlxTweenType.ONESHOT});
	}

	public function hide():Void
	{
		FlxTween.tween(this, {alpha: 0}, 0.3, {
			type: FlxTweenType.ONESHOT,
			onComplete: function(twn:FlxTween) {
				visible = false;
			}
		});
	}
}
