package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.Main;
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.tutorials.TutorialData;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gt.towers.battle.fieldes.PlaceData;
	import com.gt.towers.utils.lists.PlaceDataList;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.controls.StackScreenNavigator;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	
	import starling.events.Event;
	
	public class MainScreen extends BaseCustomScreen
	{
		private var topList:FastList;

		private var questButton:Button;
		public function MainScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			
			var battons:LayoutGroup = new LayoutGroup();
			battons.layoutData = new AnchorLayoutData(0,0,0,0);
			addChild(battons);
			
			var vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = HorizontalAlign.CENTER;
			vlayout.verticalAlign = VerticalAlign.MIDDLE;
			vlayout.gap = 20;
			battons.layout = vlayout;
			
			questButton = new Button();
			questButton.label = loc("mainpage_quest_button");
			questButton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
			battons.addChild(questButton);	
			
			var battleButton:Button = new Button();
			battleButton.label = loc("mainpage_fire_button");
			battleButton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
			battons.addChild(battleButton);
			
			addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
		}
		
		private function transitionInCompleteHandler():void
		{
			removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
			showTutorial();
		}		
		
		// show tutorial steps
		private function showTutorial():void
		{

			if(LoadingManager.instance.state < LoadingManager.STATE_LOADED )
			{
				appModel.navigator.addEventListener(Event.COMPLETE, navigator_complateHandler);
				return;
			}
			if( player.get_questIndex() > 1 )
				return;	
			
			var tutorialData:TutorialData = new TutorialData("");
			tutorialData.tasks.push(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_quest_" + player.get_questIndex() + "_start"));
			var pl:PlaceDataList = new PlaceDataList();
			pl.push(new PlaceData(0,(questButton.x+questButton.width/2)/appModel.scale, (questButton.y+questButton.height/2)/appModel.scale, 0, 0, 0, ""));
			tutorialData.tasks.push(new TutorialTask(TutorialTask.TYPE_TOUCH, null, pl));
			tutorials.show(this, tutorialData);
		}
		private function navigator_complateHandler():void
		{
			appModel.navigator.removeEventListener(Event.COMPLETE, navigator_complateHandler);
			showTutorial();
		}
		
		private function buttons_triggeredHandler(event:Event):void
		{
			var sfsObj:SFSObject = new SFSObject();
			sfsObj.putBool("quest", event.currentTarget == questButton);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.START_BATTLE, sfsObj);

			StackScreenNavigator(owner).pushScreen(Main.BATTLE_SCREEN);		
		}		
		
	}
}