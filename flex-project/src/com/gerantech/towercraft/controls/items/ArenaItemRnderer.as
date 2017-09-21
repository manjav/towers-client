package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gt.towers.arenas.Arena;
	
	import dragonBones.objects.DragonBonesData;
	import dragonBones.starling.StarlingArmatureDisplay;
	import dragonBones.starling.StarlingFactory;
	
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
		private var playerArena:int;
		private var cardsDisplay:List;
		private var mySkin:ImageSkin;
		
		public function ArenaItemRnderer()
		{
			super();
			isEnabled = false;
			layout = new AnchorLayout();
			height = 640 * appModel.scale;
			var padding:int = 28 * appModel.scale;
			var iconSize:int = 400 * appModel.scale;
			playerArena = player.get_arena(0);
			
			mySkin = new ImageSkin(appModel.theme.itemRendererDisabledSkinTexture);
			mySkin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID;
			backgroundSkin = mySkin;

			createFactory();
			
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
			
			var unlocksDisplay:RTLLabel = new RTLLabel(loc("arena_chance_to"), 0xCCCCCC, null, null, true, null, 0.8);
			unlocksDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding*2, cardsLayout.typicalItemHeight+padding*2, appModel.isLTR?padding*2:NaN);
			addChild(unlocksDisplay);
			
			var rankButton:CustomButton = new CustomButton();
			rankButton.label = loc("ranking_label", [""]);
			rankButton.width = 320 * appModel.scale;
			rankButton.height = 110 * appModel.scale;
			rankButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, (appModel.isLTR?340:-340)*appModel.scale);
			rankButton.addEventListener(Event.TRIGGERED, rankButton_triggeredHandler);
			addChild(rankButton);

			armatureDisplay = factory.buildArmatureDisplay("all");
			armatureDisplay.x = appModel.isLTR ? (width-200*appModel.scale) : 200*appModel.scale;
			armatureDisplay.y = height *0.35;
			armatureDisplay.scale = appModel.scale;
			addChild(armatureDisplay);
		}
		
		public static function createFactory():void
		{
			if( factory != null )
				return;
			factory = new StarlingFactory();
			dragonBonesData = factory.parseDragonBonesData( JSON.parse(new skeletonClass()) );
			factory.parseTextureAtlasData( JSON.parse(new atlasDataClass()), new atlasImageClass() );
	
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
			titleDisplay.text = loc("arena_title_" + index);
			messageDisplay.text = loc("arena_message_" + index);
			rangeDisplay.text = arena.min + " - " + arena.max ;
			cardsDisplay.dataProvider = new ListCollection(arena.cards._list);
			mySkin.defaultTexture = playerArena == index ? appModel.theme.itemRendererUpSkinTexture : appModel.theme.itemRendererDisabledSkinTexture;

			if( playerArena == index )
				armatureDisplay.animation.gotoAndPlayByTime("arena-"+index+"-selected", 0, 20);
			else
				armatureDisplay.animation.gotoAndStopByTime("arena-"+index+"-normal", 0);
		}
		
		override public function dispose():void
		{
			armatureDisplay.animation.stop();
			armatureDisplay.removeFromParent(false)
			super.dispose();
		}
	}
}