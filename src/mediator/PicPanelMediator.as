package mediator
{
import events.SSEvent;

import flash.events.Event;

import model.FileProcessor;
import model.StateModel;

import org.robotlegs.mvcs.Mediator;

import type.StateType;

import view.panel.PicPanel;

public class PicPanelMediator extends Mediator
{
	[Inject] public var v:PicPanel;
	
	[Inject] public var stateModel:StateModel;
	
	[Inject] public var file:FileProcessor;
	
	override public function onRegister():void
	{
		addViewListener(Event.COMPLETE, handler_captureDone);
		eventMap.mapListener(v.fileM, Event.SELECT, handler_select);
		
		eventMap.mapListener(eventDispatcher, SSEvent.ENTER_STATE, handler_enterState);
		eventMap.mapListener(eventDispatcher, SSEvent.EXIT_STATE, handler_exitState);
		if(stateModel.state == StateType.PIC)
		{
			enterState(stateModel.oldState, stateModel.state);
		}
	}
	
	private function handler_select($evt:Event):void
	{
		file.openPics(v.fileM.fun_addFile);
	}
	
	private function handler_captureDone($evt:Event):void
	{
		stateModel.state = StateType.SS;
	}
	
	public function enterState($oldState:String, $newState:String):void
	{
		trace('picPanel.updateOnStateChanged:', $oldState, $newState);
		//如果是从START状态跳转过来的，就更新一次fileList的值
		if($oldState == StateType.START)
			v.fileM.setFileList(file.selectedFiles);
		v.pic.transf.init();
		v.fileM.init();
	}
	
	public function handler_enterState($evt:SSEvent):void
	{
		enterState($evt.info.oldState,$evt.info.newState);
	}
	
	public function handler_exitState($evt:SSEvent):void
	{
		v.pic.viewer.source = null;
		v.pic.transf.destroy();
	}
}
}