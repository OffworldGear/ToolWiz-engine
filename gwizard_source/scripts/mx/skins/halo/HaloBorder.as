package mx.skins.halo
{
   import flash.display.GradientType;
   import flash.display.Graphics;
   import mx.core.EdgeMetrics;
   import mx.core.IUIComponent;
   import mx.core.mx_internal;
   import mx.graphics.RectangularDropShadow;
   import mx.skins.RectangularBorder;
   import mx.styles.IStyleClient;
   import mx.utils.ColorUtil;
   
   use namespace mx_internal;
   
   public class HaloBorder extends RectangularBorder
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static var BORDER_WIDTHS:Object = {
         "none":0,
         "solid":1,
         "inset":2,
         "outset":2,
         "alert":3,
         "dropdown":2,
         "menuBorder":1,
         "comboNonEdit":2
      };
       
      
      private var dropShadow:RectangularDropShadow;
      
      mx_internal var backgroundColor:Object;
      
      mx_internal var backgroundAlphaName:String;
      
      mx_internal var backgroundHole:Object;
      
      mx_internal var bRoundedCorners:Boolean;
      
      mx_internal var radius:Number;
      
      mx_internal var radiusObj:Object;
      
      protected var _borderMetrics:EdgeMetrics;
      
      public function HaloBorder()
      {
         super();
         BORDER_WIDTHS["default"] = 3;
      }
      
      override public function get borderMetrics() : EdgeMetrics
      {
         var _loc1_:Number = NaN;
         var _loc3_:String = null;
         if(this._borderMetrics)
         {
            return this._borderMetrics;
         }
         var _loc2_:String = getStyle("borderStyle");
         if(_loc2_ == "default" || _loc2_ == "alert")
         {
            return EdgeMetrics.EMPTY;
         }
         if(_loc2_ == "controlBar" || _loc2_ == "applicationControlBar")
         {
            this._borderMetrics = new EdgeMetrics(1,1,1,1);
         }
         else if(_loc2_ == "solid")
         {
            _loc1_ = getStyle("borderThickness");
            if(isNaN(_loc1_))
            {
               _loc1_ = 0;
            }
            this._borderMetrics = new EdgeMetrics(_loc1_,_loc1_,_loc1_,_loc1_);
            _loc3_ = getStyle("borderSides");
            if(_loc3_ != "left top right bottom")
            {
               if(_loc3_.indexOf("left") == -1)
               {
                  this._borderMetrics.left = 0;
               }
               if(_loc3_.indexOf("top") == -1)
               {
                  this._borderMetrics.top = 0;
               }
               if(_loc3_.indexOf("right") == -1)
               {
                  this._borderMetrics.right = 0;
               }
               if(_loc3_.indexOf("bottom") == -1)
               {
                  this._borderMetrics.bottom = 0;
               }
            }
         }
         else
         {
            _loc1_ = BORDER_WIDTHS[_loc2_];
            if(isNaN(_loc1_))
            {
               _loc1_ = 0;
            }
            this._borderMetrics = new EdgeMetrics(_loc1_,_loc1_,_loc1_,_loc1_);
         }
         return this._borderMetrics;
      }
      
      override public function styleChanged(param1:String) : void
      {
         super.styleChanged(param1);
         if(param1 == null || param1 == "styleName" || param1 == "borderStyle" || param1 == "borderThickness" || param1 == "borderSides")
         {
            this._borderMetrics = null;
         }
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         if(isNaN(param1) || isNaN(param2))
         {
            return;
         }
         super.updateDisplayList(param1,param2);
         this.backgroundColor = this.getBackgroundColor();
         this.bRoundedCorners = false;
         this.backgroundAlphaName = "backgroundAlpha";
         this.backgroundHole = null;
         this.radius = 0;
         this.radiusObj = null;
         this.drawBorder(param1,param2);
         this.drawBackground(param1,param2);
      }
      
      mx_internal function drawBorder(param1:Number, param2:Number) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:String = null;
         var _loc9_:Number = NaN;
         var _loc10_:uint = 0;
         var _loc11_:Boolean = false;
         var _loc12_:uint = 0;
         var _loc13_:Array = null;
         var _loc14_:Array = null;
         var _loc15_:uint = 0;
         var _loc16_:uint = 0;
         var _loc17_:uint = 0;
         var _loc18_:uint = 0;
         var _loc19_:Boolean = false;
         var _loc20_:Object = null;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Object = null;
         var _loc27_:* = false;
         var _loc28_:Number = NaN;
         var _loc29_:Array = null;
         var _loc30_:uint = 0;
         var _loc31_:Boolean = false;
         var _loc32_:Number = NaN;
         var _loc3_:String = getStyle("borderStyle");
         var _loc4_:Array = getStyle("highlightAlphas");
         var _loc21_:Boolean = false;
         var _loc26_:Graphics;
         (_loc26_ = graphics).clear();
         if(_loc3_)
         {
            switch(_loc3_)
            {
               case "none":
                  break;
               case "inset":
                  _loc7_ = getStyle("borderColor");
                  _loc22_ = ColorUtil.adjustBrightness2(_loc7_,-40);
                  _loc23_ = ColorUtil.adjustBrightness2(_loc7_,25);
                  _loc24_ = ColorUtil.adjustBrightness2(_loc7_,40);
                  if((_loc25_ = this.backgroundColor) === null || _loc25_ === "")
                  {
                     _loc25_ = _loc7_;
                  }
                  this.draw3dBorder(_loc23_,_loc22_,_loc24_,Number(_loc25_),Number(_loc25_),Number(_loc25_));
                  break;
               case "outset":
                  _loc7_ = getStyle("borderColor");
                  _loc22_ = ColorUtil.adjustBrightness2(_loc7_,-40);
                  _loc23_ = ColorUtil.adjustBrightness2(_loc7_,-25);
                  _loc24_ = ColorUtil.adjustBrightness2(_loc7_,40);
                  if((_loc25_ = this.backgroundColor) === null || _loc25_ === "")
                  {
                     _loc25_ = _loc7_;
                  }
                  this.draw3dBorder(_loc23_,_loc24_,_loc22_,Number(_loc25_),Number(_loc25_),Number(_loc25_));
                  break;
               case "alert":
               case "default":
                  break;
               case "dropdown":
                  _loc12_ = getStyle("dropdownBorderColor");
                  this.drawDropShadow(0,0,param1,param2,4,0,0,4);
                  drawRoundRect(0,0,param1,param2,{
                     "tl":4,
                     "tr":0,
                     "br":0,
                     "bl":4
                  },5068126,1);
                  drawRoundRect(0,0,param1,param2,{
                     "tl":4,
                     "tr":0,
                     "br":0,
                     "bl":4
                  },[16777215,16777215],[0.7,0],verticalGradientMatrix(0,0,param1,param2));
                  drawRoundRect(1,1,param1 - 1,param2 - 2,{
                     "tl":3,
                     "tr":0,
                     "br":0,
                     "bl":3
                  },16777215,1);
                  drawRoundRect(1,2,param1 - 1,param2 - 3,{
                     "tl":3,
                     "tr":0,
                     "br":0,
                     "bl":3
                  },[15658734,16777215],1,verticalGradientMatrix(0,0,param1 - 1,param2 - 3));
                  if(!isNaN(_loc12_))
                  {
                     drawRoundRect(0,0,param1 + 1,param2,{
                        "tl":4,
                        "tr":0,
                        "br":0,
                        "bl":4
                     },_loc12_,0.5);
                     drawRoundRect(1,1,param1 - 1,param2 - 2,{
                        "tl":3,
                        "tr":0,
                        "br":0,
                        "bl":3
                     },16777215,1);
                     drawRoundRect(1,2,param1 - 1,param2 - 3,{
                        "tl":3,
                        "tr":0,
                        "br":0,
                        "bl":3
                     },[15658734,16777215],1,verticalGradientMatrix(0,0,param1 - 1,param2 - 3));
                  }
                  this.backgroundColor = null;
                  break;
               case "menuBorder":
                  _loc7_ = getStyle("borderColor");
                  drawRoundRect(0,0,param1,param2,0,_loc7_,1);
                  this.drawDropShadow(1,1,param1 - 2,param2 - 2,0,0,0,0);
                  break;
               case "comboNonEdit":
                  break;
               case "controlBar":
                  if(param1 == 0 || param2 == 0)
                  {
                     this.backgroundColor = null;
                     break;
                  }
                  _loc27_ = (_loc14_ = getStyle("footerColors")) != null;
                  _loc28_ = getStyle("borderAlpha");
                  if(_loc27_)
                  {
                     _loc26_.lineStyle(0,_loc14_.length > 0 ? uint(_loc14_[1]) : uint(_loc14_[0]),_loc28_);
                     _loc26_.moveTo(0,0);
                     _loc26_.lineTo(param1,0);
                     _loc26_.lineStyle(0,0,0);
                     if(parent && parent.parent && parent.parent is IStyleClient)
                     {
                        this.radius = IStyleClient(parent.parent).getStyle("cornerRadius");
                        _loc28_ = IStyleClient(parent.parent).getStyle("borderAlpha");
                     }
                     if(isNaN(this.radius))
                     {
                        this.radius = 0;
                     }
                     if(IStyleClient(parent.parent).getStyle("roundedBottomCorners").toString().toLowerCase() != "true")
                     {
                        this.radius = 0;
                     }
                     drawRoundRect(0,1,param1,param2 - 1,{
                        "tl":0,
                        "tr":0,
                        "bl":this.radius,
                        "br":this.radius
                     },_loc14_,_loc28_,verticalGradientMatrix(0,0,param1,param2));
                     if(_loc14_.length > 1 && _loc14_[0] != _loc14_[1])
                     {
                        drawRoundRect(0,1,param1,param2 - 1,{
                           "tl":0,
                           "tr":0,
                           "bl":this.radius,
                           "br":this.radius
                        },[16777215,16777215],_loc4_,verticalGradientMatrix(0,0,param1,param2));
                        drawRoundRect(1,2,param1 - 2,param2 - 3,{
                           "tl":0,
                           "tr":0,
                           "bl":this.radius - 1,
                           "br":this.radius - 1
                        },_loc14_,_loc28_,verticalGradientMatrix(0,0,param1,param2));
                     }
                  }
                  this.backgroundColor = null;
                  break;
               case "applicationControlBar":
                  _loc13_ = getStyle("fillColors");
                  _loc5_ = getStyle("backgroundAlpha");
                  _loc4_ = getStyle("highlightAlphas");
                  _loc29_ = getStyle("fillAlphas");
                  _loc11_ = getStyle("docked");
                  _loc30_ = uint(this.backgroundColor);
                  this.radius = getStyle("cornerRadius");
                  if(!this.radius)
                  {
                     this.radius = 0;
                  }
                  this.drawDropShadow(0,1,param1,param2 - 1,this.radius,this.radius,this.radius,this.radius);
                  if(this.backgroundColor !== null && styleManager.isValidStyleValue(this.backgroundColor))
                  {
                     drawRoundRect(0,1,param1,param2 - 1,this.radius,_loc30_,_loc5_,verticalGradientMatrix(0,0,param1,param2));
                  }
                  drawRoundRect(0,1,param1,param2 - 1,this.radius,_loc13_,_loc29_,verticalGradientMatrix(0,0,param1,param2));
                  drawRoundRect(0,1,param1,param2 / 2 - 1,{
                     "tl":this.radius,
                     "tr":this.radius,
                     "bl":0,
                     "br":0
                  },[16777215,16777215],_loc4_,verticalGradientMatrix(0,0,param1,param2 / 2 - 1));
                  drawRoundRect(0,1,param1,param2 - 1,{
                     "tl":this.radius,
                     "tr":this.radius,
                     "bl":0,
                     "br":0
                  },16777215,0.3,null,GradientType.LINEAR,null,{
                     "x":0,
                     "y":2,
                     "w":param1,
                     "h":param2 - 2,
                     "r":{
                        "tl":this.radius,
                        "tr":this.radius,
                        "bl":0,
                        "br":0
                     }
                  });
                  this.backgroundColor = null;
                  break;
               default:
                  _loc7_ = getStyle("borderColor");
                  _loc9_ = getStyle("borderThickness");
                  _loc8_ = getStyle("borderSides");
                  _loc31_ = true;
                  this.radius = getStyle("cornerRadius");
                  this.bRoundedCorners = getStyle("roundedBottomCorners").toString().toLowerCase() == "true";
                  _loc32_ = Math.max(this.radius - _loc9_,0);
                  _loc20_ = {
                     "x":_loc9_,
                     "y":_loc9_,
                     "w":param1 - _loc9_ * 2,
                     "h":param2 - _loc9_ * 2,
                     "r":_loc32_
                  };
                  if(!this.bRoundedCorners)
                  {
                     this.radiusObj = {
                        "tl":this.radius,
                        "tr":this.radius,
                        "bl":0,
                        "br":0
                     };
                     _loc20_.r = {
                        "tl":_loc32_,
                        "tr":_loc32_,
                        "bl":0,
                        "br":0
                     };
                  }
                  if(_loc8_ != "left top right bottom")
                  {
                     _loc20_.r = {
                        "tl":_loc32_,
                        "tr":_loc32_,
                        "bl":(!!this.bRoundedCorners ? _loc32_ : 0),
                        "br":(!!this.bRoundedCorners ? _loc32_ : 0)
                     };
                     this.radiusObj = {
                        "tl":this.radius,
                        "tr":this.radius,
                        "bl":(!!this.bRoundedCorners ? this.radius : 0),
                        "br":(!!this.bRoundedCorners ? this.radius : 0)
                     };
                     if((_loc8_ = _loc8_.toLowerCase()).indexOf("left") == -1)
                     {
                        _loc20_.x = 0;
                        _loc20_.w += _loc9_;
                        _loc20_.r.tl = 0;
                        _loc20_.r.bl = 0;
                        this.radiusObj.tl = 0;
                        this.radiusObj.bl = 0;
                        _loc31_ = false;
                     }
                     if(_loc8_.indexOf("top") == -1)
                     {
                        _loc20_.y = 0;
                        _loc20_.h += _loc9_;
                        _loc20_.r.tl = 0;
                        _loc20_.r.tr = 0;
                        this.radiusObj.tl = 0;
                        this.radiusObj.tr = 0;
                        _loc31_ = false;
                     }
                     if(_loc8_.indexOf("right") == -1)
                     {
                        _loc20_.w += _loc9_;
                        _loc20_.r.tr = 0;
                        _loc20_.r.br = 0;
                        this.radiusObj.tr = 0;
                        this.radiusObj.br = 0;
                        _loc31_ = false;
                     }
                     if(_loc8_.indexOf("bottom") == -1)
                     {
                        _loc20_.h += _loc9_;
                        _loc20_.r.bl = 0;
                        _loc20_.r.br = 0;
                        this.radiusObj.bl = 0;
                        this.radiusObj.br = 0;
                        _loc31_ = false;
                     }
                  }
                  if(this.radius == 0 && _loc31_)
                  {
                     this.drawDropShadow(0,0,param1,param2,0,0,0,0);
                     _loc26_.beginFill(_loc7_);
                     _loc26_.drawRect(0,0,param1,param2);
                     _loc26_.drawRect(_loc9_,_loc9_,param1 - 2 * _loc9_,param2 - 2 * _loc9_);
                     _loc26_.endFill();
                  }
                  else if(this.radiusObj)
                  {
                     this.drawDropShadow(0,0,param1,param2,this.radiusObj.tl,this.radiusObj.tr,this.radiusObj.br,this.radiusObj.bl);
                     drawRoundRect(0,0,param1,param2,this.radiusObj,_loc7_,1,null,null,null,_loc20_);
                     this.radiusObj.tl = Math.max(this.radius - _loc9_,0);
                     this.radiusObj.tr = Math.max(this.radius - _loc9_,0);
                     this.radiusObj.bl = !!this.bRoundedCorners ? Math.max(this.radius - _loc9_,0) : 0;
                     this.radiusObj.br = !!this.bRoundedCorners ? Math.max(this.radius - _loc9_,0) : 0;
                  }
                  else
                  {
                     this.drawDropShadow(0,0,param1,param2,this.radius,this.radius,this.radius,this.radius);
                     drawRoundRect(0,0,param1,param2,this.radius,_loc7_,1,null,null,null,_loc20_);
                     this.radius = Math.max(getStyle("cornerRadius") - _loc9_,0);
                  }
            }
         }
      }
      
      mx_internal function draw3dBorder(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : void
      {
         var _loc7_:Number = width;
         var _loc8_:Number = height;
         this.drawDropShadow(0,0,width,height,0,0,0,0);
         var _loc9_:Graphics;
         (_loc9_ = graphics).beginFill(param1);
         _loc9_.drawRect(0,0,_loc7_,_loc8_);
         _loc9_.drawRect(1,0,_loc7_ - 2,_loc8_);
         _loc9_.endFill();
         _loc9_.beginFill(param2);
         _loc9_.drawRect(1,0,_loc7_ - 2,1);
         _loc9_.endFill();
         _loc9_.beginFill(param3);
         _loc9_.drawRect(1,_loc8_ - 1,_loc7_ - 2,1);
         _loc9_.endFill();
         _loc9_.beginFill(param4);
         _loc9_.drawRect(1,1,_loc7_ - 2,1);
         _loc9_.endFill();
         _loc9_.beginFill(param5);
         _loc9_.drawRect(1,_loc8_ - 2,_loc7_ - 2,1);
         _loc9_.endFill();
         _loc9_.beginFill(param6);
         _loc9_.drawRect(1,2,_loc7_ - 2,_loc8_ - 4);
         _loc9_.drawRect(2,2,_loc7_ - 4,_loc8_ - 4);
         _loc9_.endFill();
      }
      
      mx_internal function drawBackground(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:EdgeMetrics = null;
         var _loc6_:Graphics = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         if(this.backgroundColor !== null && this.backgroundColor !== "" || getStyle("mouseShield") || getStyle("mouseShieldChildren"))
         {
            _loc3_ = Number(this.backgroundColor);
            _loc4_ = 1;
            _loc5_ = this.getBackgroundColorMetrics();
            _loc6_ = graphics;
            if(isNaN(_loc3_) || this.backgroundColor === "" || this.backgroundColor === null)
            {
               _loc4_ = 0;
               _loc3_ = 16777215;
            }
            else
            {
               _loc4_ = getStyle(this.backgroundAlphaName);
            }
            if(this.radius != 0 || this.backgroundHole)
            {
               _loc7_ = _loc5_.bottom;
               if(this.radiusObj)
               {
                  _loc8_ = Math.max(this.radius - Math.max(_loc5_.top,_loc5_.left,_loc5_.right),0);
                  _loc9_ = !!this.bRoundedCorners ? Number(Math.max(this.radius - Math.max(_loc5_.bottom,_loc5_.left,_loc5_.right),0)) : Number(0);
                  this.radiusObj = {
                     "tl":_loc8_,
                     "tr":_loc8_,
                     "bl":_loc9_,
                     "br":_loc9_
                  };
                  drawRoundRect(_loc5_.left,_loc5_.top,width - (_loc5_.left + _loc5_.right),height - (_loc5_.top + _loc7_),this.radiusObj,_loc3_,_loc4_,null,GradientType.LINEAR,null,this.backgroundHole);
               }
               else
               {
                  drawRoundRect(_loc5_.left,_loc5_.top,width - (_loc5_.left + _loc5_.right),height - (_loc5_.top + _loc7_),this.radius,_loc3_,_loc4_,null,GradientType.LINEAR,null,this.backgroundHole);
               }
            }
            else
            {
               _loc6_.beginFill(_loc3_,_loc4_);
               _loc6_.drawRect(_loc5_.left,_loc5_.top,param1 - _loc5_.right - _loc5_.left,param2 - _loc5_.bottom - _loc5_.top);
               _loc6_.endFill();
            }
         }
      }
      
      mx_internal function drawDropShadow(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number) : void
      {
         var _loc11_:Number = NaN;
         var _loc12_:Boolean = false;
         if(getStyle("dropShadowEnabled") == false || getStyle("dropShadowEnabled") == "false" || param3 == 0 || param4 == 0)
         {
            return;
         }
         var _loc9_:Number = getStyle("shadowDistance");
         var _loc10_:String = getStyle("shadowDirection");
         if(getStyle("borderStyle") == "applicationControlBar")
         {
            _loc11_ = !!(_loc12_ = Boolean(getStyle("docked"))) ? Number(90) : Number(this.getDropShadowAngle(_loc9_,_loc10_));
            _loc9_ = Math.abs(_loc9_);
         }
         else
         {
            _loc11_ = this.getDropShadowAngle(_loc9_,_loc10_);
            _loc9_ = Math.abs(_loc9_) + 2;
         }
         if(!this.dropShadow)
         {
            this.dropShadow = new RectangularDropShadow();
         }
         this.dropShadow.distance = _loc9_;
         this.dropShadow.angle = _loc11_;
         this.dropShadow.color = getStyle("dropShadowColor");
         this.dropShadow.alpha = 0.4;
         this.dropShadow.tlRadius = param5;
         this.dropShadow.trRadius = param6;
         this.dropShadow.blRadius = param8;
         this.dropShadow.brRadius = param7;
         this.dropShadow.drawShadow(graphics,param1,param2,param3,param4);
      }
      
      mx_internal function getDropShadowAngle(param1:Number, param2:String) : Number
      {
         if(param2 == "left")
         {
            return param1 >= 0 ? Number(135) : Number(225);
         }
         if(param2 == "right")
         {
            return param1 >= 0 ? Number(45) : Number(315);
         }
         return param1 >= 0 ? Number(90) : Number(270);
      }
      
      mx_internal function getBackgroundColor() : Object
      {
         var _loc2_:Object = null;
         var _loc1_:IUIComponent = parent as IUIComponent;
         if(_loc1_ && !_loc1_.enabled)
         {
            _loc2_ = getStyle("backgroundDisabledColor");
            if(_loc2_ !== null && styleManager.isValidStyleValue(_loc2_))
            {
               return _loc2_;
            }
         }
         return getStyle("backgroundColor");
      }
      
      mx_internal function getBackgroundColorMetrics() : EdgeMetrics
      {
         return this.borderMetrics;
      }
   }
}
