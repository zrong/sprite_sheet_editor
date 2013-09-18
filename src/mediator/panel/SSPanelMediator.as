package mediator.panel
{
import events.SSEvent;

import flash.display.BitmapData;
import flash.geom.Rectangle;

import gnu.as3.gettext.FxGettext;

import model.SpriteSheetModel;
import model.StateModel;

import org.robotlegs.mvcs.Mediator;

import type.StateType;

import utils.Funs;

import view.panel.SSPanel;

import vo.FrameVO;
import vo.OptimizedResultVO;
import vo.PicPreferenceVO;

public class SSPanelMediator extends Mediator
{
	[Inject] public var v:SSPanel;
	[Inject] public var stateModel:StateModel;
	[Inject] public var ssModel:SpriteSheetModel;
	
	override public function onRegister():void
	{
		addContextListener(SSEvent.ENTER_STATE, handler_enterState);
		addContextListener(SSEvent.OPTIMIZE_SHEET, handler_optimizeSheet);
		addContextListener(SSEvent.PREVIEW_SS_CHANGE, handler_previewChange);
		addContextListener(SSEvent.SELECTED_FRAMEINDICES_CHANGE, handler_selected_frameindices_change);

		eventMap.mapListener(v.optPanel, SSEvent.BUILD, handler_build);
		eventMap.mapListener(v.sheetPreview, SSEvent.PREVIEW_CLICK, handler_sheetPreviewClick);
		
		enterState();
	}
	
	override public function onRemove():void
	{
		trace('SSPanel remove');
		removeContextListener(SSEvent.ENTER_STATE, handler_enterState);
		removeContextListener(SSEvent.OPTIMIZE_SHEET, handler_optimizeSheet);
		removeContextListener(SSEvent.PREVIEW_SS_CHANGE, handler_previewChange);
		removeContextListener(SSEvent.SELECTED_FRAMEINDICES_CHANGE, handler_selected_frameindices_change);

		eventMap.unmapListener(v.optPanel, SSEvent.BUILD, handler_build);
		eventMap.unmapListener(v.sheetPreview, SSEvent.PREVIEW_CLICK, handler_sheetPreviewClick);
		
		exitState();
	}
	
	private function handler_sheetPreviewClick($evt:SSEvent):void
	{
		dispatch($evt);
	}

	private function handler_enterState($evt:SSEvent):void
	{
		enterState();
	}
	
	private function enterState():void
	{
		if(stateModel.state != StateType.SS) return;
		//更新调整后的Sheet
		ssModel.rebuildAdjustedSheet();
		v.init(ssModel.adjustedSheet.bitmapData);
		
		mediatorMap.createMediator(v.framesAndLabels);
		mediatorMap.createMediator(v.aniPreview);
	}
	
	private function exitState():void
	{
		ssModel.destroySheet();
		v.destroy();
		
		mediatorMap.removeMediatorByView(v.framesAndLabels);
		mediatorMap.removeMediatorByView(v.aniPreview);
	}
	
	protected function handler_build($evt:SSEvent):void
	{
		dispatch(new SSEvent(SSEvent.OPTIMIZE_SHEET));
	}
	
	protected function handler_optimizeSheet($evt:SSEvent):void
	{
		optimizeSheet();
	}
	
	//在预览更新的时候，绘制帧的范围
	private function handler_previewChange($evt:SSEvent):void
	{
		if(ssModel.selectedFrameIndex<0) return;
		//仅在播放的时候才绘制帧的范围
		if(ssModel.playing)
		{
			var __rect:Rectangle = ssModel.adjustedSheet.metadata.frameRects[ssModel.selectedFrameIndex];
			v.sheetPreview.clearCanva();
			v.sheetPreview.drawRect(__rect.x, __rect.y, __rect.width, __rect.height);
		}
	}
	
	//在选择帧的时候，绘制选择的帧的范围
	private function handler_selected_frameindices_change($evt:SSEvent):void
	{
		var __frames:Vector.<FrameVO> = $evt.info as Vector.<FrameVO>;
		if(__frames && __frames.length>0)
		{
			v.sheetPreview.clearCanva();
			for (var i:int = 0; i < __frames.length; i++) 
			{
				var __rect:Rectangle = __frames[i].frameRect;
				v.sheetPreview.drawRect(__rect.x, __rect.y, __rect.width, __rect.height);
			}
		}
	}
	
	/**
	 * 根据当前的选择优化Sheet，优化的信息会被写入adjustedSheet中
	 */
	private function optimizeSheet():void
	{
		v.sheetPreview.destroy();
		var __picPref:PicPreferenceVO = v.optPanel.preference;
		if(ssModel.originalSheet.metadata.totalFrame==0 || ssModel.adjustedSheet.metadata.totalFrame==0)
		{
			Funs.alert(FxGettext.gettext("No frame info, can not generate the sheet."));
			v.leftPanelBG.enabled = false;
			return;
		}
		trace('优化帧数：', ssModel.originalSheet.metadata.totalFrame, ssModel.adjustedSheet.metadata.totalFrame);
		var __list:OptimizedResultVO = ssModel.optimize(__picPref);
		trace('新生成的：', __list.bmds, __list.frameRects, __list.originRects);
		//绘制大Sheet位图
		var __sheetBmd:BitmapData = new BitmapData(__list.bigSheetRect.width, __list.bigSheetRect.height, __picPref.transparent, __picPref.bgColor);
		ssModel.redrawAdjustedSheet(__sheetBmd, __list);
		v.sheetPreview.source = ssModel.adjustedSheet.bitmapData;
		//优化完毕，FramesAndLabel需要更新
		dispatch(new SSEvent(SSEvent.OPTIMIZE_SHEET_DONE));
	}
}
}