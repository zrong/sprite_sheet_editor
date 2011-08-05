package utils
{
import flash.display.BitmapData;
import flash.filesystem.File;
import flash.geom.Rectangle;
import flash.net.FileFilter;

import mx.collections.ArrayCollection;

import org.zengrong.display.spritesheet.BMPSprite;
import org.zengrong.display.spritesheet.SpriteSheet;

public class Global
{
	/**
	 * 当前编辑器的状态
	 */
	[Bindable] public var currentState:String="start";
	
	/**
	 * 所有选择的文件列表
	 */	
	[Bindable] public var files:ArrayCollection;
	
	/**
	 * 保存root对象
	 */	
	[Bindable] public var root:SpriteSheetEditor;
	
	/**
	 * 显示背景的透明格子
	 */	
	[Bindable] public var checks:BitmapData;
	
	/**
	 * 刚生成的sheet，或者打开的sheet文件，保存在此对象中。在此sheet的基础上进行调整后保存
	 */	
	[Bindable] public var sheet:SpriteSheet;
	
	/**
	 * 保存调整过的Sheet。对生成的sheet经常会做一些调整，例如剔除透明像素，加背景色等等，调整后的结果保存在此对象中
	 */	
	[Bindable] public var adjustedSheet:SpriteSheet;
	
	/**
	 * sheet宽度
	 */	
	[Bindable] public var sheetWidth:int;
	
	/**
	 * sheet高度
	 */	
	[Bindable] public var sheetHeight:int;
	
	/**
	 * 帧大小
	 */	
	[Bindable] public var frameRect:Rectangle;
	
	/**
	 * 每帧是否采用原始大小
	 */	
	[Bindable] public var useOriginal:Boolean = false;
	
	/**
	 * 位图是否透明
	 */	
	[Bindable] public var isTransparent:Boolean;
	
	/**
	 * 位图是否平滑
	 */	
	[Bindable] public var isSmooth:Boolean;
	
	/**
	 * 选择的位图背景色
	 */	
	[Bindable] public var bgColor:uint;
	
	/**
	 * 要处理的第一帧
	 */	
	[Bindable] public var firstFrame:int;
	
	private static var _instance:Global;
	
	public static function get instance():Global
	{
		if(!_instance)
			_instance = new Global(new Singlton);
		return _instance;
	}
	
	public function Global($sig:Singlton)
	{
		if(!$sig) throw new TypeError('请使用Global.instance获取单例！');
	}
}
}
class Singlton{};