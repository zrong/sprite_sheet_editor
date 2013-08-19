package ctrl 
{
import events.SSEvent;
import flash.desktop.ClipboardFormats;
import flash.desktop.NativeDragManager;
import model.FileProcessor;
import org.robotlegs.mvcs.Command;
import type.StateType;
import utils.Funs;

/**
 * 处理一个拖放文件
 * @author zrong
 * Creation: 2013-08-19
 */
public class DragFileCmd extends Command 
{
	[Inject] public var evt:SSEvent;
	[Inject] public var file:FileProcessor;
	
	public override function execute():void 
	{
		var __files:Array = evt.info as Array;
		var __state:String = Funs.getStateByFile(__files[0]);
		if(!__state)
		{
			Funs.alert("!!!!!!!!!!!!!!");
			return;
		}
		if(__state == StateType.PIC)
		{
			file.checkFileByDrag(__files, __state);
		}
		else if(__state == StateType.SS || __state == StateType.SWF)
		{
			file.checkFileByDrag(__files[0], __state);
		}
	}
}
}