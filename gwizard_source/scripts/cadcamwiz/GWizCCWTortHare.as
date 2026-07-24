package cadcamwiz
{
   import configinfo.GWizSettings;
   import feedsspeeds.GWizTortHare;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.SolidColor;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.HSlider;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.VGroup;
   import spark.primitives.Rect;
   
   use namespace mx_internal;
   
   public class GWizCCWTortHare extends Group implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1923421566GasPedalSlider:HSlider;
      
      public var _GWizCCWTortHare_Image1:Image;
      
      public var _GWizCCWTortHare_Image2:Image;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var ignoreForePanelThemes:Boolean = true;
      
      public var syncPedalFcn:Function;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCWTortHare()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCWTortHare_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCWTortHareWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCWTortHare[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.mxmlContent = [this._GWizCCWTortHare_Rect1_c(),this._GWizCCWTortHare_HGroup1_c()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCWTortHare._watcherSetupUtil = param1;
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
      
      private function _GWizCCWTortHare_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.radiusX = 3;
         _loc1_.fill = this._GWizCCWTortHare_SolidColor1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizCCWTortHare_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         return _loc1_;
      }
      
      private function _GWizCCWTortHare_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.styleName = "fontSizeDelta-2";
         _loc1_.paddingBottom = 6;
         _loc1_.paddingTop = 6;
         _loc1_.paddingLeft = 6;
         _loc1_.paddingRight = 6;
         _loc1_.mxmlContent = [this._GWizCCWTortHare_VGroup1_c(),this._GWizCCWTortHare_HSlider1_i(),this._GWizCCWTortHare_VGroup2_c()];
         _loc1_.setStyle("fontWeight","normal");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWTortHare_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizCCWTortHare_Image1_i(),this._GWizCCWTortHare_Label1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWTortHare_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.toolTip = "Emphasize tool life and surface finish";
         _loc1_.scaleX = 0.5;
         _loc1_.scaleY = 0.5;
         _loc1_.addEventListener("click",this.___GWizCCWTortHare_Image1_click);
         _loc1_.id = "_GWizCCWTortHare_Image1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCCWTortHare_Image1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCWTortHare_Image1",this._GWizCCWTortHare_Image1);
         return _loc1_;
      }
      
      public function ___GWizCCWTortHare_Image1_click(param1:MouseEvent) : void
      {
         this.GasPedalSlider.value = 1;
      }
      
      private function _GWizCCWTortHare_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Conservative";
         _loc1_.toolTip = "Emphasize tool life and surface finish";
         _loc1_.setStyle("color",16777215);
         _loc1_.addEventListener("click",this.___GWizCCWTortHare_Label1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCCWTortHare_Label1_click(param1:MouseEvent) : void
      {
         this.GasPedalSlider.value = 1;
      }
      
      private function _GWizCCWTortHare_HSlider1_i() : HSlider
      {
         var _loc1_:HSlider = new HSlider();
         _loc1_.snapInterval = 1;
         _loc1_.minimum = 1;
         _loc1_.setStyle("liveDragging",false);
         _loc1_.addEventListener("valueCommit",this.__GasPedalSlider_valueCommit);
         _loc1_.addEventListener("change",this.__GasPedalSlider_change);
         _loc1_.id = "GasPedalSlider";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.GasPedalSlider = _loc1_;
         BindingManager.executeBindings(this,"GasPedalSlider",this.GasPedalSlider);
         return _loc1_;
      }
      
      public function __GasPedalSlider_valueCommit(param1:FlexEvent) : void
      {
         this.syncPedalFcn();
      }
      
      public function __GasPedalSlider_change(param1:Event) : void
      {
         this.syncPedalFcn();
      }
      
      private function _GWizCCWTortHare_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizCCWTortHare_Image2_i(),this._GWizCCWTortHare_Label2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWTortHare_Image2_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.toolTip = "Maximize MRR";
         _loc1_.scaleX = 0.5;
         _loc1_.scaleY = 0.5;
         _loc1_.addEventListener("click",this.___GWizCCWTortHare_Image2_click);
         _loc1_.id = "_GWizCCWTortHare_Image2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCCWTortHare_Image2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCCWTortHare_Image2",this._GWizCCWTortHare_Image2);
         return _loc1_;
      }
      
      public function ___GWizCCWTortHare_Image2_click(param1:MouseEvent) : void
      {
         this.GasPedalSlider.value = GWizTortHare.GAS_PEDAL_MAX;
      }
      
      private function _GWizCCWTortHare_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Aggressive";
         _loc1_.toolTip = "Maximize MRR";
         _loc1_.setStyle("color",16777215);
         _loc1_.addEventListener("click",this.___GWizCCWTortHare_Label2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCCWTortHare_Label2_click(param1:MouseEvent) : void
      {
         this.GasPedalSlider.value = GWizTortHare.GAS_PEDAL_MAX;
      }
      
      private function _GWizCCWTortHare_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Object
         {
            return GWizSettings.TortoiseImg;
         },null,"_GWizCCWTortHare_Image1.source");
         result[1] = new Binding(this,function():Number
         {
            return GWizTortHare.GAS_PEDAL_MAX;
         },null,"GasPedalSlider.maximum");
         result[2] = new Binding(this,function():Number
         {
            return GWizTortHare.GAS_PEDAL_MAX;
         },null,"GasPedalSlider.value");
         result[3] = new Binding(this,function():Object
         {
            return GWizSettings.HareImg;
         },null,"_GWizCCWTortHare_Image2.source");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get GasPedalSlider() : HSlider
      {
         return this._1923421566GasPedalSlider;
      }
      
      public function set GasPedalSlider(param1:HSlider) : void
      {
         var _loc2_:Object = this._1923421566GasPedalSlider;
         if(_loc2_ !== param1)
         {
            this._1923421566GasPedalSlider = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GasPedalSlider",_loc2_,param1));
            }
         }
      }
   }
}
