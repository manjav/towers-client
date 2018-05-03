package com.gerantech.towercraft.views.decorators
{
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.managers.TutorialManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.views.HealthBar;
import com.gerantech.towercraft.views.PlaceView;
import com.gt.towers.constants.BuildingType;
import com.gt.towers.utils.lists.IntList;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.text.BitmapFontTextFormat;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.events.Event;

public dynamic class BuildingDecorator extends BaseDecorator
{
public var improvablePanel:ImprovablePanel;

private var populationIndicator:BitmapFontTextRenderer;
private var populationBar:HealthBar;
private var populationIcon:Image;
private var underAttack:MovieClip;
private var underAttackId:uint;
private var bodyDisplay:Image;
private var bodyTexture:String;
private var troopTypeDisplay:Image;
private var troopTypeTexture:String;

public function BuildingDecorator(placeView:PlaceView)
{
	super(placeView);
	
	populationBar = new HealthBar(place.building.troopType, place.building.get_population(), place.building.capacity);
	populationBar.width = 140
	populationBar.height = 38
	populationBar.x = place.x - populationBar.width * 0.5 + 24;
	populationBar.y = place.y + 40;
	fieldView.guiImagesContainer.addChild(populationBar);

	populationIndicator = new BitmapFontTextRenderer();
	populationIndicator.pixelSnapping = false;
	populationIndicator.textFormat = new BitmapFontTextFormat(Assets.getFont(), 36, 0xFFFFFF, "center")
	populationIndicator.width = populationBar.width;
	populationIndicator.touchable = false;
	populationIndicator.x = place.x - populationIndicator.width * 0.5 + 24 ;
	populationIndicator.y = place.y + 24;
	fieldView.guiTextsContainer.addChild(populationIndicator);
	
	populationIcon = new Image(Assets.getTexture("population-" + place.building.troopType));
	populationIcon.touchable = false;
	populationIcon.width = 49;
	populationIcon.height = 56;
	populationIcon.x = place.x - populationBar.width * 0.5 - 18;
	populationIcon.y = place.y + 35;
	fieldView.guiImagesContainer.addChild(populationIcon);

	improvablePanel = new ImprovablePanel();
	improvablePanel.x = place.x - improvablePanel.width * 0.5;
	improvablePanel.y = place.y + 50;
	fieldView.guiImagesContainer.addChild(improvablePanel);
	
	bodyDisplay = new Image(Assets.getTexture("building-1"));
	bodyDisplay.touchable = false;
	bodyDisplay.pivotX = bodyDisplay.width * 0.5;
	bodyDisplay.pivotY = bodyDisplay.height * 0.8;
	bodyDisplay.x = place.x;
	bodyDisplay.y = place.y;	
	fieldView.buildingsContainer.addChild(bodyDisplay);
	
	troopTypeDisplay = new Image(Assets.getTexture("building-1-0"));
	troopTypeDisplay.touchable = false;
	troopTypeDisplay.pivotX = troopTypeDisplay.width * 0.5;
	troopTypeDisplay.pivotY = troopTypeDisplay.height * 0.8;
	troopTypeDisplay.x = place.x;
	troopTypeDisplay.y = place.y;
	fieldView.buildingsContainer.addChild(troopTypeDisplay);
	
	underAttack = new MovieClip(Assets.getTextures("building-sword-"), 22);
	underAttack.touchable = false;
	underAttack.visible = false;
	underAttack.x = place.x - underAttack.width * 0.5;
	underAttack.y = place.y - underAttack.height * 2;
	fieldView.buildingsContainer.addChild(underAttack);
	
	if( appModel.battleFieldView.battleData.map.name == "battle_1" )
		TutorialManager.instance.addEventListener(GameEvent.TUTORIAL_TASK_SHOWN, tutorials_showHandler);
}

override protected function update(population:int, troopType:int, occupied:Boolean) : void
{
	super.update(population, troopType, occupied);
	
	var colorIndex:int = troopType==-1 ? -1 : (troopType == player.troopType ? 0 : 1);
	populationIndicator.text = population + "/" + place.building.capacity;
	populationBar.troopType = colorIndex;
	populationBar.value = population;
	populationIcon.texture = Assets.getTexture("population-" + colorIndex);
	
	// _-_-_-_-_-_-_-_-_-_-_-_-  body -_-_-_-_-_-_-_-_-_-_-_-_-_
	var txt:String = "building-" + place.building.type;
	if( bodyTexture != txt )
	{
		bodyTexture = txt;
		bodyDisplay.texture = Assets.getTexture(bodyTexture)	
	}
	//	trace(place.index, place.building.type, troopType, place.building.troopType)
	
	// _-_-_-_-_-_-_-_-_-_-_-_-  troop type -_-_-_-_-_-_-_-_-_-_-_-_-_
	if( troopType > -1 )
		txt += troopType == player.troopType ? "-0" : "-1";
	
	if( troopTypeTexture != txt )
	{
		troopTypeTexture = txt;
		troopTypeDisplay.texture = Assets.getTexture(troopTypeTexture);
		
		// play change troop sounds
		if( place.building.category == BuildingType.B00_CAMP )
		{
			// punch scale on occupation
			punch(1.3);
			
			var tsound:String = troopType == player.troopType ? "battle-capture" : "battle-lost";
			if( appModel.sounds.soundIsAdded(tsound) )
				appModel.sounds.playSound(tsound);
			else
				appModel.sounds.addSound(tsound);
		}
	}
	
	if( place.building.troopType != player.troopType )
	{
		improvablePanel.enabled = false;
		return;
	}
	
	var improvable:Boolean = false;
	if( !player.inTutorial() && !SFSConnection.instance.mySelf.isSpectator )
	{
		var options:IntList = BuildingType.getImproveList(place.building.type);
		for (var i:int=0; i < options.size(); i++) 
		{
			//trace("index:", place.index, "option:", options.get(i), "improvable:", place.building.improvable(options.get(i)), "_population:", place.building._population)
			if( place.building.improvable(options.get(i)) && options.get(i) != BuildingType.B01_CAMP )
			{
				improvable = true;
				break;
			}
		}
	}
	improvablePanel.enabled = improvable;
}

private function punch(scale:Number) : void 
{
	bodyDisplay.scale = scale;
	troopTypeDisplay.scale = scale;
	Starling.juggler.tween(bodyDisplay, 0.25, {scale:1});
	Starling.juggler.tween(troopTypeDisplay, 0.25, {scale:1});
}

public function showUnderAttack():void
{
	appModel.sounds.addAndPlaySound("battle-swords");
	underAttack.visible = true;
	punch(0.9);
	clearTimeout(underAttackId);
	underAttackId = setTimeout(underAttack_completeHandler, 400);
	Starling.juggler.add(underAttack);
	function underAttack_completeHandler():void
	{
		underAttack.visible = false;
		Starling.juggler.remove(underAttack);
	}
}

private function tutorials_showHandler(event:Event) : void 
{
	var task:TutorialTask = event.data as TutorialTask;
	if( task == null || task.type != TutorialTask.TYPE_MESSAGE || task.message != "tutor_battle_1_start_2" )
		return;
	Starling.juggler.tween(populationBar,		0.6, {scale:1.5, transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(populationIcon,		0.6, {scale:1.5, transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(populationIndicator, 0.6, {scale:1.5, transition:Transitions.EASE_OUT_BACK});
	
	Starling.juggler.tween(populationBar,		0.6, {delay:1, scale:1, transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(populationIcon,		0.6, {delay:1, scale:1, transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(populationIndicator, 0.6, {delay:1, scale:1, transition:Transitions.EASE_OUT_BACK});
}

override public function dispose() : void
{
	populationIndicator.removeFromParent(true);
	populationIcon.removeFromParent(true);
	populationBar.removeFromParent(true);
	underAttack.removeFromParent(true);
	improvablePanel.removeFromParent(true);
	bodyDisplay.removeFromParent(true);
	troopTypeDisplay.removeFromParent(true);
	super.dispose();
}
}
}