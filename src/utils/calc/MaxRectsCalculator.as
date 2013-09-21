package utils.calc
{
import flash.geom.Rectangle;

import vo.OptimizedResultVO;
import vo.PicPreferenceVO;

public class MaxRectsCalculator implements IFrameCalculator
{
	public function MaxRectsCalculator()
	{
	}
	
	private var _picPreference:PicPreferenceVO;
	
	public function get picPreference():PicPreferenceVO
	{
		return _picPreference;
	}
	
	public function set picPreference($vo:PicPreferenceVO):void
	{
		_picPreference = $vo;
	}
	
	public function optimize($optimizedResult:OptimizedResultVO):OptimizedResultVO
	{
		var __newResult:OptimizedResultVO = OptimizedResultVO.createByLength($optimizedResult.frameRects.length);
		__newResult.preference = $optimizedResult.preference;
		__newResult.bmds = $optimizedResult.bmds;
		__newResult.originRects = $optimizedResult.originRects;
		var __dimensions:uint = 0;
		var __frameRectArray:Array = [];
		for each(var $frameRect:Rectangle in $optimizedResult.frameRects)
		{
			__dimensions += $frameRect.width * $frameRect.height;
			__frameRectArray.push($frameRect);
		}
		//sort texture by size
		__frameRectArray.sort(sortFrameArray);
		
		var __widthDefault:int = _picPreference.explicitSize;
		
		if(__widthDefault == 0)
		{
			__widthDefault = Math.sqrt(__dimensions);
		}
		
		__widthDefault = getNearest2N(Math.max(__frameRectArray[0].width + _picPreference.spritePadding, __widthDefault));
		
		var __heightMax:uint = 40960;
		var __remainRectList:Vector.<Rectangle> = new Vector.<Rectangle>;
		__remainRectList.push(new Rectangle(0, 0, __widthDefault, __heightMax));
		
		var __isFit:Boolean;
		var __width:int;
		var __height:int;
		var _pivotX:Number;
		var _pivotY:Number;
		
		var __rect:Rectangle;
		var __rectPrev:Rectangle;
		var __rectNext:Rectangle;
		var __rectID:int;
		var __rectOriginID:int;
		
		do {
			//Find highest blank area
			__rect = getHighestRect(__remainRectList);
			__rectID = __remainRectList.indexOf(__rect);
			__isFit = false;
			var __frameRect:Rectangle = null;
			for(var __iT:int=0;__iT<__frameRectArray.length;__iT++) 
			{
				//check if the texture is fit
				__frameRect = __frameRectArray[__iT];
				//寻找原始的顺序
				__rectOriginID = $optimizedResult.frameRects.indexOf(__frameRect);
				__width = $frameRect.width +  _picPreference.spritePadding;
				__height = $frameRect.height +  _picPreference.spritePadding;
				if (__rect.width >= __width && __rect.height >= __height)
				{
					__isFit = true;
					break;
				}
			}
			if(__isFit)
			{
				//place texture if size is fit
				__frameRect.x = __rect.x;
				__frameRect.y = __rect.y;
				__frameRectArray.splice(__iT, 1);
				__remainRectList.splice(__rectID + 1, 0, new Rectangle(__rect.x + __width, __rect.y, __rect.width - __width, __rect.height));
				__rect.y += __height;
				__rect.width = __width;
				__rect.height -= __height;
				trace("fit:",__iT, __rectOriginID, __rect, __frameRect);
				__newResult.frameRects[__rectOriginID] = __frameRect;
			}
			else
			{
				//not fit, don't place it, merge blank area to others toghther
				if(__rectID == 0){
					__rectNext = __remainRectList[__rectID + 1];
				}else if(__rectID == __remainRectList.length - 1){
					__rectNext = __remainRectList[__rectID - 1];
				}else{
					__rectPrev = __remainRectList[__rectID - 1];
					__rectNext = __remainRectList[__rectID + 1];
					__rectNext = __rectPrev.height <= __rectNext.height?__rectNext:__rectPrev;
				}
				if(__rect.x < __rectNext.x){
					__rectNext.x = __rect.x;
				}
				__rectNext.width = __rect.width + __rectNext.width;
				__remainRectList.splice(__rectID, 1);
				trace("nofit:", __rect);
			}
		}
		while (__frameRectArray.length > 0);
		
		//calculate heightMax
		__heightMax = getNearest2N(__heightMax - getLowestRect(__remainRectList).height);
		__newResult.bigSheetRect.width = __widthDefault;
		__newResult.bigSheetRect.height = __heightMax;
		return __newResult;
	}
	
	private function getNearest2N(_n:uint):uint{
		return _n & _n - 1?1 << _n.toString(2).length:_n;
	}
	
	private function sortFrameArray($rect1:Rectangle, $rect2:Rectangle):int
	{
		var __v1:uint = int($rect1.width + $rect1.height);
		var __v2:uint = int($rect2.width + $rect2.height);
		if (__v1 == __v2) {
			return $rect1.width > $rect2.width ?-1:1;
		}
		return __v1 > __v1?-1:1;
	}
	
	private function getHighestRect($rectList:Vector.<Rectangle>):Rectangle
	{
		var __height:uint = 0;
		var __rectHighest:Rectangle;
		for each(var __rect:Rectangle in $rectList) 
		{
			if (__rect.height > __height) {
				__height = __rect.height;
				__rectHighest = __rect;
			}
		}
		return __rectHighest;
	}
	
	private function getLowestRect($rectList:Vector.<Rectangle>):Rectangle
	{
		var ___height:uint = 40960;
		var __rectLowest:Rectangle;
		for each(var _rect:Rectangle in $rectList) 
		{
			if (_rect.height < ___height) 
			{
				___height = _rect.height;
				__rectLowest = _rect;
			}
		}
		return __rectLowest;
	}
}
}