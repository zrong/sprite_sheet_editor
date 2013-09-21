package utils.calc
{
import flash.geom.Rectangle;

import gnu.as3.gettext.FxGettext;

import org.zengrong.utils.MathUtil;

import vo.OptimizedResultVO;
import vo.PicPreferenceVO;

public class BasicCalculator implements IFrameCalculator
{
	public function BasicCalculator()
	{
	}
	
	private var _picPreference:PicPreferenceVO;
	
	/**
	 * 暂存PicPreference，这样就不用再传递
	 */
	public function get picPreference():PicPreferenceVO
	{
		return _picPreference;
	}
	
	public function set picPreference(value:PicPreferenceVO):void
	{
		_picPreference = value;
	}

	/**
	 * @inheritDoc
	 */
	public function optimize($optimizedResult:OptimizedResultVO):OptimizedResultVO
	{
		if(!_picPreference) throw new TypeError(FxGettext.gettext("Please set the picPreference property first!"));
		var __newResult:OptimizedResultVO = new OptimizedResultVO();
		calculate(	$optimizedResult.frameRects,
					__newResult.frameRects,
					__newResult.bigSheetRect,
					_picPreference.explicitSize);
		__newResult.bmds = $optimizedResult.bmds;
		__newResult.originRects = $optimizedResult.originRects;
		__newResult.preference = $optimizedResult.preference;
		return __newResult;
	}
	
	/**
	 * 计算并更新第一帧信息，并返回第一帧在大Sheet中的位置
	 */
	private function calculateFirstRect( $bigSheetRect:Rectangle, $frameRect:Rectangle,$explicitSize:int):Rectangle
	{
		if(_picPreference.limitWidth)
		{
			//默认使用明确指定的宽度
			$bigSheetRect.width = addBorderPadding($explicitSize, false);
			//若限制宽度小于帧的宽度，就扩大限制宽度
			if($bigSheetRect.width<$frameRect.width) $bigSheetRect.width = addBorderPadding($frameRect.width, false);
			//计算2的幂
			if(_picPreference.powerOf2) $bigSheetRect.width = MathUtil.nextPowerOf2($bigSheetRect.width);
			$bigSheetRect.height = addBorderPadding($frameRect.height, false);
		}
		else
		{
			$bigSheetRect.height = addBorderPadding($explicitSize, false);
			if($bigSheetRect.height<$frameRect.height) $bigSheetRect.height = addBorderPadding($frameRect.height, false);
			if(_picPreference.powerOf2) $bigSheetRect.height = MathUtil.nextPowerOf2($bigSheetRect.height);
			$bigSheetRect.width = addBorderPadding($frameRect.width, false);
		}
		return new Rectangle(_picPreference.borderPadding,
			_picPreference.borderPadding,
			$frameRect.width,$frameRect.height);
	}
	
	/**
	 * 更新在Sheet中帧的Rect的位置，根据Rect位置计算出大Sheet的WH
	 * 会直接修改$rectInSheet和$whRect参数的值。
	 * @param $rectInSheet	当前处理的帧在整个Sheet中的位置和大小，会修改此参数的值
	 * @param $bigSheetRect	最终生成的大Sheet的尺寸，会修改此参数的值
	 * @param $frameRect	要处理的帧大小的Rect
	 * @param $limitW		为true代表限制宽度，否则是显示高度
	 */
	private function updateRectInSheet($rectInSheet:Rectangle, 
									  $bigSheetRect:Rectangle,
									  $frameRect:Rectangle,
									  $limitW:Boolean):void
	{
		if(!_picPreference) return;
		//限制宽度的计算
		if($limitW)
		{
			$rectInSheet.height = $frameRect.height;
			//若限制宽度小于帧的宽度，就扩大限制宽度，并进入新行
			if($bigSheetRect.width < $frameRect.width)
			{
				$bigSheetRect.width = addBorderPadding($frameRect.width, false);
				newRow($rectInSheet, $frameRect, $bigSheetRect);
				$rectInSheet.width = $frameRect.width;
			}
			//如果这一行的宽度已经不够放下当前的位图，就进入新行
			else if($rectInSheet.right + $frameRect.width > $bigSheetRect.width)
			{
				newRow($rectInSheet, $frameRect, $bigSheetRect);
				$rectInSheet.width = $frameRect.width;
			}
			//顺着往右放
			else
			{
				$rectInSheet.x += addSpritePadding($rectInSheet.width);
				$rectInSheet.width = $frameRect.width;
				checkSheetThreshold($bigSheetRect, $rectInSheet);
			}
		}
		//限制高度的计算
		else
		{
			//更新帧的宽
			$rectInSheet.width = $frameRect.width;
			//若限制高度小于帧的高度，就扩大限制高度，并进入新列
			if($bigSheetRect.height < $frameRect.height)
			{
				$bigSheetRect.height = addBorderPadding($frameRect.height, false);
				newColumn($rectInSheet, $frameRect, $bigSheetRect);
				$rectInSheet.height = $frameRect.height;
			}
			//如果这一列的高度已经放不下当前的位图，就进入新列
			else if($rectInSheet.bottom + $frameRect.height > $bigSheetRect.height)
			{
				newColumn($rectInSheet, $frameRect, $bigSheetRect);
				$rectInSheet.height = $frameRect.height;
			}
			//顺着往下放
			else
			{
				$rectInSheet.y += addSpritePadding($rectInSheet.height);
				$rectInSheet.height = $frameRect.height;
				checkSheetThreshold($bigSheetRect, $rectInSheet);
				
			}
		}
	}
	
	/**
	 * 检测放置了当前frame之后，bigSheet的宽度和高度是否可以容纳它（们）
	 * 若无法容纳，就增大bigSheet的宽高
	 */
	private function checkSheetThreshold($bigSheetRect:Rectangle, $rectInSheet:Rectangle):void
	{
		if($bigSheetRect.height<$rectInSheet.bottom)
			$bigSheetRect.height = $rectInSheet.bottom;
		if($bigSheetRect.width<$rectInSheet.right)
			$bigSheetRect.width = $rectInSheet.right;
	}
	
	/**
	 * 计算完毕后，最后调用。一般用于计算的收尾工作
	 */
	private function calculateWhenUpdateDone($bigSheetRect:Rectangle):void
	{
		//为bigSheet加入结束的borderPadding
		$bigSheetRect.width = addBorderPadding($bigSheetRect.width, false);
		$bigSheetRect.height = addBorderPadding($bigSheetRect.height, false);
	}
	
	/**
	 * 根据提供的Rectangle数组计算最终Sheet的宽高以及每帧在Sheet中的位置
	 * 这个方法仅计算sprite在大Sheet中的坐标信息，每个sprite的尺寸信息，在SpriteSheetModel.getRectsAndBmds中计算
	 * @param $frameRects 当前帧的尺寸列表
	 * @param $newSizeRects 排列后的尺寸列表（一般提供一个等待填充的空列表，将被修改）
	 * @param $bigSheetRect 最终生成的大Sheet的尺寸（一般提供一个新的Rectangle， 将被修改）
	 * @param $picPref 优化参数
	 * @param $explicitSize 明确指定的宽度或高度
	 * @param $exeTime 调用次数，避免递归调用的死循环（以前使用static函数的时候没有递归调用，可能是AS3机制不同）
	 */
	private function calculate(	$frameRects:Vector.<Rectangle>, 
									$newSizeRects:Vector.<Rectangle>,
									$bigSheetRect:Rectangle,
									$explicitSize:int,
									$exeTime:int=0):void
	{
		if($frameRects.length==0) return;
		//单独处理第一帧，不需要计算
		var __frameRect:Rectangle = $frameRects[0];
		//设置sheet的初始宽高
		//获得当前帧在大Sheet中的位置和大小
		var __rectInSheet:Rectangle = calculateFirstRect($bigSheetRect, __frameRect, $explicitSize);
		$newSizeRects[0] = __rectInSheet.clone();
		//trace('getSheetWH:', __rectInSheet, __frameRect, "bigSheet:", $bigSheetRect);
		//处理所有帧。因为第1(0)帧在上面已经处理过了，因此从第2(1)帧开始
		for (var i:int = 1; i < $frameRects.length; i++) 
		{
			__frameRect = $frameRects[i];
			updateRectInSheet(__rectInSheet, $bigSheetRect, __frameRect, _picPreference.limitWidth);
			//trace('getSheetWH:', __rectInSheet, __frameRect, $bigSheetRect);
			$newSizeRects[i] = __rectInSheet.clone();
		}
		//最后的计算
		calculateWhenUpdateDone($bigSheetRect);
		if(_picPreference.square)
		{
			//计算正方形的尺寸
			if($bigSheetRect.width!=$bigSheetRect.height)
			{
				//trace('getSheetWH,bigSheetRect:', $bigSheetRect);
				//使用当前计算出的面积开方得到正方形的基准尺寸
				var __newWH:int = Math.sqrt($bigSheetRect.width*$bigSheetRect.height);
				//trace("newWH:", __newWH, $explicitSize);
				
				//使用基准尺寸重新排列一次
				if($exeTime==0)
				{
					//递归调用，并确保仅递归一次
					calculate($frameRects, $newSizeRects, $bigSheetRect, __newWH, ++$exeTime);
					//trace('正方形计算1,bigSheet:', $bigSheetRect);
				}
				//如果基于基准尺寸重拍后依然无法实现正方形尺寸，就使用较大的尺寸作为正方形边长
				else if($bigSheetRect.width!=$bigSheetRect.height)
				{
					var __max:int = Math.max($bigSheetRect.width, $bigSheetRect.height);
					$bigSheetRect.width = __max;
					$bigSheetRect.height = __max;
				}
				//trace('正方形计算2,bigSheet:', $bigSheetRect);
			}
		}
		if(_picPreference.powerOf2)
		{
			$bigSheetRect.width = MathUtil.nextPowerOf2($bigSheetRect.width);
			$bigSheetRect.height = MathUtil.nextPowerOf2($bigSheetRect.height);
		}
	}
	
	private function addBorderPadding($value:int, $twice:Boolean=true):int
	{
		return _picPreference.borderPadding*($twice?2:1) + $value;
	}
	
	private function addSpritePadding($value:int):int
	{
		return _picPreference.spritePadding + $value;
	}

	
	private function newRow($rectInSheet:Rectangle, $frameRect:Rectangle, $bigSheetRect:Rectangle):void
	{
		//让x回到行首，前面加上borderPadding
		$rectInSheet.x = addBorderPadding(0, false);
		//更新新行的y值，中间加上spritePadding
		$rectInSheet.y = addSpritePadding($bigSheetRect.height);
		//更新Sheet的高度
		$bigSheetRect.height = $rectInSheet.bottom;
	}
	
	private function newColumn($rectInSheet:Rectangle, $frameRect:Rectangle, $bigSheetRect:Rectangle):void
	{
		$rectInSheet.y = addBorderPadding(0, false);
		$rectInSheet.x = addSpritePadding($bigSheetRect.width);
		$bigSheetRect.width = $rectInSheet.right;
	}
}
}