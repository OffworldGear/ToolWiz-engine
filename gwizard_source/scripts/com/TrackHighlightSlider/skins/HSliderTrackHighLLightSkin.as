package com.TrackHighlightSlider.skins
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
   import mx.graphics.SolidColor;
   import mx.states.State;
   import spark.components.Button;
   import spark.primitives.Rect;
   import spark.skins.SparkSkin;
   
   use namespace mx_internal;
   
   public class HSliderTrackHighLLightSkin extends SparkSkin implements IBindingClient, IStateClient2
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      public var _HSliderTrackHighLLightSkin_SolidColor1:SolidColor;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _490636047highlightColor:uint;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      private var _213507019hostComponent:Button;
      
      public function HSliderTrackHighLLightSkin()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._HSliderTrackHighLLightSkin_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_com_TrackHighlightSlider_skins_HSliderTrackHighLLightSkinWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return HSliderTrackHighLLightSkin[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.mxmlContent = [this._HSliderTrackHighLLightSkin_Rect1_c(),this._HSliderTrackHighLLightSkin_Rect2_c()];
         this.currentState = "up";
         states = [new State({
            "name":"up",
            "overrides":[]
         }),new State({
            "name":"down",
            "overrides":[]
         }),new State({
            "name":"over",
            "overrides":[]
         }),new State({
            "name":"disabled",
            "overrides":[]
         })];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         HSliderTrackHighLLightSkin._watcherSetupUtil = param1;
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
      
      override protected function initializationComplete() : void
      {
         this.highlightColor = this.getStyle("themeColor");
         super.initializationComplete();
      }
      
      override public function styleChanged(param1:String) : void
      {
         var _loc2_:uint = 0;
         super.styleChanged(param1);
         if(param1 == "themeColor")
         {
            _loc2_ = this.getStyle("themeColor");
            this.highlightColor = _loc2_;
         }
      }
      
      private function _HSliderTrackHighLLightSkin_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 4;
         _loc1_.bottom = 4;
         _loc1_.bottomLeftRadiusX = 2;
         _loc1_.bottomLeftRadiusY = 2;
         _loc1_.topLeftRadiusX = 2;
         _loc1_.topLeftRadiusY = 2;
         _loc1_.bottomRightRadiusX = 0;
         _loc1_.bottomRightRadiusY = 0;
         _loc1_.topRightRadiusX = 0;
         _loc1_.topRightRadiusY = 0;
         _loc1_.fill = this._HSliderTrackHighLLightSkin_SolidColor1_i();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _HSliderTrackHighLLightSkin_SolidColor1_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.alpha = 0.5;
         this._HSliderTrackHighLLightSkin_SolidColor1 = _loc1_;
         BindingManager.executeBindings(this,"_HSliderTrackHighLLightSkin_SolidColor1",this._HSliderTrackHighLLightSkin_SolidColor1);
         return _loc1_;
      }
      
      private function _HSliderTrackHighLLightSkin_Rect2_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.fill = this._HSliderTrackHighLLightSkin_SolidColor2_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _HSliderTrackHighLLightSkin_SolidColor2_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.alpha = 0;
         return _loc1_;
      }
      
      private function _HSliderTrackHighLLightSkin_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return highlightColor;
         },null,"_HSliderTrackHighLLightSkin_SolidColor1.color");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      private function get highlightColor() : uint
      {
         return this._490636047highlightColor;
      }
      
      private function set highlightColor(param1:uint) : void
      {
         var _loc2_:Object = this._490636047highlightColor;
         if(_loc2_ !== param1)
         {
            this._490636047highlightColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"highlightColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hostComponent() : Button
      {
         return this._213507019hostComponent;
      }
      
      public function set hostComponent(param1:Button) : void
      {
         var _loc2_:Object = this._213507019hostComponent;
         if(_loc2_ !== param1)
         {
            this._213507019hostComponent = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hostComponent",_loc2_,param1));
            }
         }
      }
   }
}
