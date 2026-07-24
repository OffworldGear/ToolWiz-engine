package views
{
   import comps.GWizNumStepOvr;
   import comps.GridComponent;
   import flash.display.Graphics;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import skins.GridSkin;
   import spark.components.Button;
   import spark.components.Group;
   import spark.components.Label;
   import spark.components.VGroup;
   import utils.GWizUtils;
   import utils.GraphicsUtil;
   
   use namespace mx_internal;
   
   public class GWizChordCalc extends Group implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizBoltCircles");
      
      private static const margin:int = 80;
      
      private static const defaultMessage:String = "Enter any two values.";
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _65193517Clear:Button;
      
      private var _929365368PctCirc:Label;
      
      private var _92960979angle:GWizNumStepOvr;
      
      private var _1823449986arcLenGrp:VGroup;
      
      private var _1823480792arcLength:GWizNumStepOvr;
      
      private var _2000300893chordHeight:GWizNumStepOvr;
      
      private var _50558262chordWidth:GWizNumStepOvr;
      
      private var _317504755gridArea:GridComponent;
      
      private var _1304200403messageLabel:Label;
      
      private var _938578798radius:GWizNumStepOvr;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _55173344chordRight:Number = 0;
      
      private var _1836814169chordTop:Number = 0;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizChordCalc()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizChordCalc_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_views_GWizChordCalcWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizChordCalc[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.styleName = "geoView";
         this.percentHeight = 100;
         this.percentWidth = 100;
         this.bottom = 10;
         this.left = 10;
         this.right = 10;
         this.top = 10;
         this.mxmlContent = [this._GWizChordCalc_GridComponent1_i()];
         this.addEventListener("creationComplete",this.___GWizChordCalc_Group1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizChordCalc._watcherSetupUtil = param1;
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
      
      private function restoreViewData() : void
      {
         this.recalc();
      }
      
      private function saveViewData() : void
      {
      }
      
      private function setMessage(param1:String = "Enter any two values.", param2:Boolean = false) : void
      {
         this.messageLabel.text = (!!param2 ? "Error: " : "") + param1;
         this.messageLabel.setStyle("color",!!param2 ? "red" : "0x222288");
      }
      
      private function recalc() : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         this.setMessage();
         var _loc1_:Boolean = true;
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         var _loc4_:int = 0;
         if(!this.chordWidth.isOverridden())
         {
            this.chordWidth.resetOverride(true);
         }
         else
         {
            _loc4_++;
         }
         if(!this.radius.isOverridden())
         {
            this.radius.resetOverride(true);
         }
         else
         {
            _loc4_++;
         }
         if(!this.angle.isOverridden())
         {
            this.angle.resetOverride(true);
         }
         else
         {
            _loc4_++;
         }
         if(!this.chordHeight.isOverridden())
         {
            this.chordHeight.resetOverride(true);
         }
         else
         {
            _loc4_++;
         }
         if(!this.arcLength.isOverridden())
         {
            this.arcLength.resetOverride(true);
         }
         else
         {
            _loc4_++;
         }
         if(_loc4_ > 2)
         {
            this.setMessage("Too many values.  Click locks to clear.",true);
         }
         if(_loc4_ != 2)
         {
            return;
         }
         var _loc5_:Number = !!this.angle.isOverridden() ? Number(GWizUtils.radians(this.angle.getVal() % 180)) : Number(0);
         while(_loc1_)
         {
            _loc1_ = false;
            if(_loc5_ != 0 && this.radius.getVal() != 0)
            {
               if(this.chordWidth.getVal() == 0)
               {
                  this.chordWidth.setVal(2 * Math.sin(_loc5_ / 2) * this.radius.getVal());
                  _loc1_ = true;
               }
               if(this.chordHeight.getVal() == 0)
               {
                  this.chordHeight.setVal(this.radius.getVal() - Math.sqrt(GWizUtils.square(this.radius.getVal()) - GWizUtils.square(this.chordWidth.getVal() / 2)));
                  _loc1_ = true;
               }
            }
            if(this.radius.getVal() != 0 && this.chordWidth.getVal() != 0)
            {
               if(this.chordWidth.getVal() / this.radius.getVal() >= 2)
               {
                  this.setMessage("2 x Radius must be greater than Width.",true);
               }
               else
               {
                  if(this.chordHeight.getVal() == 0)
                  {
                     this.chordHeight.setVal(this.radius.getVal() - Math.sqrt(GWizUtils.square(this.radius.getVal()) - GWizUtils.square(this.chordWidth.getVal() / 2)));
                     _loc1_ = true;
                  }
                  if(_loc5_ == 0)
                  {
                     _loc5_ = 2 * Math.atan(this.chordWidth.getVal() / 2 / (this.radius.getVal() - this.chordHeight.getVal()));
                     _loc1_ = true;
                  }
               }
            }
            if(this.radius.getVal() != 0 && _loc5_ != 0 && this.arcLength.getVal() == 0)
            {
               this.arcLength.setVal(_loc5_ * this.radius.getVal());
               _loc1_ = true;
            }
            if(this.radius.getVal() != 0 && this.arcLength.getVal() != 0 && _loc5_ == 0)
            {
               if((_loc5_ = this.arcLength.getVal() / this.radius.getVal()) > Math.PI)
               {
                  this.setMessage("Arc Length must be less than Radius * π (1/2 circumference)",true);
               }
               else
               {
                  _loc1_ = true;
               }
            }
            if(this.arcLength.getVal() != 0 && _loc5_ != 0 && this.radius.getVal() == 0)
            {
               this.radius.setVal(this.arcLength.getVal() / _loc5_);
               _loc1_ = true;
            }
            if(this.radius.getVal() != 0 && this.chordHeight.getVal() != 0 && this.chordWidth.getVal() == 0)
            {
               if(this.radius.getVal() < this.chordHeight.getVal())
               {
                  this.setMessage("Radius must be greater than Height.",true);
               }
               else
               {
                  this.chordWidth.setVal(2 * Math.sqrt(GWizUtils.square(this.radius.getVal()) - GWizUtils.square(this.radius.getVal() - this.chordHeight.getVal())));
                  _loc1_ = true;
               }
            }
            if(this.chordWidth.getVal() != 0 && this.chordHeight.getVal() != 0 && this.radius.getVal() == 0)
            {
               _loc2_ = this.chordHeight.getVal() / 2;
               _loc3_ = GWizUtils.square(this.chordWidth.getVal()) / (8 * this.chordHeight.getVal());
               this.radius.setVal(_loc2_ + _loc3_);
               _loc1_ = true;
            }
            _loc8_ = 0;
            if(this.chordWidth.getVal() != 0 && this.arcLength.getVal() != 0 && _loc5_ == 0)
            {
               if((_loc6_ = this.chordWidth.getVal() / this.arcLength.getVal()) < 1)
               {
                  _loc2_ = Math.sqrt(6 - 6 * _loc6_);
                  _loc7_ = _loc2_ + 1;
                  while(Math.abs(_loc2_ - _loc7_) > 0.00001 && _loc8_ < 200)
                  {
                     log.debug("x = " + _loc2_);
                     _loc2_ = (_loc7_ = _loc2_) - (Math.sin(_loc7_) - _loc6_ * _loc7_) / (Math.cos(_loc7_) - _loc6_);
                     _loc8_++;
                  }
                  _loc5_ = Math.abs(2 * _loc2_);
                  _loc1_ = true;
               }
               else
               {
                  this.setMessage("Arc Length must be greater than Width.",true);
               }
            }
            if(this.chordHeight.getVal() != 0 && this.arcLength.getVal() != 0 && _loc5_ == 0)
            {
               _loc6_ = 2 * this.chordHeight.getVal() / this.arcLength.getVal();
               _loc2_ = 2 * _loc6_;
               _loc7_ = _loc2_ + 1;
               while(Math.abs(_loc2_ - _loc7_) > 0.00001 && _loc8_ < 200)
               {
                  log.debug("x = " + _loc2_);
                  _loc2_ = (_loc7_ = _loc2_) - (Math.cos(_loc7_) - _loc6_ * _loc7_ - 1) / (-Math.sin(_loc7_) + _loc6_);
                  _loc8_++;
               }
               _loc5_ = Math.abs(2 * _loc2_);
               _loc1_ = true;
            }
            if(this.arcLength.getVal() != 0 && _loc5_ != 0 && this.radius.getVal() == 0)
            {
               this.radius.setVal(this.arcLength.getVal() / _loc5_);
               _loc1_ = true;
            }
            if(this.chordWidth.getVal() != 0 && _loc5_ != 0 && this.radius.getVal() == 0)
            {
               this.radius.setVal(this.chordWidth.getVal() / (2 * Math.abs(Math.sin(_loc5_ / 2))));
               _loc1_ = true;
            }
         }
         if(!this.angle.isOverridden() && _loc5_ != 0)
         {
            this.angle.setVal(GWizUtils.degrees(_loc5_));
         }
         if(this.radius.getVal() > 0 && this.arcLength.getVal() > 0)
         {
            this.PctCirc.text = GWizUtils.sroundHundredths(String(100 * (this.arcLength.getVal() / (this.radius.getVal() * 2 * Math.PI)))) + "% of Circumference";
         }
         else
         {
            this.PctCirc.text = "";
         }
         this.gridArea.redraw();
      }
      
      private function clearAll() : void
      {
         this.chordWidth.resetOverride(true);
         this.radius.resetOverride(true);
         this.angle.resetOverride(true);
         this.chordHeight.resetOverride(true);
         this.arcLength.resetOverride(true);
         this.PctCirc.text = "";
         this.gridArea.redraw();
      }
      
      private function drawShape(param1:Graphics) : void
      {
         var _loc2_:Number = 6.527;
         var _loc3_:Number = 100;
         var _loc4_:Number = 2.3312;
         var _loc5_:Number = 10;
         if(this.chordWidth.getVal() > 0 && this.radius.getVal() > 0 && this.angle.getVal() > 0 && this.chordHeight.getVal() > 0)
         {
            _loc2_ = this.radius.getVal();
            _loc3_ = this.angle.getVal();
            _loc4_ = this.chordHeight.getVal();
            _loc5_ = this.chordWidth.getVal();
         }
         var _loc6_:Number = (Math.min(this.gridArea.xMax,this.gridArea.yMax) - margin) / _loc2_;
         _loc2_ *= _loc6_;
         _loc4_ *= _loc6_;
         _loc5_ *= _loc6_;
         _loc3_ = GWizUtils.radians(_loc3_);
         var _loc7_:Point = new Point(this.chordRight = this.gridArea.xOrigin + _loc2_ * Math.sin(_loc3_ / 2),this.chordTop = this.gridArea.yOrigin - _loc2_ * Math.cos(_loc3_ / 2));
         var _loc8_:Point = new Point(this.gridArea.xOrigin - _loc2_ * Math.sin(_loc3_ / 2),_loc7_.y);
         var _loc9_:Point = _loc7_.clone();
         var _loc10_:Point = _loc8_.clone();
         var _loc11_:Point;
         var _loc12_:Point = (_loc11_ = new Point(this.gridArea.xOrigin,this.gridArea.yOrigin - _loc2_)).clone();
         var _loc13_:Point;
         (_loc13_ = _loc7_.clone()).x = _loc12_.x = this.gridArea.xOrigin + (_loc2_ + 50);
         _loc9_.y = _loc10_.y = this.gridArea.yOrigin - (_loc2_ + 60);
         param1.lineStyle(1,5592405,1);
         param1.drawCircle(this.gridArea.xOrigin,this.gridArea.yOrigin,_loc2_);
         param1.moveTo(_loc9_.x,_loc9_.y);
         param1.lineTo(_loc7_.x,_loc7_.y);
         param1.lineTo(this.gridArea.xOrigin,this.gridArea.yOrigin);
         param1.lineTo(_loc8_.x,_loc8_.y);
         param1.lineTo(_loc10_.x,_loc10_.y);
         param1.moveTo(_loc11_.x,_loc11_.y);
         param1.lineTo(_loc12_.x,_loc12_.y);
         param1.moveTo(_loc7_.x,_loc7_.y);
         param1.lineTo(_loc13_.x,_loc13_.y);
         param1.beginFill(0,1);
         GraphicsUtil.drawArrows(param1,_loc9_,_loc10_);
         GraphicsUtil.drawArrows(param1,_loc12_,_loc13_,30);
         param1.endFill();
         param1.lineStyle(1,4474111,1);
         param1.moveTo(_loc7_.x,_loc7_.y);
         param1.lineTo(_loc8_.x,_loc8_.y);
         param1.beginFill(4474111,1);
         param1.drawCircle(_loc7_.x,_loc7_.y,3);
         param1.drawCircle(_loc8_.x,_loc8_.y,3);
         param1.endFill();
         this.chordWidth.y = _loc9_.y - 30;
         this.chordHeight.y = _loc13_.y - _loc12_.y > 30 ? Number(_loc12_.y + (_loc13_.y - _loc12_.y) / 2 - this.chordHeight.height / 2) : Number(_loc13_.y + 20);
         this.chordHeight.x = Math.min(_loc13_.x - this.chordHeight.width / 2,this.gridArea.width - this.chordHeight.width);
         this.arcLenGrp.y = this.gridArea.yOrigin - (_loc2_ + 50);
      }
      
      private function clear() : void
      {
         this.chordWidth.resetOverride(true);
         this.radius.resetOverride(true);
         this.angle.resetOverride(true);
         this.chordHeight.resetOverride(true);
         this.arcLength.resetOverride(true);
         this.recalc();
      }
      
      private function _GWizChordCalc_GridComponent1_i() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.xOriginPos = 50;
         _loc1_.yOriginPos = 55;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizChordCalc_Array2_c);
         _loc1_.setStyle("skinClass",GridSkin);
         _loc1_.id = "gridArea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gridArea = _loc1_;
         BindingManager.executeBindings(this,"gridArea",this.gridArea);
         return _loc1_;
      }
      
      private function _GWizChordCalc_Array2_c() : Array
      {
         return [this._GWizChordCalc_Label1_i(),this._GWizChordCalc_GWizNumStepOvr1_i(),this._GWizChordCalc_GWizNumStepOvr2_i(),this._GWizChordCalc_GWizNumStepOvr3_i(),this._GWizChordCalc_GWizNumStepOvr4_i(),this._GWizChordCalc_VGroup1_i(),this._GWizChordCalc_Button1_i()];
      }
      
      private function _GWizChordCalc_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 5;
         _loc1_.y = 5;
         _loc1_.text = "Enter any two values.";
         _loc1_.setStyle("color",2237064);
         _loc1_.id = "messageLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.messageLabel = _loc1_;
         BindingManager.executeBindings(this,"messageLabel",this.messageLabel);
         return _loc1_;
      }
      
      private function _GWizChordCalc_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Width";
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.min = 0;
         _loc1_.noUnits = true;
         _loc1_.y = 30;
         _loc1_.addEventListener("valueCommit",this.__chordWidth_valueCommit);
         _loc1_.id = "chordWidth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.chordWidth = _loc1_;
         BindingManager.executeBindings(this,"chordWidth",this.chordWidth);
         return _loc1_;
      }
      
      public function __chordWidth_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizChordCalc_GWizNumStepOvr2_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Circle Radius";
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.min = 0;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__radius_valueCommit);
         _loc1_.id = "radius";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.radius = _loc1_;
         BindingManager.executeBindings(this,"radius",this.radius);
         return _loc1_;
      }
      
      public function __radius_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizChordCalc_GWizNumStepOvr3_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Angle";
         _loc1_.suffix = "°";
         _loc1_.steps = 0.0001;
         _loc1_.min = 0;
         _loc1_.max = 180;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__angle_valueCommit);
         _loc1_.id = "angle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.angle = _loc1_;
         BindingManager.executeBindings(this,"angle",this.angle);
         return _loc1_;
      }
      
      public function __angle_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizChordCalc_GWizNumStepOvr4_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Height";
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.min = 0;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__chordHeight_valueCommit);
         _loc1_.id = "chordHeight";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.chordHeight = _loc1_;
         BindingManager.executeBindings(this,"chordHeight",this.chordHeight);
         return _loc1_;
      }
      
      public function __chordHeight_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizChordCalc_VGroup1_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizChordCalc_GWizNumStepOvr5_i(),this._GWizChordCalc_Label2_i()];
         _loc1_.id = "arcLenGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.arcLenGrp = _loc1_;
         BindingManager.executeBindings(this,"arcLenGrp",this.arcLenGrp);
         return _loc1_;
      }
      
      private function _GWizChordCalc_GWizNumStepOvr5_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Arc Length";
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.min = 0;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__arcLength_valueCommit);
         _loc1_.id = "arcLength";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.arcLength = _loc1_;
         BindingManager.executeBindings(this,"arcLength",this.arcLength);
         return _loc1_;
      }
      
      public function __arcLength_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizChordCalc_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.id = "PctCirc";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PctCirc = _loc1_;
         BindingManager.executeBindings(this,"PctCirc",this.PctCirc);
         return _loc1_;
      }
      
      private function _GWizChordCalc_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.top = 10;
         _loc1_.right = 10;
         _loc1_.label = "Clear";
         _loc1_.addEventListener("click",this.__Clear_click);
         _loc1_.id = "Clear";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Clear = _loc1_;
         BindingManager.executeBindings(this,"Clear",this.Clear);
         return _loc1_;
      }
      
      public function __Clear_click(param1:MouseEvent) : void
      {
         this.clear();
      }
      
      public function ___GWizChordCalc_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.restoreViewData();
      }
      
      private function _GWizChordCalc_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Function
         {
            return drawShape;
         },null,"gridArea.drawFunc");
         result[1] = new Binding(this,function():Number
         {
            return gridArea.xOrigin - chordWidth.width / 2;
         },null,"chordWidth.x");
         result[2] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + (chordRight - gridArea.xOrigin) / 3 + 5;
         },null,"radius.x");
         result[3] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - ((gridArea.yOrigin - chordTop) / 3 - 5);
         },null,"radius.y");
         result[4] = new Binding(this,function():Number
         {
            return gridArea.xOrigin - angle.width / 2;
         },null,"angle.x");
         result[5] = new Binding(this,function():Number
         {
            return gridArea.yOrigin + 5;
         },null,"angle.y");
         result[6] = new Binding(this,function():Number
         {
            return gridArea.xOrigin - 58;
         },null,"chordHeight.x");
         result[7] = new Binding(this,function():Number
         {
            return gridArea.yOrigin + 10;
         },null,"chordHeight.y");
         result[8] = new Binding(this,function():Number
         {
            return gridArea.xOrigin - arcLenGrp.width / 2;
         },null,"arcLenGrp.x");
         result[9] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - 100;
         },null,"arcLenGrp.y");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Clear() : Button
      {
         return this._65193517Clear;
      }
      
      public function set Clear(param1:Button) : void
      {
         var _loc2_:Object = this._65193517Clear;
         if(_loc2_ !== param1)
         {
            this._65193517Clear = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Clear",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PctCirc() : Label
      {
         return this._929365368PctCirc;
      }
      
      public function set PctCirc(param1:Label) : void
      {
         var _loc2_:Object = this._929365368PctCirc;
         if(_loc2_ !== param1)
         {
            this._929365368PctCirc = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PctCirc",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get angle() : GWizNumStepOvr
      {
         return this._92960979angle;
      }
      
      public function set angle(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._92960979angle;
         if(_loc2_ !== param1)
         {
            this._92960979angle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"angle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get arcLenGrp() : VGroup
      {
         return this._1823449986arcLenGrp;
      }
      
      public function set arcLenGrp(param1:VGroup) : void
      {
         var _loc2_:Object = this._1823449986arcLenGrp;
         if(_loc2_ !== param1)
         {
            this._1823449986arcLenGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"arcLenGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get arcLength() : GWizNumStepOvr
      {
         return this._1823480792arcLength;
      }
      
      public function set arcLength(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1823480792arcLength;
         if(_loc2_ !== param1)
         {
            this._1823480792arcLength = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"arcLength",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get chordHeight() : GWizNumStepOvr
      {
         return this._2000300893chordHeight;
      }
      
      public function set chordHeight(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._2000300893chordHeight;
         if(_loc2_ !== param1)
         {
            this._2000300893chordHeight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"chordHeight",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get chordWidth() : GWizNumStepOvr
      {
         return this._50558262chordWidth;
      }
      
      public function set chordWidth(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._50558262chordWidth;
         if(_loc2_ !== param1)
         {
            this._50558262chordWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"chordWidth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gridArea() : GridComponent
      {
         return this._317504755gridArea;
      }
      
      public function set gridArea(param1:GridComponent) : void
      {
         var _loc2_:Object = this._317504755gridArea;
         if(_loc2_ !== param1)
         {
            this._317504755gridArea = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gridArea",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get messageLabel() : Label
      {
         return this._1304200403messageLabel;
      }
      
      public function set messageLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1304200403messageLabel;
         if(_loc2_ !== param1)
         {
            this._1304200403messageLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"messageLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get radius() : GWizNumStepOvr
      {
         return this._938578798radius;
      }
      
      public function set radius(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._938578798radius;
         if(_loc2_ !== param1)
         {
            this._938578798radius = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"radius",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get chordRight() : Number
      {
         return this._55173344chordRight;
      }
      
      private function set chordRight(param1:Number) : void
      {
         var _loc2_:Object = this._55173344chordRight;
         if(_loc2_ !== param1)
         {
            this._55173344chordRight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"chordRight",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get chordTop() : Number
      {
         return this._1836814169chordTop;
      }
      
      private function set chordTop(param1:Number) : void
      {
         var _loc2_:Object = this._1836814169chordTop;
         if(_loc2_ !== param1)
         {
            this._1836814169chordTop = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"chordTop",_loc2_,param1));
            }
         }
      }
   }
}
