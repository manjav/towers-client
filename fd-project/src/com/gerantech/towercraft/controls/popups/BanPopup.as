package com.gerantech.towercraft.controls.popups 
{
/**
 * ...
 * @author Mansour Djawadi
 */

import com.gerantech.extensions.NativeAbilities;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import feathers.layout.AnchorLayoutData;
import flash.desktop.NativeApplication;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import starling.events.Event;

public class BanPopup extends ConfirmPopup
{
	public function BanPopup()
	{
		super(loc("popup_ban_title"), loc("popup_ban_protest"), loc("close_button"));
		closeOnOverlay = false;
		declineStyle = "danger";
	}
	
	override protected function initialize():void
	{
		super.initialize();
		transitionIn.destinationBound = new Rectangle(stage.stageWidth * 0.15, stage.stageHeight * 0.25, stage.stageWidth * 0.7, stage.stageHeight * 0.3);
		//addChild(messageDisplay);
		
		var descriptionDisplay:RTLLabel = new RTLLabel(data + "", 1, "center", null, true, "justify");
		descriptionDisplay.layoutData = new AnchorLayoutData(padding * 4, padding, padding * 6, padding);
		container.addChild(descriptionDisplay);
		
		rejustLayoutByTransitionData();			
	}
	
	override protected function acceptButton_triggeredHandler(event:Event):void
	{
		navigateToURL(new URLRequest("mailto:towers@gerantech.com?subject=ban(udid:" + NativeAbilities.instance.deviceInfo.id + ")"));
		super.acceptButton_triggeredHandler(event);
	}
	
	override public function close(dispose:Boolean=true):void
	{
		super.close(dispose);
		NativeApplication.nativeApplication.exit();
	}
}
}