package utils.calc
{
import flash.geom.Rectangle;

import org.zengrong.utils.MathUtil;

import vo.OptimizedResultVO;
import vo.PicPreferenceVO;

public class BasicCalculator extends FrameCalculator
{
	public function BasicCalculator()
	{
	}

	/**
	 * 重新优化图像，返回一个新的已经优化过的OptimizedResultVO
	 * @param $optimizedResult 待优化对象
	 * @param $picPref 优化参数
	 * @return 返回一个已经优化过的OptimizedResultVO
	 */
	override public function calc($optimizedResult:OptimizedResultVO, $picPref:PicPreferenceVO):OptimizedResultVO
	{
		var __newResult:OptimizedResultVO = new OptimizedResultVO();
		calculate($optimizedResult.frameRects,
					__newResult.frameRects,
					__newResult.bigSheetRect,
					$picPref,
					$picPref.explicitSize);
		__newResult.bmds = $optimizedResult.bmds;
		__newResult.originRects = $optimizedResult.originRects;
		return __newResult;
	}
	
	/**
	 * 根据提供的Rectangle数组计算最终Sheet的宽高以及每帧在Sheet中的位置
	 * @param $frameRect 当前帧的独立大小
	 */
	private function calculate($frameRects:Vector.<Rectangle>, 
									 $newSizeRects:Vector.<Rectangle>,
									 $whRect:Rectangle,
									 $picPref:PicPreferenceVO,
									$wh:int):void
	{
		if($frameRects.length==0) return;
		var __frameRect:Rectangle = $frameRects[0];
		$newSizeRects[0] = new Rectangle(0,0,__frameRect.width, __frameRect.height);
		var __rectInSheet:Rectangle = new Rectangle(0,0,__frameRect.width,__frameRect.height);
		trace('getSheetWH:', __rectInSheet, __frameRect, $whRect);
		//设置sheet的初始宽高
		if($picPref.limitWidth)
		{
			//若限制宽度小于帧的宽度，就扩大限制宽度
			$whRect.width = $picPref.explicitSize;
			if($whRect.width<__frameRect.width) $whRect.width = __frameRect.width;
			//计算2的幂
			if($picPref.powerOf2) $whRect.width = MathUtil.nextPowerOf2($whRect.width);
			$whRect.height = __frameRect.height;
		}
		else
		{
			$whRect.height = $picPref.explicitSize;
			if($whRect.height<__frameRect.height) $whRect.height = __frameRect.height;
			if($picPref.powerOf2) $whRect.height = MathUtil.nextPowerOf2($whRect.height);
			$whRect.width = __frameRect.width;
		}
		for (var i:int = 1; i < $frameRects.length; i++) 
		{
			__frameRect = $frameRects[i];
			updateRectInSheet(__rectInSheet, $whRect, __frameRect, $picPref.limitWidth);
			trace('getSheetWH:', __rectInSheet, __frameRect, $whRect);
			$newSizeRects[i] = __rectInSheet.clone();
		}
		if($picPref.square)
		{
			//计算正方形的尺寸
			if($whRect.width!=$whRect.height)
			{
				//使用当前计算出的面积开方得到正方形的基准尺寸
				var __newWH:int = Math.sqrt($whRect.width*$whRect.height);
				//使用基准尺寸重新排列一次
				calculate($frameRects,$newSizeRects,$whRect,$picPref, __newWH);
				//trace('正方形计算1:', $whRect);
				//如果基准尺寸无法实现正方形尺寸，就使用结果WH中比较大的那个尺寸作为正方形边长
				if($whRect.width!=$whRect.height)
				{
					var __max:int = Math.max($whRect.width, $whRect.height);
					$whRect.width = __max;
					$whRect.height = __max;
				}
				//trace('正方形计算2:', $whRect);
			}
		}
		if($picPref.powerOf2)
		{
			$whRect.width = MathUtil.nextPowerOf2($whRect.width);
			$whRect.height = MathUtil.nextPowerOf2($whRect.height);
		}
	}
	
	/**
	 * 更新在Sheet中帧的Rect的位置，根据Rect位置计算出大Sheet的WH
	 * 会直接修改$rectInSheet和$whRect参数的值。
	 * @param $rectInSheet	当前处理的帧在整个Sheet中的位置和大小，会修改此参数的值
	 * @param $whRect		保存Sheet的W和H，会修改此参数的值
	 * @param $frameRect	要处理的帧大小的Rect
	 * @param $limitW		为true代表限制宽度，否则是显示高度
	 */
	public function updateRectInSheet($rectInSheet:Rectangle, 
											 $whRect:Rectangle,
											 $frameRect:Rectangle,
											 $limitW:Boolean):void
	{
		
		//限制宽度的计算
		if($limitW)
		{
			$rectInSheet.height = $frameRect.height;
			//若限制宽度小于帧的宽度，就扩大限制宽度，并进入新行
			if($whRect.width < $frameRect.width)
			{
				$whRect.width = $frameRect.width;
				newRow($rectInSheet, $frameRect, $whRect);
			}
				//如果这一行的宽度已经不够放下当前的位图，就进入新行
			else if($rectInSheet.right + $frameRect.width > $whRect.width)
			{
				newRow($rectInSheet, $frameRect, $whRect);
			}
			else
			{
				$rectInSheet.x += $rectInSheet.width;
				//如果当前帧比较高，就增加Sheet的高度
				if($whRect.height<$rectInSheet.bottom)
					$whRect.height = $rectInSheet.bottom;
			}
			//更新帧的宽
			$rectInSheet.width = $frameRect.width;
		}
			//限制高度的计算
		else
		{
			//更新帧的宽
			$rectInSheet.width = $frameRect.width;
			//若限制高度小于帧的高度，就扩大限制高度，并进入新列
			if($whRect.height < $frameRect.height)
			{
				$whRect.height = $frameRect.height;
				newColumn($rectInSheet, $frameRect, $whRect);
			}
				//如果这一列的高度已经放不下当前的位图，就进入新列
			else if($rectInSheet.bottom + $frameRect.height > $whRect.height)
			{
				newColumn($rectInSheet, $frameRect, $whRect);
			}
			else
			{
				//如果当前帧比Sheet还要宽，就增大Sheet的宽度
				$rectInSheet.y += $rectInSheet.height;
				if($whRect.width<$rectInSheet.right)
					$whRect.width = $rectInSheet.right;
			}
			
			$rectInSheet.height = $frameRect.height;
		}
	}
	
	private static function newRow($rectInSheet:Rectangle, $frameRect:Rectangle, $whRect:Rectangle):void
	{
		//让x回到行首
		$rectInSheet.x = 0;
		//更新新行的y值
		$rectInSheet.y = $whRect.height;
		//更新Sheet的高度
		$whRect.height += $frameRect.height;
	}
	
	private static function newColumn($rectInSheet:Rectangle, $frameRect:Rectangle, $whRect:Rectangle):void
	{
		$rectInSheet.y = 0;
		$rectInSheet.x = $whRect.width;
		$whRect.width += $frameRect.width;
	}
}
}