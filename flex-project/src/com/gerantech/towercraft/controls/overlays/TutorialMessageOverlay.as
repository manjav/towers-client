package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.controls.tooltips.BaseTooltip;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gt.towers.constants.PrefsTypes;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import feathers.controls.AutoSizeMode;
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.VerticalAlign;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Image;
	
	public class TutorialMessageOverlay extends TutorialOverlay
	{

		private var side:int;
		
		public function TutorialMessageOverlay(task:TutorialTask):void
		{
			super(task);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();

			side = int(task.data) % 2;
			var charName:int = side==0 ? (player.prefs.getAsInt(PrefsTypes.TUTE_STEP_101)==PrefsTypes.TUTE_114_SELECT_BUILDING?2:0) : 1
			var charachter:ImageLoader = new ImageLoader();
			charachter.source =  Assets.getTexture("chars/char-" + charName, "gui");
			charachter.verticalAlign = VerticalAlign.BOTTOM;
			charachter.layoutData = new AnchorLayoutData(NaN, side==0?NaN:0, 0, side==0?0:NaN);
			charachter.width = stage.stageWidth * (side==0?0.6:0.7);
			//charachter.height = stage.height / 2;
			charachter.touchable = false;
			addChild(charachter);
			
			/*var balloonSkin:Image = new Image(Assets.getTexture("tooltip-bg-bot-" + (side==0?"left":"right"), "gui"));
			balloonSkin.scale9Grid = new Rectangle(side==0?19:8, 7, 1, 1);
			
			var balloonDisplay:LayoutGroup = new LayoutGroup();
			balloonDisplay.autoSizeMode = AutoSizeMode.CONTENT;
			balloonDisplay.backgroundSkin = balloonSkin;
			balloonDisplay.layout = new AnchorLayout();
			balloonDisplay.layoutData = new AnchorLayoutData(NaN, side==0?10:stage.stageWidth*0.3, NaN, side==0?stage.stageWidth*0.3:10);
			balloonDisplay.touchable = false;
			addChild(balloonDisplay);
			
			var labelDisplay:RTLLabel = new RTLLabel(loc(task.message), 0, "justify", null, true);
			labelDisplay.layoutData = new AnchorLayoutData(10*appModel.scale, 10*appModel.scale, NaN, 10*appModel.scale);
			balloonDisplay.addChild(labelDisplay);
			labelDisplay.validate();
			balloonDisplay.height = labelDisplay.height + 40*appModel.scale;*/

			if(transitionIn == null)
			{
				transitionIn = new TransitionData(0.2, task.startAfter / 1000);
				transitionIn.sourcePosition = new Point(0, 20);
				transitionIn.sourceAlpha = 0;
				transitionIn.destinationPosition = new Point(0, 0);
				
				if(transitionOut== null)
				{
					transitionOut = new TransitionData(0.1);
					transitionOut.destinationAlpha = 0;
					transitionOut.transition = Transitions.EASE_IN;
					transitionOut.sourcePosition = new Point(0, 20);
					transitionOut.destinationPosition = transitionIn.sourcePosition;
				}
			}
			
			// execute overlay transition
			layoutData = new AnchorLayoutData(NaN,0,NaN,0);
			//x = transitionIn.sourcePosition.x;
			y = transitionIn.sourcePosition.y;
			height = stage.height;
			alpha = transitionIn.sourceAlpha;
			Starling.juggler.tween(this, transitionIn.time,
				{
					delay:transitionIn.delay,
					alpha:transitionIn.destinationAlpha,
					x:transitionIn.destinationPosition.x, 
					y:transitionIn.destinationPosition.y, 
					transition:transitionIn.transition,
					onStart:transitionInStarted,
					onComplete:transitionInCompleted
				}
			);
		}
		
		override protected function transitionInCompleted():void
		{
			super.transitionInCompleted();
			appModel.navigator.addChild( new BaseTooltip(loc(task.message), new Rectangle((side==0?400:670)*appModel.scale, (side==0?1100:900)*appModel.scale, 2, 2), 1, 0.6));

		}
		
		public override function close(dispose:Boolean=true):void
		{
			super.close(dispose);
			Starling.juggler.tween(this, transitionOut.time,
			{
				delay:transitionOut.delay,
				alpha:transitionOut.destinationAlpha,
				x:transitionOut.destinationPosition.x, 
				y:transitionOut.destinationPosition.y, 
				transition:transitionOut.transition,
				onStart:transitionOutStarted,
				onComplete:transitionOutCompleted,
				onCompleteArgs:[dispose]
			}
			);
		}
	}
}