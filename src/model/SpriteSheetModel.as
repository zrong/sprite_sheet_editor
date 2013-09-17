package model
{
import flash.display.BitmapData;
import flash.geom.Rectangle;

import org.robotlegs.mvcs.Actor;
import org.zengrong.display.spritesheet.MaskType;
import org.zengrong.display.spritesheet.SpriteSheet;
import org.zengrong.display.spritesheet.SpriteSheetMetadata;
import org.zengrong.utils.BitmapUtil;

import utils.calc.FrameCalculatorManager;
import utils.calc.CalculatorType;

import vo.OptimizedResultVO;
import vo.PicPreferenceVO;
import utils.calc.IFrameCalculator;

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
	
	public var resizeRect:Rectangle;
	
	/**
	 * 保存当前选择的帧的编号
	 */
	public var selectedFrameIndex:int=-1;
	
	public var selectedFrmaeNum:int = -1;
	
	public var selectedFrameIndices:Vector.<int>;
	
	public var playing:Boolean;
	
	public function resetSheet($bmd:BitmapData=null, $meta:SpriteSheetMetadata=null):void
	{
		if(_originalSheet) _originalSheet.destroy();
		_originalSheet = new SpriteSheet($bmd, $meta);
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
	
	public function getBMDList($crop:Boolean):Vector.<BitmapData>
	{
		if($crop)
			return adjustedSheet.getAll();
		return originalSheet.getAll();
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
		
	/**
	 * 重新设置Sheet中的帧信息，并重绘Sheet位图
	 * @param	$bmd
	 * @param	$list
	 */
	public function redrawAdjustedSheet($bmd:BitmapData, $list:OptimizedResultVO):void
	{
		_adjustedSheet.setFrames($list.bmds, $list.frameRects, $list.originRects, originalSheet.metadata.names);
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
	 * 绘制Mask，返回带有Mask的位图（如果有mask的话）
	 */
	public function getBitmapDataForSave($maskType:int, $transparent:Boolean, $bgcolor:uint):BitmapData
	{
		if(MaskType.useMask($maskType))
		{
			return BitmapUtil.getBitmapDataWithMask(adjustedSheet.bitmapData, $maskType == MaskType.HOR_MASK, $transparent, $bgcolor);
		}
		return adjustedSheet.bitmapData;
	}
	
	public function optimize($picPref:PicPreferenceVO):OptimizedResultVO
	{
		var __list:OptimizedResultVO = getRectsAndBmds($picPref.trim, $picPref.resetRect);
		var __calculator:IFrameCalculator = FrameCalculatorManager.getCalculator(CalculatorType.BASIC);
		return __calculator.calc(__list, $picPref);
	}
	
	/**
	 * 返回生成的原始帧rect尺寸（origin），在大sheet中的rect尺寸（frame），以及所有的BitmapData列表（bmd）
	 * @param $trim 是否修剪
	 * @param $reset 是否重置大小
	 */
	private function getRectsAndBmds($trim:Boolean, $reset:Boolean):OptimizedResultVO
	{
		//所有的BitmapData列表
		var __bmd:Vector.<BitmapData> = null;
		//在大sheet中的rect列表
		var __frame:Vector.<Rectangle> = null;
		//原始的（在程序中使用的）rect列表
		var __origin:Vector.<Rectangle> = null; 
		if($trim)
		{
			__bmd = new Vector.<BitmapData>;
			__frame = new Vector.<Rectangle>;
			__origin = new Vector.<Rectangle>; 
			var __sizeRect:Rectangle = null;
			//用于保存执行trim方法后的结果
			var __trim:Object = null;
			for (var i:int=0; i < originalSheet.metadata.totalFrame; i++) 
			{
				__trim = BitmapUtil.trim(originalSheet.getBMDByIndex(i));
				__sizeRect = originalSheet.metadata.originalFrameRects[i];
				__frame[i] = __trim.rect;
				//如果重设帧的尺寸，就使用trim过后的帧的宽高建立一个新的Rect尺寸，并更新bmd
				if($reset)
				{
					__origin[i] = new Rectangle(0,0,__trim.rect.width,__trim.rect.height);
					__bmd[i] = __trim.bitmapData;
				}
				else
				{
					//如果不重设帧的尺寸，就使用原始大小的宽高。同时计算trim后的xy的偏移。
					//因为获得xy的偏移是基于与原始帧大小的正数，要将其转换为基于trim后的帧的偏移，用0减
					//不重设尺寸的情况下，不更新bmd，因为原始尺寸没变。SpriteSheet中保存的bmdList，永远都与原始尺寸相同
					__bmd = originalSheet.cloneFrames();
					__origin[i] = new Rectangle(
						0-__trim.rect.x,
						0-__trim.rect.y,
						__sizeRect.width, 
						__sizeRect.height);
				}
			}
		}
		else
		{
			//bmdlist永远都是原始尺寸的，因此不需要重新绘制
			__bmd = originalSheet.cloneFrames();
			__frame = originalSheet.metadata.frameRects.concat();
			__origin = originalSheet.metadata.originalFrameRects.concat();
			//不trim，将以前trim过的信息还原
			for (var j:int = 0; j < __frame.length; j++) 
			{
				__frame[j].width = __origin[j].width;
				__frame[j].height = __origin[j].height;
				__origin[j].x = 0;
				__origin[j].y = 0;
			}
		}
		return  new OptimizedResultVO(__bmd, __origin, __frame);
	}

}
}