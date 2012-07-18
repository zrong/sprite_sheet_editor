package mediator
{
import events.SSEvent;

import flash.events.Event;

import model.FileProcessor;

import org.robotlegs.mvcs.Mediator;

import view.panel.SSPanel;

public class SSPanelMediator extends Mediator
{
	[Inject] public var v:SSPanel;
	[Inject] public var file:FileProcessor;
	
	override public function onRegister():void
	{
		eventMap.mapListener(eventDispatcher, SSEvent.ENTER_STATE, handler_enterState);
		eventMap.mapListener(eventDispatcher, SSEvent.EXIT_STATE, handler_exitState);
		
		eventMap.mapListener(v.framesAndLabels, Event.SELECT, handler_addToSS);
		eventMap.mapListener(v.saveSheet, SSEvent.SAVE_ALL, handler_saveAll);
		eventMap.mapListener(v.saveSheet, SSEvent.SAVE_META, handler_saveMeta);
		eventMap.mapListener(v.saveSheet, SSEvent.SAVE_PIC, handler_savePic);
		eventMap.mapListener(v.saveSeq, SSEvent.SAVE_SEQ, handler_saveSeq);
	}
	
	private function handler_saveAll($evt:SSEvent):void
	{
		var __data:Object = v.getAllData();		
		file.saveAll(__data.data, __data.ext);
	}
	
	protected function handler_saveMeta($event:SSEvent):void
	{
		var __data:Object = v.getMeta();
		file.saveMeta(__data.meta, __data.type);
	}
	
	protected function handler_savePic($event:SSEvent):void
	{
		var __data:Object = v.getPicData();
		file.saveSS(__data.bmd, __data.type, __data.quality);
	}
	
	private function handler_saveSeq($evt:SSEvent):void
	{
		var __data:Object = v.getSeqData();
		file.saveSeq(__data.bmds, __data.names, __data.quality);
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