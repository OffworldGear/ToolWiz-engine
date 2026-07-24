package comps.skins
{
   import comps.GWizPanel;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.BitmapFill;
   import mx.graphics.GradientEntry;
   import mx.graphics.LinearGradient;
   import mx.graphics.SolidColor;
   import mx.graphics.SolidColorStroke;
   import mx.states.SetProperty;
   import mx.states.State;
   import spark.components.Group;
   import spark.components.Label;
   import spark.components.supportClasses.Skin;
   import spark.primitives.Rect;
   
   use namespace mx_internal;
   
   public class PanelSkin extends Skin implements IBindingClient, IStateClient2
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _230501954_PanelSkin_BitmapFill1:BitmapFill;
      
      public var _PanelSkin_GradientEntry1:GradientEntry;
      
      public var _PanelSkin_GradientEntry2:GradientEntry;
      
      public var _PanelSkin_Label1:Label;
      
      public var _PanelSkin_SolidColor1:SolidColor;
      
      private var _2109780156_PanelSkin_SolidColorStroke1:SolidColorStroke;
      
      private var _1427430450backgroundRect:Rect;
      
      private var _1903855629backgroundTexture:Rect;
      
      private var _809612678contentGroup:Group;
      
      private var _343462058titleBackgroundRect:Rect;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _embed_mxml__assets_MetalTexture_jpg_475070832:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      private var _213507019hostComponent:GWizPanel;
      
      public function PanelSkin()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._embed_mxml__assets_MetalTexture_jpg_475070832 = PanelSkin__embed_mxml__assets_MetalTexture_jpg_475070832;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._PanelSkin_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_skins_PanelSkinWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return PanelSkin[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.mxmlContent = [this._PanelSkin_Rect1_i(),this._PanelSkin_Label1_i(),this._PanelSkin_Rect2_i(),this._PanelSkin_Rect3_i(),this._PanelSkin_Group1_i()];
         this.currentState = "normal";
         states = [new State({
            "name":"normal",
            "overrides":[]
         }),new State({
            "name":"disabled",
            "overrides":[]
         }),new State({
            "name":"selected",
            "overrides":[new SetProperty().initializeFromObject({
               "target":"_PanelSkin_BitmapFill1",
               "name":"alpha",
               "value":0.5
            }),new SetProperty().initializeFromObject({
               "isBaseValueDataBound":true,
               "target":"_PanelSkin_SolidColorStroke1",
               "name":"color",
               "value":16711680
            })]
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
         PanelSkin._watcherSetupUtil = param1;
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
      
      private function _PanelSkin_Rect1_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.height = 25;
         _loc1_.fill = this._PanelSkin_LinearGradient1_c();
         _loc1_.initialized(this,"titleBackgroundRect");
         this.titleBackgroundRect = _loc1_;
         BindingManager.executeBindings(this,"titleBackgroundRect",this.titleBackgroundRect);
         return _loc1_;
      }
      
      private function _PanelSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._PanelSkin_GradientEntry1_i(),this._PanelSkin_GradientEntry2_i()];
         return _loc1_;
      }
      
      private function _PanelSkin_GradientEntry1_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         this._PanelSkin_GradientEntry1 = _loc1_;
         BindingManager.executeBindings(this,"_PanelSkin_GradientEntry1",this._PanelSkin_GradientEntry1);
         return _loc1_;
      }
      
      private function _PanelSkin_GradientEntry2_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         this._PanelSkin_GradientEntry2 = _loc1_;
         BindingManager.executeBindings(this,"_PanelSkin_GradientEntry2",this._PanelSkin_GradientEntry2);
         return _loc1_;
      }
      
      private function _PanelSkin_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 5;
         _loc1_.y = 7;
         _loc1_.alpha = 0.9;
         _loc1_.styleName = "fontSizeDelta4";
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "_PanelSkin_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._PanelSkin_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_PanelSkin_Label1",this._PanelSkin_Label1);
         return _loc1_;
      }
      
      private function _PanelSkin_Rect2_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 0;
         _loc1_.fill = this._PanelSkin_BitmapFill1_i();
         _loc1_.initialized(this,"backgroundTexture");
         this.backgroundTexture = _loc1_;
         BindingManager.executeBindings(this,"backgroundTexture",this.backgroundTexture);
         return _loc1_;
      }
      
      private function _PanelSkin_BitmapFill1_i() : BitmapFill
      {
         var _loc1_:BitmapFill = new BitmapFill();
         _loc1_.source = this._embed_mxml__assets_MetalTexture_jpg_475070832;
         _loc1_.fillMode = "repeat";
         _loc1_.alpha = 1;
         this._PanelSkin_BitmapFill1 = _loc1_;
         BindingManager.executeBindings(this,"_PanelSkin_BitmapFill1",this._PanelSkin_BitmapFill1);
         return _loc1_;
      }
      
      private function _PanelSkin_Rect3_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 0;
         _loc1_.stroke = this._PanelSkin_SolidColorStroke1_i();
         _loc1_.fill = this._PanelSkin_SolidColor1_i();
         _loc1_.initialized(this,"backgroundRect");
         this.backgroundRect = _loc1_;
         BindingManager.executeBindings(this,"backgroundRect",this.backgroundRect);
         return _loc1_;
      }
      
      private function _PanelSkin_SolidColorStroke1_i() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         this._PanelSkin_SolidColorStroke1 = _loc1_;
         BindingManager.executeBindings(this,"_PanelSkin_SolidColorStroke1",this._PanelSkin_SolidColorStroke1);
         return _loc1_;
      }
      
      private function _PanelSkin_SolidColor1_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         this._PanelSkin_SolidColor1 = _loc1_;
         BindingManager.executeBindings(this,"_PanelSkin_SolidColor1",this._PanelSkin_SolidColor1);
         return _loc1_;
      }
      
      private function _PanelSkin_Group1_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.bottom = 1;
         _loc1_.alpha = 1;
         _loc1_.id = "contentGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.contentGroup = _loc1_;
         BindingManager.executeBindings(this,"contentGroup",this.contentGroup);
         return _loc1_;
      }
      
      private function _PanelSkin_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Boolean
         {
            return hostComponent.title != "";
         },null,"titleBackgroundRect.visible");
         result[1] = new Binding(this,function():uint
         {
            return !!hostComponent.darkBack ? uint(16777215) : uint(0);
         },null,"_PanelSkin_GradientEntry1.color");
         result[2] = new Binding(this,function():Number
         {
            return !!hostComponent.darkBack ? Number(0.3) : Number(0.4);
         },null,"_PanelSkin_GradientEntry1.alpha");
         result[3] = new Binding(this,function():uint
         {
            return !!hostComponent.darkBack ? uint(15658734) : uint(1118481);
         },null,"_PanelSkin_GradientEntry2.color");
         result[4] = new Binding(this,function():Number
         {
            return !!hostComponent.darkBack ? Number(0.1) : Number(0.8);
         },null,"_PanelSkin_GradientEntry2.alpha");
         result[5] = new Binding(this,function():String
         {
            var _loc1_:* = hostComponent.title;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_PanelSkin_Label1.text");
         result[6] = new Binding(this,function():Object
         {
            return hostComponent.title == "" ? 0 : 25;
         },null,"backgroundTexture.top");
         result[7] = new Binding(this,function():Object
         {
            return hostComponent.title == "" ? 0 : 25;
         },null,"backgroundRect.top");
         result[8] = new Binding(this,function():uint
         {
            return hostComponent.borderColor;
         },null,"_PanelSkin_SolidColorStroke1.color");
         result[9] = new Binding(this,function():Number
         {
            return hostComponent.borderAlpha;
         },null,"_PanelSkin_SolidColorStroke1.alpha");
         result[10] = new Binding(this,function():uint
         {
            return hostComponent.backgroundColor;
         },null,"_PanelSkin_SolidColor1.color");
         result[11] = new Binding(this,function():Number
         {
            return hostComponent.backgroundAlpha;
         },null,"_PanelSkin_SolidColor1.alpha");
         result[12] = new Binding(this,function():Object
         {
            return hostComponent.title == "" ? 1 : 25;
         },null,"contentGroup.top");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get _PanelSkin_BitmapFill1() : BitmapFill
      {
         return this._230501954_PanelSkin_BitmapFill1;
      }
      
      public function set _PanelSkin_BitmapFill1(param1:BitmapFill) : void
      {
         var _loc2_:Object = this._230501954_PanelSkin_BitmapFill1;
         if(_loc2_ !== param1)
         {
            this._230501954_PanelSkin_BitmapFill1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_PanelSkin_BitmapFill1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _PanelSkin_SolidColorStroke1() : SolidColorStroke
      {
         return this._2109780156_PanelSkin_SolidColorStroke1;
      }
      
      public function set _PanelSkin_SolidColorStroke1(param1:SolidColorStroke) : void
      {
         var _loc2_:Object = this._2109780156_PanelSkin_SolidColorStroke1;
         if(_loc2_ !== param1)
         {
            this._2109780156_PanelSkin_SolidColorStroke1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_PanelSkin_SolidColorStroke1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get backgroundRect() : Rect
      {
         return this._1427430450backgroundRect;
      }
      
      public function set backgroundRect(param1:Rect) : void
      {
         var _loc2_:Object = this._1427430450backgroundRect;
         if(_loc2_ !== param1)
         {
            this._1427430450backgroundRect = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"backgroundRect",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get backgroundTexture() : Rect
      {
         return this._1903855629backgroundTexture;
      }
      
      public function set backgroundTexture(param1:Rect) : void
      {
         var _loc2_:Object = this._1903855629backgroundTexture;
         if(_loc2_ !== param1)
         {
            this._1903855629backgroundTexture = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"backgroundTexture",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get contentGroup() : Group
      {
         return this._809612678contentGroup;
      }
      
      public function set contentGroup(param1:Group) : void
      {
         var _loc2_:Object = this._809612678contentGroup;
         if(_loc2_ !== param1)
         {
            this._809612678contentGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"contentGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get titleBackgroundRect() : Rect
      {
         return this._343462058titleBackgroundRect;
      }
      
      public function set titleBackgroundRect(param1:Rect) : void
      {
         var _loc2_:Object = this._343462058titleBackgroundRect;
         if(_loc2_ !== param1)
         {
            this._343462058titleBackgroundRect = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"titleBackgroundRect",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hostComponent() : GWizPanel
      {
         return this._213507019hostComponent;
      }
      
      public function set hostComponent(param1:GWizPanel) : void
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
