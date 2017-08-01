package com.gerantech.towercraft.controls.texts
{
	import com.gerantech.towercraft.models.AppModel;
	
	import feathers.controls.TextInput;
	import feathers.controls.text.StageTextTextEditor;
	import feathers.core.ITextEditor;
	
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
				editor.fontSize = AppModel.instance.theme.regularFontSize ;
				editor.color = textColor;
				editor.softKeyboardType = softKeyboardType;
				editor.multiline = multiline;
				editor.returnKeyLabel = returnKeyLabel;
				return editor;
			}
			
			promptProperties.textAlign = "center"//AppModel.instance.align;
			promptProperties.bidiLevel = AppModel.instance.isLTR?0:1;
			//backgroundFocusedSkin = null
		}
		
	}
}