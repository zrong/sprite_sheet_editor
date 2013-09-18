package mediator.panel
{
import gnu.as3.gettext.FxGettext;
import events.SSEvent;

import flash.display.BitmapData;
import flash.events.Event;
import flash.filesystem.File;
import flash.geom.Rectangle;

import model.FileOpenerModel;
import model.SpriteSheetModel;
import model.StateModel;

import org.robotlegs.mvcs.Mediator;
import org.zengrong.display.spritesheet.SpriteSheet;
import org.zengrong.display.spritesheet.SpriteSheetMetadata;

import type.StateType;

import utils.calc.FrameCalculatorManager;
import utils.calc.IFrameCalculator;

import view.panel.SwfPanel;

import vo.OptimizedResultVO;

/**
 * @author zrong
 * 创建日期：2012-07-18
 */
public class SwfPanelMediator extends Mediator
{
	[Inject] public var v:SwfPanel;
	
	[Inject] public var stateModel:StateModel;
	
	[Inject] public var fileOpener:FileOpenerModel;
	
	[Inject] public var ssModel:SpriteSheetModel;
	
	override public function onRegister():void
	{
		eventMap.mapListener(v.buildSetting, SSEvent.BUILD, handler_buildClick);
		
		addContextListener(SSEvent.ENTER_STATE, handler_enterState);
		
		enterState(stateModel.oldState, stateModel.state);
	}
	
	override public function onRemove():void
	{
		eventMap.unmapListener(v.buildSetting, SSEvent.BUILD, handler_buildClick);
		
		removeContextListener(SSEvent.ENTER_STATE, handler_enterState);
		
		v.destroy();
		v.preview.removeEventListener(SSEvent.PREVIEW_LOAD_COMPLETE, handler_swfLoadDone);
	}
	
	
	private var _swfURL:String;
	
	private var _swfContentX:int = 0;
	private var _swfContentY:int = 0;
	
	private var _result:OptimizedResultVO;
	private var _frameNum:int;				//当前正在处理的帧编号，这个帧编号就是swf文件时间轴上的帧编号，可能不是从0开始（例如从第10帧开始捕获）
	private var _frameIndex:int;			//当前正在处理的帧索引，与frameNum不同，这个索引是帧在SpriteSheet数组中的索引，一定从0开始
	private var _rectInSheet:Rectangle;	//正在处理的帧在整个Sheet上的rect位置
	private var _calc:IFrameCalculator;	//使用的排序算法
	
	//正在处理的帧自身的尺寸，使用getFrameRect读取
	//与PicPanelMediator不同的是，后者每帧都可能不同（因为可能自行设置过），而前者每帧都相同，因此不需要每次都更新
	//正因为如此，将起作为成员保存
	private var _frameRect:Rectangle;
	
	private function addFrameLoaded():void
	{
		v.addEventListener(Event.EXIT_FRAME, handler_frameLoaded);
	}
	
	private function removeFrameLoaded():void
	{
		v.removeEventListener(Event.EXIT_FRAME, handler_frameLoaded);
	}
	
	private function capture():void
	{
		trace('swf capture');
		addFrameLoaded();
		//帧编号永远从0开始，无论正在播放的主时间轴有几帧（可能只有1帧，使用MC做动画），也可以实现多帧捕获
		_frameNum = 0;
		//帧索引当然是从0开始了
		_frameIndex = 0;
		_rectInSheet = null;
		_result = null;
		_frameRect = null;
		_result = new OptimizedResultVO();
		_result.preference = v.preference;
		_calc = FrameCalculatorManager.getCalculator(_result.preference.algorithm);
		_calc.picPreference = _result.preference;
		handler_frameLoaded();
	}
	
	private function captureDone():void
	{
		removeFrameLoaded();
		this.dispatch(new SSEvent(SSEvent.END_PROCESS));
		var __meta:SpriteSheetMetadata = new SpriteSheetMetadata();
		for(var i:int=0;i<_result.frameRects.length;i++)
		{
			__meta.addFrame(_result.frameRects[i], null, "frame"+i);
		}
		var __ss:SpriteSheet = new SpriteSheet(null, __meta);
		__ss.setFrames(_result.bmds);
		//根据sheet的w和h建立一个大bitmapData
		var __bmd:BitmapData = new BitmapData(_result.bigSheetRect.width, 
			_result.bigSheetRect.height, 
			_result.preference.transparent, 
			_result.preference.bgColor);
		__ss.drawSheet(__bmd); 
		
		v.state = StateType.LOAD_DONE;
		ssModel.replaceOriginalSheet(__ss);
		stateModel.state = StateType.SS;
	}
	
	/**
	 * 绘制一帧，并判断所有帧绘制是否完成
	 */
	private function handler_frameLoaded($evt:Event=null):void
	{
		//当前帧进行到需要绘制的时候，就开始绘制
		if (_frameNum++ >= v.firstFrame)
		{
			this.dispatch(
				new SSEvent(SSEvent.PROCESS,
					{current:_frameIndex, total:v.totalFrame, label:FxGettext.gettext("Capturing")}
				));
			trace('drawing frame:', _frameNum-1);
			//如果没有设置_rectInSheet，应该是截取第一帧，这种情况下初始化rectInSheet、frameRect和whRect
			if(!_rectInSheet)
			{
				_frameRect = v.getFrameRect();
				_rectInSheet = new Rectangle(_result.preference.borderPadding, _result.preference.borderPadding, _frameRect.width, _frameRect.height);
				_calc.calculateFirstRect(_result.bigSheetRect, _frameRect, _calc.picPreference.explicitSize);
			}
			else
			{
				_calc.updateRectInSheet(_rectInSheet, _result.bigSheetRect, _frameRect, _calc.picPreference.limitWidth);
			}
			_result.bmds[_frameIndex] = v.drawBMD(_frameRect);
			_result.frameRects[_frameIndex] = _rectInSheet.clone();
			_frameIndex ++;
		}
		else
		{
			this.dispatch(
				new SSEvent(SSEvent.PROCESS, 
				{current:_frameNum, total:v.firstFrame, label:FxGettext.gettext("Waiting for swf playing")}
			));
		}
		//所有帧捕获完毕
		if (_frameNum - v.firstFrame >= v.totalFrame)
		{
			captureDone();
		}
	}
	
	private function handler_enterState($evt:SSEvent):void
	{
		enterState($evt.info.oldState, $evt.info.newState);
	}
	
	private function enterState($oldState:String, $newState:String):void
	{
		if($newState == StateType.SWF)
		{
			_swfURL = File(fileOpener.selectedFiles[0]).url;
			trace('swfPanel.load:', _swfURL);
			if(_swfURL)
			{
				v.preview.addEventListener(SSEvent.PREVIEW_LOAD_COMPLETE, handler_swfLoadDone);
				v.showSWF(_swfURL);
			}
		}
	}
	
	private function handler_swfLoadDone(event:SSEvent) : void
	{
		//若当前处于等待载入状态，则开始建立sheet
		if(v.state == StateType.WAIT_LOADED)
		{
			//如果允许调整尺寸，使用调整过的
			if(v.preview.enableDragContent)
				v.preview.moveContent(_swfContentX, _swfContentY);
			//开始capture
			v.state = StateType.PROCESSING;
			ssModel.resetSheet(null, new SpriteSheetMetadata());
			capture();
		}
		else
		{
			v.state = StateType.LOAD_DONE;
		}
	}
	
	private function handler_buildClick($evt:SSEvent):void
	{
		v.state = StateType.WAIT_LOADED;
		//记录当前移动的内容坐标，以便载入成功后还原
		_swfContentX = v.preview.contentX;
		_swfContentY = v.preview.contentY;
		v.build(_swfURL);
		this.dispatch(new SSEvent(SSEvent.CREATE_PROCESS, FxGettext.gettext("Loading swf file")));
	}
}
}