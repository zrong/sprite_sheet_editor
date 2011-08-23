////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong zrongzrong@gmail.com
//  创建时间：2011-8-3
////////////////////////////////////////////////////////////////////////////////

package utils
{
import flash.display.BitmapData;
import flash.errors.IOError;
import flash.events.Event;
import flash.events.FileListEvent;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.FileFilter;
import flash.utils.ByteArray;

import mx.graphics.codec.JPEGEncoder;
import mx.graphics.codec.PNGEncoder;

import org.zengrong.display.spritesheet.SpriteSheetType;
import org.zengrong.net.SpriteSheetLoader;

import type.StateType;

/**
 * 专门负责对文件的处理，包括打开、保存等等操作。
 * @author zrong
 */
public class FileProcessor
{
	/**
	 * 图像文件扩展名数组
	 */	
	public static const PIC_FILE_EXT:Array = ['png', 'jpg', 'jpeg'];
	
	/**
	 * 要打开的图像文件类型
	 */	
	public static const PNG_FILTER:FileFilter = new FileFilter('PNG图像', '*.png');
	public static const JPG_FILTER:FileFilter = new FileFilter('JPG图像', '*.jpg;*.jpeg');
	public static const SWF_FILTER:FileFilter = new FileFilter('SWF动画', '*.swf');
	
	private static var _instance:FileProcessor;
	
	public static function get instance():FileProcessor
	{
		if(!_instance)
			_instance = new FileProcessor(new Singlton);
		return _instance;
	}
	
	public function FileProcessor($sig:Singlton)
	{
		if(!$sig) throw new TypeError('请使用FileProcessor.instance获取单例！');
		_file = File.desktopDirectory;
		_file.addEventListener(FileListEvent.SELECT_MULTIPLE, handler_selectMulti);
		_file.addEventListener(Event.SELECT, handler_selectSingle);
		_file.addEventListener(Event.CANCEL, handler_selectCancel);
		
		_allPicFilter = new FileFilter('全部支持图像', PNG_FILTER.extension+';'+JPG_FILTER.extension);
		_allPicArr = [_allPicFilter, PNG_FILTER, JPG_FILTER];
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
	
	private var _fileData:*;		//等待保存的数据
	private var _fileName:*;		//要保存的文件名称或者其他代表文件名称的值
	private var _quality:int;		//jpeg压缩的质量
	
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
		_file.browseForOpen('选择一个swf文件', [SWF_FILTER]);
	}
	
	public function openPics($callBack:Function=null):void
	{
		_openState = StateType.PIC;
		_file.browseForOpenMultiple('选择图像文件', _allPicArr);
		_callBack = $callBack;
	}
	
	public function openSS():void
	{
		_openState = StateType.SS;
		_file.browseForOpen('选择一个SpriteSheet文件', _allPicArr);
	}
	
	//----------------------------------------
	// 保存文件操作
	//----------------------------------------
	
	/**
	 * 保存SpriteSheet图像
	 * @param $ba	图像的字节
	 * @param $type	图像的类型，值为SprietSheetType
	 * @param $doneFun	保存完毕后的回调方法
	 * @see org.zengrong.display.spritesheet.SpriteSheetType
	 */	
	public function saveSS($bmd:BitmapData, $type:String, $quality:int=70):void
	{
		_openState = StateType.SAVE_SHEET;
		_fileData = $bmd;
		_quality = $quality;
		_fileName = $type;
		_file.browseForSave('选择SpriteSheet的保存路径');
	}
	
	public function saveMeta($meta:String, $ext:String):void
	{
		_openState = StateType.SAVE_META;
		_fileName = $ext;
		_fileData = $meta;
		_file.browseForSave('选择元数据的保存路径');
	}
	
	public function saveAll($data:Object, $exts:Array, $quality:int=70):void
	{
		_openState = StateType.SAVE_ALL;
		_fileData = $data;
		_fileName = $exts;
		_quality = $quality;
		_file.browseForSave('选择图像和元数据的保存路径');
	}
	
	public function saveSeq($seq:Vector.<BitmapData>, $names:Vector.<String>, $quality:int=70):void
	{
		_openState = StateType.SAVE_SEQ;
		_fileData = $seq;
		_fileName = $names;
		_quality = $quality;
		_file.browseForDirectory('选择图像序列的保存路径');
	}
	
	private function saveData():void
	{
		var __stream:FileStream = new FileStream();
		var __ba:ByteArray = null;
		if(_openState == StateType.SAVE_META)
		{
			__stream.open(getFile(_fileName), FileMode.WRITE);
			__stream.writeUTFBytes(_fileData);
			__stream.close();
		}
		else if(_openState == StateType.SAVE_SHEET)
		{
			__ba = getSheet(_fileData, _fileName, _quality);
			__stream.open(getFile(_fileName), FileMode.WRITE);
			__stream.writeBytes(__ba);
			__stream.close();
		}
		else if(_openState == StateType.SAVE_ALL)
		{
			//使用metadata的扩展名（数组元素1）新建一个File
			__stream.open(getFile((_fileName as Array)[1]), FileMode.WRITE);
			__stream.writeUTFBytes(_fileData.meta);
			__stream.close();
			
			//使用sheet的扩展名（数组元素0）新建一个File
			__ba = getSheet(_fileData.bitmapData, (_fileName as Array)[0], _quality);
			__stream.open(getFile((_fileName as Array)[0]), FileMode.WRITE);
			__stream.writeBytes(__ba);
			__stream.close();
		}
		else if(_openState == StateType.SAVE_SEQ)
		{
			var __bmds:Vector.<BitmapData> = Vector.<BitmapData>(_fileData);
			var __names:Vector.<String> = Vector.<String>(_fileName);
			//获取文件的扩展名
			var __ext:String = __names[0].slice(__names[0].lastIndexOf('.'));
			for (var i:int = 0; i < __bmds.length; i++) 
			{
				__ba = getSheet(__bmds[i], __ext, _quality);
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
		if($ext == '.png')
		{
			var __png:PNGEncoder = new PNGEncoder();
			return __png.encode($bmd);
		}
		var __jpg:JPEGEncoder = new JPEGEncoder($quality);
		return __jpg.encode($bmd);
	}
	
	//----------------------------------------
	// handler
	//----------------------------------------
	
	private function handler_selectSingle($evt:Event):void
	{
		//如果发生选择事件的state是编辑器主状态，就执行状态切换
		if(StateType.isMainState(_openState))
		{
			_selectedFiles = [_file.clone()];
			if(_openState != StateType.SS)
				Funs.changeState(_openState);
			else
				_ssLoader.load(_file.url);
		}
		//否则执行保存
		else
		{
			saveData();
		}
		//trace('single:',_file.nativePath, _openState);
	}
	
	private function handler_selectMulti($evt:FileListEvent):void
	{
		_selectedFiles = $evt.files;
		Funs.changeState(_openState);
		if(_callBack is Function)
		{
			_callBack.call();
			_callBack = null;
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
		Global.instance.sheet = _ssLoader.getSpriteSheet();
		Global.instance.sheet.parseSheet();
		Funs.changeState(_openState);
	}
	
	private function handler_ssLoadError($evt:IOErrorEvent):void
	{
		Funs.alert($evt.text);
	}
}
}
class Singlton{};