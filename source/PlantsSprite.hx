package;

import flixel.FlxSprite;
import flixel.FlxG;

/**
 * Plant decoration overlay sprite.
 */
class PlantsSprite extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);
		frames = Paths.getSparrowAtlas('effects/plants');
		animation.addByPrefix('idle', 'idle', 24, false);
		animation.play('idle');
		antialiasing = FlxG.save.data.antialiasing;
		visible = false;
	}

	public function show():Void
	{
		visible = true;
	}

	public function hide():Void
	{
		visible = false;
	}
}
