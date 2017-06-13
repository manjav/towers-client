package com.gerantech.towercraft.controls.overlays
{
	import dragonBones.objects.DragonBonesData;
	import dragonBones.starling.StarlingArmatureDisplay;
	import dragonBones.starling.StarlingFactory;
	
	import feathers.controls.Button;
	import feathers.events.FeathersEventType;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalLayout;
	
	import starling.events.Event;

	public class BattleOutcomeOverlay extends BaseOverlay
	{
		[Embed(source = "../../../../../assets/animations/battle-outcome-mc_ske.json", mimeType = "application/octet-stream")]
		public static const skeletonClass: Class;
		[Embed(source = "../../../../../assets/animations/battle-outcome-mc_tex.json", mimeType = "application/octet-stream")]
		public static const atlasDataClass: Class;
		[Embed(source = "../../../../../assets/animations/battle-outcome-mc_tex.png")]
		public static const atlasImageClass: Class;
		
		private var score:int;
		private var factory: StarlingFactory;
		private var dragonBonesData:DragonBonesData;
		private var armatureDisplay:StarlingArmatureDisplay ;
		
		public function BattleOutcomeOverlay(score:int)
		{
			this.score = score;
			factory = new StarlingFactory();
			dragonBonesData = factory.parseDragonBonesData( JSON.parse(new skeletonClass()) );
			factory.parseTextureAtlasData( JSON.parse(new atlasDataClass()), new atlasImageClass() );
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			var vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = HorizontalAlign.CENTER;
			layout = vlayout;
			
			var closeBatton:Button = new Button();
			closeBatton.name = "close";
			closeBatton.label = loc("close_button");
			closeBatton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
			addChild(closeBatton);
			
			if(score == 0)
			{
				var retryButton:Button = new Button();
				retryButton.name = "retry";
				retryButton.label = loc("retry_button");
				retryButton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
				addChild(retryButton);
			}
		}
		
		private function buttons_triggeredHandler(event:Event):void
		{
			if(Button(event.currentTarget).name == "retry")
				dispatchEventWith(FeathersEventType.CLEAR, false);
			else
				close();
		}		
		
		
		override protected function addedToStageHandler(event:Event):void
		{
			closable = false;
			if(dragonBonesData == null)
				return;
			
			armatureDisplay = factory.buildArmatureDisplay(dragonBonesData.armatureNames[0]);
			
			/*for each(var a:String in dragonBonesData.armatureNames)
			trace(a);*/
			armatureDisplay.x = stage.stageWidth/2;
			armatureDisplay.y = stage.stageHeight / 2;
			armatureDisplay.scale = appModel.scale;
			armatureDisplay.animation.gotoAndPlayByTime("star_" + score, 0, 1);
			
			this.addChild(armatureDisplay);
			super.addedToStageHandler(event);
		}
		
		
	}
}