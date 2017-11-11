package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.tooltips.BaseTooltip;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gt.towers.constants.PrefsTypes;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.VerticalAlign;
	
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
			
			var charName:int = side==0 ? (player.prefs.getAsInt(PrefsTypes.TUTE_STEP_101)==PrefsTypes.TUTE_114_SELECT_BUILDING?2:0) : 1
			var charachter:ImageLoader = new ImageLoader();
			charachter.source =  Assets.getTexture("chars/char-" + charName, "gui");
			charachter.verticalAlign = VerticalAlign.BOTTOM;
			charachter.layoutData = new AnchorLayoutData(NaN, side==0?NaN:0, 0, side==0?0:NaN);
			charachter.width = stage.stageWidth * (side==0?0.6:0.7);
			charachter.touchable = false;
			addChild(charachter);
			
			addChild( new BaseTooltip(loc(task.message), new Rectangle(width * (side==0?0.35:0.65), height * (side==0?0.6:0.51), 1, 1), 1, 0.6) );
		}
	}
}