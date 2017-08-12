package com.gerantech.towercraft.controls.texts
{
	import com.gerantech.towercraft.models.AppModel;
	
	import feathers.controls.TextInput;
	import feathers.controls.text.StageTextTextEditor;
	import feathers.core.ITextEditor;
	import feathers.core.ITextRenderer;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	
	import starling.text.TextFormat;
	
	public class CustomTextInput extends TextInput
	{
		public function CustomTextInput(softKeyboardType:String, returnKeyLabel:String, textColor:uint=16777215, multiline:Boolean=false)
		{
			super();
			
			textEditorFactory = function():ITextEditor
			{
				var editor:StageTextTextEditor = new StageTextTextEditor();
				editor.fontFamily = "SourceSans";
				editor.textAlign = "center"//AppModel.instance.align;
				editor.fontSize = AppModel.instance.theme.gameFontSize * AppModel.instance.scale ;
				editor.color = textColor;
				editor.softKeyboardType = softKeyboardType;
				editor.multiline = multiline;
				editor.returnKeyLabel = returnKeyLabel;
				return editor;
			}
			
			promptFactory = function():ITextRenderer
			{
				return new RTLLabel("", textColor, "center");
			}

			height = 128 * AppModel.instance.scale;
			//backgroundFocusedSkin = null
		}
		
	}
}