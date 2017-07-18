package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.controls.sliders.BattleTimerSlider;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.vo.BattleData;
	import com.gt.towers.constants.ResourceType;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.core.Starling;
	import starling.events.Event;

	public class BattleHUD extends TowersLayout
	{
		private var battleData:BattleData;
		private var timerSlider:BattleTimerSlider;
		
		public function BattleHUD()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			this.battleData = appModel.battleFieldView.battleData;
		
			var gradient:ImageLoader = new ImageLoader();
			gradient.maintainAspectRatio = false;
			gradient.alpha = 0.5;
			gradient.width = 440*appModel.scale;
			gradient.height = 140*appModel.scale;
			gradient.source = Assets.getTexture("grad-ro-right", "skin");
			addChild(gradient);
			
			var hasQuit:Boolean = battleData.map.isQuest && player.get_questIndex() > 3;
			var padding:int = 16*appModel.scale;
			var leftPadding:int = (hasQuit ? 160 : 16) * appModel.scale;
			if( hasQuit )
			{
				var closeButton:Button = new Button();
				closeButton.label = "X";
				appModel.theme.setDangerButtonStyles(closeButton);
				closeButton.layoutData = new AnchorLayoutData(padding, NaN, NaN, padding);
				closeButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
				addChild(closeButton);			
			}
			
			// main name
			var _name:String = battleData.opponent!=null ? battleData.opponent.getText("name") : battleData.map.name;
			var nameShadow:RTLLabel = new RTLLabel(_name, 0, "left", null, false, null, 1.2);
			nameShadow.layoutData = new AnchorLayoutData(padding*0.5, NaN, NaN, leftPadding );
			addChild(nameShadow);
			var nameLabel:RTLLabel = new RTLLabel(_name, 0xFFFFFF, "left", null, false, null, 1.2);
			nameLabel.layoutData = new AnchorLayoutData(0, NaN, NaN, leftPadding );
			addChild(nameLabel);
			
			// point name
			if( battleData.opponent!=null )
			{
				var pointIcon:ImageLoader = new ImageLoader();
				pointIcon.width = padding*5;
				pointIcon.source = Assets.getTexture("res-"+ResourceType.POINT, "gui");
				pointIcon.layoutData = new AnchorLayoutData(padding*5, NaN, NaN, leftPadding-padding*0.5 );
				addChild(pointIcon);

				var pointShadow:RTLLabel = new RTLLabel(battleData.opponent.getInt("point").toString(), 0, "left", null, false, null, 0.9);
				pointShadow.layoutData = new AnchorLayoutData(padding*5.6, NaN, NaN, leftPadding+padding*5 );
				addChild(pointShadow);
				var pointLabel:RTLLabel = new RTLLabel(battleData.opponent.getInt("point").toString(), 1, "left", null, false, null, 0.9);
				pointLabel.layoutData = new AnchorLayoutData(padding*5.3, NaN, NaN, leftPadding+padding*5 );
				addChild(pointLabel);
			}
			
			timerSlider = new BattleTimerSlider();
			timerSlider.layoutData = new AnchorLayoutData(padding*3, padding*3);
			addChild(timerSlider);
			
			addEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
		}
		
		private function createCompleteHandler(event:Event):void
		{
			removeEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
			gotoCurrentTime();
		}
		
		private function gotoCurrentTime():void
		{
			for(var i:int=0; i<battleData.map.times.size(); i++)
			{
				if( timeManager.now-battleData.startAt < battleData.map.times.get(i) )
				{
					setTimePosition((i>0?battleData.map.times.get(i-1):0), timeManager.now-battleData.startAt, battleData.map.times.get(i), 2-i);
					return;
				}
			}
			//trace(timeManager.now-battleData.startAt , battleData.map.times._list)
		}
		
		private function setTimePosition(startTime:int, time:int, endTime:int, score:int):void
		{
			timerSlider.enableStars(score);
			timerSlider.minimum = startTime;
			timerSlider.maximum = endTime;
			timerSlider.value = endTime-time+startTime;
			trace("["+battleData.map.times._list+"]", "min:", startTime, "val:", endTime-time, "max:", endTime, score)
			Starling.juggler.tween(timerSlider, endTime-time, {value:startTime, onComplete:gotoCurrentTime});
		}		

		
		private function closeButton_triggeredHandler(event:Event):void
		{
			dispatchEventWith(Event.CLOSE);
		}
	}
}