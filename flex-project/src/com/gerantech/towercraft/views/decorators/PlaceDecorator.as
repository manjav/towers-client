package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.buildings.Place;
	
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.utils.MathUtil;
	
	public class PlaceDecorator extends Sprite
	{
		public var place:Place;
		public var raduis:Number;

		public var arrowContainer:Sprite;
		private var arrow:Image;
		
		private var _selectable:Boolean;
	//	internal var path:Vector.<TowerPlace>;
		private var buildingDecorator:TowerDecorator;
		
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

		/*public function fight(destination:PlaceDecorator, all:Vector.<PlaceDecorator>):void
		{
			var path:Vector.<PlaceDecorator> = PathFinder.find(this, destination, all);

			if(path == null || destination.tower == tower)
				return;
			
			var len:uint = Math.floor(tower.population/2);
			for(var i:uint=0; i<len; i++)
			{
				var t:Troop = new Troop(tower.troopType, path)
				t.x = x;
				t.y = y;
				t.width = raduis/2;
				t.scaleY = t.scaleX;
				parent.addChild(t);
				setTimeout(rush, Troop.RUSH_GAP*i, t, i);
			}			
		}
		
		public function rush(t:Troop, i:uint):void
		{//trace(i)
			if(t.rush())
				tower.popTroop();
		}*/
	}
}