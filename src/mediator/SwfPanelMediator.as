package mediator
{
import events.SSEvent;

import flash.events.Event;
import flash.filesystem.File;

import model.FileProcessor;
import model.StateModel;

import org.robotlegs.mvcs.Mediator;

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
	
	private var _swfURL:String;
	
	override public function onRegister():void
	{
		addViewListener(Event.COMPLETE, handler_captureDone);
		eventMap.mapListener(v.buildSetting, SSEvent.BUILD, handler_buildClick);
		
		addContextListener(SSEvent.ENTER_STATE, handler_enterState);
		enterState(stateModel.oldState, stateModel.state);
	}
	
	override public function onRemove():void
	{
		removeViewListener(Event.COMPLETE, handler_captureDone);
		eventMap.unmapListener(v.buildSetting, SSEvent.BUILD, handler_buildClick);
		
		removeContextListener(SSEvent.ENTER_STATE, handler_enterState);
		
		v.destroy();
	}
	
	private function handler_captureDone($evt:Event):void
	{
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
			if(_swfURL) v.showSWF(_swfURL);
		}
	}
	
	private function handler_buildClick($evt:SSEvent):void
	{
		v.build(_swfURL);
	}
}
}