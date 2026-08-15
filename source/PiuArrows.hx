package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
 * PIU (Pump It Up) 5-panel dance pad arrow system.
 * Supports 5 arrow directions: up-left, up-right, center, down-left, down-right
 * Plus standard 4-key for compatibility.
 */
class PiuArrows extends FlxTypedGroup<FlxSprite>
{
	public var arrowSprites:Array<FlxSprite> = [];
	public var isPIUMode:Bool = false;

	// PIU arrow positions (5-panel layout)
	// Panel layout: UL, DL, Center, UR, DR
	public static inline var PIU_ARROW_COUNT:Int = 5;
	public static inline var STD_ARROW_COUNT:Int = 4;

	// Arrow lane indices
	public static inline var LANE_LEFT:Int = 0;
	public static inline var LANE_DOWN:Int = 1;
	public static inline var LANE_UP:Int = 2;
	public static inline var LANE_RIGHT:Int = 3;

	// PIU lane indices
	public static inline var PIU_LANE_UP_LEFT:Int = 0;
	public static inline var PIU_LANE_DOWN_LEFT:Int = 1;
	public static inline var PIU_LANE_CENTER:Int = 2;
	public static inline var PIU_LANE_UP_RIGHT:Int = 3;
	public static inline var PIU_LANE_DOWN_RIGHT:Int = 4;

	public function new(x:Float, y:Float, piuMode:Bool = false)
	{
		super();
		this.isPIUMode = piuMode;

		if (piuMode)
			createPIUArrows(x, y);
		else
			createStandardArrows(x, y);
	}

	function createPIUArrows(x:Float, y:Float):Void
	{
		var spacing:Float = 160 * 0.7 + 10; // arrow width + gap
		var startX:Float = x - (spacing * 2);

		for (i in 0...PIU_ARROW_COUNT)
		{
			var arrow = new FlxSprite(startX + (spacing * i), y);
			arrow.loadGraphic(Paths.loadImage('PIU/arrows'));
			arrow.antialiasing = FlxG.save.data.antialiasing;
			arrow.setGraphicSize(Std.int(160 * 0.7), Std.int(160 * 0.7));
			arrow.updateHitbox();
			arrow.alpha = 0.6;
			add(arrow);
			arrowSprites.push(arrow);
		}
	}

	function createStandardArrows(x:Float, y:Float):Void
	{
		var spacing:Float = 160 * 0.7 + 10;
		var startX:Float = x - (spacing * 1.5);

		for (i in 0...STD_ARROW_COUNT)
		{
			var arrow = new FlxSprite(startX + (spacing * i), y);
			arrow.loadGraphic(Paths.loadImage('PIU/arrows_std'));
			arrow.antialiasing = FlxG.save.data.antialiasing;
			arrow.setGraphicSize(Std.int(160 * 0.7), Std.int(160 * 0.7));
			arrow.updateHitbox();
			arrow.alpha = 0.6;
			add(arrow);
			arrowSprites.push(arrow);
		}
	}

	public function pressArrow(lane:Int):Void
	{
		if (lane >= 0 && lane < arrowSprites.length)
		{
			var arrow = arrowSprites[lane];
			arrow.alpha = 1.0;
			FlxTween.tween(arrow, {alpha: 0.6}, 0.15, {ease: FlxEase.quadOut});
			// Pulse effect
			FlxTween.tween(arrow.scale, {x: 1.2, y: 1.2}, 0.05, {
				type: FlxTweenType.BACKWARD,
				ease: FlxEase.quadOut
			});
		}
	}

	public function updatePositions(scrollSpeed:Float, songPosition:Float, notes:Array<Dynamic>):Void
	{
		// Update arrow positions based on scroll speed and song position
		for (i in 0...arrowSprites.length)
		{
			if (i < notes.length)
			{
				var note = notes[i];
				var strumTime:Float = note.strumTime;
				var timeDiff = songPosition - strumTime;
				var yPos = arrowSprites[i].y + (timeDiff * 0.45 * scrollSpeed);

				// Arrow should scroll up/down based on direction
				if (timeDiff > 0)
				{
					// Note has passed - hide or mark as missed
					arrowSprites[i].alpha = 0.3;
				}
			}
		}
	}
}
