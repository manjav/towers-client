package com.gerantech.towercraft.views
{
	import com.gerantech.towercraft.managers.TutorialManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.tutorials.TutorialData;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gerantech.towercraft.views.decorators.BarracksDecorator;
	import com.gerantech.towercraft.views.decorators.BuildingDecorator;
	import com.gerantech.towercraft.views.decorators.CardDecorator;
	import com.gerantech.towercraft.views.decorators.CrystalDecorator;
	import com.gerantech.towercraft.views.weapons.DefensiveWeapon;
	import com.gt.towers.Game;
	import com.gt.towers.Player;
	import com.gt.towers.battle.fieldes.PlaceData;
	import com.gt.towers.buildings.Place;
	import com.gt.towers.constants.BuildingType;
	import com.gt.towers.utils.PathFinder;
	import com.gt.towers.utils.lists.PlaceDataList;
	import com.gt.towers.utils.lists.PlaceList;
	
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.MathUtil;
	
	public class PlaceView extends Sprite
	{
		public var place:Place;
		public var raduis:Number;
		public var arrowContainer:Sprite;
		public var decorator:BuildingDecorator;
		public var defensiveWeapon:DefensiveWeapon;
		
		private var arrow:MovieClip;
		private var rushTimeoutId:uint;
		private var _selectable:Boolean;
		private var wishedPopulation:int;
		
		public function PlaceView(place:Place)
		{
			this.place = place;
			this.raduis = 160;
			
			var bg:Image = new Image(Assets.getTexture("damage-range"));
			bg.alignPivot();
			bg.width = raduis * 2;
			bg.scaleY = bg.scaleX * 0.8;
			bg.alpha = 0.2;
			addChild(bg);
			
			x = place.x;
			y = place.y;

			createDecorator();
			createArrow();
			place.building.createEngine(place.building.troopType);
			place.building._population = wishedPopulation = place.building.get_population();
		}
		
		private function createDecorator():void
		{
			if( defensiveWeapon != null )
				defensiveWeapon.dispose();
			defensiveWeapon = null;
			
			if( decorator != null )
				decorator.removeFromParent(true); 
			
			/*switch( place.building.category )
			{
				case BuildingType.B40_CRYSTAL:
					decorator = new CrystalDecorator(this);
					defensiveWeapon = new DefensiveWeapon(this);
					break;
				case BuildingType.B10_BARRACKS:*/
					decorator = new CardDecorator(this);
/*					break;
				default:
					decorator = new BuildingDecorator(this);
					break;
			}*/
		}
		
		public function createArrow():void
		{
			arrowContainer = new Sprite();
			arrowContainer.visible = arrowContainer.touchable = false;
			addChildAt(arrowContainer, 0);
			
			arrow = new MovieClip(Assets.getTextures("attack-line-"), 50);
			arrow.touchable = false;
			arrow.width = 64;
			arrow.tileGrid = new Rectangle(0, 0, arrow.width, arrow.width);
			arrow.alignPivot("center", "bottom");
			arrowContainer.addChild(arrow);
			Starling.juggler.add(arrow);
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
		}

		public function update(population:int, troopType:int) : void
		{
			showMidSwipesTutorial(troopType);
			decorator.updateTroops(population, troopType);
			if( population < wishedPopulation )
				decorator.showUnderAttack();

			if( population == place.building._population + 1 || population == place.building._population + 2 || wishedPopulation == 0)
				wishedPopulation = population;
			place.building._population = population;
			place.building.troopType = troopType;
			
			if(hasEventListener(Event.UPDATE))
				dispatchEventWith(Event.UPDATE, false);
		}
		
		private function showMidSwipesTutorial(troopType:int):void
		{
			if( !appModel.battleFieldView.battleData.map.isQuest || appModel.battleFieldView.battleData.map.index > 2 )
				return;
			if( place.building.troopType == player.troopType || troopType != player.troopType )
				return;
			if( place.index > appModel.battleFieldView.battleData.map.places.size()-2 )
				return;
			if( !appModel.battleFieldView.responseSender.actived )
				return;

			tutorials.removeAll();
			var tutorialData:TutorialData = new TutorialData("occupy_" + appModel.battleFieldView.battleData.map.index + "_" + place.index);
			var places:PlaceDataList = new PlaceDataList();
			places.push(getPlace(place.index));
			places.push(getPlace(place.index + 1));
			if( places.size() > 0 )
				tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_SWIPE, null, places, 0, 500));
			tutorials.show(tutorialData);
		}
		
		private function getPlace(index:int):PlaceData
		{
			var p:PlaceData = appModel.battleFieldView.battleData.map.places.get(index);
			return new PlaceData(p.index, p.x, p.y, p.type, player.troopType, "", true, p.index);
		}
		
		public function fight(destination:Place) : void
		{
			wishedPopulation = Math.floor(place.building._population * 0.5);
			var path:PlaceList = PathFinder.find(place, destination, appModel.battleFieldView.battleData.battleField.getAllTowers(-1));
			if(path == null || destination.building == place.building)
				return;
			
			var len:int = Math.floor(place.building.get_population() / 2);
			for(var i:uint=0; i<len; i++)
			{
				var t:TroopView = new TroopView(place.building, path);
				t.x = x;
				t.y = y ;
				BattleFieldView(parent).troopsContainer.addChild(t);
				rushTimeoutId = setTimeout(rush, place.building.troopRushGap * i + 300, t);
			}
			
			if ( place.building.troopType == player.troopType )
			{
				var soundIndex:int = 0;
				if( len > 5 && len < 10 )
					soundIndex = 1;
				else if ( len >= 10 && len < 20 )
					soundIndex = 2;
				else if ( len >= 20 )
					soundIndex = 3;
				
				if( !appModel.sounds.soundIsPlaying("battle-go-army-"+soundIndex) )
					appModel.sounds.addAndPlaySound("battle-go-army-"+soundIndex);
			}
		}
		public function rush(t:TroopView):void
		{
			if( place.building.get_population() > 0 )
				t.rush(place);
		}
		
		public function replaceBuilding(type:int, level:int):void
		{
			/*wishedPopulation = Math.floor(place.building._population/2);
			var tt:int = place.building.troopType;
			var p:int = place.building._population;
			//trace("replaceBuilding", place.index, type, level, place.building._population);
			place.building = BuildingType.instantiate(game ,type, place, place.index);
			place.building.set_level( level );
			createDecorator();
			if( type == BuildingType.B01_CAMP )
				update(p,tt);*/
			place.building.type = type;
			place.building.set_level(level);
			decorator.updateBuilding();
		}
		
		override public function dispose():void
		{
			Starling.juggler.remove(arrow);
			clearTimeout(rushTimeoutId);
			
			if( decorator != null )
				decorator.dispose();
			if( defensiveWeapon != null )
				defensiveWeapon.dispose();
			super.dispose();
		}
		
		protected function get tutorials():		TutorialManager	{	return TutorialManager.instance;	}
		protected function get appModel():		AppModel		{	return AppModel.instance;			}
		protected function get game():			Game			{	return appModel.game;				}
		protected function get player():		Player			{	return game.player;					}
	}
}