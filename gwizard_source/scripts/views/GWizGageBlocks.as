package views
{
   import comps.GWizDataGrid;
   import comps.GWizGridColumn;
   import comps.GWizNumStep;
   import comps.GridComponent;
   import configinfo.GWizSettings;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import skins.GridSkin;
   import spark.components.Button;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.components.VGroup;
   import utils.ColorPalette;
   import utils.GWizCSVUtils;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizGageBlocks extends Group implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizGageBlocks");
      
      public static var GBSizes:ArrayCollection;
      
      public static var gageBlockFields:Array = ["Imperial","ImpDisable","Metric","MetDisable"];
      
      private static var _1649136781GageBlockStack:ArrayCollection = new ArrayCollection();
      
      private static var _1629666504cantDoItVisible:Boolean = false;
      
      private static var _1620590273sumOfBlockSzs:Number = 0;
      
      private static const PRECISION:Number = 100000;
      
      private static const THOUSAND:Number = 1000;
      
      private static var debugBreak:Boolean = false;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _43810822CantDoIt:Label;
      
      public var _GWizGageBlocks_Button2:Button;
      
      public var _GWizGageBlocks_RadioButton2:RadioButton;
      
      public var _GWizGageBlocks_RadioButton4:RadioButton;
      
      public var _GWizGageBlocks_RadioButton6:RadioButton;
      
      public var _GWizGageBlocks_RadioButton8:RadioButton;
      
      private var _1239120994blocksInches:RadioButton;
      
      private var _2020319605calculatedStackSize:Label;
      
      private var _2004760692gageBlocksInput:RadioButtonGroup;
      
      private var _817246530gageblocks:GWizDataGrid;
      
      private var _317504755gridArea:GridComponent;
      
      private var _1830308263sbInches:RadioButton;
      
      private var _89187654sbSizeInput:RadioButtonGroup;
      
      private var _1765603795sineBarAngle:Label;
      
      private var _1293004557sineBarHeight:GWizNumStep;
      
      private var _2066629137sineBarLen:GWizNumStep;
      
      private var _1879215577sizeInches:RadioButton;
      
      private var _261998344ssInches:RadioButton;
      
      private var _865050057ssSizeInput:RadioButtonGroup;
      
      private var _954445307stackSzInput:RadioButtonGroup;
      
      private var _2028785694stackWidth:GWizNumStep;
      
      private var _1056804816sumOfSizes:Label;
      
      private var _2112460350targetAngle:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizGageBlocks()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizGageBlocks_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_views_GWizGageBlocksWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizGageBlocks[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContent = [this._GWizGageBlocks_GridComponent1_i()];
         this._GWizGageBlocks_RadioButtonGroup2_i();
         this._GWizGageBlocks_RadioButtonGroup3_i();
         this._GWizGageBlocks_RadioButtonGroup4_i();
         this._GWizGageBlocks_RadioButtonGroup1_i();
         this.addEventListener("creationComplete",this.___GWizGageBlocks_Group1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      private static function biggestBlock(param1:Number, param2:Boolean) : Number
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:Number = NaN;
         var _loc8_:* = false;
         if(GBSizes)
         {
            _loc3_ = "Imperial";
            _loc4_ = "ImpDisable";
            if(!param2)
            {
               _loc3_ = "Metric";
               _loc4_ = "MetDisable";
            }
            _loc5_ = GBSizes.length - 1;
            while(_loc5_ >= 0)
            {
               _loc7_ = (_loc6_ = GBSizes.getItemAt(_loc5_))[_loc3_];
               if(!(_loc8_ = String(_loc6_[_loc4_]) != "false") && !isNaN(_loc7_) && _loc7_ <= param1)
               {
                  if(GWizUtils.lastDigit(param1) == GWizUtils.lastDigit(_loc7_))
                  {
                     return _loc7_;
                  }
               }
               _loc5_--;
            }
         }
         return 0;
      }
      
      public static function findStack(param1:Number, param2:Boolean, param3:Boolean) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Object = null;
         if(GWizUtils.debug)
         {
            if(debugBreak)
            {
               log.debug("gotcha");
            }
         }
         if(param2 != param3)
         {
            if(param3)
            {
               param1 /= 25.4;
            }
            else
            {
               param1 *= 25.4;
            }
         }
         sumOfBlockSzs = 0;
         param1 = GWizUtils.roundTenths(param1);
         GageBlockStack.removeAll();
         cantDoItVisible = false;
         var _loc4_:Boolean = false;
         var _loc5_:int = 50;
         while(!_loc4_)
         {
            _loc6_ = biggestBlock(param1,param3);
            _loc6_ = GWizUtils.roundHundredThousandths(_loc6_);
            param1 -= _loc6_;
            sumOfBlockSzs += _loc6_;
            param1 = GWizUtils.roundTenths(param1);
            if(_loc6_ > 0)
            {
               (_loc7_ = new Object()).BlockSz = _loc6_;
               _loc7_.Remainder = param1;
               GageBlockStack.addItem(_loc7_);
            }
            else
            {
               cantDoItVisible = true;
            }
            _loc5_--;
            if(param1 <= 0 || _loc6_ <= 0 || _loc5_ <= 0)
            {
               _loc4_ = true;
            }
         }
         sumOfBlockSzs = GWizUtils.roundHundredThousandths(sumOfBlockSzs);
         GageBlockStack.refresh();
      }
      
      private static function downloadBlockSizes(param1:ArrayCollection) : void
      {
         var _loc2_:File = null;
         if(param1)
         {
            GBSizes = new ArrayCollection();
            GBSizes.addAll(param1);
         }
         if(GBSizes)
         {
            _loc2_ = GWizSettings.getPrefsFile("GageBlockSizes.csv");
            GWizCSVUtils.saveCSVFile(_loc2_,GBSizes,gageBlockFields);
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizGageBlocks._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      private static function get GageBlockStack() : ArrayCollection
      {
         return GWizGageBlocks._1649136781GageBlockStack;
      }
      
      private static function set GageBlockStack(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizGageBlocks._1649136781GageBlockStack;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizGageBlocks,"GageBlockStack",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get cantDoItVisible() : Boolean
      {
         return GWizGageBlocks._1629666504cantDoItVisible;
      }
      
      private static function set cantDoItVisible(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizGageBlocks._1629666504cantDoItVisible;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizGageBlocks,"cantDoItVisible",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get sumOfBlockSzs() : Number
      {
         return GWizGageBlocks._1620590273sumOfBlockSzs;
      }
      
      private static function set sumOfBlockSzs(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizGageBlocks._1620590273sumOfBlockSzs;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizGageBlocks,"sumOfBlockSzs",_loc2_,param1));
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
      
      private function onCC() : void
      {
         var gageBlockSizeFile:File = GWizSettings.getPrefsFile("GageBlockSizes.csv");
         try
         {
            if(gageBlockSizeFile.exists)
            {
               GBSizes = GWizCSVUtils.loadCSVFile(gageBlockSizeFile);
            }
            else
            {
               this.resetBlockSizes();
            }
         }
         catch(e:Error)
         {
            GBSizes = null;
         }
      }
      
      private function recalc() : void
      {
         findStack(this.stackWidth.value,this.sizeInches.selected,this.blocksInches.selected);
      }
      
      private function UnitTest() : void
      {
         var _loc2_:Number = NaN;
         var _loc1_:int = 0;
         while(_loc1_ < 100)
         {
            _loc2_ = GWizUtils.randLimitsNum(0.01,2);
            this.stackWidth.value = _loc2_;
            _loc2_ = this.stackWidth.value;
            this.recalc();
            debugBreak = false;
            if(Math.abs(_loc2_ - sumOfBlockSzs) > 0.00009 || this.CantDoIt.visible == true)
            {
               log.debug("Test fails for " + _loc2_);
               debugBreak = true;
               this.recalc();
               debugBreak = false;
            }
            else
            {
               log.debug("Test passes: " + _loc2_);
            }
            _loc1_++;
         }
         log.debug("Unit test done!");
      }
      
      private function resetBlockSizes() : void
      {
         var _loc1_:String = "https://www.cnccookbook.com/Downloads/GageBlockSizes.csv";
         GWizCSVUtils.downloadCSV(_loc1_,downloadBlockSizes);
      }
      
      private function recalcSinBar(param1:Boolean = false) : void
      {
         var _loc2_:Number = this.sineBarLen.value * Math.sin(GWizUtils.radians(this.targetAngle.value));
         this.calculatedStackSize.text = String(GWizUtils.roundTenths(_loc2_));
         if(this.sbInches.selected)
         {
            this.calculatedStackSize.text += " inches";
         }
         else
         {
            this.calculatedStackSize.text += " mm";
         }
         var _loc3_:Number = GWizUtils.degrees(Math.asin(this.sineBarHeight.value / this.sineBarLen.value));
         this.sineBarAngle.text = GWizUtils.roundBigTenths2Str(_loc3_) + " degrees";
         if(param1)
         {
            this.stackWidth.value = _loc2_;
            this.recalc();
         }
      }
      
      private function _GWizGageBlocks_RadioButtonGroup2_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"gageBlocksInput");
         this.gageBlocksInput = _loc1_;
         BindingManager.executeBindings(this,"gageBlocksInput",this.gageBlocksInput);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_RadioButtonGroup3_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"sbSizeInput");
         this.sbSizeInput = _loc1_;
         BindingManager.executeBindings(this,"sbSizeInput",this.sbSizeInput);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_RadioButtonGroup4_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"ssSizeInput");
         this.ssSizeInput = _loc1_;
         BindingManager.executeBindings(this,"ssSizeInput",this.ssSizeInput);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"stackSzInput");
         this.stackSzInput = _loc1_;
         BindingManager.executeBindings(this,"stackSzInput",this.stackSzInput);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_GridComponent1_i() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.showXAxis = false;
         _loc1_.showYAxis = false;
         _loc1_.top = 10;
         _loc1_.bottom = 10;
         _loc1_.left = 10;
         _loc1_.right = 10;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizGageBlocks_Array2_c);
         _loc1_.setStyle("skinClass",GridSkin);
         _loc1_.id = "gridArea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gridArea = _loc1_;
         BindingManager.executeBindings(this,"gridArea",this.gridArea);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Array2_c() : Array
      {
         return [this._GWizGageBlocks_HGroup1_c()];
      }
      
      private function _GWizGageBlocks_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.x = 10;
         _loc1_.y = 10;
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizGageBlocks_VGroup1_c(),this._GWizGageBlocks_Spacer2_c(),this._GWizGageBlocks_VGroup2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.x = 10;
         _loc1_.y = 10;
         _loc1_.percentWidth = 50;
         _loc1_.mxmlContent = [this._GWizGageBlocks_Label1_c(),this._GWizGageBlocks_Label2_c(),this._GWizGageBlocks_HGroup2_c(),this._GWizGageBlocks_HGroup3_c(),this._GWizGageBlocks_Button1_c(),this._GWizGageBlocks_Label4_c(),this._GWizGageBlocks_Label5_c(),this._GWizGageBlocks_GWizDataGrid1_i(),this._GWizGageBlocks_Label6_c(),this._GWizGageBlocks_Label7_i(),this._GWizGageBlocks_Label8_i(),this._GWizGageBlocks_HGroup4_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Gage Block Calculator";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",16);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGageBlocks_GWizNumStep1_i(),this._GWizGageBlocks_RadioButton1_i(),this._GWizGageBlocks_RadioButton2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Stack Width: ";
         _loc1_.min = 0.01;
         _loc1_.max = 50;
         _loc1_.steps = 0.0001;
         _loc1_.value = 0.239;
         _loc1_.id = "stackWidth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.stackWidth = _loc1_;
         BindingManager.executeBindings(this,"stackWidth",this.stackWidth);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "inches";
         _loc1_.selected = true;
         _loc1_.id = "sizeInches";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sizeInches = _loc1_;
         BindingManager.executeBindings(this,"sizeInches",this.sizeInches);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "mm";
         _loc1_.selected = false;
         _loc1_.id = "_GWizGageBlocks_RadioButton2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGageBlocks_RadioButton2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGageBlocks_RadioButton2",this._GWizGageBlocks_RadioButton2);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGageBlocks_Label3_c(),this._GWizGageBlocks_RadioButton3_i(),this._GWizGageBlocks_RadioButton4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Gage Block Units: ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_RadioButton3_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "inches";
         _loc1_.selected = true;
         _loc1_.id = "blocksInches";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.blocksInches = _loc1_;
         BindingManager.executeBindings(this,"blocksInches",this.blocksInches);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_RadioButton4_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "mm";
         _loc1_.selected = false;
         _loc1_.id = "_GWizGageBlocks_RadioButton4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGageBlocks_RadioButton4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGageBlocks_RadioButton4",this._GWizGageBlocks_RadioButton4);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Recalc";
         _loc1_.addEventListener("click",this.___GWizGageBlocks_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizGageBlocks_Button1_click(param1:MouseEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizGageBlocks_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Wring together these gage blocks:";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_GWizDataGrid1_i() : GWizDataGrid
      {
         var _loc1_:GWizDataGrid = new GWizDataGrid();
         _loc1_.configId = "gageblocks";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.styleName = "fontSizeDelta-2";
         _loc1_.columns = this._GWizGageBlocks_ArrayCollection1_c();
         _loc1_.id = "gageblocks";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gageblocks = _loc1_;
         BindingManager.executeBindings(this,"gageblocks",this.gageblocks);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_ArrayCollection1_c() : ArrayCollection
      {
         var _loc1_:ArrayCollection = new ArrayCollection();
         _loc1_.source = [this._GWizGageBlocks_GWizGridColumn1_c(),this._GWizGageBlocks_GWizGridColumn2_c()];
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_GWizGridColumn1_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colBlockSz";
         _loc1_.width = 100;
         _loc1_.dataField = "BlockSz";
         _loc1_.headerText = "Block Size";
         return _loc1_;
      }
      
      private function _GWizGageBlocks_GWizGridColumn2_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colRemainder";
         _loc1_.width = 100;
         _loc1_.dataField = "Remainder";
         _loc1_.headerText = "Remainder";
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "sumOfSizes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sumOfSizes = _loc1_;
         BindingManager.executeBindings(this,"sumOfSizes",this.sumOfSizes);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Can\'t do it with these gage blocks!";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "CantDoIt";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CantDoIt = _loc1_;
         BindingManager.executeBindings(this,"CantDoIt",this.CantDoIt);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizGageBlocks_Button2_i(),this._GWizGageBlocks_Spacer1_c(),this._GWizGageBlocks_Button3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Unit Test";
         _loc1_.addEventListener("click",this.___GWizGageBlocks_Button2_click);
         _loc1_.id = "_GWizGageBlocks_Button2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGageBlocks_Button2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGageBlocks_Button2",this._GWizGageBlocks_Button2);
         return _loc1_;
      }
      
      public function ___GWizGageBlocks_Button2_click(param1:MouseEvent) : void
      {
         this.UnitTest();
      }
      
      private function _GWizGageBlocks_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Button3_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Reset Block Sizes";
         _loc1_.toolTip = "Download a fresh copy of the gage block sizes. You will lose any changes you made to GageBlockSizes.csv!";
         _loc1_.addEventListener("click",this.___GWizGageBlocks_Button3_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizGageBlocks_Button3_click(param1:MouseEvent) : void
      {
         this.resetBlockSizes();
      }
      
      private function _GWizGageBlocks_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.x = 10;
         _loc1_.y = 10;
         _loc1_.percentWidth = 50;
         _loc1_.mxmlContent = [this._GWizGageBlocks_Label9_c(),this._GWizGageBlocks_Label10_c(),this._GWizGageBlocks_HGroup5_c(),this._GWizGageBlocks_Label11_c(),this._GWizGageBlocks_Label12_c(),this._GWizGageBlocks_HGroup6_c(),this._GWizGageBlocks_HGroup7_c(),this._GWizGageBlocks_Button4_c(),this._GWizGageBlocks_Label16_c(),this._GWizGageBlocks_Label17_c(),this._GWizGageBlocks_GWizNumStep4_i(),this._GWizGageBlocks_RadioButton7_i(),this._GWizGageBlocks_RadioButton8_i(),this._GWizGageBlocks_HGroup8_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label9_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Sine Bar Calculator";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",16);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label10_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGageBlocks_GWizNumStep2_i(),this._GWizGageBlocks_RadioButton5_i(),this._GWizGageBlocks_RadioButton6_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Sine Bar Length: ";
         _loc1_.min = 0.01;
         _loc1_.max = 50;
         _loc1_.steps = 0.0001;
         _loc1_.value = 5;
         _loc1_.usesMetric = false;
         _loc1_.toolTip = "Enter the length of your sine bar.  Typical sizes are 5 and 10 inches.";
         _loc1_.addEventListener("valueCommit",this.__sineBarLen_valueCommit);
         _loc1_.id = "sineBarLen";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sineBarLen = _loc1_;
         BindingManager.executeBindings(this,"sineBarLen",this.sineBarLen);
         return _loc1_;
      }
      
      public function __sineBarLen_valueCommit(param1:FlexEvent) : void
      {
         this.recalcSinBar();
      }
      
      private function _GWizGageBlocks_RadioButton5_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "inches";
         _loc1_.selected = true;
         _loc1_.id = "sbInches";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sbInches = _loc1_;
         BindingManager.executeBindings(this,"sbInches",this.sbInches);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_RadioButton6_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "mm";
         _loc1_.selected = false;
         _loc1_.id = "_GWizGageBlocks_RadioButton6";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGageBlocks_RadioButton6 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGageBlocks_RadioButton6",this._GWizGageBlocks_RadioButton6);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label11_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "  ";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label12_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Find Gage Block Stack Size from Angle";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGageBlocks_GWizNumStep3_i(),this._GWizGageBlocks_Label13_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Desired Angle: ";
         _loc1_.min = 0.01;
         _loc1_.max = 50;
         _loc1_.steps = 0.0001;
         _loc1_.value = 5;
         _loc1_.usesMetric = false;
         _loc1_.toolTip = "Enter the desired angle for your sine bar in degrees.";
         _loc1_.addEventListener("valueCommit",this.__targetAngle_valueCommit);
         _loc1_.id = "targetAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.targetAngle = _loc1_;
         BindingManager.executeBindings(this,"targetAngle",this.targetAngle);
         return _loc1_;
      }
      
      public function __targetAngle_valueCommit(param1:FlexEvent) : void
      {
         this.recalcSinBar();
      }
      
      private function _GWizGageBlocks_Label13_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "degrees";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_HGroup7_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGageBlocks_Label14_c(),this._GWizGageBlocks_Label15_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label14_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Gage Block Stack Size:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label15_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.000 in";
         _loc1_.id = "calculatedStackSize";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.calculatedStackSize = _loc1_;
         BindingManager.executeBindings(this,"calculatedStackSize",this.calculatedStackSize);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Button4_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Choose Blocks";
         _loc1_.addEventListener("click",this.___GWizGageBlocks_Button4_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizGageBlocks_Button4_click(param1:MouseEvent) : void
      {
         this.recalcSinBar(true);
      }
      
      private function _GWizGageBlocks_Label16_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "  ";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label17_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Find Angle from Gage Block Stack Size";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Stack Size: ";
         _loc1_.min = 0.01;
         _loc1_.max = 50;
         _loc1_.steps = 0.0001;
         _loc1_.value = 5;
         _loc1_.toolTip = "Enter the height of the Gage Block Stack. Same units as Sine Bar Length.";
         _loc1_.addEventListener("valueCommit",this.__sineBarHeight_valueCommit);
         _loc1_.id = "sineBarHeight";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sineBarHeight = _loc1_;
         BindingManager.executeBindings(this,"sineBarHeight",this.sineBarHeight);
         return _loc1_;
      }
      
      public function __sineBarHeight_valueCommit(param1:FlexEvent) : void
      {
         this.recalcSinBar();
      }
      
      private function _GWizGageBlocks_RadioButton7_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "inches";
         _loc1_.selected = true;
         _loc1_.id = "ssInches";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ssInches = _loc1_;
         BindingManager.executeBindings(this,"ssInches",this.ssInches);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_RadioButton8_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "mm";
         _loc1_.selected = false;
         _loc1_.id = "_GWizGageBlocks_RadioButton8";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGageBlocks_RadioButton8 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGageBlocks_RadioButton8",this._GWizGageBlocks_RadioButton8);
         return _loc1_;
      }
      
      private function _GWizGageBlocks_HGroup8_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGageBlocks_Label18_c(),this._GWizGageBlocks_Label19_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label18_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Sine Bar Angle:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGageBlocks_Label19_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.000 degrees";
         _loc1_.id = "sineBarAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sineBarAngle = _loc1_;
         BindingManager.executeBindings(this,"sineBarAngle",this.sineBarAngle);
         return _loc1_;
      }
      
      public function ___GWizGageBlocks_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizGageBlocks_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,null,null,"sizeInches.group","stackSzInput");
         result[1] = new Binding(this,null,null,"_GWizGageBlocks_RadioButton2.group","stackSzInput");
         result[2] = new Binding(this,null,null,"blocksInches.group","gageBlocksInput");
         result[3] = new Binding(this,null,null,"_GWizGageBlocks_RadioButton4.group","gageBlocksInput");
         result[4] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb4;
         },function(param1:uint):void
         {
            gageblocks.setStyle("selectionColor",param1);
         },"gageblocks.selectionColor");
         result[5] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            gageblocks.setStyle("rollOverColor",param1);
         },"gageblocks.rollOverColor");
         result[6] = new Binding(this,function():IList
         {
            return GageBlockStack;
         },null,"gageblocks.dataProvider");
         result[7] = new Binding(this,function():String
         {
            var _loc1_:* = "Sum of block sizes = " + String(sumOfBlockSzs);
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"sumOfSizes.text");
         result[8] = new Binding(this,function():Boolean
         {
            return cantDoItVisible;
         },null,"CantDoIt.visible");
         result[9] = new Binding(this,function():Boolean
         {
            return GWizUtils.debug;
         },null,"_GWizGageBlocks_Button2.visible");
         result[10] = new Binding(this,null,null,"sbInches.group","sbSizeInput");
         result[11] = new Binding(this,null,null,"_GWizGageBlocks_RadioButton6.group","sbSizeInput");
         result[12] = new Binding(this,null,null,"ssInches.group","ssSizeInput");
         result[13] = new Binding(this,null,null,"_GWizGageBlocks_RadioButton8.group","sbSizeInput");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get CantDoIt() : Label
      {
         return this._43810822CantDoIt;
      }
      
      public function set CantDoIt(param1:Label) : void
      {
         var _loc2_:Object = this._43810822CantDoIt;
         if(_loc2_ !== param1)
         {
            this._43810822CantDoIt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CantDoIt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get blocksInches() : RadioButton
      {
         return this._1239120994blocksInches;
      }
      
      public function set blocksInches(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1239120994blocksInches;
         if(_loc2_ !== param1)
         {
            this._1239120994blocksInches = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"blocksInches",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get calculatedStackSize() : Label
      {
         return this._2020319605calculatedStackSize;
      }
      
      public function set calculatedStackSize(param1:Label) : void
      {
         var _loc2_:Object = this._2020319605calculatedStackSize;
         if(_loc2_ !== param1)
         {
            this._2020319605calculatedStackSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"calculatedStackSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gageBlocksInput() : RadioButtonGroup
      {
         return this._2004760692gageBlocksInput;
      }
      
      public function set gageBlocksInput(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._2004760692gageBlocksInput;
         if(_loc2_ !== param1)
         {
            this._2004760692gageBlocksInput = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gageBlocksInput",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gageblocks() : GWizDataGrid
      {
         return this._817246530gageblocks;
      }
      
      public function set gageblocks(param1:GWizDataGrid) : void
      {
         var _loc2_:Object = this._817246530gageblocks;
         if(_loc2_ !== param1)
         {
            this._817246530gageblocks = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gageblocks",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gridArea() : GridComponent
      {
         return this._317504755gridArea;
      }
      
      public function set gridArea(param1:GridComponent) : void
      {
         var _loc2_:Object = this._317504755gridArea;
         if(_loc2_ !== param1)
         {
            this._317504755gridArea = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gridArea",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sbInches() : RadioButton
      {
         return this._1830308263sbInches;
      }
      
      public function set sbInches(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1830308263sbInches;
         if(_loc2_ !== param1)
         {
            this._1830308263sbInches = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sbInches",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sbSizeInput() : RadioButtonGroup
      {
         return this._89187654sbSizeInput;
      }
      
      public function set sbSizeInput(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._89187654sbSizeInput;
         if(_loc2_ !== param1)
         {
            this._89187654sbSizeInput = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sbSizeInput",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sineBarAngle() : Label
      {
         return this._1765603795sineBarAngle;
      }
      
      public function set sineBarAngle(param1:Label) : void
      {
         var _loc2_:Object = this._1765603795sineBarAngle;
         if(_loc2_ !== param1)
         {
            this._1765603795sineBarAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sineBarAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sineBarHeight() : GWizNumStep
      {
         return this._1293004557sineBarHeight;
      }
      
      public function set sineBarHeight(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1293004557sineBarHeight;
         if(_loc2_ !== param1)
         {
            this._1293004557sineBarHeight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sineBarHeight",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sineBarLen() : GWizNumStep
      {
         return this._2066629137sineBarLen;
      }
      
      public function set sineBarLen(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._2066629137sineBarLen;
         if(_loc2_ !== param1)
         {
            this._2066629137sineBarLen = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sineBarLen",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sizeInches() : RadioButton
      {
         return this._1879215577sizeInches;
      }
      
      public function set sizeInches(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1879215577sizeInches;
         if(_loc2_ !== param1)
         {
            this._1879215577sizeInches = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sizeInches",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ssInches() : RadioButton
      {
         return this._261998344ssInches;
      }
      
      public function set ssInches(param1:RadioButton) : void
      {
         var _loc2_:Object = this._261998344ssInches;
         if(_loc2_ !== param1)
         {
            this._261998344ssInches = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ssInches",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ssSizeInput() : RadioButtonGroup
      {
         return this._865050057ssSizeInput;
      }
      
      public function set ssSizeInput(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._865050057ssSizeInput;
         if(_loc2_ !== param1)
         {
            this._865050057ssSizeInput = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ssSizeInput",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stackSzInput() : RadioButtonGroup
      {
         return this._954445307stackSzInput;
      }
      
      public function set stackSzInput(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._954445307stackSzInput;
         if(_loc2_ !== param1)
         {
            this._954445307stackSzInput = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stackSzInput",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stackWidth() : GWizNumStep
      {
         return this._2028785694stackWidth;
      }
      
      public function set stackWidth(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._2028785694stackWidth;
         if(_loc2_ !== param1)
         {
            this._2028785694stackWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stackWidth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sumOfSizes() : Label
      {
         return this._1056804816sumOfSizes;
      }
      
      public function set sumOfSizes(param1:Label) : void
      {
         var _loc2_:Object = this._1056804816sumOfSizes;
         if(_loc2_ !== param1)
         {
            this._1056804816sumOfSizes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sumOfSizes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get targetAngle() : GWizNumStep
      {
         return this._2112460350targetAngle;
      }
      
      public function set targetAngle(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._2112460350targetAngle;
         if(_loc2_ !== param1)
         {
            this._2112460350targetAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"targetAngle",_loc2_,param1));
            }
         }
      }
   }
}
