package mediator.comps
{
import events.SSEvent;

import flash.display.BitmapData;
import flash.events.Event;

import model.FileProcessor;
import model.SpriteSheetModel;

import org.robotlegs.mvcs.Mediator;

import view.comps.FramesAndLabels;

public class FramesAndLabelMediator extends Mediator
{
	[Inject] public var v:FramesAndLabels;
	
	[Inject] public var file:FileProcessor;
	
	[Inject] public var ssModel:SpriteSheetModel;
	
	override public function onRegister():void
	{
		addViewListener(Event.SELECT, handler_select);
		addViewListener(SSEvent.ADD_FRAME_TO_SS, handler_addFrameToSS);
		addViewListener(SSEvent.DELETE_FRAME, handler_addFrameToSS);
		addViewListener(SSEvent.FRAME_AND_LABEL_CHANGE, handler_framesAndLabelsChange);
		addViewListener(SSEvent.SELECTED_FRAMEINDICES_CHANGE, handler_selectedFrameIndicesChange);
		addContextListener(SSEvent.PREVIEW_SS_PLAY, handler_ssPreviewPlay);
	}
	
	override public function onRemove():void
	{
		removeContextListener(SSEvent.PREVIEW_SS_PLAY, handler_ssPreviewPlay);
	}
	
	private function handler_ssPreviewPlay($evt:SSEvent):void
	{
		if($evt.info)
			v.play();
		else
			v.pause();
	}
	
	private function handler_select($evt:Event):void
	{
		file.addToSS(v.fun_addToSS);
	}
	
	private function handler_addFrameToSS($evt:SSEvent):void
	{
		dispatch($evt);
	}
	
	/**
	 * Lable修改的时候更新动画预览
	 */
	protected function handler_framesAndLabelsChange($event:Event):void
	{
		ssModel.selectedFrameIndex = v.selectedFrameIndex;
		ssModel.selectedFrmaeNum = v.selectedFrameNum;
		if(v.selectedFrameIndex > -1)
		{
			dispatch(new SSEvent(SSEvent.PREVIEW_SS_DIS_CHANGE));
		}
	}
	
	private function handler_selectedFrameIndicesChange($evt:SSEvent):void
	{
		ssModel.selectedFrameIndices = v.selectedFrameIndices;
		dispatch($evt);
	}
}
}