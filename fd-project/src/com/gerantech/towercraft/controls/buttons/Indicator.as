package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.controls.tooltips.BaseTooltip;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.RewardData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.events.CoreEvent;
import feathers.controls.ImageLoader;
import feathers.controls.ProgressBar;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;
import starling.text.TextField;
import starling.text.TextFormat;

public class Indicator extends SimpleLayoutButton
{
public var type:int;
public var direction:String;
public var value:Number = -0.1;
public var minimum:Number = 0;
public var maximum:Number = Number.MAX_VALUE;
public var hasProgressbar:Boolean;
public var hasIncreaseButton:Boolean;
public var autoApdate:Boolean;
public var formatLabelFactory:Function;
public var iconDisplay:ImageLoader;

private var progressbar:ProgressBar;
private var progressLabel:TextField;
private var tutorialArrow:TutorialArrow;

public function Indicator(direction:String, type:int, hasProgressbar:Boolean = false, hasIncreaseButton:Boolean = true, autoApdate:Boolean = true)
{
	this.direction = direction;
	this.type = type;
	this.hasProgressbar = hasProgressbar;
	this.hasIncreaseButton = hasIncreaseButton;
	this.autoApdate = autoApdate;
	this.width = 240;
	this.height = 64;
	addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
}

override protected function initialize():void
{
	super.initialize();
	this.isQuickHitAreaEnabled = false;
	layout = new AnchorLayout();
	var skin:ImageSkin = new ImageSkin(Assets.getTexture("theme/indicator-background"));
	skin.scale9Grid = MainTheme.INDICATORS_SCALE9_GRID;
	backgroundSkin = skin;
	
	if( formatLabelFactory == null )
		formatLabelFactory = defultFormatLabelFactory;
	
	if( hasProgressbar )
	{
		progressbar = new ProgressBar();
		progressbar.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		progressbar.minimum = minimum;
		progressbar.maximum = maximum;
		progressbar.value = value;
		addChild(progressbar);
	}
	
	progressLabel = new TextField(width - (hasIncreaseButton?96:60), height, formatLabelFactory(minimum, value, maximum), new TextFormat("SourceSans", appModel.theme.gameFontSize * 0.94, MainTheme.PRIMARY_TEXT_COLOR));
	progressLabel.x = 48;
	progressLabel.pixelSnapping = false;
	progressLabel.autoScale = true;
	addChild(progressLabel);
	
	iconDisplay = new ImageLoader();
	iconDisplay.pivotX = iconDisplay.pivotY = iconDisplay.width * 0.5;
	iconDisplay.source = Assets.getTexture("res-" + type, "gui");
	iconDisplay.width = iconDisplay.height = height + 24;
	iconDisplay.layoutData = new AnchorLayoutData(NaN, direction == "ltr"?NaN: -height / 2, NaN, direction == "ltr"? -height / 2:NaN, NaN, 0);
	addChild(iconDisplay);
	
	if( hasIncreaseButton )
	{
		var addButton:IndicatorButton = new IndicatorButton();
		addButton.width = addButton.height = height + 12;
		addButton.layoutData = new AnchorLayoutData(NaN, direction == "ltr"? -height / 2:NaN, NaN, direction == "ltr"?NaN: -height / 2, NaN, 0); 
		addButton.addEventListener(Event.TRIGGERED, addButton_triggerHandler);
		addChild(addButton);
	}
	
	if( !autoApdate )
		return;
	
	if( appModel.loadingManager.state >= LoadingManager.STATE_LOADED )
		loadingManager_loadedHandler(null);
	else
		appModel.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
}

protected function loadingManager_loadedHandler(event:LoadingEvent) : void
{
	appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	appModel.navigator.addEventListener("achieveResource", navigator_achieveResourceHandler);
	player.resources.addEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
	setData(minimum, -1, maximum);
}

protected function navigator_achieveResourceHandler(event:Event) : void 
{
	var params:Array = event.data as Array;
	addResourceAnimation(params[0], params[1], params[2], params[3]);
}

protected function addedToStageHandler(event:Event):void 
{
	if( appModel.battleFieldView == null || appModel.battleFieldView.battleData == null || appModel.battleFieldView.battleData.outcomes == null )
		return;
	for( var i:int = 0; i < appModel.battleFieldView.battleData.outcomes.length; i++ )
	{
		var rd:RewardData = appModel.battleFieldView.battleData.outcomes[i];
		if( type == rd.key )
		{
			addResourceAnimation(rd.x, rd.y, rd.key, rd.value, 0.5 * i + 0.1);
			appModel.battleFieldView.battleData.outcomes.removeAt(i);
			return;
		}
	}
}

protected function playerResources_changeHandler(event:CoreEvent):void
{
	trace("CoreEvent.CHANGE:", ResourceType.getName(event.key), event.from, event.to);
	if( event.key == type )
		setData(minimum, -1, maximum);
}

public function setData(minimum:Number, value:Number, maximum:Number, changeDuration:Number = 0):void
{
	this.minimum = minimum;
	if( value == -1 )
		value = getValue();
	this.value = Math.max(minimum, Math.min( maximum, value ) );
	this.maximum = maximum;
	trace(type, this.minimum, value, this.maximum, this.value);
	if( progressLabel != null )
		progressLabel.text = formatLabelFactory(minimum, value, maximum);
	if( progressbar != null )
	{
		progressbar.minimum = minimum;
		progressbar.maximum = maximum;
		if( changeDuration <= 0 )
			progressbar.value = this.value;
		else
			Starling.juggler.tween(progressbar, changeDuration, {value:this.value, transition:Transitions.EASE_IN_OUT})
	}
}

public function addResourceAnimation(x:Number, y:Number, type:int, count:int, delay:Number = 0):void
{
	if( ResourceType.isCard(type) && type == ResourceType.R3_CURRENCY_SOFT )
	{
		appModel.navigator.addAnimation(x, y, 130, Assets.getTexture("cards"), count, new Rectangle(320, 1900), delay, null);
		return;
	}
	
	if( this.type != type )
		return;
	
	setData(minimum, getValue() - count, maximum);
	setTimeout(function():void
	{
		var rect:Rectangle;
		if( iconDisplay.stage == null )
			rect = new Rectangle(x, y - 500, 2, 2);
		else
			rect = iconDisplay.getBounds(stage);
		
		appModel.navigator.addAnimation(x, y, 130, Assets.getTexture("res-" + type, "gui"), count, rect, 0.02, punch);
	}, delay * 1000);
}

private function getValue() : int
{
	return type == ResourceType.R17_STARS ? exchanger.items.get(ExchangeType.C104_STARS).numExchanges : player.getResource(type);
}

private function defultFormatLabelFactory(minimum:Number, value:Number, maximum:Number) : String
{
	return value.toString();
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
	if( type == ResourceType.R3_CURRENCY_SOFT || type == ResourceType.R4_CURRENCY_HARD || type == ResourceType.R1_XP || type == ResourceType.R2_POINT )
		appModel.navigator.addChild(new BaseTooltip(loc("tooltip_indicator_" + type), iconDisplay.getBounds(stage)));
	else
		dispatchEventWith(Event.SELECT);
}	
private function addButton_triggerHandler(event:Event):void
{
	hideArrow();
	if( type == ResourceType.R3_CURRENCY_SOFT || type == ResourceType.R4_CURRENCY_HARD )
		appModel.navigator.gotoShop(type);
	dispatchEventWith(Event.SELECT);
}		

public function punch():void
{
	setData(minimum, -1, maximum, 1);
	iconDisplay.scale = 2;
	Starling.juggler.tween(iconDisplay, 0.5, {scale:1, transition:Transitions.EASE_OUT_BACK});
}

override public function dispose():void
{
	removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	appModel.navigator.removeEventListener("achieveResource", navigator_achieveResourceHandler);
	player.resources.removeEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
	super.dispose();
}
}
}