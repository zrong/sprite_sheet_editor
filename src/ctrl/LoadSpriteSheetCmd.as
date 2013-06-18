package ctrl 
{
import events.SSEvent;
import model.SpriteSheetLoaderModel;
import org.robotlegs.mvcs.Command;

/**
 * 处理载入已存在的SpriteSheet的工作
 * @author zrong
 * Creation: 2013-06-17
 */
public class LoadSpriteSheetCmd extends Command 
{
	[Inject]
	public var ssLoaderModel:SpriteSheetLoaderModel;
	
	[Inject]
	public var evt:SSEvent;
	
	override public function execute():void 
	{
		ssLoaderModel.load(evt.info as String);
	}
}
}