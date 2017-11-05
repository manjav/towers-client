package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.SimpleButton;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.Fields;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gt.towers.battle.fieldes.FieldData;
import com.gt.towers.battle.fieldes.PlaceData;
import com.gt.towers.utils.lists.PlaceDataList;

import flash.utils.clearInterval;
import flash.utils.setInterval;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

public class QuestMapItemRenderer extends BaseCustomItemRenderer
{
public static var questIndex:int;

private var shire:FieldData;
private var container:Sprite;
private var intervalId:uint;

public function QuestMapItemRenderer()
{
	super();
	height = 800 * appModel.scale;
	container = new Sprite();
	container.scale = appModel.scale * 1.42857;
	addChild(container);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null )
		return;
	shire = _data as FieldData;

	container.removeChildren();
	var images:Vector.<Image> = Fields.getField(shire, "quests");
	for each(var img:Image in images)
	{
		img.touchable = false;
		container.addChild(img);
	}
		
	for each(var item:PlaceData in shire.places._list)
	{
		var score:int = player.quests.get(item.index);
		//trace(item.index , player.quests.get(item.index) )
		

		var color:String = "locked";
		if ( item.index < questIndex )
			color = "passed";
		else if( item.index == questIndex )
			color = "current";

		var pin:Image = new Image(Assets.getTexture("map-pin-" + color, "quests"));
		pin.alignPivot();
		pin.touchable = false;
		
		if( item.index <= questIndex )
		{
			var pinButton:SimpleButton = new SimpleButton();
			pinButton.name = item.index+"";
			pinButton.x = item.x;
			pinButton.y = item.y;
			pinButton.addEventListener(Event.TRIGGERED, pinButton_triggeredHandler);
			container.addChild(pinButton);
			
			var shadow:Image = new Image(Assets.getTexture("pin-shadow", "quests"));
			shadow.alignPivot();
			shadow.alpha = 0.5;
			shadow.y = 4;
			pinButton.addChild(shadow);	
			
			pinButton.addChild(pin);

			if ( score > 0 )
			{
				var star_0:Image = new Image(Assets.getTexture("star-center", "quests"));
				star_0.alignPivot("center", "top");
				star_0.y = 14;
				star_0.touchable = false;
				pinButton.addChild(star_0);
				
				if ( score > 1 )
				{
					var star_1:Image = new Image(Assets.getTexture("star-side", "quests"));
					star_1.alignPivot("right", "top");
					star_1.scaleX = -1
					star_1.x = 18;
					star_1.y = 5;
					star_1.touchable = false;
					pinButton.addChild(star_1);
					
					if ( score > 2 )
					{
						var star_2:Image = new Image(Assets.getTexture("star-side", "quests"));
						star_2.alignPivot("right", "top");
						star_2.x = - 18;
						star_2.y = + 5;
						star_2.touchable = false;
						pinButton.addChild(star_2);
					}
				}
			}
			
			if( item.index == questIndex )
				intervalId = setInterval(punchButton, 2000,  pinButton, 2);
		} 
		else
		{
			pin.x = item.x;
			pin.y = item.y;
			container.addChild(pin);
			
			var lock:Image = new Image(Assets.getTexture("quest-lock", "quests"));
			lock.alignPivot();
			lock.x = item.x;
			lock.y = item.y + 16;
			container.addChild(lock);
		}
	}
}

private function pinButton_triggeredHandler(event:Event):void
{
	var btn:SimpleButton = event.currentTarget as SimpleButton;
	punchButton(btn);
	owner.dispatchEventWith(Event.SELECT, false, btn);
}

private function punchButton(button:SimpleButton, initScale:Number=0.4):void
{
	button.scale = initScale;
	Starling.juggler.tween(button, 0.9, {scale:1, transition:Transitions.EASE_OUT_ELASTIC});	
}

override public function dispose():void
{
	clearInterval(intervalId);
	super.dispose();
}
}
}