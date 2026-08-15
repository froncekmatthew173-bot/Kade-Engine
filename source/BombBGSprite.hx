package;

import flixel.FlxSprite;
import flixel.FlxG;

/**
 * Bomb explosion background effect sprite.
 */
class BombBGSprite extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);
		frames = Paths.getSparrowAtlas('effects/bombBG');
		animation.addByPrefix('idle', 'idle', 24, false);
		animation.addByPrefix('explode', 'explode', 24, false);
		animation.play('idle');
		antialiasing = FlxG.save.data.antialiasing;
		visible = false;
	}

	public function explode():Void
	{
		visible = true;
		animation.play('explode');
	}

	public function reset():Void
	{
		visible = false;
		animation.play('idle');
	}
}
