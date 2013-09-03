package ctrl 
{
import events.SSEvent;

import flash.display.BitmapData;

import model.FileSaverModel;
import model.SpriteSheetModel;

import org.robotlegs.mvcs.Command;

import type.StateType;

import vo.MetadataPreferenceVO;

/**
 * 用于保存文件的Cmd
 * @author zrong
 * Creation: 2013-06-13
 */
public class SaveCmd extends Command 
{
	[Inject] public var evt:SSEvent;
	[Inject] public var fileSaver:FileSaverModel;
	[Inject] public var ssModel:SpriteSheetModel;
	
	override public function execute():void
	{
		var __vo:MetadataPreferenceVO = evt.info as MetadataPreferenceVO;
		if(__vo.type == StateType.SAVE_ALL ||
			__vo.type == StateType.SAVE_SHEET_PIC)
		{
			__vo.bitmapData = 
				ssModel.getBitmapDataForSave(
					__vo.maskType, 
					ssModel.picReference.transparent, 
					ssModel.picReference.bgColor);
		}
		fileSaver.save(__vo);
	}
}
}