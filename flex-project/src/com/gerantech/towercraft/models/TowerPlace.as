package com.gerantech.towercraft.models
{
	import com.gerantech.towercraft.Troop;
	import com.gerantech.towercraft.decorators.TowerDecorator;
	import com.gerantech.towercraft.models.towers.Tower;
	
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import starling.display.Canvas;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.utils.MathUtil;
	
	public class TowerPlace extends Canvas
	{
		public var raduis:Number;
		public var links:Vector.<TowerPlace>;
		public var owner:TowerPlace;
		public var arrowContainer:Sprite;
		private var arrow:Image;
		
		private var _towerDecorator:TowerDecorator;
		private var _selectable:Boolean;
	//	internal var path:Vector.<TowerPlace>;
		
		public function TowerPlace(raduis:Number)
		{
			links = new Vector.<TowerPlace>();
			this.raduis = raduis;
			
			beginFill(0xFF, 0);
			drawCircle(0, 0, raduis);
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
			
			arrow = new Image(Textures.get("arrow"));
			arrow.scale9Grid = new Rectangle(6, 10, 3, 4);
			arrow.alignPivot("center", "bottom");
			arrowContainer.addChild(arrow);
		}

		public function fight(destination:TowerPlace, all:Vector.<TowerPlace>):void
		{
			trace(name, destination.name)

			for (var p:uint=0; p<all.length; p++)
				all[p].owner = null;
			
			var path:Vector.<TowerPlace> = findPath(this, destination);

			if(destination.tower == tower)
				return;
			/*trace(name, destination.name);
			var _path:Vector.<TowerPlace> = findPath(this, destination);
			for(var p:uint=0; p<_path.length; p++)
			trace("->", _path[p].name);*/
			
			var len:uint = Math.floor(tower.population/2);
			for(var i:uint=0; i<len; i++)
			{
				var t:Troop = new Troop(tower.troopType, path);
				t.x = x;
				t.y = y;
				parent.addChild(t);
				setTimeout(rush, 200*i, t, i);
			}			
		}
		
		public function rush(t:Troop, i:uint):void
		{//trace(i)
			if(t.rush())
				tower.popTroop();
		}

		
		
		
		
		/**
		 * Use 'Breadth First Search' (BFS) for finding path of troops
		 */ 
		internal static function findPath(origin:TowerPlace, destination:TowerPlace):Vector.<TowerPlace>
		{
			//trace(origin.name, "find")
			// Creating our Open and Closed Lists
			var closedList:Vector.<TowerPlace> = new Vector.<TowerPlace>();
			var openList:Vector.<TowerPlace> = new Vector.<TowerPlace>();
			// Adding our starting point to Open List
			openList.push(origin);
			
			// Loop while openList contains some data.
			while (openList.length != 0)
			{
				// Loop while openList contains some data.
				var n:TowerPlace = openList.shift();
				
				// Check if tower is Destination
				if (n == destination)
				{
					closedList.push(destination);
					break;
				}
				
				var nLength:uint = n.links.length;
				// Add each neighbor to the end of our openList
				for (var i:uint=0; i < nLength; i++) 
				{
					if((n.links[i]!=origin && n.links[i].tower.troopType == origin.tower.troopType) || n.links[i] == destination)
					{
						//trace(n.links[i].name, "added to", n.name )
						if(n.links[i].owner == null)
							n.links[i].owner = n;
						openList.push(n.links[i]);
					}
				}
				
				// Add current tower to closedList
				closedList.push(n);
			}
			
			for (i=0; i < closedList.length; i++) 
				trace(closedList[i].name, ",", (closedList[i].owner==null?"":closedList[i].owner.name))
				
			// Create return path
			var ret:Vector.<TowerPlace> = new Vector.<TowerPlace>();
			var last:TowerPlace = closedList[closedList.length-1];
			do
			{
				ret.push(last);
				last = last.owner;
			}
			while(last!=null && last != origin);
			//ret.push(origin);
			ret.reverse();
			trace("=>", ret.length)
			return ret;
		}
		
	}
}