package model 
{
import events.SSEvent;

import flash.events.Event;
import flash.events.FileListEvent;
import flash.events.IOErrorEvent;
import flash.filesystem.File;

import gnu.as3.gettext.FxGettext;

import org.zengrong.assets.AssetsType;
import org.zengrong.display.spritesheet.SpriteSheet;
import org.zengrong.display.spritesheet.SpriteSheetMetadataType;
import org.zengrong.net.SpriteSheetLoader;
import org.zengrong.utils.MathUtil;

import type.ExtendedNameType;
import type.StateType;

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
			case StateType.OPEN_OR_IMPORT:
				_file.browseForOpenMultiple(FxGettext.gettext("Select a/some compatible file(s) for open"), 
					ExtendedNameType.ALL_FILTER_LIST);
				break;
			case StateType.ADD_TO_PIC_List:
				_file.browseForOpenMultiple(FxGettext.gettext("Select image file"), 
					ExtendedNameType.ALL_PIC_FILTER_LIST);
				break;
			case StateType.ADD_TO_SS:
				_file.browseForOpenMultiple(FxGettext.gettext("Select image or metadata file"), 
					ExtendedNameType.ALL_TEXT_FILTER_LIST.concat(ExtendedNameType.ALL_PIC_FILTER_LIST));
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
	
	/**
	 * 通过检测打开的文件的扩展名，判断应该进入哪个界面
	 * 		//对于图像文件的处理，会自动搜索同名的metadata
		//若没有则作为图像处理，否则作为SpriteSheet打开
	 */
	private function checkOpenOrImportFiles($files:Array):void
	{
		var __state:String = Funs.getStateByFile($files[0]);
		if(!__state)
		{
			Funs.alert(FxGettext.gettext("These files are not supported!"));
			return;
		}
		_openState = __state;
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
				_ssLoader.load(File(_selectedFiles[0]).url);
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
				Funs.hasMetadataFile((_selectedFiles[0] as File).url, SpriteSheetMetadataType.SSE_XML))
			{
				__bfd.fileType = AssetsType.SPRITE_SHEET;
				__bfd.metaType = SpriteSheetMetadataType.SSE_XML;
			}
			this.dispatch(new SSEvent(SSEvent.BROWSE_FILE_DONE, __bfd));
		}
		//trace('checkSelectedFiles', _file.nativePath, $evt.files, _openState);
	}
	
	//----------------------------------------
	// handler
	//----------------------------------------
	//选择单个文件
	override protected function handler_selectSingle($evt:Event):void
	{
		checkSelectedFiles([_file.clone()]);
	}
	
	//选择多个文件
	override protected function handler_selectMulti($evt:FileListEvent):void
	{
		if(_openState == StateType.OPEN_OR_IMPORT)
		{
			checkOpenOrImportFiles($evt.files);
		}
		else
		{
			checkSelectedFiles($evt.files);	
		}
	}
	
	/**
	 * 打开SS格式，载入SS完毕后调用
	 */
	private function handler_ssLoadComplete($evt:Event):void
	{
		var __ss:SpriteSheet = _ssLoader.getSpriteSheet();
		//对于没有名称的metadata，自动为其加入名称。
		//这样处理的必要性在于，某些metadata必须要使用名称（例如Starling、cocos2d），若此处不加入，那么在导出该种metadata的时候
		//就会出现没有名称的情况
		if(!__ss.metadata.hasName)
		{
			//帧数量的位数
			var __zeroCount:int = String(__ss.metadata.totalFrame).length;
			var __names:Vector.<String> = new Vector.<String>;
			var __namesIndex:Object = {};
			for(var i:int=0; i< __ss.metadata.totalFrame; i++)
			{
				__names[i] = "frame_" + MathUtil.addZeroBeforeInt(i+1, __zeroCount);
				__namesIndex[__names[i]] = i;
			}
			__ss.metadata.hasName = true;
			__ss.metadata.names = __names;
			__ss.metadata.namesIndex = __namesIndex;
		}
		ssModel.updateOriginalSheet(__ss);
		stateModel.state = StateType.SS;
	}
	
	private function handler_ssLoadError($evt:IOErrorEvent):void
	{
		Funs.alert($evt.text);
	}
}
}