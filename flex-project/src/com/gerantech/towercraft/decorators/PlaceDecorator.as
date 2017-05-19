package com.gerantech.towercraft.decorators
{
	import com.gerantech.towercraft.managers.PathFinder;
	import com.gerantech.towercraft.models.towers.Tower;
	import com.gerantech.towercraft.models.vo.Troop;
	import com.gerantech.towercraft.models.vo.UserData;
	
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.utils.MathUtil;
	import com.gerantech.towercraft.models.Assets;
	
	public class PlaceDecorator extends Sprite
	{
		public var index:int;
		public var raduis:Number;
		public var links:Vector.<PlaceDecorator>;
		public var owner:PlaceDecorator;
		public var arrowContainer:Sprite;
		private var arrow:Image;
		
		private var _towerDecorator:TowerDecorator;
		private var _selectable:Boolean;
	//	internal var path:Vector.<TowerPlace>;
		
		public function PlaceDecorator(raduis:Number, index:int)
		{
			links = new Vector.<PlaceDecorator>();
			this.index = index;
			this.raduis = raduis;
			
			var bg:Image = new Image(Assets.getTexture("circle"));
			bg.alignPivot();
			bg.width = raduis*2;
			bg.scaleY = bg.scaleX;
			addChild(bg);
		}

		public function get isAlone():Boolean
		{
			var len:uint = links.length;
			for(var l:uint=0; l<len; l++)
				if(links[l].tower.troopType == tower.troopType)
					return false;
			return true;
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

		
		public function get towerDecorator():TowerDecorator
		{
			return _towerDecorator;
		}
		public function set towerDecorator(value:TowerDecorator):void
		{
			if(_towerDecorator != null)
				_towerDecorator.removeFromParent();
			
			if(value == null)
			{
				_towerDecorator.place = null;
				_towerDecorator = null;
				return;
			}
			
			_towerDecorator = value;
			_towerDecorator.place = this;
			_towerDecorator.x = 0;
			_towerDecorator.y = 0;
			addChild(_towerDecorator);
		}
		
		public function get tower():Tower
		{
			if(towerDecorator == null)
				return null;
			return towerDecorator.tower;
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

		public function fight(destination:PlaceDecorator, all:Vector.<PlaceDecorator>):void
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
		}

		
		
		
		
	}
}