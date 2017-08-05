package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.BuildingCard;
	import com.gerantech.towercraft.controls.buttons.ExchangeButton;
	import com.gerantech.towercraft.controls.items.FeatureItemRenderer;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gt.towers.buildings.Building;
	import com.gt.towers.constants.BuildingFeatureType;
	import com.gt.towers.constants.ResourceType;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.ScrollPolicy;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.HorizontalLayoutData;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;
	import feathers.skins.ImageSkin;
	
	import starling.core.Starling;
	import starling.events.Event;

	public class BuildingDetailsPopup extends BasePopup
	{
		public var buildingType:int;
		
		private var building:Building;
		private var upgradeButton:ExchangeButton;
		private var featureList:List;
		private var header:LayoutGroup;
		private var padding:int;

		private var closeButton:ExchangeButton;

		private var textsContainer:LayoutGroup;

		private var titleDisplay:RTLLabel;

		private var messageDisplay:RTLLabel;

		override protected function initialize():void
		{
			closable = false;
			super.initialize();
			layout = new AnchorLayout();
			
			building = player.buildings.get(buildingType);
			
			var skin:ImageSkin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
			skin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID;
			backgroundSkin = skin;
			
			padding = 36 * appModel.scale;
			layout = new AnchorLayout();
			
			var hLayout:HorizontalLayout = new HorizontalLayout();
			hLayout.verticalAlign = VerticalAlign.JUSTIFY;
			hLayout.gap = padding;
			
			header = new LayoutGroup();
			header.layout = hLayout;
			header.layoutData = new AnchorLayoutData(padding, padding, NaN, padding);
			header.height = transitionIn.destinationBound.height*0.3;
			addChild(header);
			
			var buildingIcon:BuildingCard = new BuildingCard();
			buildingIcon.layoutData = new HorizontalLayoutData(40, 100);
			buildingIcon.type = buildingType;
			
			var textLayout:VerticalLayout = new VerticalLayout();
			textLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			textLayout.gap = padding;
			
			textsContainer = new LayoutGroup();
			textsContainer.layoutData = new HorizontalLayoutData (100, 100);
			textsContainer.layout = textLayout;
			
			header.addChild(appModel.isLTR ? buildingIcon : textsContainer);
			header.addChild(appModel.isLTR ? textsContainer : buildingIcon);
			
			titleDisplay = new RTLLabel(loc("building_title_"+building.type), 1, null, null, false, null, 1.1, null, "bold");
			
			messageDisplay = new RTLLabel(loc("building_message_"+building.type), 1, "justify", null, true, null, 0.7);
			messageDisplay.layoutData = new VerticalLayoutData(100, 100);
			
			upgradeButton = new ExchangeButton();
			upgradeButton.height = 110*appModel.scale;
			upgradeButton.alpha = 0;
			upgradeButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
			upgradeButton.addEventListener(Event.TRIGGERED, upgradeButton_triggeredHandler);
			addChild(upgradeButton);

			var upgradeLabel:RTLLabel = new RTLLabel(loc("upgrade_title"), 1, "center", null, true, null, 0.7);
			upgradeLabel.layoutData = new AnchorLayoutData(NaN, NaN, padding+upgradeButton.height, NaN, 0);
			addChild(upgradeLabel);
			
			closeButton = new ExchangeButton();
			closeButton.label = "X";
			closeButton.layoutData = new AnchorLayoutData(padding/2, NaN, NaN, padding/2);
			closeButton.width = closeButton.height = 96 * appModel.scale;
			closeButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
			addChild(closeButton);
		}
		
		override protected function transitionInCompleted():void
		{
			super.transitionInCompleted();
			
			textsContainer.addChild(titleDisplay);
			textsContainer.addChild(messageDisplay);
			
			featureList = new List();
			//featureList.layout = listLayout;
			featureList.layoutData = new AnchorLayoutData(header.height + padding*2, padding*2, NaN, padding*2);
			//featureList.height = (listLayout.typicalItemHeight+padding) * 4
			featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
			featureList.itemRendererFactory = function ():IListItemRenderer { return new FeatureItemRenderer(building); }
			featureList.dataProvider = new ListCollection(BuildingFeatureType.getRelatedTo(buildingType)._list);
			addChild(featureList);
			
			upgradeButton.type = ResourceType.CURRENCY_SOFT;
			upgradeButton.count = building.get_upgradeCost();
			Starling.juggler.tween(upgradeButton, 0.1, {alpha:1, delay:0.3});

		}
		
		override protected function transitionOutStarted():void
		{
			removeChild(header);
			removeChild(featureList);
			super.transitionOutStarted();
			Starling.juggler.tween(upgradeButton , 0.05, {alpha:0});
		}
		
		private function closeButton_triggeredHandler():void
		{
			close();
		}
		private function upgradeButton_triggeredHandler():void
		{
			dispatchEventWith(Event.UPDATE, false, building);
		}
		override public function close(dispose:Boolean=true):void
		{
			super.close(dispose);
		}
	}
}