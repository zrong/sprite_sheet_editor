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
import vo.RectsAndBmdsVO;

public class SSPanelMediator extends Mediator
{
	[Inject] public var v:SSPanel;
	[Inject] public var stateModel:StateModel;
	[Inject] public var ssModel:SpriteSheetModel;
	
	override public function onRegister():void
	{
		addContextListener(SSEvent.ENTER_STATE, handler_enterState);
		addContextListener(SSEvent.OPTIMIZE_SHEET, handler_optimizeSheet);
		addContextListener(SSEvent.PREVIEW_SS_CHANGE, handler_displayChange);
		addContextListener(SSEvent.PREVIEW_SS_SHOW, handler_previewShow);
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
		removeContextListener(SSEvent.PREVIEW_SS_CHANGE, handler_displayChange);
		removeContextListener(SSEvent.PREVIEW_SS_SHOW, handler_previewShow);
		removeContextListener(SSEvent.SELECTED_FRAMEINDICES_CHANGE, handler_selected_frameindices_change);

		eventMap.unmapListener(v.optPanel, SSEvent.BUILD, handler_build);
		eventMap.unmapListener(v.sheetPreview, SSEvent.PREVIEW_CLICK, handler_sheetPreviewClick);
		
		exitState();
	}
	
	private function handler_sheetPreviewClick($evt:SSEvent):void
	{
		dispatch($evt);
	}

	private function handler_displayChange($evt:SSEvent):void
	{
		v.saveSeq.titleLabel.text = ssModel.displayCrop ? 
			FxGettext.gettext("trimmed size"):
			FxGettext.gettext("original size");
	}
	

	private function handler_enterState($evt:SSEvent):void
	{
		enterState();
	}
	
	private function enterState():void
	{
		if(stateModel.state != StateType.SS) return;
		//更新调整后的Sheet
		ssModel.updateAdjustedSheet();
		v.init(ssModel.adjustedSheet.bitmapData, ssModel.originalSheet.metadata.hasName);
		
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
	private function handler_previewShow($evt:SSEvent):void
	{
		//仅在播放的时候才绘制帧的范围
		if(ssModel.playing)
		{
			var __rect:Rectangle = $evt.info.rect as Rectangle;
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
		if(ssModel.originalSheet.metadata.totalFrame==0 || ssModel.adjustedSheet.metadata.totalFrame==0)
		{
			Funs.alert(FxGettext.gettext("No frame info, can not generate the sheet."));
			v.leftPanelBG.enabled = false;
			return;
		}
		trace('优化帧数：', ssModel.originalSheet.metadata.totalFrame, ssModel.adjustedSheet.metadata.totalFrame);
		var __list:RectsAndBmdsVO = ssModel.getRectsAndBmds(v.trim, v.resetRect);
		trace('新生成的：', __list.bmds, __list.frameRects, __list.originRects)
		//保存新计算出的WH
		var __whRect:Rectangle = new Rectangle();
		//保存新计算出的每个帧在大Sheet中放置的位置
		var __newFrameRects:Vector.<Rectangle> = new Vector.<Rectangle>;
		//重新计算出最终Sheet的宽高以及修改过的frameRect
		Funs.calculateSize(	
			__list.frameRects, 
			__newFrameRects, 
			__whRect,
			v.limitWidth,
			v.explicitSize,
			v.powerOf2,
			v.square
		);
		//绘制大Sheet位图
		var __sheetBmd:BitmapData = new BitmapData(__whRect.width, __whRect.height, v.transparent, v.bgColor);
		ssModel.redrawAdjustedSheet(__sheetBmd, new RectsAndBmdsVO(__list.bmds, __list.originRects, __newFrameRects));
		v.sheetPreview.source = ssModel.adjustedSheet.bitmapData;
		//优化完毕，FramesAndLabel需要更新
		dispatch(new SSEvent(SSEvent.OPTIMIZE_SHEET_DONE));
	}
}
}