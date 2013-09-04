package mediator.comps 
{
import com.hurlant.util.asn1.parser.boolean;

import events.SSEvent;

import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;

import mediator.comps.FramesAndLabelMediator;

import model.FileSaverModel;
import model.SpriteSheetModel;

import org.robotlegs.mvcs.Mediator;
import org.zengrong.display.spritesheet.ISpriteSheetMetadata;
import org.zengrong.display.spritesheet.SpriteSheetMetadataJSON;
import org.zengrong.display.spritesheet.SpriteSheetMetadataStarling;
import org.zengrong.display.spritesheet.SpriteSheetMetadataTXT;
import org.zengrong.display.spritesheet.SpriteSheetMetadataType;
import org.zengrong.display.spritesheet.SpriteSheetMetadataXML;
import org.zengrong.file.FileEnding;

import type.StateType;

import utils.Funs;

import view.comps.ExportWindow;

import vo.LabelListVO;
import vo.MetadataPreferenceVO;

/**
 * 导出SpriteSheet或者序列图的界面
 * @author zrong
 * Creation: 2013-08-27
 */
public class ExportWindowMediator extends Mediator 
{
	[Inject] public var v:ExportWindow;
	[Inject] public var fileSaver:FileSaverModel;
	[Inject] public var ssModel:SpriteSheetModel;
	
	private function get app():SpriteSheetEditor
	{
		return contextView as SpriteSheetEditor;
	}
	
	override public function onRegister():void 
	{
		v.init( ssModel.originalSheet.metadata.hasName);
		
		
		eventMap.mapListener(v.saveBTN, MouseEvent.CLICK, handler_save);
		eventMap.mapListener(v.nameCB, Event.CHANGE, handler_nameCBChange);
		
		v.init(ssModel.originalSheet.metadata.hasName);
	}
	
	override public function onRemove():void 
	{
		
		eventMap.unmapListener(v.saveBTN, MouseEvent.CLICK, handler_save);
		eventMap.unmapListener(v.nameCB, Event.CHANGE, handler_nameCBChange);
	}
	
	
	protected function handler_nameCBChange($evt:Event):void
	{
		ssModel.adjustedSheet.metadata.hasName = v.nameCB.selected;
	}
	
	private function handler_save($evt:MouseEvent):void
	{
		updateMetadata();
		var __vo:MetadataPreferenceVO = v.exportPrefenence;
		__vo.metadata = getMetadata(__vo.metaType);
		if(__vo.metaType == ExportWindow.SEQUENCE)
		{
			__vo.fileNameList = v.getSeqFileNames(ssModel.adjustedSheet.metadata.totalFrame);
			__vo.type = StateType.SAVE_SEQ;
			//根据显示的帧类型来保存序列
			__vo.bitmapDataList = ssModel.getBMDList(v.saveSeq.frameCropDisplayRBG.selectedValue as Boolean);
		}
		else if(v.includeImageCb.selected)
		{
			__vo.bitmapData = 
				ssModel.getBitmapDataForSave(
					__vo.maskType, 
					ssModel.picReference.transparent, 
					ssModel.picReference.bgColor);
			__vo.type = StateType.SAVE_SHEET_PIC;
			if(v.includeMetadataCb.selected) __vo.type = StateType.SAVE_ALL;
		}
		else if(v.includeMetadataCb.selected)
		{
			__vo.type = StateType.SAVE_META;
		}
		fileSaver.save(__vo);
	}
	
	private function getMetadata($metaType:String):ISpriteSheetMetadata
	{
		var __meta:ISpriteSheetMetadata = null;
		if($metaType == SpriteSheetMetadataType.SSE_JSON)
		{
			__meta = new SpriteSheetMetadataJSON(ssModel.adjustedSheet.metadata);
		}
		else if($metaType == SpriteSheetMetadataType.SSE_XML)
		{
			__meta = new SpriteSheetMetadataXML(ssModel.adjustedSheet.metadata);
			SpriteSheetMetadataXML(__meta).header = Funs.getXMLHeader(FileEnding.UNIX);
		}
		else if($metaType == SpriteSheetMetadataType.SSE_TXT)
		{
			__meta = new SpriteSheetMetadataTXT(ssModel.adjustedSheet.metadata);
		}
		else if($metaType == SpriteSheetMetadataType.STARLING)
		{
			__meta = new SpriteSheetMetadataStarling(ssModel.adjustedSheet.metadata);
			SpriteSheetMetadataStarling(__meta).header = Funs.getXMLHeader(FileEnding.UNIX);
		}
		else if($metaType == SpriteSheetMetadataType.COCOS2D)
		{

		}
		return __meta;
	}
	
	/**
	 * 更新spriteSheet的metadata。在生成新的SpriteSheet前调用。
	 */
	private function updateMetadata():void
	{
		//hasName, names, namesIndex, totalFrame, frameRects, originalFrameRects 这几个变量
		//是在生成Sheet的时候填充的，因此这里不需要更新
		var __meta:ISpriteSheetMetadata = ssModel.adjustedSheet.metadata;
		__meta.type = v.imageSetting.spriteSheetType;
		__meta.maskType = v.maskDDL.selectedIndex;
		var __mediator:FramesAndLabelMediator = mediatorMap.retrieveMediator(app.ss.framesAndLabels) as FramesAndLabelMediator;
		var __labelMeta:LabelListVO = __mediator.getLabels();
		__meta.hasLabel = __labelMeta.hasLabel;
		__meta.labels = __labelMeta.labels;
		__meta.labelsFrame = __labelMeta.labelsFrame;
	}
}
}