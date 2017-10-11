package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.BuildingCard;
	import com.gerantech.towercraft.controls.buttons.ExchangeButton;
	import com.gerantech.towercraft.controls.items.BuildingFeatureItemRenderer;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gt.towers.buildings.Building;
	import com.gt.towers.constants.BuildingFeatureType;
	import com.gt.towers.constants.ResourceType;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.ScrollPolicy;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalLayout;
	
	import starling.core.Starling;
	import starling.events.Event;

	public class BuildingDetailsPopup extends SimplePopup
	{
		public var buildingType:int;
		
		private var building:Building;

		override protected function initialize():void
		{
			super.initialize();
			
			building = player.buildings.get(buildingType);
			
			var buildingIcon:BuildingCard = new BuildingCard();
			buildingIcon.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
			buildingIcon.width = padding * 9;
			buildingIcon.height = padding * 13;
			buildingIcon.type = buildingType;
			buildingIcon.level = building.get_level();
			addChild(buildingIcon);
		}
		
		override protected function transitionInCompleted():void
		{
			super.transitionInCompleted();
			
			var textLayout:VerticalLayout = new VerticalLayout();
			textLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			textLayout.gap = padding;
				
			var titleDisplay:RTLLabel = new RTLLabel(loc("building_title_"+building.type), 1, null, null, false, null, 1.1, null, "bold");
			titleDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?padding:padding*11, NaN, appModel.isLTR?padding*11:padding);
			addChild(titleDisplay);
			
			var messageDisplay:RTLLabel = new RTLLabel(loc("building_message_"+building.type), 1, "justify", null, true, null, 0.7);
			messageDisplay.layoutData = new AnchorLayoutData(padding*4, appModel.isLTR?padding:padding*11, NaN, appModel.isLTR?padding*11:padding);
			addChild(messageDisplay);
			
			var featureList:List = new List();
			featureList.layoutData = new AnchorLayoutData(padding*15, padding*2, NaN, padding*2);
			featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
			featureList.itemRendererFactory = function ():IListItemRenderer { return new BuildingFeatureItemRenderer(building); }
			featureList.dataProvider = new ListCollection(BuildingFeatureType.getRelatedTo(buildingType)._list);
			addChild(featureList);
			
			var upgradeButton:ExchangeButton = new ExchangeButton();
			upgradeButton.count = building.get_upgradeCost();
			upgradeButton.type = ResourceType.CURRENCY_SOFT;
			upgradeButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
			upgradeButton.height = 110*appModel.scale;
			upgradeButton.addEventListener(Event.TRIGGERED, upgradeButton_triggeredHandler);
			addChild(upgradeButton);
			
			/*upgradeButton.alpha = 0;
			Starling.juggler.tween(upgradeButton, 0.1, {alpha:1, delay:0.3});*/
			
			var upgradeLabel:RTLLabel = new RTLLabel(loc("upgrade_title"), 1, "center", null, true, null, 0.7);
			upgradeLabel.layoutData = new AnchorLayoutData(NaN, NaN, padding+upgradeButton.height, NaN, 0);
			upgradeLabel.alpha = 0;
			Starling.juggler.tween(upgradeLabel, 0.1, {alpha:1, delay:0.3});
			addChild(upgradeLabel);
			
			/*var closeButton:CustomButton = new CustomButton();
			closeButton.style = "danger";
			closeButton.label = "X";
			closeButton.layoutData = new AnchorLayoutData(padding/2, NaN, NaN, padding/2);
			closeButton.width = closeButton.height = 96 * appModel.scale;
			closeButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
			addChild(closeButton);	*/	
		}
		
		override protected function transitionOutStarted():void
		{
			removeChildren(2);
			super.transitionOutStarted();
		}
		
		/*private function closeButton_triggeredHandler():void
		{
			close();
		}*/
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