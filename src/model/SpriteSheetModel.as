package model
{
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import org.robotlegs.mvcs.Actor;
import org.zengrong.display.spritesheet.MaskType;
import org.zengrong.display.spritesheet.SpriteSheet;
import org.zengrong.display.spritesheet.SpriteSheetMetadata;
import org.zengrong.utils.BitmapUtil;

import utils.calc.CalculatorType;
import utils.calc.FrameCalculatorManager;
import utils.calc.IFrameCalculator;

import vo.OptimizedResultVO;
import vo.PicPreferenceVO;
import gnu.as3.gettext.FxGettext;

/**
 * 暂存编辑过程中的位图资源
 * @author zrong(zengrong.net)
 * Creation: 2012-07-25
 * Modification: 2013-09-17
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
	public function replaceOriginalSheet($sheet:SpriteSheet):void
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

	public function addOriginalFrame($bmd:BitmapData, $sizeRect:Rectangle=null, $originalRect:Rectangle=null, $name:String=null):void
	{
		_originalSheet.addFrame($bmd, $sizeRect, $originalRect, $name);
	}
	
	public function addOriginalFrameAt($index:int, $bmd:BitmapData, $sizeRect:Rectangle=null, $originalRect:Rectangle=null,$name:String=null):void
	{
		_originalSheet.addFrameAt($index, $bmd, $sizeRect, $originalRect, $name);
	}
		
	/**
	 * 基于原始的Sheet重建调整后的Sheet
	 */
	public function rebuildAdjustedSheet():void
	{
		if(!_originalSheet) throw new TypeError(FxGettext.gettext("Original Sprite Sheet is unavailable！"));
		if(_adjustedSheet) _adjustedSheet.destroy();
		_adjustedSheet = _originalSheet.clone();
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
	
	/**
	 * 根据提供的参数对Sheet进行优化
	 * @param $picPref BuildSetting组件中提供的优化
	 * @return 优化之后的图像数组
	 */
	public function optimize($picPref:PicPreferenceVO):OptimizedResultVO
	{
		var __list:OptimizedResultVO = getRectsAndBmds($picPref);
		var __calculator:IFrameCalculator = FrameCalculatorManager.getCalculator(CalculatorType.BASIC);
		__calculator.picPreference = $picPref;
		return __calculator.optimize(__list);
	}
	
	/**
	 * 返回生成的原始帧rect尺寸（origin），在大sheet中的rect尺寸（frame），以及所有的BitmapData列表（bmd）
	 * 这个方法只负责计算单个sprite的尺寸信息，以及大Sheet中每个Sprite的修剪情况，并不负责计算Sprite在大Sheet中的坐标信息
	 * 大Sheet中的坐标信息在IFrameCalculator中设置
	 */
	private function getRectsAndBmds($picPref:PicPreferenceVO):OptimizedResultVO
	{
		//所有的BitmapData列表
		var __bmds:Vector.<BitmapData> = null;
		//修剪过的rect列表，这个Rectangle并不包含在大sheet中的坐标信息
		//大sheet中的坐标信息在IFrameCalculator中设置
		var __frames:Vector.<Rectangle> = null;
		//原始的（未修剪）rect列表
		var __origins:Vector.<Rectangle> = null; 
		//处理修剪
		if($picPref.trim)
		{
			__frames = new Vector.<Rectangle>;
			__origins = new Vector.<Rectangle>; 
			//用于保存执行trim方法后的结果
			var __trim:Object = null;
			var i:int=0;
			if($picPref.resetRect)
			{
				__bmds = new Vector.<BitmapData>;
				for (i=0; i < originalSheet.metadata.totalFrame; i++) 
				{
					//对每张小图进行修剪操作
					__trim = BitmapUtil.trimByColor(originalSheet.getBMDByIndex(i));
					__frames[i] = __trim.rect;
					//重设帧的尺寸，就使用trim过后的帧的宽高建立一个新的Rect尺寸，并更新bmd
					__origins[i] = new Rectangle(0,0,__trim.rect.width,__trim.rect.height);
					__bmds[i] = __trim.bitmapData;
				}
			}
			else
			{
				for (i=0; i < originalSheet.metadata.totalFrame; i++) 
				{
					//对每张小图进行修剪操作
					__trim = BitmapUtil.trimByColor(originalSheet.getBMDByIndex(i));
					var __sizeRect:Rectangle = originalSheet.metadata.originalFrameRects[i];
					__frames[i] = __trim.rect;
					//不重设帧的尺寸，就使用原始大小的宽高。同时计算trim后的xy的偏移。
					//因为获得xy的偏移是基于与原始帧大小的正数，要将其转换为基于trim后的帧的偏移，用0减
					__origins[i] = new Rectangle(
						0-__trim.rect.x,
						0-__trim.rect.y,
						__sizeRect.width, 
						__sizeRect.height);
				}
				//不重设尺寸的情况下，不更新bmd，因为原始尺寸没变。SpriteSheet中保存的bmdList，永远都与原始尺寸相同
				__bmds = originalSheet.cloneFrames();
			}
		}
		//不修剪就复制
		else
		{
			//bmdlist永远都是原始尺寸的，因此不需要重新绘制
			__bmds = originalSheet.cloneFrames();
			__frames = originalSheet.metadata.frameRects.concat();
			__origins = originalSheet.metadata.originalFrameRects.concat();
			//不trim，将以前trim过的信息还原
			for (var j:int = 0; j < __frames.length; j++) 
			{
				__frames[j].width = __origins[j].width;
				__frames[j].height = __origins[j].height;
				__origins[j].x = 0;
				__origins[j].y = 0;
			}
		}
		//对位图和尺寸进行缩放
		if($picPref.scale != 1)
		{
			for(var k:int=0;k<__bmds.length;k++)
			{
				var __oldBmd:BitmapData = __bmds[k];
				var __scaleBmd:BitmapData = new BitmapData(
					__oldBmd.width*$picPref.scale, 
					__oldBmd.height*$picPref.scale, 
					$picPref.transparent, 
					$picPref.bgColor);
				var __matrix:Matrix = new Matrix();
				__matrix.scale($picPref.scale, $picPref.scale);
				__scaleBmd.draw(__oldBmd, __matrix, null, null, null, $picPref.smooth);
				__bmds[k] = __scaleBmd;
				var __oldFrameRect:Rectangle = __frames[k];
				__frames[k] = new Rectangle(
					__oldFrameRect.x*$picPref.scale,
					__oldFrameRect.y*$picPref.scale,
					__oldFrameRect.width*$picPref.scale,
					__oldFrameRect.height*$picPref.scale );
				var __oldOriginRect:Rectangle = __origins[k];
				__origins[k] = new Rectangle(
					__oldOriginRect.x*$picPref.scale,
					__oldOriginRect.y*$picPref.scale,
					__oldOriginRect.width*$picPref.scale,
					__oldOriginRect.height*$picPref.scale );
			}
		}
		return new OptimizedResultVO(__bmds, __origins, __frames);
	}
}
}