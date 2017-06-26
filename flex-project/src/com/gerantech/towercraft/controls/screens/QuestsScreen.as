package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.Main;
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
	import com.gerantech.towercraft.controls.items.QuestItemRenderer;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.vo.Quest;
	import com.gt.towers.Game;
	import com.gt.towers.battle.fieldes.FieldData;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Image;
	import starling.events.Event;

	public class QuestsScreen extends BaseCustomScreen
	{
		private var list:FastList;

		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			
			var listLayout:VerticalLayout = new VerticalLayout();
			listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			listLayout.useVirtualLayout = true;
			listLayout.padding = 12 * appModel.scale;	
			listLayout.gap = 6 * appModel.scale;	
			
			list = new FastList();
			list.layout = listLayout;
			list.layoutData = new AnchorLayoutData(0,0,0,0);
			list.itemRendererFactory = function():IListItemRenderer
			{
				return new QuestItemRenderer();
			}
			list.dataProvider = getQuestsData();
			list.addEventListener(Event.CHANGE, list_changeHandler);
			addChild(list);
			
			var backButton:SimpleLayoutButton = new SimpleLayoutButton();
			backButton.width = backButton.height = 240*appModel.scale;
			backButton.layoutData = new AnchorLayoutData(NaN,NaN,0, 0);
			backButton.backgroundSkin = new Image(Assets.getTexture("tab-1", "gui"));
			backButton.addEventListener(Event.TRIGGERED, backButtonHandler);
			addChild(backButton);
		}
		
		private function list_changeHandler(event:Event):void
		{
			var quest:Quest = list.selectedItem as Quest;

			var sfsObj:SFSObject = new SFSObject();
			sfsObj.putBool("q", true);
			sfsObj.putInt("i", quest.index);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.START_BATTLE, sfsObj);
			appModel.navigator.pushScreen( Main.BATTLE_SCREEN );
		}
		
		private function getQuestsData():ListCollection
		{
			var field:FieldData;
			var source:Array = new Array();
			
			var fkeys:Vector.<String> = game.fieldProvider.fields.keys();
			for( var i:int=0; i<fkeys.length; i++)
			{
				field = game.fieldProvider.fields.get(fkeys[i]);
				if(field.isQuest)
				{
					source.push( new Quest(field, field.index>player.get_questIndex() ? -1 : player.quests.get(field.index) ) );
				}
			}
			source.sortOn("index");
			return new ListCollection(source);
		}
	}
}