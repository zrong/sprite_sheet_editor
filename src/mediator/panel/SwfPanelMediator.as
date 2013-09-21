package mediator.panel
{
import events.SSEvent;

import flash.events.Event;
import flash.filesystem.File;
import flash.geom.Rectangle;

import gnu.as3.gettext.FxGettext;

import org.zengrong.display.spritesheet.SpriteSheetMetadata;

import type.StateType;

import utils.calc.FrameCalculatorManager;

import view.panel.DrawablePanel;
import view.panel.SwfPanel;

import vo.OptimizedResultVO;

/**
 * @author zrong
 * 创建日期：2012-07-18
 */
public class SwfPanelMediator extends DrawablePanelMediator
{
	[Inject] public var v:SwfPanel;
	
	override protected function get gv():DrawablePanel
	{
		return v;
	}
	
	override public function onRegister():void
	{
		super.onRegister();
		addContextListener(SSEvent.ENTER_STATE, handler_enterState);
		enterState(stateModel.oldState, stateModel.state);
	}
	
	override public function onRemove():void
	{
		super.onRemove();		
		removeContextListener(SSEvent.ENTER_STATE, handler_enterState);
		
		v.destroy();
		v.preview.removeEventListener(SSEvent.PREVIEW_LOAD_COMPLETE, handler_swfLoadDone);
	}
	
	
	private var _swfURL:String;
	
	private var _swfContentX:int = 0;
	private var _swfContentY:int = 0;
	
	private var _frameInTimeline:int;	//当前正在处理的swf文件时间轴上的帧编号
	
	//正在处理的帧自身的尺寸，使用getFrameRect读取
	//与PicPanelMediator不同的是，后者每帧都可能不同（因为可能自行设置过），而前者每帧都相同，因此不需要每次都更新
	//正因为如此，将起作为成员保存
	private var _frameRect:Rectangle;
	
	override protected function addFrameLoaded():void
	{
		v.addEventListener(Event.EXIT_FRAME, handler_frameLoaded);
	}
	
	override protected function removeFrameLoaded():void
	{
		v.removeEventListener(Event.EXIT_FRAME, handler_frameLoaded);
	}
	
	override protected function capture():void
	{
		super.capture();
		//时间轴帧编号永远从0开始，无论正在播放的主时间轴有几帧（可能只有1帧，使用MC做动画），也可以实现多帧捕获
		_frameInTimeline = 0;
		_frameNum = 0;
		handler_frameLoaded();
	}
	
	override protected function captureDone():void
	{
		v.state = StateType.LOAD_DONE;
		super.captureDone();
	}
	
	/**
	 * 绘制一帧，并判断所有帧绘制是否完成
	 */
	override protected function handler_frameLoaded($evt:Event=null):void
	{
		//当前帧进行到需要绘制的时候，就开始绘制
		//例如，需要从第10帧开始捕获，那么这里就要等待_frameInTimeline为10
		if (_frameInTimeline++ >= v.firstFrame)
		{
			this.dispatch(
				new SSEvent(SSEvent.PROCESS,
					{current:_frameNum, total:v.totalFrame, label:FxGettext.gettext("Capturing")}
				));
//			trace('drawing frame:', _frameInTimeline-1);
			//记录BitmapData和它们的尺寸
			if(!_frameRect) _frameRect = v.getFrameRect();
			fillFrameInResult(_frameRect);
		}
		else
		{
			this.dispatch(
				new SSEvent(SSEvent.PROCESS, 
				{current:_frameInTimeline, total:v.firstFrame, label:FxGettext.gettext("Waiting for swf playing")}
			));
		}
		//所有帧捕获完毕
		if (_frameInTimeline - v.firstFrame >= v.totalFrame)
		{
			captureDone();
		}
	}
	
	private function handler_enterState($evt:SSEvent):void
	{
		enterState($evt.info.oldState, $evt.info.newState);
	}
	
	private function enterState($oldState:String, $newState:String):void
	{
		if($newState == StateType.SWF)
		{
			_swfURL = File(fileOpener.selectedFiles[0]).url;
			trace('swfPanel.load:', _swfURL);
			if(_swfURL)
			{
				v.preview.addEventListener(SSEvent.PREVIEW_LOAD_COMPLETE, handler_swfLoadDone);
				v.showSWF(_swfURL);
			}
		}
	}
	
	private function handler_swfLoadDone(event:SSEvent) : void
	{
		//若当前处于等待载入状态，则开始建立sheet
		if(v.state == StateType.WAIT_LOADED)
		{
			//如果允许调整尺寸，使用调整过的
			if(v.preview.enableDragContent)
				v.preview.moveContent(_swfContentX, _swfContentY);
			//开始capture
			v.state = StateType.PROCESSING;
			ssModel.resetSheet(null, new SpriteSheetMetadata());
			capture();
		}
		else
		{
			v.state = StateType.LOAD_DONE;
		}
	}
	
	override protected function handler_build($evt:SSEvent):void
	{
		v.state = StateType.WAIT_LOADED;
		//记录当前移动的内容坐标，以便载入成功后还原
		_swfContentX = v.preview.contentX;
		_swfContentY = v.preview.contentY;
		v.build(_swfURL);
		this.dispatch(new SSEvent(SSEvent.CREATE_PROCESS, FxGettext.gettext("Loading swf file")));
	}
}
}