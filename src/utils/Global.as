package utils
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.ui.Mouse;
import flash.ui.MouseCursorData;

public class Global
{
	[Embed(source="/../asset/embed/chess.png")]
	public static const BMP_CHESS:Class;
	
	[Embed(source="/../asset/embed/about.txt",mimeType="application/octet-stream")] 
	public static const ABOUT_TEXT:Class;
	
	//Assets.swf来自于Flex框架 %FLEX_SDK%\frameworks\projects\framework\assets\Assets.swf
	[Embed(source="Assets.swf",symbol="mx.skins.cursor.VBoxDivider")]
	public static const MC_CURSOR_VDIVIDER:Class;
	
	[Embed(source="Assets.swf",symbol="mx.skins.BoxDividerSkin")]
	public static const MC_BOX_DIVIDER:Class;
	
	public static const VDIVIDER:String = 'vdivider';
	
	/**
	 * 保存root对象
	 */	
	public static var root:SpriteSheetEditor;
	
	public static var bmd_chess:BitmapData;
	
	public static var cursor_vdivider:MouseCursorData;
	
	public static function init($root:SpriteSheetEditor):void
	{
		root = $root;
		var __bmp:Bitmap = new BMP_CHESS as Bitmap;
		bmd_chess = __bmp.bitmapData;
		
		var __sp:Sprite = new MC_CURSOR_VDIVIDER as Sprite;
		var __bmd:BitmapData = new BitmapData(16, 16, true, 0x00000000);
		__bmd.drawWithQuality(__sp, new Matrix(1,0,0,1, 8, 8), null, null, null, true, StageQuality.BEST);
		cursor_vdivider = new MouseCursorData();
		cursor_vdivider.data = Vector.<BitmapData>([__bmd]);
		cursor_vdivider.hotSpot = new Point(8,8);
		Mouse.registerCursor(VDIVIDER, cursor_vdivider);
	}
}
}