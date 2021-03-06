package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.constants.BuildingType;
	import com.gt.towers.constants.ResourceType;
	
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.display.Image;
	
	public class ChestReward extends TowersLayout
	{
		public var index:int;
		public var state:int = -1;

		private var type:int;
		private var count:int;
		private var detailsContainer:LayoutGroup;
		private var countInsideDisplay:BitmapFontTextRenderer;
		
		public function ChestReward(index:int, type:int, count:int)
		{
			super();
			this.index = index;
			this.type = type;
			this.count = count;
			touchable = touchGroup = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
	
			var padding:int = 16 *appModel.scale;
			width = 800 * appModel.scale;
			height = 440 * appModel.scale;
			
			var iconContainer:LayoutGroup = new LayoutGroup ();
			iconContainer.x = appModel.isLTR ? -width*0.4-padding : padding;
			iconContainer.y = -height * 0.5;
			iconContainer.width = width * 0.4;
			iconContainer.height = height;
			iconContainer.layout = new AnchorLayout();
			iconContainer.backgroundSkin = new Image(Assets.getTexture("theme/building-button", "gui"));
			Image(iconContainer.backgroundSkin).scale9Grid = new Rectangle(10, 10, 56, 37);
			
			var ic:int = ResourceType.isBuilding(type) ? BuildingType.get_category(type) : type;
			var iconDisplay:ImageLoader = new ImageLoader();
			iconDisplay.pixelSnapping = false;
			iconDisplay.maintainAspectRatio = false;
			iconDisplay.source = Assets.getTexture("cards/"+ic, "gui");
			iconDisplay.layoutData = new AnchorLayoutData(padding, padding, padding*1.8, padding);
			iconContainer.addChild(iconDisplay);
			
			if( ResourceType.isBuilding(type) )
			{
				var improveDisplay:ImageLoader = new ImageLoader();
				improveDisplay.source = Assets.getTexture("cards/" + type, "gui");
				improveDisplay.width = padding * 5;
				improveDisplay.layoutData = new AnchorLayoutData(padding, padding, padding*1.8, padding);
				iconContainer.addChild(improveDisplay);
				
				if( player.buildings.get(type).get_level() == -1 )
				{
					var newDisplay:ImageLoader = new ImageLoader();
					newDisplay.source = Assets.getTexture("cards/new-badge", "gui");
					newDisplay.layoutData = new AnchorLayoutData(-10*appModel.scale, NaN, NaN, -10*appModel.scale);
					newDisplay.width = 200 * appModel.scale;
					newDisplay.height = 200 * appModel.scale;
					iconContainer.addChild(newDisplay);
					appModel.game.loginData.buildingsLevel.set(type, 1);
					
					setTimeout(appModel.sounds.addAndPlaySound, 100, "chest-open-new")
				}
			}
			
			countInsideDisplay = new BitmapFontTextRenderer();
			countInsideDisplay.visible = false;
			countInsideDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 96*appModel.scale, 0xFFFFFF, appModel.align);
			countInsideDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding*2, padding, appModel.isLTR?padding*2:NaN);
			countInsideDisplay.text = "x " + count; 
			iconContainer.addChild(countInsideDisplay);

			detailsContainer = new LayoutGroup ();
			detailsContainer.visible = false;
			detailsContainer.x = appModel.isLTR ? padding : -width*0.6-padding;
			detailsContainer.y = -height * 0.5;
			detailsContainer.width = width * 0.6;
			detailsContainer.height = height;
			detailsContainer.layout = new VerticalLayout();
			VerticalLayout(detailsContainer.layout).horizontalAlign = HorizontalAlign.JUSTIFY;
			
			addChild(appModel.isLTR ? iconContainer : detailsContainer);
			addChild(appModel.isLTR ? detailsContainer : iconContainer);
			
			var titleDisplay:RTLLabel = new RTLLabel(loc("building_title_"+type), 1, null, null, false, null, 1.1, null, "bold");
			detailsContainer.addChild(titleDisplay);
			
			var countDisplay:BitmapFontTextRenderer = new BitmapFontTextRenderer();
			countDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 96*appModel.scale, 16777215, appModel.align);
			countDisplay.layoutData = new VerticalLayoutData(100);
			countDisplay.text = "x " + count; 
			detailsContainer.addChild(countDisplay);
			state = 0;
		}
		
		public function showDetails():void
		{
			state = 1;
			detailsContainer.visible = true;
		}		
		public function hideDetails():void
		{
			state = 2;
			detailsContainer.visible = false;
			countInsideDisplay.visible = true;
		}		
		
	}
}