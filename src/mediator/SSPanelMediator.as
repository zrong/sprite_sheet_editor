package mediator
{
import events.SSEvent;

import flash.events.Event;

import model.FileProcessor;
import model.StateModel;

import org.robotlegs.mvcs.Mediator;

import type.StateType;

import view.panel.SSPanel;

public class SSPanelMediator extends Mediator
{
	[Inject] public var v:SSPanel;
	[Inject] public var file:FileProcessor;
	[Inject] public var stateModel:StateModel;
	
	override public function onRegister():void
	{
		eventMap.mapListener(eventDispatcher, SSEvent.ENTER_STATE, handler_enterState);
		eventMap.mapListener(eventDispatcher, SSEvent.EXIT_STATE, handler_exitState);
		
		eventMap.mapListener(v.framesAndLabels, Event.SELECT, handler_addToSS);
		eventMap.mapListener(v.saveSheet, SSEvent.SAVE_ALL, handler_saveAll);
		eventMap.mapListener(v.saveSheet, SSEvent.SAVE_META, handler_saveMeta);
		eventMap.mapListener(v.saveSheet, SSEvent.SAVE_PIC, handler_savePic);
		eventMap.mapListener(v.saveSeq, SSEvent.SAVE_SEQ, handler_saveSeq);
		
		if(stateModel.state == StateType.SS)
		{
			v.enterState(stateModel.oldState, stateModel.state);
		}
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
		file.save(v.getSeqSave());
	}

	private function handler_addToSS($evt:Event):void
	{
		file.addToSS(v.framesAndLabels.fun_addToSS);
	}
	
	private function handler_enterState($evt:SSEvent):void
	{
		v.enterState($evt.info.oldState, $evt.info.newState);
	}
	
	private function handler_exitState():void
	{
		v.exitState();
	}
}
}