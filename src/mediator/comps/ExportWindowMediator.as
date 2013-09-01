package mediator.comps 
{
import events.SSEvent;
import type.StateType;
import flash.display.BitmapData;
import flash.events.Event;

import model.FileSaverModel;
import model.SpriteSheetModel;

import org.robotlegs.mvcs.Mediator;
import org.zengrong.display.spritesheet.SpriteSheetMetadataJSON;

import view.comps.ExportWindow;

import vo.SaveVO;
import org.zengrong.display.spritesheet.ISpriteSheetMetadata;
import org.zengrong.display.spritesheet.SpriteSheetMetadataStarling;

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
	
	override public function onRegister():void 
	{
		v.init( ssModel.originalSheet.metadata.hasName);
		
		
		eventMap.mapListener(v.saveSheet, SSEvent.SAVE_ALL, handler_saveAll);
		eventMap.mapListener(v.saveSheet, SSEvent.SAVE_META, handler_saveMeta);
		eventMap.mapListener(v.saveSheet, SSEvent.SAVE_PIC, handler_savePic);
		eventMap.mapListener(v.saveSeq, SSEvent.SAVE_SEQ, handler_saveSeq);
		eventMap.mapListener(v.saveSheet.nameCB, Event.CHANGE, handler_nameCBChange);
	}
	
	override public function onRemove():void 
	{
		
		eventMap.unmapListener(v.saveSheet, SSEvent.SAVE_ALL, handler_saveAll);
		eventMap.unmapListener(v.saveSheet, SSEvent.SAVE_META, handler_saveMeta);
		eventMap.unmapListener(v.saveSheet, SSEvent.SAVE_PIC, handler_savePic);
		eventMap.unmapListener(v.saveSeq, SSEvent.SAVE_SEQ, handler_saveSeq);
		eventMap.unmapListener(v.saveSheet.nameCB, Event.CHANGE, handler_nameCBChange);
	}
	
	
	protected function handler_nameCBChange($evt:Event):void
	{
		ssModel.adjustedSheet.metadata.hasName = v.saveSheet.nameCB.selected;
	}
	
	private function handler_saveAll($evt:SSEvent):void
	{
		updateMetadata();
		var __vo:SaveVO = v.getSheetSaveVO();
		var __bmd:BitmapData = ssModel.getBitmapDataForSave(v.maskTypeValue, v.transparent, v.bgColor);
		__vo.bitmapData = __bmd;
		__vo.metadata = getMetadata();
		__vo.type = StateType.SAVE_ALL;
		dispatch(new SSEvent(SSEvent.SAVE, __vo));
	}
	
	
	protected function handler_saveMeta($event:SSEvent):void
	{
		updateMetadata();
		var __vo:SaveVO =  v.getSheetSaveVO();
		__vo.metadata = getMetadata();
		__vo.type = StateType.SAVE_META;
		dispatch(new SSEvent(SSEvent.SAVE, __vo));
	}
	
	protected function handler_savePic($event:SSEvent):void
	{
		updateMetadata();
		var __vo:SaveVO =v.getSheetSaveVO();
		__vo.bitmapData = ssModel.getBitmapDataForSave(v.maskTypeValue, v.transparent, v.bgColor);
		__vo.type = StateType.SAVE_SHEET_PIC;
		dispatch(new SSEvent(SSEvent.SAVE, __vo));
	}
	
	private function handler_saveSeq($evt:SSEvent):void
	{
		var __vo:SaveVO = v.getSeqSaveVO();
		__vo.fileNameList = v.getSeqFileNames(ssModel.adjustedSheet.metadata.totalFrame);
		__vo.type = StateType.SAVE_SEQ;
		//根据显示的帧类型来保存序列
		__vo.bitmapDataList = ssModel.getBMDList();
		dispatch(new SSEvent(SSEvent.SAVE, __vo));
	}
	
	
	private function getMetadata():ISpriteSheetMetadata
	{
		var __meta:ISpriteSheetMetadata = null;
		if(v.saveSheet.jsonRB.selected)
		{
			__meta = new SpriteSheetMetadataJSON(ssModel.adjustedSheet.metadata);
		}
		else if(v.saveSheet.xmlRB.selected)
		{
			__meta = new SpriteSheetMetadataXML(ssModel.adjustedSheet.metadata);
			SpriteSheetMetadataXML(__meta).header = Funs.getXMLHeader(FileEnding.UNIX);
		}
		else if(v.saveSheet.starlingRB.selected)
		{
			__meta = new SpriteSheetMetadataStarling(ssModel.adjustedSheet.metadata);
			SpriteSheetMetadataStarling(__meta).header = Funs.getXMLHeader(FileEnding.UNIX);
		}
		else
		{
			__meta = new SpriteSheetMetadataTXT(ssModel.adjustedSheet.metadata);
		}
		return __meta;
	}
	
	private function SpriteSheetMetadataXML(__meta:ISpriteSheetMetadata):Object
	{
		// TODO Auto Generated method stub
		return null;
	}
	
	/**
	 * 更新spriteSheet的metadata。在生成新的SpriteSheet前调用。
	 */
	private function updateMetadata():void
	{
		//hasName, names, namesIndex, totalFrame, frameRects, originalFrameRects 这几个变量
		//是在生成Sheet的时候填充的，因此这里不需要更新
		var __meta:ISpriteSheetMetadata = ssModel.adjustedSheet.metadata;
		__meta.type = v.sheetType;
		__meta.maskType = v.saveSheet.maskDDL.selectedIndex;
		var __mediator:FramesAndLabelMediator = mediatorMap.retrieveMediator(v.framesAndLabels) as FramesAndLabelMediator;
		var __labelMeta:LabelListVO = __mediator.getLabels();
		__meta.hasLabel = __labelMeta.hasLabel;
		__meta.labels = __labelMeta.labels;
		__meta.labelsFrame = __labelMeta.labelsFrame;
	}
}
}