package
{
import ctrl.PreviewSSChangeCmd;
import ctrl.SaveCmd;

import events.SSEvent;

import flash.display.DisplayObjectContainer;

import mediator.*;
import mediator.comps.*;
import mediator.panel.*;

import model.*;

import org.robotlegs.mvcs.Context;

import utils.Global;

import view.comps.FramesAndLabels;
import view.comps.SSPreview;
import view.panel.*;

/**
 * 
 * @author zrong(zengrong.net)
 * 创建日期：2012-07-18
 */
public class SSEContext extends Context
{
	public function SSEContext(contextView:DisplayObjectContainer=null, autoStartup:Boolean=true)
	{
		super(contextView, autoStartup);
	}
	
	private function init():void
	{
		Global.init(contextView as SpriteSheetEditor);
	}
	
	override public function startup():void
	{
		init();
		injector.mapSingleton(FileProcessor);
		injector.mapSingleton(StateModel);
		injector.mapSingleton(SpriteSheetModel);
		
		mediatorMap.mapView(SpriteSheetEditor, AppMediator);
		mediatorMap.mapView(TopPanel, TopPanelMediator);
		mediatorMap.mapView(SwfPanel, SwfPanelMediator);
		mediatorMap.mapView(SSPanel, SSPanelMediator);
		mediatorMap.mapView(StartPanel, StartPanelMediator);
		mediatorMap.mapView(PicPanel, PicPanelMediator);
		
		mediatorMap.mapView(SSPreview, SSPreviewMediator,null, false, false);
		mediatorMap.mapView(FramesAndLabels,FramesAndLabelMediator, null, false, false);
		
		commandMap.mapEvent(SSEvent.PREVIEW_SS_CHANGE, PreviewSSChangeCmd);
		commandMap.mapEvent(SSEvent.SAVE, SaveCmd);
	}
}
}