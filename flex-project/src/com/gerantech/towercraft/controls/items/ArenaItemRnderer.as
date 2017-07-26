package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.buttons.ExchangeButton;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gt.towers.arenas.Arena;
	
	import dragonBones.objects.DragonBonesData;
	import dragonBones.starling.StarlingArmatureDisplay;
	import dragonBones.starling.StarlingFactory;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalAlign;
	import feathers.skins.ImageSkin;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.events.Event;

	public class ArenaItemRnderer extends BaseCustomItemRenderer
	{
		
		[Embed(source = "../../../../../assets/animations/factions/factions_ske.json", mimeType = "application/octet-stream")]
		public static const skeletonClass: Class;
		[Embed(source = "../../../../../assets/animations/factions/factions_tex.json", mimeType = "application/octet-stream")]
		public static const atlasDataClass: Class;
		[Embed(source = "../../../../../assets/animations/factions/factions_tex.png")]
		public static const atlasImageClass: Class;
		
		public static var factory: StarlingFactory;
		public static var dragonBonesData:DragonBonesData;
		
		private var armatureDisplay:StarlingArmatureDisplay;
		private var titleDisplay:RTLLabel;
		private var messageDisplay:RTLLabel;
		private var rangeDisplay:BitmapFontTextRenderer;
		
		private var arena:Arena;
		private var cardsDisplay:List;
		
		public function ArenaItemRnderer()
		{
			super();
			layout = new AnchorLayout();
			height = 640 * appModel.scale;
			var padding:int = 28 * appModel.scale;
			var iconSize:int = 400 * appModel.scale;
			
			skin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
			skin.setTextureForState(STATE_NORMAL, appModel.theme.itemRendererUpSkinTexture);
			skin.setTextureForState(STATE_DOWN, appModel.theme.itemRendererUpSkinTexture);
			skin.setTextureForState(STATE_SELECTED, appModel.theme.itemRendererUpSkinTexture);
			skin.setTextureForState(STATE_DISABLED, Assets.getTexture("item-renderer-neutral-skin", "skin"));
			skin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID;
			backgroundSkin = skin;

			if(factory == null)
			{
				factory = new StarlingFactory();
				dragonBonesData = factory.parseDragonBonesData( JSON.parse(new skeletonClass()) );
				factory.parseTextureAtlasData( JSON.parse(new atlasDataClass()), new atlasImageClass() );
			}
			
			titleDisplay = new RTLLabel("", 1, null, null, false, null, 1.2, null, "bold");
			titleDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
			addChild(titleDisplay);
			
			messageDisplay = new RTLLabel("", 1, "justify", null, true, null, 0.7);
			messageDisplay.layoutData = new AnchorLayoutData(padding*4, appModel.isLTR?iconSize:padding, padding, appModel.isLTR?padding:iconSize);
			//messageDisplay.leading = -22*appModel.scale;
			addChild(messageDisplay);
			
			rangeDisplay = new BitmapFontTextRenderer();
			rangeDisplay.alignPivot();
			rangeDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 48*appModel.scale, 0xFFFFFF, "center");
			rangeDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, (appModel.isLTR?340:-340)*appModel.scale);
			rangeDisplay.x = appModel.isLTR ? (width-200*appModel.scale) : 200*appModel.scale;
			rangeDisplay.y = height*0.6;
			addChild(rangeDisplay);
			
			var cardsLayout:HorizontalLayout = new HorizontalLayout();
			cardsLayout.useVirtualLayout = true;
			cardsLayout.gap = padding;
			cardsLayout.typicalItemWidth = padding*6;
			cardsLayout.typicalItemHeight = padding*7;
			cardsLayout.horizontalAlign = appModel.align;
			cardsLayout.verticalAlign = VerticalAlign.JUSTIFY;
			
			cardsDisplay = new List();
			cardsDisplay.layout = cardsLayout;
			cardsDisplay.height = cardsLayout.typicalItemHeight;
			cardsDisplay.itemRendererFactory = function ():IListItemRenderer { return new BuildingItemRenderer ( false ); };
			cardsDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, padding, appModel.isLTR?padding:NaN);
			addChild(cardsDisplay);
			
			var unlocksDisplay:RTLLabel = new RTLLabel(loc("achievements_label"), 0xCCCCCC, null, null, true, null, 0.8);
			unlocksDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding*2, cardsLayout.typicalItemHeight+padding*2, appModel.isLTR?padding*2:NaN);
			addChild(unlocksDisplay);
			
			var rankButton:ExchangeButton = new ExchangeButton();
			rankButton.label = loc("ranking_label", [""]);
			rankButton.width = 320 * appModel.scale;
			rankButton.height = 110 * appModel.scale;
			rankButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, (appModel.isLTR?340:-340)*appModel.scale);
			rankButton.addEventListener(Event.TRIGGERED, rankButton_triggeredHandler);
			addChild(rankButton);
		}
		
		private function rankButton_triggeredHandler():void
		{
			_owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, arena);
		}
		
		override protected function commitData():void
		{
			super.commitData();
			if( index < 0 )
				return;

			arena = _data as Arena;
			if(armatureDisplay!=null)
				armatureDisplay.removeFromParent();
			armatureDisplay = factory. buildArmatureDisplay("arena-"+arena.index);
			armatureDisplay.x = appModel.isLTR ? (width-200*appModel.scale) : 200*appModel.scale;
			armatureDisplay.y = height *0.35;
			armatureDisplay.scale = appModel.scale;
			currentState = player.get_arena(0) == index ? STATE_DISABLED : STATE_NORMAL;
			if( player.get_arena(0) == index )
				armatureDisplay.animation.gotoAndPlayByTime("animtion0", 0, -1);
			else
				armatureDisplay.animation.gotoAndStopByFrame("animtion0", 0);
			addChild(armatureDisplay);
			
			titleDisplay.text = loc("arena_title_" + index);
			messageDisplay.text = loc("arena_message_" + index);
			rangeDisplay.text = arena.min + " - " + arena.max ;
			cardsDisplay.dataProvider = new ListCollection(arena.cards._list);
			//rangDisplay.x = ( appModel.isLTR ? (width-200*appModel.scale) : 200*appModel.scale ) - rangDisplay.width/2;
		}
	}
}