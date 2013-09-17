package utils.calc
{
import flash.geom.Rectangle;

import org.zengrong.utils.MathUtil;

import vo.OptimizedResultVO;
import vo.PicPreferenceVO;

public class BasicCalculator implements IFrameCalculator
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
	public function calc($optimizedResult:OptimizedResultVO, $picPref:PicPreferenceVO):OptimizedResultVO
	{
		var __newResult:OptimizedResultVO = new OptimizedResultVO();
		calculate(	$optimizedResult.frameRects,
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
	 * @param $frameRects 当前帧的尺寸列表
	 * @param $newSizeRects 排列后的尺寸列表（一般提供一个等待填充的空列表，将被修改）
	 * @param $bigSheetRect 最终生成的大Sheet的尺寸（一般提供一个新的Rectangle， 将被修改）
	 * @param $picPref 优化参数
	 * @param $explicitSize 明确指定的宽度或高度
	 * @param $exeTime 调用次数，避免递归调用的死循环（以前使用static函数的时候）
	 */
	private function calculate(	$frameRects:Vector.<Rectangle>, 
									$newSizeRects:Vector.<Rectangle>,
									$bigSheetRect:Rectangle,
									$picPref:PicPreferenceVO,
									$explicitSize:int,
									$exeTime:int=0):void
	{
		if($frameRects.length==0) return;
		//单独处理第一帧，不需要计算
		var __frameRect:Rectangle = $frameRects[0];
		$newSizeRects[0] = new Rectangle(0,0,__frameRect.width, __frameRect.height);
		//当前帧在大Sheet中的位置和大小
		var __rectInSheet:Rectangle = new Rectangle(0,0,__frameRect.width,__frameRect.height);
		//trace('getSheetWH:', __rectInSheet, __frameRect, "bigSheet:", $bigSheetRect);
		//设置sheet的初始宽高
		if($picPref.limitWidth)
		{
			//默认使用明确指定的宽度
			$bigSheetRect.width = $explicitSize;
			//若限制宽度小于帧的宽度，就扩大限制宽度
			if($bigSheetRect.width<__frameRect.width) $bigSheetRect.width = __frameRect.width;
			//计算2的幂
			if($picPref.powerOf2) $bigSheetRect.width = MathUtil.nextPowerOf2($bigSheetRect.width);
			$bigSheetRect.height = __frameRect.height;
		}
		else
		{
			$bigSheetRect.height = $explicitSize;
			if($bigSheetRect.height<__frameRect.height) $bigSheetRect.height = __frameRect.height;
			if($picPref.powerOf2) $bigSheetRect.height = MathUtil.nextPowerOf2($bigSheetRect.height);
			$bigSheetRect.width = __frameRect.width;
		}
		//第1(0)帧已经处理过了，因此从第2(1)帧开始
		for (var i:int = 1; i < $frameRects.length; i++) 
		{
			__frameRect = $frameRects[i];
			updateRectInSheet(__rectInSheet, $bigSheetRect, __frameRect, $picPref.limitWidth);
			//trace('getSheetWH:', __rectInSheet, __frameRect, $bigSheetRect);
			$newSizeRects[i] = __rectInSheet.clone();
		}
		if($picPref.square)
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
					calculate($frameRects, $newSizeRects, $bigSheetRect, $picPref, __newWH, ++$exeTime);
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
		if($picPref.powerOf2)
		{
			$bigSheetRect.width = MathUtil.nextPowerOf2($bigSheetRect.width);
			$bigSheetRect.height = MathUtil.nextPowerOf2($bigSheetRect.height);
		}
	}
	
	/**
	 * 更新在Sheet中帧的Rect的位置，根据Rect位置计算出大Sheet的WH
	 * 会直接修改$rectInSheet和$whRect参数的值。
	 * @param $rectInSheet	当前处理的帧在整个Sheet中的位置和大小，会修改此参数的值
	 * @param $bigSheetRect	最终生成的大Sheet的尺寸，会修改此参数的值
	 * @param $frameRect	要处理的帧大小的Rect
	 * @param $limitW		为true代表限制宽度，否则是显示高度
	 */
	public function updateRectInSheet($rectInSheet:Rectangle, 
											 $bigSheetRect:Rectangle,
											 $frameRect:Rectangle,
											 $limitW:Boolean):void
	{
		//限制宽度的计算
		if($limitW)
		{
			$rectInSheet.height = $frameRect.height;
			//若限制宽度小于帧的宽度，就扩大限制宽度，并进入新行
			if($bigSheetRect.width < $frameRect.width)
			{
				$bigSheetRect.width = $frameRect.width;
				newRow($rectInSheet, $frameRect, $bigSheetRect);
			}
			//如果这一行的宽度已经不够放下当前的位图，就进入新行
			else if($rectInSheet.right + $frameRect.width > $bigSheetRect.width)
			{
				newRow($rectInSheet, $frameRect, $bigSheetRect);
			}
			//顺着往右放
			else
			{
				$rectInSheet.x += $rectInSheet.width;
				//如果当前帧比较高，就增加Sheet的高度
				if($bigSheetRect.height<$rectInSheet.bottom)
					$bigSheetRect.height = $rectInSheet.bottom;
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
			if($bigSheetRect.height < $frameRect.height)
			{
				$bigSheetRect.height = $frameRect.height;
				newColumn($rectInSheet, $frameRect, $bigSheetRect);
			}
			//如果这一列的高度已经放不下当前的位图，就进入新列
			else if($rectInSheet.bottom + $frameRect.height > $bigSheetRect.height)
			{
				newColumn($rectInSheet, $frameRect, $bigSheetRect);
			}
			//顺着往下放
			else
			{
				//如果当前帧比Sheet还要宽，就增大Sheet的宽度
				$rectInSheet.y += $rectInSheet.height;
				if($bigSheetRect.width<$rectInSheet.right)
					$bigSheetRect.width = $rectInSheet.right;
			}
			$rectInSheet.height = $frameRect.height;
		}
	}
	
	private function newRow($rectInSheet:Rectangle, $frameRect:Rectangle, $bigSheetRect:Rectangle):void
	{
		//让x回到行首
		$rectInSheet.x = 0;
		//更新新行的y值
		$rectInSheet.y = $bigSheetRect.height;
		//更新Sheet的高度
		$bigSheetRect.height += $frameRect.height;
	}
	
	private function newColumn($rectInSheet:Rectangle, $frameRect:Rectangle, $bigSheetRect:Rectangle):void
	{
		$rectInSheet.y = 0;
		$rectInSheet.x = $bigSheetRect.width;
		$bigSheetRect.width += $frameRect.width;
	}
}
}