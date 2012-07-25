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
		if(sheet) sheet.destroy();
		sheet = new SpriteSheet($bmd, $meta);
	}	
	
	public function getBMDList():Vector.<BitmapData>
	{
		if(displayCrop) return adjustedSheet.getAll();
		return sheet.getAll();
	}
	/**
	 * 刚生成的sheet，或者打开的sheet文件，保存在此对象中。在此sheet的基础上进行调整后保存
	 */	
	public var sheet:SpriteSheet;
	
	/**
	 * 保存调整过的Sheet。对生成的sheet经常会做一些调整，例如剔除透明像素，加背景色等等，调整后的结果保存在此对象中
	 */	
	public var adjustedSheet:SpriteSheet;
	
	/**
	 * 是否显示修剪空白后的帧的效果
	 */
	public var displayCrop:Boolean;
	
	public var resizeRect:Rectangle;
	
	/**
	 * 保存当前选择的帧的编号
	 */
	public var selectedFrameIndex:int=-1;
	
	public var selectedFrmaeNum:int = -1;
	
	public var selectedFrameIndices:Vector.<int>
	
	public var playing:Boolean;
}
}