package;

import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.utils.Assets;
import openfl.utils.AssetType;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['play', 'freeplay', 'options', 'credits'];
	#else
	var optionShit:Array<String> = ['play', 'freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;

	public static var firstStart:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.8" + nightly;
	public static var gameVer:String = "0.2.7.1";

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	public static var finishedFunnyMove:Bool = false;

	// Custom menu background sprites
	private var menuBG:FlxSprite;
	private var menuDesat:FlxSprite;
	private var menuOverlay:FlxSprite;

	override function create()
	{
		trace(0 / 2);
		clean();
		PlayState.inDaPlay = false;
		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		// Try custom menu BG first, fallback to default
		if (openfl.utils.Assets.exists(Paths.image('images/Menus/Main/menuBG'), openfl.utils.AssetType.IMAGE))
		{
			menuBG = new FlxSprite(-100).loadGraphic(Paths.loadImage('Menus/Main/menuBG'));
		}
		else
		{
			menuBG = new FlxSprite(-100).loadGraphic(Paths.loadImage('menuBG'));
		}
		menuBG.scrollFactor.x = 0;
		menuBG.scrollFactor.y = 0.10;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = FlxG.save.data.antialiasing;
		add(menuBG);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		// Try custom menu desat first, fallback to default
		if (openfl.utils.Assets.exists(Paths.image('images/Menus/Main/menuDesat'), openfl.utils.AssetType.IMAGE))
		{
			menuDesat = new FlxSprite(-80).loadGraphic(Paths.loadImage('Menus/Main/menuDesat'));
		}
		else
		{
			menuDesat = new FlxSprite(-80).loadGraphic(Paths.loadImage('menuDesat'));
		}
		menuDesat.scrollFactor.x = 0;
		menuDesat.scrollFactor.y = 0.10;
		menuDesat.setGraphicSize(Std.int(menuDesat.width * 1.1));
		menuDesat.updateHitbox();
		menuDesat.screenCenter();
		menuDesat.visible = false;
		menuDesat.antialiasing = FlxG.save.data.antialiasing;
		menuDesat.color = 0xFFfd719b;
		add(menuDesat);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		// Try custom menu assets first, fallback to default
		var tex:FlxAtlasFrames;
		if (openfl.utils.Assets.exists(Paths.image('images/Menus/Main/Menu_assets'), openfl.utils.AssetType.IMAGE))
		{
			tex = Paths.getSparrowAtlas('Menus/Main/Menu_assets');
		}
		else
		{
			tex = Paths.getSparrowAtlas('FNF_main_menu_assets');
		}

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, FlxG.height * 1.6);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = FlxG.save.data.antialiasing;
			if (firstStart)
				FlxTween.tween(menuItem, {y: 60 + (i * 160)}, 1 + (i * 0.25), {
					ease: FlxEase.expoInOut,
					onComplete: function(flxTween:FlxTween)
					{
						finishedFunnyMove = true;
						changeItem();
					}
				});
			else
				menuItem.y = 60 + (i * 160);
		}

		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer + " | Kade Engine " + kadeEngineVer, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}
			}

			if (FlxG.keys.justPressed.UP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.DOWN)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					fancyOpenURL("https://ninja-muffin24.itch.io/funkin");
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if (FlxG.save.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							if (FlxG.save.data.flashing)
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									goToState();
								});
							}
							else
							{
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									goToState();
								});
							}
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'play':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");
			case 'freeplay':
				FlxG.switchState(new FreeplayState());
				trace("Freeplay Menu Selected");
			case 'options':
				FlxG.switchState(new OptionsDirect());
			case 'credits':
				FlxG.switchState(new CreditsState());
				trace("Credits Selected");
		}
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.animation.curAnim.frameRate = 24 * (60 / FlxG.save.data.fpsCap);

			spr.updateHitbox();
		});
	}
}
