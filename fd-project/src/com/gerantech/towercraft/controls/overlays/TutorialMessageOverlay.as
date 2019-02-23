package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.tooltips.ConfirmTooltip;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import dragonBones.events.EventObject;
import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingFactory;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalAlign;
import flash.filesystem.File;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;
import starling.events.TouchEvent;

public class TutorialMessageOverlay extends TutorialOverlay
{
	
public static var factory: StarlingFactory;
public static var dragonBonesData:DragonBonesData;

protected var side:int;
protected var characterArmature:StarlingArmatureDisplay;
public function TutorialMessageOverlay(task:TutorialTask):void
{
	super(task);
	side = int(task.data) % 2;
	Assets.loadAnimationAssets(createFactory, "characters");
}

public static function createFactory():void
{
	if( factory != null )
		return;
	factory = new StarlingFactory();
	dragonBonesData = factory.parseDragonBonesData(AppModel.instance.assets.getObject("characters_ske"));
	factory.parseTextureAtlasData(AppModel.instance.assets.getObject("characters_tex"), AppModel.instance.assets.getTexture("characters_tex"));
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	
	appModel.sounds.addAndPlay("whoosh");
	overlay.touchable = true;
	
	characterArmature = factory.buildArmatureDisplay("103");
	characterArmature.touchable = false;
	characterArmature.x = side == 0 ? -300 : stageWidth + 300;
	characterArmature.y = stageHeight;
	characterArmature.scale = 1 / 0.7;
	characterArmature.addEventListener(EventObject.COMPLETE, characterArmature_completeHandler);
	characterArmature.animation.gotoAndPlayByTime("appear", 0, 1);
	addChild(characterArmature);
	Starling.juggler.tween(characterArmature, 0.4, {delay:0.2, x:(side == 0 ? 220 : stageWidth - 220), transition:Transitions.EASE_OUT_BACK, onComplete:characterArmature_completeHandler});
}

protected function characterArmature_completeHandler():void 
{
	var position:Rectangle = new Rectangle(characterArmature.x, stageHeight - 900, 1, 1);
	var tootlip:ConfirmTooltip = new ConfirmTooltip( loc(task.message), position, 1, 0.75, task.type == TutorialTask.TYPE_CONFIRM);
	tootlip.valign = "bot";
	tootlip.addEventListener(Event.SELECT, tootlip_eventsHandler); 
	tootlip.addEventListener(Event.CANCEL, tootlip_eventsHandler); 
	addChild(tootlip);
}

protected function tootlip_eventsHandler(event:Event):void
{
	dispatchEventWith(event.type);
	ConfirmTooltip(event.currentTarget).close();
	close();
}
override protected function stage_touchHandler(event:TouchEvent):void
{
	//if( !_isEnabled || task.type == TutorialTask.TYPE_CONFIRM )
		return;
	super.stage_touchHandler(event);
}
}
}