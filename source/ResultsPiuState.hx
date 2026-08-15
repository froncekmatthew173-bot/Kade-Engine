package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxCamera;
import flixel.input.keyboard.FlxKey;

/**
 * ResultsPiuState - Custom PIU-style results screen.
 * Shows combo/miss counts with beat-synced animations.
 */
class ResultsPiuState extends FlxState
{
	private var bg:FlxSprite;
	private var primoRepair:FlxSprite;
	private var dancePad:FlxSprite;
	private var beethoven:FlxSprite;
	private var bgBeat:FlxSprite;

	private var comboLabel:FlxText;
	private var missLabel:FlxText;
	private var textSprite:FlxText;

	private var comboCount:Int = 0;
	private var missCount:Int = 0;
	private var bgButton1:FlxSprite;
	private var bgButton2:FlxSprite;

	public function new(combo:Int = 0, misses:Int = 0)
	{
		super();
		this.comboCount = combo;
		this.missCount = misses;

		// Botplay forces combo to 0
		if (PlayStateChangeables.botPlay)
			this.comboCount = 0;
	}

	override public function create():Void
	{
		super.create();

		// Background
		bg = new FlxSprite(0, 0).loadGraphic(Paths.loadImage('Menus/Results-Piu/bg'));
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		// Beat background
		bgBeat = new FlxSprite(0, 0).loadGraphic(Paths.loadImage('Menus/Results-Piu/bgBeat'));
		bgBeat.antialiasing = FlxG.save.data.antialiasing;
		bgBeat.alpha = 0;
		add(bgBeat);

		// Dance pad sprite
		dancePad = new FlxSprite(400, 300).loadGraphic(Paths.loadImage('Menus/Results-Piu/dancePad'));
		dancePad.antialiasing = FlxG.save.data.antialiasing;
		dancePad.alpha = 0;
		add(dancePad);

		// Beethoven sprite
		beethoven = new FlxSprite(600, 250).loadGraphic(Paths.loadImage('Menus/Results-Piu/beethoven'));
		beethoven.antialiasing = FlxG.save.data.antialiasing;
		beethoven.alpha = 0;
		add(beethoven);

		// Primo repair sprite
		primoRepair = new FlxSprite(200, 200).loadGraphic(Paths.loadImage('Menus/Results-Piu/primoRepair'));
		primoRepair.antialiasing = FlxG.save.data.antialiasing;
		primoRepair.alpha = 0;
		add(primoRepair);

		// Background buttons
		bgButton1 = new FlxSprite(0, 0).loadGraphic(Paths.loadImage('Menus/Results-Piu/bgBeat'));
		bgButton1.antialiasing = FlxG.save.data.antialiasing;
		bgButton1.alpha = 0;
		add(bgButton1);

		bgButton2 = new FlxSprite(0, 0).loadGraphic(Paths.loadImage('Menus/Results-Piu/bgBeat'));
		bgButton2.antialiasing = FlxG.save.data.antialiasing;
		bgButton2.alpha = 0;
		add(bgButton2);

		// Combo display
		comboLabel = new FlxText(870, 460, 0, "Combo: " + comboCount, 50);
		comboLabel.setFormat(Paths.font("vcr.ttf"), 50, 0xFF800080, CENTER);
		comboLabel.antialiasing = FlxG.save.data.antialiasing;
		comboLabel.alpha = 0;
		add(comboLabel);

		// Miss display
		missLabel = new FlxText(1090, 460, 0, "Misses: " + missCount, 50);
		missLabel.setFormat(Paths.font("vcr.ttf"), 50, 0xFF800080, CENTER);
		missLabel.antialiasing = FlxG.save.data.antialiasing;
		missLabel.alpha = 0;
		add(missLabel);

		// Result text
		var resultText = "CLEAR";
		if (missCount == 0)
			resultText = "FC";
		if (comboCount > 100)
			resultText = "AMAZING";

		textSprite = new FlxText(0, 100, FlxG.width, resultText, 60);
		textSprite.setFormat(Paths.font("vcr.ttf"), 60, 0xFFFFD700, CENTER);
		textSprite.antialiasing = FlxG.save.data.antialiasing;
		textSprite.alpha = 0;
		add(textSprite);

		// Animate in
		FlxTween.tween(bg, {alpha: 1}, 0.5);
		FlxTween.tween(dancePad, {alpha: 1}, 0.8, {startDelay: 0.2});
		FlxTween.tween(beethoven, {alpha: 1}, 0.8, {startDelay: 0.3});
		FlxTween.tween(primoRepair, {alpha: 1}, 0.8, {startDelay: 0.4});
		FlxTween.tween(comboLabel, {alpha: 1}, 0.5, {startDelay: 0.5});
		FlxTween.tween(missLabel, {alpha: 1}, 0.5, {startDelay: 0.6});
		FlxTween.tween(textSprite, {alpha: 1}, 0.5, {startDelay: 0.7});

		// Beat pulse on bgBeat
		FlxTween.tween(bgBeat, {alpha: 0.3}, 0.5, {startDelay: 0.3, type: FlxTweenType.PINGPONG});
	}

	override public function beatHit():Void
	{
		super.beatHit();

		// Beat-synced pulse animations
		if (bgButton1 != null && bgButton1.alpha > 0)
		{
			FlxTween.tween(bgButton1.scale, {x: 0.5, y: 0.5}, 0.2, {type: FlxTweenType.BACKWARD});
		}
		if (bgButton2 != null && bgButton2.alpha > 0)
		{
			FlxTween.tween(bgButton2.scale, {x: 0.5, y: 0.5}, 0.2, {type: FlxTweenType.BACKWARD});
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// Press any key to continue
		if (FlxG.keys.anyJustPressed([FlxKey.ENTER, FlxKey.SPACE, FlxKey.ESCAPE]))
		{
			FlxG.switchState(new MainMenuState());
		}
	}
}
