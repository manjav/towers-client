package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
	import com.gerantech.towercraft.controls.headers.AttendeeHeader;
	import com.gerantech.towercraft.controls.items.StickerItemRenderer;
	import com.gerantech.towercraft.controls.sliders.BattleTimerSlider;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.vo.BattleData;
	import com.gerantech.towercraft.utils.StrUtils;
	import com.gt.towers.constants.StickerType;
	
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.List;
	import feathers.controls.ScrollPolicy;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalAlign;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.events.Event;

	public class BattleHUD extends TowersLayout
	{
		private var battleData:BattleData;
		private var timerSlider:BattleTimerSlider;
		private var stickerList:List;

		private var padding:int;

		private var stickerCloserOveraly:SimpleLayoutButton;
		private var myBubble:StickerBubble;
		private var opponentBubble:StickerBubble;

		private var starsNotice:StarsNotice;
		private var scoreIndex:int = 0;
		private var timeLog:RTLLabel;
		private var debugMode:Boolean = true;
		
		public function BattleHUD()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			this.battleData = appModel.battleFieldView.battleData;
		
			var gradient:ImageLoader = new ImageLoader();
			gradient.maintainAspectRatio = false;
			gradient.alpha = 0.5;
			gradient.width = 440 * appModel.scale;
			gradient.height = 140 * appModel.scale;
			gradient.source = Assets.getTexture("grad-ro-right", "skin");
			addChild(gradient);
			
			var hasQuit:Boolean = battleData.map.isQuest && player.get_questIndex() > 3 || SFSConnection.instance.mySelf.isSpectator;
			padding = 16 * appModel.scale;
			var leftPadding:int = (hasQuit ? 150 : 0) * appModel.scale;
			if( hasQuit )
			{
				var closeButton:CustomButton = new CustomButton();
				closeButton.style = "danger";
				closeButton.label = "X";
				closeButton.height = closeButton.width = 120 * appModel.scale;
				closeButton.layoutData = new AnchorLayoutData(padding, NaN, NaN, padding);
				closeButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
				addChild(closeButton);			
			}
			
			var _name:String = battleData.map.isQuest ? loc("quest_label") + " " + StrUtils.getNumber(battleData.map.index+1) : battleData.opponent.getVariable("name").getStringValue();
			var _point:int = battleData.map.isQuest ? 0 : battleData.opponent.getVariable("point").getIntValue();
			var opponentHeader:AttendeeHeader = new AttendeeHeader(_name, _point);
			opponentHeader.layoutData = new AnchorLayoutData(0, NaN, NaN, leftPadding );
			addChild(opponentHeader);
			
			if( SFSConnection.instance.mySelf.isSpectator )
			{
				_name = battleData.me.getVariable("name").getStringValue();
				_point = battleData.me.getVariable("point").getIntValue();
				var meHeader:AttendeeHeader = new AttendeeHeader(_name, _point);
				meHeader.layoutData = new AnchorLayoutData(NaN, NaN, 0, 0 );
				addChild(meHeader);
			}
			
			if( debugMode )
			{
				timeLog = new RTLLabel("", 0);
				timeLog.layoutData = new AnchorLayoutData(padding*10, padding*6);
				addChild(timeLog);
			}

			timerSlider = new BattleTimerSlider();
			timerSlider.layoutData = new AnchorLayoutData(padding*4, padding*6);
			addChild(timerSlider);
			
			starsNotice = new StarsNotice();
			starsNotice.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0);
			starsNotice.alpha = 0;
			starsNotice.y = 480 * appModel.scale;
			
			addEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
			
			if( !battleData.map.isQuest )
			{
				if( !SFSConnection.instance.mySelf.isSpectator )
				{
					var stickerButton:CustomButton = new CustomButton();
					stickerButton.icon = Assets.getTexture("sticker-bubble-me", "gui");
					stickerButton.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -4*appModel.scale);
					stickerButton.width = 140 * appModel.scale;
					stickerButton.layoutData = new AnchorLayoutData(NaN, padding, padding);
					stickerButton.addEventListener(Event.TRIGGERED, stickerButton_triggeredHandler);
					addChild(stickerButton);
				}
				
				myBubble = new StickerBubble();
				myBubble.layoutData = new AnchorLayoutData( NaN, padding, padding);
				
				opponentBubble = new StickerBubble(true);
				opponentBubble.layoutData = new AnchorLayoutData( 140 * appModel.scale + padding, NaN, NaN, padding);
			}
		}
		
		private function createCompleteHandler(event:Event):void
		{
			removeEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
			timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
			setTimePosition();
			
			if( battleData.battleField.extraTime > 0 )
				appModel.navigator.addAnimation(stage.stageWidth*0.5, stage.stageHeight*0.5, 240, Assets.getTexture("extra-time", "gui"), battleData.battleField.extraTime, timerSlider.iconDisplay.getBounds(this), 0.5, punchTimer, "+ ");
			function punchTimer():void {
				var diff:int = 48 * appModel.scale;
				timerSlider.y -= diff;
				Starling.juggler.tween(timerSlider, 0.4, {y:y+diff, transition:Transitions.EASE_OUT_ELASTIC});
			}
		}
		
		private function timeManager_changeHandler(event:Event):void
		{
			//trace(timeManager.now-battleData.startAt , battleData.map.times._list)
			if( scoreIndex<battleData.map.times.size() && timeManager.now-battleData.startAt > battleData.battleField.getTime(scoreIndex) )
			{
				scoreIndex ++;
				if( scoreIndex<battleData.map.times.size() )
				{
					setTimePosition();
				}
				else
				{
					timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
					timerSlider.enableStars(0);
				}
			}
			var time:int = timeManager.now - battleData.startAt - timerSlider.minimum;
			if( debugMode )
				timeLog.text = time.toString();
			//trace(time, timerSlider.minimum, timerSlider.maximum)
			if( time % 2 == 0 )
				Starling.juggler.tween(timerSlider, 1, {value:timerSlider.maximum - time, transition:Transitions.EASE_OUT_ELASTIC});
		}
		
		private function setTimePosition():void
		{
			timerSlider.enableStars(2-scoreIndex);
			timerSlider.minimum = scoreIndex>0?battleData.battleField.getTime(scoreIndex-1):0;
			timerSlider.value = timerSlider.maximum = battleData.battleField.getTime(scoreIndex);
			showTimeNotice(2-scoreIndex);
			trace("["+battleData.map.times._list+"]", "min:", timerSlider.minimum, "max:", timerSlider.maximum, "score:", 2-scoreIndex)
		}		
		
		private function showTimeNotice(score:int):void
		{
			if ( score > 1 )
				return;
			
			if( score == 1 )
				appModel.sounds.addAndPlaySound("battle-clock-ticking");
			else if( score == 0 )
				appModel.sounds.playSoundUnique("battle-clock-ticking", 0.4, 300, 0.3);

			addChild(starsNotice);
			setTimeout(starsNotice.pass, 1, score);
			Starling.juggler.tween(starsNotice, 0.3, {alpha:1, y:400*appModel.scale, transition:Transitions.EASE_OUT});
			Starling.juggler.tween(starsNotice, 0.3, {delay:3, alpha:0, y:480*appModel.scale, transition:Transitions.EASE_IN, onComplete:starsNotice.removeFromParent});
			appModel.sounds.addAndPlaySound("whoosh");
		}
		
		private function closeButton_triggeredHandler(event:Event):void
		{
			dispatchEventWith(Event.CLOSE);
		}
		
		private function stickerButton_triggeredHandler(event:Event):void
		{
			if( stickerList == null )
			{
				var stickersLayout:TiledRowsLayout = new TiledRowsLayout();
				stickersLayout.padding = stickersLayout.gap = padding;
				stickersLayout.tileHorizontalAlign = HorizontalAlign.JUSTIFY;
				stickersLayout.tileVerticalAlign = VerticalAlign.JUSTIFY;
				stickersLayout.useSquareTiles = false;
				stickersLayout.distributeWidths = true;
				stickersLayout.distributeHeights = true;
				stickersLayout.requestedColumnCount = 4;
				
				stickerList = new List();
				stickerList.layout = stickersLayout;
				stickerList.layoutData = new AnchorLayoutData(NaN,0,NaN,0);
				stickerList.height = padding*20;
				stickerList.itemRendererFactory = function ():IListItemRenderer { return new StickerItemRenderer(); }
				stickerList.verticalScrollPolicy = stickerList.horizontalScrollPolicy = ScrollPolicy.OFF;
				stickerList.dataProvider = new ListCollection(StickerType.getAll(game)._list);
				
				stickerCloserOveraly = new SimpleLayoutButton();
				stickerCloserOveraly.backgroundSkin = new Quad(1,1,0);
				stickerCloserOveraly.backgroundSkin.alpha = 0.1;
				stickerCloserOveraly.layoutData = new AnchorLayoutData(0,0,0,0);
				stickerCloserOveraly.addEventListener(Event.TRIGGERED, stickerCloserOveraly_triggeredHandler);
			}
			addChild(stickerCloserOveraly);

			AnchorLayoutData(stickerList.layoutData).bottom = -padding*20;
			Starling.juggler.tween(stickerList.layoutData, 0.2, {bottom:0, transition:Transitions.EASE_OUT});
			stickerList.addEventListener(Event.CHANGE, stickerList_changeHandler);
			addChild(stickerList);
		}
		private function hideStickerList():void
		{
			stickerList.removeEventListener(Event.CHANGE, stickerList_changeHandler);
			removeChild(stickerCloserOveraly);
			AnchorLayoutData(stickerList.layoutData).bottom = 0;
			Starling.juggler.tween(stickerList.layoutData, 0.2, {bottom:-padding*20, transition:Transitions.EASE_IN, onComplete:stickerList.removeFromParent});
		}
		
		private function stickerCloserOveraly_triggeredHandler(event:Event):void
		{
			hideStickerList();
		}
		
		private function stickerList_changeHandler(event:Event):void
		{
			hideStickerList();
			var sticker:int = stickerList.selectedItem as int
			appModel.battleFieldView.responseSender.sendSticker(sticker);
			showBubble(sticker);
			stickerList.selectedIndex = -1;
		}
		
		public function showBubble(type:int, itsMe:Boolean=true):void
		{
			var bubble:StickerBubble = itsMe ? myBubble : opponentBubble;

			Starling.juggler.removeTweens(bubble);
			bubble.type = type;
			bubble.scale = 0.5;
			addChild(bubble);
			Starling.juggler.tween(bubble, 0.2, {scale:1, transition:Transitions.EASE_OUT_BACK});
			Starling.juggler.tween(bubble, 0.2, {scale:0.5, transition:Transitions.EASE_IN_BACK, delay:4, onComplete:bubble.removeFromParent});
			appModel.sounds.addAndPlaySound("whoosh");
		}
		
		override public function dispose():void
		{
			timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
			super.dispose();
		}
	}

}