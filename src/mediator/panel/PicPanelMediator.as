package mediator.panel
{
import events.SSEvent;
import flash.events.Event;
import model.FileOpenerModel;
import model.SpriteSheetModel;
import model.StateModel;
import org.robotlegs.mvcs.Mediator;
import org.zengrong.display.spritesheet.SpriteSheetMetadata;
import type.StateType;
import view.panel.PicPanel;
import vo.BrowseFileDoneVO;
import vo.NamesVO;

public class PicPanelMediator extends Mediator
{
	[Inject] public var v:PicPanel;
	
	[Inject] public var stateModel:StateModel;
	
	[Inject] public var fileOpener:FileOpenerModel;
	
	[Inject] public var ssModel:SpriteSheetModel;
	
	override public function onRegister():void
	{
		addViewListener(SSEvent.CAPTURE_DONE, handler_captureDone);
		addViewListener(SSEvent.ADD_FRAME, handler_addFrame);
		eventMap.mapListener(v.fileM, Event.SELECT, handler_select);
		eventMap.mapListener(v.buildSetting, SSEvent.BUILD, handler_build);
		eventMap.mapListener(eventDispatcher, SSEvent.BROWSE_FILE_DONE, handler_browseFileDone);
		
		enterState(stateModel.oldState, stateModel.state);
	}

	
	override public function onRemove():void
	{
		removeViewListener(SSEvent.CAPTURE_DONE, handler_captureDone);
		removeViewListener(SSEvent.ADD_FRAME, handler_addFrame);
		eventMap.unmapListener(v.fileM, Event.SELECT, handler_select);
		eventMap.unmapListener(v.buildSetting, SSEvent.BUILD, handler_build);
		eventMap.unmapListener(eventDispatcher, SSEvent.BROWSE_FILE_DONE, handler_browseFileDone);
		
		v.fileM.init();
		v.pic.viewer.source = null;
		v.pic.transf.destroy();
	}
	
	/**
	 * 在PicPanel界面中新增Pic
	 * @param	$evt
	 */
	private function handler_select($evt:Event):void
	{
		this.dispatch(new SSEvent(SSEvent.BROWSE_FILE, StateType.ADD_TO_PIC_List));
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
	
	private function enterState($oldState:String, $newState:String):void
	{
		trace('picPanel.updateOnStateChanged:', $oldState, $newState);
		if($newState== StateType.PIC &&
			$oldState != $newState)
		{
			v.pic.transf.init();
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
		ssModel.resetSheet(null, new SpriteSheetMetadata());
		v.capture();
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