package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.models.vo.BattleData;
	import com.gt.towers.battle.fieldes.FieldData;
	
	import feathers.controls.LayoutGroup;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.events.Event;

	public class BattleHUD extends TowersLayout
	{
		private var battleData:BattleData;
		private var progressbar:Devider;
		private var finalUTC:uint;
		
		public function BattleHUD()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			this.battleData = appModel.battleFieldView.battleData;
		
			var header:Devider  = new Devider ();
			header.layout = new AnchorLayout();
			header.layoutData = new AnchorLayoutData(0,0,NaN,0);
			addChild(header);
			
			progressbar = new Devider(0xFF, 32*appModel.scale);
			progressbar.layoutData = new AnchorLayoutData(0,NaN,0,0);
			header.addChild(progressbar);
			
			timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
			//finalUTC = battleData.startAt + battleData.map.times.get(2);
		}
		
		private function timeManager_changeHandler(event:Event):void
		{
			//trace(battleData.map.times.get(2),timeManager.now-battleData.startAt)
			progressbar.width = ((timeManager.now-battleData.startAt) / battleData.map.times.get(2)) * stage.stageWidth;;
		}		
		
		override public function dispose():void
		{
			timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
			super.dispose();
		}
		
		
	}
}