package apps
{
   import comps.GWizDataGrid;
   import comps.GWizForePanel;
   import comps.GWizGridColumn;
   import comps.GWizHardnessChooser;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import material.GWizMaterialsDB;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.VGroup;
   import utils.ColorPalette;
   import utils.GWizCSVUtils;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizHardness extends GWizForePanel implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1986596748fromHardness:GWizHardnessChooser;
      
      private var _116645314hardness:GWizDataGrid;
      
      private var _96576861toHardness:GWizHardnessChooser;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var hardnessFields:Array;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizHardness()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.hardnessFields = ["RockwellC","DiamondPyr","BrinStdBall","BrinHult","BrinTung","RockA","RockD","Rock15","Rock30","Rock45","Shore","Leeb","RockB","Vickers","Tensile"];
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizHardness_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_apps_GWizHardnessWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizHardness[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizHardness_Array1_c);
         this.addEventListener("creationComplete",this.___GWizHardness_GWizForePanel1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizHardness._watcherSetupUtil = param1;
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
         if(false && GWizUtils.debug)
         {
            GWizCSVUtils.saveCSVFileURL("C:\\Users\\BobWarfield\\Dropbox\\CNCCookbook\\ArticleResearch\\Hardness.csv",GWizMaterialsDB.HardnessConv,this.hardnessFields);
         }
      }
      
      public function convertZeros(param1:Object, param2:GWizGridColumn) : String
      {
         var _loc3_:String = "";
         if(param2.headerText == "Brinell Standard")
         {
            if(param1.BrinStdBall == 0)
            {
               _loc3_ = "";
            }
            else
            {
               _loc3_ = param1.BrinStdBall;
            }
         }
         else if(param2.headerText == "Brinell Hultgren")
         {
            if(param1.BrinHult == 0)
            {
               _loc3_ = "";
            }
            else
            {
               _loc3_ = param1.BrinHult;
            }
         }
         else if(param2.headerText == "Brinell Tungsten")
         {
            if(param1.BrinTung == 0)
            {
               _loc3_ = "";
            }
            else
            {
               _loc3_ = param1.BrinTung;
            }
         }
         return _loc3_;
      }
      
      private function recalc() : void
      {
         var _loc1_:String = this.fromHardness.Units.selectedItem.name;
         var _loc2_:String = this.toHardness.Units.selectedItem.name;
         this.toHardness.Hardness.value = GWizHardnessChooser.convertHardness(this.fromHardness.Hardness.value,_loc1_,_loc2_);
         this.hardness.selectedIndex = GWizHardnessChooser.lookupRow;
      }
      
      private function _GWizHardness_Array1_c() : Array
      {
         return [this._GWizHardness_VGroup1_c()];
      }
      
      private function _GWizHardness_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 10;
         _loc1_.paddingRight = 10;
         _loc1_.paddingTop = 10;
         _loc1_.mxmlContent = [this._GWizHardness_HGroup1_c(),this._GWizHardness_GWizDataGrid1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizHardness_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizHardness_Label1_c(),this._GWizHardness_GWizHardnessChooser1_i(),this._GWizHardness_Label2_c(),this._GWizHardness_GWizHardnessChooser2_i(),this._GWizHardness_Label3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizHardness_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Convert Hardness From ";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizHardness_GWizHardnessChooser1_i() : GWizHardnessChooser
      {
         var _loc1_:GWizHardnessChooser = new GWizHardnessChooser();
         _loc1_.addEventListener("click",this.__fromHardness_click);
         _loc1_.addEventListener("keyUp",this.__fromHardness_keyUp);
         _loc1_.id = "fromHardness";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fromHardness = _loc1_;
         BindingManager.executeBindings(this,"fromHardness",this.fromHardness);
         return _loc1_;
      }
      
      public function __fromHardness_click(param1:MouseEvent) : void
      {
         this.recalc();
      }
      
      public function __fromHardness_keyUp(param1:KeyboardEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizHardness_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " To ";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizHardness_GWizHardnessChooser2_i() : GWizHardnessChooser
      {
         var _loc1_:GWizHardnessChooser = new GWizHardnessChooser();
         _loc1_.changeFcn = this.recalc;
         _loc1_.id = "toHardness";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toHardness = _loc1_;
         BindingManager.executeBindings(this,"toHardness",this.toHardness);
         return _loc1_;
      }
      
      private function _GWizHardness_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " (0 means no conversion possible)";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizHardness_GWizDataGrid1_i() : GWizDataGrid
      {
         var _loc1_:GWizDataGrid = new GWizDataGrid();
         _loc1_.configId = "hardness";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.styleName = "fontSizeDelta-2";
         _loc1_.columns = this._GWizHardness_ArrayCollection1_c();
         _loc1_.id = "hardness";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.hardness = _loc1_;
         BindingManager.executeBindings(this,"hardness",this.hardness);
         return _loc1_;
      }
      
      private function _GWizHardness_ArrayCollection1_c() : ArrayCollection
      {
         var _loc1_:ArrayCollection = new ArrayCollection();
         _loc1_.source = [this._GWizHardness_GWizGridColumn1_c(),this._GWizHardness_GWizGridColumn2_c(),this._GWizHardness_GWizGridColumn3_c(),this._GWizHardness_GWizGridColumn4_c(),this._GWizHardness_GWizGridColumn5_c(),this._GWizHardness_GWizGridColumn6_c(),this._GWizHardness_GWizGridColumn7_c(),this._GWizHardness_GWizGridColumn8_c(),this._GWizHardness_GWizGridColumn9_c(),this._GWizHardness_GWizGridColumn10_c(),this._GWizHardness_GWizGridColumn11_c(),this._GWizHardness_GWizGridColumn12_c(),this._GWizHardness_GWizGridColumn13_c()];
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizHardness_GWizGridColumn1_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colRockA";
         _loc1_.width = 100;
         _loc1_.dataField = "RockA";
         _loc1_.headerText = "Rockwell A";
         return _loc1_;
      }
      
      private function _GWizHardness_GWizGridColumn2_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colRockB";
         _loc1_.width = 100;
         _loc1_.dataField = "RockB";
         _loc1_.headerText = "Rockwell B";
         return _loc1_;
      }
      
      private function _GWizHardness_GWizGridColumn3_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colRockwellC";
         _loc1_.width = 100;
         _loc1_.dataField = "RockwellC";
         _loc1_.headerText = "Rockwell C";
         return _loc1_;
      }
      
      private function _GWizHardness_GWizGridColumn4_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colRockD";
         _loc1_.width = 100;
         _loc1_.dataField = "RockD";
         _loc1_.headerText = "Rockwell D";
         return _loc1_;
      }
      
      private function _GWizHardness_GWizGridColumn5_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colRock15";
         _loc1_.width = 100;
         _loc1_.dataField = "Rock15";
         _loc1_.headerText = "Rockwell 15N";
         return _loc1_;
      }
      
      private function _GWizHardness_GWizGridColumn6_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colRock30";
         _loc1_.width = 100;
         _loc1_.dataField = "Rock30";
         _loc1_.headerText = "Rockwell 30N";
         return _loc1_;
      }
      
      private function _GWizHardness_GWizGridColumn7_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colRock45";
         _loc1_.width = 100;
         _loc1_.dataField = "Rock45";
         _loc1_.headerText = "Rockwell 45N";
         return _loc1_;
      }
      
      private function _GWizHardness_GWizGridColumn8_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colBriStd";
         _loc1_.width = 100;
         _loc1_.dataField = "BrinStdBall";
         _loc1_.headerText = "Brinell Standard";
         _loc1_.labelFunction = this.convertZeros;
         return _loc1_;
      }
      
      private function _GWizHardness_GWizGridColumn9_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colBriHult";
         _loc1_.width = 100;
         _loc1_.dataField = "BrinHult";
         _loc1_.headerText = "Brinell Hultgren";
         _loc1_.labelFunction = this.convertZeros;
         return _loc1_;
      }
      
      private function _GWizHardness_GWizGridColumn10_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colBriTung";
         _loc1_.width = 100;
         _loc1_.dataField = "BrinTung";
         _loc1_.headerText = "Brinell Tungsten";
         _loc1_.labelFunction = this.convertZeros;
         return _loc1_;
      }
      
      private function _GWizHardness_GWizGridColumn11_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colVickers";
         _loc1_.width = 100;
         _loc1_.dataField = "Vickers";
         _loc1_.headerText = "Vickers";
         return _loc1_;
      }
      
      private function _GWizHardness_GWizGridColumn12_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colShore";
         _loc1_.width = 100;
         _loc1_.dataField = "Shore";
         _loc1_.headerText = "Shore Scler.";
         return _loc1_;
      }
      
      private function _GWizHardness_GWizGridColumn13_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colTensile";
         _loc1_.width = 100;
         _loc1_.dataField = "Tensile";
         _loc1_.headerText = "Tensile (psi)";
         return _loc1_;
      }
      
      public function ___GWizHardness_GWizForePanel1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizHardness_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb4;
         },function(param1:uint):void
         {
            hardness.setStyle("selectionColor",param1);
         },"hardness.selectionColor");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            hardness.setStyle("rollOverColor",param1);
         },"hardness.rollOverColor");
         result[2] = new Binding(this,function():IList
         {
            return GWizMaterialsDB.HardnessConv;
         },null,"hardness.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get fromHardness() : GWizHardnessChooser
      {
         return this._1986596748fromHardness;
      }
      
      public function set fromHardness(param1:GWizHardnessChooser) : void
      {
         var _loc2_:Object = this._1986596748fromHardness;
         if(_loc2_ !== param1)
         {
            this._1986596748fromHardness = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fromHardness",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hardness() : GWizDataGrid
      {
         return this._116645314hardness;
      }
      
      public function set hardness(param1:GWizDataGrid) : void
      {
         var _loc2_:Object = this._116645314hardness;
         if(_loc2_ !== param1)
         {
            this._116645314hardness = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hardness",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toHardness() : GWizHardnessChooser
      {
         return this._96576861toHardness;
      }
      
      public function set toHardness(param1:GWizHardnessChooser) : void
      {
         var _loc2_:Object = this._96576861toHardness;
         if(_loc2_ !== param1)
         {
            this._96576861toHardness = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toHardness",_loc2_,param1));
            }
         }
      }
   }
}
