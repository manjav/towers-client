package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.models.vo.BattleData;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;

	public class BattleHUD extends TowersLayout
	{
		private var battleData:BattleData;
		private var progressbar:Devider;
		
		public function BattleHUD()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			this.battleData = appModel.battleFieldView.battleData;
		
			var header:Devider  = new Devider (0xAAAAAA);
			header.height = 16*appModel.scale;
			header.layout = new AnchorLayout();
			header.layoutData = new AnchorLayoutData(0,0,NaN,0);
			addChild(header);
			
			progressbar = new Devider(0xFF, 32*appModel.scale);
			progressbar.layoutData = new AnchorLayoutData(0,NaN,0,0);
			header.addChild(progressbar);
			
			//timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
			progressbar.width = 0;
			Starling.juggler.tween(progressbar, battleData.map.times.get(2), {width:stage.stageWidth});
			//progressbar.width = ((timeManager.now-battleData.startAt) / battleData.map.times.get(2)) * stage.stageWidth;;

			for (var i:int=0; i < battleData.map.times.size(); i++) 
			{
				var checkpoint:Devider = new Devider (0x111111);
				checkpoint.layoutData = new AnchorLayoutData(0, NaN, 0, NaN);
				checkpoint.width = 12*appModel.scale;trace( battleData.map.times.get(i), battleData.map.times.get(2),  battleData.map.times.get(i) / battleData.map.times.get(2))
				checkpoint.x =( battleData.map.times.get(i) / battleData.map.times.get(2)) * stage.stageWidth - 6*appModel.scale;
				header.addChild(checkpoint);
			}
			
		
		}
	}
}