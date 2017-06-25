package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.BuildingIcon;
	import com.gerantech.towercraft.controls.RTLLabel;
	import com.gerantech.towercraft.controls.items.FeatureItemRenderer;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gt.towers.buildings.Building;
	import com.gt.towers.constants.BuildingFeatureType;
	
	import feathers.controls.Button;
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
	import feathers.layout.RelativePosition;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;
	import feathers.skins.ImageSkin;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;

	public class BuildingDetailsPopup extends BasePopup
	{
		public var buildingType:int;
		
		private var building:Building;
		private var upgradeButton:Button;
		private var optionList:List;
		private var header:LayoutGroup;
		private var padding:int;

		override protected function initialize():void
		{
			closable = false;
			super.initialize();
			layout = new AnchorLayout();
			
			building = player.get_buildings().get(buildingType);
			
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
			header.layoutData = new AnchorLayoutData(padding,padding,NaN,padding);
			header.height = transitionIn.destinationBound.height*0.3;
			addChild(header);
			
			var buildingIcon:BuildingIcon = new BuildingIcon();
			buildingIcon.layoutData = new HorizontalLayoutData(40, 100);
			buildingIcon.setImage(Assets.getTexture("improve-"+building.type, "gui"));
			buildingIcon.setData(0, player.get_resources().get(building.type), building.get_upgradeCards());
			
			var textLayout:VerticalLayout = new VerticalLayout();
			textLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			textLayout.gap = padding;
			
			var textsContainer:LayoutGroup = new LayoutGroup();
			textsContainer.layoutData = new HorizontalLayoutData (100, 100);
			textsContainer.layout = textLayout;
			
			header.addChild(appModel.isLTR ? buildingIcon : textsContainer);
			header.addChild(appModel.isLTR ? textsContainer : buildingIcon);
			
			var titleDisplay:RTLLabel = new RTLLabel(loc("building_title_"+building.type), 1, null, null, false, null, 1.1, null, "bold");
			textsContainer.addChild(titleDisplay);
			
			var messageDisplay:RTLLabel = new RTLLabel(loc("building_message_"+building.type), 1, "justify", null, true, null, 0.7);
			messageDisplay.layoutData = new VerticalLayoutData(100, 100);
			textsContainer.addChild(messageDisplay);
		
		}
		
		override protected function transitionInCompleted():void
		{
			super.transitionInCompleted();
			
			var listLayout:TiledRowsLayout = new TiledRowsLayout();
			listLayout.gap = padding;
			listLayout.horizontalAlign = HorizontalAlign.RIGHT;
			listLayout.useSquareTiles = false;
			listLayout.requestedColumnCount = 2;
			listLayout.typicalItemWidth = (transitionIn.destinationBound.width-padding*3) / 2;
			listLayout.typicalItemHeight = 72 * appModel.scale;
			
			optionList = new List();
			optionList.layout = listLayout;
			optionList.layoutData = new AnchorLayoutData(header.height + padding*2, padding, NaN, padding);
			optionList.height = (listLayout.typicalItemHeight+padding) * 4
			optionList.horizontalScrollPolicy = optionList.verticalScrollPolicy = ScrollPolicy.OFF;
			optionList.itemRendererFactory = function ():IListItemRenderer
			{
				return new FeatureItemRenderer(building);
			}
			optionList.dataProvider = new ListCollection(BuildingFeatureType.getAll().keys());
			addChild(optionList);
			
			upgradeButton = new Button();
			upgradeButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
			upgradeButton.label = building.get_upgradeCost().toString();
			upgradeButton.iconPosition = RelativePosition.RIGHT;
			upgradeButton.iconOffsetX = 24*appModel.scale;
			Starling.juggler.tween(upgradeButton, 0.1, {alpha:1, delay:0.2});
			upgradeButton.alpha = 0;
			upgradeButton.addEventListener(Event.TRIGGERED, upgradeButton_triggeredHandler);
			addChild(upgradeButton);
			
			var upgradeIcon:Image = new Image(Assets.getTexture("res-1002", "gui"));
			upgradeIcon.width = upgradeIcon.height = appModel.theme.controlSize;
			upgradeButton.defaultIcon = upgradeIcon;
			
			var closeButton:Button = new Button();
			closeButton.label = "X";
			closeButton.layoutData = new AnchorLayoutData(padding/2, NaN, NaN, padding/2);
			closeButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
			addChild(closeButton);
		}
		
		
		override protected function transitionOutStarted():void
		{
			removeChild(header);
			removeChild(optionList);
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
			close();
		}
		
		override public function close(dispose:Boolean=true):void
		{
			super.close(dispose);
		}
		
		
	
	}
}