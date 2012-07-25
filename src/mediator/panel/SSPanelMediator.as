package mediator.panel
{
import events.SSEvent;

import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Rectangle;

import model.FileProcessor;
import model.SpriteSheetModel;
import model.StateModel;

import org.robotlegs.mvcs.Mediator;
import org.zengrong.utils.BitmapUtil;
import org.zengrong.utils.MathUtil;

import type.StateType;

import utils.Funs;

import view.panel.SSPanel;

import vo.SaveVO;

public class SSPanelMediator extends Mediator
{
	[Inject] public var v:SSPanel;
	[Inject] public var file:FileProcessor;
	[Inject] public var stateModel:StateModel;
	[Inject] public var ssModel:SpriteSheetModel;
	
	override public function onRegister():void
	{
		addContextListener(SSEvent.ENTER_STATE, handler_enterState);
		addContextListener(SSEvent.PREVIEW_SS_RESIZE_SAVE, handler_saveResizeBTNclick);
		addContextListener(SSEvent.PREVIEW_SS_DIS_CHANGE, handler_displayChange);
		addContextListener(SSEvent.ADD_FRAME_TO_SS, handler_addFraemToSS);
		addContextListener(SSEvent.DELETE_FRAME, handler_addFraemToSS);
		
		eventMap.mapListener(v.saveSheet, SSEvent.SAVE_ALL, handler_saveAll);
		eventMap.mapListener(v.saveSheet, SSEvent.SAVE_META, handler_saveMeta);
		eventMap.mapListener(v.saveSheet, SSEvent.SAVE_PIC, handler_savePic);
		eventMap.mapListener(v.saveSeq, SSEvent.SAVE_SEQ, handler_saveSeq);
		
		if(stateModel.state == StateType.SS)
		{
			enterState();
		}
	}
	
	override public function onRemove():void
	{
		trace('remove');
		removeContextListener(SSEvent.ENTER_STATE, handler_enterState);
		removeContextListener(SSEvent.PREVIEW_SS_RESIZE_SAVE, handler_saveResizeBTNclick);
		removeContextListener(SSEvent.PREVIEW_SS_DIS_CHANGE, handler_displayChange);
		removeContextListener(SSEvent.ADD_FRAME_TO_SS, handler_addFraemToSS);
		removeContextListener(SSEvent.DELETE_FRAME, handler_addFraemToSS);
		
		eventMap.unmapListener(v.saveSheet, SSEvent.SAVE_ALL, handler_saveAll);
		eventMap.unmapListener(v.saveSheet, SSEvent.SAVE_META, handler_saveMeta);
		eventMap.unmapListener(v.saveSheet, SSEvent.SAVE_PIC, handler_savePic);
		eventMap.unmapListener(v.saveSeq, SSEvent.SAVE_SEQ, handler_saveSeq);
		
		exitState();
		
	}
	
	private function handler_displayChange($evt:SSEvent):void
	{
		v.saveSeq.title = $evt.info ? '保存序列(修剪尺寸)':'保存序列(原始尺寸)';
	}
	
	private function handler_saveAll($evt:SSEvent):void
	{
		file.save(v.getAllSave());
	}
	
	protected function handler_saveMeta($event:SSEvent):void
	{
		file.save(v.getMetaSave());
	}
	
	protected function handler_savePic($event:SSEvent):void
	{
		file.save(v.getPicSave());
	}
	
	private function handler_saveSeq($evt:SSEvent):void
	{
		var __vo:SaveVO = v.getSeqSave();
		//根据显示的帧类型来保存序列
		__vo.bitmapDataList = ssModel.getBMDList();
		file.save(__vo);
	}

	private function handler_enterState($evt:SSEvent):void
	{
		if(stateModel.state == StateType.SS)
		{
			enterState();
		}
	}
	
	private function handler_addFraemToSS($evt:SSEvent):void
	{
		optimizeSheet();
	}
	
	private function enterState():void
	{
		//更新调整后的Sheet
		ssModel.adjustedSheet = ssModel.sheet.clone();
		v.sheet.source = ssModel.adjustedSheet.bitmapData;
		//sheet的name是在编辑器的图像文件处理状态中被加入的，如果没有经历过图像文件处理状态，则hasName为false
		//这里根据是否拥有name，来显示(选择)或者隐藏(不选择)nameCB，从而影响最终生成的Metadata中的name的值
		v.saveSheet.nameCB.visible = ssModel.sheet.metadata.hasName;
		v.saveSheet.nameCB.selected =ssModel.sheet.metadata.hasName;
		v.leftPanelBG.enabled = true;
		v.init();
	}
	
	private function exitState():void
	{
		ssModel.sheet.destroy();
		ssModel.sheet = null;
		ssModel.adjustedSheet.destroy();
		ssModel.adjustedSheet = null;
		v.destroy();
	}
	
	protected function handler_saveResizeBTNclick($evt:SSEvent):void
	{
		v.framesAndLabels.resizeFrames(ssModel.resizeRect);
		optimizeSheet();
		//ani.destroy();
	}
	
	/**
	 * 根据当前的选择优化Sheet，优化的信息会被写入adjustedSheet中
	 */
	public function optimizeSheet():void
	{
		v.ssPreview.destory();
		v.sheet.destroy();
		if(ssModel.sheet.metadata.totalFrame==0 || ssModel.adjustedSheet.metadata.totalFrame==0)
		{
			Funs.alert('没有帧的信息，不能生成Sheet。');
			v.leftPanelBG.enabled = false;
			return;
		}
		trace('优化帧数：', ssModel.sheet.metadata.totalFrame, ssModel.adjustedSheet.metadata.totalFrame);
		var __list:Object = getRectsAndBmds();
		trace('新生成的：', __list.bmd, __list.frame, __list.origin)
		//保存新计算出的WH
		var __whRect:Rectangle = new Rectangle();
		//保存新计算出的每个帧在大Sheet中放置的位置
		var __newFrameRects:Vector.<Rectangle> = new Vector.<Rectangle>;
		//重新计算出最终Sheet的宽高以及修改过的frameRect
		calculateSize(	
			__list.frame, 
			__newFrameRects, 
			__whRect,
			v.optPanel.whDDL.selectedIndex == 0, 
			v.optPanel.whNS.value,
			v.optPanel.powerOf2CB.selected,
			v.optPanel.squareCB.selected
		);
		ssModel.adjustedSheet.setFrames(__list.bmd, __newFrameRects, __list.origin, ssModel.sheet.metadata.names);
		//绘制大Sheet位图
		var __sheetBmd:BitmapData = new BitmapData(__whRect.width, __whRect.height, v.optPanel.transparentCB.selected, v.optPanel.bgColorPicker.selectedColor);
		ssModel.adjustedSheet.drawSheet(__sheetBmd);
		v.sheet.source = ssModel.adjustedSheet.bitmapData;
		//显示优化过的Frame
		v.ssPreview.disFrame = true;
	}
	
	/**
	 * 返回生成的原始帧rect尺寸（origin），在大sheet中的rect尺寸（frame），以及所有的BitmapData列表（bmd）
	 */
	private function getRectsAndBmds():Object
	{
		//所有的BitmapData列表
		var __bmd:Vector.<BitmapData> = null;
		//在大sheet中的rect列表
		var __frame:Vector.<Rectangle> = null;
		//原始的（在程序中使用的）rect列表
		var __origin:Vector.<Rectangle> = null; 
		if(v.optPanel.trimCB.selected)
		{
			__bmd = new Vector.<BitmapData>;
			__frame = new Vector.<Rectangle>;
			__origin = new Vector.<Rectangle>; 
			var __sizeRect:Rectangle = null;
			//用于保存执行trim方法后的结果
			var __trim:Object = null;
			for (var i:int=0; i < ssModel.sheet.metadata.totalFrame; i++) 
			{
				__trim = BitmapUtil.trim(ssModel.sheet.getBMDByIndex(i));
				__sizeRect = ssModel.sheet.metadata.originalFrameRects[i];
				__frame[i] = __trim.rect;
				//如果重设帧的尺寸，就使用trim过后的帧的宽高建立一个新的Rect尺寸，并更新bmd
				if(v.optPanel.resetRectCB.selected)
				{
					__origin[i] = new Rectangle(0,0,__trim.rect.width,__trim.rect.height);
					__bmd[i] = __trim.bitmapData;
				}
				else
				{
					//如果不重设帧的尺寸，就使用原始大小的宽高。同时计算trim后的xy的偏移。
					//因为获得xy的偏移是基于与原始帧大小的正数，要将其转换为基于trim后的帧的偏移，用0减
					//不重设尺寸的情况下，不更新bmd，因为原始尺寸没变。SpriteSheet中保存的bmdList，永远都与原始尺寸相同
					__bmd = ssModel.sheet.cloneFrames();
					__origin[i] = new Rectangle(
						0-__trim.rect.x,
						0-__trim.rect.y,
						__sizeRect.width, 
						__sizeRect.height);
				}
			}
		}
		else
		{
			//bmdlist永远都是原始尺寸的，因此不需要重新绘制
			__bmd = ssModel.sheet.cloneFrames();
			__frame = ssModel.sheet.metadata.frameRects.concat();
			__origin = ssModel.sheet.metadata.originalFrameRects.concat();
			//不trim，将以前trim过的信息还原
			for (var j:int = 0; j < __frame.length; j++) 
			{
				__frame[j].width = __origin[j].width;
				__frame[j].height = __origin[j].height;
				__origin[j].x = 0;
				__origin[j].y = 0;
			}
		}
		return {frame:__frame, origin:__origin, bmd:__bmd}
	}
	
	
	
	/**
	 * 根据提供的Rectangle数组计算最终Sheet的宽高以及每帧在Sheet中的位置
	 * @param $frameRect 当前帧的独立大小
	 */
	private function calculateSize($frameRects:Vector.<Rectangle>, 
								   $newSizeRects:Vector.<Rectangle>,
								   $whRect:Rectangle, 
								   $limitW:Boolean, 
								   $wh:int,
								   $powOf2:Boolean=false,
								   $square:Boolean=false):void
	{
		if($frameRects.length==0) return;
		var __frameRect:Rectangle = $frameRects[0];
		$newSizeRects[0] = new Rectangle(0,0,__frameRect.width, __frameRect.height);
		var __rectInSheet:Rectangle = new Rectangle(0,0,__frameRect.width,__frameRect.height);
		trace('getSheetWH:', __rectInSheet, __frameRect, $whRect);
		//设置sheet的初始宽高
		if($limitW)
		{
			//若限制宽度小于帧的宽度，就扩大限制宽度
			$whRect.width = $wh;
			if($whRect.width<__frameRect.width) $whRect.width = __frameRect.width;
			//计算2的幂
			if($powOf2) $whRect.width = MathUtil.nextPowerOf2($whRect.width);
			$whRect.height = __frameRect.height;
		}
		else
		{
			$whRect.height = $wh;
			if($whRect.height<__frameRect.height) $whRect.height = __frameRect.height;
			if($powOf2) $whRect.height = MathUtil.nextPowerOf2($whRect.height);
			$whRect.width = __frameRect.width;
		}
		for (var i:int = 1; i < $frameRects.length; i++) 
		{
			__frameRect = $frameRects[i];
			Funs.updateRectInSheet(__rectInSheet, $whRect, __frameRect, $limitW);
			trace('getSheetWH:', __rectInSheet, __frameRect, $whRect);
			$newSizeRects[i] = __rectInSheet.clone();
		}
		if($square)
		{
			//计算正方形的尺寸
			if($whRect.width!=$whRect.height)
			{
				//使用当前计算出的面积开方得到正方形的基准尺寸
				var __newWH:int = Math.sqrt($whRect.width*$whRect.height);
				//使用基准尺寸重新排列一次
				calculateSize($frameRects,$newSizeRects,$whRect,$limitW,__newWH, $powOf2);
				//trace('正方形计算1:', $whRect);
				//如果基准尺寸无法实现正方形尺寸，就使用结果WH中比较大的那个尺寸作为正方形边长
				if($whRect.width!=$whRect.height)
				{
					var __max:int = Math.max($whRect.width, $whRect.height);
					$whRect.width = __max;
					$whRect.height = __max;
				}
				//trace('正方形计算2:', $whRect);
			}
		}
		if($powOf2)
		{
			$whRect.width = MathUtil.nextPowerOf2($whRect.width);
			$whRect.height = MathUtil.nextPowerOf2($whRect.height);
		}
	}
	
}
}