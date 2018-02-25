package com.gerantech.towercraft.controls.segments.lobby
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;

public class LobbyChatItemDonateSegment extends LobbyChatItemSegment
{

private var labelDisplay:ShadowLabel;
private var messageDisplay:RTLLabel;
private var actionButton:CustomButton;
private var messageLayout:AnchorLayoutData;
public function LobbyChatItemDonateSegment(){}
override public function init():void
{
	super.init();

	height = 220*appModel.scale;
	var background:ImageLoader = new ImageLoader();
	background.source = appModel.theme.popupBackgroundSkinTexture;
	background.layoutData = new AnchorLayoutData( 0, padding*0.5, 0, padding*0.5);
	background.scale9Grid = BaseMetalWorksMobileTheme.POPUP_SCALE9_GRID;
	addChild(background);
	
	actionButton = new CustomButton();
	actionButton.layoutData = new AnchorLayoutData( NaN, padding, NaN, NaN, NaN, 0);
	addChild(actionButton);
	
	messageDisplay = new RTLLabel("", 2, "left", null, false, null, 1);
	messageLayout = new AnchorLayoutData( NaN, actionButton.width + padding, NaN, padding, NaN, 0);
	messageDisplay.layoutData = messageLayout;
	addChild(messageDisplay);
}
override public function commitData(_data:ISFSObject):void
{
	super.commitData(_data);
	actionButton.visible = true;
	messageLayout.right = actionButton.width + padding;
	if ( data.getInt("i") == player.id )
	{
		actionButton.visible = false;
		messageDisplay.align = "right";
		messageDisplay.text = data.getShort("st") > 1 ? "TIME FINISHED! My Req" + " | ct-->" + data.getShort("ct") : "My Req" + " | ct-->" + data.getShort("ct");
	}
	else
	{
		if ( data.getShort("st") == 2 )
		{
			actionButton.visible = false;
			messageDisplay.align = "left";
			messageDisplay.text = "CARD LIMIT REACHED!";
		}
		else if ( data.getShort("st") == 3 )
		{
			actionButton.visible = false;
			messageDisplay.align = "left";
			messageDisplay.text = "TIME FINISHED!" + "Req from " + data.getText("s");
		}
		else{
			actionButton.style = "neutral";
			actionButton.label = "Donate";
			messageDisplay.text = "Req from " + data.getText("s") + " | ct-->" + data.getShort("ct");
		}
	}
}

}
}