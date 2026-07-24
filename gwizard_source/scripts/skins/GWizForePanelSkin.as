package skins
{
   import comps.GWizForePanel;
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
   import mx.states.SetProperty;
   import mx.states.State;
   import spark.components.Group;
   import spark.components.Label;
   import spark.components.supportClasses.Skin;
   import spark.layouts.HorizontalLayout;
   import spark.primitives.Rect;
   
   use namespace mx_internal;
   
   public class GWizForePanelSkin extends Skin implements IBindingClient, IStateClient2
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      public var _GWizForePanelSkin_BitmapFill1:BitmapFill;
      
      public var _GWizForePanelSkin_GradientEntry1:GradientEntry;
      
      public var _GWizForePanelSkin_GradientEntry2:GradientEntry;
      
      public var _GWizForePanelSkin_HorizontalLayout1:HorizontalLayout;
      
      public var _GWizForePanelSkin_Label1:Label;
      
      public var _GWizForePanelSkin_Rect1:Rect;
      
      public var _GWizForePanelSkin_Rect2:Rect;
      
      private var _809612678contentGroup:Group;
      
      private var _1671708693labelGroup:Group;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      private var _213507019hostComponent:GWizForePanel;
      
      public function GWizForePanelSkin()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizForePanelSkin_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_skins_GWizForePanelSkinWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizForePanelSkin[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.mxmlContent = [this._GWizForePanelSkin_Rect1_i(),this._GWizForePanelSkin_Rect2_i(),this._GWizForePanelSkin_Group1_i(),this._GWizForePanelSkin_Group2_i()];
         this.currentState = "normal";
         states = [new State({
            "name":"normal",
            "overrides":[]
         }),new State({
            "name":"disabled",
            "overrides":[new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
            })]
         }),new State({
            "name":"disabledWithControlBar",
            "overrides":[]
         }),new State({
            "name":"normalWithControlBar",
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
         GWizForePanelSkin._watcherSetupUtil = param1;
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
      
      private function _GWizForePanelSkin_Rect1_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.top = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 0;
         _loc1_.fill = this._GWizForePanelSkin_BitmapFill1_i();
         _loc1_.initialized(this,"_GWizForePanelSkin_Rect1");
         this._GWizForePanelSkin_Rect1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizForePanelSkin_Rect1",this._GWizForePanelSkin_Rect1);
         return _loc1_;
      }
      
      private function _GWizForePanelSkin_BitmapFill1_i() : BitmapFill
      {
         var _loc1_:BitmapFill = new BitmapFill();
         _loc1_.fillMode = "repeat";
         this._GWizForePanelSkin_BitmapFill1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizForePanelSkin_BitmapFill1",this._GWizForePanelSkin_BitmapFill1);
         return _loc1_;
      }
      
      private function _GWizForePanelSkin_Rect2_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.top = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 0;
         _loc1_.fill = this._GWizForePanelSkin_LinearGradient1_c();
         _loc1_.initialized(this,"_GWizForePanelSkin_Rect2");
         this._GWizForePanelSkin_Rect2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizForePanelSkin_Rect2",this._GWizForePanelSkin_Rect2);
         return _loc1_;
      }
      
      private function _GWizForePanelSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.entries = [this._GWizForePanelSkin_GradientEntry1_i()];
         return _loc1_;
      }
      
      private function _GWizForePanelSkin_GradientEntry1_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         this._GWizForePanelSkin_GradientEntry1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizForePanelSkin_GradientEntry1",this._GWizForePanelSkin_GradientEntry1);
         return _loc1_;
      }
      
      private function _GWizForePanelSkin_Group1_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.left = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.mxmlContent = [this._GWizForePanelSkin_Rect3_c(),this._GWizForePanelSkin_Label1_i()];
         _loc1_.id = "labelGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.labelGroup = _loc1_;
         BindingManager.executeBindings(this,"labelGroup",this.labelGroup);
         return _loc1_;
      }
      
      private function _GWizForePanelSkin_Rect3_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.x = 0;
         _loc1_.y = 0;
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.fill = this._GWizForePanelSkin_LinearGradient2_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizForePanelSkin_LinearGradient2_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.entries = [this._GWizForePanelSkin_GradientEntry2_i()];
         return _loc1_;
      }
      
      private function _GWizForePanelSkin_GradientEntry2_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.alpha = 1;
         this._GWizForePanelSkin_GradientEntry2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizForePanelSkin_GradientEntry2",this._GWizForePanelSkin_GradientEntry2);
         return _loc1_;
      }
      
      private function _GWizForePanelSkin_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.left = 10;
         _loc1_.top = 10;
         _loc1_.right = 10;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizForePanelSkin_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizForePanelSkin_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizForePanelSkin_Label1",this._GWizForePanelSkin_Label1);
         return _loc1_;
      }
      
      private function _GWizForePanelSkin_Group2_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.layout = this._GWizForePanelSkin_HorizontalLayout1_i();
         _loc1_.id = "contentGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.contentGroup = _loc1_;
         BindingManager.executeBindings(this,"contentGroup",this.contentGroup);
         return _loc1_;
      }
      
      private function _GWizForePanelSkin_HorizontalLayout1_i() : HorizontalLayout
      {
         var _loc1_:HorizontalLayout = new HorizontalLayout();
         this._GWizForePanelSkin_HorizontalLayout1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizForePanelSkin_HorizontalLayout1",this._GWizForePanelSkin_HorizontalLayout1);
         return _loc1_;
      }
      
      private function _GWizForePanelSkin_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Object
         {
            return hostComponent.title == "" || hostComponent.hideLabel ? 0 : hostComponent.labelWidth + 1;
         },null,"_GWizForePanelSkin_Rect1.left");
         result[1] = new Binding(this,function():Object
         {
            return hostComponent.contentBackgroundTexture;
         },null,"_GWizForePanelSkin_BitmapFill1.source");
         result[2] = new Binding(this,function():Object
         {
            return hostComponent.title == "" || hostComponent.hideLabel ? 0 : hostComponent.labelWidth + 1;
         },null,"_GWizForePanelSkin_Rect2.left");
         result[3] = new Binding(this,function():uint
         {
            return hostComponent.contentBackgroundColor;
         },null,"_GWizForePanelSkin_GradientEntry1.color");
         result[4] = new Binding(this,function():Number
         {
            return hostComponent.contentFillAlpha;
         },null,"_GWizForePanelSkin_GradientEntry1.alpha");
         result[5] = new Binding(this,function():Boolean
         {
            return hostComponent.title == "" || hostComponent.hideLabel ? false : true;
         },null,"labelGroup.visible");
         result[6] = new Binding(this,function():Number
         {
            return hostComponent.labelWidth;
         },null,"labelGroup.width");
         result[7] = new Binding(this,function():uint
         {
            return hostComponent.labelBackgroundColor;
         },null,"_GWizForePanelSkin_GradientEntry2.color");
         result[8] = new Binding(this,function():String
         {
            var _loc1_:* = hostComponent.title;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizForePanelSkin_Label1.text");
         result[9] = new Binding(this,function():uint
         {
            return hostComponent.labelColor;
         },function(param1:uint):void
         {
            _GWizForePanelSkin_Label1.setStyle("color",param1);
         },"_GWizForePanelSkin_Label1.color");
         result[10] = new Binding(this,function():Object
         {
            return hostComponent.title == "" || hostComponent.hideLabel ? hostComponent.gapSize : hostComponent.labelWidth + hostComponent.gapSize;
         },null,"contentGroup.left");
         result[11] = new Binding(this,function():Object
         {
            return hostComponent.gapSize;
         },null,"contentGroup.right");
         result[12] = new Binding(this,function():Object
         {
            return hostComponent.gapSize;
         },null,"contentGroup.top");
         result[13] = new Binding(this,function():Object
         {
            return hostComponent.gapSize;
         },null,"contentGroup.bottom");
         result[14] = new Binding(this,function():int
         {
            return hostComponent.gapSize;
         },null,"_GWizForePanelSkin_HorizontalLayout1.gap");
         return result;
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
      public function get labelGroup() : Group
      {
         return this._1671708693labelGroup;
      }
      
      public function set labelGroup(param1:Group) : void
      {
         var _loc2_:Object = this._1671708693labelGroup;
         if(_loc2_ !== param1)
         {
            this._1671708693labelGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labelGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hostComponent() : GWizForePanel
      {
         return this._213507019hostComponent;
      }
      
      public function set hostComponent(param1:GWizForePanel) : void
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
