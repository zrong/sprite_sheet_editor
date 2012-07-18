package
{
import flash.display.DisplayObjectContainer;

import mediator.*;

import model.*;

import org.robotlegs.mvcs.Context;

import utils.Global;

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
		Global.instance.root = contextView as SpriteSheetEditor;
	}
	
	override public function startup():void
	{
		init();
		injector.mapSingleton(FileProcessor);
		injector.mapSingleton(StateModel);
		
		mediatorMap.mapView(SpriteSheetEditor, AppMediator);
		mediatorMap.mapView(TopPanel, TopPanelMediator);
		mediatorMap.mapView(SwfPanel, SwfPanelMediator);
		mediatorMap.mapView(SSPanel, SSPanelMediator);
		mediatorMap.mapView(StartPanel, StartPanelMediator);
		mediatorMap.mapView(PicPanel, PicPanelMediator);
	}
}
}