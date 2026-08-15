package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxCamera;
import flixel.util.FlxColor;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 0;

	var credits:Array<CreditEntry> = [
		// Original FNF
		{
			name: "ninjamuffin99",
			role: "Programming",
			desc: "Lead Developer"
		},
		{
			name: "PhantomArcade",
			role: "Art & Animation",
			desc: "Lead Artist"
		},
		{
			name: "kawaisprite",
			role: "Music",
			desc: "Lead Composer"
		},
		{
			name: "evilsk8er",
			role: "Art",
			desc: "Character Design"
		},
		// Kade Engine
		{
			name: "Kade",
			role: "Kade Engine",
			desc: "Engine Developer"
		},
		// Custom mod credits
		{
			name: "Splingo",
			role: "Custom Characters",
			desc: "Splingo & Jimble Week"
		},
		{
			name: "The Derelict",
			role: "Custom Boss",
			desc: "Derelict Week"
		},
		{
			name: "Garretson",
			role: "Artificial Week",
			desc: "Artificial Characters"
		},
		{
			name: "Primo & Prima",
			role: "PIU/Chortle",
		.desc: "Pump It Up Content"
		},
		{
			name: "Sarah",
			role: "Deja-Vu Week",
			desc: "PIU Deja-Vu Content"
		},
		{
			name: "Miya",
			role: "Reality-Legacy",
			desc: "Reality Legacy Content"
		},
		{
			name: "Atrocious",
			role: "Atrocious Week",
			desc: "Atrocious Content"
		},
		{
			name: "Musical Cast",
			role: "Musical Week",
			desc: "Richard, Play, Mr Do You"
		},
		{
			name: "Artificial Cast",
			role: "Artificial Week",
			desc: "Vilbert, Maldo, Carl, Faldo"
		}
	];

	var grpCredits:FlxTypedGroup<FlxText>;
	var nameText:FlxText;
	var roleText:FlxText;
	var descText:FlxText;
	var bg:FlxSprite;
	var selectedSomethin:Bool = false;

	override function create()
	{
		#if FEATURE_DISCORD
		DiscordClient.changePresence("In the Credits", null);
		#end

		persistentUpdate = persistentDraw = true;

		// Background
		bg = new FlxSprite(-100).loadGraphic(Paths.loadImage('menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.antialiasing;
		bg.color = 0xFF444488;
		add(bg);

		// Title
		var titleText:FlxText = new FlxText(0, 30, FlxG.width, "CREDITS", 48);
		titleText.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleText.antialiasing = FlxG.save.data.antialiasing;
		titleText.scrollFactor.set();
		add(titleText);

		// Credits list
		grpCredits = new FlxTypedGroup<FlxText>();
		add(grpCredits);

		for (i in 0...credits.length)
		{
			var creditText:FlxText = new FlxText(0, 120 + (i * 45), FlxG.width, credits[i].name + " - " + credits[i].role, 20);
			creditText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			creditText.antialiasing = FlxG.save.data.antialiasing;
			creditText.scrollFactor.set();
			creditText.ID = i;
			grpCredits.add(creditText);
		}

		// Description text
		descText = new FlxText(0, FlxG.height - 80, FlxG.width, "", 16);
		descText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.antialiasing = FlxG.save.data.antialiasing;
		descText.scrollFactor.set();
		add(descText);

		// Navigation hint
		var hint:FlxText = new FlxText(0, FlxG.height - 30, FlxG.width, "Press BACK to return", 12);
		hint.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		hint.scrollFactor.set();
		add(hint);

		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!selectedSomethin)
		{
			if (FlxG.keys.justPressed.UP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(-1);
			}

			if (FlxG.keys.justPressed.DOWN)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(new MainMenuState());
			}
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = credits.length - 1;
		if (curSelected >= credits.length)
			curSelected = 0;

		// Update text colors
		grpCredits.forEach(function(txt:FlxText)
		{
			if (txt.ID == curSelected)
			{
				txt.color = FlxColor.YELLOW;
				txt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			}
			else
			{
				txt.color = FlxColor.WHITE;
				txt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			}
		});

		// Update description
		if (credits[curSelected] != null)
		{
			descText.text = credits[curSelected].desc;
		}
	}
}

typedef CreditEntry =
{
	var name:String;
	var role:String;
	var desc:String;
}
