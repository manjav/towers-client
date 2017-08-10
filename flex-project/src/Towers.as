package
{
	import com.gerantech.towercraft.Main;
	import com.gerantech.towercraft.controls.screens.SplashScreen;
	import com.gerantech.towercraft.managers.BillingManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.mesmotronic.ane.AndroidFullScreen;
	import com.marpies.ane.gameanalytics.GameAnalytics;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import feathers.utils.ScreenDensityScaleFactorManager;
	
	import starling.core.Starling;
	
	[ResourceBundle("loc")]
	
	[SWF(frameRate="60", backgroundColor="#3d4759")]
	public class Towers extends Sprite
	{
		private var starling:Starling;
		private var scaler:ScreenDensityScaleFactorManager;
		public static var t:int;
		
		public function Towers()
		{
			/*for(var improveLevel:int=1; improveLevel<=4; improveLevel++)
			{
				var str:String = improveLevel + " :  ";
				for(var level:int=1; level<=10; level++)
					str += level + " => " + ((  Math.round( Math.log(level * level) + Math.log(improveLevel * improveLevel))+1  )) + "  " ;
				trace(str);
			}
			return;*/
/*			var spawnGap:Number;
			trace("\n##### Barrack:\n");
			for (var level:int = 1; level < 11; level++) 
			{
				spawnGap = 2000 - Math.round( ( (Math.log(level)*Math.log(level))/(Math.log(2.7)*Math.log(2.7)) + 3*Math.log(1)/Math.log(2.7) ) * 200 );
				trace("spawnGap level(", level, ")--> \nType 11: ", spawnGap);
				spawnGap = 2000 - Math.round( ( (Math.log(level)*Math.log(level))/(Math.log(2.7)*Math.log(2.7)) + 3*Math.log(2)/Math.log(2.7) ) * 200 );
				trace("    Type 12: ", spawnGap);
				spawnGap = 2000 - Math.round( ( (Math.log(level)*Math.log(level))/(Math.log(2.7)*Math.log(2.7)) + 3*Math.log(3)/Math.log(2.7) ) * 200 );
				trace("        Type 13: ", spawnGap);
				spawnGap = 2000 - Math.round( ( (Math.log(level)*Math.log(level))/(Math.log(2.7)*Math.log(2.7)) + 3*Math.log(4)/Math.log(2.7) ) * 200 );
				trace("            Type 14: ", spawnGap);
			}
			return;*/
			
			GameAnalytics.config/*.setUserId("test_id").setResourceCurrencies(new <String>["gems", "coins"]).setResourceItemTypes(new <String>["boost", "lives"]).setCustomDimensions01(new <String>["ninja", "samurai"])*/
				.setBuildAndroid(AppModel.instance.descriptor.versionNumber).setGameKeyAndroid("8ecad253293db70a84469b3d79243f12").setGameSecretAndroid("6c3abba9c19b989f5e45749396bcb1b78b51fbf2")
				/*.setBuildiOS(AppModel.instance.descriptor.versionNumber).setGameKeyiOS("[ios_game_key]").setGameSecretiOS("[ios_secret_key]")*/
			GameAnalytics.init();

			t = getTimer();
			if(this.stage)
			{
				// full screen for android platform
				if( AppModel.instance.platform == AppModel.PLATFORM_ANDROID )//if(Capabilities.manufacturer.indexOf("droid")>-1)
				{
					AndroidFullScreen.stage = stage; // Set this to your app's stage
					AndroidFullScreen.fullScreen();
				}
				
				this.stage.scaleMode = StageScaleMode.NO_SCALE;
				this.stage.align = StageAlign.TOP_LEFT;
			}
			
			this.mouseEnabled = this.mouseChildren = false;
			addChild(new SplashScreen());
			this.loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
		}
		
		private function loaderInfo_completeHandler(event:Event):void
		{
			this.loaderInfo.removeEventListener(Event.COMPLETE, loaderInfo_completeHandler);
			/*var originalWidth:Number = 1920;
			var originalHeight:Number = 1080;
			var x:Number = originalWidth/stage.stageWidth;
			var y:Number = originalHeight/stage.stageHeight;*/
			
			Starling.multitouchEnabled = true;
			this.starling = new Starling(com.gerantech.towercraft.Main, this.stage, null, null, Context3DRenderMode.AUTO, Context3DProfile.BASELINE);
			//this.starling.viewPort = new Rectangle(0, 0, stage.stageWidth*x, stage.stageHeight*y);
			this.starling.supportHighResolutions = true;
			//this.starling.showStats = true;
			//this.starling.showStatsAt()//"left", "bottom", 0.8);
			this.starling.skipUnchangedFrames = false;
			this.starling.start();
			this.starling.addEventListener("rootCreated", starling_rootCreatedHandler);
			
			this.scaler = new ScreenDensityScaleFactorManager(this.starling);
			this.stage.addEventListener(Event.DEACTIVATE, stage_deactivateHandler, false, 0, true);
			
			AppModel.instance.scale = this.starling.stage.stageWidth/1080;
			
			BillingManager.instance.init();
		}
		private function starling_rootCreatedHandler(event:Object):void
		{
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
			//AppModel.instance.notifier.clear();
		}
	}
}