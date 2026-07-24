package mx.charts
{
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.text.TextFormat;
   import flash.utils.getQualifiedClassName;
   import mx.charts.chartClasses.AxisBase;
   import mx.charts.chartClasses.AxisLabelSet;
   import mx.charts.chartClasses.ChartBase;
   import mx.charts.chartClasses.ChartLabel;
   import mx.charts.chartClasses.ChartState;
   import mx.charts.chartClasses.DualStyleObject;
   import mx.charts.chartClasses.IAxis;
   import mx.charts.chartClasses.IAxisRenderer;
   import mx.charts.chartClasses.InstanceCache;
   import mx.charts.styles.HaloDefaults;
   import mx.core.ContextualClassFactory;
   import mx.core.IDataRenderer;
   import mx.core.IFactory;
   import mx.core.IFlexDisplayObject;
   import mx.core.IFlexModuleFactory;
   import mx.core.IUIComponent;
   import mx.core.IUITextField;
   import mx.core.LayoutDirection;
   import mx.core.UIComponent;
   import mx.core.UITextField;
   import mx.core.UITextFormat;
   import mx.core.mx_internal;
   import mx.graphics.IStroke;
   import mx.graphics.SolidColorStroke;
   import mx.managers.ILayoutManagerClient;
   import mx.managers.ISystemManager;
   import mx.resources.IResourceManager;
   import mx.resources.ResourceManager;
   import mx.styles.CSSStyleDeclaration;
   import mx.styles.ISimpleStyleClient;
   
   use namespace mx_internal;
   
   public class AxisRenderer extends DualStyleObject implements IAxisRenderer
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static var textFieldFactory:ContextualClassFactory;
      
      private static var resourceManager:IResourceManager = ResourceManager.getInstance();
       
      
      private var _moduleFactoryInitialized:Boolean = false;
      
      private var _cacheDirty:Boolean = true;
      
      private var _labelFormatCache:TextFormat;
      
      private var _otherAxes:Array;
      
      private var _ticks:Array;
      
      private var _minorTicks:Array;
      
      private var _heightLimit:Number;
      
      private var _maxLabelHeight:Number;
      
      private var _maxLabelWidth:Number;
      
      private var _maxRotatedLabelHeight:Number;
      
      private var _axisLabelSet:AxisLabelSet;
      
      private var _labels:Array;
      
      private var _labelPlacement:Object;
      
      private var _forceLabelUpdate:Boolean = false;
      
      private var _labelCache:InstanceCache;
      
      private var _horizontal:Boolean;
      
      private var _titleField:UIComponent;
      
      private var _titleFieldChanged:Boolean;
      
      private var _canRotate:Boolean;
      
      private var _inverted:Boolean = false;
      
      private var _bGuttersAdjusted:Boolean = false;
      
      private var _supressInvalidations:int = 0;
      
      private var _measuringField:DisplayObject;
      
      private var _axis:IAxis = null;
      
      private var _gutters:Rectangle;
      
      private var _highlightElements:Boolean = false;
      
      private var _labelFunction:Function = null;
      
      private var _labelRenderer:IFactory = null;
      
      private var _placement:String = "";
      
      private var _titleRenderer:IFactory = null;
      
      public function AxisRenderer()
      {
         this._ticks = [];
         this._minorTicks = [];
         this._labels = [];
         this._gutters = new Rectangle();
         super();
         var _loc1_:Class = this.getLabelClass();
         textFieldFactory = new ContextualClassFactory(_loc1_,moduleFactory);
         this._labelCache = new InstanceCache(_loc1_,this);
         this._labelCache.discard = true;
         this._labelCache.remove = true;
         this.updateRotation();
         super.showInAutomationHierarchy = false;
      }
      
      override public function set showInAutomationHierarchy(param1:Boolean) : void
      {
      }
      
      public function get axis() : IAxis
      {
         return this._axis;
      }
      
      public function set axis(param1:IAxis) : void
      {
         if(this._axis)
         {
            this._axis.removeEventListener("axisChange",this.axisChangeHandler,false);
            this._axis.removeEventListener("titleChange",this.titleChangeHandler,false);
         }
         this._axis = param1;
         param1.addEventListener("axisChange",this.axisChangeHandler,false,0,true);
         param1.addEventListener("titleChange",this.titleChangeHandler,false,0,true);
      }
      
      protected function get chart() : ChartBase
      {
         var _loc1_:DisplayObject = parent;
         while(!(_loc1_ is ChartBase) && _loc1_)
         {
            _loc1_ = _loc1_.parent;
         }
         return _loc1_ as ChartBase;
      }
      
      public function get gutters() : Rectangle
      {
         if(this._horizontal == false)
         {
            return new Rectangle(this._gutters.bottom,this._gutters.left,-this._gutters.height,this._gutters.width);
         }
         return this._gutters;
      }
      
      public function set gutters(param1:Rectangle) : void
      {
         var _loc2_:Rectangle = param1;
         if(this._gutters && this._gutters.left == _loc2_.left && this._gutters.right == _loc2_.right && this._gutters.top == _loc2_.top && this._gutters.bottom == _loc2_.bottom)
         {
            this._gutters = _loc2_;
            return;
         }
         this.adjustGutters(param1,{
            "left":false,
            "top":false,
            "right":false,
            "bottom":false
         });
      }
      
      public function get heightLimit() : Number
      {
         return this._heightLimit;
      }
      
      public function set heightLimit(param1:Number) : void
      {
         this._heightLimit = param1;
      }
      
      public function get highlightElements() : Boolean
      {
         return this._highlightElements;
      }
      
      public function set highlightElements(param1:Boolean) : void
      {
         if(param1 == this._highlightElements)
         {
            return;
         }
         this._highlightElements = param1;
         invalidateProperties();
      }
      
      public function get horizontal() : Boolean
      {
         return this._horizontal;
      }
      
      public function set horizontal(param1:Boolean) : void
      {
         this._horizontal = param1;
         this.updateRotation();
      }
      
      public function get labelFunction() : Function
      {
         return this._labelFunction;
      }
      
      public function set labelFunction(param1:Function) : void
      {
         this._labelFunction = param1;
         if(this.chart)
         {
            this.chart.invalidateDisplayList();
         }
         this._forceLabelUpdate = true;
         this._cacheDirty = true;
         this._axisLabelSet = null;
         this.invalidateDisplayList();
      }
      
      public function get labelRenderer() : IFactory
      {
         return this._labelRenderer;
      }
      
      public function set labelRenderer(param1:IFactory) : void
      {
         var _loc2_:IFactory = this._labelRenderer;
         this._labelRenderer = param1;
         if(_loc2_ == param1)
         {
            return;
         }
         if(this._measuringField)
         {
            removeChild(this._measuringField);
            this._measuringField = null;
         }
         this._labelCache.discard = true;
         this._labelCache.count = 0;
         this._labelCache.discard = false;
         if(!param1)
         {
            this._labelCache.factory = textFieldFactory;
         }
         else
         {
            this._labelCache.factory = this._labelRenderer;
         }
         if(this.chart)
         {
            this.chart.invalidateDisplayList();
         }
         this._forceLabelUpdate = true;
         this._cacheDirty = true;
         this.invalidateDisplayList();
      }
      
      public function get length() : Number
      {
         return unscaledWidth - this._gutters.left - this._gutters.right;
      }
      
      public function get minorTicks() : Array
      {
         return this._minorTicks;
      }
      
      public function set otherAxes(param1:Array) : void
      {
         this._otherAxes = param1;
      }
      
      public function get placement() : String
      {
         return this._placement;
      }
      
      public function set placement(param1:String) : void
      {
         this._placement = param1;
         this._inverted = param1 == "right" || param1 == "top";
         if(this.chart)
         {
            dispatchEvent(new Event("axisPlacementChange",true));
         }
         this._forceLabelUpdate = true;
         this._cacheDirty = true;
         this.invalidateDisplayList();
      }
      
      public function get ticks() : Array
      {
         return this._ticks;
      }
      
      public function get titleRenderer() : IFactory
      {
         return this._titleRenderer;
      }
      
      public function set titleRenderer(param1:IFactory) : void
      {
         var _loc2_:IFactory = this._titleRenderer;
         this._titleRenderer = param1;
         if(_loc2_ == param1)
         {
            return;
         }
         if(this.chart)
         {
            this.chart.invalidateDisplayList();
         }
         this.invalidateDisplayList();
      }
      
      private function initStyles() : Boolean
      {
         HaloDefaults.init(styleManager);
         var _loc1_:CSSStyleDeclaration = styleManager.getStyleDeclaration("mx.charts.AxisRenderer");
         _loc1_.setStyle("axisStroke",new SolidColorStroke(0,0,1));
         _loc1_.setStyle("tickStroke",new SolidColorStroke(0,0,1));
         _loc1_.setStyle("minorTickStroke",new SolidColorStroke(0,0,1));
         var _loc2_:CSSStyleDeclaration = styleManager.getStyleDeclaration(".blockCategoryAxis");
         _loc2_.setStyle("axisStroke",new SolidColorStroke(12307677,8,1,false,"normal","none"));
         _loc2_.setStyle("tickStroke",new SolidColorStroke(16777215,2,1,false,"normal","none"));
         var _loc3_:CSSStyleDeclaration = styleManager.getStyleDeclaration(".blockNumericAxis");
         _loc3_.setStyle("axisStroke",new SolidColorStroke(12307677,8,1,false,"normal","none"));
         _loc3_.setStyle("tickStroke",new SolidColorStroke(12307677,1,1,false,"normal","none"));
         _loc3_.setStyle("minorTickStroke",new SolidColorStroke(16777215,1,1,false,"normal","none"));
         var _loc4_:CSSStyleDeclaration;
         (_loc4_ = styleManager.getStyleDeclaration(".linedNumericAxis")).setStyle("axisStroke",new SolidColorStroke(12307677,1,1,false,"normal","none"));
         _loc4_.setStyle("tickStroke",new SolidColorStroke(12307677,1,1,false,"normal","none"));
         _loc4_.setStyle("minorTickStroke",new SolidColorStroke(12307677,1,1,false,"normal","none"));
         var _loc5_:CSSStyleDeclaration;
         (_loc5_ = styleManager.getStyleDeclaration(".dashedNumericAxis")).setStyle("tickStroke",new SolidColorStroke(12307677,1,1,false,"normal","none"));
         _loc5_.setStyle("minorTickStroke",new SolidColorStroke(12307677,1,1,false,"normal","none"));
         var _loc6_:CSSStyleDeclaration;
         (_loc6_ = styleManager.getStyleDeclaration(".dashedCategoryAxis")).setStyle("axisStroke",new SolidColorStroke(12307677,1,1,false,"normal","none"));
         _loc6_.setStyle("tickStroke",new SolidColorStroke(16777215,2,1,false,"normal","none"));
         var _loc7_:CSSStyleDeclaration;
         (_loc7_ = styleManager.getStyleDeclaration(".hangingCategoryAxis")).setStyle("axisStroke",new SolidColorStroke(12307677,1,1,false,"normal","none"));
         _loc7_.setStyle("tickStroke",new SolidColorStroke(12307677,1,1,false,"normal","none"));
         _loc7_.setStyle("minorTickStroke",new SolidColorStroke(0,0,0));
         return true;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         if(this._moduleFactoryInitialized)
         {
            return;
         }
         this._moduleFactoryInitialized = true;
         this.initStyles();
      }
      
      override protected function commitProperties() : void
      {
         var _loc1_:Class = null;
         super.commitProperties();
         if(!this.labelRenderer)
         {
            _loc1_ = this.getLabelClass();
            textFieldFactory = new ContextualClassFactory(_loc1_,moduleFactory);
            this._labelCache.factory = textFieldFactory;
         }
         this.setupMouseDispatching();
      }
      
      override public function invalidateSize() : void
      {
         if(this._supressInvalidations == 0)
         {
            super.invalidateSize();
         }
      }
      
      override public function invalidateDisplayList() : void
      {
         if(this._supressInvalidations == 0)
         {
            super.invalidateDisplayList();
         }
      }
      
      override protected function measure() : void
      {
         var _loc1_:Number = 0;
         var _loc2_:Object = getStyle("showLabels");
         var _loc3_:Boolean = _loc2_ != false && _loc2_ != "false";
         var _loc4_:Object;
         var _loc5_:Boolean = (_loc4_ = getStyle("showLine")) != false && _loc4_ != "false";
         var _loc6_:IStroke = getStyle("axisStroke");
         _loc1_ += this.tickSize(_loc5_);
         _loc1_ += getStyle("labelGap");
         _loc1_ += Number(_loc5_ == true && _loc6_ ? _loc6_.weight : 0);
         var _loc7_:Number = 0;
         var _loc8_:Number = 1;
         var _loc9_:Point;
         _loc7_ = (_loc9_ = this.measureTitle()).y;
         _loc1_ += _loc7_;
         if(this._horizontal)
         {
            measuredMinHeight = _loc1_;
         }
         else
         {
            measuredMinWidth = _loc1_;
         }
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:Number = NaN;
         super.updateDisplayList(param1,param2);
         ++this._supressInvalidations;
         var _loc3_:ChartBase = this.chart;
         if(this._bGuttersAdjusted == true && _loc3_.chartState != ChartState.PREPARING_TO_HIDE_DATA && _loc3_.chartState != ChartState.HIDING_DATA)
         {
            this.updateCaches();
            graphics.clear();
            _loc4_ = getStyle("showLine");
            _loc5_ = this.drawLabels(_loc4_);
            this.drawTitle(_loc5_);
            this.drawAxis(_loc4_);
            this.drawTicks(_loc4_);
         }
         --this._supressInvalidations;
      }
      
      override public function move(param1:Number, param2:Number) : void
      {
         if(this._horizontal)
         {
            super.move(param1,param2);
         }
         else
         {
            super.move(param1 + unscaledHeight,param2);
         }
      }
      
      override public function setActualSize(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         if(this._horizontal)
         {
            super.setActualSize(param1,param2);
         }
         else
         {
            _loc3_ = x - unscaledHeight;
            super.setActualSize(param2,param1);
            this.move(_loc3_ + param1,y);
         }
      }
      
      override public function styleChanged(param1:String) : void
      {
         if(param1 == null || param1 == "axisTitleStyleName")
         {
            this._titleFieldChanged = true;
         }
         if(this.chart)
         {
            this.chart.invalidateDisplayList();
         }
         this._axisLabelSet = null;
         this._forceLabelUpdate = true;
         this._cacheDirty = true;
         this.invalidateDisplayList();
      }
      
      public function chartStateChanged(param1:uint, param2:uint) : void
      {
         this.invalidateDisplayList();
      }
      
      public function adjustGutters(param1:Rectangle, param2:Object) : Rectangle
      {
         var _loc7_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc19_:Rectangle = null;
         var _loc20_:ARLabelData = null;
         var _loc21_:int = 0;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:int = 0;
         var _loc27_:ARLabelData = null;
         var _loc28_:Number = NaN;
         this._bGuttersAdjusted = true;
         var _loc3_:IStroke = getStyle("axisStroke");
         this.updateCaches();
         var _loc4_:Number = unscaledWidth;
         var _loc5_:Number = unscaledHeight;
         var _loc6_:Number = 1;
         if(this._horizontal == false)
         {
            (_loc19_ = new Rectangle(param1.top,param1.right,0,0)).right = param1.bottom;
            _loc19_.bottom = param1.left;
            this._gutters = param1 = _loc19_;
            param2 = {
               "left":param2.top,
               "top":param2.right,
               "right":param2.bottom,
               "bottom":param2.left
            };
         }
         else
         {
            this._gutters = param1 = param1.clone();
         }
         if(this._inverted)
         {
            _loc7_ = param1.top;
            param1.top = param1.bottom;
            param1.bottom = _loc7_;
         }
         var _loc8_:Number = 0;
         var _loc9_:Object;
         var _loc10_:Boolean = (_loc9_ = getStyle("showLabels")) != false && _loc9_ != "false";
         var _loc11_:Object;
         var _loc12_:Boolean = (_loc11_ = getStyle("showLine")) != false && _loc11_ != "false";
         _loc8_ = (_loc8_ = (_loc8_ += this.tickSize(_loc12_)) + getStyle("labelGap")) + Number(_loc12_ == true && _loc3_ ? _loc3_.weight : 0);
         var _loc13_:Number = 0;
         var _loc14_:Number = 1;
         var _loc15_:Point;
         _loc13_ = (_loc15_ = this.measureTitle()).y;
         _loc8_ += _loc13_ * _loc14_;
         if(param2.bottom == false)
         {
            _loc16_ = Math.max(0,param1.bottom - _loc8_);
         }
         else if(!isNaN(this.heightLimit))
         {
            _loc16_ = Math.max(0,this.heightLimit - _loc8_);
         }
         var _loc17_:IStroke;
         if(_loc17_ = getStyle("tickStroke"))
         {
            param1.left = Math.max(param1.left,_loc17_.weight / 2);
            param1.right = Math.max(param1.right,_loc17_.weight / 2);
         }
         if(_loc17_ = getStyle("minorTickStroke"))
         {
            param1.left = Math.max(param1.left,_loc17_.weight / 2);
            param1.right = Math.max(param1.right,_loc17_.weight / 2);
         }
         if(_loc10_)
         {
            this._labelPlacement = this.calcRotationAndSpacing(_loc4_,_loc5_,_loc16_,param1,param2);
            _loc20_ = this._labels[0];
            _loc21_ = this._labels.length;
            if(this._labelPlacement.rotation == 0)
            {
               if(this._labelPlacement.staggered)
               {
                  _loc8_ += 2 * _loc20_.height * this._labelPlacement.scale;
               }
               else
               {
                  _loc8_ += this._maxLabelHeight * this._labelPlacement.scale;
               }
            }
            else
            {
               _loc22_ = Math.cos(Math.abs(this._labelPlacement.rotation));
               _loc23_ = Math.sin(Math.abs(this._labelPlacement.rotation));
               _loc24_ = 1 - this.labelAlignOffset;
               _loc25_ = 0;
               _loc6_ = this._labelPlacement.scale;
               _loc26_ = 0;
               while(_loc26_ < _loc21_)
               {
                  _loc27_ = this._labels[_loc26_];
                  _loc28_ = _loc22_ * _loc27_.height * _loc24_ * _loc6_ + _loc23_ * _loc27_.width * _loc6_;
                  _loc25_ = Math.max(_loc28_,_loc25_);
                  _loc26_++;
               }
               this._maxRotatedLabelHeight = _loc25_;
               _loc8_ += _loc25_;
            }
         }
         else
         {
            this.measureLabels(false,_loc4_);
            this._labelPlacement = {
               "rotation":0,
               "left":0,
               "right":0,
               "scale":1,
               "staggered":false
            };
         }
         var _loc18_:Number = Math.max(param1.left,this._labelPlacement.left);
         param1 = new Rectangle(_loc18_,param1.top,Math.max(param1.right,this._labelPlacement.right) - _loc18_,Math.max(param1.bottom,_loc8_) - param1.top);
         if(this._inverted)
         {
            _loc7_ = param1.top;
            param1.top = param1.bottom;
            param1.bottom = _loc7_;
         }
         this._gutters = param1;
         this.invalidateDisplayList();
         return this.gutters;
      }
      
      private function measureTitle() : Point
      {
         if(!this._axis || !this._axis.title || this._axis.title.length == 0)
         {
            return new Point(0,0);
         }
         this.renderTitle();
         ++this._supressInvalidations;
         (this._titleField as IDataRenderer).data = !!this._axis ? this._axis.title : "";
         this._titleField.validateProperties();
         this._titleField.validateSize(true);
         --this._supressInvalidations;
         return new Point(this._titleField.measuredWidth,this._titleField.measuredHeight);
      }
      
      private function renderTitle() : void
      {
         var _loc1_:Object = null;
         if(!this._titleField || getQualifiedClassName(this._titleField) == "mx.charts.chartClasses::ChartLabel" && this._titleRenderer || getQualifiedClassName(this._titleField) != "mx.charts.chartClasses::ChartLabel" && !this._titleRenderer)
         {
            if(this._titleField)
            {
               removeChild(this._titleField);
            }
            if(this._titleRenderer)
            {
               this._titleField = this._titleRenderer.newInstance();
            }
            else
            {
               this._titleField = new ChartLabel();
            }
            this._titleField.visible = false;
            addChild(this._titleField);
         }
         this._titleFieldChanged = true;
         if(this._titleFieldChanged)
         {
            this._titleFieldChanged = false;
            _loc1_ = getStyle("axisTitleStyleName");
            if(_loc1_ != null)
            {
               this._titleField.styleName = _loc1_;
            }
            else
            {
               this._titleField.styleName = this;
            }
         }
      }
      
      private function getLabelClass() : Class
      {
         var labelClass:Class = getStyle("labelClass");
         if(labelClass == null)
         {
            try
            {
               labelClass = Class(ApplicationDomain.currentDomain.getDefinition("spark.components::Label"));
            }
            catch(e:Error)
            {
               labelClass = Class(ApplicationDomain.currentDomain.getDefinition("mx.controls::Label"));
            }
         }
         return labelClass;
      }
      
      private function calcRotationAndSpacing(param1:Number, param2:Number, param3:Number, param4:Rectangle, param5:Object) : Object
      {
         var _loc12_:Boolean = false;
         var _loc14_:ARLabelData = null;
         var _loc25_:Object = null;
         var _loc26_:Object = null;
         var _loc27_:Object = null;
         var _loc28_:Object = null;
         var _loc29_:Object = null;
         var _loc30_:Object = null;
         var _loc31_:ARLabelData = null;
         var _loc32_:ARLabelData = null;
         var _loc33_:Number = NaN;
         var _loc34_:Number = NaN;
         var _loc35_:Number = NaN;
         var _loc36_:Boolean = false;
         var _loc37_:int = 0;
         var _loc38_:int = 0;
         var _loc39_:int = 0;
         var _loc40_:Boolean = false;
         var _loc41_:Boolean = false;
         var _loc42_:int = 0;
         var _loc43_:int = 0;
         this.updateCaches();
         var _loc6_:Number = param4.left;
         var _loc7_:Number = param4.right;
         var _loc8_:Boolean = this.measureLabels(true,0);
         var _loc9_:int;
         if((_loc9_ = this._labels.length) == 0)
         {
            return {
               "rotation":0,
               "left":_loc6_,
               "right":_loc7_,
               "scale":1,
               "staggered":false
            };
         }
         var _loc10_:Number;
         if((_loc10_ = getStyle("labelRotation")) > 90)
         {
            _loc10_ = 0 / 0;
         }
         if(this._horizontal == false)
         {
            if(isNaN(_loc10_))
            {
               _loc10_ = 0;
            }
            if(_loc10_ >= 0)
            {
               _loc10_ = 90 - _loc10_;
            }
            else
            {
               _loc10_ = -(90 + _loc10_);
            }
         }
         var _loc11_:Object;
         if((_loc11_ = getStyle("canDropLabels")) == null)
         {
            _loc12_ = Boolean(this._axis.preferDropLabels());
         }
         else
         {
            _loc12_ = _loc11_ != false && _loc11_ != "false";
         }
         var _loc13_:ARLabelData = this._labels[0];
         if(_loc12_)
         {
            _loc31_ = _loc13_;
            _loc35_ = param1 - _loc6_ - _loc7_;
            _loc36_ = true;
            _loc39_ = 0;
            _loc41_ = true;
            _loc42_ = 0;
            _loc9_ = this._labels.length;
            if(this._horizontal)
            {
               if(_loc9_ > 0)
               {
                  _loc31_ = this._labels[0];
               }
               _loc37_ = 0;
               _loc38_ = 1;
            }
            else
            {
               if(_loc9_ > 0)
               {
                  _loc31_ = this._labels[_loc9_ - 1];
               }
               _loc37_ = _loc9_ - 1;
               _loc38_ = -1;
            }
            _loc43_ = 1;
            while(_loc43_ < _loc9_)
            {
               _loc32_ = this._labels[_loc37_ + _loc38_ * _loc43_];
               _loc33_ = Math.abs(_loc32_.position - _loc31_.position) * _loc35_;
               if((_loc34_ = (_loc32_.width + _loc31_.width) / 2) > _loc33_)
               {
                  _loc42_++;
               }
               else
               {
                  if(_loc42_ > _loc39_)
                  {
                     _loc39_ = _loc42_;
                  }
                  _loc42_ = 0;
                  _loc31_ = _loc32_;
               }
               _loc43_++;
            }
            if(_loc42_ > _loc39_)
            {
               _loc39_ = _loc42_;
            }
            if(_loc39_ == 0)
            {
               _loc14_ = this._labels[this._labels.length - 1];
            }
            else
            {
               _loc14_ = !!this._labels[_loc39_ + 1] ? this._labels[_loc39_ + 1] : this._labels[this._labels.length - 1];
            }
         }
         else
         {
            _loc14_ = this._labels[this._labels.length - 1];
         }
         var _loc15_:Boolean;
         var _loc16_:Boolean = (_loc15_ = this._horizontal && this._canRotate && _loc10_ == 90 || this._horizontal == false && (isNaN(_loc10_) || _loc10_ == 90 || this._canRotate == false)) == false && (isNaN(_loc10_) && this._horizontal == true || _loc10_ == 0 || this._canRotate == false);
         var _loc17_:Number = 0;
         var _loc18_:Object;
         var _loc19_:Boolean = (_loc18_ = getStyle("canStagger")) == null || _loc18_ != false && _loc18_ != "false";
         var _loc20_:Boolean = _loc15_ == false && (_loc12_ == false && _loc16_ && false != _loc18_);
         var _loc21_:Number = 0;
         var _loc22_:Boolean = _loc15_ == false && (this._canRotate == true && _loc10_ != 0 && (_loc12_ == false || !isNaN(_loc10_)));
         var _loc23_:Number = 0;
         var _loc24_:Number = param1 - _loc6_ - _loc7_;
         if(_loc8_)
         {
            if(_loc15_)
            {
               _loc25_ = this.calcVerticalGutters(param1,_loc6_,_loc7_,_loc13_,_loc14_,param5);
               return this.calcVerticalSpacing(param1,_loc25_,param3,_loc13_,_loc14_,_loc12_);
            }
            if(_loc16_ || _loc20_)
            {
               _loc26_ = this.measureHorizontalGutters(param1,_loc6_,_loc7_,_loc13_,_loc14_,param5);
               if((_loc17_ = (_loc29_ = this.calcHorizontalSpacing(param1,_loc26_,param3,_loc13_,_loc14_,_loc12_,param5,_loc24_)).scale) != 1 && _loc20_)
               {
                  _loc21_ = (_loc30_ = this.calcStaggeredSpacing(param1,_loc26_,param3,_loc13_,_loc14_,_loc12_,param5)).scale;
               }
            }
            if(_loc17_ != 1 && _loc21_ != 1 && _loc22_)
            {
               _loc27_ = this.measureAngledGutters(param1,_loc10_,param3,_loc13_,_loc6_,_loc7_,param5);
               _loc23_ = (_loc28_ = this.calcAngledSpacing(_loc27_)).scale;
            }
            if(_loc17_ >= _loc21_ && _loc17_ >= _loc23_)
            {
               if(_loc29_ != null)
               {
                  return _loc29_;
               }
               return _loc28_;
            }
            if(_loc21_ >= _loc23_)
            {
               if(_loc30_ != null)
               {
                  return _loc30_;
               }
               return _loc28_;
            }
            return _loc28_;
         }
         if(_loc15_)
         {
            _loc25_ = this.calcVerticalGutters(param1,_loc6_,_loc7_,_loc13_,_loc14_,param5);
            _loc24_ = Math.min(_loc24_,_loc25_.minimumAxisLength);
         }
         if(_loc16_ || _loc20_)
         {
            _loc26_ = this.measureHorizontalGutters(param1,_loc6_,_loc7_,_loc13_,_loc14_,param5);
            _loc24_ = Math.min(_loc24_,_loc26_.minimumAxisLength);
         }
         if(_loc22_)
         {
            _loc27_ = this.measureAngledGutters(param1,_loc10_,param3,_loc13_,_loc6_,_loc7_,param5);
            _loc24_ = Math.min(_loc24_,_loc27_.minimumAxisLength);
         }
         this.measureLabels(false,_loc24_);
         if(this._labels.length == 0)
         {
            return {
               "rotation":0,
               "left":_loc6_,
               "right":_loc7_,
               "scale":1,
               "staggered":false
            };
         }
         if(_loc15_)
         {
            return this.calcVerticalSpacing(param1,_loc25_,param3,_loc13_,_loc14_,_loc12_);
         }
         if(_loc16_)
         {
            _loc17_ = (_loc29_ = this.calcHorizontalSpacing(param1,_loc26_,param3,_loc13_,_loc14_,_loc12_,param5,_loc24_)).scale;
         }
         if(_loc20_)
         {
            _loc21_ = (_loc30_ = this.calcStaggeredSpacing(param1,_loc26_,param3,_loc13_,_loc14_,_loc12_,param5)).scale;
         }
         if(_loc22_)
         {
            _loc23_ = (_loc28_ = this.calcAngledSpacing(_loc27_)).scale;
         }
         if(_loc17_ >= _loc21_ && _loc17_ >= _loc23_)
         {
            if(_loc29_ != null)
            {
               return _loc29_;
            }
            return _loc28_;
         }
         if(_loc21_ >= _loc23_)
         {
            if(_loc30_ != null)
            {
               return _loc30_;
            }
            return _loc28_;
         }
         return _loc28_;
      }
      
      private function measureLabels(param1:Boolean, param2:Number) : Boolean
      {
         var _loc3_:AxisLabelSet = null;
         if(!this._axis)
         {
            throw new Error(resourceManager.getString("charts","noAxisSet"));
         }
         if(param1)
         {
            _loc3_ = this._axis.getLabelEstimate();
         }
         else
         {
            _loc3_ = this._axis.getLabels(param2);
         }
         if(_loc3_ == this._axisLabelSet && this._forceLabelUpdate == false)
         {
            return _loc3_.accurate;
         }
         var _loc4_:Boolean = this.processAxisLabels(_loc3_);
         this._axisLabelSet = _loc3_;
         return _loc4_;
      }
      
      private function calcVerticalGutters(param1:Number, param2:Number, param3:Number, param4:ARLabelData, param5:ARLabelData, param6:Object) : Object
      {
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc7_:Number = this.labelAlignOffset;
         var _loc8_:Number = param1 - param2 - param3;
         var _loc9_:Number = param4.height * _loc7_;
         var _loc10_:Number = param4.height * (1 - _loc7_);
         var _loc11_:Number = param4.position;
         var _loc12_:Number = 1 - param5.position;
         var _loc15_:* = Boolean(param6.left != false && _loc9_ > param2 + _loc11_ * _loc8_);
         var _loc16_:* = Boolean(param6.right != false && _loc10_ > param3 + _loc12_ * _loc8_);
         if(_loc15_ == false && _loc16_ == false)
         {
            _loc13_ = param2;
            _loc14_ = param3;
         }
         else if(_loc15_ == true && _loc16_ == false)
         {
            _loc8_ = (param1 - param3 - _loc9_) / (1 - _loc11_);
            _loc13_ = param1 - param3 - _loc8_;
            _loc14_ = param3;
            _loc16_ = _loc10_ > _loc14_ + _loc12_ * _loc8_;
         }
         else if(_loc15_ == false && _loc16_ == true)
         {
            _loc8_ = (param1 - param2 - _loc10_) / (1 - _loc12_);
            _loc13_ = param2;
            _loc14_ = param1 - param2 - _loc8_;
            _loc15_ = _loc9_ > _loc13_ + _loc11_ * _loc8_;
         }
         if(_loc15_ && _loc16_)
         {
            _loc8_ = (param1 - _loc9_ - _loc10_) / (1 - _loc11_ - _loc12_);
            _loc13_ = _loc9_ - _loc11_ * _loc8_;
            _loc14_ = _loc10_ - _loc12_ * _loc8_;
         }
         return {
            "hlm":_loc13_,
            "hrm":_loc14_,
            "minimumAxisLength":param1 - _loc13_ - _loc14_
         };
      }
      
      private function calcVerticalSpacing(param1:Number, param2:Object, param3:Number, param4:ARLabelData, param5:ARLabelData, param6:Boolean) : Object
      {
         var _loc7_:Number = NaN;
         var _loc10_:ARLabelData = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:Boolean = false;
         var _loc19_:Boolean = false;
         var _loc20_:int = 0;
         var _loc21_:Object = null;
         var _loc22_:Object = null;
         var _loc23_:int = 0;
         var _loc8_:Number = param1 - param2.hlm - param2.hrm;
         if(!isNaN(param3))
         {
            _loc7_ = Math.min(1,param3 / this._maxLabelWidth);
         }
         else
         {
            _loc7_ = 1;
         }
         var _loc9_:ARLabelData = param4;
         var _loc13_:Boolean = true;
         var _loc14_:int = this._labels.length;
         if(param6)
         {
            _loc17_ = 0;
            _loc19_ = true;
            do
            {
               _loc17_ = 0;
               _loc20_ = 0;
               if(this._horizontal)
               {
                  if(this._labels.length > 0)
                  {
                     _loc9_ = this._labels[0];
                  }
                  _loc15_ = 0;
                  _loc16_ = 1;
               }
               else
               {
                  if(this._labels.length > 0)
                  {
                     _loc9_ = this._labels[this._labels.length - 1];
                  }
                  _loc15_ = this._labels.length - 1;
                  _loc16_ = -1;
               }
               _loc14_ = this._labels.length;
               _loc23_ = 1;
               while(_loc23_ < _loc14_)
               {
                  _loc10_ = this._labels[_loc15_ + _loc16_ * _loc23_];
                  _loc11_ = Math.abs(_loc10_.position - _loc9_.position) * _loc8_;
                  if((_loc12_ = (_loc10_.height + _loc9_.height) / 2) <= _loc11_)
                  {
                     if(_loc20_ > _loc17_)
                     {
                        _loc17_ = _loc20_;
                        _loc21_ = _loc9_;
                        _loc22_ = this._labels[_loc15_ + _loc16_ * (_loc23_ - 1)];
                     }
                  }
                  _loc20_++;
                  _loc23_++;
               }
               if(_loc20_ > _loc17_)
               {
                  _loc17_ = _loc20_;
                  _loc21_ = _loc9_;
                  _loc22_ = this._labels[_loc15_ + _loc16_ * (_loc23_ - 1)];
               }
               if(_loc17_)
               {
                  _loc18_ = this.reduceLabels(_loc21_.value,_loc22_.value);
               }
               else
               {
                  _loc19_ = false;
                  _loc13_ = false;
               }
            }
            while(_loc19_ && _loc18_);
            
         }
         if(_loc13_)
         {
            _loc9_ = this._labels[0];
            _loc14_ = this._labels.length;
            _loc23_ = 1;
            while(_loc23_ < _loc14_)
            {
               _loc11_ = ((_loc10_ = this._labels[_loc23_]).position - _loc9_.position) * _loc8_;
               _loc12_ = (_loc10_.height + _loc9_.height) / 2;
               _loc7_ = Math.min(_loc7_,_loc11_ / _loc12_);
               _loc9_ = _loc10_;
               _loc23_++;
            }
         }
         return {
            "rotation":Math.PI / 2,
            "left":param2.hlm,
            "right":param2.hrm,
            "scale":Math.max(0,_loc7_),
            "staggered":false
         };
      }
      
      private function measureHorizontalGutters(param1:Number, param2:Number, param3:Number, param4:ARLabelData, param5:ARLabelData, param6:Object) : Object
      {
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc7_:Number = this.labelAlignOffset;
         var _loc8_:Number = param1 - param2 - param3;
         var _loc9_:Number = param4.width * _loc7_;
         var _loc10_:Number = param5.width * (1 - _loc7_);
         var _loc11_:Number = param4.position;
         var _loc12_:Number = 1 - param5.position;
         var _loc15_:* = Boolean(param6.left != false && _loc9_ > param2 + _loc11_ * _loc8_);
         var _loc16_:* = Boolean(param6.right != false && _loc10_ > param3 + _loc12_ * _loc8_);
         if(_loc15_ == false && _loc16_ == false)
         {
            _loc13_ = param2;
            _loc14_ = param3;
         }
         else if(_loc15_ == true && _loc16_ == false)
         {
            _loc8_ = (param1 - param3 - _loc9_) / (1 - _loc11_);
            _loc13_ = param1 - param3 - _loc8_;
            _loc14_ = param3;
            _loc16_ = _loc10_ > _loc14_ + _loc12_ * _loc8_;
         }
         else if(_loc15_ == false && _loc16_ == true)
         {
            _loc8_ = (param1 - param2 - _loc10_) / (1 - _loc12_);
            _loc13_ = param2;
            _loc14_ = param1 - param2 - _loc8_;
            _loc15_ = _loc9_ > _loc13_ + _loc11_ * _loc8_;
         }
         if(_loc15_ && _loc16_)
         {
            _loc8_ = (param1 - _loc9_ - _loc10_) / (1 - _loc11_ - _loc12_);
            _loc13_ = _loc9_ - _loc11_ * _loc8_;
            _loc14_ = _loc10_ - _loc12_ * _loc8_;
         }
         return {
            "horizontalleftGutter":_loc13_,
            "horizontalrightGutter":_loc14_,
            "minimumAxisLength":param1 - _loc13_ - _loc14_
         };
      }
      
      private function calcHorizontalSpacing(param1:Number, param2:Object, param3:Number, param4:ARLabelData, param5:ARLabelData, param6:Boolean, param7:Object, param8:Number) : Object
      {
         var _loc12_:ARLabelData = null;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:Boolean = false;
         var _loc23_:Boolean = false;
         var _loc24_:int = 0;
         var _loc25_:Object = null;
         var _loc26_:Object = null;
         var _loc27_:int = 0;
         var _loc9_:Number = param2.horizontalleftGutter;
         var _loc10_:Number = param2.horizontalrightGutter;
         var _loc11_:Number = 1;
         if(!isNaN(param3))
         {
            _loc11_ = Math.min(1,param3 / this._maxLabelHeight);
         }
         var _loc13_:ARLabelData = param4;
         var _loc14_:int = this._labels.length;
         var _loc15_:Number = param1 - _loc9_ - _loc10_;
         var _loc18_:Boolean = true;
         if(param6)
         {
            _loc21_ = 0;
            _loc23_ = true;
            do
            {
               _loc21_ = 0;
               _loc24_ = 0;
               if(this._horizontal)
               {
                  if(this._labels.length > 0)
                  {
                     _loc13_ = this._labels[0];
                  }
                  _loc19_ = 0;
                  _loc20_ = 1;
               }
               else
               {
                  if(this._labels.length > 0)
                  {
                     _loc13_ = this._labels[this._labels.length - 1];
                  }
                  _loc19_ = this._labels.length - 1;
                  _loc20_ = -1;
               }
               _loc14_ = this._labels.length;
               _loc27_ = 1;
               while(_loc27_ < _loc14_)
               {
                  _loc12_ = this._labels[_loc19_ + _loc20_ * _loc27_];
                  _loc16_ = Math.abs(_loc12_.position - _loc13_.position) * _loc15_;
                  if((_loc17_ = (_loc12_.width + _loc13_.width) / 2) > _loc16_)
                  {
                     _loc24_++;
                  }
                  else
                  {
                     if(_loc24_ > _loc21_)
                     {
                        _loc21_ = _loc24_;
                        _loc25_ = _loc13_;
                        _loc26_ = this._labels[_loc19_ + _loc20_ * (_loc27_ - 1)];
                     }
                     _loc24_ = 0;
                     _loc13_ = _loc12_;
                  }
                  _loc27_++;
               }
               if(_loc24_ > _loc21_)
               {
                  _loc21_ = _loc24_;
                  _loc25_ = _loc13_;
                  _loc26_ = this._labels[_loc19_ + _loc20_ * (_loc27_ - 1)];
               }
               if(_loc21_)
               {
                  _loc22_ = this.reduceLabels(_loc25_.value,_loc26_.value);
               }
               else
               {
                  _loc23_ = false;
                  _loc18_ = false;
               }
            }
            while(_loc23_ && _loc22_);
            
         }
         if(_loc18_)
         {
            if(param7.left == false)
            {
               _loc11_ = Math.min(_loc11_,(_loc9_ + param4.position * _loc15_) / (param4.width / 2));
            }
            if(param7.right == false)
            {
               _loc11_ = Math.min(_loc11_,(_loc10_ + (1 - param5.position) * _loc15_) / (param5.width / 2));
            }
            _loc13_ = this._labels[0];
            _loc14_ = this._labels.length;
            _loc27_ = 1;
            while(_loc27_ < _loc14_)
            {
               _loc16_ = ((_loc12_ = this._labels[_loc27_]).position - _loc13_.position) * _loc15_;
               _loc17_ = (_loc12_.width + _loc13_.width) / 2;
               _loc11_ = Math.min(_loc11_,_loc16_ / _loc17_);
               _loc13_ = _loc12_;
               _loc27_++;
            }
         }
         return {
            "rotation":0,
            "left":_loc9_,
            "right":_loc10_,
            "scale":Math.max(0,_loc11_),
            "staggered":false
         };
      }
      
      private function calcStaggeredSpacing(param1:Number, param2:Object, param3:Number, param4:ARLabelData, param5:ARLabelData, param6:Boolean, param7:Object) : Object
      {
         var _loc10_:Number = NaN;
         var _loc15_:ARLabelData = null;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc8_:Number = param2.horizontalleftGutter;
         var _loc9_:Number = param2.horizontalrightGutter;
         var _loc11_:Number = param1 - _loc8_ - _loc9_;
         if(!isNaN(param3))
         {
            _loc10_ = Math.min(1,param3 / (2 * this._maxLabelHeight));
         }
         else
         {
            _loc10_ = 1;
         }
         var _loc12_:ARLabelData = param4;
         param5 = this._labels[1];
         if(param7.left == false)
         {
            _loc10_ = Math.min(_loc10_,_loc8_ / (param4.width / 2));
         }
         if(param7.right == false)
         {
            _loc10_ = Math.min(_loc10_,_loc9_ / (param5.width / 2));
         }
         var _loc13_:int = this._labels.length;
         var _loc14_:int = 2;
         while(_loc14_ < _loc13_)
         {
            _loc16_ = ((_loc15_ = this._labels[_loc14_]).position - _loc12_.position) * _loc11_;
            _loc17_ = (_loc15_.width + _loc12_.width) / 2;
            _loc10_ = Math.min(_loc10_,_loc16_ / _loc17_);
            _loc12_ = param5;
            param5 = _loc15_;
            _loc14_++;
         }
         return {
            "rotation":0,
            "left":_loc8_,
            "right":_loc9_,
            "scale":Math.max(0,_loc10_),
            "staggered":true
         };
      }
      
      private function measureAngledGutters(param1:Number, param2:Number, param3:Number, param4:ARLabelData, param5:Number, param6:Number, param7:Object) : Object
      {
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:ARLabelData = null;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc22_:int = 0;
         var _loc23_:ARLabelData = null;
         var _loc24_:* = false;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc30_:Number = NaN;
         var _loc11_:Number = param5;
         var _loc12_:Number = param6;
         var _loc18_:Number = 1;
         var _loc19_:Number = 1;
         var _loc20_:ARLabelData = this._labels[0];
         var _loc21_:int = this._labels.length;
         _loc22_ = 1;
         while(_loc22_ < _loc21_)
         {
            _loc23_ = this._labels[_loc22_];
            _loc19_ = Math.min(_loc19_,_loc23_.position - _loc20_.position);
            _loc20_ = _loc23_;
            _loc22_++;
         }
         if(!isNaN(param2))
         {
            _loc10_ = param2 / 180 * Math.PI;
         }
         else if(this._horizontal == false)
         {
            _loc10_ = Math.PI / 2;
         }
         if(param7.left == false && (param2 >= 0 || isNaN(param2)))
         {
            _loc13_ = param1 - _loc11_ - _loc12_;
            if(isNaN(_loc10_))
            {
               if((_loc8_ = this._maxLabelHeight / (_loc19_ * _loc13_)) >= 1)
               {
                  _loc10_ = Math.PI / 2;
                  _loc8_ = 1;
                  _loc18_ = Math.min(_loc18_,(param4.position * _loc13_ + _loc11_) / (param4.height / 2));
               }
               else
               {
                  _loc10_ = Math.asin(_loc8_);
                  if(Math.cos(_loc10_) * param4.width > param4.position * _loc13_ + _loc11_)
                  {
                     _loc10_ = Math.acos((param4.position * _loc13_ + _loc11_) / param4.width);
                     _loc8_ = Math.sin(_loc10_);
                  }
               }
            }
            else if((_loc8_ = Math.sin(_loc10_)) < 1)
            {
               _loc18_ = Math.min(_loc18_,(param4.position * _loc13_ + _loc11_) / (Math.cos(_loc10_) * param4.width));
            }
            else
            {
               _loc18_ = Math.min(_loc18_,(param4.position * _loc13_ + _loc11_) / (param4.height / 2));
            }
            if(!isNaN(param3))
            {
               _loc18_ = Math.min(_loc18_,param3 / (this._maxLabelWidth * _loc8_ + this._maxLabelHeight * Math.cos(_loc10_)));
            }
         }
         else if(param7.right == false && param2 < 0)
         {
            _loc13_ = param1 - _loc11_ - _loc12_;
            if((_loc8_ = Math.sin(-_loc10_)) < 1)
            {
               _loc18_ = Math.min(_loc18_,((1 - _loc20_.position) * _loc13_ + _loc12_) / (Math.cos(_loc10_) * _loc20_.width));
            }
            else
            {
               _loc18_ = Math.min(_loc18_,((1 - _loc20_.position) * _loc13_ + _loc12_) / (param4.height / 2));
            }
            if(!isNaN(param3))
            {
               _loc18_ = Math.min(_loc18_,param3 / (this._maxLabelWidth * _loc8_ + this._maxLabelHeight * Math.cos(-_loc10_)));
            }
         }
         else if(_loc10_ > 0)
         {
            _loc8_ = Math.sin(_loc10_);
            _loc9_ = Math.cos(_loc10_);
            _loc14_ = param4;
            if(!isNaN(param3))
            {
               _loc18_ = Math.min(1,param3 / (this._maxLabelWidth * _loc8_));
            }
            if(param7.right != false)
            {
               _loc12_ = Math.max(_loc12_,this._labels[_loc21_ - 1].height / 2 * _loc18_);
            }
            _loc13_ = param1 - _loc11_ - _loc12_;
            _loc22_ = 0;
            while(_loc22_ < _loc21_)
            {
               _loc14_ = this._labels[_loc22_];
               _loc17_ = _loc9_ * _loc14_.width * _loc18_ + _loc14_.height / 2 * _loc18_ * _loc8_;
               _loc16_ = _loc11_ + _loc13_ * _loc14_.position;
               if(_loc17_ > _loc16_)
               {
                  _loc13_ = (param1 - _loc12_ - _loc17_) / (1 - _loc14_.position);
                  _loc11_ = param1 - _loc13_ - _loc12_;
               }
               _loc22_++;
            }
         }
         else if(_loc10_ < 0)
         {
            _loc8_ = Math.sin(-_loc10_);
            _loc9_ = Math.cos(-_loc10_);
            _loc14_ = _loc20_;
            if(!isNaN(param3))
            {
               _loc18_ = Math.min(1,param3 / (this._maxLabelWidth * _loc8_));
            }
            if(param7.left != false)
            {
               _loc11_ = Math.max(_loc11_,this._labels[0].height / 2 * _loc18_);
            }
            _loc13_ = param1 - _loc11_ - _loc12_;
            _loc22_ = _loc21_ - 1;
            while(_loc22_ >= 0)
            {
               _loc14_ = this._labels[_loc22_];
               _loc15_ = param1 - _loc9_ * _loc14_.width * _loc18_ - _loc8_ * _loc14_.height / 2 * _loc18_;
               _loc16_ = _loc11_ + _loc13_ * _loc14_.position;
               if(_loc15_ < _loc16_)
               {
                  _loc13_ = (_loc15_ - _loc11_) / _loc14_.position;
                  _loc12_ = param1 - _loc13_ - _loc11_;
               }
               _loc22_--;
            }
         }
         else
         {
            _loc12_ = param6;
            _loc11_ = param5;
            _loc21_ = this._labels.length;
            _loc22_ = 0;
            while(_loc22_ < _loc21_)
            {
               _loc14_ = this._labels[_loc22_];
               _loc24_ = true;
               if(!isNaN(_loc10_))
               {
                  _loc24_ = _loc14_.width * _loc9_ > _loc11_ + _loc13_ * _loc14_.position;
               }
               if(_loc24_)
               {
                  _loc25_ = Math.PI / 2;
                  _loc26_ = 0;
                  _loc10_ = _loc25_;
                  do
                  {
                     _loc8_ = Math.sin(_loc10_);
                     _loc9_ = Math.cos(_loc10_);
                     if(!isNaN(param3))
                     {
                        _loc18_ = Math.min(1,param3 / (this._maxLabelWidth * _loc8_ + this._maxLabelHeight * _loc9_));
                     }
                     _loc17_ = _loc9_ * _loc14_.width * _loc18_;
                     _loc27_ = Math.max(_loc17_,param5 + (param1 - param5 - param6) * _loc14_.position);
                     _loc13_ = (param1 - _loc12_ - _loc27_) / (1 - _loc14_.position);
                     _loc11_ = Math.max(param5,param1 - _loc13_ - _loc12_);
                     _loc28_ = _loc19_ * _loc13_;
                     _loc29_ = this._maxLabelHeight * _loc18_ / _loc8_;
                     if((_loc30_ = _loc28_ - _loc29_) > 0 && _loc30_ < 1)
                     {
                        break;
                     }
                     if(_loc28_ > _loc29_)
                     {
                        if(_loc26_ >= _loc10_)
                        {
                           break;
                        }
                        _loc25_ = _loc10_;
                     }
                     else
                     {
                        if(_loc25_ <= _loc10_)
                        {
                           break;
                        }
                        _loc26_ = _loc10_;
                     }
                     if(_loc25_ - _loc26_ < 0.00001)
                     {
                        break;
                     }
                     _loc10_ = _loc26_ + (_loc25_ - _loc26_) / 2;
                  }
                  while(1);
                  
               }
               _loc22_++;
            }
         }
         return {
            "minimumAxisLength":param1 - _loc11_ - _loc12_,
            "left":_loc11_,
            "right":_loc12_,
            "scale":_loc18_,
            "rotation":_loc10_,
            "sint":_loc8_,
            "minDist":_loc19_
         };
      }
      
      private function calcAngledSpacing(param1:Object) : Object
      {
         var _loc2_:Number = param1.sint * param1.minDist * param1.minimumAxisLength;
         param1.scale = Math.max(0,Math.min(param1.scale,_loc2_ / this._maxLabelHeight));
         return param1;
      }
      
      private function updateCaches() : void
      {
         var _loc1_:ISystemManager = null;
         var _loc2_:Boolean = false;
         if(this._cacheDirty)
         {
            this._labelFormatCache = determineTextFormatFromStyles();
            _loc1_ = systemManager as ISystemManager;
            _loc2_ = this._canRotate = _loc1_.isFontFaceEmbedded(this._labelFormatCache);
            if(!this._labelRenderer)
            {
               this._labelCache.properties = {"styleName":this};
            }
            else
            {
               this._labelCache.properties = {};
            }
            this._cacheDirty = false;
         }
      }
      
      private function drawLabels(param1:Boolean) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:ARLabelData = null;
         var _loc7_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:int = 0;
         var _loc21_:ARLabelData = null;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Class = null;
         var _loc2_:IStroke = getStyle("axisStroke");
         this.renderLabels();
         var _loc8_:ARLabelData = this._labels[0];
         if(this._inverted)
         {
            _loc9_ = this._gutters.top - Number(param1 == true ? _loc2_.weight : 0) - this.tickSize(param1);
         }
         else
         {
            _loc9_ = unscaledHeight - this._gutters.bottom + Number(param1 == true ? _loc2_.weight : 0) + this.tickSize(param1);
         }
         var _loc10_:Number = this._labelPlacement.scale;
         var _loc11_:int = this._labels.length;
         var _loc13_:Boolean;
         var _loc12_:Object;
         if((_loc13_ = (_loc12_ = getStyle("showLabels")) != false && _loc12_ != "false") == false)
         {
            return _loc9_;
         }
         var _loc14_:Number = _loc10_;
         var _loc15_:int = 0;
         while(_loc15_ < _loc11_)
         {
            (_loc6_ = this._labels[_loc15_]).instance.scaleX = _loc6_.instance.scaleY = _loc14_;
            _loc15_++;
         }
         var _loc16_:Number = unscaledWidth - this._gutters.left - this._gutters.right;
         var _loc17_:Number = getStyle("labelGap");
         var _loc18_:Number = this.labelAlignOffset;
         if(this._labelPlacement.rotation == 0)
         {
            _loc19_ = 0;
            if(this._labelPlacement.staggered)
            {
               _loc19_ = _loc10_ * this._maxLabelHeight * Number(!!this._inverted ? -1 : 1);
            }
            if(this._inverted)
            {
               _loc3_ = (_loc4_ = _loc9_ - _loc17_ - this._maxLabelHeight * _loc10_) - _loc19_;
            }
            else
            {
               _loc3_ = (_loc4_ = _loc9_ + _loc17_) + this._maxLabelHeight * _loc10_ + _loc19_;
            }
            _loc20_ = 0;
            _loc15_ = 0;
            while(_loc15_ < _loc11_)
            {
               (_loc21_ = this._labels[_loc15_]).instance.rotation = 0;
               _loc21_.instance.x = this._gutters.left + _loc16_ * _loc21_.position - _loc21_.width * _loc10_ * _loc18_;
               _loc21_.instance.y = _loc4_ + _loc20_ * _loc19_;
               _loc20_ = 1 - _loc20_;
               _loc15_++;
            }
         }
         else if(this._labelPlacement.rotation > 0)
         {
            _loc5_ = 2 + Math.sin(this._labelPlacement.rotation) * _loc8_.height * _loc10_ / 2;
            if(this._inverted)
            {
               _loc4_ = _loc9_ - _loc17_;
               if(this._horizontal)
               {
                  _loc7_ = this._labelPlacement.rotation / Math.PI * 180;
                  _loc22_ = Math.cos(Math.abs(this._labelPlacement.rotation));
                  _loc23_ = Math.sin(Math.abs(this._labelPlacement.rotation));
                  _loc18_ = 1 - _loc18_;
                  _loc15_ = 0;
                  while(_loc15_ < _loc11_)
                  {
                     (_loc6_ = this._labels[_loc15_]).instance.rotation = _loc7_;
                     _loc6_.instance.x = this._gutters.left + _loc16_ * _loc6_.position - _loc6_.width * _loc10_ * _loc22_ + _loc6_.height * _loc18_ * _loc10_ * _loc23_;
                     _loc6_.instance.y = _loc4_ - _loc6_.width * _loc10_ * _loc23_ - _loc6_.height * _loc18_ * _loc10_ * _loc22_;
                     _loc15_++;
                  }
                  _loc3_ = _loc4_ - this._maxRotatedLabelHeight;
               }
               else
               {
                  _loc7_ = -90 - (90 - this._labelPlacement.rotation / Math.PI * 180);
                  _loc22_ = Math.cos(Math.abs(this._labelPlacement.rotation));
                  _loc23_ = Math.sin(Math.abs(this._labelPlacement.rotation));
                  _loc15_ = 0;
                  while(_loc15_ < _loc11_)
                  {
                     (_loc6_ = this._labels[_loc15_]).instance.rotation = _loc7_;
                     _loc6_.instance.x = this._gutters.left + _loc16_ * _loc6_.position - _loc6_.height * _loc18_ * _loc10_ * _loc23_;
                     _loc6_.instance.y = _loc4_ + _loc6_.height * _loc18_ * _loc10_ * _loc22_;
                     _loc15_++;
                  }
                  _loc3_ = _loc4_ - this._maxRotatedLabelHeight;
               }
            }
            else
            {
               _loc22_ = Math.cos(Math.abs(this._labelPlacement.rotation));
               _loc23_ = Math.sin(Math.abs(this._labelPlacement.rotation));
               _loc7_ = -this._labelPlacement.rotation / Math.PI * 180;
               _loc4_ = _loc9_ + _loc17_;
               try
               {
                  if(ApplicationDomain.currentDomain.getDefinition("spark.components.Label"))
                  {
                     _loc24_ = Class(ApplicationDomain.currentDomain.getDefinition("spark.components.Label"));
                  }
               }
               catch(e:Error)
               {
               }
               _loc15_ = 0;
               while(_loc15_ < _loc11_)
               {
                  (_loc6_ = this._labels[_loc15_]).instance.rotation = _loc7_;
                  _loc6_.instance.x = this._gutters.left + _loc16_ * _loc6_.position - _loc6_.width * _loc10_ * _loc22_ - _loc6_.height * _loc18_ * _loc10_ * _loc23_;
                  _loc6_.instance.y = _loc4_ + _loc6_.width * _loc10_ * _loc23_ - _loc6_.height * _loc18_ * _loc10_ * _loc22_;
                  if(_loc24_ && _loc6_.instance is _loc24_ && layoutDirection == LayoutDirection.RTL)
                  {
                     _loc6_.instance.x -= _loc6_.width;
                     _loc6_.instance.y = _loc4_;
                  }
                  _loc15_++;
               }
               _loc3_ = _loc4_ + this._maxRotatedLabelHeight;
            }
         }
         else if(this._inverted)
         {
            if(this._horizontal)
            {
               _loc7_ = this._labelPlacement.rotation / Math.PI * 180;
               _loc22_ = Math.cos(Math.abs(this._labelPlacement.rotation));
               _loc23_ = Math.sin(Math.abs(this._labelPlacement.rotation));
               _loc4_ = _loc9_ - _loc17_;
               _loc15_ = 0;
               while(_loc15_ < _loc11_)
               {
                  (_loc6_ = this._labels[_loc15_]).instance.rotation = _loc7_;
                  _loc6_.instance.x = this._gutters.left + _loc16_ * _loc6_.position - _loc6_.height * _loc18_ * _loc10_ * _loc23_;
                  _loc6_.instance.y = _loc4_ - _loc6_.height * _loc18_ * _loc10_ * _loc22_;
                  _loc15_++;
               }
               _loc3_ = _loc4_ + this._maxRotatedLabelHeight;
            }
            else
            {
               _loc7_ = this._labelPlacement.rotation / Math.PI * 180;
               _loc22_ = Math.cos(Math.abs(this._labelPlacement.rotation));
               _loc23_ = Math.sin(Math.abs(this._labelPlacement.rotation));
               _loc4_ = _loc9_ - _loc17_;
               _loc15_ = 0;
               while(_loc15_ < _loc11_)
               {
                  (_loc6_ = this._labels[_loc15_]).instance.rotation = _loc7_;
                  _loc6_.instance.x = this._gutters.left + _loc16_ * _loc6_.position - _loc6_.height * _loc18_ * _loc10_ * _loc23_;
                  _loc6_.instance.y = _loc4_ - _loc6_.height * _loc18_ * _loc10_ * _loc22_;
                  _loc15_++;
               }
            }
         }
         else if(this._horizontal)
         {
            _loc7_ = -this._labelPlacement.rotation / Math.PI * 180;
            _loc22_ = Math.cos(Math.abs(this._labelPlacement.rotation));
            _loc23_ = Math.sin(Math.abs(this._labelPlacement.rotation));
            _loc4_ = _loc9_ + _loc17_;
            _loc15_ = 0;
            while(_loc15_ < _loc11_)
            {
               (_loc6_ = this._labels[_loc15_]).instance.rotation = _loc7_;
               _loc6_.instance.x = this._gutters.left + _loc16_ * _loc6_.position + _loc23_ * _loc6_.height * _loc10_ * _loc18_;
               _loc6_.instance.y = _loc4_ - _loc22_ * _loc6_.height * _loc10_ * _loc18_;
               _loc15_++;
            }
            _loc3_ = _loc4_ + this._maxRotatedLabelHeight;
         }
         else
         {
            _loc7_ = -180 - this._labelPlacement.rotation / Math.PI * 180;
            _loc22_ = Math.cos(Math.abs(this._labelPlacement.rotation + Math.PI / 2));
            _loc23_ = Math.sin(Math.abs(this._labelPlacement.rotation + Math.PI / 2));
            _loc4_ = _loc9_ + _loc17_;
            _loc15_ = 0;
            while(_loc15_ < _loc11_)
            {
               (_loc6_ = this._labels[_loc15_]).instance.rotation = _loc7_;
               _loc6_.instance.x = this._gutters.left + _loc16_ * _loc6_.position - _loc6_.height * _loc18_ * _loc10_ * _loc22_ + _loc6_.width * _loc10_ * _loc23_;
               _loc6_.instance.y = _loc4_ + _loc6_.height * _loc18_ * _loc10_ * _loc23_ + _loc6_.width * _loc10_ * _loc22_;
               _loc15_++;
            }
            _loc3_ = _loc4_ + this._maxRotatedLabelHeight;
         }
         return _loc3_;
      }
      
      private function renderLabels() : void
      {
         var _loc2_:int = 0;
         var _loc3_:ARLabelData = null;
         var _loc6_:Class = null;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         var _loc1_:int = 0;
         var _loc4_:Object;
         var _loc5_:Boolean = (_loc4_ = getStyle("showLabels")) != false && _loc4_ != "false";
         try
         {
            if(ApplicationDomain.currentDomain.getDefinition("spark.components.Label"))
            {
               _loc6_ = Class(ApplicationDomain.currentDomain.getDefinition("spark.components.Label"));
            }
         }
         catch(e:Error)
         {
         }
         if(_loc5_ == false)
         {
            this._labelCache.count = 0;
         }
         else
         {
            this._labelCache.count = this._labels.length;
            _loc7_ = this._labels.length;
            if(!this._labelRenderer)
            {
               _loc2_ = 0;
               while(_loc2_ < _loc7_)
               {
                  _loc3_ = this._labels[_loc2_];
                  _loc3_.instance = this._labelCache.instances[_loc1_++];
                  if((_loc8_ = _loc3_.instance).hasOwnProperty("htmlText"))
                  {
                     _loc8_.htmlText = _loc3_.text;
                  }
                  else
                  {
                     _loc8_.text = _loc3_.text;
                  }
                  if(_loc6_ && _loc3_.instance is _loc6_)
                  {
                     _loc8_.setStyle("paddingTop",5);
                     _loc8_.setStyle("paddingLeft",2);
                  }
                  _loc3_.instance.width = _loc3_.width;
                  _loc3_.instance.height = _loc3_.height;
                  _loc2_++;
               }
            }
            else
            {
               while(_loc2_ < _loc7_)
               {
                  _loc3_ = this._labels[_loc2_];
                  _loc3_.instance = this._labelCache.instances[_loc1_++];
                  (_loc3_.instance as IDataRenderer).data = _loc3_.value;
                  (_loc3_.instance as IFlexDisplayObject).setActualSize(_loc3_.width * this._labelPlacement.scale,_loc3_.height * this._labelPlacement.scale);
                  _loc2_++;
               }
            }
         }
      }
      
      private function drawTitle(param1:Number) : void
      {
         if(this._axis.title == "")
         {
            if(this._titleField)
            {
               this._titleField.visible = false;
            }
            return;
         }
         this._titleField.visible = true;
         this._titleField.setActualSize(this._titleField.measuredWidth,this._titleField.measuredHeight);
         var _loc2_:Matrix = this._titleField.transform.matrix;
         _loc2_.a = Math.min(1,(unscaledWidth - this._gutters.left - this._gutters.right) / this._titleField.measuredWidth);
         if(_loc2_.a < 0)
         {
            _loc2_.a = 0;
         }
         _loc2_.d = Math.min(1,1.3 * _loc2_.a);
         this._titleField.transform.matrix = _loc2_;
         this._titleField.y = Number(!!this._inverted ? param1 - this._titleField.measuredHeight : param1);
         this._titleField.x = this._gutters.left + (unscaledWidth - this._gutters.left - this._gutters.right - this._titleField.measuredWidth * _loc2_.a) / 2;
      }
      
      private function drawAxis(param1:Boolean) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:IAxisRenderer = null;
         var _loc10_:IStroke = null;
         var _loc11_:Boolean = false;
         var _loc12_:String = null;
         var _loc2_:IStroke = getStyle("axisStroke");
         if(param1 == true)
         {
            _loc3_ = Number(_loc2_.weight == 0 ? 1 : _loc2_.weight);
            _loc4_ = Number(!!this._inverted ? this._gutters.top - _loc3_ : unscaledHeight - this._gutters.bottom);
            graphics.lineStyle(0,0,0);
            _loc5_ = 0;
            _loc6_ = 0;
            if(this._horizontal && this._otherAxes)
            {
               _loc7_ = this._otherAxes.length;
               _loc8_ = 0;
               while(_loc8_ < _loc7_)
               {
                  if((_loc9_ = this._otherAxes[_loc8_]) is AxisRenderer)
                  {
                     _loc10_ = AxisRenderer(_loc9_).getStyle("axisStroke");
                     _loc11_ = AxisRenderer(_loc9_).getStyle("showLine");
                  }
                  _loc12_ = _loc9_.placement;
                  if(_loc10_ && _loc11_)
                  {
                     if(_loc12_ == "right" || _loc12_ == "top")
                     {
                        _loc6_ += _loc10_.weight;
                     }
                     else
                     {
                        _loc5_ += _loc10_.weight;
                     }
                  }
                  _loc8_++;
               }
            }
            graphics.moveTo(this._gutters.left - _loc5_,_loc4_ + _loc3_ / 2);
            _loc2_.apply(graphics,null,null);
            graphics.lineTo(unscaledWidth - this._gutters.right + _loc6_,_loc4_ + _loc3_ / 2);
         }
      }
      
      private function drawTicks(param1:Boolean) : Number
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc18_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:Array = null;
         var _loc2_:IStroke = getStyle("axisStroke");
         var _loc3_:Number = Number(param1 == true ? _loc2_.weight : 0);
         var _loc4_:Number = Number(!!this._inverted ? this._gutters.top : unscaledHeight - this._gutters.bottom);
         var _loc13_:Number = getStyle("tickLength");
         var _loc14_:String = getStyle("tickPlacement");
         if(this._inverted)
         {
            _loc13_ *= -1;
            _loc3_ *= -1;
         }
         var _loc16_:IStroke = getStyle("tickStroke");
         switch(_loc14_)
         {
            case "inside":
               _loc11_ = _loc4_ - _loc13_;
               _loc12_ = _loc4_;
               break;
            case "outside":
            default:
               _loc11_ = _loc4_ + _loc3_;
               _loc12_ = _loc4_ + _loc3_ + _loc13_;
               break;
            case "cross":
               _loc11_ = _loc4_ - _loc13_;
               _loc12_ = _loc4_ + _loc3_ + _loc13_;
               break;
            case "none":
               _loc11_ = 0;
               _loc12_ = 0;
         }
         var _loc17_:int = this._ticks.length;
         _loc9_ = this._gutters.left;
         _loc10_ = unscaledWidth - this._gutters.left - this._gutters.right;
         var _loc19_:Graphics = graphics;
         if(_loc11_ != _loc12_)
         {
            _loc15_ = _loc16_.weight;
            _loc16_.weight = this._labelPlacement.scale * Number(_loc16_.weight == 0 ? 1 : _loc16_.weight);
            _loc16_.apply(_loc19_,null,null);
            _loc16_.weight = _loc15_;
            _loc18_ = _loc17_;
            _loc21_ = 0;
            while(_loc21_ < _loc18_)
            {
               _loc7_ = _loc9_ + _loc10_ * this._ticks[_loc21_];
               _loc19_.moveTo(_loc7_,_loc11_);
               _loc19_.lineTo(_loc7_,_loc12_);
               _loc21_++;
            }
         }
         var _loc20_:IStroke = getStyle("minorTickStroke");
         _loc9_ = this._gutters.left;
         _loc10_ = unscaledWidth - this._gutters.left - this._gutters.right;
         _loc13_ = getStyle("minorTickLength");
         _loc14_ = getStyle("minorTickPlacement");
         _loc11_ = _loc12_ = 0;
         if(this._inverted)
         {
            _loc13_ *= -1;
         }
         switch(_loc14_)
         {
            case "inside":
               _loc11_ = _loc4_ - _loc13_;
               _loc12_ = _loc4_;
               break;
            case "outside":
            default:
               _loc11_ = _loc4_ + _loc3_;
               _loc12_ = _loc4_ + _loc3_ + _loc13_;
               break;
            case "cross":
               _loc11_ = _loc4_ - _loc13_;
               _loc12_ = _loc4_ + _loc3_ + _loc13_;
               break;
            case "none":
               _loc11_ = 0;
               _loc12_ = 0;
         }
         if(_loc11_ != _loc12_)
         {
            _loc17_ = !!(_loc22_ = this._minorTicks) ? int(_loc22_.length) : 0;
            _loc15_ = _loc20_.weight;
            _loc20_.weight = this._labelPlacement.scale * Number(_loc20_.weight == 0 ? 1 : _loc20_.weight);
            _loc20_.apply(_loc19_,null,null);
            _loc20_.weight = _loc15_;
            _loc18_ = _loc17_;
            _loc21_ = 0;
            while(_loc21_ < _loc18_)
            {
               _loc7_ = _loc9_ + _loc10_ * _loc22_[_loc21_];
               _loc19_.moveTo(_loc7_,_loc11_);
               _loc19_.lineTo(_loc7_,_loc12_);
               _loc21_++;
            }
         }
         return _loc4_ + _loc12_;
      }
      
      private function get labelAlignOffset() : Number
      {
         var _loc1_:Number = NaN;
         var _loc2_:String = getStyle("labelAlign");
         switch(_loc2_)
         {
            case "left":
            case "top":
               _loc1_ = 1;
               break;
            case "right":
            case "bottom":
               _loc1_ = 0;
               break;
            case "center":
            default:
               _loc1_ = 0.5;
         }
         return _loc1_;
      }
      
      private function updateRotation() : void
      {
         rotation = Number(!!this._horizontal ? 0 : 90);
      }
      
      private function processAxisLabels(param1:AxisLabelSet) : Boolean
      {
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         var _loc8_:AxisLabel = null;
         var _loc9_:ARLabelData = null;
         var _loc10_:ISystemManager = null;
         var _loc11_:IUITextField = null;
         var _loc12_:UITextFormat = null;
         var _loc13_:IUIComponent = null;
         var _loc14_:ILayoutManagerClient = null;
         var _loc15_:IDataRenderer = null;
         var _loc16_:int = 0;
         var _loc17_:Array = null;
         var _loc3_:Array = [];
         var _loc4_:* = this._labelRenderer != null;
         ++this._supressInvalidations;
         _loc2_ = param1.labels.length;
         this._labels = [];
         _loc5_ = 0;
         while(_loc5_ < _loc2_)
         {
            _loc3_.push(param1.labels[_loc5_].text);
            _loc5_++;
         }
         if(param1 != this._axisLabelSet)
         {
            if(this._labelFunction != null)
            {
               _loc3_ = [];
               _loc5_ = 0;
               while(_loc5_ < _loc2_)
               {
                  _loc3_.push(this._labelFunction(this,param1.labels[_loc5_].text));
                  _loc5_++;
               }
            }
         }
         var _loc6_:Number = 0;
         var _loc7_:Number = 0;
         if(!_loc4_)
         {
            _loc10_ = systemManager as ISystemManager;
            _loc11_ = this._measuringField as IUITextField;
            if(!this._measuringField)
            {
               _loc11_ = IUITextField(createInFontContext(UITextField));
               this._measuringField = DisplayObject(_loc11_);
            }
            _loc12_ = determineTextFormatFromStyles();
            _loc11_.defaultTextFormat = _loc12_;
            _loc11_.setTextFormat(_loc12_);
            _loc11_.multiline = true;
            _loc11_.antiAliasType = _loc12_.antiAliasType;
            _loc11_.gridFitType = _loc12_.gridFitType;
            _loc11_.sharpness = _loc12_.sharpness;
            _loc11_.thickness = _loc12_.thickness;
            _loc11_.autoSize = "left";
            _loc11_.embedFonts = _loc10_ && _loc10_.isFontFaceEmbedded(_loc12_);
         }
         else
         {
            if(!(_loc13_ = this._measuringField as IUIComponent))
            {
               _loc13_ = this._labelRenderer.newInstance();
               this._measuringField = _loc13_ as DisplayObject;
               if(_loc13_ is ISimpleStyleClient)
               {
                  (_loc13_ as ISimpleStyleClient).styleName = this;
               }
               _loc13_.visible = false;
               addChild(DisplayObject(_loc13_));
            }
            _loc14_ = _loc13_ as ILayoutManagerClient;
            _loc15_ = _loc13_ as IDataRenderer;
         }
         if(this._horizontal)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc2_)
            {
               _loc8_ = param1.labels[_loc5_];
               _loc9_ = new ARLabelData(_loc8_,_loc8_.position,_loc3_[_loc5_]);
               if(!_loc4_)
               {
                  _loc11_.htmlText = _loc3_[_loc5_];
                  _loc9_.width = _loc11_.width + 5;
                  _loc9_.height = _loc11_.height;
               }
               else
               {
                  _loc15_.data = _loc8_;
                  if(_loc14_)
                  {
                     _loc14_.validateSize(true);
                  }
                  _loc9_.width = _loc13_.measuredWidth + 5;
                  _loc9_.height = _loc13_.measuredHeight;
               }
               _loc6_ = Math.max(_loc6_,_loc9_.width);
               _loc7_ = Math.max(_loc7_,_loc9_.height);
               this._labels[_loc5_] = _loc9_;
               _loc5_++;
            }
            this._ticks = param1.ticks == null ? [] : param1.ticks;
            this._minorTicks = param1.minorTicks == null ? [] : param1.minorTicks;
         }
         else
         {
            _loc16_ = _loc2_ - 1;
            _loc5_ = 0;
            while(_loc5_ < _loc2_)
            {
               _loc8_ = param1.labels[_loc5_];
               _loc9_ = new ARLabelData(_loc8_,1 - _loc8_.position,_loc3_[_loc5_]);
               if(!_loc4_)
               {
                  _loc11_.htmlText = _loc3_[_loc5_];
                  _loc9_.width = _loc11_.width + 5;
                  _loc9_.height = _loc11_.height;
               }
               else
               {
                  _loc15_.data = _loc8_;
                  if(_loc14_)
                  {
                     _loc14_.validateSize(true);
                  }
                  _loc9_.width = _loc13_.measuredWidth + 5;
                  _loc9_.height = _loc13_.measuredHeight;
               }
               _loc6_ = Math.max(_loc6_,_loc9_.width);
               _loc7_ = Math.max(_loc7_,_loc9_.height);
               this._labels[_loc16_ - _loc5_] = _loc9_;
               _loc5_++;
            }
            this._ticks = [];
            if(param1.ticks)
            {
               _loc2_ = (_loc17_ = param1.ticks).length;
               _loc5_ = _loc2_ - 1;
               while(_loc5_ >= 0)
               {
                  this._ticks.push(1 - _loc17_[_loc5_]);
                  _loc5_--;
               }
            }
            this._minorTicks = [];
            if(param1.minorTicks)
            {
               _loc2_ = (_loc17_ = param1.minorTicks).length;
               _loc5_ = _loc2_ - 1;
               while(_loc5_ >= 0)
               {
                  this._minorTicks.push(1 - _loc17_[_loc5_]);
                  _loc5_--;
               }
            }
         }
         this._maxLabelWidth = _loc6_;
         this._maxLabelHeight = _loc7_;
         this._forceLabelUpdate = false;
         --this._supressInvalidations;
         return param1.accurate == true;
      }
      
      private function reduceLabels(param1:AxisLabel, param2:AxisLabel) : Boolean
      {
         var _loc3_:AxisLabelSet = this._axis.reduceLabels(param1,param2);
         if(!_loc3_ || _loc3_ == this._axisLabelSet || _loc3_.labels.length >= this._axisLabelSet.labels.length)
         {
            return false;
         }
         this.processAxisLabels(_loc3_);
         this._axisLabelSet = _loc3_;
         return true;
      }
      
      private function tickSize(param1:Boolean) : Number
      {
         var _loc2_:Number = getStyle("tickLength");
         var _loc3_:String = getStyle("tickPlacement");
         var _loc4_:IStroke = getStyle("axisStroke");
         var _loc5_:Number = 0;
         switch(_loc3_)
         {
            case "cross":
               if(param1)
               {
                  _loc5_ = _loc2_ + _loc4_.weight;
               }
               else
               {
                  _loc5_ = _loc2_;
               }
               break;
            case "inside":
               _loc5_ = 0;
               break;
            case "none":
               _loc5_ = 0;
               break;
            case "outside":
            default:
               _loc5_ = _loc2_;
         }
         return _loc5_;
      }
      
      mx_internal function getAxisLabelSet() : AxisLabelSet
      {
         return this._axisLabelSet;
      }
      
      private function setupMouseDispatching() : void
      {
         if(this._highlightElements)
         {
            addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
            addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
            addEventListener(MouseEvent.MOUSE_MOVE,this.mouseOverHandler);
         }
         else
         {
            removeEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
            removeEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
            removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseOverHandler);
         }
      }
      
      private function axisChangeHandler(param1:Event) : void
      {
         if(this.chart)
         {
            this.chart.invalidateDisplayList();
         }
         this.invalidateDisplayList();
      }
      
      private function titleChangeHandler(param1:Event) : void
      {
         if(this.chart)
         {
            this.chart.invalidateDisplayList();
         }
         this.invalidateDisplayList();
      }
      
      private function mouseOutHandler(param1:MouseEvent) : void
      {
         AxisBase(this._axis).highlightElements(false);
      }
      
      private function mouseOverHandler(param1:MouseEvent) : void
      {
         AxisBase(this._axis).highlightElements(true);
      }
   }
}

import flash.display.DisplayObject;
import mx.charts.AxisLabel;

class ARLabelData
{
    
   
   public var value:AxisLabel;
   
   public var position:Number;
   
   public var width:Number;
   
   public var height:Number;
   
   public var instance:DisplayObject;
   
   public var text:String;
   
   function ARLabelData(param1:AxisLabel, param2:Number, param3:String)
   {
      super();
      this.value = param1;
      this.position = param2;
      this.text = param3;
   }
}
