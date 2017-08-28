package com.gerantech.towercraft.controls.segments
{
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	import com.gerantech.towercraft.controls.items.LobbyItemRenderer;
	import com.gerantech.towercraft.controls.items.RankItemRenderer;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	import com.gerantech.towercraft.controls.popups.BuildingDetailsPopup;
	import com.gerantech.towercraft.controls.popups.LobbyDetailsPopup;
	import com.gerantech.towercraft.controls.texts.CustomTextInput;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.animation.Transitions;
	import starling.events.Event;

	public class LobbySearchSegment extends Segment
	{
		private var list:FastList;
		private var textInput:CustomTextInput;
		private var _listCollection:ListCollection;
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			
			var padding:int = 24 * appModel.scale;
			var buttonW:int = 240 * appModel.scale;
			var buttonH:int = 96 * appModel.scale;
			
			textInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.GO);
			textInput.promptProperties.fontSize = textInput.textEditorProperties.fontSize = 0.8*appModel.theme.gameFontSize*appModel.scale;
			//textInput.maxChars = game.loginData.nameMaxLen ;
			//textInput.prompt = "آنم آرزوست"//loc( "village_name" );
			textInput.addEventListener(Event.CHANGE, textInput_changeHandler);
			textInput.addEventListener(FeathersEventType.ENTER, searchButton_triggeredHandler);
			textInput.layoutData = new AnchorLayoutData( padding, appModel.isLTR?buttonW+padding*2:padding, NaN, appModel.isLTR?padding:buttonW+padding*2 );
			textInput.height = buttonH;
			addChild(textInput);
			
			var searchButton:CustomButton = new CustomButton();
			searchButton.width = buttonW;
			searchButton.height = buttonH;
			searchButton.label = "Search";
			searchButton.layoutData = new AnchorLayoutData( padding, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding );
			searchButton.addEventListener(Event.TRIGGERED,  searchButton_triggeredHandler);
			addChild(searchButton);
			
			_listCollection = new ListCollection();
			list = new FastList();
			list.itemRendererFactory = function():IListItemRenderer { return new LobbyItemRenderer(); }
			list.layoutData = new AnchorLayoutData(padding*2+buttonH, padding, padding, padding);
			list.dataProvider = _listCollection;
			list.addEventListener(Event.CHANGE, list_changeHandler);
			addChild(list);
		}

		
		protected function textInput_changeHandler(event:Event):void
		{
			//acceptButton.visible = textInput.text.length >= game.loginData.nameMinLen
		}
		
		protected function searchButton_triggeredHandler(event:Event):void
		{
			if( textInput.text.length < 4 || textInput.text.length > 16 )
			{
				//errorDisplay.text = loc("text_size_warn", [loc("lobby_name"), 4, 16]);
				return;
			}
			var params:SFSObject = new SFSObject();
			params.putUtfString("name", textInput.text);
			SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_roomGetResponseHandler);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_DATA, params);
		}

		protected function sfsConnection_roomGetResponseHandler(event:SFSEvent):void
		{
			if( event.params.cmd != SFSCommands.LOBBY_DATA )
				return;
			SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_roomGetResponseHandler);
			_listCollection.data = SFSArray(event.params.params.getSFSArray("rooms")).toArray();
		}
		
		private function list_changeHandler(event:Event):void
		{
			if( list.selectedIndex < 0 || list.selectedItem == null )
				return;
			
			var detailsPopup:LobbyDetailsPopup = new LobbyDetailsPopup(list.selectedItem);
			appModel.navigator.addPopup(detailsPopup);
			list.selectedIndex = -1;
		}
	}
}