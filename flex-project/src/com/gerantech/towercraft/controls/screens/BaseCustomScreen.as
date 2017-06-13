package com.gerantech.towercraft.controls.screens
{

	import com.gerantech.towercraft.managers.TutorialManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gt.towers.Game;
	import com.gt.towers.Player;
	
	import mx.resources.ResourceManager;
	
	import feathers.controls.Screen;
	
	import starling.events.Event;
	
	public class BaseCustomScreen extends Screen
	{
		public var type:String = "";

		override protected function initialize():void
		{
			super.initialize();
			
			backButtonHandler = backButtonFunction;
		}
		
		protected function backButtonFunction():void
		{
			dispatchEventWith(Event.COMPLETE);
		}
			
		protected function loc(resourceName:String, parameters:Array=null, locale:String=null):String
		{
			return ResourceManager.getInstance().getString("loc", resourceName, parameters, locale);
		}
		protected function get appModel():		AppModel		{	return AppModel.instance;			}
		protected function get tutorials():		TutorialManager	{	return TutorialManager.instance;	}
		protected function get core():			Game			{	return Game.get_instance();			}
		protected function get player():		Player			{	return core.get_player();			}
	
	}
}