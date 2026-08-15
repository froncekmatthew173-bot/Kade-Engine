package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
 * TV Start/CRT visual effect sprite.
 * Creates a CRT monitor startup animation with scrolling lines.
 */
class TvStartSprite extends FlxSprite
{
	public var isActive:Bool = false;
	private var scrollSpeed:Float = 300.0;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		frames = Paths.getSparrowAtlas('effects/tvStart');
		animation.addByPrefix('idle', 'idle', 24, false);
		animation.addByPrefix('start', 'start', 24, false);
		antialiasing = FlxG.save.data.antialiasing;
		visible = false;
	}

	public function showAnims():Void
	{
		visible = true;
		alpha = 1.0;
		animation.play('start');
		isActive = true;
	}

	public function hideAnims():Void
	{
		visible = false;
		isActive = false;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (isActive)
		{
			// Scroll effect
			x += scrollSpeed * elapsed;
			if (x > 250)
			{
				x -= width;
			}
		}
	}
}
