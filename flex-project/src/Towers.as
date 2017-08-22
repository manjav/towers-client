package
{
	import com.gerantech.towercraft.Main;
	import com.gerantech.towercraft.controls.screens.SplashScreen;
	import com.gerantech.towercraft.managers.BillingManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gt.towers.constants.BuildingType;
	import com.gt.towers.constants.ResourceType;
	import com.marpies.ane.gameanalytics.GameAnalytics;
	
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
	
	import feathers.utils.ScreenDensityScaleFactorManager;
	
	import starling.core.Starling;
	
	[ResourceBundle("loc")]
	
	[SWF(frameRate="60", backgroundColor="#000000")]//#3d4759
	public class Towers extends Sprite
	{
		private var starling:Starling;
		private var scaler:ScreenDensityScaleFactorManager;
		public static var t:int;
		
		public function Towers()
		{
			/*for(var improveLevel:int=1; improveLevel<=4; improveLevel++)
			{
				var str:String = improveLevel + " : ";
				for(var level:int=1; level<=10; level++)
				{
					str += level + "[" + ((  1.1 + ( Math.log(level) * 0.7 + Math.log(improveLevel) ) * 0.3  )).toFixed(2) + "-" ;
					str += ((  1.05 + ( Math.log(level) * 0.7 + Math.log(improveLevel) ) * 0.3  )).toFixed(2) + "] " ;
				}
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
			
			// GameAnalytic Configurations
			
			var resources:Vector.<String> = new Vector.<String>();
			for( var r:int in BuildingType.getAll() )
				resources.push(r+"");
			resources.push(ResourceType.XP);
			resources.push(ResourceType.POINT);

			GameAnalytics.config/*.setUserId("test_id").setResourceCurrencies(new <String>["gems", "coins"]).setResourceItemTypes(new <String>["boost", "lives"]).setCustomDimensions01(new <String>["ninja", "samurai"])*/
				.setBuildAndroid(AppModel.instance.descriptor.versionNumber).setGameKeyAndroid("8ecad253293db70a84469b3d79243f12").setGameSecretAndroid("6c3abba9c19b989f5e45749396bcb1b78b51fbf2")
				.setResourceCurrencies(new  <String>[ResourceType.CURRENCY_HARD.toString(), ResourceType.CURRENCY_SOFT.toString()])
				.setResourceItemTypes(resources)
				
				/*.setBuildiOS(AppModel.instance.descriptor.versionNumber).setGameKeyiOS("[ios_game_key]").setGameSecretiOS("[ios_secret_key]")*/
			GameAnalytics.init();

			t = getTimer();
			if(this.stage)
			{
				this.stage.scaleMode = StageScaleMode.NO_SCALE;
				this.stage.align = StageAlign.TOP_LEFT;
			}
			
			this.mouseEnabled = this.mouseChildren = false;
			addChild(new SplashScreen());
			this.loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, nativeApplication_invokeHandler);
		}
		
		protected function nativeApplication_invokeHandler(event:InvokeEvent):void
		{
			NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, nativeApplication_invokeHandler);
			AppModel.instance.invokes = event.arguments;
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
			
			AppModel.instance.scale = this.starling.stage.stageWidth/1080;
			BillingManager.instance.init();
			
			loaderInfo.uncaughtErrorEvents.addEventListener( UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler );
		}
		
		protected function uncaughtErrorHandler(event:UncaughtErrorEvent):void
		{
			var errorText:String;
			var stack:String;
			if( event.error is Error )
			{
				errorText = (event.error as Error).message;
				stack = (event.error as Error).getStackTrace();
				if(stack != null){
					errorText += stack;
				}
			} else if( event.error is ErrorEvent )
			{
				errorText = (event.error as ErrorEvent).text;
			} else
			{
				errorText = event.text;
			}
			if(GameAnalytics.isInitialized)
				GameAnalytics.addErrorEvent(0, errorText);
			//event.preventDefault();
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
			//AppModel.instance.notifier.clear();
		}
	}
}