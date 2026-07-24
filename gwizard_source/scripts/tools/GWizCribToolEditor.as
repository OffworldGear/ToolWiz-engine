package tools
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import comps.GWizPopUp;
   import configinfo.GWizSettings;
   import feedsspeeds.GWizFeedsSpeeds2;
   import feedsspeeds.GWizMfgCutterSpecs;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.Proxy;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.utils.ChangeWatcher;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.CheckBox;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.TextInput;
   import spark.components.VGroup;
   import utils.ColorPalette;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizCribToolEditor extends GWizPopUp implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizToolEditor");
      
      private static var _1674103052ignoreLockForToolCrib:Boolean = false;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _1070003602Clockwise:CheckBox;
      
      private var _826465597DescLabel:Label;
      
      private var _2104126103Field1:TextInput;
      
      private var _2104126104Field2:TextInput;
      
      private var _2104126105Field3:TextInput;
      
      private var _2104126106Field4:TextInput;
      
      private var _1511422423FromFeedsSpeeds:Button;
      
      private var _771909245HolderDesc:TextInput;
      
      private var _1083478256HolderDia:GWizNumStep;
      
      private var _1083470679HolderLen:GWizNumStep;
      
      private var _772405030HolderType:GWizToolHolderDDList;
      
      private var _2099925287Insert:TextInput;
      
      private var _226242346JobCode:TextInput;
      
      private var _121906283PricePaid:GWizNumStep;
      
      private var _1355179215Product:TextInput;
      
      private var _175999337ProductLink:TextInput;
      
      private var _81558Qty:GWizNumStep;
      
      private var _1431617269SerialNo:TextInput;
      
      private var _1226533941ShoulderLen:GWizNumStep;
      
      private var _2579998Slot:NumericStepper;
      
      private var _1808614382Status:GWizToolStatusDDList;
      
      private var _1213577551TaperAngle2:GWizNumStep;
      
      private var _710237386ThreadPitch:GWizNumStep;
      
      private var _302192831TipLength:GWizNumStep;
      
      private var _2612664Tool:GWizToolMenu;
      
      private var _919276975ToolIcon:Image;
      
      private var _1784194663ToolNo:TextInput;
      
      private var _1573588780ToolPanel:GWizForePanel;
      
      private var _1736208024Vendor:TextInput;
      
      private var _83376007XComp:GWizNumStep;
      
      private var _85223049ZComp:GWizNumStep;
      
      private var _85332662ZGeom:GWizNumStep;
      
      public var _GWizCribToolEditor_GWizForePanel2:GWizForePanel;
      
      public var _GWizCribToolEditor_GWizForePanel4:GWizForePanel;
      
      public var _GWizCribToolEditor_GWizForePanel5:GWizForePanel;
      
      public var _GWizCribToolEditor_GWizForePanel6:GWizForePanel;
      
      public var _GWizCribToolEditor_GWizForePanel7:GWizForePanel;
      
      public var _GWizCribToolEditor_GWizForePanel8:GWizForePanel;
      
      public var _GWizCribToolEditor_Label15:Label;
      
      public var _GWizCribToolEditor_Label16:Label;
      
      public var _GWizCribToolEditor_Label17:Label;
      
      public var _GWizCribToolEditor_Label18:Label;
      
      private var _1855403334bottomGrp:GWizForePanel;
      
      private var _950398559comment:TextInput;
      
      private var _1724546052description:TextInput;
      
      private var _549914448firstCol:HGroup;
      
      private var _52752074mfgSpecs:GWizMfgCutterSpecs;
      
      private var _817627028secondCol:HGroup;
      
      private var _668939158slotLabel:Label;
      
      private var _3696td:GWizToolDef;
      
      private var _1228027545thirdCol:HGroup;
      
      private var _45253020vendorPanel:GWizForePanel;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _lockSaver:Boolean = false;
      
      private var widthWatch:ChangeWatcher;
      
      private var heightWatch:ChangeWatcher;
      
      private var resizeExecuting:Boolean = false;
      
      public var refObject:GWizToolCribEntry = null;
      
      public var toolsList:Array = null;
      
      public var toolNum:Number = 0;
      
      public var isNewTool:Boolean = false;
      
      public var toolKey:int = -1;
      
      public var customIPT:Array = null;
      
      private var oldSlot:int = -1;
      
      public var saveFcn:Function = null;
      
      public var cancelFcn:Function = null;
      
      private var _513770495powerUserState:Boolean = true;
      
      private const THIS_WIDTH_DELTA:int = 20;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCribToolEditor()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCribToolEditor_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_tools_GWizCribToolEditorWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCribToolEditor[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Tool Editor";
         this.fullScreen = true;
         this.okLabel = "Save";
         this.mxmlContent = [this._GWizCribToolEditor_VGroup1_c()];
         this.addEventListener("creationComplete",this.___GWizCribToolEditor_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCribToolEditor._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get ignoreLockForToolCrib() : Boolean
      {
         return GWizCribToolEditor._1674103052ignoreLockForToolCrib;
      }
      
      public static function set ignoreLockForToolCrib(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCribToolEditor._1674103052ignoreLockForToolCrib;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCribToolEditor,"ignoreLockForToolCrib",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function setTitle() : void
      {
         if(this.isNewTool)
         {
            this.title = "New Tool Based on Tool #" + this.toolNum;
         }
         else
         {
            this.title = "Edit Tool #" + this.toolNum;
         }
      }
      
      private function onCC() : void
      {
         this._lockSaver = GWizToolDef.lockForToolCrib;
         GWizToolDef.lockForToolCrib = false;
         this.setTitle();
         this.FromFeedsSpeeds.visible = GWizSettings.FeedsSpeedsApp != null;
         this.Tool.vcHandler = this.toolPopupSetFunctions;
         ignoreLockForToolCrib = true;
         this.widthWatch = ChangeWatcher.watch(this,"width",this.onResize);
         this.heightWatch = ChangeWatcher.watch(this,"height",this.onResize);
         this.onResize(null);
         this.powerUserChanged();
      }
      
      private function onResize(param1:Event) : void
      {
         if(!this.resizeExecuting)
         {
            this.callLater(this.handleResize);
         }
         this.resizeExecuting = true;
      }
      
      private function handleResize() : void
      {
         var _loc1_:Number = this.width;
         var _loc2_:Number = 0.33 * _loc1_;
         var _loc3_:Number = 0.34 * _loc1_;
         var _loc4_:Number = 0.33 * _loc1_;
         log.debug("this.width = " + this.width);
         log.debug("firstColWd = " + _loc2_ + ", secondColWd = " + _loc3_ + ", thirdColWd = " + _loc4_);
         this.firstCol.width = _loc2_;
         this.secondCol.width = _loc3_;
         this.thirdCol.width = _loc4_;
         log.debug("firstColWd = " + this.firstCol.width + ", secondColWd = " + this.secondCol.width + ", thirdColWd = " + this.thirdCol.width);
         invalidateDisplayList();
         this.resizeExecuting = false;
      }
      
      public function showSlot() : void
      {
         this.slotLabel.visible = true;
         this.slotLabel.width = 40;
         this.Slot.visible = true;
         this.Slot.width = 60;
      }
      
      public function updateFromRefObject() : void
      {
         this.Tool.dataProvider = GWizToolData.MillToolsList;
         this.description.text = this.refObject.description;
         this.Slot.value = this.refObject.slot;
         this.oldSlot = this.refObject.slot;
         this.td.toolParms.toolType = this.refObject.tool;
         this.td.setGeometry(this.refObject.geometry);
         this.Tool.selectedLabel = this.refObject.tool;
         this.td._toolDiameter.setVal(this.refObject.diameter);
         this.td._flutes.value = this.refObject.flutes;
         this.setFunctions();
         this.td.toolParms.helixAngle = this.refObject.helixAngle;
         this.td.toolParms.shankSize = this.refObject.shankSize;
         this.td._LeadAngle.value = this.refObject.leadang;
         this.td.toolParms.leadAngle = this.refObject.leadang;
         this.td._stickout.setVal(this.refObject.stickout);
         this.td.toolParms.cutLength = this.refObject.cutLength;
         this.td.toolParms.overallLength = this.refObject.overallLength;
         this.td.toolParms.noseRad = this.refObject.noseRad;
         this.td.toolParms.noCutDia = this.refObject.tipDiameter;
         this.td.toolParms.threadPitch = this.refObject.threadPitch;
         if(this.refObject.hasOwnProperty("useMfgSFM") && this.refObject.useMfgSFM)
         {
            this.mfgSpecs.mfgSFM.setValOverride(this.refObject.mfgSFM);
         }
         if(this.refObject.hasOwnProperty("useMfgIPT") && this.refObject.useMfgIPT)
         {
            this.mfgSpecs.mfgIPT.setValOverride(this.refObject.mfgIPT);
         }
         if(this.refObject.hasOwnProperty("toolFamily"))
         {
            this.mfgSpecs.ToolFamily = this.refObject.toolFamily;
         }
         else
         {
            this.mfgSpecs.ToolFamily = null;
         }
         if(this.refObject.serialno != null)
         {
            this.SerialNo.text = this.refObject.serialno;
         }
         this.XComp.setVal(this.refObject.xcomp);
         this.ZComp.setVal(this.refObject.zcomp);
         this.ZGeom.setVal(this.refObject.zgeom);
         this.Vendor.text = this.refObject.vendor;
         this.Product.text = this.refObject.product;
         this.ToolNo.text = this.refObject.idNo;
         this.Insert.text = this.refObject.insNo;
         this.Status.setValue(this.refObject.status);
         this.Qty.setVal(this.refObject.quantity);
         this.setTitle();
         this.HolderType.setValue(this.refObject.holderType);
         this.HolderDesc.text = this.refObject.holderDesc;
         this.HolderDia.setVal(this.refObject.holderDia);
         this.HolderLen.setVal(this.refObject.holderLen);
         if(this.refObject.hasOwnProperty("field1"))
         {
            this.Field1.text = this.refObject.field1;
         }
         if(this.refObject.hasOwnProperty("field2"))
         {
            this.Field2.text = this.refObject.field2;
         }
         if(this.refObject.hasOwnProperty("field3"))
         {
            this.Field3.text = this.refObject.field3;
         }
         if(this.refObject.hasOwnProperty("field4"))
         {
            this.Field4.text = this.refObject.field4;
         }
         if(this.refObject.coating != null)
         {
            this.td.toolParms.coating = this.refObject.coating;
         }
         if(this.refObject.toolmaterial != null)
         {
            this.td.toolParms.toolmaterial = this.refObject.toolmaterial;
         }
         this.comment.text = this.refObject.comment;
         this.Clockwise.selected = this.refObject.clockwise;
         this.ShoulderLen.value = this.refObject.shoulderLength;
         this.TaperAngle2.value = this.refObject.taperAngle2;
         this.TipLength.value = this.refObject.tipLength;
         this.ProductLink.text = this.refObject.productLink;
         this.JobCode.text = this.refObject.jobCode;
         this.PricePaid.value = this.refObject.pricePaid;
      }
      
      private function doSave() : void
      {
         if(this.refObject)
         {
            this.refObject.description = this.description.text;
            this.refObject.slot = this.Slot.value;
            this.refObject.tool = this.Tool.selectedLabel;
            this.refObject.diameter = this.td.toolParms.toolDiam;
            this.refObject.flutes = this.td.toolParms.flutes;
            this.refObject.helixAngle = this.td.toolParms.helixAngle;
            this.refObject.geometry = this.td.toolParms.geometry;
            this.refObject.shankSize = this.td.toolParms.shankSize;
            this.refObject.leadang = this.td.toolParms.leadAngle;
            this.refObject.stickout = this.td.toolParms.stickout;
            this.refObject.cutLength = this.td.toolParms.cutLength;
            this.refObject.overallLength = this.td.toolParms.overallLength;
            this.refObject.noseRad = this.td.toolParms.noseRad;
            this.refObject.tipDiameter = this.td.toolParms.noCutDia;
            this.refObject.threadPitch = this.td.toolParms.threadPitch;
            this.refObject.serialno = this.SerialNo.text;
            this.refObject.xcomp = this.XComp.getVal();
            this.refObject.zcomp = this.ZComp.getVal();
            this.refObject.zgeom = this.ZGeom.getVal();
            this.refObject.vendor = this.Vendor.text;
            this.refObject.product = this.Product.text;
            this.refObject.status = this.Status.getValue();
            this.refObject.quantity = this.Qty.getVal();
            this.refObject.holderType = this.HolderType.getValue();
            this.refObject.holderDesc = this.HolderDesc.text;
            this.refObject.holderDia = this.HolderDia.getVal();
            this.refObject.holderLen = this.HolderLen.getVal();
            this.refObject.idNo = this.ToolNo.text;
            this.refObject.insNo = this.Insert.text;
            this.refObject.field1 = this.Field1.text;
            this.refObject.field2 = this.Field2.text;
            this.refObject.field3 = this.Field3.text;
            this.refObject.field4 = this.Field4.text;
            this.refObject.useMfgSFM = this.mfgSpecs.mfgSFM.isOverridden();
            this.refObject.mfgSFM = this.mfgSpecs.mfgSFM.getVal();
            this.refObject.useMfgIPT = this.mfgSpecs.mfgIPT.isOverridden();
            this.refObject.mfgIPT = this.mfgSpecs.mfgIPT.getVal();
            this.refObject.toolFamily = this.mfgSpecs.ToolFamily;
            this.refObject.noseRad = this.td.toolParms.noseRad;
            this.refObject.coating = this.td.toolParms.coating;
            this.refObject.toolmaterial = this.td.toolParms.toolmaterial;
            this.refObject.comment = this.comment.text;
            this.refObject.clockwise = this.Clockwise.selected;
            this.refObject.shoulderLength = this.ShoulderLen.value;
            this.refObject.taperAngle2 = this.TaperAngle2.value;
            this.refObject.tipLength = this.TipLength.value;
            this.refObject.productLink = this.ProductLink.text;
            this.refObject.jobCode = this.JobCode.text;
            this.refObject.pricePaid = this.PricePaid.value;
         }
         super.close();
         if(this.saveFcn != null)
         {
            this.saveFcn(this.oldSlot);
         }
      }
      
      override public function onCancel(param1:Event) : void
      {
         super.close();
         if(this.cancelFcn != null)
         {
            this.cancelFcn();
         }
         GWizToolDef.lockForToolCrib = this._lockSaver;
         ignoreLockForToolCrib = false;
      }
      
      private function setFunctions() : void
      {
         GWizFeedsSpeeds2.setFunctionsRecurse = true;
         if(this.Tool && this.td)
         {
            this.ToolIcon.source = GWizToolTypeRenderer.toolTypeIcon(this.Tool.selectedLabel,this.td.geometryLabel());
         }
         if(this.td)
         {
            this.td.setFunctions(this.Tool.selectedLabel);
         }
         GWizFeedsSpeeds2.setFunctionsRecurse = false;
      }
      
      public function fromFeedsSpeeds() : void
      {
         var _loc1_:GWizFeedsSpeeds2 = GWizSettings.FeedsSpeedsApp;
         this.FromFeedsSpeeds.visible = _loc1_ != null;
         if(_loc1_)
         {
            this.Tool.selectedLabel = _loc1_.getToolType();
            this.td.copyToolDef(_loc1_.td);
            if(_loc1_.mfgSpecs.mfgSFM.isOverridden())
            {
               this.mfgSpecs.mfgSFM.setValOverride(_loc1_.mfgSpecs.mfgSFM.getVal());
            }
            if(_loc1_.mfgSpecs.mfgIPT.isOverridden())
            {
               this.mfgSpecs.mfgIPT.setValOverride(_loc1_.mfgSpecs.mfgIPT.getVal());
            }
            this.description.text = "";
            this.comment.text = "";
            this.Clockwise.selected = true;
            this.ShoulderLen.value = 0;
            this.TaperAngle2.value = 0;
            this.TipLength.value = 0;
            this.ProductLink.text = "";
            this.JobCode.text = "";
            this.PricePaid.value = 0;
         }
      }
      
      private function toolPopupSetFunctions(param1:GWizToolData) : void
      {
         this.Tool.selectedLabel = param1.toolType;
         this.td.toolParms = param1;
         this.setFunctions();
      }
      
      override public function onOk(param1:Event) : void
      {
         this.doSave();
         ignoreLockForToolCrib = false;
      }
      
      private function setFunctionsAux(param1:GWizToolData) : void
      {
         this.td.toolParms = param1;
      }
      
      private function openProductLink() : void
      {
         if(this.ProductLink.text != "")
         {
            GWizUtils.doWebPage(this.ProductLink.text);
         }
      }
      
      private function powerUserChanged(param1:Object = null) : Boolean
      {
         if(GWizSettings.prefs.powerUser != this.powerUserState)
         {
            if(GWizSettings.prefs.powerUser)
            {
               this.mfgSpecs.visible = true;
            }
            else
            {
               this.mfgSpecs.visible = false;
            }
            this.powerUserState = GWizSettings.prefs.powerUser;
         }
         return true;
      }
      
      private function _GWizCribToolEditor_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingRight = 5;
         _loc1_.mxmlContent = [this._GWizCribToolEditor_GWizForePanel1_i(),this._GWizCribToolEditor_GWizForePanel2_i(),this._GWizCribToolEditor_GWizToolDef1_i(),this._GWizCribToolEditor_GWizMfgCutterSpecs1_i(),this._GWizCribToolEditor_GWizForePanel3_i(),this._GWizCribToolEditor_GWizForePanel4_i(),this._GWizCribToolEditor_GWizForePanel5_i(),this._GWizCribToolEditor_GWizForePanel6_i(),this._GWizCribToolEditor_GWizForePanel7_i(),this._GWizCribToolEditor_GWizForePanel8_i(),this._GWizCribToolEditor_GWizForePanel9_i()];
         _loc1_.setStyle("color",0);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "ID";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCribToolEditor_Array3_c);
         _loc1_.id = "ToolPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ToolPanel = _loc1_;
         BindingManager.executeBindings(this,"ToolPanel",this.ToolPanel);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Array3_c() : Array
      {
         return [this._GWizCribToolEditor_VGroup2_c()];
      }
      
      private function _GWizCribToolEditor_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCribToolEditor_HGroup1_c(),this._GWizCribToolEditor_HGroup2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_Label1_i(),this._GWizCribToolEditor_TextInput1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Description";
         _loc1_.id = "DescLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DescLabel = _loc1_;
         BindingManager.executeBindings(this,"DescLabel",this.DescLabel);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.percentWidth = 100;
         _loc1_.prompt = "Description";
         _loc1_.setStyle("color",0);
         _loc1_.id = "description";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.description = _loc1_;
         BindingManager.executeBindings(this,"description",this.description);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_Label2_i(),this._GWizCribToolEditor_NumericStepper1_i(),this._GWizCribToolEditor_Label3_c(),this._GWizCribToolEditor_TextInput2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Slot";
         _loc1_.visible = false;
         _loc1_.id = "slotLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.slotLabel = _loc1_;
         BindingManager.executeBindings(this,"slotLabel",this.slotLabel);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.maximum = 1000;
         _loc1_.visible = false;
         _loc1_.id = "Slot";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Slot = _loc1_;
         BindingManager.executeBindings(this,"Slot",this.Slot);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Comment";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_TextInput2_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.percentWidth = 100;
         _loc1_.prompt = "Comment";
         _loc1_.setStyle("color",0);
         _loc1_.id = "comment";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.comment = _loc1_;
         BindingManager.executeBindings(this,"comment",this.comment);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizForePanel2_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Type";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCribToolEditor_Array7_c);
         _loc1_.id = "_GWizCribToolEditor_GWizForePanel2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCribToolEditor_GWizForePanel2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCribToolEditor_GWizForePanel2",this._GWizCribToolEditor_GWizForePanel2);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Array7_c() : Array
      {
         return [this._GWizCribToolEditor_HGroup3_c()];
      }
      
      private function _GWizCribToolEditor_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_Image1_i(),this._GWizCribToolEditor_GWizToolMenu1_i(),this._GWizCribToolEditor_CheckBox1_i(),this._GWizCribToolEditor_Button1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.id = "ToolIcon";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ToolIcon = _loc1_;
         BindingManager.executeBindings(this,"ToolIcon",this.ToolIcon);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizToolMenu1_i() : GWizToolMenu
      {
         var _loc1_:GWizToolMenu = new GWizToolMenu();
         _loc1_.toolTip = "Select which cutter \ror operation you\'re running";
         _loc1_.inFeedsSpeedsApp = false;
         _loc1_.addEventListener("valueCommit",this.__Tool_valueCommit);
         _loc1_.id = "Tool";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Tool = _loc1_;
         BindingManager.executeBindings(this,"Tool",this.Tool);
         return _loc1_;
      }
      
      public function __Tool_valueCommit(param1:FlexEvent) : void
      {
         this.setFunctions();
      }
      
      private function _GWizCribToolEditor_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Clockwise";
         _loc1_.toolTip = "If selected, tool runs clockwise in spindle (i.e. Right hand).";
         _loc1_.id = "Clockwise";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Clockwise = _loc1_;
         BindingManager.executeBindings(this,"Clockwise",this.Clockwise);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "From FeedsSpeeds";
         _loc1_.visible = false;
         _loc1_.addEventListener("click",this.__FromFeedsSpeeds_click);
         _loc1_.id = "FromFeedsSpeeds";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FromFeedsSpeeds = _loc1_;
         BindingManager.executeBindings(this,"FromFeedsSpeeds",this.FromFeedsSpeeds);
         return _loc1_;
      }
      
      public function __FromFeedsSpeeds_click(param1:MouseEvent) : void
      {
         this.fromFeedsSpeeds();
      }
      
      private function _GWizCribToolEditor_GWizToolDef1_i() : GWizToolDef
      {
         var _loc1_:GWizToolDef = new GWizToolDef();
         _loc1_.hideToCrib = true;
         _loc1_.id = "td";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.td = _loc1_;
         BindingManager.executeBindings(this,"td",this.td);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizMfgCutterSpecs1_i() : GWizMfgCutterSpecs
      {
         var _loc1_:GWizMfgCutterSpecs = new GWizMfgCutterSpecs();
         _loc1_.percentWidth = 100;
         _loc1_.id = "mfgSpecs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.mfgSpecs = _loc1_;
         BindingManager.executeBindings(this,"mfgSpecs",this.mfgSpecs);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizForePanel3_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Vendor";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCribToolEditor_Array9_c);
         _loc1_.id = "vendorPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.vendorPanel = _loc1_;
         BindingManager.executeBindings(this,"vendorPanel",this.vendorPanel);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Array9_c() : Array
      {
         return [this._GWizCribToolEditor_VGroup3_c()];
      }
      
      private function _GWizCribToolEditor_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCribToolEditor_HGroup4_c(),this._GWizCribToolEditor_HGroup11_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_VGroup4_c(),this._GWizCribToolEditor_VGroup5_c(),this._GWizCribToolEditor_VGroup6_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_VGroup4_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 33;
         _loc1_.mxmlContent = [this._GWizCribToolEditor_HGroup5_c(),this._GWizCribToolEditor_HGroup6_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_Label4_c(),this._GWizCribToolEditor_TextInput3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Vendor";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_TextInput3_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.text = "N/A";
         _loc1_.setStyle("color",0);
         _loc1_.id = "Vendor";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Vendor = _loc1_;
         BindingManager.executeBindings(this,"Vendor",this.Vendor);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_Label5_c(),this._GWizCribToolEditor_TextInput4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Prod #";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_TextInput4_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.text = "N/A";
         _loc1_.setStyle("color",0);
         _loc1_.id = "ToolNo";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ToolNo = _loc1_;
         BindingManager.executeBindings(this,"ToolNo",this.ToolNo);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_VGroup5_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 34;
         _loc1_.mxmlContent = [this._GWizCribToolEditor_HGroup7_c(),this._GWizCribToolEditor_HGroup8_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup7_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_Label6_c(),this._GWizCribToolEditor_TextInput5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Product";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_TextInput5_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.text = "N/A";
         _loc1_.width = 310;
         _loc1_.setStyle("color",0);
         _loc1_.id = "Product";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Product = _loc1_;
         BindingManager.executeBindings(this,"Product",this.Product);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup8_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_Label7_c(),this._GWizCribToolEditor_TextInput6_i(),this._GWizCribToolEditor_Label8_c(),this._GWizCribToolEditor_TextInput7_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Insert";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_TextInput6_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.text = "N/A";
         _loc1_.setStyle("color",0);
         _loc1_.id = "Insert";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Insert = _loc1_;
         BindingManager.executeBindings(this,"Insert",this.Insert);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Serial #";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_TextInput7_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.toolTip = "The tool\'s serial number for tracking purposes";
         _loc1_.setStyle("color",0);
         _loc1_.id = "SerialNo";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SerialNo = _loc1_;
         BindingManager.executeBindings(this,"SerialNo",this.SerialNo);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_VGroup6_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 33;
         _loc1_.mxmlContent = [this._GWizCribToolEditor_HGroup9_c(),this._GWizCribToolEditor_HGroup10_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup9_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_Label9_c(),this._GWizCribToolEditor_GWizToolStatusDDList1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label9_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Status";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizToolStatusDDList1_i() : GWizToolStatusDDList
      {
         var _loc1_:GWizToolStatusDDList = new GWizToolStatusDDList();
         _loc1_.id = "Status";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Status = _loc1_;
         BindingManager.executeBindings(this,"Status",this.Status);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup10_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_Label10_c(),this._GWizCribToolEditor_GWizNumStep1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label10_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Quantity";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 100000;
         _loc1_.steps = 1;
         _loc1_.usesMetric = false;
         _loc1_.id = "Qty";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Qty = _loc1_;
         BindingManager.executeBindings(this,"Qty",this.Qty);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup11_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_Label11_c(),this._GWizCribToolEditor_TextInput8_i(),this._GWizCribToolEditor_Button2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label11_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Product Link:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_TextInput8_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.percentWidth = 100;
         _loc1_.prompt = "URL to Product";
         _loc1_.id = "ProductLink";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ProductLink = _loc1_;
         BindingManager.executeBindings(this,"ProductLink",this.ProductLink);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Open...";
         _loc1_.addEventListener("click",this.___GWizCribToolEditor_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCribToolEditor_Button2_click(param1:MouseEvent) : void
      {
         this.openProductLink();
      }
      
      private function _GWizCribToolEditor_GWizForePanel4_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Data";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCribToolEditor_Array22_c);
         _loc1_.id = "_GWizCribToolEditor_GWizForePanel4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCribToolEditor_GWizForePanel4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCribToolEditor_GWizForePanel4",this._GWizCribToolEditor_GWizForePanel4);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Array22_c() : Array
      {
         return [this._GWizCribToolEditor_HGroup12_c()];
      }
      
      private function _GWizCribToolEditor_HGroup12_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_GWizNumStep2_i(),this._GWizCribToolEditor_GWizNumStep3_i(),this._GWizCribToolEditor_GWizNumStep4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "X Comp";
         _loc1_.min = 0;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Cutter Compensation value";
         _loc1_.id = "XComp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.XComp = _loc1_;
         BindingManager.executeBindings(this,"XComp",this.XComp);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Z Comp";
         _loc1_.min = 0;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Tool Length Compensation value";
         _loc1_.id = "ZComp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ZComp = _loc1_;
         BindingManager.executeBindings(this,"ZComp",this.ZComp);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Z Geom";
         _loc1_.min = 0;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.toolTip = "Height geometry offset";
         _loc1_.id = "ZGeom";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ZGeom = _loc1_;
         BindingManager.executeBindings(this,"ZGeom",this.ZGeom);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizForePanel5_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Holder";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCribToolEditor_Array24_c);
         _loc1_.id = "_GWizCribToolEditor_GWizForePanel5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCribToolEditor_GWizForePanel5 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCribToolEditor_GWizForePanel5",this._GWizCribToolEditor_GWizForePanel5);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Array24_c() : Array
      {
         return [this._GWizCribToolEditor_VGroup7_c()];
      }
      
      private function _GWizCribToolEditor_VGroup7_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCribToolEditor_HGroup13_c(),this._GWizCribToolEditor_HGroup14_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup13_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCribToolEditor_Label12_c(),this._GWizCribToolEditor_TextInput9_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label12_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Toolholder Description:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_TextInput9_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.percentWidth = 100;
         _loc1_.id = "HolderDesc";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HolderDesc = _loc1_;
         BindingManager.executeBindings(this,"HolderDesc",this.HolderDesc);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup14_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCribToolEditor_Label13_c(),this._GWizCribToolEditor_GWizToolHolderDDList1_i(),this._GWizCribToolEditor_GWizNumStep5_i(),this._GWizCribToolEditor_GWizNumStep6_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label13_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Type:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizToolHolderDDList1_i() : GWizToolHolderDDList
      {
         var _loc1_:GWizToolHolderDDList = new GWizToolHolderDDList();
         _loc1_.percentWidth = 100;
         _loc1_.id = "HolderType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HolderType = _loc1_;
         BindingManager.executeBindings(this,"HolderType",this.HolderType);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizNumStep5_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Holder Dia:";
         _loc1_.id = "HolderDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HolderDia = _loc1_;
         BindingManager.executeBindings(this,"HolderDia",this.HolderDia);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizNumStep6_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Holder Len:";
         _loc1_.id = "HolderLen";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HolderLen = _loc1_;
         BindingManager.executeBindings(this,"HolderLen",this.HolderLen);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizForePanel6_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Other";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCribToolEditor_Array28_c);
         _loc1_.id = "_GWizCribToolEditor_GWizForePanel6";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCribToolEditor_GWizForePanel6 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCribToolEditor_GWizForePanel6",this._GWizCribToolEditor_GWizForePanel6);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Array28_c() : Array
      {
         return [this._GWizCribToolEditor_HGroup15_c()];
      }
      
      private function _GWizCribToolEditor_HGroup15_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_GWizNumStep7_i(),this._GWizCribToolEditor_GWizNumStep8_i(),this._GWizCribToolEditor_GWizNumStep9_i(),this._GWizCribToolEditor_GWizNumStep10_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizNumStep7_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Shoulder Len";
         _loc1_.min = 0;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.id = "ShoulderLen";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ShoulderLen = _loc1_;
         BindingManager.executeBindings(this,"ShoulderLen",this.ShoulderLen);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizNumStep8_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Taper Angle 2";
         _loc1_.min = 0;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.id = "TaperAngle2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TaperAngle2 = _loc1_;
         BindingManager.executeBindings(this,"TaperAngle2",this.TaperAngle2);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizNumStep9_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Tip Length";
         _loc1_.min = 0;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.id = "TipLength";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TipLength = _loc1_;
         BindingManager.executeBindings(this,"TipLength",this.TipLength);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizNumStep10_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Thread Pitch";
         _loc1_.min = 0;
         _loc1_.max = 5000;
         _loc1_.steps = 0.0001;
         _loc1_.id = "ThreadPitch";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ThreadPitch = _loc1_;
         BindingManager.executeBindings(this,"ThreadPitch",this.ThreadPitch);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizForePanel7_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Costing";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCribToolEditor_Array30_c);
         _loc1_.id = "_GWizCribToolEditor_GWizForePanel7";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCribToolEditor_GWizForePanel7 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCribToolEditor_GWizForePanel7",this._GWizCribToolEditor_GWizForePanel7);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Array30_c() : Array
      {
         return [this._GWizCribToolEditor_VGroup8_c()];
      }
      
      private function _GWizCribToolEditor_VGroup8_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCribToolEditor_HGroup16_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup16_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_Label14_c(),this._GWizCribToolEditor_TextInput10_i(),this._GWizCribToolEditor_GWizNumStep11_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label14_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Job Code";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_TextInput10_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.toolTip = "Job we want to charge for this tool.";
         _loc1_.setStyle("color",0);
         _loc1_.id = "JobCode";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.JobCode = _loc1_;
         BindingManager.executeBindings(this,"JobCode",this.JobCode);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizNumStep11_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Price Paid";
         _loc1_.min = 0;
         _loc1_.max = 50000;
         _loc1_.steps = 0.01;
         _loc1_.usesMetric = false;
         _loc1_.id = "PricePaid";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PricePaid = _loc1_;
         BindingManager.executeBindings(this,"PricePaid",this.PricePaid);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizForePanel8_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "User";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCribToolEditor_Array33_c);
         _loc1_.id = "_GWizCribToolEditor_GWizForePanel8";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCribToolEditor_GWizForePanel8 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCribToolEditor_GWizForePanel8",this._GWizCribToolEditor_GWizForePanel8);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Array33_c() : Array
      {
         return [this._GWizCribToolEditor_VGroup9_c()];
      }
      
      private function _GWizCribToolEditor_VGroup9_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCribToolEditor_HGroup17_c(),this._GWizCribToolEditor_HGroup18_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup17_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_Label15_i(),this._GWizCribToolEditor_TextInput11_i(),this._GWizCribToolEditor_Label16_i(),this._GWizCribToolEditor_TextInput12_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label15_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "_GWizCribToolEditor_Label15";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCribToolEditor_Label15 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCribToolEditor_Label15",this._GWizCribToolEditor_Label15);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_TextInput11_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.setStyle("color",0);
         _loc1_.id = "Field1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Field1 = _loc1_;
         BindingManager.executeBindings(this,"Field1",this.Field1);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label16_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "_GWizCribToolEditor_Label16";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCribToolEditor_Label16 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCribToolEditor_Label16",this._GWizCribToolEditor_Label16);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_TextInput12_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.setStyle("color",0);
         _loc1_.id = "Field2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Field2 = _loc1_;
         BindingManager.executeBindings(this,"Field2",this.Field2);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup18_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCribToolEditor_Label17_i(),this._GWizCribToolEditor_TextInput13_i(),this._GWizCribToolEditor_Label18_i(),this._GWizCribToolEditor_TextInput14_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label17_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "_GWizCribToolEditor_Label17";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCribToolEditor_Label17 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCribToolEditor_Label17",this._GWizCribToolEditor_Label17);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_TextInput13_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.setStyle("color",0);
         _loc1_.id = "Field3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Field3 = _loc1_;
         BindingManager.executeBindings(this,"Field3",this.Field3);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Label18_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "_GWizCribToolEditor_Label18";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCribToolEditor_Label18 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCribToolEditor_Label18",this._GWizCribToolEditor_Label18);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_TextInput14_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.setStyle("color",0);
         _loc1_.id = "Field4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Field4 = _loc1_;
         BindingManager.executeBindings(this,"Field4",this.Field4);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_GWizForePanel9_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentHeight = 100;
         _loc1_.title = "  ";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCribToolEditor_Array37_c);
         _loc1_.id = "bottomGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.bottomGrp = _loc1_;
         BindingManager.executeBindings(this,"bottomGrp",this.bottomGrp);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_Array37_c() : Array
      {
         return [this._GWizCribToolEditor_HGroup19_i(),this._GWizCribToolEditor_HGroup20_i(),this._GWizCribToolEditor_HGroup21_i()];
      }
      
      private function _GWizCribToolEditor_HGroup19_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 33;
         _loc1_.percentHeight = 100;
         _loc1_.id = "firstCol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.firstCol = _loc1_;
         BindingManager.executeBindings(this,"firstCol",this.firstCol);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup20_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 34;
         _loc1_.percentHeight = 100;
         _loc1_.id = "secondCol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.secondCol = _loc1_;
         BindingManager.executeBindings(this,"secondCol",this.secondCol);
         return _loc1_;
      }
      
      private function _GWizCribToolEditor_HGroup21_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 33;
         _loc1_.percentHeight = 100;
         _loc1_.id = "thirdCol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.thirdCol = _loc1_;
         BindingManager.executeBindings(this,"thirdCol",this.thirdCol);
         return _loc1_;
      }
      
      public function ___GWizCribToolEditor_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizCribToolEditor_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Number
         {
            return this.width - THIS_WIDTH_DELTA;
         },null,"ToolPanel.width");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"ToolPanel.labelBackgroundColor");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"ToolPanel.labelColor");
         result[3] = new Binding(this,function():Number
         {
            return DescLabel.width;
         },null,"slotLabel.width");
         result[4] = new Binding(this,function():Number
         {
            return this.width - THIS_WIDTH_DELTA;
         },null,"_GWizCribToolEditor_GWizForePanel2.width");
         result[5] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizCribToolEditor_GWizForePanel2.labelBackgroundColor");
         result[6] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizCribToolEditor_GWizForePanel2.labelColor");
         result[7] = new Binding(this,function():Array
         {
            var _loc1_:* = GWizToolData.MillToolsList;
            return _loc1_ == null || _loc1_ is Array || _loc1_ is Proxy ? _loc1_ : [_loc1_];
         },null,"Tool.dataProvider");
         result[8] = new Binding(this,null,null,"Tool.toolDef","td");
         result[9] = new Binding(this,function():Number
         {
            return this.width - THIS_WIDTH_DELTA;
         },null,"td.width");
         result[10] = new Binding(this,function():Function
         {
            return Tool.showToolMenu2;
         },null,"td.popupToolMenu");
         result[11] = new Binding(this,function():int
         {
            return firstCol.width;
         },null,"td.firstColWd");
         result[12] = new Binding(this,function():int
         {
            return secondCol.width;
         },null,"td.secondColWd");
         result[13] = new Binding(this,function():int
         {
            return thirdCol.width - 20;
         },null,"td.thirdColWd");
         result[14] = new Binding(this,function():int
         {
            return firstCol.width;
         },null,"mfgSpecs.firstColWd");
         result[15] = new Binding(this,function():int
         {
            return secondCol.width;
         },null,"mfgSpecs.secondColWd");
         result[16] = new Binding(this,function():int
         {
            return thirdCol.width - 20;
         },null,"mfgSpecs.thirdColWd");
         result[17] = new Binding(this,function():Boolean
         {
            return mfgSpecs.visible;
         },null,"mfgSpecs.includeInLayout");
         result[18] = new Binding(this,function():Number
         {
            return this.width - THIS_WIDTH_DELTA;
         },null,"vendorPanel.width");
         result[19] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"vendorPanel.labelBackgroundColor");
         result[20] = new Binding(this,function():Boolean
         {
            return mfgSpecs.visible;
         },null,"vendorPanel.includeInLayout");
         result[21] = new Binding(this,function():Boolean
         {
            return mfgSpecs.visible;
         },null,"vendorPanel.visible");
         result[22] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"vendorPanel.labelColor");
         result[23] = new Binding(this,function():Number
         {
            return this.width - THIS_WIDTH_DELTA;
         },null,"_GWizCribToolEditor_GWizForePanel4.width");
         result[24] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizCribToolEditor_GWizForePanel4.labelBackgroundColor");
         result[25] = new Binding(this,function():Boolean
         {
            return mfgSpecs.visible;
         },null,"_GWizCribToolEditor_GWizForePanel4.includeInLayout");
         result[26] = new Binding(this,function():Boolean
         {
            return mfgSpecs.visible;
         },null,"_GWizCribToolEditor_GWizForePanel4.visible");
         result[27] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizCribToolEditor_GWizForePanel4.labelColor");
         result[28] = new Binding(this,function():Number
         {
            return this.width - THIS_WIDTH_DELTA;
         },null,"_GWizCribToolEditor_GWizForePanel5.width");
         result[29] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizCribToolEditor_GWizForePanel5.labelBackgroundColor");
         result[30] = new Binding(this,function():Boolean
         {
            return mfgSpecs.visible;
         },null,"_GWizCribToolEditor_GWizForePanel5.includeInLayout");
         result[31] = new Binding(this,function():Boolean
         {
            return mfgSpecs.visible;
         },null,"_GWizCribToolEditor_GWizForePanel5.visible");
         result[32] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizCribToolEditor_GWizForePanel5.labelColor");
         result[33] = new Binding(this,function():Number
         {
            return this.width - THIS_WIDTH_DELTA;
         },null,"_GWizCribToolEditor_GWizForePanel6.width");
         result[34] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizCribToolEditor_GWizForePanel6.labelBackgroundColor");
         result[35] = new Binding(this,function():Boolean
         {
            return mfgSpecs.visible;
         },null,"_GWizCribToolEditor_GWizForePanel6.includeInLayout");
         result[36] = new Binding(this,function():Boolean
         {
            return mfgSpecs.visible;
         },null,"_GWizCribToolEditor_GWizForePanel6.visible");
         result[37] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizCribToolEditor_GWizForePanel6.labelColor");
         result[38] = new Binding(this,function():Number
         {
            return this.width - THIS_WIDTH_DELTA;
         },null,"_GWizCribToolEditor_GWizForePanel7.width");
         result[39] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizCribToolEditor_GWizForePanel7.labelBackgroundColor");
         result[40] = new Binding(this,function():Boolean
         {
            return mfgSpecs.visible;
         },null,"_GWizCribToolEditor_GWizForePanel7.includeInLayout");
         result[41] = new Binding(this,function():Boolean
         {
            return mfgSpecs.visible;
         },null,"_GWizCribToolEditor_GWizForePanel7.visible");
         result[42] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizCribToolEditor_GWizForePanel7.labelColor");
         result[43] = new Binding(this,function():Number
         {
            return this.width - THIS_WIDTH_DELTA;
         },null,"_GWizCribToolEditor_GWizForePanel8.width");
         result[44] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizCribToolEditor_GWizForePanel8.labelBackgroundColor");
         result[45] = new Binding(this,function():Boolean
         {
            return mfgSpecs.visible;
         },null,"_GWizCribToolEditor_GWizForePanel8.includeInLayout");
         result[46] = new Binding(this,function():Boolean
         {
            return mfgSpecs.visible;
         },null,"_GWizCribToolEditor_GWizForePanel8.visible");
         result[47] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizCribToolEditor_GWizForePanel8.labelColor");
         result[48] = new Binding(this,function():String
         {
            var _loc1_:* = GWizToolCrib.field1Name;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizCribToolEditor_Label15.text");
         result[49] = new Binding(this,function():String
         {
            var _loc1_:* = GWizToolCrib.field2Name;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizCribToolEditor_Label16.text");
         result[50] = new Binding(this,function():String
         {
            var _loc1_:* = GWizToolCrib.field3Name;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizCribToolEditor_Label17.text");
         result[51] = new Binding(this,function():String
         {
            var _loc1_:* = GWizToolCrib.field4Name;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizCribToolEditor_Label18.text");
         result[52] = new Binding(this,function():Number
         {
            return this.width - THIS_WIDTH_DELTA;
         },null,"bottomGrp.width");
         result[53] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"bottomGrp.labelBackgroundColor");
         result[54] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"bottomGrp.labelColor");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Clockwise() : CheckBox
      {
         return this._1070003602Clockwise;
      }
      
      public function set Clockwise(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1070003602Clockwise;
         if(_loc2_ !== param1)
         {
            this._1070003602Clockwise = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Clockwise",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get DescLabel() : Label
      {
         return this._826465597DescLabel;
      }
      
      public function set DescLabel(param1:Label) : void
      {
         var _loc2_:Object = this._826465597DescLabel;
         if(_loc2_ !== param1)
         {
            this._826465597DescLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DescLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Field1() : TextInput
      {
         return this._2104126103Field1;
      }
      
      public function set Field1(param1:TextInput) : void
      {
         var _loc2_:Object = this._2104126103Field1;
         if(_loc2_ !== param1)
         {
            this._2104126103Field1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Field1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Field2() : TextInput
      {
         return this._2104126104Field2;
      }
      
      public function set Field2(param1:TextInput) : void
      {
         var _loc2_:Object = this._2104126104Field2;
         if(_loc2_ !== param1)
         {
            this._2104126104Field2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Field2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Field3() : TextInput
      {
         return this._2104126105Field3;
      }
      
      public function set Field3(param1:TextInput) : void
      {
         var _loc2_:Object = this._2104126105Field3;
         if(_loc2_ !== param1)
         {
            this._2104126105Field3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Field3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Field4() : TextInput
      {
         return this._2104126106Field4;
      }
      
      public function set Field4(param1:TextInput) : void
      {
         var _loc2_:Object = this._2104126106Field4;
         if(_loc2_ !== param1)
         {
            this._2104126106Field4 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Field4",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FromFeedsSpeeds() : Button
      {
         return this._1511422423FromFeedsSpeeds;
      }
      
      public function set FromFeedsSpeeds(param1:Button) : void
      {
         var _loc2_:Object = this._1511422423FromFeedsSpeeds;
         if(_loc2_ !== param1)
         {
            this._1511422423FromFeedsSpeeds = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FromFeedsSpeeds",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HolderDesc() : TextInput
      {
         return this._771909245HolderDesc;
      }
      
      public function set HolderDesc(param1:TextInput) : void
      {
         var _loc2_:Object = this._771909245HolderDesc;
         if(_loc2_ !== param1)
         {
            this._771909245HolderDesc = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HolderDesc",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HolderDia() : GWizNumStep
      {
         return this._1083478256HolderDia;
      }
      
      public function set HolderDia(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1083478256HolderDia;
         if(_loc2_ !== param1)
         {
            this._1083478256HolderDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HolderDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HolderLen() : GWizNumStep
      {
         return this._1083470679HolderLen;
      }
      
      public function set HolderLen(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1083470679HolderLen;
         if(_loc2_ !== param1)
         {
            this._1083470679HolderLen = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HolderLen",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HolderType() : GWizToolHolderDDList
      {
         return this._772405030HolderType;
      }
      
      public function set HolderType(param1:GWizToolHolderDDList) : void
      {
         var _loc2_:Object = this._772405030HolderType;
         if(_loc2_ !== param1)
         {
            this._772405030HolderType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HolderType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Insert() : TextInput
      {
         return this._2099925287Insert;
      }
      
      public function set Insert(param1:TextInput) : void
      {
         var _loc2_:Object = this._2099925287Insert;
         if(_loc2_ !== param1)
         {
            this._2099925287Insert = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Insert",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get JobCode() : TextInput
      {
         return this._226242346JobCode;
      }
      
      public function set JobCode(param1:TextInput) : void
      {
         var _loc2_:Object = this._226242346JobCode;
         if(_loc2_ !== param1)
         {
            this._226242346JobCode = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"JobCode",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PricePaid() : GWizNumStep
      {
         return this._121906283PricePaid;
      }
      
      public function set PricePaid(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._121906283PricePaid;
         if(_loc2_ !== param1)
         {
            this._121906283PricePaid = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PricePaid",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Product() : TextInput
      {
         return this._1355179215Product;
      }
      
      public function set Product(param1:TextInput) : void
      {
         var _loc2_:Object = this._1355179215Product;
         if(_loc2_ !== param1)
         {
            this._1355179215Product = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Product",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ProductLink() : TextInput
      {
         return this._175999337ProductLink;
      }
      
      public function set ProductLink(param1:TextInput) : void
      {
         var _loc2_:Object = this._175999337ProductLink;
         if(_loc2_ !== param1)
         {
            this._175999337ProductLink = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ProductLink",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Qty() : GWizNumStep
      {
         return this._81558Qty;
      }
      
      public function set Qty(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._81558Qty;
         if(_loc2_ !== param1)
         {
            this._81558Qty = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Qty",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SerialNo() : TextInput
      {
         return this._1431617269SerialNo;
      }
      
      public function set SerialNo(param1:TextInput) : void
      {
         var _loc2_:Object = this._1431617269SerialNo;
         if(_loc2_ !== param1)
         {
            this._1431617269SerialNo = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SerialNo",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ShoulderLen() : GWizNumStep
      {
         return this._1226533941ShoulderLen;
      }
      
      public function set ShoulderLen(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1226533941ShoulderLen;
         if(_loc2_ !== param1)
         {
            this._1226533941ShoulderLen = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ShoulderLen",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Slot() : NumericStepper
      {
         return this._2579998Slot;
      }
      
      public function set Slot(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._2579998Slot;
         if(_loc2_ !== param1)
         {
            this._2579998Slot = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Slot",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Status() : GWizToolStatusDDList
      {
         return this._1808614382Status;
      }
      
      public function set Status(param1:GWizToolStatusDDList) : void
      {
         var _loc2_:Object = this._1808614382Status;
         if(_loc2_ !== param1)
         {
            this._1808614382Status = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Status",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TaperAngle2() : GWizNumStep
      {
         return this._1213577551TaperAngle2;
      }
      
      public function set TaperAngle2(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1213577551TaperAngle2;
         if(_loc2_ !== param1)
         {
            this._1213577551TaperAngle2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TaperAngle2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ThreadPitch() : GWizNumStep
      {
         return this._710237386ThreadPitch;
      }
      
      public function set ThreadPitch(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._710237386ThreadPitch;
         if(_loc2_ !== param1)
         {
            this._710237386ThreadPitch = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ThreadPitch",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TipLength() : GWizNumStep
      {
         return this._302192831TipLength;
      }
      
      public function set TipLength(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._302192831TipLength;
         if(_loc2_ !== param1)
         {
            this._302192831TipLength = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TipLength",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Tool() : GWizToolMenu
      {
         return this._2612664Tool;
      }
      
      public function set Tool(param1:GWizToolMenu) : void
      {
         var _loc2_:Object = this._2612664Tool;
         if(_loc2_ !== param1)
         {
            this._2612664Tool = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Tool",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ToolIcon() : Image
      {
         return this._919276975ToolIcon;
      }
      
      public function set ToolIcon(param1:Image) : void
      {
         var _loc2_:Object = this._919276975ToolIcon;
         if(_loc2_ !== param1)
         {
            this._919276975ToolIcon = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ToolIcon",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ToolNo() : TextInput
      {
         return this._1784194663ToolNo;
      }
      
      public function set ToolNo(param1:TextInput) : void
      {
         var _loc2_:Object = this._1784194663ToolNo;
         if(_loc2_ !== param1)
         {
            this._1784194663ToolNo = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ToolNo",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ToolPanel() : GWizForePanel
      {
         return this._1573588780ToolPanel;
      }
      
      public function set ToolPanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._1573588780ToolPanel;
         if(_loc2_ !== param1)
         {
            this._1573588780ToolPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ToolPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Vendor() : TextInput
      {
         return this._1736208024Vendor;
      }
      
      public function set Vendor(param1:TextInput) : void
      {
         var _loc2_:Object = this._1736208024Vendor;
         if(_loc2_ !== param1)
         {
            this._1736208024Vendor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Vendor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get XComp() : GWizNumStep
      {
         return this._83376007XComp;
      }
      
      public function set XComp(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._83376007XComp;
         if(_loc2_ !== param1)
         {
            this._83376007XComp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"XComp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ZComp() : GWizNumStep
      {
         return this._85223049ZComp;
      }
      
      public function set ZComp(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._85223049ZComp;
         if(_loc2_ !== param1)
         {
            this._85223049ZComp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ZComp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ZGeom() : GWizNumStep
      {
         return this._85332662ZGeom;
      }
      
      public function set ZGeom(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._85332662ZGeom;
         if(_loc2_ !== param1)
         {
            this._85332662ZGeom = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ZGeom",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get bottomGrp() : GWizForePanel
      {
         return this._1855403334bottomGrp;
      }
      
      public function set bottomGrp(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._1855403334bottomGrp;
         if(_loc2_ !== param1)
         {
            this._1855403334bottomGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"bottomGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get comment() : TextInput
      {
         return this._950398559comment;
      }
      
      public function set comment(param1:TextInput) : void
      {
         var _loc2_:Object = this._950398559comment;
         if(_loc2_ !== param1)
         {
            this._950398559comment = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"comment",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get description() : TextInput
      {
         return this._1724546052description;
      }
      
      public function set description(param1:TextInput) : void
      {
         var _loc2_:Object = this._1724546052description;
         if(_loc2_ !== param1)
         {
            this._1724546052description = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"description",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get firstCol() : HGroup
      {
         return this._549914448firstCol;
      }
      
      public function set firstCol(param1:HGroup) : void
      {
         var _loc2_:Object = this._549914448firstCol;
         if(_loc2_ !== param1)
         {
            this._549914448firstCol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"firstCol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get mfgSpecs() : GWizMfgCutterSpecs
      {
         return this._52752074mfgSpecs;
      }
      
      public function set mfgSpecs(param1:GWizMfgCutterSpecs) : void
      {
         var _loc2_:Object = this._52752074mfgSpecs;
         if(_loc2_ !== param1)
         {
            this._52752074mfgSpecs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"mfgSpecs",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get secondCol() : HGroup
      {
         return this._817627028secondCol;
      }
      
      public function set secondCol(param1:HGroup) : void
      {
         var _loc2_:Object = this._817627028secondCol;
         if(_loc2_ !== param1)
         {
            this._817627028secondCol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"secondCol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get slotLabel() : Label
      {
         return this._668939158slotLabel;
      }
      
      public function set slotLabel(param1:Label) : void
      {
         var _loc2_:Object = this._668939158slotLabel;
         if(_loc2_ !== param1)
         {
            this._668939158slotLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"slotLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get td() : GWizToolDef
      {
         return this._3696td;
      }
      
      public function set td(param1:GWizToolDef) : void
      {
         var _loc2_:Object = this._3696td;
         if(_loc2_ !== param1)
         {
            this._3696td = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"td",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get thirdCol() : HGroup
      {
         return this._1228027545thirdCol;
      }
      
      public function set thirdCol(param1:HGroup) : void
      {
         var _loc2_:Object = this._1228027545thirdCol;
         if(_loc2_ !== param1)
         {
            this._1228027545thirdCol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"thirdCol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get vendorPanel() : GWizForePanel
      {
         return this._45253020vendorPanel;
      }
      
      public function set vendorPanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._45253020vendorPanel;
         if(_loc2_ !== param1)
         {
            this._45253020vendorPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"vendorPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get powerUserState() : Boolean
      {
         return this._513770495powerUserState;
      }
      
      private function set powerUserState(param1:Boolean) : void
      {
         var _loc2_:Object = this._513770495powerUserState;
         if(_loc2_ !== param1)
         {
            this._513770495powerUserState = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"powerUserState",_loc2_,param1));
            }
         }
      }
   }
}
