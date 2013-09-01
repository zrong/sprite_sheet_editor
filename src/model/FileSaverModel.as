package model 
{
import flash.display.BitmapData;
import flash.display.JPEGEncoderOptions;
import flash.display.JPEGXREncoderOptions;
import flash.display.PNGEncoderOptions;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
import gnu.as3.gettext.FxGettext;
import type.ExtendedNameType;
import type.StateType;
import vo.SaveVO;
import flash.events.Event;
/**
 * 负责保存文件
 * @author zrong(zengrong.net)
 * Creation: 2013-08-19
 */
public class FileSaverModel extends FileProcessor 
{
	public function FileSaverModel() 
	{
		super();
	}
	
	private var _exportPreference:SaveVO;
	
	public function get exportPreference():SaveVO 
	{
		if (_exportPreference) _exportPreference = new SaveVO();
		return _exportPreference;
	}
	
	public function set exportPreference(value:SaveVO):void 
	{
		_exportPreference = value;
	}
	
	private var _saveData:SaveVO;
	
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
	
	override protected function handler_selectSingle($evt:Event):void
	{
		saveData();
	}
}
}