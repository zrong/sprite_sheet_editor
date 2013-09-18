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

import type.StateType;

import utils.Funs;
import utils.calc.FrameCalculatorManager;
import utils.calc.IFrameCalculator;

import view.panel.PicPanel;

import vo.BrowseFileDoneVO;
import vo.NamesVO;
import vo.OptimizedResultVO;

public class PicPanelMediator extends Mediator
{
	[Inject] public var v:PicPanel;
	
	[Inject] public var stateModel:StateModel;
	
	[Inject] public var fileOpener:FileOpenerModel;
	
	[Inject] public var ssModel:SpriteSheetModel;
	
	override public function onRegister():void
	{
		eventMap.mapListener(v.fileM, Event.SELECT, handler_select);
		eventMap.mapListener(v.buildSetting, SSEvent.BUILD, handler_build);
		eventMap.mapListener(eventDispatcher, SSEvent.BROWSE_FILE_DONE, handler_browseFileDone);
		
		enterState(stateModel.oldState, stateModel.state);
	}

	
	override public function onRemove():void
	{
		eventMap.unmapListener(v.fileM, Event.SELECT, handler_select);
		eventMap.unmapListener(v.buildSetting, SSEvent.BUILD, handler_build);
		eventMap.unmapListener(eventDispatcher, SSEvent.BROWSE_FILE_DONE, handler_browseFileDone);
		
		v.destory();
	}
	
	private var _result:OptimizedResultVO;
	private var _frameNum:int;				//当前正在处理的帧编号
	private var _rectInSheet:Rectangle;	//正在处理的帧在整个Sheet上的rect位置
	
	/**
	 * 在PicPanel界面中新增Pic
	 * @param	$evt
	 */
	private function handler_select($evt:Event):void
	{
		this.dispatch(new SSEvent(SSEvent.BROWSE_FILE, StateType.ADD_TO_PIC_List));
	}
	
	private function removePicLoadDone():void
	{
		v.pic.viewer.removeEventListener(Event.COMPLETE, handler_picLoadDone);
	}
	
	private function addPicLoadDone():void
	{
		v.pic.viewer.addEventListener(Event.COMPLETE, handler_picLoadDone);
	}
	
	private function handler_picLoadDone($evt:Event):void
	{
		var __rect:Rectangle = v.getCaptureFrameRect(_frameNum);
		trace('handler_picLoadDone,before:', ',frameRect:', __rect, ',rectInSheet:', _rectInSheet, ',bigSheetRect:', _result.bigSheetRect);
		var __calc:IFrameCalculator = FrameCalculatorManager.getCalculator(_result.preference.algorithm);
		__calc.picPreference = _result.preference;
		//如果没有创建过_rectInSheet，且当前是第一帧捕获，就建立第一帧在sheet中的rect位置
		if(!_rectInSheet && _frameNum==0)
		{
			
			_rectInSheet = new Rectangle(0,0,__rect.width,__rect.height);
			__calc.calculateFirstRect(__calc.picPreference.explicitSize, _result.bigSheetRect, __rect);
		}
		else
		{
			__calc.updateRectInSheet(_rectInSheet, _result.bigSheetRect, __rect, __calc.picPreference.limitWidth);
		}
		trace('handler_picLoadDone,after:', ',frameRect:', __rect, ',rectInSheet:', _rectInSheet, ',bigSheetRect:', _result.bigSheetRect);
		_result.bmds[_frameNum] = v.drawBMD(__rect);
		_result.frameRects[_frameNum] = _rectInSheet.clone();
		//向Sheet中添加这个位图，同时添加当前帧在Sheet中的位置
		//this.dispatchEvent(new SSEvent(SSEvent.ADD_FRAME, {bmd:__bmd, rect:_rectInSheet.clone()}));
		//绘制下一帧
		_frameNum ++;
		var __done:Boolean = v.drawFrame(_frameNum);
		if(__done)
		{
			try
			{
				captureDone();
			}
			catch($err:Error)
			{
				Funs.alert($err.message);
			}
		}
	}
	
	private function captureDone():void
	{
		removePicLoadDone();
		var __meta:SpriteSheetMetadata = new SpriteSheetMetadata();
		var __names:Vector.<String> = v.getNames();
		for(var i:int=0;i<_result.frameRects.length;i++)
		{
			__meta.addFrame(_result.frameRects[i], null, __names?__names[i]:null);
		}
		var __ss:SpriteSheet = new SpriteSheet(null, __meta);
		__ss.setFrames(_result.bmds);
		//根据sheet的w和h建立一个大bitmapData
		var __bmd:BitmapData = new BitmapData(_result.bigSheetRect.width, 
			_result.bigSheetRect.height, 
			_result.preference.transparent, 
			_result.preference.bgColor);
		__ss.drawSheet(__bmd); 
		
		ssModel.updateOriginalSheet(__ss);
		stateModel.state = StateType.SS;
	}
	
	private function enterState($oldState:String, $newState:String):void
	{
		trace('picPanel.updateOnStateChanged:', $oldState, $newState);
		if($newState== StateType.PIC &&
			$oldState != $newState)
		{
			v.fileM.init();
			//如果是从START状态跳转过来的，就更新一次fileList的值
			if($oldState == StateType.START)
			{
				v.fileM.setFileList(fileOpener.selectedFiles);
				//trace("从start进入pic");
				//trace("file:", file.selectedFiles.length);
				//trace("enterState.fileList:", v.fileM.fileList.length);
			}
		}
	}
	
	protected function handler_build($event:SSEvent):void
	{
		//ssModel.resetSheet(null, new SpriteSheetMetadata());
		ssModel.destroySheet();
		addPicLoadDone();
		_frameNum = 0;
		_rectInSheet = null;
		_result = null;
		_result = new OptimizedResultVO();
		_result.preference = v.preference;
		v.init();
		v.drawFrame(_frameNum);
	}
	
	private function handler_addFrame($evt:SSEvent):void
	{
		ssModel.addOriginalFrame($evt.info.bmd, $evt.info.rect);
	}
		
	private function handler_browseFileDone($evt:SSEvent):void 
	{
		var __vo:BrowseFileDoneVO = $evt.info as BrowseFileDoneVO;
		if(__vo && __vo.openState == StateType.ADD_TO_PIC_List)
		{
			v.fileM.addFile2Manager(__vo.selectedFiles);
		}
	}
}
}