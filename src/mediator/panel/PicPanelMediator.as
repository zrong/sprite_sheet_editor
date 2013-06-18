package mediator.panel
{
import events.SSEvent;

import flash.events.Event;

import model.FileProcessor;
import model.SpriteSheetModel;
import model.StateModel;

import org.robotlegs.mvcs.Mediator;
import org.zengrong.display.spritesheet.SpriteSheetMetadata;

import type.StateType;

import view.panel.PicPanel;

import vo.NamesVO;

public class PicPanelMediator extends Mediator
{
	[Inject] public var v:PicPanel;
	
	[Inject] public var stateModel:StateModel;
	
	[Inject] public var file:FileProcessor;
	
	[Inject] public var ssModel:SpriteSheetModel;
	
	override public function onRegister():void
	{
		addViewListener(SSEvent.CAPTURE_DONE, handler_captureDone);
		addViewListener(SSEvent.ADD_FRAME, handler_addFrame);
		eventMap.mapListener(v.fileM, Event.SELECT, handler_select);
		eventMap.mapListener(v.buildSetting, SSEvent.BUILD, handler_build);
		
		eventMap.mapListener(eventDispatcher, SSEvent.ENTER_STATE, handler_enterState);
		if(stateModel.state == StateType.PIC)
		{
			enterState(stateModel.oldState, stateModel.state);
		}
	}
	
	override public function onRemove():void
	{
		removeViewListener(SSEvent.CAPTURE_DONE, handler_captureDone);
		removeViewListener(SSEvent.ADD_FRAME, handler_addFrame);
		eventMap.unmapListener(v.fileM, Event.SELECT, handler_select);
		eventMap.unmapListener(v.buildSetting, SSEvent.BUILD, handler_build);
		
		eventMap.unmapListener(eventDispatcher, SSEvent.ENTER_STATE, handler_enterState);
		v.pic.viewer.source = null;
		v.pic.transf.destroy();
	}
	
	private function handler_select($evt:Event):void
	{
		file.openPics(v.fileM.fun_addFile);
	}
	
	private function handler_captureDone($evt:SSEvent):void
	{
		ssModel.drawOriginalSheet($evt.info.bmd);
		var __namesVO:NamesVO = $evt.info.updateNames as NamesVO;
		if(__namesVO)
		{
			ssModel.originalSheet.metadata.hasName = __namesVO.hasName;
			ssModel.originalSheet.metadata.names = __namesVO.names;
			ssModel.originalSheet.metadata.namesIndex = __namesVO.namesIndex;
		}
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
	
	protected function handler_build($event:SSEvent):void
	{
		ssModel.resetSheet(null, new SpriteSheetMetadata());
		v.capture();
	}
	
	private function handler_addFrame($evt:SSEvent):void
	{
		ssModel.addOriginalFrame($evt.info.bmd, $evt.info.rect);
	}	
}
}