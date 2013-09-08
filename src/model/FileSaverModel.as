package model 
{
import events.SSEvent;

import flash.display.BitmapData;
import flash.display.JPEGEncoderOptions;
import flash.display.JPEGXREncoderOptions;
import flash.display.PNGEncoderOptions;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import gnu.as3.gettext.FxGettext;

import org.zengrong.assets.AssetsType;
import org.zengrong.display.spritesheet.SpriteSheetMetadataType;

import type.StateType;

import vo.MetadataPreferenceVO;

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
	
	private var _exportPreference:MetadataPreferenceVO;
	
	public function get exportPreference():MetadataPreferenceVO 
	{
		if (_exportPreference) _exportPreference = new MetadataPreferenceVO();
		return _exportPreference;
	}
	
	public function set exportPreference(value:MetadataPreferenceVO):void 
	{
		_exportPreference = value;
	}
	
	private var _saveData:MetadataPreferenceVO;
	
	//----------------------------------------
	// 保存文件操作
	//----------------------------------------
	
	public function save($vo:MetadataPreferenceVO):void
	{
		_saveData = $vo;
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
		if(_saveData.type == StateType.SAVE_META)
		{
			saveMetadata(__imgFile.name);
		}
		else if(_saveData.type == StateType.SAVE_SHEET_PIC)
		{
			savePic(__imgFile, _saveData.bitmapData, _saveData.picType, _saveData.quality);
		}
		else if(_saveData.type == StateType.SAVE_ALL)
		{
			saveMetadata(__imgFile.name);
			savePic(__imgFile, _saveData.bitmapData, _saveData.picType, _saveData.quality);
		}
		else if(_saveData.type == StateType.SAVE_SEQ)
		{
			var __bmds:Vector.<BitmapData> = _saveData.bitmapDataList;
			var __names:Vector.<String> = _saveData.fileNameList;
			//获取文件的扩展名
			var __ext:String = _saveData.picType;
			for (var i:int = 0; i < __bmds.length; i++) 
			{
				savePic(_file.resolvePath(__names[i]), __bmds[i], __ext, _saveData.quality);
			}
		}
		dispatch(new SSEvent(SSEvent.CLOSE_EXPORT));
	}
	
	//保存metadata信息，其中需要传递图像文件名
	private function saveMetadata($name:String):void
	{
		var __stream:FileStream = new FileStream();
		__stream.open(getFile(SpriteSheetMetadataType.getTypeExt(_saveData.metaType)), FileMode.WRITE);
		__stream.writeUTFBytes(_saveData.metadata.objectify(_saveData.isSimple, _saveData.includeName, $name));
		__stream.close();
	}
	
	//保存图像，包括sheet或者序列图中的一帧
	private function savePic($file:File, $bmd:BitmapData, $picType:String, $quality:int):void
	{
		var __stream:FileStream = new FileStream();
		var __ba:ByteArray = getSheet($bmd, $picType, $quality);
		__stream.open($file, FileMode.WRITE);
		__stream.writeBytes(__ba);
		__stream.close();
	}
	
	//----------------------------------------
	// 内部方法
	//----------------------------------------
	
	/**
	 * 根据扩展名，制作一个新的File文件对象并返回
	 */	
	private function getFile($ext:String):File
	{
		var __newFileName:String = _file.name;
		var __fileNameAndExt:Array = __newFileName.split('.');
		if(__fileNameAndExt.length>1)
		{
			__newFileName = __fileNameAndExt[0] + "." + $ext;
		}
		else
		{
			__newFileName += ("." + $ext);
		}
		var __file:File = _file.parent.resolvePath(__newFileName);
		return __file;
	}
	
	/**
	 * 获取压缩之后的Sheet的Byte
	 */
	private function getSheet($bmd:BitmapData, $ext:String, $quality:int=70):ByteArray
	{
		var __ba:ByteArray = null;
		var __opt:*;
		if($ext == AssetsType.PNG)
		{
			__opt = new PNGEncoderOptions();
		}
		else if($ext == AssetsType.JPEG_XR)
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