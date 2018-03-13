package com.gerantech.towercraft.controls.toasts 
{
	import com.gerantech.towercraft.controls.texts.ShadowLabel;
	import com.gerantech.towercraft.models.Assets;
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalAlign;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Quad;
/**
* ...
* @author MAnsour Djawadi
*/
public class BattleExtraTimeToast extends BaseToast
{

public function BattleExtraTimeToast() 
{
	closeAfter = 3000;
	toastHeight = 340;
}

override protected function initialize():void
{
	super.initialize();

	touchable = false;
	backgroundSkin = new Quad (1, 1, 0);
	backgroundSkin.alpha = 0.5;
	
	transitionIn.time = 0.7;
	transitionOut.destinationBound.y = transitionIn.sourceBound.y = 350 * appModel.scale;
	transitionIn.destinationBound.y = transitionOut.sourceBound.y = 400 * appModel.scale;
	rejustLayoutByTransitionData();
	
	layout = new AnchorLayout();
	
	// time
	var timeLine:LayoutGroup = new LayoutGroup();
	timeLine.layout = new HorizontalLayout();
	HorizontalLayout(timeLine.layout).verticalAlign = VerticalAlign.MIDDLE;
	timeLine.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -100 * appModel.scale);
	addChild(timeLine);
	
	var extraIcon:ImageLoader = new ImageLoader();
	extraIcon.width = 200 * appModel.scale;
	extraIcon.source = Assets.getTexture("extra-time", "gui");
	extraIcon.pixelSnapping = false;
	
	var extraLabel:ShadowLabel = new ShadowLabel(loc("battle_extratime"), 1, 0, null, null, false, null, 1.4);
	
	timeLine.addChild(!appModel.isLTR ? extraLabel : extraIcon);
	timeLine.addChild( appModel.isLTR ? extraLabel : extraIcon);
	
	// elixir
	var elixirLine:LayoutGroup = new LayoutGroup();
	elixirLine.layout = new HorizontalLayout();
	HorizontalLayout(elixirLine.layout).verticalAlign = VerticalAlign.MIDDLE;
	elixirLine.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 100 * appModel.scale);
	addChild(elixirLine);
	
	var elixirIcon:ImageLoader = new ImageLoader();
	elixirIcon.width = 200 * appModel.scale;
	elixirIcon.source = Assets.getTexture("elixir", "gui");
	elixirIcon.pixelSnapping = false;
	
	var elixirLabel:ShadowLabel = new ShadowLabel("2x", 0x27E0DC, 0, null, null, false, null, 2.2);
	elixirLine.addChild( appModel.isLTR ? elixirLabel : elixirIcon);
	elixirLine.addChild(!appModel.isLTR ? elixirLabel : elixirIcon);
	
	// animations
	timeLine.scale = 0;
	Starling.juggler.tween(timeLine, 0.3, {delay:0.0, scale:1, transition:Transitions.EASE_OUT_BACK });
	Starling.juggler.tween(timeLine, 0.3, {delay:3.0, scale:0, transition:Transitions.EASE_IN_BACK });
	
	elixirLine.scale = 0;
	Starling.juggler.tween(elixirLine, 0.3, {delay:0.2, scale:1, transition:Transitions.EASE_OUT_BACK });
	Starling.juggler.tween(elixirLine, 0.3, {delay:3.1, scale:0, transition:Transitions.EASE_IN_BACK });
	appModel.sounds.addAndPlaySound("whoosh");
}
}
}