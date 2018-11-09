package com.gerantech.towercraft.views 
{
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.MovieClip;
import starling.display.Sprite;
import starlingbuilder.engine.IAssetMediator;
import starlingbuilder.engine.UIBuilder;
import starlingbuilder.engine.localization.ILocalization;
import starlingbuilder.engine.tween.ITweenBuilder;

/**
* ...
* @author Mansour Djawadi
*/
public class MapBuilder extends UIBuilder 
{
public static const linkers:Array = [MovieClip];
public var mainMap:Sprite;
private var movieClips:Vector.<MovieClip>;
public function MapBuilder(assetMediator:IAssetMediator, forEditor:Boolean=false, template:Object=null, localization:ILocalization=null, tweenBuilder:ITweenBuilder=null) 
{
    movieClips = new Vector.<MovieClip>();
	super(assetMediator, forEditor, template, localization, tweenBuilder);
}

override public function create(data:Object, trimLeadingSpace:Boolean = true, binder:Object = null) : Object
{
	var root:Sprite = super.create(data, trimLeadingSpace, binder) as Sprite;
	mainMap = root.getChildByName("main") as Sprite;
	activeMovieClips(mainMap);
	addObstacles(root.getChildByName("obstacles"));
	return root;
}

private function addObstacles(childByName:starling.display.DisplayObject):void 
{
	
}

private function activeMovieClips(container:DisplayObjectContainer) : void
{
	for ( var i:int = 0; i < container.numChildren; i ++ )
	{
		if( container.getChildAt(i) is MovieClip )
		{
			var m:MovieClip = container.getChildAt(i) as MovieClip;
			Starling.current.juggler.add(m);
			m.play();
			movieClips.push(m);
		}
		if( container.getChildAt(i) is DisplayObjectContainer )
			activeMovieClips(container.getChildAt(i) as DisplayObjectContainer );
	}
}

public function dispose() : void 
{
	for each( var m:MovieClip in movieClips )
		Starling.current.juggler.remove(m);
}
}
}