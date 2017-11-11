package com.gerantech.towercraft.controls.segments
{
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	import com.gerantech.towercraft.controls.buttons.LobbyTabButton;
	import com.gerantech.towercraft.controls.items.LobbyItemRenderer;
	import com.gerantech.towercraft.controls.popups.LobbyDetailsPopup;
	import com.gerantech.towercraft.controls.texts.CustomTextInput;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.Assets;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	import flash.utils.setTimeout;
	
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.events.Event;

	public class LobbySearchSegment extends Segment
	{
		private var list:FastList;
		private var textInput:CustomTextInput;
		private var _listCollection:ListCollection;
		private var tabs:Vector.<LobbyTabButton>;
		
		private var searchPattern:String;
		private var searchMode:int;
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			
			var padding:int = 24 * appModel.scale;
			var buttonH:int = 96 * appModel.scale;
			
			textInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.SEARCH);
			textInput.promptProperties.fontSize = textInput.textEditorProperties.fontSize = 0.8*appModel.theme.gameFontSize*appModel.scale;
			textInput.maxChars = 16 ;
			textInput.prompt = loc("lobby_name");
			textInput.addEventListener(FeathersEventType.ENTER, searchButton_triggeredHandler);
			textInput.layoutData = new AnchorLayoutData( padding, appModel.isLTR?buttonH*2+padding*3:padding, NaN, appModel.isLTR?padding:buttonH*2+padding*3 );
			textInput.height = buttonH;
			addChild(textInput);
			
			var searchButton:CustomButton = new CustomButton();
			searchButton.width = buttonH;
			searchButton.height = buttonH;
			searchButton.icon = Assets.getTexture("search-icon", "gui");
			searchButton.layoutData = new AnchorLayoutData( padding, appModel.isLTR?padding*2+buttonH:NaN, NaN, appModel.isLTR?NaN:padding*2+buttonH );
			searchButton.addEventListener(Event.TRIGGERED,  searchButton_triggeredHandler);
			addChild(searchButton);	
		
			var rankButton:CustomButton = new CustomButton();
			rankButton.style = "neutral";
			rankButton.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -4*appModel.scale);
			rankButton.icon = Assets.getTexture("rank-icon", "gui");
			rankButton.width = buttonH;
			rankButton.height = buttonH;
			rankButton.layoutData = new AnchorLayoutData( padding, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding );
			rankButton.addEventListener(Event.TRIGGERED,  rankButton_triggeredHandler);
			addChild(rankButton);
			
			tabs = new Vector.<LobbyTabButton>();
			tabs[0] = new LobbyTabButton(loc("lobby_point"));
			tabs[0].addEventListener(Event.TRIGGERED, tabs_triggeredHandler);
			tabs[0].layoutData = new AnchorLayoutData( padding*5.4, appModel.isLTR?padding*2:NaN, NaN, appModel.isLTR?NaN:padding*2 );
			tabs[0].isEnabled = false;
			addChild(tabs[0]);
			
			tabs[1] = new LobbyTabButton(loc("lobby_population"));
			tabs[1].addEventListener(Event.TRIGGERED, tabs_triggeredHandler);
			tabs[1].layoutData = new AnchorLayoutData( padding*5.4, appModel.isLTR?padding*9:NaN, NaN, appModel.isLTR?NaN:padding*9 );
			addChild(tabs[1]);
			
			tabs[2] = new LobbyTabButton(loc("lobby_activeness"));
			tabs[2].addEventListener(Event.TRIGGERED, tabs_triggeredHandler);
			tabs[2].layoutData = new AnchorLayoutData( padding*5.4, appModel.isLTR?padding*17:NaN, NaN, appModel.isLTR?NaN:padding*17 );
			addChild(tabs[2]);
			
			_listCollection = new ListCollection();
			list = new FastList();
			list.itemRendererFactory = function():IListItemRenderer { return new LobbyItemRenderer(); }
			list.layoutData = new AnchorLayoutData(padding*5+buttonH, padding, padding, padding);
			list.dataProvider = _listCollection;
			list.addEventListener(Event.CHANGE, list_changeHandler);
			addChild(list);
			if( SFSConnection.instance.lobbyManager.lobby == null )
				search();
		}
		
		private function tabs_triggeredHandler(event:Event):void
		{
			setTimeout(function(sb:LobbyTabButton):void{
			for each ( var b:LobbyTabButton in tabs )
				b.isEnabled = b != sb;
			}, 10, event.currentTarget);
			searchMode = tabs.indexOf(event.currentTarget as LobbyTabButton);
			search();
		}
		
		protected function rankButton_triggeredHandler(event:Event):void
		{
			searchPattern = "!@#$";
			search();
		}
		protected function searchButton_triggeredHandler(event:Event):void
		{
			if( textInput.text.length < 2 || textInput.text.length > 16 )
			{
				appModel.navigator.addLog( loc("text_size_warn", [loc("lobby_name"), 2, 16] ));
				return;
			}
			searchPattern = textInput.text;
			search();
		}		
		private function search():void
		{
			var params:SFSObject = new SFSObject();
			if( searchPattern != null )
				params.putUtfString("name", searchPattern);
			params.putInt("mode", searchMode);
			SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_roomGetResponseHandler);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_DATA, params);			
		}
		
		protected function sfsConnection_roomGetResponseHandler(event:SFSEvent):void
		{
			if( event.params.cmd != SFSCommands.LOBBY_DATA )
				return;
			SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_roomGetResponseHandler);
			_listCollection.data = SFSArray(event.params.params.getSFSArray("rooms")).toArray();
			for each ( var b:LobbyTabButton in tabs )
				b.visible = true;
		}
		
		private function list_changeHandler(event:Event):void
		{
			if( list.selectedIndex < 0 || list.selectedItem == null )
				return;
			
			var detailsPopup:LobbyDetailsPopup = new LobbyDetailsPopup(list.selectedItem);
			detailsPopup.addEventListener(Event.UPDATE, detailsPopup_updateHandler);
			detailsPopup.addEventListener(Event.CLOSE, detailsPopup_closeHandler);
			appModel.navigator.addPopup(detailsPopup);
			function detailsPopup_closeHandler(e:Event):void 
			{
				detailsPopup.removeEventListener(Event.CLOSE, detailsPopup_closeHandler);
				detailsPopup.removeEventListener(Event.UPDATE, detailsPopup_updateHandler);
				visible = true;
			}
			function detailsPopup_updateHandler(e:Event):void 
			{
				detailsPopup.removeEventListener(Event.CLOSE, detailsPopup_closeHandler);
				detailsPopup.removeEventListener(Event.UPDATE, detailsPopup_updateHandler);
				dispatchEventWith(Event.UPDATE, true, e.data);
			}
			list.selectedIndex = -1;
			if( searchPattern == null )
				return;
			
			/*_listCollection.removeAll();
			for each ( var b:LobbyTabButton in tabs )
				b.visible = false;*/
			visible = false;
		}
	}
}