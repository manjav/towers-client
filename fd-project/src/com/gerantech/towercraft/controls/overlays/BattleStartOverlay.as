package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.headers.BattleHeader;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.vo.BattleData;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import starling.display.Sprite;

import flash.utils.setTimeout;

import feathers.controls.AutoSizeMode;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;

public class BattleStartOverlay extends BaseOverlay
{
public var mapIndex:int = 0;
public var battleData:BattleData;

private var padding:int;
private var axisHeader:BattleHeader;
private var alliseHeader:BattleHeader;
private var container:LayoutGroup;

public function BattleStartOverlay(mapIndex:int, battleData:BattleData)
{
	super();
	padding = 48 * appModel.scale;
	this.mapIndex = mapIndex;
	this.battleData = battleData;
}

override protected function initialize():void
{
	closeOnStage = false;
	autoSizeMode = AutoSizeMode.STAGE;
	hasOverlay = true;
	super.initialize();
	
	container = new LayoutGroup();
	container.layout = new AnchorLayout();
	container.x = padding;
	container.width = stage.stageWidth - padding * 2;
	container.height = stage.stageHeight;
	addChild(container);
	
	// axis elements
	var name:String = mapIndex >-1?(loc("quest_label") + " " +(mapIndex + 1)): battleData.axis.getText("name");
	if( player.inTutorial() && player.tutorialMode == 1 )
		name = loc("trainer_label");
	axisHeader = new BattleHeader(name, false);
	axisHeader.layoutData = new AnchorLayoutData(300 * appModel.scale, 0, NaN, 0);
	container.addChild(axisHeader);
	
	if( mapIndex > -1 )
	{
		setTimeout(disappear, 2000);
		return;
	}
	
	// allise elements
	name = battleData.allis.getText("name") == "guest" ? loc("guest_label") : battleData.allis.getText("name");
	alliseHeader = new BattleHeader( name, true);
	alliseHeader.width = padding * 16;
	alliseHeader.layoutData = new AnchorLayoutData(800 * appModel.scale, 0, NaN, 0);
	container.addChild(alliseHeader);
	
	setTimeout(disappear, 2000);
}

public function disappear():void
{
	Starling.juggler.tween(container, 0.6, {alpha:0, y:-padding*4, transition:Transitions.EASE_IN_BACK});
	Starling.juggler.tween(overlay, 0.5, {alpha:0});
	setTimeout(close, 800, true)
}
}
}