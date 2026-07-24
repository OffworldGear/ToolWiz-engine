package apps
{
   import comps.GWizForePanel;
   import comps.GWizGMCodePanel;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import post.GWizGCParseData;
   import spark.components.DataGrid;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.VGroup;
   import spark.components.gridClasses.GridColumn;
   import utils.ColorPalette;
   
   use namespace mx_internal;
   
   public class GWizGMCodeReference extends GWizForePanel implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      public var _GWizGMCodeReference_Label1:Label;
      
      private var _1732925274dgOCodes:DataGrid;
      
      private var _121056446gmPanel:GWizGMCodePanel;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizGMCodeReference()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizGMCodeReference_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_apps_GWizGMCodeReferenceWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizGMCodeReference[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizGMCodeReference_Array1_c);
         this.addEventListener("creationComplete",this.___GWizGMCodeReference_GWizForePanel1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizGMCodeReference._watcherSetupUtil = param1;
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
         this.gmPanel.changeGroup("G");
      }
      
      private function _GWizGMCodeReference_Array1_c() : Array
      {
         return [this._GWizGMCodeReference_HGroup1_c()];
      }
      
      private function _GWizGMCodeReference_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 10;
         _loc1_.paddingRight = 10;
         _loc1_.paddingTop = 10;
         _loc1_.mxmlContent = [this._GWizGMCodeReference_GWizGMCodePanel1_i(),this._GWizGMCodeReference_VGroup1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGMCodeReference_GWizGMCodePanel1_i() : GWizGMCodePanel
      {
         var _loc1_:GWizGMCodePanel = new GWizGMCodePanel();
         _loc1_.percentWidth = 60;
         _loc1_.percentHeight = 100;
         _loc1_.id = "gmPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gmPanel = _loc1_;
         BindingManager.executeBindings(this,"gmPanel",this.gmPanel);
         return _loc1_;
      }
      
      private function _GWizGMCodeReference_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 40;
         _loc1_.mxmlContent = [this._GWizGMCodeReference_Label1_i(),this._GWizGMCodeReference_DataGrid1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGMCodeReference_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Other Codes";
         _loc1_.horizontalCenter = true;
         _loc1_.id = "_GWizGMCodeReference_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGMCodeReference_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGMCodeReference_Label1",this._GWizGMCodeReference_Label1);
         return _loc1_;
      }
      
      private function _GWizGMCodeReference_DataGrid1_i() : DataGrid
      {
         var _loc1_:DataGrid = null;
         _loc1_ = new DataGrid();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.columns = this._GWizGMCodeReference_ArrayList1_c();
         _loc1_.id = "dgOCodes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.dgOCodes = _loc1_;
         BindingManager.executeBindings(this,"dgOCodes",this.dgOCodes);
         return _loc1_;
      }
      
      private function _GWizGMCodeReference_ArrayList1_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizGMCodeReference_GridColumn1_c(),this._GWizGMCodeReference_GridColumn2_c()];
         return _loc1_;
      }
      
      private function _GWizGMCodeReference_GridColumn1_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Code";
         _loc1_.dataField = "code";
         _loc1_.width = 50;
         return _loc1_;
      }
      
      private function _GWizGMCodeReference_GridColumn2_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Function";
         _loc1_.dataField = "hint";
         return _loc1_;
      }
      
      public function ___GWizGMCodeReference_GWizForePanel1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizGMCodeReference_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            _GWizGMCodeReference_Label1.setStyle("color",param1);
         },"_GWizGMCodeReference_Label1.color");
         result[1] = new Binding(this,function():IList
         {
            return GWizGCParseData.OtherCodes;
         },null,"dgOCodes.dataProvider");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb4;
         },function(param1:uint):void
         {
            dgOCodes.setStyle("selectionColor",param1);
         },"dgOCodes.selectionColor");
         result[3] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            dgOCodes.setStyle("rollOverColor",param1);
         },"dgOCodes.rollOverColor");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get dgOCodes() : DataGrid
      {
         return this._1732925274dgOCodes;
      }
      
      public function set dgOCodes(param1:DataGrid) : void
      {
         var _loc2_:Object = this._1732925274dgOCodes;
         if(_loc2_ !== param1)
         {
            this._1732925274dgOCodes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"dgOCodes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gmPanel() : GWizGMCodePanel
      {
         return this._121056446gmPanel;
      }
      
      public function set gmPanel(param1:GWizGMCodePanel) : void
      {
         var _loc2_:Object = this._121056446gmPanel;
         if(_loc2_ !== param1)
         {
            this._121056446gmPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gmPanel",_loc2_,param1));
            }
         }
      }
   }
}
