package
{
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.screens.SplashScreen;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.vo.Descriptor;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.ResourceType;
import com.gameanalytics.sdk.GameAnalytics;
import com.gameanalytics.sdk.GAErrorSeverity;
import feathers.events.FeathersEventType;

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
import flash.geom.Rectangle;
import flash.utils.getTimer;

import starling.core.Starling;
import com.tuarua.FirebaseANE;
import com.tuarua.firebase.FirebaseOptions;
import com.tuarua.fre.ANEError;

import ir.metrix.sdk.Metrix;
import com.gerantech.towercraft.utils.Localizations;
import com.gerantech.extensions.NativeAbilities;

public class Main extends Sprite
{
public static var t:int;
private var starling:Starling;
private var splash:SplashScreen;

public function Main()
{
	Localizations.instance.changeLocale(Localizations.instance.getLocaleByTimezone(NativeAbilities.instance.getTimezone()));

	/*for(var improveLevel:int=1; improveLevel<=4; improveLevel++)
	{
		var str:String = improveLevel + " : ";
		for(var level:int=1; level<=10; level++)
			str += level + "[" + ((  0.25 + Math.log(level) * 0.02 + Math.log(improveLevel) * 0.003  )).toFixed(3) + "]   " ;
		trace(str);
	}
	NativeApplication.nativeApplication.exit();
	return;*/
    
	// GameAnalytic Configurations
	var desc:Descriptor = AppModel.instance.descriptor;
	GameAnalytics.config/*.setUserId("test_id").setResourceCurrencies(new <String>["gems", "coins"]).setResourceItemTypes(new <String>["boost", "lives"]).setCustomDimensions01(new <String>["ninja", "samurai"])*/
		.setBuildAndroid(desc.versionNumber).setGameKeyAndroid(desc.analyticskey).setGameSecretAndroid(desc.analyticssec)
		.setResourceCurrencies(new <String>[ResourceType.getName(ResourceType.R1_XP), ResourceType.getName(ResourceType.R2_POINT), ResourceType.getName(ResourceType.R3_CURRENCY_SOFT), ResourceType.getName(ResourceType.R4_CURRENCY_HARD), ResourceType.getName(ResourceType.R6_TICKET)])
		.setResourceItemTypes(new <String>["Initial", ExchangeType.getName(ExchangeType.C0_HARD), ExchangeType.getName(ExchangeType.C10_SOFT), ExchangeType.getName(ExchangeType.C20_SPECIALS), ExchangeType.getName(ExchangeType.C30_BUNDLES), ExchangeType.getName(ExchangeType.C40_OTHERS), ExchangeType.getName(ExchangeType.BOOKS_50), ExchangeType.getName(ExchangeType.C70_TICKETS), ExchangeType.getName(ExchangeType.C80_EMOTES), ExchangeType.getName(ExchangeType.C100_FREES), ExchangeType.getName(ExchangeType.C110_BATTLES), ExchangeType.getName(ExchangeType.C120_MAGICS)]);
	if ( GameAnalytics.isSupported )
	{
		try {
			GameAnalytics.init();
		}
		catch (error:Error)
		{
			trace(error.message);
		}
	}
	
	t = getTimer();
	stage.scaleMode = StageScaleMode.NO_SCALE;
	stage.align = StageAlign.TOP_LEFT;

	mouseEnabled = mouseChildren = false;
	splash = new SplashScreen(stage);
	splash.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, loaderInfo_completeHandler);
	loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
	loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, loaderInfo_uncaughtErrorHandler);

	NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, nativeApplication_invokeHandler);

	if (AppModel.instance.platform == AppModel.PLATFORM_ANDROID)
	{
		try
		{
			/**
			 * Here we will initalize firebase native extension, required for 
			 * Firebase Cloud Messaging.
			 */
			FirebaseANE.init();
			if(!FirebaseANE.isGooglePlayServicesAvailable)
			{
				trace("Google Play Service is not installed on device");
				// TODO: Requires handle method.
			}
			var firebaseOptions:FirebaseOptions = FirebaseANE.options;
			if (firebaseOptions)
			{
				trace("apiKey", firebaseOptions.apiKey);
				trace("googleAppId", firebaseOptions.googleAppId);
			}
		}
		catch (e:ANEError)
		{
			trace(e.errorID, e.message, e.getStackTrace(), e.source);
		}
	}

	if( Metrix.instance.isSupported )
	{
		Metrix.instance.appID = "jhhosgjzkirrzsc";
		Metrix.instance.initialize();
	}
}

private function loaderInfo_completeHandler(event:Event):void
{
	if( event.currentTarget == loaderInfo )
		loaderInfo.removeEventListener(Event.COMPLETE, loaderInfo_completeHandler);
	else
		splash.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, loaderInfo_completeHandler);
	
	if( loaderInfo.bytesLoaded == loaderInfo.bytesTotal && splash.transitionInCompleted )
		starStarling();
}

private function starStarling():void
{
	this.starling = new Starling(Game, stage, new Rectangle(0,0,stage.stageWidth,stage.stageHeight), null, Context3DRenderMode.AUTO, Context3DProfile.BASELINE);
	this.starling.addEventListener("rootCreated", starling_rootCreatedHandler);
	this.starling.supportHighResolutions = true;
	this.starling.skipUnchangedFrames = true;
	this.starling.start();
	this.starling.stage.stageWidth  = 1080;
	this.starling.stage.stageHeight = 1080 * (stage.stageHeight / stage.stageWidth);
	//NativeAbilities.instance.showToast(stage.fullScreenWidth + "," + stage.fullScreenHeight + "," + this.starling.stage.stageWidth + "," + this.starling.stage.stageHeight + "," + this.starling.contentScaleFactor, 2);
	//this.starling.showStatsAt("right", "top", 1 / this.starling.contentScaleFactor);
	trace("Screen(" + stage.fullScreenWidth + "x" + stage.fullScreenHeight + "), Stage(" + stage.stageWidth + "x" +  stage.stageHeight + "), Starling(" + starling.stage.stageWidth + "x" +  starling.stage.stageHeight + "), Ratio:" + starling.contentScaleFactor);
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
	AppModel.instance.invokes = event.arguments;
	if(AppModel.instance.navigator)
		AppModel.instance.navigator.handleInvokes();
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
	if(GameAnalytics.isInitialized)
		GameAnalytics.addErrorEvent(severity, text);
	//navigateToURL(new URLRequest("http://127.0.0.1:8080/towerslet/towers?" + severity + "--" + text));
}
}
}