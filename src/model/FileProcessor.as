package model
{
import flash.events.Event;
import flash.events.FileListEvent;
import flash.filesystem.File;
import org.robotlegs.mvcs.Actor;

/**
 * 专门负责对文件的处理，基类。
 * @author zrong(zengrong.net)
 * Creation: 2011-8-3
 * Modification: 2013-08-19
 */
public class FileProcessor extends Actor
{
	[Inject] public var stateModel:StateModel;
	
	public function FileProcessor()
	{
		initFile(File.desktopDirectory);
	}
	
	protected var _file:File;
	protected var _openState:String;
	
	protected function initFile($file:File):void
	{
		if(_file)
		{
			_file.removeEventListener(FileListEvent.SELECT_MULTIPLE, handler_selectMulti);
			_file.removeEventListener(Event.SELECT, handler_selectSingle);
			_file.removeEventListener(Event.CANCEL, handler_selectCancel);
		}
		_file = $file;
		_file.addEventListener(FileListEvent.SELECT_MULTIPLE, handler_selectMulti);
		_file.addEventListener(Event.SELECT, handler_selectSingle);
		_file.addEventListener(Event.CANCEL, handler_selectCancel);
	}

	public function get openState():String
	{
		return _openState;
	}

	//----------------------------------------
	// handler
	//----------------------------------------
	
	protected function handler_selectSingle($evt:Event):void
	{
	}
	
	protected function handler_selectMulti($evt:FileListEvent):void
	{
	}
	
	protected function handler_selectCancel($evt:Event):void
	{
	}
}
}