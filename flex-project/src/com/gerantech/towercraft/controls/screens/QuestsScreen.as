package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.Main;
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.controls.items.QuestItemRenderer;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.vo.Quest;
	import com.gt.towers.Game;
	import com.gt.towers.battle.fieldes.FieldData;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.events.Event;

	public class QuestsScreen extends BaseCustomScreen
	{
		private var list:FastList;

		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			
			list = new FastList();
			list.itemRendererFactory = function():IListItemRenderer
			{
				return new QuestItemRenderer();
			}
			list.dataProvider = getQuestsData();
			list.layoutData = new AnchorLayoutData(30,0,0,0);
			list.addEventListener(Event.CHANGE, list_changeHandler);
			addChild(list);
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
			
			var fkeys:Vector.<String> = Game.fieldProvider.fields.keys();
			for( var i:int=0; i<fkeys.length; i++)
			{
				field = Game.fieldProvider.fields.get(fkeys[i]);
				if(field.isQuest)
				{
					source.push( new Quest(field, field.index>player.get_questIndex() ? -1 : player.get_quests().get(field.index) ) );
				}
			}
			source.sortOn("index");
			return new ListCollection(source);
		}
	}
}