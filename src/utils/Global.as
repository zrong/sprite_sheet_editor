package utils
{
import org.zengrong.display.spritesheet.SpriteSheet;

public class Global
{
	[Embed(source="/checks.png")]
	[Bindable] public var bmp_checks:Class;
	
	/**
	 * 保存root对象
	 */	
	[Bindable] public var root:SpriteSheetEditor;
	
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