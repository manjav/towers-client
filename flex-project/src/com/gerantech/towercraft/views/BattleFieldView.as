package com.gerantech.towercraft.views
{
	import com.gerantech.towercraft.managers.DropTargets;
	import com.gerantech.towercraft.views.decorators.PlaceDecorator;
	import com.gt.towers.Game;
	
	import feathers.controls.LayoutGroup;
	import feathers.layout.AnchorLayout;
	
	import starling.display.Quad;
	
	public class BattleFieldView extends LayoutGroup
	{
		public static const MODE_EDIT:int = 0;
		public static const MODE_PLAY:int = 1;
			
		public var mode:int;
		public var dropTargets:DropTargets;
		
		public var places:Vector.<PlaceDecorator>;

		private var _width:Number;

		private var _height:Number;
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			backgroundSkin = new Quad(1,1,1)

			_width = stage.stageWidth/2;
			_height = (_width/3)*4;
			
			var leftTopGround:Ground = new Ground(0, 0, _width, _height);
			addChild(leftTopGround);
			
			var rightTopGround:Ground = new Ground(_width*2, 0, _width, _height);
			rightTopGround.scaleX = -1
			addChild(rightTopGround);
			
			var leftBotGround:Ground = new Ground(0, _height*2, _width, _height);
			leftBotGround.scaleY = -1
			addChild(leftBotGround);
			
			var rightBotGround:Ground = new Ground(_width*2, _height*2, _width, _height);
			rightBotGround.scaleX = rightBotGround.scaleY = -1
			addChild(rightBotGround);
		}
		
		public function createPlaces():void
		{
			var paddingX:Number = _width/4.444444444444445;
			var paddingY:Number = _height/7.6190476190476195;
			var gapX:Number = _width-paddingX;
			var gapY:Number = (_height-paddingY)/2;
			var cols:Number = 3;
			var rows:Number = 5;
			
			var len:uint = Game.get_instance().battleField.places.size();
			places = new Vector.<PlaceDecorator>(len, true);
			for (var i:uint=0; i<len; i++)
			{
				places[i] = new PlaceDecorator(Game.get_instance().battleField.places.get(i), gapX/3);
				if(Game.get_instance().get_player().troopType == 0 )
				{
					places[i].x = paddingX + gapX * (i%cols);
					places[i].y = paddingY + gapY * Math.floor((len-i-1)/cols);
				}
				else
				{
					places[i].x = _width*2 - (paddingX + gapX * (i%cols));
					places[i].y = _height*2 - (paddingY + gapY * Math.floor((len-i-1)/cols));
				}

				places[i].visible
				places[i].selectable = (i < 6 || mode==MODE_PLAY);
				places[i].name = i;
				addChild(places[i]);
			}

			dropTargets = new DropTargets(stage);
			for each(var t:PlaceDecorator in places)
				if(t.selectable)
					dropTargets.add(t);
		}
		
		/*public function readyForEdit():void
		{
			for(var p:uint=0; p<6; p++)
				towerPlaces[p].towerDecorator = new TowerDecorator(Player.instance.createTower(Player.instance.towerPlaces[p], Player.instance.getTowerLevel(Player.instance.towerPlaces[p]), p), true);
		}*/

	}
}

import com.gerantech.towercraft.models.Assets;

import feathers.controls.ImageLoader;

class Ground extends ImageLoader
{
	public function Ground(x:Number, y:Number, w:Number, h:Number)
	{
		maintainAspectRatio = false;
		this.x = x;
		this.y = y;
		width = w;
		height = h;
		source = Assets.getTexture("ground");
	}
}