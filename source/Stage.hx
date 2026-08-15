package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Stage extends MusicBeatState
{
	public var curStage:String = '';
	public var camZoom:Float; // The zoom of the camera to have at the start of the game
	public var hideLastBG:Bool = false; // True = hide last BGs and show ones from slowBacks on certain step, False = Toggle visibility of BGs from SlowBacks on certain step
	// Use visible property to manage if BG would be visible or not at the start of the game
	public var tweenDuration:Float = 2; // How long will it tween hiding/showing BGs, variable above must be set to True for tween to activate
	public var toAdd:Array<Dynamic> = []; // Add BGs on stage startup, load BG in by using "toAdd.push(bgVar);"
	// Layering algorithm for noobs: Everything loads by the method of "On Top", example: You load wall first(Every other added BG layers on it), then you load road(comes on top of wall and doesn't clip through it), then loading street lights(comes on top of wall and road)
	public var swagBacks:Map<String,
		Dynamic> = []; // Store BGs here to use them later (for example with slowBacks, using your custom stage event or to adjust position in stage debug menu(press 8 while in PlayState with debug build of the game))
	public var swagGroup:Map<String, FlxTypedGroup<Dynamic>> = []; // Store Groups
	public var animatedBacks:Array<FlxSprite> = []; // Store animated backgrounds and make them play animation(Animation must be named Idle!! Else use swagGroup/swagBacks and script it in stepHit/beatHit function of this file!!)
	public var layInFront:Array<Array<FlxSprite>> = [[], [], []]; // BG layering, format: first [0] - in front of GF, second [1] - in front of opponent, third [2] - in front of boyfriend(and technically also opponent since Haxe layering moment)
	public var slowBacks:Map<Int,
		Array<FlxSprite>> = []; // Change/add/remove backgrounds mid song! Format: "slowBacks[StepToBeActivated] = [Sprites,To,Be,Changed,Or,Added];"

	// BGs still must be added by using toAdd Array for them to show in game after slowBacks take effect!!
	// BGs still must be added by using toAdd Array for them to show in game after slowBacks take effect!!
	// All of the above must be set or used in your stage case code block!!
	public var positions:Map<String, Map<String, Array<Int>>> = [
		// Assign your characters positions on stage here!
		'halloween' => ['spooky' => [100, 300], 'monster' => [100, 200]],
		'philly' => ['pico' => [100, 400]],
		'limo' => ['bf-car' => [1030, 230]],
		'mall' => ['bf-christmas' => [970, 450], 'parents-christmas' => [-400, 100]],
		'mallEvil' => ['bf-christmas' => [1090, 450], 'monster-christmas' => [100, 150]],
		'school' => [
			'gf-pixel' => [580, 430],
			'bf-pixel' => [970, 670],
			'senpai' => [250, 460],
			'senpai-angry' => [250, 460]
		],
		'schoolEvil' => ['gf-pixel' => [580, 430], 'bf-pixel' => [970, 670], 'spirit' => [-50, 200]],
		// Custom stages from decompiled binary
		'derelict' => [
			'theDerelict' => [500, 100],
			'bf' => [770, 450],
			'gf' => [400, 130]
		],
		'mainStage_splingo' => [
			'splingo' => [100, 100],
			'bf' => [770, 450],
			'gf' => [400, 130]
		],
		'stageArtificial_garretson' => [
			'garretson' => [100, 100],
			'bf' => [770, 450],
			'gf' => [400, 130]
		],
		'stageArtificial_villbert' => [
			'vilbert' => [100, 100],
			'bf' => [770, 450],
			'gf' => [400, 130]
		],
		'stageArtificial_maldo' => [
			'maldo' => [100, 100],
			'bf' => [770, 450],
			'gf' => [400, 130]
		],
		'stageArtificial_carl' => [
			'carl' => [100, 100],
			'bf' => [770, 450],
			'gf' => [400, 130]
		],
		'chortle' => [
			'primo' => [100, 100],
			'bf' => [770, 450],
			'gf' => [400, 130]
		],
		'musical' => [
			'garretson' => [100, 100],
			'richard' => [473, 244],
			'play' => [261, 368],
			'bf' => [770, 450],
			'gf' => [400, 130]
		],
		'sarah' => [
			'sarah' => [100, 100],
			'bf' => [770, 450],
			'gf' => [400, 130]
		],
		'miya' => [
			'miya' => [100, 100],
			'bf' => [770, 450],
			'gf' => [400, 130]
		],
		'atrocious' => [
			'bf' => [770, 450],
			'gf' => [400, 130]
		],
		'blitz' => [
			'bf' => [770, 450],
			'gf' => [400, 130]
		],
		'minus' => [
			'bf' => [770, 450],
			'gf' => [400, 130]
		],
		'schoolCustom' => [
			'gf-pixel' => [580, 430],
			'bf-pixel' => [970, 670]
		]
	];

	public function new(daStage:String)
	{
		super();
		this.curStage = daStage;
		camZoom = 1.05; // Don't change zoom here, unless you want to change zoom of every stage that doesn't have custom one
		if (PlayStateChangeables.Optimize)
			return;

		switch (daStage)
		{
			case 'halloween':
				{
					var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

					var halloweenBG = new FlxSprite(-200, -80);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['halloweenBG'] = halloweenBG;
					toAdd.push(halloweenBG);
				}
			case 'philly':
				{
					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.loadImage('philly/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.loadImage('philly/city', 'week3'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					swagBacks['city'] = city;
					toAdd.push(city);

					var phillyCityLights = new FlxTypedGroup<FlxSprite>();
					if (FlxG.save.data.distractions)
					{
						swagGroup['phillyCityLights'] = phillyCityLights;
						toAdd.push(phillyCityLights);
					}

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.loadImage('philly/win' + i, 'week3'));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						light.antialiasing = FlxG.save.data.antialiasing;
						phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.loadImage('philly/behindTrain', 'week3'));
					swagBacks['streetBehind'] = streetBehind;
					toAdd.push(streetBehind);

					var phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.loadImage('philly/train', 'week3'));
					if (FlxG.save.data.distractions)
					{
						swagBacks['phillyTrain'] = phillyTrain;
						toAdd.push(phillyTrain);
					}

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'shared'));
					FlxG.sound.list.add(trainSound);

					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.loadImage('philly/street', 'week3'));
					swagBacks['street'] = street;
					toAdd.push(street);
				}
			case 'limo':
				{
					camZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.loadImage('limo/limoSunset', 'week4'));
					skyBG.scrollFactor.set(0.1, 0.1);
					skyBG.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['skyBG'] = skyBG;
					toAdd.push(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					bgLimo.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['bgLimo'] = bgLimo;
					toAdd.push(bgLimo);

					var fastCar:FlxSprite;
					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.loadImage('limo/fastCarLol', 'week4'));
					fastCar.antialiasing = FlxG.save.data.antialiasing;
					fastCar.visible = false;

					if (FlxG.save.data.distractions)
					{
						var grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
						swagGroup['grpLimoDancers'] = grpLimoDancers;
						toAdd.push(grpLimoDancers);

						for (i in 0...5)
						{
							var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
							dancer.scrollFactor.set(0.4, 0.4);
							grpLimoDancers.add(dancer);
							swagBacks['dancer' + i] = dancer;
						}

						swagBacks['fastCar'] = fastCar;
						layInFront[2].push(fastCar);
						resetFastCar();
					}

					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.loadImage('limo/limoOverlay', 'week4'));
					overlayShit.alpha = 0.5;
					// add(overlayShit);

					// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

					// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

					// overlayShit.shader = shaderBullshit;

					var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');

					var limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = FlxG.save.data.antialiasing;
					layInFront[0].push(limo);
					swagBacks['limo'] = limo;
				}
			case 'mall':
				{
					camZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.loadImage('christmas/bgWalls', 'week5'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
					upperBoppers.animation.addByPrefix('idle', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = FlxG.save.data.antialiasing;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					if (FlxG.save.data.distractions)
					{
						swagBacks['upperBoppers'] = upperBoppers;
						toAdd.push(upperBoppers);
						animatedBacks.push(upperBoppers);
					}

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.loadImage('christmas/bgEscalator', 'week5'));
					bgEscalator.antialiasing = FlxG.save.data.antialiasing;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					swagBacks['bgEscalator'] = bgEscalator;
					toAdd.push(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.loadImage('christmas/christmasTree', 'week5'));
					tree.antialiasing = FlxG.save.data.antialiasing;
					tree.scrollFactor.set(0.40, 0.40);
					swagBacks['tree'] = tree;
					toAdd.push(tree);

					var bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
					bottomBoppers.animation.addByPrefix('idle', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = FlxG.save.data.antialiasing;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					if (FlxG.save.data.distractions)
					{
						swagBacks['bottomBoppers'] = bottomBoppers;
						toAdd.push(bottomBoppers);
						animatedBacks.push(bottomBoppers);
					}

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.loadImage('christmas/fgSnow', 'week5'));
					fgSnow.active = false;
					fgSnow.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['fgSnow'] = fgSnow;
					toAdd.push(fgSnow);

					var santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = FlxG.save.data.antialiasing;
					if (FlxG.save.data.distractions)
					{
						swagBacks['santa'] = santa;
						toAdd.push(santa);
						animatedBacks.push(santa);
					}
				}
			case 'mallEvil':
				{
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.loadImage('christmas/evilBG', 'week5'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.loadImage('christmas/evilTree', 'week5'));
					evilTree.antialiasing = FlxG.save.data.antialiasing;
					evilTree.scrollFactor.set(0.2, 0.2);
					swagBacks['evilTree'] = evilTree;
					toAdd.push(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.loadImage("christmas/evilSnow", 'week5'));
					evilSnow.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['evilSnow'] = evilSnow;
					toAdd.push(evilSnow);
				}
			case 'school':
				{
					// defaultCamZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.loadImage('weeb/weebSky', 'week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					swagBacks['bgSky'] = bgSky;
					toAdd.push(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.loadImage('weeb/weebSchool', 'week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					swagBacks['bgSchool'] = bgSchool;
					toAdd.push(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.loadImage('weeb/weebStreet', 'week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					swagBacks['bgStreet'] = bgStreet;
					toAdd.push(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.loadImage('weeb/weebTreesBack', 'week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					swagBacks['fgTrees'] = fgTrees;
					toAdd.push(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					swagBacks['bgTrees'] = bgTrees;
					toAdd.push(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					swagBacks['treeLeaves'] = treeLeaves;
					toAdd.push(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					var bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					// if (PlayState.SONG.songId.toLowerCase() == 'roses')
					if (GameplayCustomizeState.freeplaySong == 'roses')
					{
						if (FlxG.save.data.distractions)
							bgGirls.getScared();
					}

					bgGirls.setGraphicSize(Std.int(bgGirls.width * CoolUtil.daPixelZoom));
					bgGirls.updateHitbox();
					if (FlxG.save.data.distractions)
					{
						swagBacks['bgGirls'] = bgGirls;
						toAdd.push(bgGirls);
					}
				}
			case 'schoolEvil':
				{
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

					var posX = 400;
					var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					/* 
						var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.loadImage('weeb/evilSchoolBG'));
						bg.scale.set(6, 6);
						// bg.setGraphicSize(Std.int(bg.width * 6));
						// bg.updateHitbox();
						add(bg);
						var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.loadImage('weeb/evilSchoolFG'));
						fg.scale.set(6, 6);
						// fg.setGraphicSize(Std.int(fg.width * 6));
						// fg.updateHitbox();
						add(fg);
						wiggleShit.effectType = WiggleEffectType.DREAMY;
						wiggleShit.waveAmplitude = 0.01;
						wiggleShit.waveFrequency = 60;
						wiggleShit.waveSpeed = 0.8;
					 */

					// bg.shader = wiggleShit.shader;
					// fg.shader = wiggleShit.shader;

					/* 
						var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
						var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);
						// Using scale since setGraphicSize() doesnt work???
						waveSprite.scale.set(6, 6);
						waveSpriteFG.scale.set(6, 6);
						waveSprite.setPosition(posX, posY);
						waveSpriteFG.setPosition(posX, posY);
						waveSprite.scrollFactor.set(0.7, 0.8);
						waveSpriteFG.scrollFactor.set(0.9, 0.8);
						// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
						// waveSprite.updateHitbox();
						// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
						// waveSpriteFG.updateHitbox();
						add(waveSprite);
						add(waveSpriteFG);
					 */
				}
			// ============================================
			// DERELICT STAGE - Multi-layer boss stage
			// ============================================
			case 'derelict':
				{
					camZoom = 0.85;

					var delerictMain_BG = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/derelict/delerictMain_BG'));
					delerictMain_BG.antialiasing = FlxG.save.data.antialiasing;
					delerictMain_BG.scrollFactor.set(0.9, 0.9);
					swagBacks['delerictMain_BG'] = delerictMain_BG;
					toAdd.push(delerictMain_BG);

					var delerictBack1Main_BG = new FlxSprite(-300, -150).loadGraphic(Paths.loadImage('bgs/derelict/delerictBack1Main_BG'));
					delerictBack1Main_BG.antialiasing = FlxG.save.data.antialiasing;
					delerictBack1Main_BG.scrollFactor.set(0.6, 0.6);
					swagBacks['delerictBack1Main_BG'] = delerictBack1Main_BG;
					toAdd.push(delerictBack1Main_BG);

					var delerictBack2Main_BG = new FlxSprite(-250, -120).loadGraphic(Paths.loadImage('bgs/derelict/delerictBack2Main_BG'));
					delerictBack2Main_BG.antialiasing = FlxG.save.data.antialiasing;
					delerictBack2Main_BG.scrollFactor.set(0.7, 0.7);
					swagBacks['delerictBack2Main_BG'] = delerictBack2Main_BG;
					toAdd.push(delerictBack2Main_BG);

					var delerictLeech_blocks = new FlxSprite(-100, 200).loadGraphic(Paths.loadImage('bgs/derelict/delerictLeech_blocks'));
					delerictLeech_blocks.antialiasing = FlxG.save.data.antialiasing;
					delerictLeech_blocks.visible = false;
					swagBacks['delerictLeech_blocks'] = delerictLeech_blocks;
					toAdd.push(delerictLeech_blocks);

					var delerictCutsceneBG = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/derelict/delerictCutsceneBG'));
					delerictCutsceneBG.antialiasing = FlxG.save.data.antialiasing;
					delerictCutsceneBG.visible = false;
					swagBacks['delerictCutsceneBG'] = delerictCutsceneBG;
					toAdd.push(delerictCutsceneBG);

					var delerictScrewRed_BG = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/derelict/delerictScrewRed_BG'));
					delerictScrewRed_BG.antialiasing = FlxG.save.data.antialiasing;
					delerictScrewRed_BG.visible = false;
					swagBacks['delerictScrewRed_BG'] = delerictScrewRed_BG;
					toAdd.push(delerictScrewRed_BG);

					var delerictCorrupted_BG = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/derelict/delerictCorrupted_BG'));
					delerictCorrupted_BG.antialiasing = FlxG.save.data.antialiasing;
					delerictCorrupted_BG.visible = false;
					swagBacks['delerictCorrupted_BG'] = delerictCorrupted_BG;
					toAdd.push(delerictCorrupted_BG);

					var derelictStickers = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/derelict/derelictStickers'));
					derelictStickers.antialiasing = FlxG.save.data.antialiasing;
					derelictStickers.visible = false;
					swagBacks['derelictStickers'] = derelictStickers;
					layInFront[0].push(derelictStickers);

					// Derelict body parts for cutscene
					var delerictBody = new FlxSprite(500, 100);
					delerictBody.frames = Paths.getSparrowAtlas('bgs/derelict/delerictBody');
					delerictBody.animation.addByPrefix('idle', 'idle', 24, false);
					delerictBody.animation.play('idle');
					delerictBody.antialiasing = FlxG.save.data.antialiasing;
					delerictBody.visible = false;
					swagBacks['delerictBody'] = delerictBody;
					layInFront[1].push(delerictBody);

					var delerictEye1 = new FlxSprite(520, 80);
					delerictEye1.frames = Paths.getSparrowAtlas('bgs/derelict/delerictEye1');
					delerictEye1.animation.addByPrefix('idle', 'idle', 24, false);
					delerictEye1.animation.play('idle');
					delerictEye1.antialiasing = FlxG.save.data.antialiasing;
					delerictEye1.visible = false;
					swagBacks['delerictEye1'] = delerictEye1;
					layInFront[1].push(delerictEye1);

					var delerictEye2 = new FlxSprite(540, 80);
					delerictEye2.frames = Paths.getSparrowAtlas('bgs/derelict/delerictEye2');
					delerictEye2.animation.addByPrefix('idle', 'idle', 24, false);
					delerictEye2.animation.play('idle');
					delerictEye2.antialiasing = FlxG.save.data.antialiasing;
					delerictEye2.visible = false;
					swagBacks['delerictEye2'] = delerictEye2;
					layInFront[1].push(delerictEye2);

					var delerictHand1 = new FlxSprite(400, 200);
					delerictHand1.frames = Paths.getSparrowAtlas('bgs/derelict/delerictHand1');
					delerictHand1.animation.addByPrefix('idle', 'idle', 24, false);
					delerictHand1.animation.play('idle');
					delerictHand1.antialiasing = FlxG.save.data.antialiasing;
					delerictHand1.visible = false;
					swagBacks['delerictHand1'] = delerictHand1;
					layInFront[2].push(delerictHand1);

					var delerictHand2 = new FlxSprite(600, 200);
					delerictHand2.frames = Paths.getSparrowAtlas('bgs/derelict/delerictHand2');
					delerictHand2.animation.addByPrefix('idle', 'idle', 24, false);
					delerictHand2.animation.play('idle');
					delerictHand2.antialiasing = FlxG.save.data.antialiasing;
					delerictHand2.visible = false;
					swagBacks['delerictHand2'] = delerictHand2;
					layInFront[2].push(delerictHand2);

					// Step-triggered BGs
					slowBacks[0] = [];
				}

			// ============================================
			// SPLINGO STAGE - Splingo & Jimble
			// ============================================
			case 'mainStage_splingo':
				{
					camZoom = 0.9;

					var splingoBG = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/splingo/splingoBG'));
					splingoBG.antialiasing = FlxG.save.data.antialiasing;
					splingoBG.scrollFactor.set(0.9, 0.9);
					swagBacks['splingoBG'] = splingoBG;
					toAdd.push(splingoBG);

					var jimbleIntro = new FlxSprite(300, 100);
					jimbleIntro.frames = Paths.getSparrowAtlas('bgs/splingo/jimble_intro');
					jimbleIntro.animation.addByPrefix('idle', 'idle', 24, false);
					jimbleIntro.animation.addByPrefix('appear', 'appear', 24, false);
					jimbleIntro.animation.play('idle');
					jimbleIntro.antialiasing = FlxG.save.data.antialiasing;
					jimbleIntro.visible = false;
					swagBacks['jimbleIntro'] = jimbleIntro;
					layInFront[1].push(jimbleIntro);

					var squash = new FlxSprite(400, 150);
					squash.frames = Paths.getSparrowAtlas('bgs/splingo/squash');
					squash.animation.addByPrefix('appear', 'appear', 24, false);
					squash.animation.addByPrefix('idle', 'idle', 24, false);
					squash.animation.play('appear');
					squash.antialiasing = FlxG.save.data.antialiasing;
					squash.visible = false;
					swagBacks['squash'] = squash;
					layInFront[1].push(squash);

					var explostion = new FlxSprite(350, 120);
					explostion.frames = Paths.getSparrowAtlas('bgs/splingo/explostion');
					explostion.animation.addByPrefix('idle', 'idle', 24, false);
					explostion.animation.play('idle');
					explostion.antialiasing = FlxG.save.data.antialiasing;
					explostion.visible = false;
					swagBacks['explostion'] = explostion;
					layInFront[1].push(explostion);
				}

			// ============================================
			// ARTIFICIAL STAGES - Garretson, Villbert, Maldo, Carl
			// ============================================
			case 'stageArtificial_garretson':
				{
					camZoom = 0.9;

					var garretson_back = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/artificial/stages/garretson_back'));
					garretson_back.antialiasing = FlxG.save.data.antialiasing;
					garretson_back.scrollFactor.set(0.9, 0.9);
					swagBacks['garretson_back'] = garretson_back;
					toAdd.push(garretson_back);

					var garretsonScreenSinging = new FlxSprite(100, 50);
					garretsonScreenSinging.frames = Paths.getSparrowAtlas('bgs/artificial/garretsonScreenSinging');
					garretsonScreenSinging.animation.addByPrefix('idle', 'idle', 24, false);
					garretsonScreenSinging.animation.play('idle');
					garretsonScreenSinging.antialiasing = FlxG.save.data.antialiasing;
					garretsonScreenSinging.scrollFactor.set(0.6, 0.6);
					swagBacks['garretsonScreenSinging'] = garretsonScreenSinging;
					toAdd.push(garretsonScreenSinging);

					var garretsonFunnys = new FlxSprite(150, 100);
					garretsonFunnys.frames = Paths.getSparrowAtlas('bgs/artificial/garretsonFunnys');
					garretsonFunnys.animation.addByPrefix('idle', 'idle', 24, false);
					garretsonFunnys.animation.play('idle');
					garretsonFunnys.antialiasing = FlxG.save.data.antialiasing;
					garretsonFunnys.visible = false;
					swagBacks['garretsonFunnys'] = garretsonFunnys;
					toAdd.push(garretsonFunnys);

					var artificial_star = new FlxSprite(-100, -50).loadGraphic(Paths.loadImage('bgs/artificial/artificial_star'));
					artificial_star.antialiasing = FlxG.save.data.antialiasing;
					artificial_star.scrollFactor.set(0.3, 0.3);
					swagBacks['artificial_star'] = artificial_star;
					toAdd.push(artificial_star);
				}

			case 'stageArtificial_villbert':
				{
					camZoom = 0.9;

					var vilbert_back = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/artificial/stages/vilbert_back'));
					vilbert_back.antialiasing = FlxG.save.data.antialiasing;
					vilbert_back.scrollFactor.set(0.9, 0.9);
					swagBacks['vilbert_back'] = vilbert_back;
					toAdd.push(vilbert_back);

					var artificial_star = new FlxSprite(-100, -50).loadGraphic(Paths.loadImage('bgs/artificial/artificial_star'));
					artificial_star.antialiasing = FlxG.save.data.antialiasing;
					artificial_star.scrollFactor.set(0.3, 0.3);
					swagBacks['artificial_star'] = artificial_star;
					toAdd.push(artificial_star);
				}

			case 'stageArtificial_maldo':
				{
					camZoom = 0.9;

					var maldo_back = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/artificial/stages/maldo_back'));
					maldo_back.antialiasing = FlxG.save.data.antialiasing;
					maldo_back.scrollFactor.set(0.9, 0.9);
					swagBacks['maldo_back'] = maldo_back;
					toAdd.push(maldo_back);

					var artificial_star = new FlxSprite(-100, -50).loadGraphic(Paths.loadImage('bgs/artificial/artificial_star'));
					artificial_star.antialiasing = FlxG.save.data.antialiasing;
					artificial_star.scrollFactor.set(0.3, 0.3);
					swagBacks['artificial_star'] = artificial_star;
					toAdd.push(artificial_star);
				}

			case 'stageArtificial_carl':
				{
					camZoom = 0.9;

					var carl_back = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/artificial/stages/carl_back'));
					carl_back.antialiasing = FlxG.save.data.antialiasing;
					carl_back.scrollFactor.set(0.9, 0.9);
					swagBacks['carl_back'] = carl_back;
					toAdd.push(carl_back);

					var artificial_star = new FlxSprite(-100, -50).loadGraphic(Paths.loadImage('bgs/artificial/artificial_star'));
					artificial_star.antialiasing = FlxG.save.data.antialiasing;
					artificial_star.scrollFactor.set(0.3, 0.3);
					swagBacks['artificial_star'] = artificial_star;
					toAdd.push(artificial_star);
				}

			// ============================================
			// CHORTLE / PIU STAGE - Dance pad stage
			// ============================================
			case 'chortle':
				{
					camZoom = 0.85;

					var bgChortleMain = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/chortle/bgChortleMain'));
					bgChortleMain.antialiasing = FlxG.save.data.antialiasing;
					bgChortleMain.scrollFactor.set(0.9, 0.9);
					swagBacks['bgChortleMain'] = bgChortleMain;
					toAdd.push(bgChortleMain);

					var piuBgChortleMain = new FlxSprite(-150, -80).loadGraphic(Paths.loadImage('bgs/chortle/piuBgChortleMain'));
					piuBgChortleMain.antialiasing = FlxG.save.data.antialiasing;
					piuBgChortleMain.scrollFactor.set(0.7, 0.7);
					swagBacks['piuBgChortleMain'] = piuBgChortleMain;
					toAdd.push(piuBgChortleMain);

					var piuBgChortleMain2 = new FlxSprite(-100, -50).loadGraphic(Paths.loadImage('bgs/chortle/piuBgChortleMain2'));
					piuBgChortleMain2.antialiasing = FlxG.save.data.antialiasing;
					piuBgChortleMain2.scrollFactor.set(0.8, 0.8);
					swagBacks['piuBgChortleMain2'] = piuBgChortleMain2;
					toAdd.push(piuBgChortleMain2);

					var piuMachineChortle = new FlxSprite(100, 200).loadGraphic(Paths.loadImage('bgs/chortle/piuMachineChortle'));
					piuMachineChortle.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['piuMachineChortle'] = piuMachineChortle;
					toAdd.push(piuMachineChortle);

					var dancePadsChortle = new FlxSprite(200, 350).loadGraphic(Paths.loadImage('bgs/chortle/dancePadsChortle'));
					dancePadsChortle.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['dancePadsChortle'] = dancePadsChortle;
					toAdd.push(dancePadsChortle);

					var piuBgChortleScreen = new FlxSprite(50, 50);
					piuBgChortleScreen.frames = Paths.getSparrowAtlas('bgs/chortle/piuBgChortleScreen');
					piuBgChortleScreen.animation.addByPrefix('idle', 'idle', 24, false);
					piuBgChortleScreen.animation.play('idle');
					piuBgChortleScreen.antialiasing = FlxG.save.data.antialiasing;
					piuBgChortleScreen.scrollFactor.set(0.6, 0.6);
					swagBacks['piuBgChortleScreen'] = piuBgChortleScreen;
					toAdd.push(piuBgChortleScreen);

					// Prima animated background
					var primaNormalBG = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/chortle/primaNormalBG'));
					primaNormalBG.antialiasing = FlxG.save.data.antialiasing;
					primaNormalBG.scrollFactor.set(0.5, 0.5);
					swagBacks['primaNormalBG'] = primaNormalBG;
					toAdd.push(primaNormalBG);

					var primaDancingBG = new FlxSprite(-200, -100);
					primaDancingBG.frames = Paths.getSparrowAtlas('bgs/chortle/prima/primaDacing');
					primaDancingBG.animation.addByPrefix('idle', 'idle', 24, false);
					primaDancingBG.animation.play('idle');
					primaDancingBG.antialiasing = FlxG.save.data.antialiasing;
					primaDancingBG.scrollFactor.set(0.5, 0.5);
					primaDancingBG.visible = false;
					swagBacks['primaDancingBG'] = primaDancingBG;
					toAdd.push(primaDancingBG);

					// Miku backgrounds
					var mikuNormalBG = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/chortle/mikuNormalBG'));
					mikuNormalBG.antialiasing = FlxG.save.data.antialiasing;
					mikuNormalBG.scrollFactor.set(0.5, 0.5);
					mikuNormalBG.visible = false;
					swagBacks['mikuNormalBG'] = mikuNormalBG;
					toAdd.push(mikuNormalBG);

					var mikuDancingBG = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/chortle/mikuDancingBG'));
					mikuDancingBG.antialiasing = FlxG.save.data.antialiasing;
					mikuDancingBG.scrollFactor.set(0.5, 0.5);
					mikuDancingBG.visible = false;
					swagBacks['mikuDancingBG'] = mikuDancingBG;
					toAdd.push(mikuDancingBG);

					var pumpArrowsBG = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/chortle/pumpArrowsBG'));
					pumpArrowsBG.antialiasing = FlxG.save.data.antialiasing;
					pumpArrowsBG.scrollFactor.set(0.9, 0.9);
					pumpArrowsBG.visible = false;
					swagBacks['pumpArrowsBG'] = pumpArrowsBG;
					toAdd.push(pumpArrowsBG);

					// PIU arrows overlay
					var piuArrows = new FlxSprite(300, 400);
					piuArrows.frames = Paths.getSparrowAtlas('bgs/chortle/piuStage/arrows');
					piuArrows.animation.addByPrefix('idle', 'idle', 24, false);
					piuArrows.animation.play('idle');
					piuArrows.antialiasing = FlxG.save.data.antialiasing;
					piuArrows.scrollFactor.set(1.0, 1.0);
					swagBacks['piuArrows'] = piuArrows;
					layInFront[2].push(piuArrows);

					var screenPiu = new FlxSprite(100, 50);
					screenPiu.frames = Paths.getSparrowAtlas('bgs/chortle/piuScreen');
					screenPiu.animation.addByPrefix('idle', 'idle', 24, false);
					screenPiu.animation.play('idle');
					screenPiu.antialiasing = FlxG.save.data.antialiasing;
					screenPiu.scrollFactor.set(0.6, 0.6);
					swagBacks['screenPiu'] = screenPiu;
					toAdd.push(screenPiu);

					var trashCanChortle = new FlxSprite(800, 350).loadGraphic(Paths.loadImage('bgs/chortle/trashCanChortle'));
					trashCanChortle.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['trashCanChortle'] = trashCanChortle;
					layInFront[2].push(trashCanChortle);

					// Dance pad side overlays
					var leftDancePadChortle = new FlxSprite(-100, 300).loadGraphic(Paths.loadImage('bgs/chortle/leftDancePadChortle'));
					leftDancePadChortle.antialiasing = FlxG.save.data.antialiasing;
					leftDancePadChortle.visible = false;
					swagBacks['leftDancePadChortle'] = leftDancePadChortle;
					layInFront[2].push(leftDancePadChortle);

					var rightDancePadChortle = new FlxSprite(700, 300).loadGraphic(Paths.loadImage('bgs/chortle/rightDancePadChortle'));
					rightDancePadChortle.antialiasing = FlxG.save.data.antialiasing;
					rightDancePadChortle.visible = false;
					swagBacks['rightDancePadChortle'] = rightDancePadChortle;
					layInFront[2].push(rightDancePadChortle);
				}

			// ============================================
			// MUSICAL STAGE
			// ============================================
			case 'musical':
				{
					camZoom = 0.9;

					var musicalPlanta = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/musical/planta'));
					musicalPlanta.antialiasing = FlxG.save.data.antialiasing;
					musicalPlanta.scrollFactor.set(0.9, 0.9);
					swagBacks['musicalPlanta'] = musicalPlanta;
					toAdd.push(musicalPlanta);
				}

			// ============================================
			// SARAH / DEJA-VU STAGE
			// ============================================
			case 'sarah':
				{
					camZoom = 0.85;

					var bgFinalDejavu = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/PIU/Deja-vu/bgFinalDejavu'));
					bgFinalDejavu.antialiasing = FlxG.save.data.antialiasing;
					bgFinalDejavu.scrollFactor.set(0.9, 0.9);
					swagBacks['bgFinalDejavu'] = bgFinalDejavu;
					toAdd.push(bgFinalDejavu);

					var bgNewsMan = new FlxSprite(-150, -80).loadGraphic(Paths.loadImage('bgs/PIU/Deja-vu/bgNewsMan'));
					bgNewsMan.antialiasing = FlxG.save.data.antialiasing;
					bgNewsMan.scrollFactor.set(0.7, 0.7);
					bgNewsMan.visible = false;
					swagBacks['bgNewsMan'] = bgNewsMan;
					toAdd.push(bgNewsMan);

					var purplething = new FlxSprite(-100, -50).loadGraphic(Paths.loadImage('bgs/PIU/Deja-vu/purplething'));
					purplething.antialiasing = FlxG.save.data.antialiasing;
					purplething.scrollFactor.set(0.6, 0.6);
					purplething.visible = false;
					swagBacks['purplething'] = purplething;
					toAdd.push(purplething);

					var purplething2 = new FlxSprite(-80, -30).loadGraphic(Paths.loadImage('bgs/PIU/Deja-vu/purplething2'));
					purplething2.antialiasing = FlxG.save.data.antialiasing;
					purplething2.scrollFactor.set(0.65, 0.65);
					purplething2.visible = false;
					swagBacks['purplething2'] = purplething2;
					toAdd.push(purplething2);

					var smileDejavu1 = new FlxSprite(100, 100).loadGraphic(Paths.loadImage('bgs/PIU/Deja-vu/smileDejavu1'));
					smileDejavu1.antialiasing = FlxG.save.data.antialiasing;
					smileDejavu1.visible = false;
					swagBacks['smileDejavu1'] = smileDejavu1;
					toAdd.push(smileDejavu1);

					var smileDejavu2 = new FlxSprite(200, 150).loadGraphic(Paths.loadImage('bgs/PIU/Deja-vu/smileDejavu2'));
					smileDejavu2.antialiasing = FlxG.save.data.antialiasing;
					smileDejavu2.visible = false;
					swagBacks['smileDejavu2'] = smileDejavu2;
					toAdd.push(smileDejavu2);

					var bombBGsprite1 = new FlxSprite(0, 0).loadGraphic(Paths.loadImage('bgs/PIU/Deja-vu/bombBGsprite1'));
					bombBGsprite1.antialiasing = FlxG.save.data.antialiasing;
					bombBGsprite1.visible = false;
					swagBacks['bombBGsprite1'] = bombBGsprite1;
					toAdd.push(bombBGsprite1);

					var bombBGsprite2 = new FlxSprite(50, 50).loadGraphic(Paths.loadImage('bgs/PIU/Deja-vu/bombBGsprite2'));
					bombBGsprite2.antialiasing = FlxG.save.data.antialiasing;
					bombBGsprite2.visible = false;
					swagBacks['bombBGsprite2'] = bombBGsprite2;
					toAdd.push(bombBGsprite2);

					var sarahAnims = new FlxSprite(300, 200);
					sarahAnims.frames = Paths.getSparrowAtlas('bgs/PIU/Deja-vu/sarahAnims');
					sarahAnims.animation.addByPrefix('idle', 'idle', 24, false);
					sarahAnims.animation.play('idle');
					sarahAnims.antialiasing = FlxG.save.data.antialiasing;
					sarahAnims.visible = false;
					swagBacks['sarahAnims'] = sarahAnims;
					layInFront[1].push(sarahAnims);

					var newsManGrabSarah = new FlxSprite(400, 250).loadGraphic(Paths.loadImage('bgs/PIU/Deja-vu/newsManGrabSarah'));
					newsManGrabSarah.antialiasing = FlxG.save.data.antialiasing;
					newsManGrabSarah.visible = false;
					swagBacks['newsManGrabSarah'] = newsManGrabSarah;
					layInFront[1].push(newsManGrabSarah);

					var tvStartDejavu = new FlxSprite(100, 50);
					tvStartDejavu.frames = Paths.getSparrowAtlas('bgs/PIU/Deja-vu/tvStartDejavu');
					tvStartDejavu.animation.addByPrefix('idle', 'idle', 24, false);
					tvStartDejavu.animation.play('idle');
					tvStartDejavu.antialiasing = FlxG.save.data.antialiasing;
					tvStartDejavu.visible = false;
					swagBacks['tvStartDejavu'] = tvStartDejavu;
					layInFront[0].push(tvStartDejavu);

					var sarahSurprice = new FlxSprite(350, 200);
					sarahSurprice.frames = Paths.getSparrowAtlas('bgs/PIU/Deja-vu/sarahSurprice');
					sarahSurprice.animation.addByPrefix('idle', 'idle', 24, false);
					sarahSurprice.animation.play('idle');
					sarahSurprice.antialiasing = FlxG.save.data.antialiasing;
					sarahSurprice.visible = false;
					swagBacks['sarahSurprice'] = sarahSurprice;
					layInFront[1].push(sarahSurprice);

					var darkness = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/PIU/Deja-vu/Darkness'));
					darkness.antialiasing = FlxG.save.data.antialiasing;
					darkness.alpha = 0;
					swagBacks['darkness'] = darkness;
					layInFront[0].push(darkness);
				}

			// ============================================
			// MIYA / REALITY-LEGACY STAGE
			// ============================================
			case 'miya':
				{
					camZoom = 0.85;

					for (i in 1...5)
					{
						var miyaBG = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/PIU/Reality_Legacy/miyaBG' + i));
						miyaBG.antialiasing = FlxG.save.data.antialiasing;
						miyaBG.scrollFactor.set(0.9, 0.9);
						miyaBG.visible = (i == 1);
						swagBacks['miyaBG' + i] = miyaBG;
						toAdd.push(miyaBG);
					}

					for (i in 1...5)
					{
						var miyaCity = new FlxSprite(-150, -80).loadGraphic(Paths.loadImage('bgs/PIU/Reality_Legacy/miyaCity' + i));
						miyaCity.antialiasing = FlxG.save.data.antialiasing;
						miyaCity.scrollFactor.set(0.7, 0.7);
						miyaCity.visible = false;
						swagBacks['miyaCity' + i] = miyaCity;
						toAdd.push(miyaCity);
					}

					var miyaWhiteCircules = new FlxSprite(-100, -50).loadGraphic(Paths.loadImage('bgs/PIU/Reality_Legacy/miyaWhiteCircules'));
					miyaWhiteCircules.antialiasing = FlxG.save.data.antialiasing;
					miyaWhiteCircules.scrollFactor.set(0.6, 0.6);
					miyaWhiteCircules.visible = false;
					swagBacks['miyaWhiteCircules'] = miyaWhiteCircules;
					toAdd.push(miyaWhiteCircules);

					var miyaHeartBG = new FlxSprite(-100, -50).loadGraphic(Paths.loadImage('bgs/PIU/Reality_Legacy/miyaHeartBG'));
					miyaHeartBG.antialiasing = FlxG.save.data.antialiasing;
					miyaHeartBG.scrollFactor.set(0.8, 0.8);
					miyaHeartBG.visible = false;
					swagBacks['miyaHeartBG'] = miyaHeartBG;
					toAdd.push(miyaHeartBG);

					var miyaHearts = new FlxSprite(0, 0);
					miyaHearts.frames = Paths.getSparrowAtlas('bgs/PIU/Reality_Legacy/miyaHearts');
					miyaHearts.animation.addByPrefix('idle', 'idle', 24, false);
					miyaHearts.animation.play('idle');
					miyaHearts.antialiasing = FlxG.save.data.antialiasing;
					miyaHearts.scrollFactor.set(0.5, 0.5);
					miyaHearts.visible = false;
					swagBacks['miyaHearts'] = miyaHearts;
					toAdd.push(miyaHearts);

					var miyaSadBG = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/PIU/Reality_Legacy/miyaSadBG'));
					miyaSadBG.antialiasing = FlxG.save.data.antialiasing;
					miyaSadBG.scrollFactor.set(0.9, 0.9);
					miyaSadBG.visible = false;
					swagBacks['miyaSadBG'] = miyaSadBG;
					toAdd.push(miyaSadBG);

					var miyaRain = new FlxSprite(-200, -100);
					miyaRain.frames = Paths.getSparrowAtlas('bgs/PIU/Reality_Legacy/rain');
					miyaRain.animation.addByPrefix('idle', 'idle', 24, false);
					miyaRain.animation.play('idle');
					miyaRain.antialiasing = FlxG.save.data.antialiasing;
					miyaRain.scrollFactor.set(1.0, 1.0);
					miyaRain.visible = false;
					swagBacks['miyaRain'] = miyaRain;
					layInFront[0].push(miyaRain);

					var miyaWind = new FlxSprite(-100, 0);
					miyaWind.frames = Paths.getSparrowAtlas('pops/PIU/reality-legacy/wind');
					miyaWind.animation.addByPrefix('idle', 'idle', 24, false);
					miyaWind.animation.play('idle');
					miyaWind.antialiasing = FlxG.save.data.antialiasing;
					miyaWind.scrollFactor.set(1.0, 1.0);
					miyaWind.visible = false;
					swagBacks['miyaWind'] = miyaWind;
					layInFront[0].push(miyaWind);

					var miyaTalk = new FlxSprite(300, 200);
					miyaTalk.frames = Paths.getSparrowAtlas('pops/PIU/reality-legacy/stay_a_long_way');
					miyaTalk.animation.addByPrefix('idle', 'idle', 24, false);
					miyaTalk.animation.play('idle');
					miyaTalk.antialiasing = FlxG.save.data.antialiasing;
					miyaTalk.visible = false;
					swagBacks['miyaTalk'] = miyaTalk;
					layInFront[1].push(miyaTalk);

					var miyaTalkMouth = new FlxSprite(320, 220);
					miyaTalkMouth.frames = Paths.getSparrowAtlas('pops/PIU/reality-legacy/stay_a_long_way_mouth');
					miyaTalkMouth.animation.addByPrefix('idle', 'idle', 24, false);
					miyaTalkMouth.animation.play('idle');
					miyaTalkMouth.antialiasing = FlxG.save.data.antialiasing;
					miyaTalkMouth.visible = false;
					swagBacks['miyaTalkMouth'] = miyaTalkMouth;
					layInFront[1].push(miyaTalkMouth);

					var miyaText = new FlxSprite(200, 100);
					miyaText.frames = Paths.getSparrowAtlas('pops/PIU/reality-legacy/text');
					miyaText.animation.addByPrefix('idle', 'idle', 24, false);
					miyaText.animation.play('idle');
					miyaText.antialiasing = FlxG.save.data.antialiasing;
					miyaText.visible = false;
					swagBacks['miyaText'] = miyaText;
					layInFront[1].push(miyaText);

					var darkness = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/PIU/Reality_Legacy/darkness'));
					darkness.antialiasing = FlxG.save.data.antialiasing;
					darkness.alpha = 0;
					swagBacks['darkness'] = darkness;
					layInFront[0].push(darkness);
				}

			// ============================================
			// ATROCIOUS STAGE
			// ============================================
			case 'atrocious':
				{
					camZoom = 0.9;

					var atrociousBG = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/atrocious/atrociousBG'));
					atrociousBG.antialiasing = FlxG.save.data.antialiasing;
					atrociousBG.scrollFactor.set(0.9, 0.9);
					swagBacks['atrociousBG'] = atrociousBG;
					toAdd.push(atrociousBG);
				}

			// ============================================
			// BLITZ STAGE
			// ============================================
			case 'blitz':
				{
					camZoom = 0.9;

					var bg_blitz = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/blitz/bg_blitz'));
					bg_blitz.antialiasing = FlxG.save.data.antialiasing;
					bg_blitz.scrollFactor.set(0.9, 0.9);
					swagBacks['bg_blitz'] = bg_blitz;
					toAdd.push(bg_blitz);

					var floor_blitz = new FlxSprite(-150, 300).loadGraphic(Paths.loadImage('bgs/blitz/floor_blitz'));
					floor_blitz.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['floor_blitz'] = floor_blitz;
					toAdd.push(floor_blitz);

					var house_blitz = new FlxSprite(-100, 50).loadGraphic(Paths.loadImage('bgs/blitz/house_blitz'));
					house_blitz.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['house_blitz'] = house_blitz;
					toAdd.push(house_blitz);

					var land_blitz = new FlxSprite(-50, 200).loadGraphic(Paths.loadImage('bgs/blitz/land_blitz'));
					land_blitz.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['land_blitz'] = land_blitz;
					toAdd.push(land_blitz);
				}

			// ============================================
			// MINUS STAGE
			// ============================================
			case 'minus':
				{
					camZoom = 0.9;

					var bg_minus = new FlxSprite(-200, -100).loadGraphic(Paths.loadImage('bgs/minus/bg_minus'));
					bg_minus.antialiasing = FlxG.save.data.antialiasing;
					bg_minus.scrollFactor.set(0.9, 0.9);
					swagBacks['bg_minus'] = bg_minus;
					toAdd.push(bg_minus);

					var bf_minus = new FlxSprite(500, 300).loadGraphic(Paths.loadImage('bgs/minus/bf_minus'));
					bf_minus.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['bf_minus'] = bf_minus;
					layInFront[1].push(bf_minus);

					var dave_minus = new FlxSprite(100, 200).loadGraphic(Paths.loadImage('bgs/minus/dave_minus'));
					dave_minus.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['dave_minus'] = dave_minus;
					layInFront[1].push(dave_minus);
				}

			// ============================================
			// CUSTOM SCHOOL STAGE
			// ============================================
			case 'schoolCustom':
				{
					var bgSky = new FlxSprite().loadGraphic(Paths.loadImage('weeb/weebSky', 'week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					swagBacks['bgSky'] = bgSky;
					toAdd.push(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.loadImage('weeb/weebSchool', 'week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					swagBacks['bgSchool'] = bgSchool;
					toAdd.push(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.loadImage('weeb/weebStreet', 'week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					swagBacks['bgStreet'] = bgStreet;
					toAdd.push(bgStreet);

					var bgschoolsback = new FlxSprite(-300, -100).loadGraphic(Paths.loadImage('bgs/schoolCustom/bgschoolsback'));
					bgschoolsback.antialiasing = FlxG.save.data.antialiasing;
					bgschoolsback.scrollFactor.set(0.8, 0.8);
					swagBacks['bgschoolsback'] = bgschoolsback;
					toAdd.push(bgschoolsback);

					var school_char1 = new FlxSprite(100, 200);
					school_char1.frames = Paths.getSparrowAtlas('bgs/schoolCustom/school_char1');
					school_char1.animation.addByPrefix('idle', 'idle', 24, false);
					school_char1.animation.play('idle');
					school_char1.antialiasing = FlxG.save.data.antialiasing;
					school_char1.scrollFactor.set(0.9, 0.9);
					swagBacks['school_char1'] = school_char1;
					toAdd.push(school_char1);

					var school_char2 = new FlxSprite(700, 200);
					school_char2.frames = Paths.getSparrowAtlas('bgs/schoolCustom/school_char2');
					school_char2.animation.addByPrefix('idle', 'idle', 24, false);
					school_char2.animation.play('idle');
					school_char2.antialiasing = FlxG.save.data.antialiasing;
					school_char2.scrollFactor.set(0.9, 0.9);
					swagBacks['school_char2'] = school_char2;
					toAdd.push(school_char2);

					var widShit = Std.int(bgSky.width * 6);
					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
				}

			default:
			{
				camZoom = 0.9;
				curStage = 'stage';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.loadImage('stageback', 'shared'));
				bg.antialiasing = FlxG.save.data.antialiasing;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				swagBacks['bg'] = bg;
				toAdd.push(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.loadImage('stagefront', 'shared'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = FlxG.save.data.antialiasing;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				swagBacks['stageFront'] = stageFront;
				toAdd.push(stageFront);

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.loadImage('stagecurtains', 'shared'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = FlxG.save.data.antialiasing;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;

				swagBacks['stageCurtains'] = stageCurtains;
				toAdd.push(stageCurtains);
			}
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!PlayStateChangeables.Optimize)
		{
			switch (curStage)
			{
				case 'philly':
					if (trainMoving)
					{
						trainFrameTiming += elapsed;

						if (trainFrameTiming >= 1 / 24)
						{
							updateTrainPos();
							trainFrameTiming = 0;
						}
					}
					// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
			}
		}
	}

	override function stepHit()
	{
		// NOTE: super.stepHit() intentionally NOT called here.
		// Stage is instantiated as an object (not a state), so its curStep is never
		// updated by the game loop. Calling super would incorrectly trigger beatHit()
		// every time since curStep stays at 0.

		if (!PlayStateChangeables.Optimize)
		{
			var array = slowBacks[curStep];
			if (array != null && array.length > 0)
			{
				if (hideLastBG)
				{
					for (bg in swagBacks)
					{
						if (!array.contains(bg))
						{
							var tween = FlxTween.tween(bg, {alpha: 0}, tweenDuration, {
								onComplete: function(tween:FlxTween):Void
								{
									bg.visible = false;
								}
							});
						}
					}
					for (bg in array)
					{
						bg.visible = true;
						FlxTween.tween(bg, {alpha: 1}, tweenDuration);
					}
				}
				else
				{
					for (bg in array)
						bg.visible = !bg.visible;
				}
			}
		}
	}

	override function beatHit()
	{
		// NOTE: super.beatHit() intentionally NOT called here (see stepHit note).

		if (FlxG.save.data.distractions && animatedBacks.length > 0)
		{
			for (bg in animatedBacks)
				bg.animation.play('idle', true);
		}

		if (!PlayStateChangeables.Optimize)
		{
			switch (curStage)
			{
				case 'halloween':
					if (FlxG.random.bool(Conductor.bpm > 320 ? 100 : 10) && curBeat > lightningStrikeBeat + lightningOffset)
					{
						if (FlxG.save.data.distractions)
						{
							lightningStrikeShit();
							trace('spooky');
						}
					}
				case 'school':
					if (FlxG.save.data.distractions)
					{
						swagBacks['bgGirls'].dance();
					}
				case 'limo':
					if (FlxG.save.data.distractions)
					{
						swagGroup['grpLimoDancers'].forEach(function(dancer:BackgroundDancer)
						{
							dancer.dance();
						});

						if (FlxG.random.bool(10) && fastCarCanDrive)
							fastCarDrive();
					}
				case "philly":
					if (FlxG.save.data.distractions)
					{
						if (!trainMoving)
							trainCooldown += 1;

						if (curBeat % 4 == 0)
						{
							var phillyCityLights = swagGroup['phillyCityLights'];
							phillyCityLights.forEach(function(light:FlxSprite)
							{
								light.visible = false;
							});

							curLight = FlxG.random.int(0, phillyCityLights.length - 1);

							phillyCityLights.members[curLight].visible = true;
							// phillyCityLights.members[curLight].alpha = 1;
						}
					}

					if (curBeat % 8 == 4 && FlxG.random.bool(Conductor.bpm > 320 ? 150 : 30) && !trainMoving && trainCooldown > 8)
					{
						if (FlxG.save.data.distractions)
						{
							trainCooldown = FlxG.random.int(-4, 0);
							trainStart();
							trace('train');
						}
					}

				case 'chortle':
					if (FlxG.save.data.distractions)
					{
						// Toggle prima/miku backgrounds on beat
						if (curBeat % 8 == 0)
						{
							if (swagBacks['primaDancingBG'] != null)
							{
								swagBacks['primaDancingBG'].visible = true;
								swagBacks['primaNormalBG'].visible = false;
							}
						}
						if (curBeat % 8 == 4)
						{
							if (swagBacks['primaDancingBG'] != null)
							{
								swagBacks['primaDancingBG'].visible = false;
								swagBacks['primaNormalBG'].visible = true;
							}
						}
						// Pulse PIU arrows on beat
						if (swagBacks['piuArrows'] != null)
						{
							FlxTween.tween(swagBacks['piuArrows'], {y: swagBacks['piuArrows'].y - 10}, 0.1, {type: FlxTweenType.BACKWARD});
						}
					}

				case 'miya':
					if (FlxG.save.data.distractions)
					{
						// Cycle miya BG layers on beat
						var bgIndex = (Std.int(curBeat / 4) % 4) + 1;
						for (i in 1...5)
						{
							if (swagBacks['miyaBG' + i] != null)
								swagBacks['miyaBG' + i].visible = (i == bgIndex);
							if (swagBacks['miyaCity' + i] != null)
								swagBacks['miyaCity' + i].visible = (i == bgIndex);
						}
						// Pulse hearts on beat
						if (swagBacks['miyaHearts'] != null)
						{
							swagBacks['miyaHearts'].visible = (curBeat % 4 == 0);
							FlxTween.tween(swagBacks['miyaHearts'], {alpha: 0.5}, 0.5, {type: FlxTweenType.ONESHOT});
						}
					}

				case 'sarah':
					if (FlxG.save.data.distractions)
					{
						// Sarah stage events
						if (curBeat % 16 == 0)
						{
							if (swagBacks['bgNewsMan'] != null)
								swagBacks['bgNewsMan'].visible = true;
							if (swagBacks['purplething'] != null)
								swagBacks['purplething'].visible = true;
						}
						if (curBeat % 16 == 8)
						{
							if (swagBacks['bgNewsMan'] != null)
								swagBacks['bgNewsMan'].visible = false;
							if (swagBacks['purplething'] != null)
								swagBacks['purplething'].visible = false;
						}
					}

				case 'derelict':
					if (FlxG.save.data.distractions)
					{
						// Derelict stage events - step-triggered BG changes
						if (curBeat % 32 == 0)
						{
							// Show corrupted BG
							if (swagBacks['delerictCorrupted_BG'] != null)
								swagBacks['delerictCorrupted_BG'].visible = true;
							if (swagBacks['delerictMain_BG'] != null)
								swagBacks['delerictMain_BG'].visible = false;
						}
						if (curBeat % 32 == 16)
						{
							// Show screw red BG
							if (swagBacks['delerictScrewRed_BG'] != null)
								swagBacks['delerictScrewRed_BG'].visible = true;
							if (swagBacks['delerictCorrupted_BG'] != null)
								swagBacks['delerictCorrupted_BG'].visible = false;
						}
						if (curBeat % 32 == 24)
						{
							// Show stickers
							if (swagBacks['derelictStickers'] != null)
								swagBacks['derelictStickers'].visible = true;
						}
						if (curBeat % 32 == 0)
						{
							// Hide stickers and screw red
							if (swagBacks['derelictStickers'] != null)
								swagBacks['derelictStickers'].visible = false;
							if (swagBacks['delerictScrewRed_BG'] != null)
								swagBacks['delerictScrewRed_BG'].visible = false;
							if (swagBacks['delerictCorrupted_BG'] != null)
								swagBacks['delerictCorrupted_BG'].visible = false;
							if (swagBacks['delerictMain_BG'] != null)
								swagBacks['delerictMain_BG'].visible = true;
						}
					}

				case 'mainStage_splingo':
					if (FlxG.save.data.distractions)
					{
						// Splingo events
						if (curBeat == 16)
						{
							// Jimble joins
							if (swagBacks['jimbleIntro'] != null)
							{
								swagBacks['jimbleIntro'].visible = true;
								swagBacks['jimbleIntro'].animation.play('appear');
							}
						}
						if (curBeat == 32)
						{
							// Explosion
							if (swagBacks['explostion'] != null)
							{
								swagBacks['explostion'].visible = true;
								swagBacks['explostion'].animation.play('idle');
							}
						}
					}

				case 'stageArtificial_garretson':
					if (FlxG.save.data.distractions)
					{
						// Garretson screen singing events
						if (swagBacks['garretsonScreenSinging'] != null)
						{
							if (curBeat % 4 == 0)
								swagBacks['garretsonScreenSinging'].animation.play('idle', true);
						}
						if (curBeat % 16 == 8)
						{
							if (swagBacks['garretsonFunnys'] != null)
								swagBacks['garretsonFunnys'].visible = true;
						}
						if (curBeat % 16 == 12)
						{
							if (swagBacks['garretsonFunnys'] != null)
								swagBacks['garretsonFunnys'].visible = false;
						}
					}

				case 'musical':
					if (FlxG.save.data.distractions)
					{
						// Musical stage idle animations
						for (bg in animatedBacks)
							bg.animation.play('idle', true);
					}
			}
		}
	}

	// Variables and Functions for Stages
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var curLight:Int = 0;

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2, 'shared'));
		swagBacks['halloweenBG'].animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if (PlayState.boyfriend != null)
		{
			PlayState.boyfriend.playAnim('scared', true);
			PlayState.gf.playAnim('scared', true);
		}
		else
		{
			GameplayCustomizeState.boyfriend.playAnim('scared', true);
			GameplayCustomizeState.gf.playAnim('scared', true);
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var trainSound:FlxSound;

	function trainStart():Void
	{
		if (FlxG.save.data.distractions)
		{
			trainMoving = true;
			trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (trainSound.time >= 4700)
			{
				startedMoving = true;

				if (PlayState.gf != null)
					PlayState.gf.playAnim('hairBlow');
				else
					GameplayCustomizeState.gf.playAnim('hairBlow');
			}

			if (startedMoving)
			{
				var phillyTrain = swagBacks['phillyTrain'];
				phillyTrain.x -= 400;

				if (phillyTrain.x < -2000 && !trainFinishing)
				{
					phillyTrain.x = -1150;
					trainCars -= 1;

					if (trainCars <= 0)
						trainFinishing = true;
				}

				if (phillyTrain.x < -4000 && trainFinishing)
					trainReset();
			}
		}
	}

	function trainReset():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (PlayState.gf != null)
				PlayState.gf.playAnim('hairFall');
			else
				GameplayCustomizeState.gf.playAnim('hairFall');

			swagBacks['phillyTrain'].x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if (FlxG.save.data.distractions)
		{
			var fastCar = swagBacks['fastCar'];
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCar.visible = false;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if (FlxG.save.data.distractions)
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1, 'shared'), 0.7);

			swagBacks['fastCar'].visible = true;
			swagBacks['fastCar'].velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}
}
