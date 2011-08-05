////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong zrongzrong@gmail.com
//  创建时间：2011-8-3
////////////////////////////////////////////////////////////////////////////////

package utils
{
import flash.events.Event;
import flash.events.FileListEvent;
import flash.filesystem.File;
import flash.net.FileFilter;

import mx.collections.ArrayCollection;

import type.StateType;

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
	
	private function handler_selectSingle($evt:Event):void
	{
		Global.instance.files = new ArrayCollection([_file]);
		Funs.changeState(_openState);
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