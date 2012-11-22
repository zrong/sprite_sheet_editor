package model
{
import flash.display.BitmapData;
import flash.geom.Rectangle;

import org.robotlegs.mvcs.Actor;
import org.zengrong.display.spritesheet.SpriteSheet;
import org.zengrong.display.spritesheet.SpriteSheetMetadata;

/**
 * 暂存编辑过程中的位图资源
 * @author zrong
 * 创建日期：2012-07-25
 */
public class SpriteSheetModel extends Actor
{
	public function SpriteSheetModel()
	{
	}
	
	
	public function resetSheet($bmd:BitmapData=null, $meta:SpriteSheetMetadata=null):void
	{
		if(_originalSheet) _originalSheet.destroy();
		_originalSheet = new SpriteSheet($bmd, $meta);
	}	
	
	public function getBMDList():Vector.<BitmapData>
	{
		if(displayCrop) return adjustedSheet.getAll();
		return originalSheet.getAll();
	}
	
	public function destroySheet():void
	{
		if(_originalSheet) _originalSheet.destroy();
		_originalSheet = null;
		if(adjustedSheet) adjustedSheet.destroy();
		_adjustedSheet = null;	
	}
	
	private var _originalSheet:SpriteSheet;
	/**
	 * 刚生成的sheet，或者打开的sheet文件，保存在此对象中。在此sheet的基础上进行调整后保存
	 */	
	public function get originalSheet():SpriteSheet
	{
		return _originalSheet;
	}
	
	/**
	 * 更新当前保存的原始Sheet
	 */
	public function updateOriginalSheet($sheet:SpriteSheet):void
	{
		if(_originalSheet) _originalSheet.destroy();
		_originalSheet = $sheet;
		_originalSheet.parseSheet();
	}
	
	private var _adjustedSheet:SpriteSheet;
	
	/**
	 * 保存调整过的Sheet。对生成的sheet经常会做一些调整，例如剔除透明像素，加背景色等等，调整后的结果保存在此对象中
	 */	
	public function get adjustedSheet():SpriteSheet
	{
		return _adjustedSheet;
	}
	
	/**
	 * 基于原始的Sheet更新调整后的Sheet
	 */
	public function updateAdjustedSheet():void
	{
		//TODO 将支持多语言
		if(!_originalSheet) throw new TypeError("无法获取原始Sprite Sheet！");
		if(_adjustedSheet) _adjustedSheet.destroy();
		_adjustedSheet = _originalSheet.clone();
	}
	
	public function drawOriginalSheet($bmd:BitmapData):void
	{
		_originalSheet.drawSheet($bmd);
	}
	
	public function addOriginalFrame($bmd:BitmapData, $sizeRect:Rectangle=null, $originalRect:Rectangle=null, $name:String=null):void
	{
		_originalSheet.addFrame($bmd, $sizeRect, $originalRect, $name);
	}
	
	public function addOriginalFrameAt($index:int, $bmd:BitmapData, $sizeRect:Rectangle=null, $originalRect:Rectangle=null,$name:String=null):void
	{
		_originalSheet.addFrameAt($index, $bmd, $sizeRect, $originalRect, $name);
	}
		
	public function drawAdjustedSheet($bmd:BitmapData):void
	{
		_adjustedSheet.drawSheet($bmd);
	}
	
	public function addAdjustedFrame($bmd:BitmapData, $sizeRect:Rectangle=null, $originalRect:Rectangle=null, $name:String=null):void
	{
		_adjustedSheet.addFrame($bmd, $sizeRect, $originalRect, $name);
	}
	
	public function addAdjustedFrameAt($index:int, $bmd:BitmapData, $sizeRect:Rectangle=null, $originalRect:Rectangle=null,$name:String=null):void
	{
		_adjustedSheet.addFrameAt($index, $bmd, $sizeRect, $originalRect, $name);
	}
	
	/**
	 * 是否显示修剪空白后的帧的效果
	 */
	public var displayCrop:Boolean;
	
	/**
	 * 为true代表显示选择的Frame，false代表显示Label
	 */
	public var displayFrame:Boolean;
	
	public var resizeRect:Rectangle;
	
	/**
	 * 保存当前选择的帧的编号
	 */
	public var selectedFrameIndex:int=-1;
	
	public var selectedFrmaeNum:int = -1;
	
	public var selectedFrameIndices:Vector.<int>;
	
	public var playing:Boolean;
}
}