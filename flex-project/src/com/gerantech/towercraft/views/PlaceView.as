package com.gerantech.towercraft.views
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.decorators.BarracksDecorator;
	import com.gerantech.towercraft.views.decorators.BuildingDecorator;
	import com.gerantech.towercraft.views.decorators.CrystalDecorator;
	import com.gerantech.towercraft.views.weapons.DefensiveWeapon;
	import com.gt.towers.Game;
	import com.gt.towers.buildings.Barracks;
	import com.gt.towers.buildings.Place;
	import com.gt.towers.constants.BuildingType;
	import com.gt.towers.utils.PathFinder;
	import com.gt.towers.utils.lists.PlaceList;
	
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.MathUtil;
	
	public class PlaceView extends Sprite
	{
		public var place:Place;
		public var raduis:Number;
		public var arrowContainer:Sprite;
		
		private var arrow:Image;
		private var population:int;
		private var rushTimeoutId:uint;
		private var _selectable:Boolean;
		
		private var decorator:BuildingDecorator;
		private var defensiveWeapon:DefensiveWeapon;
		
		public function PlaceView(place:Place, raduis:Number)
		{
			this.place = place;
			this.raduis = raduis;
			
			var bg:Image = new Image(Assets.getTexture("circle"));
			bg.alignPivot();
			bg.width = raduis*2;
			bg.scaleY = bg.scaleX;
			addChild(bg);
			
			createDecorator();
			createArrow();
			place.building.createEngine(place.building.troopType);
		}
		
		private function createDecorator():void
		{
			if(defensiveWeapon != null)
				defensiveWeapon.dispose();
			
			if(decorator != null)
				decorator.removeFromParent(true); 
			
			if(place.building.type == BuildingType.B04_SNIPER)
				decorator = new CrystalDecorator(place);
			else
				decorator = new  BarracksDecorator(place);
			decorator.x = 0;
			decorator.y = 0;
			addChild(decorator);
			
			if(place.building.type == BuildingType.B04_SNIPER)
				defensiveWeapon = new DefensiveWeapon(this);
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
			this.population = population;
			place.building.troopType = troopType;
			decorator.updateElements(population, troopType);
			
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
				var t:TroopView = new TroopView(place.building, path);
				t.x = x;
				t.y = y;
				t.width = raduis;
				t.scaleY = t.scaleX;
				parent.addChildAt(t, 19);
				
				rushTimeoutId = setTimeout(rush, place.building.get_exitGap() * i, t);
			}			
		}
		public function rush(t:TroopView):void
		{
			t.rush();
		}
		
		public function improvable(improveType:int):Boolean
		{
			return population >= place.building.get_capacity() || improveType == BuildingType.B00_CAMP;
		}
		
		public function replaceBuilding(type:int, level:int):void
		{  
			place.building = BuildingType.instantiate(type, place, place.index);
			place.building.level = level;
				
			createDecorator();
		}
		
		override public function dispose():void
		{
			clearTimeout(rushTimeoutId);
			super.dispose();
		}
		
		
	}
}