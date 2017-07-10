package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.controls.overlays.BattleOutcomeOverlay;
	import com.gerantech.towercraft.models.Assets;
	
	import dragonBones.objects.DragonBonesData;
	import dragonBones.starling.StarlingArmatureDisplay;
	import dragonBones.starling.StarlingFactory;
	
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.events.Event;
	import starling.utils.Padding;

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
		private var rangDisplay:BitmapFontTextRenderer;
		
		public function ArenaItemRnderer()
		{
			super();
			layout = new AnchorLayout();
			height = 540 * appModel.scale;
			var padding:int = 28 * appModel.scale;
			var iconSize:int = 400 * appModel.scale;

			if(factory == null)
			{
				factory = new StarlingFactory();
				dragonBonesData = factory.parseDragonBonesData( JSON.parse(new skeletonClass()) );
				factory.parseTextureAtlasData( JSON.parse(new atlasDataClass()), new atlasImageClass() );
			}
			
			titleDisplay = new RTLLabel("", 1, null, null, false, null, 64*appModel.scale, null, "bold");
			titleDisplay.layoutData = new AnchorLayoutData(0, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
			addChild(titleDisplay);
			
			messageDisplay = new RTLLabel("", 1, "justify", null, true);
			messageDisplay.layoutData = new AnchorLayoutData(padding*4, appModel.isLTR?iconSize:padding, padding, appModel.isLTR?padding:iconSize);
			messageDisplay.leading = -22*appModel.scale;
			addChild(messageDisplay);
			
			rangDisplay = new BitmapFontTextRenderer();
			//rangDisplay.pivotX = rangDisplay.width/2
			rangDisplay.alignPivot();
			rangDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 32*appModel.scale, 0xFFFFFF, "center");
			rangDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, (appModel.isLTR?340:-340)*appModel.scale);
			rangDisplay.x = appModel.isLTR ? (width-200*appModel.scale) : 200*appModel.scale;
			rangDisplay.y = height*0.7;
			addChild(rangDisplay);
		}
		
		override protected function commitData():void
		{
			super.commitData();
			if( index < 0 )
				return;

			if(armatureDisplay!=null)
				armatureDisplay.removeFromParent();
			armatureDisplay = factory. buildArmatureDisplay("arena-"+index);
			armatureDisplay.x = appModel.isLTR ? (width-200*appModel.scale) : 200*appModel.scale;
			armatureDisplay.y = height *0.35;
			armatureDisplay.scale = appModel.scale;
			if( player.get_arena() == index )
				armatureDisplay.animation.gotoAndPlayByTime("animtion0", 0, -1);
			else
				armatureDisplay.animation.gotoAndStopByFrame("animtion0", 0);
			addChild(armatureDisplay);
			
			titleDisplay.text = loc("arena_title_" + index);
			messageDisplay.text = loc("arena_message_" + index);
			rangDisplay.text = game.arenas.get(index) + ( game.arenas.keys().length==index+1 ? "" : "-" + game.arenas.get(index+1) );
			//rangDisplay.x = ( appModel.isLTR ? (width-200*appModel.scale) : 200*appModel.scale ) - rangDisplay.width/2;
		}
	}
}