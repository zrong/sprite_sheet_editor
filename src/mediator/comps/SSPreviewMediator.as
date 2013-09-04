package mediator.comps
{
import events.SSEvent;

import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;

import gnu.as3.gettext.FxGettext;

import model.SpriteSheetModel;

import mx.events.FlexEvent;

import org.robotlegs.mvcs.Mediator;

import view.comps.SSPreview;

public class SSPreviewMediator extends Mediator
{
	[Inject] public var v:SSPreview;
	
	[Inject] public var ssModel:SpriteSheetModel;
	
	override public function onRegister():void
	{
		eventMap.mapListener(v.playBTN, MouseEvent.CLICK, handler_playBTNclick);
		eventMap.mapListener(v.transControlBar.saveResizeBTN, MouseEvent.CLICK, handler_saveResizeBTNclick);
		eventMap.mapListener(v.transControlBar.useCustomSizeCB, FlexEvent.VALUE_COMMIT, handler_resizeOriginCBChange);
		eventMap.mapListener(v.frameOrLabelRBG, FlexEvent.VALUE_COMMIT, handler_frameDisChange);
		eventMap.mapListener(v.frameCropDisplayRBG, FlexEvent.VALUE_COMMIT, handler_frameDisChange);
		
		addViewListener(SSEvent.TRANSFORM_CHANGE, handler_transformSizeChange);
		
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
		eventMap.unmapListener(v.frameOrLabelRBG, FlexEvent.VALUE_COMMIT, handler_frameDisChange);
		eventMap.unmapListener(v.frameCropDisplayRBG, FlexEvent.VALUE_COMMIT, handler_frameDisChange);
		
		removeViewListener(SSEvent.TRANSFORM_CHANGE, handler_transformSizeChange);
		
		removeContextListener(SSEvent.SELECTED_FRAMEINDICES_CHANGE, handler_framesAndLabelsChange);
		removeContextListener(SSEvent.OPTIMIZE_SHEET, handler_optimizeSheet);
		removeContextListener(SSEvent.PREVIEW_SS_CHANGE, handler_previewSSChange);
		
		v.destroy();
		handler_playBTNclick(null);
	}
	
	private function get app():SpriteSheetEditor
	{
		return contextView as SpriteSheetEditor;
	}
	
	private function get framesAndLabels_labelEnabled():Boolean
	{
		return app.ss.framesAndLabels.labelEnabled;
	}
	
	private function get framesAndLabels_selectedLabelName():String
	{
		return app.ss.framesAndLabels.selectedLabel ? 
			app.ss.framesAndLabels.selectedLabel.name: 
			"";
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
	
	private function handler_frameDisChange($evt:FlexEvent):void
	{
		updateFrame();
		updateTitle();
		showPreview();
	}
	
	private function handler_previewSSChange($evt:SSEvent):void
	{
		updateFrame();
		updateTitle();
		showPreview();
	}
	
	private function handler_resizeOriginCBChange($evt:FlexEvent):void
	{
		updateFrame();
	}
	
	private function handler_framesAndLabelsChange($evt:SSEvent):void
	{
		updateFrame();
		updateTitle();
	}
	
	private function handler_transformSizeChange($evt:Event):void
	{
		updateFrame();
	}
	
	//获取到要显示的帧的图像，直接显示
	private function showPreview():void
	{
		if(ssModel.selectedFrameIndex<0) return;
		//根据选择显示原始的或者修剪过的Frame
		var __frameBmd:BitmapData = (v.frameCropDisplayRBG.selectedValue as Boolean) ?
			ssModel.adjustedSheet.getTrimBMDByIndex(ssModel.selectedFrameIndex):
			ssModel.adjustedSheet.getBMDByIndex(ssModel.selectedFrameIndex);
		v.showBmd(__frameBmd);
	}
	
	//更新当前的Title，用于指示当前显示的是帧动画预览还是Label动画预览
	//有可用Label的时候，才允许选择Frame或者Label显示
	private function updateTitle():void
	{
		v.frameOrLabelGRP.enabled= framesAndLabels_labelEnabled;
		//不可选择的时候，返回默认选项，即显示帧
		if(!framesAndLabels_labelEnabled && !v.frameOrLabelRBG.selectedValue) 
		{
			v.frameOrLabelRBG.selectedValue = true;
		}
		//到了这里，v.frameOrLabelRBG.selectedValue的值一定是个确定值
		v.label = (!v.frameOrLabelRBG.selectedValue) ? 
			("Label("+framesAndLabels_selectedLabelName+")" + FxGettext.gettext("animation preview")) :
			FxGettext.gettext("Frame animation preview");
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