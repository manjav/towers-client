package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.TroopView;
	import com.gt.towers.Game;
	import com.gt.towers.buildings.Place;
	import com.gt.towers.others.BalancingData;
	import com.gt.towers.utils.PathFinder;
	import com.gt.towers.utils.lists.PlaceList;
	
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.MathUtil;
	
	public class PlaceDecorator extends Sprite
	{
		public var place:Place;
		public var raduis:Number;

		public var arrowContainer:Sprite;
		
		private var arrow:Image;
		private var _selectable:Boolean;
		private var buildingDecorator:TowerDecorator;
		private var population:int;
		
		public function PlaceDecorator(place:Place, raduis:Number)
		{
			this.place = place;
			this.raduis = raduis;
			
			var bg:Image = new Image(Assets.getTexture("circle"));
			bg.alignPivot();
			bg.width = raduis*2;
			bg.scaleY = bg.scaleX;
			addChild(bg);
			
			buildingDecorator = new TowerDecorator(place);
			buildingDecorator.x = 0;
			buildingDecorator.y = 0;
			addChild(buildingDecorator);
			
			createArrow();
			
			place.building.createEngine(place.building.troopType);
		}

		
		public function createArrow():void
		{
			arrowContainer = new Sprite();
			arrowContainer.visible = arrowContainer.touchable = false;
			addChildAt(arrowContainer, 0);
			
			arrow = new Image(Assets.getTexture("arrow"));
			arrow.scale9Grid = new Rectangle(6, 6, 3, 2);
			arrow.alignPivot("center", "bottom");
			arrowContainer.addChild(arrow);
		}
		public function arrowTo(disX:Number, disY:Number):void
		{
			arrow.height = Math.sqrt(Math.pow(disX, 2) + Math.pow(disY, 2));
			arrowContainer.rotation = MathUtil.normalizeAngle(-Math.atan2(-disX, -disY));//trace(tp.arrow.scaleX, tp.arrow.scaleY, tp.arrow.height)
		}

		
		public function get selectable():Boolean
		{
			return _selectable;
		}
		public function set selectable(value:Boolean):void
		{
			touchable = value;
			_selectable = value;
			//alpha = _selectable ? 1: 0.5;
		}

		
		public function update(population:int, troopType:int) : void
		{
			// reset when captured.
			if(place.building.troopType != troopType)
				place.building.level = 1;
			
			place.building.troopType = troopType;
			this.population = population;
			buildingDecorator.updateElements(population, troopType);
			
			if(hasEventListener(Event.UPDATE))
				dispatchEventWith(Event.UPDATE, false);
		}
		
		
		public function fight(destination:Place) : void
		{
			var path:PlaceList = PathFinder.find(place, destination, Game.get_instance().battleField.getAllTowers(-1));
			
			if(path == null || destination.building == place.building)
				return;
			
			var len:int = Math.floor(population / 2);
			for(var i:uint=0; i<len; i++)
			{
				var t:TroopView = new TroopView(place.building.troopType, path);
				t.x = x;
				t.y = y;
				t.width = raduis/2;
				t.scaleY = t.scaleX;
				parent.addChild(t);
				
				setTimeout(rush, BalancingData.RUSH_GAP * i, t);
			}			
		}
		public function rush(t:TroopView):void
		{
			t.rush();
		}
		
		public function get upgradable():Boolean
		{
			return population >= place.building.get_capacity();
		}
		public function upgrade():void
		{
			place.building.level ++;
		}
	}
}