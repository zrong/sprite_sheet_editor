package mediator.panel
{
import events.SSEvent;

import flash.events.Event;
import flash.geom.Rectangle;

import type.StateType;

import utils.Funs;
import utils.calc.FrameCalculatorManager;

import view.panel.DrawablePanel;
import view.panel.PicPanel;

import vo.BrowseFileDoneVO;
import vo.OptimizedResultVO;

public class PicPanelMediator extends DrawablePanelMediator
{
	[Inject] public var v:PicPanel;
	
	override protected function get gv():DrawablePanel
	{
		return v;
	}
	
	override public function onRegister():void
	{
		super.onRegister();
		eventMap.mapListener(v.fileM, Event.SELECT, handler_select);
		eventMap.mapListener(eventDispatcher, SSEvent.BROWSE_FILE_DONE, handler_browseFileDone);
		
		enterState(stateModel.oldState, stateModel.state);
	}

	
	override public function onRemove():void
	{
		super.onRemove();
		eventMap.unmapListener(v.fileM, Event.SELECT, handler_select);
		eventMap.unmapListener(eventDispatcher, SSEvent.BROWSE_FILE_DONE, handler_browseFileDone);
		
		v.destory();
	}
	
	/**
	 * 在PicPanel界面中新增Pic
	 * @param	$evt
	 */
	private function handler_select($evt:Event):void
	{
		this.dispatch(new SSEvent(SSEvent.BROWSE_FILE, StateType.ADD_TO_PIC_List));
	}
	
	override protected function removeFrameLoaded():void
	{
		v.preview.viewer.removeEventListener(Event.COMPLETE, handler_frameLoaded);
	}
	
	override protected function addFrameLoaded():void
	{
		v.preview.viewer.addEventListener(Event.COMPLETE, handler_frameLoaded);
	}
	
	override protected function handler_frameLoaded($evt:Event=null):void
	{
		this.dispatch(new SSEvent(SSEvent.PROCESS, {current:_frameNum, total:v.totalFrame}));
		var __rect:Rectangle = v.getCaptureFrameRect(_frameNum);
		//记录BitmapData和它们的尺寸
		fillFrameInResult(__rect);
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
	
	override protected function capture():void
	{
		super.capture();
		v.init();
		v.drawFrame(_frameNum);
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
	
	override protected function handler_build($event:SSEvent):void
	{
		ssModel.destroySheet();
		this.dispatch(new SSEvent(SSEvent.CREATE_PROCESS, "Capturing"));
		capture();
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