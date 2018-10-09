package com.gerantech.towercraft.managers
{
	
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.vo.SettingsData;
	import com.gerantech.towercraft.models.vo.UserData;
	import com.gt.towers.constants.PrefsTypes;
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	
	import starling.core.Starling;
	
	public class SoundManager 
	{
		
		public static const CATE_THEME:int = 0;
		public static const CATE_SFX:int = 1;
		
		private var _isMuted:Boolean = false;		// When true, every change in volume for ALL sounds is ignored
		
		public var sounds:Dictionary;				// contains all the sounds registered with the Sound Manager
		public var currPlayingSounds:Dictionary;	// contains all the sounds that are currently playing
		
		public function SoundManager() 
		{			
			sounds = new Dictionary();
			currPlayingSounds = new Dictionary();
		}
		// -------------------------------------------------------------------------------------------------------------------------		
		public function dispose():void {			
			sounds = null;
			currPlayingSounds = null;
		}
		
		public function addAndPlaySound(id:String, sound:Sound=null, category:int=1):void 
		{
			addSound(id, sound, soundAdded, category);
			function soundAdded():void{playSound(id);}
		}
		// -------------------------------------------------------------------------------------------------------------------------			
		/** Add sounds to the sound dictionary */
		public function addSound(id:String, sound:Sound=null, callback:Function=null, category:int=1):void 
		{
			if ( soundIsAdded(id) )
			{
				if(callback != null)
					callback();
				return;
			}

			if( sound == null )
			{
				AppModel.instance.assets.enqueue("assets/sounds/" + id + ".mp3");
				AppModel.instance.assets.loadQueue(assets_loadCallback);
				return;
			}
			sounds[id] = {s:sound, c:category};
			function assets_loadCallback(ratio:Number):void
			{
				if( ratio < 1 )
					return;
				sound = AppModel.instance.assets.getSound(id);
				sounds[id] = {s:sound, c:category};
				if(callback != null)
					callback();
			}
		}
		// -------------------------------------------------------------------------------------------------------------------------		
		/** Remove sounds from the sound manager */
		public function removeSound(id:String):void {
			if (soundIsAdded(id)) {
				delete sounds[id];	
				
			//	AppModel.instance.assets.
				if (soundIsPlaying(id))
					delete currPlayingSounds[id];
			}
			else {
				throw Error("The sound you are trying to remove is not in the sound manager");
			}
		}
		// -------------------------------------------------------------------------------------------------------------------------		
		/** Check if a sound is in the sound manager */
		public function soundIsAdded(id:String):Boolean {
			return Boolean(sounds[id]);
		}
		// -------------------------------------------------------------------------------------------------------------------------		
		/** Check if a sound is playing */
		public function soundIsPlaying(id:String):Boolean
		{
			for (var currID:String in currPlayingSounds) {
				if ( currID == id )
					return true;
			}	
			return false;
		}
		
		public function playSoundUnique(id:String, volume:Number = 1.0, repetitions:int = 1, panning:Number = 0):void		
		{
			if( soundIsPlaying(id) )
				return;
			playSound( id, volume, repetitions, panning);
		}
		
		// -------------------------------------------------------------------------------------------------------------------------		
		/** Play a sound */
		public function playSound(id:String, volume:Number = 1.0, repetitions:int = 1, panning:Number = 0):void {			
			
			if( soundIsAdded(id) )
			{
				if( AppModel.instance.loadingManager.state < LoadingManager.STATE_LOADED )
					return;
				var category:int = sounds[id].c;
				if( category == CATE_SFX && !AppModel.instance.game.player.prefs.getAsBool(PrefsTypes.SETTINGS_2_SFX) )
					return;
				if( category == CATE_THEME && !AppModel.instance.game.player.prefs.getAsBool(PrefsTypes.SETTINGS_1_MUSIC) )
					return;
				
				var soundObject:Sound = sounds[id].s;
				var channel:SoundChannel = soundObject.play(0, repetitions);
				
				if (!channel)
					return;
				
				channel.addEventListener(Event.SOUND_COMPLETE, removeSoundFromDictionary);
				
				// if the sound manager is muted, set the sound's volume to zero
				var v:Number = (_isMuted)? 0 : volume;
				var s:SoundTransform = new SoundTransform(v, panning);
				channel.soundTransform = s;
				
				currPlayingSounds[id] = { channel:channel, sound:soundObject, volume:volume };
			}
			else
			{
				trace("The sound you are trying to play (" + id + ") is not in the Sound Manager. Try adding it to the Sound Manager first.");
			}
		}
		// -------------------------------------------------------------------------------------------------------------------------		
		/** Remove a sound from the dictionary of the sounds that are currently playing */
		private function removeSoundFromDictionary(e:Event):void {			
			
			for (var id:String in currPlayingSounds) 
			{
				if (currPlayingSounds[id].channel == e.target)
					delete currPlayingSounds[id];
			}
			e.currentTarget.removeEventListener(Event.SOUND_COMPLETE, removeSoundFromDictionary);
		}
		// -------------------------------------------------------------------------------------------------------------------------		
		/** Stop a sound */
		public function stopSound(id:String):void {
			if( !soundIsAdded(id) )
				return;
			
			if (soundIsPlaying(id))
			{
				SoundChannel(currPlayingSounds[id].channel).stop();				
				delete currPlayingSounds[id];				
			}
		}
		// -------------------------------------------------------------------------------------------------------------------------
		/** Stop all sounds that are currently playing */
        public function stopAllSounds(category:int=-1):void {
			for (var currID:String in currPlayingSounds) 
                if( category == -1 || category == currPlayingSounds[currID].c == category )
					stopSound(currID);
		}
		// -------------------------------------------------------------------------------------------------------------------------		
		/** Set a sound's volume */
		public function setVolume(id:String, volume:Number):void {			
			if (soundIsPlaying(id))
			{
				var s:SoundTransform = new SoundTransform(volume);
				SoundChannel(currPlayingSounds[id].channel).soundTransform = s;
				currPlayingSounds[id].volume = volume;
			}
			else
			{
				trace("This sound (id = " + id + " ) is not currently playing");
				//throw Error("This sound (id = " + id + " ) is not currently playing");
			}
		}
		// -------------------------------------------------------------------------------------------------------------------------
		/** Tween a sound's volume */
		public function tweenVolume(id:String, volume:Number = 0, tweenDuration:Number = 2):void {
			if (soundIsPlaying(id))
			{
				var s:SoundTransform = new SoundTransform();
				var soundObject:Object = currPlayingSounds[id];
				var c:SoundChannel = currPlayingSounds[id].channel;
				
				Starling.juggler.tween(soundObject, tweenDuration, {
					volume: volume,
					onUpdate: function():void {
						if (!_isMuted)
						{
							s.volume = soundObject.volume;
							c.soundTransform = s;
						}
					}
				});
			}
			else
			{
				throw Error("This sound (id = " + id + " ) is not currently playing");
			}
		}
		// -------------------------------------------------------------------------------------------------------------------------		
		/** Cross fade two sounds. N.B. The sounds that fades out must be already playing */
		public function crossFade(fadeOutId:String, fadeInId:String, tweenDuration:Number = 2, fadeInVolume:Number = 1, fadeInRepetitions:int = 1):void {			
			
			// If the fade-in sound is not already playing, start playing it
			if (!soundIsPlaying(fadeInId))
				playSound(fadeInId, 0, fadeInRepetitions);
			
			tweenVolume (fadeOutId, 0, tweenDuration);
			tweenVolume (fadeInId, fadeInVolume, tweenDuration);
			
			// If the fade-out sound is playing, stop it when its volume reaches zero
			if (soundIsPlaying(fadeOutId))
				Starling.juggler.delayCall(stopSound, tweenDuration, fadeOutId);
		}
		// -------------------------------------------------------------------------------------------------------------------------		
		/** Sets a new volume for all the sounds currently playing 
		 *  @param volume the new volume value 
		 */
		public function setGlobalVolume(volume:Number):void {
			var s:SoundTransform;
			for (var currID:String in currPlayingSounds) {
				s = new SoundTransform(volume);
				SoundChannel(currPlayingSounds[currID].channel).soundTransform = s;
				currPlayingSounds[currID].volume = volume;
			}
		}
		// -------------------------------------------------------------------------------------------------------------------------		
		/** Mute all sounds currently playing.
		 *  @param mute a Boolean dictating whether all the sounds in the sound manager should be silenced (true) or restored to their original volume (false). 
		 */ 
		public function muteAll(mute:Boolean = true):void {
			
			if (mute != _isMuted)
			{
				var s:SoundTransform;
				for (var currID:String in currPlayingSounds) 
				{
					s = new SoundTransform(mute ? 0 : currPlayingSounds[currID].volume);
					SoundChannel(currPlayingSounds[currID].channel).soundTransform = s;
				}
				_isMuted = mute;
			}
		}
		// -------------------------------------------------------------------------------------------------------------------------		
		public function getSoundChannel(id:String):SoundChannel {			
			if (soundIsPlaying(id))
				return SoundChannel(currPlayingSounds[id].channel);
			
			throw Error("You are trying to get a non-existent soundChannel. Play the sound first in order to assign a channel.");
		}
		// -------------------------------------------------------------------------------------------------------------------------		
		public function getSoundTransform(id:String):SoundTransform {			
			if (soundIsPlaying(id))
				return SoundChannel(currPlayingSounds[id].channel).soundTransform;
			
			throw Error("You are trying to get a non-existent soundTransform. Play the sound first in order to assign a transform.");
		}
		// -------------------------------------------------------------------------------------------------------------------------		
		public function getSoundVolume(id:String):Number {			
			if (soundIsPlaying(id))
				return currPlayingSounds[id].volume;
			
			throw Error("You are trying to get a non-existent volume. Play the sound first in order to assign a volume.");
		}		
		// --------------------------------------------------------------------------------------------------------------------------------------
		// SETTERS & GETTERS
		public function get isMuted():Boolean { return _isMuted; }		
	}
}