package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.Main;
	import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
	import com.gerantech.towercraft.controls.items.ArenaItemRnderer;
	import com.gerantech.towercraft.controls.items.QuestItemRenderer;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	import com.gerantech.towercraft.controls.popups.RankingPopup;
	import com.gerantech.towercraft.controls.popups.RequirementConfirmPopup;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.Assets;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.List;
	import feathers.controls.ScrollBarDisplayMode;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.animation.Transitions;
	import starling.display.Image;
	import starling.events.Event;

	public class ArenaScreen extends BaseCustomScreen
	{
		private var list:List;
		public function ArenaScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			
			list = new List()
			list.layoutData = new AnchorLayoutData(0,0,0,0);
			list.itemRendererFactory = function():IListItemRenderer { return new ArenaItemRnderer(); }
			list.dataProvider = new ListCollection(game.arenas.values());
			list.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
			list.addEventListener(Event.CHANGE, list_changeHandler);
			list.scrollToDisplayIndex(player.get_arena(0));
			addChild(list);
			
			var backButton:SimpleLayoutButton = new SimpleLayoutButton();
			backButton.width = backButton.height = 240 * appModel.scale;
			backButton.layoutData = new AnchorLayoutData(NaN, 0, 0, NaN);
			backButton.backgroundSkin = new Image(Assets.getTexture("tab-1", "gui"));
			backButton.addEventListener(Event.TRIGGERED, backButtonHandler);
			addChild(backButton);
		}
		
		private function list_changeHandler():void
		{
			var extraInfo:SFSObject = new SFSObject();
			extraInfo.putInt("arena", list.selectedIndex);
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
			rankingPopup.arenaIndex = list.selectedIndex;
			rankingPopup.transitionIn = transitionIn;
			rankingPopup.transitionOut = transitionOut;
			appModel.navigator.addChild(rankingPopup);
			
			list.removeEventListener(Event.CHANGE, list_changeHandler);
			list.selectedIndex = -1;
			list.addEventListener(Event.CHANGE, list_changeHandler);
		}		

	}
}