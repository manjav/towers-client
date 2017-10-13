package
{
	import com.gerantech.towercraft.Main;
	import com.gerantech.towercraft.controls.screens.SplashScreen;
	import com.gerantech.towercraft.managers.BillingManager;
	import com.gerantech.towercraft.models.AppModel;
	
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.events.InvokeEvent;
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
		private var loadingState:int = 0;

		private var splash:SplashScreen;
		
		public function Towers()
		{
			/*for(var improveLevel:int=1; improveLevel<=4; improveLevel++)
			{
				var str:String = improveLevel + " : ";
				for(var get_level:int=1; get_level<=10; get_level++)
				{
					str += get_level + "[" + ((  180 + Math.round( (Math.log(improveLevel) + Math.log(get_level)) * 32)  )).toFixed(2) + "   " ;
				}
				trace(str);
			}
			NativeApplication.nativeApplication.exit();
			return;*/

			t = getTimer();
			if(this.stage)
			{
				this.stage.scaleMode = StageScaleMode.NO_SCALE;
				this.stage.align = StageAlign.TOP_LEFT;
			}
			
			this.mouseEnabled = this.mouseChildren = false;
			splash = new SplashScreen();
			splash.addEventListener(Event.CLEAR, loaderInfo_completeHandler);
			addChild(splash);
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
			//this.starling.showStatsAt("right", "bottom", 0.8);
			this.starling.skipUnchangedFrames = false;
			this.starling.start();
			this.starling.addEventListener("rootCreated", starling_rootCreatedHandler);
			
			this.scaler = new ScreenDensityScaleFactorManager(this.starling);
			
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
			//AppModel.instance.notifier.clear();
		}
	}
}