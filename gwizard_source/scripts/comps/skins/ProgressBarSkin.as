package comps.skins
{
   import comps.ProgressBar;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.GradientEntry;
   import mx.graphics.LinearGradient;
   import mx.graphics.SolidColor;
   import spark.components.Label;
   import spark.components.supportClasses.Skin;
   import spark.filters.DropShadowFilter;
   import spark.primitives.Rect;
   import utils.ColorPalette;
   
   use namespace mx_internal;
   
   public class ProgressBarSkin extends Skin implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      public var _ProgressBarSkin_GradientEntry1:GradientEntry;
      
      public var _ProgressBarSkin_GradientEntry2:GradientEntry;
      
      public var _ProgressBarSkin_Label1:Label;
      
      public var _ProgressBarSkin_SolidColor1:SolidColor;
      
      private var _97299bar:Rect;
      
      private var _110621003track:Rect;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      private var _213507019hostComponent:ProgressBar;
      
      public function ProgressBarSkin()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._ProgressBarSkin_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_skins_ProgressBarSkinWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return ProgressBarSkin[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.width = 250;
         this.height = 16;
         this.mxmlContent = [this._ProgressBarSkin_Rect1_i(),this._ProgressBarSkin_Rect2_i(),this._ProgressBarSkin_Label1_i()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         ProgressBarSkin._watcherSetupUtil = param1;
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
      
      private function _ProgressBarSkin_Rect1_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.top = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 0;
         _loc1_.left = 0;
         _loc1_.radiusX = 0;
         _loc1_.radiusY = 0;
         _loc1_.filters = [this._ProgressBarSkin_DropShadowFilter1_c()];
         _loc1_.fill = this._ProgressBarSkin_SolidColor1_i();
         _loc1_.initialized(this,"track");
         this.track = _loc1_;
         BindingManager.executeBindings(this,"track",this.track);
         return _loc1_;
      }
      
      private function _ProgressBarSkin_DropShadowFilter1_c() : DropShadowFilter
      {
         var _loc1_:DropShadowFilter = new DropShadowFilter();
         _loc1_.angle = 135;
         _loc1_.inner = true;
         _loc1_.distance = 1;
         _loc1_.blurX = 1;
         _loc1_.blurY = 1;
         _loc1_.alpha = 0.7;
         return _loc1_;
      }
      
      private function _ProgressBarSkin_SolidColor1_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         this._ProgressBarSkin_SolidColor1 = _loc1_;
         BindingManager.executeBindings(this,"_ProgressBarSkin_SolidColor1",this._ProgressBarSkin_SolidColor1);
         return _loc1_;
      }
      
      private function _ProgressBarSkin_Rect2_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.radiusX = 0;
         _loc1_.radiusY = 0;
         _loc1_.fill = this._ProgressBarSkin_LinearGradient1_c();
         _loc1_.initialized(this,"bar");
         this.bar = _loc1_;
         BindingManager.executeBindings(this,"bar",this.bar);
         return _loc1_;
      }
      
      private function _ProgressBarSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._ProgressBarSkin_GradientEntry1_i(),this._ProgressBarSkin_GradientEntry2_i()];
         return _loc1_;
      }
      
      private function _ProgressBarSkin_GradientEntry1_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         this._ProgressBarSkin_GradientEntry1 = _loc1_;
         BindingManager.executeBindings(this,"_ProgressBarSkin_GradientEntry1",this._ProgressBarSkin_GradientEntry1);
         return _loc1_;
      }
      
      private function _ProgressBarSkin_GradientEntry2_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         this._ProgressBarSkin_GradientEntry2 = _loc1_;
         BindingManager.executeBindings(this,"_ProgressBarSkin_GradientEntry2",this._ProgressBarSkin_GradientEntry2);
         return _loc1_;
      }
      
      private function _ProgressBarSkin_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.styleName = "fontSizeDelta-2";
         _loc1_.blendMode = "invert";
         _loc1_.setStyle("paddingTop",4);
         _loc1_.setStyle("textAlign","center");
         _loc1_.setStyle("verticalAlign","middle");
         _loc1_.setStyle("color",0);
         _loc1_.id = "_ProgressBarSkin_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._ProgressBarSkin_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_ProgressBarSkin_Label1",this._ProgressBarSkin_Label1);
         return _loc1_;
      }
      
      private function _ProgressBarSkin_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.gray5;
         },null,"_ProgressBarSkin_SolidColor1.color");
         result[1] = new Binding(this,function():Number
         {
            return track.width * (ProgressBar(hostComponent).value / ProgressBar(hostComponent).maximum);
         },null,"bar.width");
         result[2] = new Binding(this,function():Number
         {
            return track.height;
         },null,"bar.height");
         result[3] = new Binding(this,function():uint
         {
            return hostComponent.progressColor;
         },null,"_ProgressBarSkin_GradientEntry1.color");
         result[4] = new Binding(this,function():uint
         {
            return hostComponent.progressColorHilight;
         },null,"_ProgressBarSkin_GradientEntry2.color");
         result[5] = new Binding(this,function():String
         {
            var _loc1_:* = hostComponent.label;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_ProgressBarSkin_Label1.text");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get bar() : Rect
      {
         return this._97299bar;
      }
      
      public function set bar(param1:Rect) : void
      {
         var _loc2_:Object = this._97299bar;
         if(_loc2_ !== param1)
         {
            this._97299bar = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"bar",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get track() : Rect
      {
         return this._110621003track;
      }
      
      public function set track(param1:Rect) : void
      {
         var _loc2_:Object = this._110621003track;
         if(_loc2_ !== param1)
         {
            this._110621003track = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"track",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hostComponent() : ProgressBar
      {
         return this._213507019hostComponent;
      }
      
      public function set hostComponent(param1:ProgressBar) : void
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
