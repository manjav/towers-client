package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.StarCheck;
import com.gerantech.towercraft.controls.buttons.SimpleButton;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.Fields;
import com.gt.towers.battle.fieldes.FieldData;
import com.gt.towers.battle.fieldes.PlaceData;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

public class OperationMapItemRenderer extends AbstractTouchableListItemRenderer
{
public static var OPERATION_INDEX:int;

private var shire:FieldData;
private var container:Sprite;
private var intervalId:uint;

public function OperationMapItemRenderer()
{
	super();
	width = stageWidth;
	height = (560 / 756) * width;
	container = new Sprite();
	container.scale = width / 756;
	addChild(container);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null )
		return;
	shire = _data as FieldData;

	container.removeChildren();
	var images:Vector.<Image> = Fields.getField(shire, "operations");
	for each(var img:Image in images)
	{
		img.touchable = false;
		container.addChild(img);
	}
		
	for each(var item:PlaceData in shire.places._list)
	{
		var itemIndex:int = item.index + shire.index * 10;
		var score:int = player.operations.get(itemIndex);
		//trace(itemIndex  , OPERATION_INDEX )
		
		var color:String = "locked";
		if ( itemIndex < OPERATION_INDEX )
			color = "passed";
		else if( itemIndex == OPERATION_INDEX )
			color = "current";
		
		var pin:Image = new Image(Assets.getTexture("map-pin-" + color, "operations"));
		pin.alignPivot();
		pin.touchable = false;
		
		if( itemIndex <= OPERATION_INDEX )
		{
			var pinButton:SimpleButton = new SimpleButton();
			pinButton.name = itemIndex.toString();
			pinButton.x = item.x;
			pinButton.y = item.y;
			pinButton.addEventListener(Event.TRIGGERED, pinButton_triggeredHandler);
			container.addChild(pinButton);
			
			var shadow:Image = new Image(Assets.getTexture("pin-shadow", "operations"));
			shadow.alignPivot();
			shadow.alpha = 0.5;
			shadow.y = 4;
			pinButton.addChild(shadow);	
			
			pinButton.addChild(pin);
			
			for( var i:int = 0; i < 3; i++ ) 
			{
				var starImage:StarCheck = new StarCheck(i < score, i == 0 ? 40 : 32, "operations");
				starImage.x = (Math.ceil(i / 4) * ( i == 1 ? 1 : -1 )) * 30;
				starImage.y = (i == 0 ? -50 : -40);
				pinButton.addChild(starImage);
			}
			
			if( item.index == OPERATION_INDEX )
				intervalId = setInterval(punchButton, 2000,  pinButton, 2);
		} 
		else
		{
			pin.x = item.x;
			pin.y = item.y;
			container.addChild(pin);
			
			var lock:Image = new Image(Assets.getTexture("quest-lock", "operations"));
			lock.alignPivot();
			lock.x = item.x;
			lock.y = item.y;
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