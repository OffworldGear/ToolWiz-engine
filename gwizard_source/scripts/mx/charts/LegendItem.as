package mx.charts
{
   import flash.display.DisplayObject;
   import flash.geom.Rectangle;
   import mx.charts.chartClasses.IChartElement;
   import mx.charts.renderers.BoxItemRenderer;
   import mx.core.IDataRenderer;
   import mx.core.IFactory;
   import mx.core.IFlexDisplayObject;
   import mx.core.IFlexModuleFactory;
   import mx.core.IUITextField;
   import mx.core.UIComponent;
   import mx.core.UITextField;
   import mx.core.mx_internal;
   import mx.styles.ISimpleStyleClient;
   
   use namespace mx_internal;
   
   public class LegendItem extends UIComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _moduleFactoryInitialized:Boolean = false;
      
      private var nameLabel:IUITextField;
      
      private var labelChanged:Boolean = false;
      
      public var element:IChartElement;
      
      private var _label:String = "";
      
      private var _legendData:Object;
      
      private var _marker:IFlexDisplayObject;
      
      public var markerAspectRatio:Number;
      
      public function LegendItem()
      {
         super();
      }
      
      public function get label() : String
      {
         return this._label;
      }
      
      public function set label(param1:String) : void
      {
         this._label = param1;
         this.labelChanged = true;
         invalidateSize();
         invalidateDisplayList();
      }
      
      public function set legendData(param1:Object) : void
      {
         this._legendData = param1;
         if(this._marker is IDataRenderer)
         {
            (this._marker as IDataRenderer).data = this._legendData;
         }
      }
      
      public function get marker() : IFlexDisplayObject
      {
         return this._marker;
      }
      
      public function set marker(param1:IFlexDisplayObject) : void
      {
         if(this._marker)
         {
            removeChild(this._marker as DisplayObject);
         }
         this._marker = param1;
         if(this._marker)
         {
            addChild(this._marker as DisplayObject);
         }
         if(this._marker is IDataRenderer)
         {
            (this._marker as IDataRenderer).data = this._legendData;
         }
         invalidateDisplayList();
      }
      
      public function get source() : Object
      {
         return this.element;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         if(this._moduleFactoryInitialized)
         {
            return;
         }
         this._moduleFactoryInitialized = true;
      }
      
      override protected function createChildren() : void
      {
         this.nameLabel = IUITextField(createInFontContext(UITextField));
         this.nameLabel.selectable = false;
         this.nameLabel.styleName = this;
         addChild(DisplayObject(this.nameLabel));
         super.createChildren();
         if(!this.nameLabel)
         {
            this.nameLabel = IUITextField(createInFontContext(UITextField));
            this.nameLabel.selectable = false;
            this.nameLabel.styleName = this;
            addChild(DisplayObject(this.nameLabel));
         }
      }
      
      override protected function measure() : void
      {
         super.measure();
         var _loc1_:String = this._label;
         var _loc2_:String = getStyle("labelPlacement");
         if(_loc2_ == "" && parent)
         {
            _loc2_ = UIComponent(parent).getStyle("labelPlacement");
         }
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         if(_loc1_ == null || _loc1_ == "" || _loc1_.length < 2)
         {
            _loc1_ = "Wj";
         }
         if(this.labelChanged)
         {
            this.labelChanged = false;
            this.nameLabel.htmlText = this._label;
         }
         var _loc5_:Number = this.nameLabel.textWidth + UITextField.TEXT_WIDTH_PADDING;
         var _loc6_:Number = this.nameLabel.textHeight + UITextField.TEXT_HEIGHT_PADDING;
         if(isNaN(_loc5_))
         {
            _loc5_ = 0;
         }
         if(isNaN(_loc6_))
         {
            _loc6_ = 0;
         }
         if(_loc5_ > 0 || this.calculateMarkerWidth() > 0)
         {
            _loc3_ += getStyle("paddingLeft") + getStyle("paddingRight");
            _loc4_ += getStyle("paddingTop") + getStyle("paddingBottom");
            if(_loc2_ == "top" || _loc2_ == "bottom")
            {
               _loc3_ += Math.max(_loc5_,this.calculateMarkerWidth());
               _loc4_ += getStyle("verticalGap") + this.calculateMarkerHeight() + _loc6_;
            }
            else
            {
               _loc3_ += getStyle("horizontalGap") + this.calculateMarkerWidth() + _loc5_;
               _loc4_ += Math.max(_loc6_,this.calculateMarkerHeight());
            }
         }
         measuredWidth = _loc3_;
         measuredHeight = _loc4_;
         this.nameLabel.setActualSize(getExplicitOrMeasuredWidth(),measuredHeight);
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc18_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:IFactory = null;
         super.updateDisplayList(param1,param2);
         var _loc3_:String = getStyle("labelPlacement");
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         var _loc7_:Number = 0;
         var _loc8_:Number = getStyle("paddingLeft");
         var _loc9_:Number = getStyle("paddingRight");
         var _loc10_:Number = getStyle("paddingTop");
         var _loc11_:Number = this.calculateMarkerWidth();
         var _loc12_:Number;
         var _loc13_:Number = _loc12_ = this.calculateMarkerHeight();
         var _loc14_:Number = _loc11_;
         var _loc15_:String;
         if((_loc15_ = this._label) == null || _loc15_.length < 2)
         {
            _loc15_ = "Wj";
         }
         if(this.labelChanged)
         {
            this.labelChanged = false;
            this.nameLabel.text = this._label;
         }
         var _loc16_:Number = this.nameLabel.textWidth + UITextField.TEXT_WIDTH_PADDING;
         var _loc17_:Number = this.nameLabel.textHeight + UITextField.TEXT_HEIGHT_PADDING;
         if(isNaN(_loc16_))
         {
            _loc16_ = 0;
         }
         if(isNaN(_loc17_))
         {
            _loc17_ = 0;
         }
         switch(_loc3_)
         {
            case "top":
               _loc7_ = (_loc5_ = _loc10_) + getStyle("verticalGap") + _loc17_;
               _loc4_ = (_loc18_ = _loc8_ + (param1 - _loc8_ - _loc9_) / 2) - _loc16_ / 2;
               _loc6_ = _loc18_ - _loc14_ / 2;
               break;
            case "bottom":
               _loc5_ = (_loc7_ = _loc10_) + getStyle("verticalGap") + _loc13_;
               _loc4_ = (_loc18_ = _loc8_ + (param1 - _loc8_ - _loc9_) / 2) - _loc16_ / 2;
               _loc6_ = _loc18_ - _loc14_ / 2;
               break;
            case "left":
               _loc4_ = (_loc6_ = param1 - _loc14_ - _loc9_) - getStyle("horizontalGap") - _loc16_;
               _loc5_ = _loc7_ = _loc10_;
               if(_loc17_ < _loc13_)
               {
                  _loc5_ += (_loc13_ - _loc17_) / 2;
               }
               else
               {
                  _loc7_ += (_loc17_ - _loc13_) / 2;
               }
               break;
            default:
               _loc4_ = (_loc6_ = _loc8_) + getStyle("horizontalGap") + _loc14_;
               _loc7_ = _loc5_ = _loc10_;
               if(_loc13_ < _loc17_)
               {
                  _loc7_ += (_loc17_ - _loc13_) / 2;
               }
               else
               {
                  _loc5_ += (_loc13_ - _loc17_) / 2;
               }
         }
         this.nameLabel.move(_loc4_,_loc5_);
         if(!isNaN(this.markerAspectRatio))
         {
            if((_loc20_ = _loc14_ / _loc13_) > this.markerAspectRatio)
            {
               _loc14_ = this.markerAspectRatio * _loc13_;
            }
            else
            {
               _loc13_ = _loc14_ / this.markerAspectRatio;
            }
         }
         var _loc19_:Rectangle = new Rectangle((_loc11_ - _loc14_) / 2,(_loc12_ - _loc13_) / 2,_loc14_,_loc13_);
         if(!this._marker)
         {
            if(_loc21_ = getStyle("legendMarkerRenderer"))
            {
               this.marker = _loc21_.newInstance();
            }
            else
            {
               this.marker = new BoxItemRenderer();
            }
            if(this._marker is ISimpleStyleClient)
            {
               (this._marker as ISimpleStyleClient).styleName = !this.element ? this : this.element;
            }
         }
         this._marker.x = _loc6_ + (_loc11_ - _loc14_) / 2;
         this._marker.y = _loc7_ + (_loc12_ - _loc13_) / 2;
         this._marker.setActualSize(_loc14_,_loc13_);
      }
      
      override public function styleChanged(param1:String) : void
      {
         invalidateDisplayList();
      }
      
      private function calculateMarkerWidth() : Number
      {
         var _loc1_:Number = getStyle("markerWidth");
         if(isNaN(_loc1_))
         {
            _loc1_ = 10;
         }
         return _loc1_;
      }
      
      private function calculateMarkerHeight() : Number
      {
         var _loc1_:Number = getStyle("markerHeight");
         if(isNaN(_loc1_))
         {
            _loc1_ = 15;
         }
         return _loc1_;
      }
   }
}
