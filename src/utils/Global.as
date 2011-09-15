package utils
{
import org.zengrong.display.spritesheet.SpriteSheet;

public class Global
{
	[Embed(source="/checks.png")]
	[Bindable] public var bmp_checks:Class;
	/**
	 * 当前编辑器的状态
	 */
	[Bindable] public var currentState:String="start";
	
	/**
	 * 保存root对象
	 */	
	[Bindable] public var root:SpriteSheetEditor;
	
	/**
	 * 刚生成的sheet，或者打开的sheet文件，保存在此对象中。在此sheet的基础上进行调整后保存
	 */	
	[Bindable] public var sheet:SpriteSheet;
	
	/**
	 * 保存调整过的Sheet。对生成的sheet经常会做一些调整，例如剔除透明像素，加背景色等等，调整后的结果保存在此对象中
	 */	
	[Bindable] public var adjustedSheet:SpriteSheet;
	
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