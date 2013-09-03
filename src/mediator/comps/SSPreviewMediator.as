package mediator.comps
{
import events.SSEvent;

import flash.events.Event;
import flash.events.MouseEvent;

import gnu.as3.gettext.FxGettext;

import model.SpriteSheetModel;

import mx.events.FlexEvent;

import org.robotlegs.mvcs.Mediator;

import view.comps.SSPreview;

import vo.FramesAndLabelChangeVO;
import flash.display.BitmapData;

public class SSPreviewMediator extends Mediator
{
	[Inject] public var v:SSPreview;
	
	[Inject] public var ssModel:SpriteSheetModel;
	
	override public function onRegister():void
	{
		eventMap.mapListener(v.playBTN, MouseEvent.CLICK, handler_playBTNclick);
		eventMap.mapListener(v.transControlBar.saveResizeBTN, MouseEvent.CLICK, handler_saveResizeBTNclick);
		eventMap.mapListener(v.transControlBar.useCustomSizeCB, FlexEvent.VALUE_COMMIT, handler_resizeOriginCBChange);
		eventMap.mapListener(v, FlexEvent.VALUE_COMMIT, handler_resizeOriginCBChange);
		eventMap.mapListener(v.frameCropDisplayRBG, FlexEvent.VALUE_COMMIT, handler_frameDisChange);
		
		addViewListener(SSEvent.TRANSFORM_CHANGE, handler_transformSizeChange);
		
		addContextListener(SSEvent.FRAME_AND_LABEL_CHANGE, handler_framesAndLabelsChange);
		addContextListener(SSEvent.SELECTED_FRAMEINDICES_CHANGE, handler_framesAndLabelsChange);
		addContextListener(SSEvent.OPTIMIZE_SHEET, handler_optimizeSheet);
		addContextListener(SSEvent.PREVIEW_SS_CHANGE, handler_previewSSChange);
		
		v.init();
		setPlayEnable();
	}
	
	override public function onRemove():void
	{
		eventMap.unmapListener(v.playBTN, MouseEvent.CLICK, handler_playBTNclick);
		eventMap.unmapListener(v.transControlBar.saveResizeBTN, MouseEvent.CLICK, handler_saveResizeBTNclick);
		eventMap.unmapListener(v.transControlBar.useCustomSizeCB, FlexEvent.VALUE_COMMIT, handler_resizeOriginCBChange);
		eventMap.unmapListener(v.frameCropDisplayRBG, FlexEvent.VALUE_COMMIT, handler_frameDisChange);
		
		removeViewListener(SSEvent.TRANSFORM_CHANGE, handler_transformSizeChange);
		
		removeContextListener(SSEvent.FRAME_AND_LABEL_CHANGE, handler_framesAndLabelsChange);
		removeContextListener(SSEvent.SELECTED_FRAMEINDICES_CHANGE, handler_framesAndLabelsChange);
		removeContextListener(SSEvent.OPTIMIZE_SHEET, handler_optimizeSheet);
		removeContextListener(SSEvent.PREVIEW_SS_CHANGE, handler_previewSSChange);
		
		v.destroy();
		handler_playBTNclick(null);
	}
	
	private function handler_frameDisChange($evt:FlexEvent):void
	{
		handler_previewSSChange(null);
	}
	
	protected function handler_optimizeSheet($evt:SSEvent):void
	{
		v.destroyAni();
	}
	
	protected function handler_playBTNclick($event:MouseEvent):void
	{
		ssModel.playing = v.playBTN.selected;
		dispatch(new SSEvent(SSEvent.PREVIEW_SS_PLAY, v.playBTN.selected));
	}
	
	private function handler_saveResizeBTNclick($evt:MouseEvent):void
	{
		dispatch(new SSEvent(SSEvent.PREVIEW_SS_RESIZE_SAVE));
	}
	
	/**
	 * 保存预览变动的时候，从FrameAndLabel传来的一些值
	 */
	private var _frameAndLabelChange:FramesAndLabelChangeVO;
	private function handler_previewSSChange($evt:SSEvent):void
	{
		_frameAndLabelChange = $evt.info as FramesAndLabelChangeVO;
		updateFrame();
		v.label = (_frameAndLabelChange&&_frameAndLabelChange.labelEnabled) ? 
			("Label("+_frameAndLabelChange.labelName+")" + FxGettext.gettext("animation preview")) :
			FxGettext.gettext("Frame animation preview");
		
		if(ssModel.selectedFrameIndex<0) return;
		//根据选择显示原始的或者修剪过的Frame
		var __frameBmd:BitmapData = (v.frameCropDisplayRBG.selectedValue as Boolean) ?
			ssModel.adjustedSheet.getTrimBMDByIndex(ssModel.selectedFrameIndex):
			ssModel.adjustedSheet.getBMDByIndex(ssModel.selectedFrameIndex);
		v.showBmd(__frameBmd);
	}
	
	private function handler_resizeOriginCBChange($evt:FlexEvent):void
	{
		updateFrame();
	}
	
	private function handler_framesAndLabelsChange($evt:SSEvent):void
	{
		updateFrame();
	}
	
	private function handler_transformSizeChange($evt:Event):void
	{
		updateFrame();
	}
	
	private function updateFrame():void
	{
		v.frameLabel.text = ssModel.selectedFrmaeNum.toString();
		setPlayEnable();
		setSaveEnable();
		ssModel.resizeRect = v.getResizeRect();
	}
	
	private function setSaveEnable():void
	{
		v.transControlBar.setResizeBtnEnable(!ssModel.playing  && ssModel.selectedFrameIndices);
	}
	
	private function setPlayEnable():void
	{
		if(v.useFrameRB.selected)
		{
			v.playBTN.enabled = ssModel.selectedFrameIndices && ssModel.selectedFrameIndices.length>1;
		}
		else
		{
			v.playBTN.enabled = true;
		}
	}
}
}