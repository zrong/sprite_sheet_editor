package view.comps 
{
	import gnu.as3.gettext.FxGettext;
	import mx.controls.Spacer;
	import spark.components.CheckBox;
	import spark.components.HGroup;
	import spark.components.Button;
	import spark.layouts.VerticalLayout;
/**
 * 专用于SSPreview界面的大小设定
 * @author zrong
 */
public class TransformToolControlBarForSS extends TransformToolControlBar 
{
	public function TransformToolControlBarForSS() 
	{
		super();
		this.maxlimi
		var __layout:VerticalLayout = new VerticalLayout();
		__layout.horizontalAlign = "center";
		this.layout = __layout;
	}
	
	public var saveResizeBTN:Button = new Button();
	
	protected override function createChildren():void 
	{
		super.createChildren();
		var __grp:HGroup = new HGroup();
		__grp.addElement(useCustomSizeCB);
		__grp.addElement(createSpacer());
		__grp.addElement(createCheckBox());
		this.addElement(__grp);
		this.addElement(nsGrp);
	}
	
	private function createSpacer():Spacer
	{
		var __spacer:Spacer = new Spacer();
		__spacer.percentHeight = 100;
		__spacer.height = 20;
		return __spacer;
	}
	
	private function createCheckBox():CheckBox
	{
		useCustomSizeCB.label = FxGettext.gettext("Adjust the original size(x,y,w,h)");
		useCustomSizeCB.toolTip = FxGettext.gettext("Is selected, the original size is reduced. But you can still be executed 'Trim blank' again on the basis of reduced size.");
	}
	
	private function createButton():Button
	{
		saveResizeBTN.label  = FxGettext.gettext("Do adjusting");
		saveResizeBTN.toolTip = FxGettext.gettext("Recalculated according to the original size adjusted, and immediate optimization.\nThis action will directly modify the size of the original size.")
	}
	/**
	<s:HGroup horizontalAlign="center" width="100%">
		<s:CheckBox id="resizeOriginCB" enabled="{!ani.scaleContent}" >
			<s:label>{FxGettext.gettext("Adjust the original size(x,y,w,h)")}</s:label>
			<s:toolTip>{FxGettext.gettext("Is selected, the original size is reduced. But you can still be executed 'Trim blank' again on the basis of reduced size.")}</s:toolTip>
		</s:CheckBox>
		<s:Spacer width="100%" height="20"/>
		<s:Button id="saveResizeBTN" enabled="false" >
			<s:label>{FxGettext.gettext("Do adjusting")}</s:label>
			<s:toolTip>{FxGettext.gettext("Recalculated according to the original size adjusted, and immediate optimization.\nThis action will directly modify the size of the original size.")}</s:toolTip>
		</s:Button>
	</s:HGroup>
	<s:HGroup width="100%" enabled="{resizeOriginCB.selected}">
		<s:NumericStepper id="frameX" width="100%"  minimum="0" maximum="{ani.sourceWidth-1}" change="handler_frameChange(event)"/>
		<s:NumericStepper id="frameY" width="100%"  minimum="0" maximum="{ani.sourceHeight-1}" change="handler_frameChange(event)"/>
		<s:NumericStepper id="frameW" width="100%" minimum="1" maximum="{ani.sourceWidth}" change="handler_frameChange(event)"/>
		<s:NumericStepper id="frameH" width="100%" minimum="1" maximum="{ani.sourceHeight}" change="handler_frameChange(event)"/>
	</s:HGroup>
	**/
}
}