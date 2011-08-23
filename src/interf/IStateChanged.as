package interf
{
public interface IStateChanged
{
	function enterState($old:String, $new:String):void;
	function exitState():void;
}
}