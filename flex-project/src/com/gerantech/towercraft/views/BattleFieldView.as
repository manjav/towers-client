package com.gerantech.towercraft.views
{
	import com.gerantech.towercraft.controls.TowersLayout;
	import com.gerantech.towercraft.managers.DropTargets;
	import com.gerantech.towercraft.managers.net.ResponseSender;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.Fields;
	import com.gerantech.towercraft.models.vo.BattleData;
	
	import flash.geom.Rectangle;
	
	import feathers.layout.AnchorLayout;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class BattleFieldView extends TowersLayout
	{
		public var battleData:BattleData;
		
		public var places:Vector.<PlaceView>;
		public var troopsList:Vector.<TroopView>;
		public var responseSender:ResponseSender;

		public var dropTargets:DropTargets;
		public var troopsContainer:Sprite;
		public var buildingsContainer:Sprite;
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			backgroundSkin = new Quad(1,1,0xb7bb3c);
			y = (stage.stageHeight-1920*appModel.scale)/2;

			troopsContainer = new Sprite();
			buildingsContainer = new Sprite();
	
			troopsList = new Vector.<TroopView>();
			troopsContainer.addEventListener(Event.ADDED, battleField_addedHandler);
			troopsContainer.addEventListener(Event.REMOVED, battleField_removedHandler);
		}
		
		private function battleField_addedHandler(event:Event):void
		{
			var troopView:TroopView = event.target as TroopView;
			if(troopView == null)
				return;
			troopView.addEventListener(Event.TRIGGERED, troopView_triggeredHandler);
			troopsList.push(troopView);
		}
		private function battleField_removedHandler(event:Event):void
		{
			var troopView:TroopView = event.target as TroopView;
			if(troopView == null)
				return;
			troopView.removeEventListener(Event.TRIGGERED, troopView_triggeredHandler);
			troopsList.removeAt(troopsList.indexOf(troopView));
		}		
		private function troopView_triggeredHandler(event:Event):void
		{
			var troopView:TroopView = event.target as TroopView;
			//trace("hitTroop", battleData.singleMode, troopView.type, player.troopType, troopView.id);
			if(battleData.singleMode || troopView.type == player.troopType)
				responseSender.hitTroop(troopView.id, event.data as Number);
		}		
		
		
		public function createPlaces(battleData:BattleData):void
		{
			this.battleData = battleData;
			responseSender = new ResponseSender(battleData.room);
			
			var images:Vector.<Image> = Fields.getField(battleData.battleField.map, "battlefields", true);
			for each(var img:Image in images)
				addChild(img);
			
			// tile grass ground
			var tileTexture:Texture = Assets.getTexture("ground-228","battlefields");
			var image:Image = new Image(tileTexture);
			image.tileGrid = new Rectangle(0, 0, 456, 456);
			image.width = stage.width;
			image.height = stage.height;
			addChildAt(image, 0);
			
			var len:uint = battleData.battleField.places.size();
			places = new Vector.<PlaceView>(len, true);
			for (var i:uint=0; i<len; i++)
			{
				places[i] = new PlaceView(battleData.battleField.places.get(i));

				places[i].selectable = true;
				places[i].name = i;
				addChild(places[i]);
			}

			dropTargets = new DropTargets(stage);
			for each(var t:PlaceView in places)
				if(t.selectable)
					dropTargets.add(t);
				
			addChild(troopsContainer);
			addChild(buildingsContainer);
		}
	}
}