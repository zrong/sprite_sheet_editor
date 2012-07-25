package mediator.comps
{
import events.SSEvent;

import flash.events.Event;
import flash.events.MouseEvent;

import model.SpriteSheetModel;

import org.robotlegs.mvcs.Mediator;

import view.comps.SSPreview;

public class SSPreviewMediator extends Mediator
{
	[Inject]
	public var v:SSPreview;
	
	[Inject] public var ssModel:SpriteSheetModel;
	
	override public function onRegister():void
	{
		eventMap.mapListener(v.playBTN, MouseEvent.CLICK, handler_playBTNclick);
		eventMap.mapListener(v.saveResizeBTN, MouseEvent.CLICK, handler_saveResizeBTNclick);
		eventMap.mapListener(v.frameCropDisplayRBG, Event.CHANGE, handler_frameDisChange);
		addViewListener(SSPreview.EVENT_FRAME_SIZE_CHANGE, handler_frameSizeChange);
		
		addContextListener(SSEvent.PREVIEW_SS_SHOW, handler_previewShow);
		addContextListener(SSEvent.FRAME_AND_LABEL_CHANGE, handler_framesAndLabelsChange);
		addContextListener(SSEvent.SELECTED_FRAMEINDICES_CHANGE, handler_framesAndLabelsChange);
	}
	
	override public function onRemove():void
	{
		eventMap.unmapListener(v.playBTN, MouseEvent.CLICK, handler_playBTNclick);
		eventMap.unmapListener(v.saveResizeBTN, MouseEvent.CLICK, handler_saveResizeBTNclick);
		eventMap.unmapListener(v.frameCropDisplayRBG, Event.CHANGE, handler_frameDisChange);
		removeViewListener(SSPreview.EVENT_FRAME_SIZE_CHANGE, handler_frameSizeChange);
		
		removeContextListener(SSEvent.PREVIEW_SS_SHOW, handler_previewShow);
		removeContextListener(SSEvent.SELECTED_FRAMEINDICES_CHANGE, handler_framesAndLabelsChange);
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
	
	private function handler_previewShow($evt:SSEvent):void
	{
		v.showBmd($evt.info);
	}
	
	private function handler_frameDisChange($evt:Event):void
	{
		ssModel.displayCrop = v.frameCropDisplayRBG.selectedValue;
		updateFrame();
		v.frameLabel.text = ssModel.selectedFrmaeNum.toString();
		v.playBTN.enabled = ssModel.selectedFrameIndices && ssModel.selectedFrameIndices.length>1;
		dispatch(new SSEvent(SSEvent.PREVIEW_SS_DIS_CHANGE));
	}
	
	private function handler_framesAndLabelsChange($evt:SSEvent):void
	{
		updateFrame();
	}
	
	private function handler_frameSizeChange($evt:Event):void
	{
		ssModel.resizeRect = v.getResizeRect();
	}
	
	private function updateFrame():void
	{
		v.frameLabel.text = ssModel.selectedFrmaeNum.toString();
		v.playBTN.enabled = ssModel.selectedFrameIndices && ssModel.selectedFrameIndices.length>1;
		v.saveResizeBTN.enabled = !ssModel.playing && v.resizeOriginCB.selected && v.playBTN.enabled;
	}
}
}