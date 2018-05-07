package
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.screens.SplashScreen;
import com.gerantech.towercraft.managers.BillingManager;
import com.gerantech.towercraft.models.AppModel;
import com.gt.towers.constants.BuildingType;
import com.gt.towers.constants.ResourceType;
import com.marpies.ane.gameanalytics.GameAnalytics;
import com.marpies.ane.gameanalytics.data.GAErrorSeverity;
import feathers.utils.ScreenDensityScaleFactorManager;
import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display3D.Context3DProfile;
import flash.display3D.Context3DRenderMode;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.UncaughtErrorEvent;
import flash.utils.getTimer;
import starling.core.Starling;

[ResourceBundle("loc")]
[SWF(frameRate="60", backgroundColor="#000000")]//#3d4759
public class Towers extends Sprite
{
public static var t:int;

private var starling:Starling;
private var loadingState:int = 0;
private var splash:SplashScreen;

public function Towers()
{
	/*for(var improveLevel:int=1; improveLevel<=4; improveLevel++)
	{
		var str:String = improveLevel + " : ";
		for(var level:int=1; level<=10; level++)
			str += level + "[" + ((  0.04 + Math.log(level) * 0.03 + Math.log(improveLevel) * 0.02  )).toFixed(3) + "]   " ;
		trace(str);
	}
	NativeApplication.nativeApplication.exit();
	return;*/
    
	// GameAnalytic Configurations
	var currencies:Vector.<String> = new Vector.<String>();
	var bt:Vector.<int> = BuildingType.getAll().keys();
	for each( var r:int in bt )
		currencies.push(r.toString());
	currencies.push(ResourceType.XP.toString());
	currencies.push(ResourceType.POINT.toString());
	currencies.push(ResourceType.KEY.toString());
	currencies.push(ResourceType.CURRENCY_HARD.toString());
	currencies.push(ResourceType.CURRENCY_SOFT.toString());
	
	GameAnalytics.config/*.setUserId("test_id").setResourceCurrencies(new <String>["gems", "coins"]).setResourceItemTypes(new <String>["boost", "lives"]).setCustomDimensions01(new <String>["ninja", "samurai"])*/
		.setBuildAndroid(AppModel.instance.descriptor.versionNumber).setGameKeyAndroid("8ecad253293db70a84469b3d79243f12").setGameSecretAndroid("6c3abba9c19b989f5e45749396bcb1b78b51fbf2")
		.setResourceCurrencies(currencies)
		.setResourceItemTypes(new <String>["outcome", "special", "chest", "purchase", "exchange", "upgrade", "donate"])
	/*.setBuildiOS(AppModel.instance.descriptor.versionNumber).setGameKeyiOS("[ios_game_key]").setGameSecretiOS("[ios_secret_key]")*/
	GameAnalytics.init();
	
	t = getTimer();
	if( this.stage )
	{
		this.stage.scaleMode = StageScaleMode.NO_SCALE;
		this.stage.align = StageAlign.TOP_LEFT;
	}
	
	this.mouseEnabled = this.mouseChildren = false;
	splash = new SplashScreen();
	splash.addEventListener(Event.CLEAR, loaderInfo_completeHandler);
	addChild(splash);
	loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
	loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, loaderInfo_uncaughtErrorHandler);

	NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, nativeApplication_invokeHandler);
}

private function loaderInfo_completeHandler(event:Event):void
{
	loadingState ++;
	if( event.currentTarget == this.loaderInfo )
		this.loaderInfo.removeEventListener(Event.COMPLETE, loaderInfo_completeHandler);
	else
		splash.removeEventListener(Event.CLEAR, loaderInfo_completeHandler);
	
	if( loadingState >= 2 )
		starStarling();
}

private function starStarling():void
{
	Starling.multitouchEnabled = true;
	this.starling = new Starling(com.gerantech.towercraft.Main, this.stage, null, null, Context3DRenderMode.AUTO, Context3DProfile.BASELINE);
	//this.starling.viewPort = new Rectangle(0, 0, stage.stageWidth*x, stage.stageHeight*y);
	this.starling.supportHighResolutions = true;
	//this.starling.showStatsAt("right", "bottom", 1.2);
	this.starling.skipUnchangedFrames = true;
	this.starling.start();
	this.starling.addEventListener("rootCreated", starling_rootCreatedHandler);
    new ScreenDensityScaleFactorManager(this.starling);
	
	AppModel.instance.scale = this.starling.stage.stageWidth/1080;
	BillingManager.instance.init();			
}

private function starling_rootCreatedHandler(event:Object):void
{
	this.stage.addEventListener(Event.DEACTIVATE, stage_deactivateHandler, false, 0, true);
}

private function stage_deactivateHandler(event:Event):void
{
	this.starling.stop(true);
	stage.frameRate = 0;
	this.stage.addEventListener(Event.ACTIVATE, stage_activateHandler, false, 0, true);
	AppModel.instance.sounds.muteAll(true);
	AppModel.instance.notifier.reset();
}
private function stage_activateHandler(event:Event):void
{
	this.stage.removeEventListener(Event.ACTIVATE, stage_activateHandler);
	stage.frameRate = 60;
	this.starling.start();
	AppModel.instance.sounds.muteAll(false);
	AppModel.instance.notifier.clear();
}

protected function nativeApplication_invokeHandler(event:InvokeEvent):void
{
	NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, nativeApplication_invokeHandler);
	AppModel.instance.invokes = event.arguments;
}

protected function loaderInfo_uncaughtErrorHandler(event:UncaughtErrorEvent):void 
{
	var text:String;
	var severity:int;

	if( event.error is Error )
	{
		text =  event.error.getStackTrace();
		severity = GAErrorSeverity.CRITICAL;
	}
	else if( event.error is ErrorEvent )
	{
		text = event.error.text;
		severity = GAErrorSeverity.ERROR;
	}
	else
	{
		text = event.error.toString();
		severity = GAErrorSeverity.WARNING;
	}
	GameAnalytics.addErrorEvent(severity, text);
	//navigateToURL(new URLRequest("http://127.0.0.1:8080/towerslet/towers?" + severity + "--" + text));
}
}
}