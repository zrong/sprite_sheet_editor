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
	
	public function calculateFirstRect($bigSheetRect:Rectangle, $frameRect:Rectangle, $explicitSize:int):Rectangle
	{
		return null;
	}
	
	public function updateRectInSheet($rectInSheet:Rectangle, $bigSheetRect:Rectangle, $frameRect:Rectangle, $limitW:Boolean):void
	{
	}
	
	public function calculateWhenUpdateDone($bigSheetRect:Rectangle):void
	{
	}
	
	public function optimize($optimizedResult:OptimizedResultVO):OptimizedResultVO
	{
		return null;
	}
}
}