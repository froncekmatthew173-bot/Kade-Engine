package;

import flixel.FlxSprite;
import flixel.FlxG;

/**
 * Lighting overlay effect sprite.
 * Used for lightsOn/lightsOff events.
 */
class LightSprite extends FlxSprite
{
	public var isLightOn:Bool = true;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0xFF000000);
		antialiasing = FlxG.save.data.antialiasing;
		alpha = 0;
		scrollFactor.set(0, 0);
	}

	public function lightsOff():Void
	{
		isLightOn = false;
		alpha = 0.7; // Dark overlay
	}

	public function lightsOn():Void
	{
		isLightOn = true;
		alpha = 0; // No overlay
	}

	public function toggle():Void
	{
		if (isLightOn)
			lightsOff();
		else
			lightsOn();
	}
}
