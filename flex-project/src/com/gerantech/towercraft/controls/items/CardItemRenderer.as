package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.buildings.Building;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.ProgressBar;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.display.Quad;
	import starling.events.Event;

	public class CardItemRenderer extends AbstractTouchableListItemRenderer
	{
		private var tower:Building;

		private var iconDisplay:ImageLoader;
		private var labelDisplay:Label;
		private var progressbar:ProgressBar;
		
		public function CardItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			
			backgroundSkin = new Quad(1,1,0xFFFFFF)
			
			width = stage.stageWidth/4-1;
			height = stage.stageWidth/3;
			
			iconDisplay = new ImageLoader();
			iconDisplay.delayTextureCreation = true;
			iconDisplay.height = width;
			iconDisplay.layoutData = new AnchorLayoutData(6,0,16,0);
			addChild(iconDisplay);
			
			labelDisplay = new Label();
			labelDisplay.isEnabled = false;
			labelDisplay.styleNameList.add(Label.ALTERNATE_STYLE_NAME_DETAIL);
			labelDisplay.layoutData = new AnchorLayoutData(NaN,2,16,2);
			addChild(labelDisplay);
			
			progressbar = new ProgressBar();
			progressbar.layoutData = new AnchorLayoutData(NaN,1,1,1);
			addChild(progressbar);
		}
		
		override protected function commitData():void
		{
			if(_owner==null || _data==null)
				return;
			
			tower = _data as Building;
			iconDisplay.source = Assets.getTexture("tower-type-"+tower.type);
			labelDisplay.text = "Level " + tower.level;
			//progressbar.maximum = tower.get_upgradeRequirements();
			progressbar.value = 5;
		}
		
		override public function set isSelected(value:Boolean):void
		{
			super.isSelected = value;
			if(value)
				_owner.dispatchEventWith(Event.READY, false, this);
		}
		
		
	}
}