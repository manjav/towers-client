package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	import com.gerantech.towercraft.controls.items.RankItemRenderer;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	
	import flash.utils.setTimeout;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalLayout;
	
	import starling.core.Starling;
	import starling.events.Event;

	public class RankingPopup extends BasePopup
	{
		public var arenaIndex:int = 0		

		private var titleDisplay:RTLLabel;
		private var closeButton:CustomButton;
		
		private var _listCollection:ListCollection;
		private var padding:int;

		private var list:FastList;

		public function RankingPopup()
		{
			super();
			_listCollection = new ListCollection();
		}
	
		override protected function initialize():void
		{
			closable = false;
			super.initialize();
			overlay.alpha = 0.8;
			layout = new AnchorLayout();
			
			var skin:ImageLoader = new ImageLoader();
			skin.source = appModel.theme.popupBackgroundSkinTexture;
			skin.scale9Grid = BaseMetalWorksMobileTheme.POPUP_SCALE9_GRID;
			skin.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			addChild( skin );
			
			padding = 28 * appModel.scale;
			
			titleDisplay = new RTLLabel(loc("ranking_label", [loc("arena_title_"+arenaIndex)]), 1, "center");
			titleDisplay.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
			titleDisplay.alpha = 0;
			
			closeButton = new CustomButton();
			closeButton.alpha = 0;
			closeButton.height = 110 * appModel.scale;
			closeButton.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0);
			closeButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
			
			SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
		}
		
		private function closeButton_triggeredHandler():void
		{
			close();
		}
		
		override protected function transitionInCompleted():void
		{
			super.transitionInCompleted();
			
			Starling.juggler.tween(titleDisplay, 0.2, {alpha:1});
			addChild(titleDisplay);

			var listLayout:VerticalLayout = new VerticalLayout();
			listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			listLayout.useVirtualLayout = true;
			listLayout.hasVariableItemDimensions = true;
			
			list = new FastList();
			list.itemRendererFactory = function():IListItemRenderer { return new RankItemRenderer(); }
			list.dataProvider = _listCollection;
			list.layout = listLayout;
			list.layoutData = new AnchorLayoutData(padding*5, padding, padding*6, padding);
			addChild(list);
			
			
			var indexOfMe:int = findMe();
			if ( indexOfMe > -1 )
				setTimeout(list.scrollToDisplayIndex, 500, indexOfMe, 0.5);


			list.alpha = 0;
			Starling.juggler.tween(list, 0.3, {delay:0.1, alpha:1});
			
			addChild(closeButton);
			closeButton.y = height - closeButton.height - padding*2;
			closeButton.label = loc("close_button");
			Starling.juggler.tween(closeButton, 0.2, {delay:0.2, alpha:1, y:height - closeButton.height - padding});
		}
	
		
		protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
		{
			if( event.params.cmd != SFSCommands.RANK )
				return;
			
			SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
			_listCollection.data = SFSArray(event.params.params.getSFSArray("list")).toArray();
		}
		
		private function findMe():int
		{
			for (var i:int=0; i<_listCollection.length; i++)
				if( _listCollection.getItemAt(i).i == player.id)
					return i;
			return -1;
		}
		
		override public function dispose():void
		{
			SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
			super.dispose();
		}
	}
}