package com.gerantech.towercraft.controls.floatings
{
	import com.gerantech.towercraft.controls.buttons.ImproveButton;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.tutorials.TutorialData;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gt.towers.battle.fieldes.PlaceData;
	import com.gt.towers.constants.BuildingType;
	import com.gt.towers.utils.lists.IntList;
	import com.gt.towers.utils.lists.PlaceDataList;
	import flash.geom.Rectangle;
	
	import feathers.controls.Button;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;

	public class ImproveFloating extends BaseFloating
	{
		public var placeView:PlaceView;
		
		private var upgradeButton:Button;
		private var buttons:Vector.<ImproveButton>;
		
		public function ImproveFloating(){}
		override protected function initialize():void
		{
			super.initialize();
			
			transitionOut.destinationAlpha = 0;
			overlay.visible = false;
			var raduis:int = 160;

			var circle:Image = new Image(Assets.getTexture("damage-range"));
			circle.alignPivot();
			circle.width = circle.height = raduis;
			Starling.juggler.tween(circle, 0.2, {width:raduis * 2, height:raduis * 2, transition:Transitions.EASE_OUT});
			addChild(circle);
				
			buttons = new Vector.<ImproveButton>();
			var options:IntList = BuildingType.getImproveList(placeView.place.building.type);
			var numButtons:int = options.size();
			for (var i:int=0; i < numButtons; i++) 
			{
				var impoveType:int = options.get(i);
				
				buttons[i] = new ImproveButton(placeView.place.building, impoveType);
				buttons[i].renable();
				
				var angle:Number = Math.PI * 2 / numButtons * i;
				var _x:Number = Math.sin(angle) * raduis;
				var _y:Number = Math.cos(angle) * raduis;
				buttons[i].x = _x * 0.7;
				buttons[i].y = _y * 0.7;
				buttons[i].alpha = 0;
				//trace(i, angle, Math.sin(angle), Math.cos(angle))
				Starling.juggler.tween(buttons[i], 0.2, {delay:i * 0.03 + 0.03, alpha:1, x:_x, y:_y, transition:Transitions.EASE_OUT_BACK});
				
				buttons[i].addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
				addChild(buttons[i]);
			}
			placeView.addEventListener(Event.UPDATE, placeView_updateHandler);
		}
		
		override protected function transitionInCompleted():void
		{
			super.transitionInCompleted();
			var pdata:PlaceData = appModel.battleFieldView.battleData.battleField.map.getImprovableTutorPlace();
			if( pdata == null || pdata.index != placeView.place.index )
				return;
			
			for (var i:int=0; i < buttons.length; i++) 
			{
				if( buttons[i].type == -pdata.tutorIndex && player.buildings.exists(buttons[i].type) )
				{
					var tutorialData:TutorialData = new TutorialData(SFSCommands.BUILDING_IMPROVE);
					var places:PlaceDataList = new PlaceDataList();
					var point:Rectangle = buttons[i].getBounds(appModel.battleFieldView);
					places.push(new PlaceData( 0, point.x + point.width * 0.5, point.y + point.height, 0, 0, ""));
					tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_TOUCH, null, places, 0, 200));
					tutorials.show(tutorialData);
				}
			}
		}
		
		private function placeView_updateHandler(event:Event):void
		{
			for (var i:int=0; i < buttons.length; i++) 
				buttons[i].renable();
		}
		
		private function buttons_triggeredHandler(event:Event):void
		{
			dispatchEventWith(Event.SELECT, false, event.currentTarget as ImproveButton);
			close();
		}
		
		override public function close(dispose:Boolean=true):void
		{
			placeView.removeEventListener(Event.UPDATE, placeView_updateHandler);
			super.close(dispose);
		}
	}
}