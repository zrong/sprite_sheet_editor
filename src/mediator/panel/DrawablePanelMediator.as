package mediator.panel
{
import events.SSEvent;

import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Rectangle;

import model.FileOpenerModel;
import model.SpriteSheetModel;
import model.StateModel;

import org.robotlegs.mvcs.Mediator;
import org.zengrong.display.spritesheet.SpriteSheet;
import org.zengrong.display.spritesheet.SpriteSheetMetadata;
import org.zengrong.utils.BitmapUtil;

import type.StateType;

import utils.Funs;
import utils.calc.FrameCalculatorManager;
import utils.calc.IFrameCalculator;

import view.panel.DrawablePanel;

import vo.OptimizedResultVO;

/**
 * DrawablePanel的中介，SWFPanelMediator和PicPanelMediator的基类
 */
public class DrawablePanelMediator extends Mediator
{
	
	[Inject] public var stateModel:StateModel;
	[Inject] public var fileOpener:FileOpenerModel;
	[Inject] public var ssModel:SpriteSheetModel;
	
	protected var _calc:IFrameCalculator;	//使用的排序算法
	protected var _result:OptimizedResultVO;
	protected var _frameNum:int;		//当前正在处理的帧编号
	
	protected function get gv():DrawablePanel
	{
		return null;
	}
	
	override public function onRegister():void
	{
		eventMap.mapListener(gv.buildSetting, SSEvent.BUILD, handler_build);
	}
	
	override public function onRemove():void
	{
		eventMap.unmapListener(gv.buildSetting, SSEvent.BUILD, handler_build);
	}
	
	protected function handler_frameLoaded($evt:Event=null):void
	{
		
	}
	
	protected function handler_build($evt:SSEvent):void
	{
		
	}
	
	/**
	 * 将BitmapData、Rectangle填充到Result中
	 */
	protected function fillFrameInResult($frameRect:Rectangle):void
	{
		var __bmd:BitmapData = gv.drawBMD($frameRect);
		//根据设置进行修剪操作
		if(_result.preference.trim)
		{
			var __trim:Object = BitmapUtil.trimByColor(__bmd);
			//保存位图的时候，永远保存没有修剪过的版本
			//后面在绘制大sheet的时候，则会根据选择在绘制的时候进行修剪
			_result.bmds[_frameNum] = __bmd;
			_result.frameRects[_frameNum] = __trim.rect;
			var __originRect:Rectangle = $frameRect.clone();
			__originRect.x = 0 - __trim.rect.x;
			__originRect.y = 0 - __trim.rect.y;
			_result.originRects[_frameNum] = __originRect;
		}
		else
		{
			_result.bmds[_frameNum] = __bmd;
			_result.frameRects[_frameNum] = $frameRect.clone();
			_result.originRects[_frameNum] = $frameRect.clone();
		}
		if(_result.preference.scale != 1)
		{
			var __result:Object = Funs.scaleBmdAndRect(_result.preference, 
				_result.bmds[_frameNum], 
				_result.frameRects[_frameNum], 
				_result.originRects[_frameNum]);
			_result.bmds[_frameNum] = __result.bmd;
			_result.frameRects[_frameNum] = __result.rect;
			_result.originRects[_frameNum] =  __result.originRect;
		}
		//绘制下一帧
		_frameNum ++;
	}
	
	protected function capture():void
	{
		addFrameLoaded();
		_frameNum = 0;
		_result = null;
		_result = new OptimizedResultVO();
		_result.preference = gv.preference;
		_calc = FrameCalculatorManager.getCalculator(_result.preference.algorithm);
		_calc.picPreference = _result.preference;
	}
	
	protected function captureDone():void
	{
		removeFrameLoaded();
		this.dispatch(new SSEvent(SSEvent.END_PROCESS));
		//排序计算，建立一个新的OptimizedResultVO
		var __lastResult:OptimizedResultVO = _calc.optimize(_result);
		//建立metadata，填充帧名称
		var __meta:SpriteSheetMetadata = new SpriteSheetMetadata();
		for(var i:int=0;i<__lastResult.frameRects.length;i++)
		{
			__meta.addFrame(__lastResult.frameRects[i], __lastResult.originRects[i], gv.getFrameName(i));
		}
		var __ss:SpriteSheet = new SpriteSheet(null, __meta);
		__ss.setFrames(__lastResult.bmds);
		//根据sheet的w和h建立一个大bitmapData
		var __bmd:BitmapData = new BitmapData(__lastResult.bigSheetRect.width, 
			__lastResult.bigSheetRect.height, 
			__lastResult.preference.transparent, 
			__lastResult.preference.bgColor);
		__ss.drawSheet(__bmd); 
		
		ssModel.replaceOriginalSheet(__ss);
		ssModel.picPreference = _result.preference;
		stateModel.state = StateType.SS;
	}
	protected function removeFrameLoaded():void
	{
	}
	
	protected function addFrameLoaded():void
	{
	}
}
}