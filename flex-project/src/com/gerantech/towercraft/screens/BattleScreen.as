package com.gerantech.towercraft.screens
{
	import com.gerantech.towercraft.BattleField;
	import com.gerantech.towercraft.managers.RTMFPConnector;
	import com.gerantech.towercraft.models.Player;
	import com.gerantech.towercraft.models.Textures;
	import com.gerantech.towercraft.models.TowerPlace;
	
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;

	public class BattleScreen extends BaseCustomScreen
	{
		private var battleField:BattleField;
		private var sourceTowers:Vector.<TowerPlace>;
		private var rtmpConnector:RTMFPConnector;
		
		override protected function initialize():void
		{
			alpha = 0.5;
			super.initialize();
			layout = new AnchorLayout();
			
			battleField = new BattleField();
			battleField.mode = BattleField.MODE_PLAY;
			battleField.layoutData = new AnchorLayoutData(stage.width/3,0,NaN,0);
			addChild(battleField);
			
			addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
		}
		
		private function transitionInCompleteHandler():void
		{
			removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
			battleField.addDrops();
			battleField.readyForBattle();
			
			rtmpConnector = new RTMFPConnector();
			rtmpConnector.addEventListener(Event.COMPLETE, rtmpConnector_completeHandler);
			rtmpConnector.connect();
			addEventListener(TouchEvent.TOUCH, touchHandler);
			//new AIEnemy(battleField, Troop.TYPE_RED);
		}
		
		private function rtmpConnector_completeHandler():void
		{
			addEventListener(TouchEvent.TOUCH, touchHandler);
			rtmpConnector.removeEventListener(Event.COMPLETE, rtmpConnector_completeHandler);
			rtmpConnector.addEventListener(Event.UPDATE, rtmpConnector_updateHandler);
			rtmpConnector.addEventListener(Event.CLOSE, rtmpConnector_closeHandler);
			alpha = 1;
		}
		
		private function rtmpConnector_closeHandler():void
		{
			alpha = 1;
			removeEventListener(TouchEvent.TOUCH, touchHandler);
			rtmpConnector.addEventListener(Event.COMPLETE, rtmpConnector_completeHandler);
			rtmpConnector.removeEventListener(Event.UPDATE, rtmpConnector_updateHandler);
			rtmpConnector.removeEventListener(Event.CLOSE, rtmpConnector_closeHandler);
		}
		
		override protected function screen_removedFromStageHandler(event:Event):void
		{
			super.screen_removedFromStageHandler(event);
			if(rtmpConnector == null)
				return;
			rtmpConnector.disconnect();
		}
		

		private function touchHandler(event:TouchEvent):void
		{
			var tp:TowerPlace; 
			var touch:Touch = event.getTouch(this);
			if(touch == null)
				return;
			
			if(touch.phase == TouchPhase.BEGAN)
			{
				//trace("BEGAN", touch.target, touch.target.parent);
				if(!(touch.target.parent is TowerPlace))
					return;
				tp = touch.target.parent as TowerPlace;
				
				if(tp.tower.troopType != Player.instance.troopType)
					return;
				
				sourceTowers = new Vector.<TowerPlace>();
				sourceTowers.push(tp);
			}
			else 
			{
				if(sourceTowers == null || sourceTowers.length==0)
					return;
				
				if(touch.phase == TouchPhase.MOVED)
				{
					var dest:DisplayObject = battleField.dropTargets.contain(touch.globalX, touch.globalY);
					//trace("MOVED", dest)
					if(dest!=null && dest is TowerPlace)
					{
						tp = dest as TowerPlace;
						if(sourceTowers.indexOf(tp)==-1 && tp.tower.troopType == sourceTowers[0].tower.troopType)
							sourceTowers.push(tp);
					}
					
					for each(tp in sourceTowers)
					{
						tp.arrowContainer.visible = true;
						tp.arrowTo(touch.globalX-tp.x-battleField.x, touch.globalY-tp.y-battleField.y);
					}
				}
				else if(touch.phase == TouchPhase.ENDED)
				{
					dest = battleField.dropTargets.contain(touch.globalX, touch.globalY);
					//trace("ENDED", dest)
					if(dest is TowerPlace)
					{
						var destination:TowerPlace = dest as TowerPlace;
						var lastPoint:TowerPlace;
					
						// check destination is neighbor of our towers 
						var all:Vector.<TowerPlace> = battleField.getAllTowers(sourceTowers[0].tower.troopType);
						for each(tp in all)
						{
							if(destination.links.indexOf(tp) > -1)
							{
								lastPoint = tp;
								break;
							}
						}
						// get allllllll
						all = battleField.getAllTowers(-1);
						if(lastPoint != null)
						{
							var self:int = sourceTowers.indexOf(destination);
							if(self>-1)
								sourceTowers.slice(self, 1);
							
							var sources:Array = new Array();
							for each(tp in sourceTowers)
							{
								tp.fight(destination, all);
								sources.push(tp.index);
							}
							rtmpConnector.send(sources, destination.index);
						}
					}
					for each(tp in sourceTowers)
						tp.arrowContainer.visible = false;
					
					sourceTowers = null;
				}
			}
		}
		
		
		private function rtmpConnector_updateHandler(event:Event):void
		{
			var destination:TowerPlace = battleField.getTower(14-rtmpConnector.rtmfpObject.destination);
			var sourceLen:uint = rtmpConnector.rtmfpObject.source.length;
			
			for(var i:uint=0; i<sourceLen; i++)
				battleField.getTower(14-rtmpConnector.rtmfpObject.source[i]).fight(destination, battleField.getAllTowers(-1));
			//trace(rtmpConnector.rtmfpObject.toString())
		}
		
	}
}