package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.controls.tooltips.BaseTooltip;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import com.gt.towers.constants.ResourceType;
import feathers.controls.ImageLoader;
import feathers.controls.ProgressBar;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;
import starling.text.TextField;
import starling.text.TextFormat;

public class Indicator extends SimpleLayoutButton
{
public var direction:String;
public var resourceType:int;
public var hasProgressbar:Boolean;
public var hasIncreaseButton:Boolean;

private var progressbar:ProgressBar;
private var progressLabel:TextField;

public var iconDisplay:ImageLoader;
private var _value:Number = -0.1;

private var tutorialArrow:TutorialArrow;
private var minimum:Number;
private var maximum:Number;

public function Indicator(direction:String = "ltr", resourceType:int = 0, hasProgressbar:Boolean = false, hasIncreaseButton:Boolean=true)
{
	this.direction = direction;
	this.resourceType = resourceType;
	this.hasProgressbar = hasProgressbar;
	this.hasIncreaseButton = hasIncreaseButton;
	height = 64 * appModel.scale;
	width = 240 * appModel.scale;
}

override protected function initialize():void
{
	super.initialize();
	this.isQuickHitAreaEnabled = false;
	layout = new AnchorLayout();
	var skin:ImageSkin = new ImageSkin(Assets.getTexture("theme/indicator-background", "gui"));
	skin.scale9Grid = BaseMetalWorksMobileTheme.INDICATORS_SCALE9_GRID;
	backgroundSkin = skin;
	
	var padding:int = 12 * appModel.scale;
	y = 18 * appModel.scale;
	
	if( hasProgressbar )
	{
		progressbar = new ProgressBar();
		progressbar.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		progressbar.minimum = minimum;
		progressbar.maximum = maximum;
		progressbar.value = Math.max(minimum, Math.min( maximum, value ) );
		addChild(progressbar);
	}
	
	progressLabel = new TextField(width-padding*(hasIncreaseButton?8:5), height, _value + "", new TextFormat("SourceSans", appModel.theme.gameFontSize*appModel.scale*0.94, BaseMetalWorksMobileTheme.PRIMARY_TEXT_COLOR));
	progressLabel.x = padding*4;
	progressLabel.pixelSnapping = false;
	progressLabel.autoScale = true;
	addChild(progressLabel);
	
	iconDisplay = new ImageLoader();
	iconDisplay.source = Assets.getTexture("res-"+resourceType, "gui");
	iconDisplay.width = iconDisplay.height = height + padding*2;
	iconDisplay.layoutData = new AnchorLayoutData(NaN, direction=="ltr"?NaN:-height/2, NaN, direction=="ltr"?-height/2:NaN, NaN, 0);
	addChild(iconDisplay);
	
	if( hasIncreaseButton )
	{
		var addButton:IndicatorButton = new IndicatorButton();
		addButton.width = addButton.height = height + padding;
		addButton.layoutData = new AnchorLayoutData(NaN, direction=="ltr"?-height/2:NaN, NaN, direction=="ltr"?NaN:-height/2, NaN, 0);
		addButton.addEventListener(Event.TRIGGERED, addButton_triggerHandler);
		addChild(addButton);
	}
}


public function setData(minimum:Number, value:Number, maximum:Number):void
{
	this.minimum = minimum;
	this.value = value;
	this.maximum = maximum;
	if( progressbar != null )
	{
		progressbar.minimum = minimum;
		progressbar.maximum = maximum;
		progressbar.value = Math.max(minimum, Math.min( maximum, value ) );
	}
}

/*override public function set currentState(value:String):void
{
	if( value == super.currentState )
		return;
	if( hasEventListener(Event.TRIGGERED) )
	{
		scale = value == ButtonState.DOWN ? 1.1 : 1;
		if( value == ButtonState.DOWN && parent != null )
			parent.addChild(this);
	}
	super.currentState = value;
}*/

public function get value():Number
{
	return _value;
}

public function set value(val:Number):void
{
	if( _value == val )
		return;
	_value = val;
	if( progressLabel )
		progressLabel.text = _value.toString();
}

public function showArrow():void
{
	if( tutorialArrow != null || !player.inTutorial() )
		return;
	
	tutorialArrow = new TutorialArrow(true);
	tutorialArrow.layoutData = new AnchorLayoutData(height, NaN, NaN, NaN, 0);
	addChild(tutorialArrow);	
}
public function hideArrow():void
{
	if( tutorialArrow != null )
		tutorialArrow.removeFromParent(true);
	tutorialArrow = null;
}
override protected function trigger():void
{
	hideArrow();
	super.trigger();
	if( resourceType == ResourceType.CURRENCY_SOFT || resourceType == ResourceType.CURRENCY_HARD || resourceType == ResourceType.XP || resourceType == ResourceType.POINT )
		appModel.navigator.addChild(new BaseTooltip(loc("tooltip_indicator_" + resourceType), iconDisplay.getBounds(stage)));
	else
		dispatchEventWith(Event.SELECT);
}	
private function addButton_triggerHandler(event:Event):void
{
	hideArrow();
	dispatchEventWith(Event.SELECT);
}		

public function punch():void
{
	var reservedY:Number = y + 0;
	value = player.resources.get(resourceType);
	y = reservedY - 40 * appModel.scale;
	Starling.juggler.tween(this, 0.3, {y:reservedY, transition:Transitions.EASE_OUT_BACK});
}
}
}