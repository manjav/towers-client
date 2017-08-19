package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	import com.gerantech.towercraft.controls.headers.ScreenHeader;
	import com.gerantech.towercraft.controls.items.ArenaItemRnderer;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	import com.gerantech.towercraft.controls.popups.RankingPopup;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gt.towers.arenas.Arena;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.ScrollBarDisplayMode;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalLayout;
	
	import starling.animation.Transitions;
	import starling.display.Image;
	import starling.events.Event;

	public class ArenaScreen extends BaseCustomScreen
	{
		private var list:List;
		private var header:ScreenHeader;

		private var headerSize:int = 0;
		private var startScrollBarIndicator:Number = 0;
		private var initialized:Boolean;

		public function ArenaScreen()
		{
			super();
			 appModel.assets.verbose = true;
			if( appModel.assets.getTexture("factions_ske") == null )
			{
				appModel.assets.enqueue(File.applicationDirectory.resolvePath( "assets/animations/factions" ));
				appModel.assets.loadQueue(assets_loadCallback)
			}
		}
		
		private function assets_loadCallback(ratio:Number):void
		{
			if( ratio >= 1 && initialized )
				initialize();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			initialized = true;
			if( appModel.assets.isLoading )
				return;
			
			layout = new AnchorLayout();
			headerSize = 150 * appModel.scale;
			
			var listLayout:VerticalLayout = new VerticalLayout();
			listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			listLayout.padding = 8 * appModel.scale;
			listLayout.paddingTop = headerSize + listLayout.padding;
			listLayout.useVirtualLayout = true;
			
			list = new List();
			list.layout = listLayout;
			list.layoutData = new AnchorLayoutData(0,0,headerSize,0);
			list.itemRendererFactory = function():IListItemRenderer { return new ArenaItemRnderer(); }
			list.dataProvider = new ListCollection(game.arenas.values());
			list.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
			list.addEventListener(FeathersEventType.FOCUS_IN, list_focusInHandler);
			list.scrollToDisplayIndex(player.get_arena(0));
			setTimeout(list.addEventListener, 100, Event.SCROLL, list_scrollHandler);
			addChild(list);
			
			header = new ScreenHeader(loc("map-portal-tower"));
			header.height = headerSize;
			header.layoutData = new AnchorLayoutData(NaN,0,NaN,0);
			addChild(header);
			
			var footer:LayoutGroup = new LayoutGroup();
			footer.backgroundSkin = new Image(appModel.theme.tabUpSkinTexture);
			Image(footer.backgroundSkin).scale9Grid = BaseMetalWorksMobileTheme.TAB_SCALE9_GRID;
			footer.height = headerSize;
			footer.layoutData = new AnchorLayoutData(NaN,0,0,0);
			addChild(footer);
			
			var closeButton:CustomButton = new CustomButton();
			closeButton.height = 110 * appModel.scale;
			closeButton.layoutData = new AnchorLayoutData(NaN, NaN, 18*appModel.scale, NaN, 0);
			closeButton.addEventListener(Event.TRIGGERED, backButtonHandler);
			closeButton.label = loc("close_button");
			addChild(closeButton);
		}
		
		private function list_scrollHandler(event:Event):void
		{
			var scrollPos:Number = Math.max(0,list.verticalScrollPosition);
			var changes:Number = startScrollBarIndicator-scrollPos;
			header.y = Math.max(-headerSize, Math.min(0, header.y+changes));
			startScrollBarIndicator = scrollPos;
		}
		
		private function list_focusInHandler(event:Event):void
		{
			var arenaIndex:int = Arena(event.data).index;
			var extraInfo:SFSObject = new SFSObject();
			extraInfo.putInt("arena", arenaIndex );
			SFSConnection.instance.sendExtensionRequest( SFSCommands.RANK, extraInfo );
			
			var padding:int = 36*appModel.scale;
			var transitionIn:TransitionData = new TransitionData();
			transitionIn.sourceAlpha = 0;
			var transitionOut:TransitionData = new TransitionData();
			transitionOut.destinationAlpha = 0;
			transitionOut.transition = Transitions.EASE_IN;
			transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(padding,		padding,	stage.stageWidth-padding*2,	stage.stageHeight-padding*2);
			transitionIn.destinationBound = transitionOut.sourceBound = new Rectangle(padding*2,	padding*2,	stage.stageWidth-padding*4,	stage.stageHeight-padding*4);

			//appModel.navigator.pushScreen( Main.RANK_SCREEN );
			var rankingPopup:RankingPopup = new RankingPopup();
			rankingPopup.arenaIndex = arenaIndex;
			rankingPopup.transitionIn = transitionIn;
			rankingPopup.transitionOut = transitionOut;
			appModel.navigator.addPopup(rankingPopup);
		}		

	}
}