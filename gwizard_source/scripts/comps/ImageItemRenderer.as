package comps
{
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.states.SetProperty;
   import mx.states.SetStyle;
   import mx.states.State;
   import spark.components.Label;
   import spark.components.VGroup;
   import spark.components.supportClasses.ItemRenderer;
   import spark.filters.ColorMatrixFilter;
   import spark.primitives.BitmapImage;
   
   use namespace mx_internal;
   
   public class ImageItemRenderer extends ItemRenderer implements IBindingClient, IStateClient2
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1566445913_ImageItemRenderer_SetProperty1:SetProperty;
      
      private var _1566445912_ImageItemRenderer_SetProperty2:SetProperty;
      
      private var _1566445911_ImageItemRenderer_SetProperty3:SetProperty;
      
      private var _1566445910_ImageItemRenderer_SetProperty4:SetProperty;
      
      private var _21946069_ImageItemRenderer_SetStyle1:SetStyle;
      
      private var _21946070_ImageItemRenderer_SetStyle2:SetStyle;
      
      private var _21946071_ImageItemRenderer_SetStyle3:SetStyle;
      
      private var _21946072_ImageItemRenderer_SetStyle4:SetStyle;
      
      private var _100313435image:BitmapImage;
      
      private var _1721941989nameTxt:Label;
      
      private var _1513016745rolloverFilter:ColorMatrixFilter;
      
      private var _1478232563selectedFilter:ColorMatrixFilter;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function ImageItemRenderer()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._ImageItemRenderer_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_ImageItemRendererWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return ImageItemRenderer[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.name = "ImageItemRenderer";
         this.autoDrawBackground = false;
         this.focusEnabled = false;
         this.mxmlContent = [this._ImageItemRenderer_VGroup1_c()];
         this.currentState = "normal";
         this._ImageItemRenderer_ColorMatrixFilter2_i();
         this._ImageItemRenderer_ColorMatrixFilter1_i();
         states = [new State({
            "name":"normal",
            "overrides":[]
         }),new State({
            "name":"hovered",
            "overrides":[this._ImageItemRenderer_SetProperty3 = SetProperty(new SetProperty().initializeFromObject({
               "target":"image",
               "name":"filters",
               "value":undefined
            })),new SetStyle().initializeFromObject({
               "target":"nameTxt",
               "name":"color",
               "value":0
            }),this._ImageItemRenderer_SetStyle1 = SetStyle(new SetStyle().initializeFromObject({
               "target":"nameTxt",
               "name":"backgroundColor",
               "value":undefined
            }))]
         }),new State({
            "name":"selected",
            "overrides":[this._ImageItemRenderer_SetProperty1 = SetProperty(new SetProperty().initializeFromObject({
               "target":"image",
               "name":"filters",
               "value":undefined
            })),this._ImageItemRenderer_SetStyle3 = SetStyle(new SetStyle().initializeFromObject({
               "target":"nameTxt",
               "name":"backgroundColor",
               "value":undefined
            }))]
         }),new State({
            "name":"normalAndShowsCaret",
            "overrides":[]
         }),new State({
            "name":"hoveredAndShowsCaret",
            "overrides":[this._ImageItemRenderer_SetProperty4 = SetProperty(new SetProperty().initializeFromObject({
               "target":"image",
               "name":"filters",
               "value":undefined
            })),new SetStyle().initializeFromObject({
               "target":"nameTxt",
               "name":"color",
               "value":0
            }),this._ImageItemRenderer_SetStyle2 = SetStyle(new SetStyle().initializeFromObject({
               "target":"nameTxt",
               "name":"backgroundColor",
               "value":undefined
            }))]
         }),new State({
            "name":"selectedAndShowsCaret",
            "overrides":[this._ImageItemRenderer_SetProperty2 = SetProperty(new SetProperty().initializeFromObject({
               "target":"image",
               "name":"filters",
               "value":undefined
            })),this._ImageItemRenderer_SetStyle4 = SetStyle(new SetStyle().initializeFromObject({
               "target":"nameTxt",
               "name":"backgroundColor",
               "value":undefined
            }))]
         })];
         BindingManager.executeBindings(this,"_ImageItemRenderer_SetProperty3",this._ImageItemRenderer_SetProperty3);
         BindingManager.executeBindings(this,"_ImageItemRenderer_SetStyle1",this._ImageItemRenderer_SetStyle1);
         BindingManager.executeBindings(this,"_ImageItemRenderer_SetProperty1",this._ImageItemRenderer_SetProperty1);
         BindingManager.executeBindings(this,"_ImageItemRenderer_SetStyle3",this._ImageItemRenderer_SetStyle3);
         BindingManager.executeBindings(this,"_ImageItemRenderer_SetProperty4",this._ImageItemRenderer_SetProperty4);
         BindingManager.executeBindings(this,"_ImageItemRenderer_SetStyle2",this._ImageItemRenderer_SetStyle2);
         BindingManager.executeBindings(this,"_ImageItemRenderer_SetProperty2",this._ImageItemRenderer_SetProperty2);
         BindingManager.executeBindings(this,"_ImageItemRenderer_SetStyle4",this._ImageItemRenderer_SetStyle4);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         ImageItemRenderer._watcherSetupUtil = param1;
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
      
      override public function set data(param1:Object) : void
      {
         this.image.source = param1.src;
         this.nameTxt.text = param1.name;
      }
      
      private function _ImageItemRenderer_ColorMatrixFilter2_i() : ColorMatrixFilter
      {
         var _loc1_:ColorMatrixFilter = new ColorMatrixFilter();
         _loc1_.matrix = [0.5,0,0.5,0,0,0,1,0,0,0,1,0,1,0,1,0,0,0,1,0];
         this.rolloverFilter = _loc1_;
         BindingManager.executeBindings(this,"rolloverFilter",this.rolloverFilter);
         return _loc1_;
      }
      
      private function _ImageItemRenderer_ColorMatrixFilter1_i() : ColorMatrixFilter
      {
         var _loc1_:ColorMatrixFilter = new ColorMatrixFilter();
         _loc1_.matrix = [0.5,0,0.5,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
         this.selectedFilter = _loc1_;
         BindingManager.executeBindings(this,"selectedFilter",this.selectedFilter);
         return _loc1_;
      }
      
      private function _ImageItemRenderer_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.gap = 0;
         _loc1_.mxmlContent = [this._ImageItemRenderer_BitmapImage1_i(),this._ImageItemRenderer_Label1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _ImageItemRenderer_BitmapImage1_i() : BitmapImage
      {
         var _loc1_:BitmapImage = new BitmapImage();
         _loc1_.scaleX = 0.5;
         _loc1_.scaleY = 0.5;
         _loc1_.initialized(this,"image");
         this.image = _loc1_;
         BindingManager.executeBindings(this,"image",this.image);
         return _loc1_;
      }
      
      private function _ImageItemRenderer_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.maxDisplayedLines = 1;
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("color",16777215);
         _loc1_.setStyle("backgroundAlpha",1);
         _loc1_.setStyle("backgroundColor",0);
         _loc1_.setStyle("textAlign","center");
         _loc1_.setStyle("paddingLeft",5);
         _loc1_.setStyle("paddingRight",5);
         _loc1_.setStyle("paddingTop",5);
         _loc1_.setStyle("paddingBottom",5);
         _loc1_.id = "nameTxt";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.nameTxt = _loc1_;
         BindingManager.executeBindings(this,"nameTxt",this.nameTxt);
         return _loc1_;
      }
      
      private function _ImageItemRenderer_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():*
         {
            return [selectedFilter];
         },null,"_ImageItemRenderer_SetProperty1.value");
         result[1] = new Binding(this,function():*
         {
            return [selectedFilter];
         },null,"_ImageItemRenderer_SetProperty2.value");
         result[2] = new Binding(this,function():*
         {
            return [selectedFilter];
         },null,"_ImageItemRenderer_SetProperty3.value");
         result[3] = new Binding(this,function():*
         {
            return [selectedFilter];
         },null,"_ImageItemRenderer_SetProperty4.value");
         result[4] = new Binding(this,function():Object
         {
            return getStyle("rollOverColor");
         },null,"_ImageItemRenderer_SetStyle1.value");
         result[5] = new Binding(this,function():Object
         {
            return getStyle("rollOverColor");
         },null,"_ImageItemRenderer_SetStyle2.value");
         result[6] = new Binding(this,function():Object
         {
            return getStyle("selectionColor");
         },null,"_ImageItemRenderer_SetStyle3.value");
         result[7] = new Binding(this,function():Object
         {
            return getStyle("selectionColor");
         },null,"_ImageItemRenderer_SetStyle4.value");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get _ImageItemRenderer_SetProperty1() : SetProperty
      {
         return this._1566445913_ImageItemRenderer_SetProperty1;
      }
      
      public function set _ImageItemRenderer_SetProperty1(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1566445913_ImageItemRenderer_SetProperty1;
         if(_loc2_ !== param1)
         {
            this._1566445913_ImageItemRenderer_SetProperty1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ImageItemRenderer_SetProperty1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ImageItemRenderer_SetProperty2() : SetProperty
      {
         return this._1566445912_ImageItemRenderer_SetProperty2;
      }
      
      public function set _ImageItemRenderer_SetProperty2(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1566445912_ImageItemRenderer_SetProperty2;
         if(_loc2_ !== param1)
         {
            this._1566445912_ImageItemRenderer_SetProperty2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ImageItemRenderer_SetProperty2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ImageItemRenderer_SetProperty3() : SetProperty
      {
         return this._1566445911_ImageItemRenderer_SetProperty3;
      }
      
      public function set _ImageItemRenderer_SetProperty3(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1566445911_ImageItemRenderer_SetProperty3;
         if(_loc2_ !== param1)
         {
            this._1566445911_ImageItemRenderer_SetProperty3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ImageItemRenderer_SetProperty3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ImageItemRenderer_SetProperty4() : SetProperty
      {
         return this._1566445910_ImageItemRenderer_SetProperty4;
      }
      
      public function set _ImageItemRenderer_SetProperty4(param1:SetProperty) : void
      {
         var _loc2_:Object = this._1566445910_ImageItemRenderer_SetProperty4;
         if(_loc2_ !== param1)
         {
            this._1566445910_ImageItemRenderer_SetProperty4 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ImageItemRenderer_SetProperty4",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ImageItemRenderer_SetStyle1() : SetStyle
      {
         return this._21946069_ImageItemRenderer_SetStyle1;
      }
      
      public function set _ImageItemRenderer_SetStyle1(param1:SetStyle) : void
      {
         var _loc2_:Object = this._21946069_ImageItemRenderer_SetStyle1;
         if(_loc2_ !== param1)
         {
            this._21946069_ImageItemRenderer_SetStyle1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ImageItemRenderer_SetStyle1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ImageItemRenderer_SetStyle2() : SetStyle
      {
         return this._21946070_ImageItemRenderer_SetStyle2;
      }
      
      public function set _ImageItemRenderer_SetStyle2(param1:SetStyle) : void
      {
         var _loc2_:Object = this._21946070_ImageItemRenderer_SetStyle2;
         if(_loc2_ !== param1)
         {
            this._21946070_ImageItemRenderer_SetStyle2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ImageItemRenderer_SetStyle2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ImageItemRenderer_SetStyle3() : SetStyle
      {
         return this._21946071_ImageItemRenderer_SetStyle3;
      }
      
      public function set _ImageItemRenderer_SetStyle3(param1:SetStyle) : void
      {
         var _loc2_:Object = this._21946071_ImageItemRenderer_SetStyle3;
         if(_loc2_ !== param1)
         {
            this._21946071_ImageItemRenderer_SetStyle3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ImageItemRenderer_SetStyle3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _ImageItemRenderer_SetStyle4() : SetStyle
      {
         return this._21946072_ImageItemRenderer_SetStyle4;
      }
      
      public function set _ImageItemRenderer_SetStyle4(param1:SetStyle) : void
      {
         var _loc2_:Object = this._21946072_ImageItemRenderer_SetStyle4;
         if(_loc2_ !== param1)
         {
            this._21946072_ImageItemRenderer_SetStyle4 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_ImageItemRenderer_SetStyle4",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get image() : BitmapImage
      {
         return this._100313435image;
      }
      
      public function set image(param1:BitmapImage) : void
      {
         var _loc2_:Object = this._100313435image;
         if(_loc2_ !== param1)
         {
            this._100313435image = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"image",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get nameTxt() : Label
      {
         return this._1721941989nameTxt;
      }
      
      public function set nameTxt(param1:Label) : void
      {
         var _loc2_:Object = this._1721941989nameTxt;
         if(_loc2_ !== param1)
         {
            this._1721941989nameTxt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"nameTxt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get rolloverFilter() : ColorMatrixFilter
      {
         return this._1513016745rolloverFilter;
      }
      
      public function set rolloverFilter(param1:ColorMatrixFilter) : void
      {
         var _loc2_:Object = this._1513016745rolloverFilter;
         if(_loc2_ !== param1)
         {
            this._1513016745rolloverFilter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"rolloverFilter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get selectedFilter() : ColorMatrixFilter
      {
         return this._1478232563selectedFilter;
      }
      
      public function set selectedFilter(param1:ColorMatrixFilter) : void
      {
         var _loc2_:Object = this._1478232563selectedFilter;
         if(_loc2_ !== param1)
         {
            this._1478232563selectedFilter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"selectedFilter",_loc2_,param1));
            }
         }
      }
   }
}
