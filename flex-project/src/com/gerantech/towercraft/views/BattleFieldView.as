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
		
		private var towerPlaces:Vector.<PlaceDecorator>;
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			backgroundSkin = new Quad(1,1,1)

			var w:Number = stage.stageWidth/2;
			var h:Number = (w/3)*4;
			
			var leftTopGround:Ground = new Ground(0, 0, w, h);
			addChild(leftTopGround);
			
			var rightTopGround:Ground = new Ground(w*2, 0, w, h);
			rightTopGround.scaleX = -1
			addChild(rightTopGround);
			
			var leftBotGround:Ground = new Ground(0, h*2, w, h);
			leftBotGround.scaleY = -1
			addChild(leftBotGround);
			
			var rightBotGround:Ground = new Ground(w*2, h*2, w, h);
			rightBotGround.scaleX = rightBotGround.scaleY = -1
			addChild(rightBotGround);
			
			createPlaces(w, h);
		}
		
		private function createPlaces(w:Number, h:Number):void
		{
			var paddingX:Number = w/4.444444444444445;
			var paddingY:Number = h/7.6190476190476195;
			var gapX:Number = w-paddingX;
			var gapY:Number = (h-paddingY)/2;
			var cols:Number = 3;
			var rows:Number = 5;
			
			var len:uint = Game.get_instance().battleField.places.size();
			towerPlaces = new Vector.<PlaceDecorator>(len, true);
			for (var i:uint=0; i<len; i++)
			{
				towerPlaces[i] = new PlaceDecorator(Game.get_instance().battleField.places.get(i), gapX/3);
				towerPlaces[i].x = paddingX + gapX * (i%cols);
				towerPlaces[i].y = paddingY + gapY * Math.floor((len-i-1)/cols);
				towerPlaces[i].selectable = (i < 6 || mode==MODE_PLAY);
				towerPlaces[i].name = i;
				addChild(towerPlaces[i]);
			}
		}
	
		public function addDrops():void
		{
			dropTargets = new DropTargets(stage);
			for each(var t:PlaceDecorator in towerPlaces)
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