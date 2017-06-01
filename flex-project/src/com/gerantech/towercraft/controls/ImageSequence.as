package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.models.Assets;
	
	import starling.display.MovieClip;
	import starling.textures.Texture;
	
	public class ImageSequence extends MovieClip
	{
		public function ImageSequence(textures:__AS3__.vec.Vector.<starling.textures.Texture>, fps:Number=12)
		{
			super(textures, fps);
		}
		
		public function changeTextures(textures:__AS3__.vec.Vector.<starling.textures.Texture>, fps:Number=-1):void
		{
			for(var i:int=0; i < numFrames; i++)
				setFrameTexture(i, Assets.getTexture(ttype+direction+(i>8 ? "_0"+(i+1) : "_00"+(i+1))));
			
			if(fps > -1)
				this.fps = fps;
		}
	}
}