package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.tooltips.BaseTooltip;
	import com.gerantech.towercraft.controls.tooltips.ConfirmTooltip;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gt.towers.constants.PrefsTypes;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.VerticalAlign;
	
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class TutorialMessageOverlay extends TutorialOverlay
	{
		private var side:int;
		
		public function TutorialMessageOverlay(task:TutorialTask):void
		{
			super(task);
			side = int(task.data) % 2;
		}

		override protected function transitionInCompleted():void
		{
			super.transitionInCompleted();
			appModel.sounds.addAndPlaySound("whoosh");
			overlay.touchable = task.type == TutorialTask.TYPE_CONFIRM;
			
			var charachter:ImageLoader = new ImageLoader();
			charachter.source =  Assets.getTexture("chars/char-" + side, "gui");
			charachter.verticalAlign = VerticalAlign.BOTTOM;
			charachter.layoutData = new AnchorLayoutData(NaN, side==0?NaN:0, 0, side==0?0:NaN);
			charachter.height = stage.stageHeight * (side==0?0.45:0.5);
			charachter.touchable = false;
			addChild(charachter);
			
			var msg:String = loc(task.message);
			if( msg == null )
				msg = task.message;
			
			var tootlip:BaseTooltip;
			var position:Rectangle = new Rectangle(width * (side==0?0.35:0.65), height * (side==0?0.55:0.55), 1, 1)
			if( task.type == TutorialTask.TYPE_CONFIRM )
				tootlip = new ConfirmTooltip(msg, position, 1, 0.6);
			else
				tootlip = new BaseTooltip(msg, position, 1, 0.6);
			tootlip.addEventListener(Event.SELECT, tootlip_eventsHandler); 
			tootlip.addEventListener(Event.CANCEL, tootlip_eventsHandler); 
			addChild( tootlip );
		}
		private function tootlip_eventsHandler(event:Event):void
		{
			dispatchEventWith(event.type);
			BaseTooltip(event.currentTarget).close();
			close();
		}
		override protected function stage_touchHandler(event:TouchEvent):void
		{
			if( !_isEnabled || task.type == TutorialTask.TYPE_CONFIRM )
				return;
			super.stage_touchHandler(event);
		}
	}
}