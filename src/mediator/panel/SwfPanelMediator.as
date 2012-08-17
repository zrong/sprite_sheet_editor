package mediator.panel
{
import events.SSEvent;

import flash.events.Event;
import flash.filesystem.File;

import model.FileProcessor;
import model.SpriteSheetModel;
import model.StateModel;

import org.robotlegs.mvcs.Mediator;
import org.zengrong.display.spritesheet.SpriteSheetMetadata;

import type.StateType;

import view.panel.SwfPanel;

/**
 * @author zrong
 * 创建日期：2012-07-18
 */
public class SwfPanelMediator extends Mediator
{
	[Inject] public var v:SwfPanel;
	
	[Inject] public var stateModel:StateModel;
	
	[Inject] public var file:FileProcessor;
	
	[Inject] public var ssModel:SpriteSheetModel;
	
	private var _swfURL:String;
	
	override public function onRegister():void
	{
		addViewListener(SSEvent.CAPTURE_DONE, handler_captureDone);
		addViewListener(SSEvent.ADD_FRAME, handler_addFrame);
		eventMap.mapListener(v.buildSetting, SSEvent.BUILD, handler_buildClick);
		
		addContextListener(SSEvent.ENTER_STATE, handler_enterState);
		
		enterState(stateModel.oldState, stateModel.state);
	}
	
	override public function onRemove():void
	{
		removeViewListener(SSEvent.CAPTURE_DONE, handler_captureDone);
		removeViewListener(SSEvent.ADD_FRAME, handler_addFrame);
		eventMap.unmapListener(v.buildSetting, SSEvent.BUILD, handler_buildClick);
		
		removeContextListener(SSEvent.ENTER_STATE, handler_enterState);
		
		v.destroy();
		v.swf.removeEventListener(SSEvent.PREVIEW_LOAD_COMPLETE, handler_swfLoadDone);
	}
	
	private function handler_captureDone($evt:SSEvent):void
	{
		v.state = StateType.LOAD_DONE;
		ssModel.drawOriginalSheet($evt.info);
		stateModel.state = StateType.SS;
	}
	
	private function handler_enterState($evt:SSEvent):void
	{
		enterState($evt.info.oldState, $evt.info.newState);
	}
	
	private function enterState($oldState:String, $newState:String):void
	{
		if($newState == StateType.SWF)
		{
			_swfURL = File(file.selectedFiles[0]).url;
			trace('swfPanel.load:', _swfURL);
			if(_swfURL)
			{
				v.swf.addEventListener(SSEvent.PREVIEW_LOAD_COMPLETE, handler_swfLoadDone);
				v.showSWF(_swfURL);
			}
		}
	}
	
	private function handler_swfLoadDone(event:SSEvent) : void
	{
		//若当前处于等待载入状态，则开始建立sheet
		if(v.state == StateType.WAIT_LOADED)
		{
			//开始capture
			v.state = StateType.PROCESSING;
			ssModel.resetSheet(null, new SpriteSheetMetadata());
			v.capture();
		}
		else
		{
			v.state = StateType.LOAD_DONE;
		}
	}
	
	private function handler_buildClick($evt:SSEvent):void
	{
		v.state = StateType.WAIT_LOADED;
		v.build(_swfURL);
	}
	
	private function handler_addFrame($evt:SSEvent):void
	{
		ssModel.addOriginalFrame($evt.info.bmd, $evt.info.rect);
	}
}
}