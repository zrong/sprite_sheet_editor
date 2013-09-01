package mediator.panel
{
import events.SSEvent;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import view.comps.ExportWindow;

import flash.events.Event;
import flash.events.MouseEvent;

import model.StateModel;

import org.robotlegs.mvcs.Mediator;
import org.zengrong.utils.SOUtil;

import type.StateType;

import view.panel.TopPanel;

public class TopPanelMediator extends Mediator
{
	[Inject] public var v:TopPanel;
	
	[Inject] public var stateModel:StateModel;
	
	private var _prevState:String;

	private var _so:SOUtil;
	
	override public function onRegister():void
	{
		eventMap.mapListener(v.prevBTN, MouseEvent.CLICK, handler_prievBTNClick);
		eventMap.mapListener(v.fpsNS, Event.CHANGE, handler_fpsNSChange);
		eventMap.mapListener(v.exportBTN, MouseEvent.CLICK, handler_exportClick);
		
		eventMap.mapListener(eventDispatcher, SSEvent.ENTER_STATE, handler_enterState);
		
		_so = SOUtil.getSOUtil('sse');
		showFPS();
	}	

	private var _exportWindow:ExportWindow;

	private function handler_exportClick($evt:MouseEvent):void
	{
		if(_exportWindow)
		{
			PopUpManager.addPopUp(_exportWindow, v.root);
			PopUpManager.centerPopUp(_exportWindow);
		}
		else
		{
			_exportWindow = PopUpManager.createPopUp(v.root, ExportWindow, true) as ExportWindow;
			PopUpManager.centerPopUp(_exportWindow);
			_exportWindow.addEventListener(CloseEvent.CLOSE, destroyExportWindow);
		}
		if(!mediatorMap.hasMediatorForView(_exportWindow)) mediatorMap.createMediator(_exportWindow);
	}

	private function destroyExportWindow($evt:CloseEvent=null):void
	{
		if(_exportWindow)
		{
			PopUpManager.removePopUp(_exportWindow);
			mediatorMap.removeMediatorByView(_exportWindow);
		}
	}
	
	private function handler_enterState($evt:SSEvent):void
	{
		enterState($evt.info.oldState, $evt.info.newState);
	}
	
	private function showFPS():void
	{
		v.fpsLabel.visible = (stateModel.state != StateType.START);
		v.fpsNS.visible = v.fpsLabel.visible;
		var __frameRate:int = int(_so.get('frameRate'));
		if(__frameRate > 0)
		{
			v.fpsNS.value = __frameRate;
			v.stage.frameRate = v.fpsNS.value;
		}
	}
	
	private function showExport():void
	{
		v.exportBTN.visible =  (stateModel.state == StateType.SS);
	}
	
	private function enterState($oldState:String, $newState:String):void
	{
		if(!$oldState && !$newState) return;
		v.stateNameLabel.text = StateType.toMainStateName($newState);
		if($newState == StateType.START)
		{
			_prevState = null;
		}
		else
		{
			_prevState = $oldState;
			//如果状态是反向跳转（从后一步跳转到前一步），那么就将返回按钮指向第一步
			if( ($newState == StateType.PIC || $newState == StateType.SWF) &&
				($oldState != StateType.START) )
				_prevState = StateType.START;
		}
		trace(_prevState);
		v.prevBTN.enabled = (_prevState != null);
		showFPS();
		showExport();
	}
	
	protected function handler_fpsNSChange(event:Event):void
	{
		v.stage.frameRate = v.fpsNS.value;
		_so.save(v.fpsNS.value, 'frameRate');
	}
	
	protected function handler_prievBTNClick(event:MouseEvent):void
	{
		stateModel.state = _prevState;
	}
}
}