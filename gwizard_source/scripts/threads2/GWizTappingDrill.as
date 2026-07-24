package threads2
{
   import comps.GWizDataGrid;
   import comps.GWizForePanel;
   import comps.GWizGridColumn;
   import comps.GWizPopUpManager;
   import flash.events.MouseEvent;
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
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.layouts.VerticalLayout;
   
   use namespace mx_internal;
   
   public class GWizTappingDrill extends GWizForePanel implements IBindingClient
   {
      
      public static var bhClearanceCalc:BlindHoleClearancePopup;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1501463536Cutting:RadioButton;
      
      private var _2195684Form:RadioButton;
      
      public var _GWizTappingDrill_Button1:Button;
      
      private var _229412975itDiaCol:GWizGridColumn;
      
      private var _164873549radiogroup1:RadioButtonGroup;
      
      private var _609885603threadPctGrid:GWizDataGrid;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var recalcFcn:Function;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizTappingDrill()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizTappingDrill_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_threads2_GWizTappingDrillWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizTappingDrill[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.layout = this._GWizTappingDrill_VerticalLayout1_c();
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizTappingDrill_Array1_c);
         this._GWizTappingDrill_RadioButtonGroup1_i();
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizTappingDrill._watcherSetupUtil = param1;
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
      
      private function doBlindHoleClearance() : void
      {
         bhClearanceCalc = BlindHoleClearancePopup(GWizPopUpManager.createPopUp(null,BlindHoleClearancePopup,true));
      }
      
      private function _GWizTappingDrill_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"radiogroup1");
         this.radiogroup1 = _loc1_;
         BindingManager.executeBindings(this,"radiogroup1",this.radiogroup1);
         return _loc1_;
      }
      
      private function _GWizTappingDrill_VerticalLayout1_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizTappingDrill_Array1_c() : Array
      {
         return [this._GWizTappingDrill_Label1_c(),this._GWizTappingDrill_HGroup1_c(),this._GWizTappingDrill_GWizDataGrid1_i(),this._GWizTappingDrill_Button1_i()];
      }
      
      private function _GWizTappingDrill_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 39;
         _loc1_.y = 217;
         _loc1_.text = "Tapping Drill";
         _loc1_.styleName = "fontSizeDelta2";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTappingDrill_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizTappingDrill_RadioButton1_i(),this._GWizTappingDrill_RadioButton2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTappingDrill_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Cutting";
         _loc1_.groupName = "radiogroup1";
         _loc1_.selected = true;
         _loc1_.addEventListener("valueCommit",this.__Cutting_valueCommit);
         _loc1_.id = "Cutting";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Cutting = _loc1_;
         BindingManager.executeBindings(this,"Cutting",this.Cutting);
         return _loc1_;
      }
      
      public function __Cutting_valueCommit(param1:FlexEvent) : void
      {
         this.recalcFcn();
      }
      
      private function _GWizTappingDrill_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Form";
         _loc1_.groupName = "radiogroup1";
         _loc1_.addEventListener("valueCommit",this.__Form_valueCommit);
         _loc1_.id = "Form";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Form = _loc1_;
         BindingManager.executeBindings(this,"Form",this.Form);
         return _loc1_;
      }
      
      public function __Form_valueCommit(param1:FlexEvent) : void
      {
         this.recalcFcn();
      }
      
      private function _GWizTappingDrill_GWizDataGrid1_i() : GWizDataGrid
      {
         var _loc1_:GWizDataGrid = new GWizDataGrid();
         _loc1_.configId = "threadRef";
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "Negative % thread are clearance holes. -6% = Close, -12% = Normal";
         _loc1_.columns = this._GWizTappingDrill_ArrayList1_c();
         _loc1_.id = "threadPctGrid";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.threadPctGrid = _loc1_;
         BindingManager.executeBindings(this,"threadPctGrid",this.threadPctGrid);
         return _loc1_;
      }
      
      private function _GWizTappingDrill_ArrayList1_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizTappingDrill_GWizGridColumn1_c(),this._GWizTappingDrill_GWizGridColumn2_i(),this._GWizTappingDrill_GWizGridColumn3_c()];
         return _loc1_;
      }
      
      private function _GWizTappingDrill_GWizGridColumn1_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colDrill";
         _loc1_.headerText = "Drill";
         _loc1_.dataField = "designation";
         return _loc1_;
      }
      
      private function _GWizTappingDrill_GWizGridColumn2_i() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colDia";
         _loc1_.headerText = "Diameter";
         this.itDiaCol = _loc1_;
         BindingManager.executeBindings(this,"itDiaCol",this.itDiaCol);
         return _loc1_;
      }
      
      private function _GWizTappingDrill_GWizGridColumn3_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colPct";
         _loc1_.headerText = "% Thread";
         _loc1_.dataField = "pct";
         return _loc1_;
      }
      
      private function _GWizTappingDrill_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Blind Clearance";
         _loc1_.toolTip = "Clearance to leave between bottom of tap and hole bottom when tapping blind holes.";
         _loc1_.addEventListener("click",this.___GWizTappingDrill_Button1_click);
         _loc1_.id = "_GWizTappingDrill_Button1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizTappingDrill_Button1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizTappingDrill_Button1",this._GWizTappingDrill_Button1);
         return _loc1_;
      }
      
      public function ___GWizTappingDrill_Button1_click(param1:MouseEvent) : void
      {
         this.doBlindHoleClearance();
      }
      
      private function _GWizTappingDrill_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Boolean
         {
            return this.enabled;
         },null,"this.visible");
         result[1] = new Binding(this,function():Boolean
         {
            return this.enabled;
         },null,"this.includeInLayout");
         result[2] = new Binding(this,function():IList
         {
            return GWizAbstractThreadEngine.tapDrillList;
         },null,"threadPctGrid.dataProvider");
         result[3] = new Binding(this,function():Number
         {
            return threadPctGrid.width;
         },null,"_GWizTappingDrill_Button1.width");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Cutting() : RadioButton
      {
         return this._1501463536Cutting;
      }
      
      public function set Cutting(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1501463536Cutting;
         if(_loc2_ !== param1)
         {
            this._1501463536Cutting = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Cutting",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Form() : RadioButton
      {
         return this._2195684Form;
      }
      
      public function set Form(param1:RadioButton) : void
      {
         var _loc2_:Object = this._2195684Form;
         if(_loc2_ !== param1)
         {
            this._2195684Form = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Form",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get itDiaCol() : GWizGridColumn
      {
         return this._229412975itDiaCol;
      }
      
      public function set itDiaCol(param1:GWizGridColumn) : void
      {
         var _loc2_:Object = this._229412975itDiaCol;
         if(_loc2_ !== param1)
         {
            this._229412975itDiaCol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"itDiaCol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get radiogroup1() : RadioButtonGroup
      {
         return this._164873549radiogroup1;
      }
      
      public function set radiogroup1(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._164873549radiogroup1;
         if(_loc2_ !== param1)
         {
            this._164873549radiogroup1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"radiogroup1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get threadPctGrid() : GWizDataGrid
      {
         return this._609885603threadPctGrid;
      }
      
      public function set threadPctGrid(param1:GWizDataGrid) : void
      {
         var _loc2_:Object = this._609885603threadPctGrid;
         if(_loc2_ !== param1)
         {
            this._609885603threadPctGrid = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"threadPctGrid",_loc2_,param1));
            }
         }
      }
   }
}
