package
{
	import com.gerantech.towercraft.Main;
	import com.gerantech.towercraft.controls.screens.SplashScreen;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import feathers.utils.ScreenDensityScaleFactorManager;
	
	import starling.core.Starling;
	
	[SWF(frameRate="60", backgroundColor="#000000")]
	public class TowerCraft extends Sprite
	{
		private var starling:Starling;
		private var scaler:ScreenDensityScaleFactorManager;
		public static var t:int;
		
		public function TowerCraft()
		{
			/*for(var level:int=1; level<=20; level++)
				trace(level, 800 - Math.round( Math.log(level) * 200) );
			return;*/

			t = getTimer();
			if(this.stage)
			{
				/*// full screen for android platform
				if(Capabilities.manufacturer.indexOf("droid")>-1)
				{
				AndroidFullScreen.stage = stage;
				AndroidFullScreen.fullScreen();
				}*/
				
				this.stage.scaleMode = StageScaleMode.NO_SCALE;
				this.stage.align = StageAlign.TOP_LEFT;
				
			}
			this.mouseEnabled = this.mouseChildren = false;
			addChild(new SplashScreen());
			this.loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
		}
		
		private function loaderInfo_completeHandler(event:Event):void
		{
			/*var originalWidth:Number = 1920;
			var originalHeight:Number = 1080;
			var x:Number = originalWidth/stage.stageWidth;
			var y:Number = originalHeight/stage.stageHeight;*/
			
			Starling.multitouchEnabled = true;
			this.starling = new Starling(com.gerantech.towercraft.Main, this.stage, null, null, Context3DRenderMode.AUTO, Context3DProfile.BASELINE);
			//this.starling.viewPort = new Rectangle(0, 0, stage.stageWidth*x, stage.stageHeight*y);
			this.starling.supportHighResolutions = true;
			this.starling.showStats = true
			this.starling.skipUnchangedFrames = false;
			this.starling.start();
			this.starling.addEventListener("rootCreated", starling_rootCreatedHandler);
			
			this.scaler = new ScreenDensityScaleFactorManager(this.starling);
			this.stage.addEventListener(Event.DEACTIVATE, stage_deactivateHandler, false, 0, true);
		}
		private function starling_rootCreatedHandler(event:Object):void
		{
		}
		
		private function stage_deactivateHandler(event:Event):void
		{
			this.starling.stop(true);
			stage.frameRate = 0;
			this.stage.addEventListener(Event.ACTIVATE, stage_activateHandler, false, 0, true);
		}
		private function stage_activateHandler(event:Event):void
		{
			this.stage.removeEventListener(Event.ACTIVATE, stage_activateHandler);
			stage.frameRate = 60;
			this.starling.start();
		}
	}
}