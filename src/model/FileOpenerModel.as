package model 
{
import events.SSEvent;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import gnu.as3.gettext.FxGettext;
import org.zengrong.net.SpriteSheetLoader;
import type.ExtendedNameType;
import type.StateType;
import flash.events.Event;
import flash.events.FileListEvent;
import utils.Funs;
import vo.BrowseFileDoneVO;
/**
 * 负责打开文件
 * @author zrong(zengrong.net)
 * Creation: 2013-08-19 
 */
public class FileOpenerModel extends FileProcessor 
{	
	public function FileOpenerModel() 
	{
		super();
		_ssLoader = new SpriteSheetLoader();
		_ssLoader.addEventListener(Event.COMPLETE, handler_ssLoadComplete);
		_ssLoader.addEventListener(IOErrorEvent.IO_ERROR, handler_ssLoadError);
	}
	
	[Inject] public var ssModel:SpriteSheetModel;
	
	private var _ssLoader:SpriteSheetLoader;	//用于载入现有的SpriteSheet
	
	private var _selectedFiles:Array;	//选择的文件数组
		
	public function get selectedFiles():Array
	{
		return _selectedFiles;
	}

	//----------------------------------------
	// 打开文件操作
	//----------------------------------------
	
	public function open($state:String):void
	{
		_openState = $state;
		switch(_openState)
		{
			case StateType.SWF:
				_file.browseForOpen(FxGettext.gettext("Select a swf file"), [ExtendedNameType.SWF_FILTER]);
				break;
			case StateType.SS:
				_file.browseForOpen(FxGettext.gettext("Select a Sprite Sheet file"), ExtendedNameType.ALL_PIC_FILTER_LIST);
				break;
			case StateType.PIC:
				_file.browseForOpenMultiple(FxGettext.gettext("Select image file"), ExtendedNameType.ALL_PIC_FILTER_LIST);
				break;
			case StateType.ADD_TO_PIC_List:
				_file.browseForOpenMultiple(FxGettext.gettext("Select image file"), ExtendedNameType.ALL_PIC_FILTER_LIST);
				break;
			case StateType.ADD_TO_SS:
				_file.browseForOpenMultiple(FxGettext.gettext("Select image file"), ExtendedNameType.ALL_PIC_FILTER_LIST);
				break;
		}
	}
	
		
	/**
	 * 打开一个被拖入界面中的文件
	 * @param	$file 要处理的文件，可能是一个File，也可能是File数组
	 * @param	$openState 打开的状态
	 */
	public function openFileByDrag($file:*, $openState:String):void
	{
		_openState = $openState;
		if(_openState == StateType.SS ||
			_openState == StateType.SWF )
		{
			checkSingleFileAndDispatch($file as File);
		}
		else if(_openState == StateType.PIC ||
			_openState == StateType.ADD_TO_PIC_List ||
			_openState == StateType.ADD_TO_SS)
		{
			checkMultiFileAndDispatch($file as Array);
		}
	}
	
	private function checkSingleFileAndDispatch($file:File):void
	{
		if(_file != $file) _file = $file;
		//如果发生选择事件的state是编辑器界面/open状态，就执行状态切换
		if(StateType.isViewState(_openState))
		{
			_selectedFiles = [_file.clone()];
			//如果要切换到SS状态，需要等待SS文件载入并解析完毕后才能切换状态。
			//载入的工作交给SpriteSheetLaoderModel。
			if(_openState == StateType.SS)
			{
				_ssLoader.load(_file.url);
			}
			else
				stateModel.state = _openState;
		}
		//trace('single:',_file.nativePath, _openState);
	}
	
	private function checkMultiFileAndDispatch($files:Array):void
	{
		_selectedFiles = $files;
		if(StateType.isViewState(_openState))
		{
			stateModel.state = _openState;
		}
		if(_openState == StateType.ADD_TO_PIC_List ||
			_openState == StateType.ADD_TO_SS)
		{
			this.dispatch
			(
				new SSEvent
				(
					SSEvent.BROWSE_FILE_DONE, 
					new BrowseFileDoneVO(_openState, _selectedFiles)
				)
			);
		}
		//trace('multi:', _file.nativePath, $evt.files, _openState);
	}
	
	//----------------------------------------
	// handler
	//----------------------------------------
	override protected function handler_selectSingle($evt:Event):void
	{
		checkSingleFileAndDispatch(_file);
	}
	
	override protected function handler_selectMulti($evt:FileListEvent):void
	{
		checkMultiFileAndDispatch($evt.files);
	}
	
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