////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong zrongzrong@gmail.com
//  创建时间：2011-8-3
////////////////////////////////////////////////////////////////////////////////

package model
{
import air.update.net.FileDownloader;
import flash.display.BitmapData;
import flash.display.JPEGEncoderOptions;
import flash.display.JPEGXREncoderOptions;
import flash.display.PNGEncoderOptions;
import flash.events.Event;
import flash.events.FileListEvent;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.FileFilter;
import flash.utils.ByteArray;
import gnu.as3.gettext.FxGettext;

import org.robotlegs.mvcs.Actor;
import org.zengrong.net.SpriteSheetLoader;

import type.ExtendedNameType;
import type.StateType;

import utils.Funs;

import vo.SaveVO;

/**
 * 专门负责对文件的处理，包括打开、保存等等操作。
 * @author zrong
 */
public class FileProcessor extends Actor
{
	[Inject] public var stateModel:StateModel;
	[Inject] public var ssModel:SpriteSheetModel;
	/**
	 * 要打开的图像文件类型
	 */	
	public static const PNG_FILTER:FileFilter = new FileFilter(FxGettext.gettext("PNG image"), '*.png');
	public static const JPG_FILTER:FileFilter = new FileFilter(FxGettext.gettext("JPEG image"), '*.jpg;*.jpeg');
	public static const JPEG_XR_FILTER:FileFilter = new FileFilter(FxGettext.gettext("JPEG-XR image"), '*.wdp;*.hdp');
	public static const SWF_FILTER:FileFilter = new FileFilter(FxGettext.gettext("SWF animation"), '*.swf');
	
	public function FileProcessor()
	{
		initFile(File.desktopDirectory);
		
		initFilter();
		
		_ssLoader = new SpriteSheetLoader();
		_ssLoader.addEventListener(Event.COMPLETE, handler_ssLoadComplete);
		_ssLoader.addEventListener(IOErrorEvent.IO_ERROR, handler_ssLoadError);
	}
	
	private var _file:File;
	private var _allPicFilter:FileFilter;
	private var _allPicArr:Array;
	private var _openState:String;
	private var _selectedFiles:Array;	//选择的文件数组
	private var _callBack:Function;
	
	private var _ssLoader:SpriteSheetLoader;	//用于载入现有的SpriteSheet
	
	private var _saveData:SaveVO;
	
	private function initFile($file:File):void
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
	
	private function initFilter():void
	{
		_allPicFilter = new FileFilter(FxGettext.gettext("All compatible image"), PNG_FILTER.extension+';'+JPG_FILTER.extension+';'+JPEG_XR_FILTER.extension);
		_allPicArr = [_allPicFilter, PNG_FILTER, JPG_FILTER, JPEG_XR_FILTER];
	}
	
	public function get selectedFiles():Array
	{
		return _selectedFiles;
	}
	
	//----------------------------------------
	// 打开文件操作
	//----------------------------------------
	
	public function openSwf():void
	{
		_openState = StateType.SWF;
		_file.browseForOpen(FxGettext.gettext("Select a swf file"), [SWF_FILTER]);
	}
	
	public function openPics($callBack:Function=null):void
	{
		_openState = StateType.PIC;
		_file.browseForOpenMultiple(FxGettext.gettext("Select image file"), _allPicArr);
		_callBack = $callBack;
	}
	
	public function openSS():void
	{
		_openState = StateType.SS;
		_file.browseForOpen(FxGettext.gettext("Select a Sprite Sheet file"), _allPicArr);
	}
	
	public function addToSS($callBack:Function=null):void
	{
		_openState = StateType.ADD_TO_SS;
		_file.browseForOpenMultiple(FxGettext.gettext("Select image file"), _allPicArr);
		_callBack = $callBack;
	}
	
	//----------------------------------------
	// 保存文件操作
	//----------------------------------------
	
	public function save($vo:SaveVO):void
	{
		_saveData = $vo;
		_openState = _saveData.type;
		var __title:String;
		switch(_saveData.type)
		{
			case StateType.SAVE_SHEET_PIC:
				__title = FxGettext.gettext("Select the save path of Sprite Sheet file");
				//更新一次File的引用，是为了避免File指向老的已经存在的图片，导致AIR的覆盖提示错误
				initFile(getFile(_saveData.picType));
				_file.browseForSave(__title);
				break;
			case StateType.SAVE_META:
				__title = FxGettext.gettext("Select the save path of metadata");
				_file.browseForSave(__title);
				break;
			case StateType.SAVE_SEQ:
				__title = FxGettext.gettext("Select the save path of the image sequence");
				_file.browseForDirectory(__title);
				break;
			case StateType.SAVE_ALL:
				__title = FxGettext.gettext("Select the save path of image and metedata");
				//更新一次File的引用，是为了避免File指向老的已经存在的图片，导致AIR的覆盖提示错误
				initFile(getFile(_saveData.picType));
				_file.browseForSave(__title);
				break;
		}
	}
	
	private function saveData():void
	{
		var __stream:FileStream = new FileStream();
		var __ba:ByteArray = null;
		var __imgFile:File = getFile(_saveData.picType);
		if(_openState == StateType.SAVE_META)
		{
			__stream.open(getFile(_saveData.metaType), FileMode.WRITE);
			__stream.writeUTFBytes(_saveData.metadata.objectify(_saveData.isSimple, _saveData.includeName, __imgFile.name));
			__stream.close();
		}
		else if(_openState == StateType.SAVE_SHEET_PIC)
		{
			__ba = getSheet(_saveData.bitmapData, _saveData.picType, _saveData.quality);
			__stream.open(__imgFile, FileMode.WRITE);
			__stream.writeBytes(__ba);
			__stream.close();
		}
		else if(_openState == StateType.SAVE_ALL)
		{
			//使用sheet的扩展名（数组元素0）新建一个File
			__ba = getSheet(_saveData.bitmapData, _saveData.picType, _saveData.quality);
			__stream.open(__imgFile, FileMode.WRITE);
			__stream.writeBytes(__ba);
			__stream.close();
			
			//使用metadata的扩展名（数组元素1）新建一个File
			__stream.open(getFile(_saveData.metaType), FileMode.WRITE);
			__stream.writeUTFBytes(_saveData.metadata.objectify(_saveData.isSimple, _saveData.includeName,__imgFile.name));
			__stream.close();
		}
		else if(_openState == StateType.SAVE_SEQ)
		{
			var __bmds:Vector.<BitmapData> = _saveData.bitmapDataList;
			var __names:Vector.<String> = _saveData.fileNameList;
			//获取文件的扩展名
			var __ext:String = __names[0].slice(__names[0].lastIndexOf('.'));
			for (var i:int = 0; i < __bmds.length; i++) 
			{
				__ba = getSheet(__bmds[i], __ext, _saveData.quality);
				__stream.open(_file.resolvePath(__names[i]), FileMode.WRITE);
				__stream.writeBytes(__ba);
				__stream.close();
			}
		}
	}
	
	//----------------------------------------
	// 内部方法
	//----------------------------------------
	
	/**
	 * 根据扩展名，制作一个新的File文件对象并返回
	 */	
	private function getFile($ext:String):File
	{
		var __file:File = _file.parent.resolvePath(_file.name.split('.')[0]+$ext);
		return __file;
	}
	
	/**
	 * 获取压缩之后的Sheet的Byte
	 */
	private function getSheet($bmd:BitmapData, $ext:String, $quality:int=70):ByteArray
	{
		var __ba:ByteArray = null;
		var __opt:*;
		if($ext == ExtendedNameType.PNG)
		{
			__opt = new PNGEncoderOptions();
		}
		else if($ext == ExtendedNameType.JPEG_XR)
		{
			__opt = new JPEGXREncoderOptions($quality);
		}
		else
		{
			__opt = new JPEGEncoderOptions($quality);
		}
		return $bmd.encode($bmd.rect, __opt);
	}
	
	//----------------------------------------
	// handler
	//----------------------------------------
	
	private function handler_selectSingle($evt:Event):void
	{
		//如果发生选择事件的state是编辑器界面状态，就执行状态切换
		if(StateType.isViewState(_openState))
		{
			_selectedFiles = [_file.clone()];
			//如果要切换到SS状态，需要等待SS文件载入并解析完毕后才能切换状态
			if(_openState == StateType.SS)
			{
				_ssLoader.load(_file.url);
			}
			else
				stateModel.state = _openState;
		}
		//否则执行保存
		else
		{
			saveData();
		}
		//trace('single:',_file.nativePath, _openState);
	}
	
	protected function getMetadataUrl($url:String, $type:String):String
	{
		var __dotIndex:int = $url.lastIndexOf('.');
		if(__dotIndex == -1)
			return $url + '.'+$type;
		return $url.slice(0, __dotIndex) + '.'+$type;
	}
	
	private function handler_selectMulti($evt:FileListEvent):void
	{
		_selectedFiles = $evt.files;
		if(StateType.isViewState(_openState))
		{
			stateModel.state = _openState;
		}
		if(_openState == StateType.PIC ||
			_openState == StateType.ADD_TO_SS)
		{
			if(_callBack is Function)
			{
				_callBack.call(null, _selectedFiles);
				_callBack = null;
			}
		}
		//trace('multi:', _file.nativePath, $evt.files, _openState);
	}
	
	private function handler_selectCancel($evt:Event):void
	{
		_callBack = null;
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