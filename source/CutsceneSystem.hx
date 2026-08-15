package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

/**
 * CutsceneSystem - Manages cutscene playback during gameplay.
 * Supports various cutscene types: derelict, splingo, atrocious, etc.
 */
class CutsceneSystem
{
	public static var instance:CutsceneSystem = null;
	public var isPlaying:Bool = false;
	private var currentState:FlxState;

	// Cutscene types
	public static inline var CUTSCENE_DERELICT:String = "derelict";
	public static inline var CUTSCENE_SPLINGO:String = "splingo";
	public static inline var CUTSCENE_ATROCIOUS:String = "atrocious";
	public static inline var CUTSCENE_SARAH:String = "sarah";
	public static inline var CUTSCENE_MIYA:String = "miya";

	public function new(state:FlxState)
	{
		instance = this;
		this.currentState = state;
	}

	/**
	 * Play a cutscene by type name.
	 */
	public function playCutscene(type:String, ?callback:Void->Void):Void
	{
		if (isPlaying)
			return;

		isPlaying = true;

		switch (type)
		{
			case CUTSCENE_DERELICT:
				playDerelictCutscene(callback);
			case CUTSCENE_SPLINGO:
				playSplingoCutscene(callback);
			case CUTSCENE_ATROCIOUS:
				playAtrociousCutscene(callback);
			case CUTSCENE_SARAH:
				playSarahCutscene(callback);
			case CUTSCENE_MIYA:
				playMiyaCutscene(callback);
			default:
				isPlaying = false;
				if (callback != null)
					callback();
		}
	}

	function playDerelictCutscene(?callback:Void->Void):Void
	{
		// Derelict cutscene: Shows the Derelict character appearing
		trace("Playing Derelict cutscene...");

		// Phase 1: Background shift
		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			// Show corrupted background
			if (PlayState.Stage != null)
			{
				var stage = PlayState.Stage;
				if (stage.swagBacks['delerictCutsceneBG'] != null)
					stage.swagBacks['delerictCutsceneBG'].visible = true;
				if (stage.swagBacks['delerictMain_BG'] != null)
					stage.swagBacks['delerictMain_BG'].visible = false;
			}
		});

		// Phase 2: Show Derelict body parts
		new FlxTimer().start(1.5, function(tmr:FlxTimer) {
			if (PlayState.Stage != null)
			{
				var stage = PlayState.Stage;
				if (stage.swagBacks['delerictBody'] != null)
					stage.swagBacks['delerictBody'].visible = true;
				if (stage.swagBacks['delerictEye1'] != null)
					stage.swagBacks['delerictEye1'].visible = true;
				if (stage.swagBacks['delerictEye2'] != null)
					stage.swagBacks['delerictEye2'].visible = true;
			}
		});

		// Phase 3: Show hands and complete cutscene
		new FlxTimer().start(3.0, function(tmr:FlxTimer) {
			if (PlayState.Stage != null)
			{
				var stage = PlayState.Stage;
				if (stage.swagBacks['delerictHand1'] != null)
					stage.swagBacks['delerictHand1'].visible = true;
				if (stage.swagBacks['delerictHand2'] != null)
					stage.swagBacks['delerictHand2'].visible = true;
			}
		});

		// Phase 4: End cutscene
		new FlxTimer().start(5.0, function(tmr:FlxTimer) {
			isPlaying = false;
			if (callback != null)
				callback();
		});
	}

	function playSplingoCutscene(?callback:Void->Void):Void
	{
		// Splingo cutscene: Jimble joins the stage
		trace("Playing Splingo cutscene...");

		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			if (PlayState.Stage != null)
			{
				var stage = PlayState.Stage;
				if (stage.swagBacks['jimbleIntro'] != null)
				{
					stage.swagBacks['jimbleIntro'].visible = true;
					stage.swagBacks['jimbleIntro'].animation.play('appear');
				}
			}
		});

		new FlxTimer().start(3.0, function(tmr:FlxTimer) {
			if (PlayState.Stage != null)
			{
				var stage = PlayState.Stage;
				if (stage.swagBacks['jimbleIntro'] != null)
					stage.swagBacks['jimbleIntro'].animation.play('idle');
			}
		});

		new FlxTimer().start(4.0, function(tmr:FlxTimer) {
			isPlaying = false;
			if (callback != null)
				callback();
		});
	}

	function playAtrociousCutscene(?callback:Void->Void):Void
	{
		// Atrocious cutscene
		trace("Playing Atrocious cutscene...");

		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			// Play cutscene animation
			FlxG.sound.play(Paths.sound('atrociousCutsceneSfx'));
		});

		new FlxTimer().start(3.0, function(tmr:FlxTimer) {
			isPlaying = false;
			if (callback != null)
				callback();
		});
	}

	function playSarahCutscene(?callback:Void->Void):Void
	{
		// Sarah cutscene: NewsMan grab sequence
		trace("Playing Sarah cutscene...");

		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			if (PlayState.Stage != null)
			{
				var stage = PlayState.Stage;
				if (stage.swagBacks['bgNewsMan'] != null)
					stage.swagBacks['bgNewsMan'].visible = true;
				if (stage.swagBacks['tvStartDejavu'] != null)
				{
					stage.swagBacks['tvStartDejavu'].visible = true;
					stage.swagBacks['tvStartDejavu'].animation.play('idle');
				}
			}
		});

		new FlxTimer().start(2.0, function(tmr:FlxTimer) {
			if (PlayState.Stage != null)
			{
				var stage = PlayState.Stage;
				if (stage.swagBacks['newsManGrabSarah'] != null)
					stage.swagBacks['newsManGrabSarah'].visible = true;
				if (stage.swagBacks['sarahSurprice'] != null)
				{
					stage.swagBacks['sarahSurprice'].visible = true;
					stage.swagBacks['sarahSurprice'].animation.play('idle');
				}
			}
		});

		new FlxTimer().start(4.0, function(tmr:FlxTimer) {
			isPlaying = false;
			if (callback != null)
				callback();
		});
	}

	function playMiyaCutscene(?callback:Void->Void):Void
	{
		// Miya cutscene: Rain and wind effects
		trace("Playing Miya cutscene...");

		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			if (PlayState.Stage != null)
			{
				var stage = PlayState.Stage;
				if (stage.swagBacks['miyaRain'] != null)
					stage.swagBacks['miyaRain'].visible = true;
				if (stage.swagBacks['miyaWind'] != null)
					stage.swagBacks['miyaWind'].visible = true;
				if (stage.swagBacks['miyaTalk'] != null)
					stage.swagBacks['miyaTalk'].visible = true;
			}
		});

		new FlxTimer().start(3.0, function(tmr:FlxTimer) {
			if (PlayState.Stage != null)
			{
				var stage = PlayState.Stage;
				if (stage.swagBacks['miyaText'] != null)
					stage.swagBacks['miyaText'].visible = true;
			}
		});

		new FlxTimer().start(5.0, function(tmr:FlxTimer) {
			isPlaying = false;
			if (callback != null)
				callback();
		});
	}

	/**
	 * Stop any currently playing cutscene.
	 */
	public function stopCutscene():Void
	{
		isPlaying = false;
	}
}
