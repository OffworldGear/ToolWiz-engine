package mx.skins.spark
{
   import flash.accessibility.*;
   import flash.debugger.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.geom.*;
   import flash.media.*;
   import flash.net.*;
   import flash.printing.*;
   import flash.profiler.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   import mx.binding.*;
   import mx.core.EdgeMetrics;
   import mx.core.IFlexModuleFactory;
   import mx.core.IRectangularBorder;
   import mx.core.IUIComponent;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.filters.*;
   import mx.graphics.GradientEntry;
   import mx.graphics.LinearGradient;
   import mx.graphics.LinearGradientStroke;
   import mx.graphics.SolidColor;
   import mx.graphics.SolidColorStroke;
   import mx.styles.*;
   import spark.components.Group;
   import spark.primitives.Rect;
   import spark.primitives.RectangularDropShadow;
   
   use namespace mx_internal;
   
   public class PanelBorderSkin extends SparkSkinForHalo implements IBindingClient, IRectangularBorder
   {
      
      private static const exclusions:Array = ["background"];
      
      private static const borderItem:Array = ["borderStroke"];
      
      private static var panels:Object = {};
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1332194002background:Rect;
      
      private var _1427077073backgroundFill:SolidColor;
      
      private var _1383304148border:Rect;
      
      private var _1395787140borderStroke:SolidColorStroke;
      
      private var _3046628cbbg:Rect;
      
      private var _94447570cbdiv:Rect;
      
      private var _389362939contentMask:Group;
      
      private var _1596289399contentMaskRect:Rect;
      
      private var _567321830contents:Group;
      
      private var _906978543dropShadow:RectangularDropShadow;
      
      private var _3553075tbbg:Rect;
      
      private var _110147427tbdiv:Rect;
      
      private var _3553263tbhi:Rect;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _metrics:EdgeMetrics;
      
      private var _backgroundImageBounds:Rectangle;
      
      private var cornerRadius:Number;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function PanelBorderSkin()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._metrics = new EdgeMetrics(1,32,1,1);
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._PanelBorderSkin_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_mx_skins_spark_PanelBorderSkinWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return PanelBorderSkin[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.mxmlContent = [this._PanelBorderSkin_RectangularDropShadow1_i(),this._PanelBorderSkin_Group1_i(),this._PanelBorderSkin_Rect2_i(),this._PanelBorderSkin_Group2_i()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      private static function isPanel(param1:Object) : Boolean
      {
         var s:String = null;
         var x:XML = null;
         var parent:Object = param1;
         s = getQualifiedClassName(parent);
         if(panels[s] == 1)
         {
            return true;
         }
         if(panels[s] == 0)
         {
            return false;
         }
         if(s == "mx.containers::Panel")
         {
            panels[s] == 1;
            return true;
         }
         x = describeType(parent);
         var xmllist:XMLList = x.extendsClass.(@type == "mx.containers::Panel");
         if(xmllist.length() == 0)
         {
            panels[s] = 0;
            return false;
         }
         panels[s] = 1;
         return true;
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         PanelBorderSkin._watcherSetupUtil = param1;
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
         useChromeColor = true;
         super.initializationComplete();
      }
      
      override public function get colorizeExclusions() : Array
      {
         return exclusions;
      }
      
      override protected function get borderItems() : Array
      {
         return borderItem;
      }
      
      override protected function get defaultBorderItemColor() : uint
      {
         return getStyle("borderColor");
      }
      
      override protected function get defaultBorderAlpha() : Number
      {
         return getStyle("borderAlpha");
      }
      
      public function get borderMetrics() : EdgeMetrics
      {
         var _loc3_:Number = NaN;
         var _loc1_:Boolean = isPanel(parent);
         var _loc2_:IUIComponent = !!_loc1_ ? Object(parent).mx_internal::_controlBar : null;
         if(_loc1_)
         {
            _loc3_ = Object(parent).getStyle("headerHeight") + 2;
         }
         if(isNaN(_loc3_))
         {
            _loc3_ = !!_loc1_ ? Number(Object(parent).mx_internal::getHeaderHeightProxy(true) + 1) : Number(32);
         }
         this._metrics.top = _loc3_;
         if(_loc2_ && _loc2_.includeInLayout)
         {
            this._metrics.bottom = _loc2_.getExplicitOrMeasuredHeight() + 1;
         }
         else
         {
            this._metrics.bottom = 1;
         }
         return this._metrics;
      }
      
      public function get backgroundImageBounds() : Rectangle
      {
         return this._backgroundImageBounds;
      }
      
      public function set backgroundImageBounds(param1:Rectangle) : void
      {
         if(this._backgroundImageBounds && param1 && this._backgroundImageBounds.equals(param1))
         {
            return;
         }
         this._backgroundImageBounds = param1;
         invalidateDisplayList();
      }
      
      public function get hasBackgroundImage() : Boolean
      {
         return false;
      }
      
      public function layoutBackgroundImage() : void
      {
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc4_:Number = NaN;
         var _loc3_:Boolean = isPanel(parent);
         if(_loc3_)
         {
            _loc4_ = Object(parent).getStyle("headerHeight");
         }
         if(isNaN(_loc4_))
         {
            _loc4_ = !!_loc3_ ? Number(Object(parent).mx_internal::getHeaderHeightProxy(true) - 1) : Number(30);
         }
         this.tbbg.height = _loc4_;
         this.tbhi.height = _loc4_;
         this.tbdiv.top = _loc4_;
         var _loc5_:EdgeMetrics;
         if((_loc5_ = this.borderMetrics).bottom > 1)
         {
            this.cbbg.height = _loc5_.bottom - 1;
            this.cbdiv.bottom = this.cbbg.height;
            this.cbbg.visible = this.cbdiv.visible = true;
         }
         else
         {
            this.cbbg.visible = this.cbdiv.visible = false;
         }
         if(getStyle("borderVisible") == false)
         {
            this.border.visible = false;
            this.contents.left = this.contents.top = this.contents.right = this.contents.bottom = 0;
         }
         else
         {
            this.border.visible = true;
            this.contents.left = this.contents.top = this.contents.right = this.contents.bottom = 1;
         }
         this.dropShadow.visible = getStyle("dropShadowVisible") && width > 0 && height > 0;
         var _loc6_:Number = getStyle("cornerRadius");
         if(this.cornerRadius != _loc6_)
         {
            this.cornerRadius = _loc6_;
            this.contentMaskRect.topLeftRadiusX = this.cornerRadius;
            this.contentMaskRect.topRightRadiusX = this.cornerRadius;
            this.border.topLeftRadiusX = this.cornerRadius;
            this.border.topRightRadiusX = this.cornerRadius;
            this.dropShadow.trRadius = this.cornerRadius;
            this.dropShadow.tlRadius = this.cornerRadius;
            if(this.cbbg.visible)
            {
               this.contentMaskRect.bottomLeftRadiusX = this.cornerRadius;
               this.contentMaskRect.bottomRightRadiusX = this.cornerRadius;
               this.border.bottomLeftRadiusX = this.cornerRadius;
               this.border.bottomRightRadiusX = this.cornerRadius;
               this.dropShadow.blRadius = this.cornerRadius;
               this.dropShadow.brRadius = this.cornerRadius;
            }
         }
         this.backgroundFill.color = getStyle("backgroundColor");
         this.backgroundFill.alpha = getStyle("backgroundAlpha");
         super.updateDisplayList(param1,param2);
      }
      
      private function _PanelBorderSkin_RectangularDropShadow1_i() : RectangularDropShadow
      {
         var _loc1_:RectangularDropShadow = new RectangularDropShadow();
         _loc1_.blurX = 20;
         _loc1_.blurY = 20;
         _loc1_.alpha = 0.32;
         _loc1_.distance = 11;
         _loc1_.angle = 90;
         _loc1_.color = 0;
         _loc1_.left = 0;
         _loc1_.top = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 0;
         _loc1_.tlRadius = 0;
         _loc1_.trRadius = 0;
         _loc1_.blRadius = 0;
         _loc1_.brRadius = 0;
         _loc1_.id = "dropShadow";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.dropShadow = _loc1_;
         BindingManager.executeBindings(this,"dropShadow",this.dropShadow);
         return _loc1_;
      }
      
      private function _PanelBorderSkin_Group1_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.left = 1;
         _loc1_.top = 1;
         _loc1_.right = 1;
         _loc1_.bottom = 1;
         _loc1_.mxmlContent = [this._PanelBorderSkin_Rect1_i()];
         _loc1_.id = "contentMask";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.contentMask = _loc1_;
         BindingManager.executeBindings(this,"contentMask",this.contentMask);
         return _loc1_;
      }
      
      private function _PanelBorderSkin_Rect1_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.top = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 0;
         _loc1_.topLeftRadiusX = 0;
         _loc1_.topRightRadiusX = 0;
         _loc1_.fill = this._PanelBorderSkin_SolidColor1_c();
         _loc1_.initialized(this,"contentMaskRect");
         this.contentMaskRect = _loc1_;
         BindingManager.executeBindings(this,"contentMaskRect",this.contentMaskRect);
         return _loc1_;
      }
      
      private function _PanelBorderSkin_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.alpha = 0;
         return _loc1_;
      }
      
      private function _PanelBorderSkin_Rect2_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.topLeftRadiusX = 0;
         _loc1_.topRightRadiusX = 0;
         _loc1_.stroke = this._PanelBorderSkin_SolidColorStroke1_i();
         _loc1_.initialized(this,"border");
         this.border = _loc1_;
         BindingManager.executeBindings(this,"border",this.border);
         return _loc1_;
      }
      
      private function _PanelBorderSkin_SolidColorStroke1_i() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.weight = 1;
         this.borderStroke = _loc1_;
         BindingManager.executeBindings(this,"borderStroke",this.borderStroke);
         return _loc1_;
      }
      
      private function _PanelBorderSkin_Group2_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.left = 1;
         _loc1_.right = 1;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.mxmlContent = [this._PanelBorderSkin_Rect3_i(),this._PanelBorderSkin_Rect4_i(),this._PanelBorderSkin_Rect5_i(),this._PanelBorderSkin_Rect6_i(),this._PanelBorderSkin_Rect7_i(),this._PanelBorderSkin_Rect8_i()];
         _loc1_.id = "contents";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.contents = _loc1_;
         BindingManager.executeBindings(this,"contents",this.contents);
         return _loc1_;
      }
      
      private function _PanelBorderSkin_Rect3_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.top = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 0;
         _loc1_.fill = this._PanelBorderSkin_SolidColor2_i();
         _loc1_.initialized(this,"background");
         this.background = _loc1_;
         BindingManager.executeBindings(this,"background",this.background);
         return _loc1_;
      }
      
      private function _PanelBorderSkin_SolidColor2_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         this.backgroundFill = _loc1_;
         BindingManager.executeBindings(this,"backgroundFill",this.backgroundFill);
         return _loc1_;
      }
      
      private function _PanelBorderSkin_Rect4_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.minHeight = 30;
         _loc1_.fill = this._PanelBorderSkin_LinearGradient1_c();
         _loc1_.initialized(this,"tbbg");
         this.tbbg = _loc1_;
         BindingManager.executeBindings(this,"tbbg",this.tbbg);
         return _loc1_;
      }
      
      private function _PanelBorderSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._PanelBorderSkin_GradientEntry1_c(),this._PanelBorderSkin_GradientEntry2_c()];
         return _loc1_;
      }
      
      private function _PanelBorderSkin_GradientEntry1_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14869218;
         return _loc1_;
      }
      
      private function _PanelBorderSkin_GradientEntry2_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14277081;
         return _loc1_;
      }
      
      private function _PanelBorderSkin_Rect5_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.minHeight = 30;
         _loc1_.stroke = this._PanelBorderSkin_LinearGradientStroke1_c();
         _loc1_.initialized(this,"tbhi");
         this.tbhi = _loc1_;
         BindingManager.executeBindings(this,"tbhi",this.tbhi);
         return _loc1_;
      }
      
      private function _PanelBorderSkin_LinearGradientStroke1_c() : LinearGradientStroke
      {
         var _loc1_:LinearGradientStroke = new LinearGradientStroke();
         _loc1_.rotation = 90;
         _loc1_.weight = 1;
         _loc1_.entries = [this._PanelBorderSkin_GradientEntry3_c(),this._PanelBorderSkin_GradientEntry4_c()];
         return _loc1_;
      }
      
      private function _PanelBorderSkin_GradientEntry3_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 15395562;
         return _loc1_;
      }
      
      private function _PanelBorderSkin_GradientEntry4_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14277081;
         return _loc1_;
      }
      
      private function _PanelBorderSkin_Rect6_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 30;
         _loc1_.height = 1;
         _loc1_.fill = this._PanelBorderSkin_SolidColor3_c();
         _loc1_.initialized(this,"tbdiv");
         this.tbdiv = _loc1_;
         BindingManager.executeBindings(this,"tbdiv",this.tbdiv);
         return _loc1_;
      }
      
      private function _PanelBorderSkin_SolidColor3_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 12632256;
         return _loc1_;
      }
      
      private function _PanelBorderSkin_Rect7_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 0;
         _loc1_.height = 20;
         _loc1_.fill = this._PanelBorderSkin_SolidColor4_c();
         _loc1_.initialized(this,"cbbg");
         this.cbbg = _loc1_;
         BindingManager.executeBindings(this,"cbbg",this.cbbg);
         return _loc1_;
      }
      
      private function _PanelBorderSkin_SolidColor4_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 15263976;
         return _loc1_;
      }
      
      private function _PanelBorderSkin_Rect8_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 20;
         _loc1_.height = 1;
         _loc1_.fill = this._PanelBorderSkin_SolidColor5_c();
         _loc1_.initialized(this,"cbdiv");
         this.cbdiv = _loc1_;
         BindingManager.executeBindings(this,"cbdiv",this.cbdiv);
         return _loc1_;
      }
      
      private function _PanelBorderSkin_SolidColor5_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 13487565;
         return _loc1_;
      }
      
      private function _PanelBorderSkin_bindingsSetup() : Array
      {
         var _loc1_:Array = [];
         _loc1_[0] = new Binding(this,null,null,"contents.mask","contentMask");
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get background() : Rect
      {
         return this._1332194002background;
      }
      
      public function set background(param1:Rect) : void
      {
         var _loc2_:Object = this._1332194002background;
         if(_loc2_ !== param1)
         {
            this._1332194002background = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"background",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get backgroundFill() : SolidColor
      {
         return this._1427077073backgroundFill;
      }
      
      public function set backgroundFill(param1:SolidColor) : void
      {
         var _loc2_:Object = this._1427077073backgroundFill;
         if(_loc2_ !== param1)
         {
            this._1427077073backgroundFill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"backgroundFill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get border() : Rect
      {
         return this._1383304148border;
      }
      
      public function set border(param1:Rect) : void
      {
         var _loc2_:Object = this._1383304148border;
         if(_loc2_ !== param1)
         {
            this._1383304148border = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"border",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get borderStroke() : SolidColorStroke
      {
         return this._1395787140borderStroke;
      }
      
      public function set borderStroke(param1:SolidColorStroke) : void
      {
         var _loc2_:Object = this._1395787140borderStroke;
         if(_loc2_ !== param1)
         {
            this._1395787140borderStroke = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"borderStroke",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cbbg() : Rect
      {
         return this._3046628cbbg;
      }
      
      public function set cbbg(param1:Rect) : void
      {
         var _loc2_:Object = this._3046628cbbg;
         if(_loc2_ !== param1)
         {
            this._3046628cbbg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cbbg",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cbdiv() : Rect
      {
         return this._94447570cbdiv;
      }
      
      public function set cbdiv(param1:Rect) : void
      {
         var _loc2_:Object = this._94447570cbdiv;
         if(_loc2_ !== param1)
         {
            this._94447570cbdiv = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cbdiv",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get contentMask() : Group
      {
         return this._389362939contentMask;
      }
      
      public function set contentMask(param1:Group) : void
      {
         var _loc2_:Object = this._389362939contentMask;
         if(_loc2_ !== param1)
         {
            this._389362939contentMask = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"contentMask",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get contentMaskRect() : Rect
      {
         return this._1596289399contentMaskRect;
      }
      
      public function set contentMaskRect(param1:Rect) : void
      {
         var _loc2_:Object = this._1596289399contentMaskRect;
         if(_loc2_ !== param1)
         {
            this._1596289399contentMaskRect = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"contentMaskRect",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get contents() : Group
      {
         return this._567321830contents;
      }
      
      public function set contents(param1:Group) : void
      {
         var _loc2_:Object = this._567321830contents;
         if(_loc2_ !== param1)
         {
            this._567321830contents = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"contents",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get dropShadow() : RectangularDropShadow
      {
         return this._906978543dropShadow;
      }
      
      public function set dropShadow(param1:RectangularDropShadow) : void
      {
         var _loc2_:Object = this._906978543dropShadow;
         if(_loc2_ !== param1)
         {
            this._906978543dropShadow = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"dropShadow",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tbbg() : Rect
      {
         return this._3553075tbbg;
      }
      
      public function set tbbg(param1:Rect) : void
      {
         var _loc2_:Object = this._3553075tbbg;
         if(_loc2_ !== param1)
         {
            this._3553075tbbg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tbbg",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tbdiv() : Rect
      {
         return this._110147427tbdiv;
      }
      
      public function set tbdiv(param1:Rect) : void
      {
         var _loc2_:Object = this._110147427tbdiv;
         if(_loc2_ !== param1)
         {
            this._110147427tbdiv = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tbdiv",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tbhi() : Rect
      {
         return this._3553263tbhi;
      }
      
      public function set tbhi(param1:Rect) : void
      {
         var _loc2_:Object = this._3553263tbhi;
         if(_loc2_ !== param1)
         {
            this._3553263tbhi = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tbhi",_loc2_,param1));
            }
         }
      }
   }
}
