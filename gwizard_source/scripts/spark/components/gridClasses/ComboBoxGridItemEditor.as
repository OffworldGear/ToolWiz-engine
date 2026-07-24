package spark.components.gridClasses
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.IList;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.SolidColor;
   import spark.components.ComboBox;
   import spark.events.DropDownEvent;
   import spark.primitives.Rect;
   
   use namespace mx_internal;
   
   public class ComboBoxGridItemEditor extends GridItemEditor implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1391998104bgFill:SolidColor;
      
      private var _1391644727bgRect:Rect;
      
      private var _612318883comboBox:ComboBox;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _dataProvider:IList;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function ComboBoxGridItemEditor()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._ComboBoxGridItemEditor_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_spark_components_gridClasses_ComboBoxGridItemEditorWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return ComboBoxGridItemEditor[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.mxmlContent = [this._ComboBoxGridItemEditor_Rect1_i(),this._ComboBoxGridItemEditor_ComboBox1_i()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         ComboBoxGridItemEditor._watcherSetupUtil = param1;
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
      
      override public function get value() : Object
      {
         return this.comboBox.selectedItem;
      }
      
      override public function set value(param1:Object) : void
      {
         this.comboBox.selectedItem = param1;
      }
      
      [Bindable("comboBoxGridItemEditorDataProviderChanged")]
      public function get dataProvider() : IList
      {
         return this._dataProvider;
      }
      
      public function set dataProvider(param1:IList) : void
      {
         if(this._dataProvider == param1)
         {
            return;
         }
         this._dataProvider = param1;
         dispatchEvent(new Event("comboBoxGridItemEditorDataProviderChanged"));
      }
      
      override public function prepare() : void
      {
         super.prepare();
         this.comboBox.addEventListener(DropDownEvent.OPEN,this.dropDown_openHandler);
         this.comboBox.openDropDown();
      }
      
      override public function setFocus() : void
      {
         this.comboBox.setFocus();
      }
      
      private function dropDown_openHandler(param1:DropDownEvent) : void
      {
         if(this.comboBox.dataGroup)
         {
            this.comboBox.dataGroup.addEventListener(MouseEvent.MOUSE_DOWN,this.dataGroup_mouseClickHandler,false,0,true);
         }
      }
      
      private function dataGroup_mouseClickHandler(param1:MouseEvent) : void
      {
         callLater(dataGrid.endItemEditorSession);
      }
      
      private function _ComboBoxGridItemEditor_Rect1_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.top = 1;
         _loc1_.left = 1;
         _loc1_.bottom = 1;
         _loc1_.right = 1;
         _loc1_.fill = this._ComboBoxGridItemEditor_SolidColor1_i();
         _loc1_.initialized(this,"bgRect");
         this.bgRect = _loc1_;
         BindingManager.executeBindings(this,"bgRect",this.bgRect);
         return _loc1_;
      }
      
      private function _ComboBoxGridItemEditor_SolidColor1_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 16777215;
         this.bgFill = _loc1_;
         BindingManager.executeBindings(this,"bgFill",this.bgFill);
         return _loc1_;
      }
      
      private function _ComboBoxGridItemEditor_ComboBox1_i() : ComboBox
      {
         var _loc1_:ComboBox = new ComboBox();
         _loc1_.percentWidth = 100;
         _loc1_.id = "comboBox";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.comboBox = _loc1_;
         BindingManager.executeBindings(this,"comboBox",this.comboBox);
         return _loc1_;
      }
      
      private function _ComboBoxGridItemEditor_bindingsSetup() : Array
      {
         var _loc1_:Array = [];
         _loc1_[0] = new Binding(this,null,null,"comboBox.dataProvider","dataProvider");
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get bgFill() : SolidColor
      {
         return this._1391998104bgFill;
      }
      
      public function set bgFill(param1:SolidColor) : void
      {
         var _loc2_:Object = this._1391998104bgFill;
         if(_loc2_ !== param1)
         {
            this._1391998104bgFill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"bgFill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get bgRect() : Rect
      {
         return this._1391644727bgRect;
      }
      
      public function set bgRect(param1:Rect) : void
      {
         var _loc2_:Object = this._1391644727bgRect;
         if(_loc2_ !== param1)
         {
            this._1391644727bgRect = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"bgRect",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get comboBox() : ComboBox
      {
         return this._612318883comboBox;
      }
      
      public function set comboBox(param1:ComboBox) : void
      {
         var _loc2_:Object = this._612318883comboBox;
         if(_loc2_ !== param1)
         {
            this._612318883comboBox = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"comboBox",_loc2_,param1));
            }
         }
      }
   }
}
