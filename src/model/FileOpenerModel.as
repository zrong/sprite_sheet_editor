package model 
{
import events.SSEvent;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import gnu.as3.gettext.FxGettext;
import org.zengrong.assets.AssetsType;
import org.zengrong.display.spritesheet.SpriteSheetMetadataType;
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
	public function openFilesByDrag($files:Array, $openState:String):void
	{
		_openState = $openState;
		checkSelectedFiles($files);
	}
	
	private function checkSelectedFiles($files:Array):void
	{
		_selectedFiles = $files;
		if(StateType.isViewState(_openState))
		{
			//如果要切换到SS状态，需要等待SS文件载入并解析完毕后才能切换状态。
			//载入的工作交给SpriteSheetLaoderModel。
			if(_openState == StateType.SS)
				_ssLoader.load(_file.url);
			//如果发生选择事件的state是编辑器界面/open状态，就执行状态切换
			else
				stateModel.state = _openState;
		}
		if(_openState == StateType.ADD_TO_PIC_List ||
			_openState == StateType.ADD_TO_SS)
		{
			var __bfd:BrowseFileDoneVO = new BrowseFileDoneVO(_openState, _selectedFiles);
			//向SS中加入帧的时候，要判断加入的文件是否是SS类型
			if(_openState == StateType.ADD_TO_SS &&
				Funs.hasMetadataFile((_selectedFiles[0] as File).url, SpriteSheetMetadataType.XML))
			{
				__bfd.fileType = AssetsType.SPRITE_SHEET;
				__bfd.metaType = SpriteSheetMetadataType.XML;
			}
			this.dispatch(new SSEvent(SSEvent.BROWSE_FILE_DONE, 	__bfd));
		}
		//trace('checkSelectedFiles', _file.nativePath, $evt.files, _openState);
	}
	
	//----------------------------------------
	// handler
	//----------------------------------------
	override protected function handler_selectSingle($evt:Event):void
	{
		checkSelectedFiles([_file.clone()]);
	}
	
	override protected function handler_selectMulti($evt:FileListEvent):void
	{
		checkSelectedFiles($evt.files);
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