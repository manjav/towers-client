package com.gerantech.towercraft.controls.segments.lobby
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import com.smartfoxserver.v2.entities.data.ISFSObject;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;

public class LobbyChatItemBattleSegment extends LobbyChatItemSegment
{
	
private var labelDisplay:ShadowLabel;
private var messageDisplay:RTLLabel;
private var actionButton:CustomButton;

private var messageLayout:AnchorLayoutData;

public function LobbyChatItemBattleSegment(){}
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
	
	messageDisplay = new RTLLabel("", 1, "center", null, false, null, 1);
	messageLayout = new AnchorLayoutData( NaN, actionButton.width + padding, NaN, padding, NaN, 0);
	messageDisplay.layoutData = messageLayout;
	addChild(messageDisplay);
}
override public function commitData(_data:ISFSObject):void
{
	super.commitData(_data);
	actionButton.visible = data.getShort("st") < 2;
	messageLayout.right = data.getShort("st") < 2 ? (actionButton.width + padding) : (padding*0.5);
	
	if( data.getShort("st") == 0 )
	{
		actionButton.style = itsMe ? "neutral" : "danger";
		actionButton.label = loc( itsMe ? "popup_cancel_label" : "lobby_battle_accept" );
		messageDisplay.text = loc( itsMe ? "lobby_battle_me" : "lobby_battle_request", [data.getUtfString("s")]);
	}
	else if( data.getShort("st") == 1 )
	{
		actionButton.label = loc( "lobby_battle_spectate" );
		messageDisplay.text = loc( "lobby_battle_in", [data.getUtfString("s"), data.getUtfString("o")]);
	}	
	else if( data.getShort("st") == 2 )
	{
		messageDisplay.text = loc( "lobby_battle_ended", [data.getUtfString("s"), data.getUtfString("o")]);
	}
}

}
}