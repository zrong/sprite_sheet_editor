////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong zrongzrong@gmail.com
//  创建时间：2011-8-3
////////////////////////////////////////////////////////////////////////////////

package utils
{
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.FileListEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.FileFilter;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.graphics.codec.JPEGEncoder;
import mx.graphics.codec.PNGEncoder;

import org.zengrong.display.spritesheet.SpriteSheetType;

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
		
		_allPicFilter = new FileFilter('全部支持图像', PNG_FILTER.extension+';'+JPG_FILTER.extension);
		_allPicArr = [_allPicFilter, PNG_FILTER, JPG_FILTER];
	}
	
	private var _file:File;
	private var _allPicFilter:FileFilter;
	private var _allPicArr:Array;
	private var _openState:String;
	
	private var _fileData:*;		//等待保存的数据
	private var _fileExt:String;	//要保存的文件的扩展名或其他代表类型的值
	private var _quality:int;		//jpeg压缩的质量
	
	public function openSwf():void
	{
		_openState = StateType.SWF;
		_file.browseForOpen('选择一个swf文件', [SWF_FILTER]);
	}
	
	public function openPics():void
	{
		_openState = StateType.PIC;
		_file.browseForOpenMultiple('选择图像文件', _allPicArr);
	}
	
	public function openSS():void
	{
		_openState = StateType.SS;
		_file.browseForOpen('选择一个SpriteSheet文件', _allPicArr);
	}
	
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
		_fileExt = $type;
		_file.browseForSave('选择SpriteSheet的保存路径');
	}
	
	public function saveMeta($meta:String, $ext:String):void
	{
		_openState = StateType.SAVE_META;
		_fileExt = $ext;
		_fileData = $meta;
		_file.browseForSave('选择元数据的保存路径');
	}
	
	public function saveAll($data:Object, $ext:String, $quality:int=70):void
	{
		_openState = StateType.SAVE_ALL;
		_fileData = $data;
		_fileExt = $ext;
		_quality = $quality;
		_file.browseForSave('选择图像和元数据的保存路径');
	}
	
	public function saveSeq($seq:Vector.<BitmapData>, $type:String):void
	{
		
	}
	
	private function saveData():void
	{
		var __stream:FileStream = new FileStream();
		var __ba:ByteArray = null;
		if(_openState == StateType.SAVE_META)
		{
			__stream.open(getFile(_fileExt), FileMode.WRITE);
			__stream.writeUTFBytes(_fileData);
			__stream.close();
		}
		else if(_openState == StateType.SAVE_SHEET)
		{
			__ba = getSheet(_fileData, _fileExt, _quality);
			__stream.open(getFile(_fileExt), FileMode.WRITE);
			__stream.writeBytes(__ba);
			__stream.close();
		}
		else if(_openState == StateType.SAVE_ALL)
		{
			var __exts:Array = _fileExt.split(',');
			//使用metadata的扩展名（数组元素1）新建一个File
			__stream.open(getFile(__exts[1]), FileMode.WRITE);
			__stream.writeUTFBytes(_fileData.meta);
			__stream.close();
			
			//__exts的0元素是Sheet的类型，值为SpriteSheetType中的值
			//getSheet会使用正确的扩展名填充_fileExt
			__ba = getSheet(_fileData.bitmapData, __exts[0], _quality);
			__stream.open(getFile(_fileExt), FileMode.WRITE);
			__stream.writeBytes(__ba);
			__stream.close();
		}
	}
	
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
	private function getSheet($bmd:BitmapData, $type:String, $quality:int=70):ByteArray
	{
		var __ba:ByteArray = null;
		if($type == SpriteSheetType.PNG)
		{
			var __png:PNGEncoder = new PNGEncoder();
			_fileExt = '.png';
			return __png.encode($bmd);
		}
		var __jpg:JPEGEncoder = new JPEGEncoder($quality);
		_fileExt = '.jpg';
		return __jpg.encode($bmd);
	}
	
	private function handler_selectSingle($evt:Event):void
	{
		//如果发生选择事件的state是编辑器主状态，就执行状态切换
		if(StateType.isMainState(_openState))
		{
			Global.instance.files = new ArrayCollection([_file]);
			Funs.changeState(_openState);
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
		Global.instance.files = new ArrayCollection($evt.files);
		Funs.changeState(_openState);
		//trace('multi:', _file.nativePath, $evt.files, _openState);
	}
	
}
}
class Singlton{};