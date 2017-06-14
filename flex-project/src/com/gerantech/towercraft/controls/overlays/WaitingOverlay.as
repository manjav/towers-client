package com.gerantech.towercraft.controls.overlays
{
	import dragonBones.objects.DragonBonesData;
	import dragonBones.starling.StarlingArmatureDisplay;
	import dragonBones.starling.StarlingFactory;
	
	import starling.events.Event;

	public class WaitingOverlay extends BaseOverlay
	{
		[Embed(source = "../../../../../assets/animations/battle-outcome-mc_ske.json", mimeType = "application/octet-stream")]
		public static const skeletonClass: Class;
		[Embed(source = "../../../../../assets/animations/battle-outcome-mc_tex.json", mimeType = "application/octet-stream")]
		public static const atlasDataClass: Class;
		[Embed(source = "../../../../../assets/animations/battle-outcome-mc_tex.png")]
		public static const atlasImageClass: Class;
		
		
		private var factory: StarlingFactory;
		private var dragonBonesData:DragonBonesData;
		private var armatureDisplay:StarlingArmatureDisplay ;
		
		public function WaitingOverlay()
		{
			super();
			
			factory = new StarlingFactory();
			dragonBonesData = factory.parseDragonBonesData( JSON.parse(new skeletonClass()) );
			factory.parseTextureAtlasData( JSON.parse(new atlasDataClass()), new atlasImageClass() );
		}
		
		override protected function addedToStageHandler(event:Event):void
		{
			super.addedToStageHandler(event);
			closable = false;
			if(dragonBonesData == null)
				return;
			
			armatureDisplay = factory.buildArmatureDisplay(dragonBonesData.armatureNames[1]);
			
			/*for each(var a:String in dragonBonesData.armatureNames)
			trace(a);*/
			armatureDisplay.x = stage.stageWidth/2;
			armatureDisplay.y = stage.stageHeight / 2;
			armatureDisplay.scale = appModel.scale;
			armatureDisplay.animation.gotoAndPlayByTime("animtion0", 0, 1);
			
			this.addChild(armatureDisplay);
		}
		
	}
}