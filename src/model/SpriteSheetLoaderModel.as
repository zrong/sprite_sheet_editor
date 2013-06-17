package model 
{
import org.robotlegs.mvcs.Actor;
import org.zengrong.net.SpriteSheetLoader;
import type.StateType;
import utils.Funs;
	
/**
 * 用于载入已经存在的SpriteSheet
 * @author zrong
 * Creation:2013-06-17
 */
public class SpriteSheetLoaderModel extends Actor 
{
	
	[Inject]
	public var ssModel:SpriteSheetModel;
	
	[Inject]
	public var stateModel:StateModel;
	
	public function SpriteSheetLoaderModel() 
	{
		super();
		_ssLoader = new SpriteSheetLoader();
		_ssLoader.addEventListener(Event.COMPLETE, handler_ssLoadComplete);
		_ssLoader.addEventListener(IOErrorEvent.IO_ERROR, handler_ssLoadError);
	}
	
	private var _ssLoader:SpriteSheetLoader;	//用于载入现有的SpriteSheet
	
	public function load($url:String, ...$args):void
	{
		_ssLoader.load($url);
	}
	
	/**
	 * 打开SS格式，载入SS完毕后调用
	 */
	private function handler_ssLoadComplete($evt:Event):void
	{
		ssModel.updateOriginalSheet(_ssLoader.getSpriteSheet());
		stateModel.state = StateType.SS;
	}
	
	private function handler_ssLoadError($evt:IOErrorEvent):void
	{
		Funs.alert($evt.text);
	}
	
}
}