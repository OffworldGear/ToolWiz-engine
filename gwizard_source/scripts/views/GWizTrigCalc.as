package views
{
   import comps.GWizNumStepOvr;
   import comps.GridComponent;
   import flash.display.Graphics;
   import flash.events.MouseEvent;
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
   import spark.components.Button;
   import spark.components.Label;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizTrigCalc extends VGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _65193517Clear:Button;
      
      private var _92158296aSide:GWizNumStepOvr;
      
      private var _1744540548aSideLabel:Label;
      
      private var _93081817bSide:GWizNumStepOvr;
      
      private var _1941054053bSideLabel:Label;
      
      private var _94005338cSide:GWizNumStepOvr;
      
      private var _2137567558cSideLabel:Label;
      
      private var _317504755gridArea:GridComponent;
      
      private var _1304200403messageLabel:Label;
      
      private var _796060869xAngle:GWizNumStepOvr;
      
      private var _1420904569xAngleLabel:Label;
      
      private var _767431718yAngle:GWizNumStepOvr;
      
      private var _376046790yAngleLabel:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _3688988yTop:Number;
      
      private var _780510076xRight:Number;
      
      private var _686853213drawDefault:Boolean = true;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizTrigCalc()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizTrigCalc_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_views_GWizTrigCalcWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizTrigCalc[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.styleName = "geoView";
         this.percentHeight = 100;
         this.percentWidth = 100;
         this.paddingBottom = 10;
         this.paddingLeft = 10;
         this.paddingRight = 10;
         this.paddingTop = 10;
         this.mxmlContent = [this._GWizTrigCalc_VGroup2_c()];
         this.addEventListener("creationComplete",this.___GWizTrigCalc_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizTrigCalc._watcherSetupUtil = param1;
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
      
      private function recalc() : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc1_:Number = 0;
         var _loc2_:Number = 0;
         var _loc3_:* = "";
         var _loc4_:* = "";
         this.drawDefault = false;
         if(this.aSide.isOverridden())
         {
            _loc1_++;
            _loc3_ += "a";
         }
         if(this.bSide.isOverridden())
         {
            _loc1_++;
            _loc3_ += "b";
         }
         if(this.cSide.isOverridden())
         {
            _loc1_++;
            _loc3_ += "c";
         }
         if(this.xAngle.isOverridden())
         {
            _loc2_++;
            _loc4_ += "x";
         }
         if(this.yAngle.isOverridden())
         {
            _loc2_++;
            _loc4_ += "y";
         }
         if(_loc2_ > 1)
         {
            this.messageLabel.text = "Error: Too many angles.  Only enter 1 angle and 1 side OR 2 sides." + "  Touch locks to remove values.";
            this.messageLabel.setStyle("color",GWizUtils.ERROR_COLOR);
            this.drawDefault = true;
         }
         else if(_loc1_ > 1)
         {
            if(_loc1_ == 3)
            {
               this.messageLabel.text = "Error: Specify no more than 2 sides.";
               this.messageLabel.setStyle("color",GWizUtils.ERROR_COLOR);
               this.drawDefault = true;
            }
            else if(_loc2_ > 0)
            {
               this.messageLabel.text = "Error: Too many values.  Only enter 1 angle and 1 side OR 2 sides.";
               this.messageLabel.setStyle("color",GWizUtils.ERROR_COLOR);
               this.drawDefault = true;
            }
            else
            {
               switch(_loc3_)
               {
                  case "ab":
                     _loc5_ = this.aSide.getVal();
                     _loc5_ *= _loc5_;
                     _loc6_ = this.bSide.getVal();
                     _loc6_ *= _loc6_;
                     _loc7_ = Math.sqrt(_loc5_ + _loc6_);
                     this.cSide.setVal(_loc7_);
                     break;
                  case "ac":
                     _loc5_ = this.aSide.getVal();
                     _loc5_ *= _loc5_;
                     _loc7_ = this.cSide.getVal();
                     _loc7_ *= _loc7_;
                     _loc6_ = Math.sqrt(_loc7_ - _loc5_);
                     this.bSide.setVal(_loc6_);
                     break;
                  case "bc":
                     _loc6_ = this.bSide.getVal();
                     _loc6_ *= _loc6_;
                     _loc7_ = this.cSide.getVal();
                     _loc7_ *= _loc7_;
                     _loc5_ = Math.sqrt(_loc7_ - _loc6_);
                     this.aSide.setVal(_loc5_);
                     break;
                  default:
                     GWizUtils.assert(false);
               }
               _loc8_ = Math.acos(this.bSide.getVal() / this.cSide.getVal());
               _loc8_ = GWizUtils.degrees(_loc8_);
               this.xAngle.setVal(_loc8_);
               this.yAngle.setVal(180 - 90 - _loc8_);
            }
         }
         else if(_loc1_ > 0 && _loc2_ > 0)
         {
            if(_loc1_ > 1)
            {
               this.messageLabel.text = "Error: Too many values.  Only enter 1 angle and 1 side OR 2 sides." + "  Touch locks to remove values.";
               this.messageLabel.setStyle("color",GWizUtils.ERROR_COLOR);
               this.drawDefault = true;
            }
            else if(_loc4_ == "x")
            {
               _loc8_ = this.xAngle.getVal();
               _loc8_ = GWizUtils.radians(_loc8_);
               switch(_loc3_)
               {
                  case "a":
                     _loc6_ = (_loc7_ = (_loc5_ = this.aSide.getVal()) / Math.sin(_loc8_)) * Math.cos(_loc8_);
                     break;
                  case "b":
                     _loc5_ = (_loc7_ = (_loc6_ = this.bSide.getVal()) / Math.cos(_loc8_)) * Math.sin(_loc8_);
                     break;
                  case "c":
                     _loc5_ = (_loc7_ = this.cSide.getVal()) * Math.sin(_loc8_);
                     _loc6_ = _loc7_ * Math.cos(_loc8_);
                     break;
                  default:
                     this.drawDefault = true;
                     GWizUtils.assert(false);
               }
               this.aSide.setVal(_loc5_);
               this.bSide.setVal(_loc6_);
               this.cSide.setVal(_loc7_);
               this.yAngle.setVal(180 - this.xAngle.getVal() - 90);
            }
            else
            {
               _loc9_ = this.yAngle.getVal();
               _loc9_ = GWizUtils.radians(_loc9_);
               switch(_loc3_)
               {
                  case "a":
                     _loc6_ = (_loc7_ = (_loc5_ = this.aSide.getVal()) / Math.cos(_loc9_)) * Math.sin(_loc9_);
                     break;
                  case "b":
                     _loc5_ = (_loc7_ = (_loc6_ = this.bSide.getVal()) / Math.sin(_loc9_)) * Math.cos(_loc9_);
                     break;
                  case "c":
                     _loc6_ = (_loc7_ = this.cSide.getVal()) * Math.sin(_loc9_);
                     _loc5_ = _loc7_ * Math.cos(_loc9_);
                     break;
                  default:
                     this.drawDefault = true;
                     GWizUtils.assert(false);
               }
               this.aSide.setVal(_loc5_);
               this.bSide.setVal(_loc6_);
               this.cSide.setVal(_loc7_);
               this.xAngle.setVal(180 - this.yAngle.getVal() - 90);
            }
         }
         else
         {
            this.messageLabel.text = "Specify 1 angle and 1 side OR 2 sides.";
            this.messageLabel.setStyle("color",GWizUtils.MESSAGE_COLOR);
            this.drawDefault = true;
         }
         this.gridArea.redraw();
         this.updateLabels();
      }
      
      private function clearAll() : void
      {
         this.aSide.resetOverride(true);
         this.bSide.resetOverride(true);
         this.cSide.resetOverride(true);
         this.xAngle.resetOverride(true);
         this.yAngle.resetOverride(true);
         this.drawDefault = true;
         this.gridArea.redraw();
         this.updateLabels();
      }
      
      private function updateLabels() : void
      {
         this.xAngleLabel.text = this.xAngle.getVal() > 0 ? "∠a = " + this.xAngle.getVal().toString() + "°" : "∠a";
         this.yAngleLabel.text = this.yAngle.getVal() > 0 ? "∠b = " + this.yAngle.getVal().toString() + "°" : "∠b";
         this.aSideLabel.text = this.aSide.getVal() > 0 ? "A = " + this.aSide.getVal().toString() : "A";
         this.bSideLabel.text = this.bSide.getVal() > 0 ? "B = " + this.bSide.getVal().toString() : "B";
         this.cSideLabel.text = this.cSide.getVal() > 0 ? "C = " + this.cSide.getVal().toString() : "C";
      }
      
      public function drawShape(param1:Graphics) : void
      {
         var _loc2_:Number = Math.min(this.gridArea.xMax / this.bSide.getVal(),this.gridArea.yMax / this.aSide.getVal());
         if(this.drawDefault)
         {
            this.yTop = this.gridArea.yOrigin - Math.min(this.gridArea.yMax,this.gridArea.xMax);
            this.xRight = this.gridArea.xOrigin + Math.min(this.gridArea.yMax,this.gridArea.xMax);
         }
         else
         {
            this.yTop = this.gridArea.yOrigin - Number(this.aSide.getVal() * _loc2_);
            this.xRight = this.gridArea.xOrigin + Number(this.bSide.getVal() * _loc2_);
         }
         param1.beginFill(0,0.2);
         param1.lineStyle(1,5592405,1);
         param1.moveTo(this.gridArea.xOrigin,this.gridArea.yOrigin);
         param1.lineTo(this.xRight,this.gridArea.yOrigin);
         param1.lineTo(this.gridArea.xOrigin,this.yTop);
         param1.lineTo(this.gridArea.xOrigin,this.gridArea.yOrigin);
         param1.endFill();
      }
      
      private function clear() : void
      {
         this.xAngle.resetOverride(true);
         this.yAngle.resetOverride(true);
         this.aSide.resetOverride(true);
         this.bSide.resetOverride(true);
         this.cSide.resetOverride(true);
         this.recalc();
      }
      
      private function _GWizTrigCalc_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.gap = 0;
         _loc1_.alpha = 1;
         _loc1_.mxmlContent = [this._GWizTrigCalc_GridComponent1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTrigCalc_GridComponent1_i() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.xOrigin = 150;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizTrigCalc_Array3_c);
         _loc1_.id = "gridArea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gridArea = _loc1_;
         BindingManager.executeBindings(this,"gridArea",this.gridArea);
         return _loc1_;
      }
      
      private function _GWizTrigCalc_Array3_c() : Array
      {
         return [this._GWizTrigCalc_Label1_i(),this._GWizTrigCalc_Label2_i(),this._GWizTrigCalc_Label3_i(),this._GWizTrigCalc_Label4_i(),this._GWizTrigCalc_Label5_i(),this._GWizTrigCalc_GWizNumStepOvr1_i(),this._GWizTrigCalc_GWizNumStepOvr2_i(),this._GWizTrigCalc_GWizNumStepOvr3_i(),this._GWizTrigCalc_GWizNumStepOvr4_i(),this._GWizTrigCalc_GWizNumStepOvr5_i(),this._GWizTrigCalc_Button1_i(),this._GWizTrigCalc_Label6_i()];
      }
      
      private function _GWizTrigCalc_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "∠b";
         _loc1_.addEventListener("click",this.__yAngleLabel_click);
         _loc1_.id = "yAngleLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.yAngleLabel = _loc1_;
         BindingManager.executeBindings(this,"yAngleLabel",this.yAngleLabel);
         return _loc1_;
      }
      
      public function __yAngleLabel_click(param1:MouseEvent) : void
      {
         this.yAngle.setFocus();
      }
      
      private function _GWizTrigCalc_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "A";
         _loc1_.id = "aSideLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.aSideLabel = _loc1_;
         BindingManager.executeBindings(this,"aSideLabel",this.aSideLabel);
         return _loc1_;
      }
      
      private function _GWizTrigCalc_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "B";
         _loc1_.id = "bSideLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.bSideLabel = _loc1_;
         BindingManager.executeBindings(this,"bSideLabel",this.bSideLabel);
         return _loc1_;
      }
      
      private function _GWizTrigCalc_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "∠a";
         _loc1_.id = "xAngleLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xAngleLabel = _loc1_;
         BindingManager.executeBindings(this,"xAngleLabel",this.xAngleLabel);
         return _loc1_;
      }
      
      private function _GWizTrigCalc_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "C";
         _loc1_.id = "cSideLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cSideLabel = _loc1_;
         BindingManager.executeBindings(this,"cSideLabel",this.cSideLabel);
         return _loc1_;
      }
      
      private function _GWizTrigCalc_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.x = 10;
         _loc1_.y = 20;
         _loc1_.steps = 0.0001;
         _loc1_.min = 0;
         _loc1_.max = 180;
         _loc1_.labelWidth = 20;
         _loc1_.titleTxt = "∠a";
         _loc1_.suffix = "°";
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__xAngle_valueCommit);
         _loc1_.id = "xAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xAngle = _loc1_;
         BindingManager.executeBindings(this,"xAngle",this.xAngle);
         return _loc1_;
      }
      
      public function __xAngle_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTrigCalc_GWizNumStepOvr2_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.x = 10;
         _loc1_.y = 50;
         _loc1_.steps = 0.0001;
         _loc1_.min = 0;
         _loc1_.max = 180;
         _loc1_.labelWidth = 20;
         _loc1_.titleTxt = "∠b";
         _loc1_.suffix = "°";
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__yAngle_valueCommit);
         _loc1_.id = "yAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.yAngle = _loc1_;
         BindingManager.executeBindings(this,"yAngle",this.yAngle);
         return _loc1_;
      }
      
      public function __yAngle_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTrigCalc_GWizNumStepOvr3_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.x = 10;
         _loc1_.y = 100;
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.min = 0;
         _loc1_.labelWidth = 20;
         _loc1_.titleTxt = "A";
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__aSide_valueCommit);
         _loc1_.id = "aSide";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.aSide = _loc1_;
         BindingManager.executeBindings(this,"aSide",this.aSide);
         return _loc1_;
      }
      
      public function __aSide_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTrigCalc_GWizNumStepOvr4_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.x = 10;
         _loc1_.y = 130;
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.min = 0;
         _loc1_.labelWidth = 20;
         _loc1_.titleTxt = "B";
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__bSide_valueCommit);
         _loc1_.id = "bSide";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.bSide = _loc1_;
         BindingManager.executeBindings(this,"bSide",this.bSide);
         return _loc1_;
      }
      
      public function __bSide_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTrigCalc_GWizNumStepOvr5_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.x = 10;
         _loc1_.y = 160;
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.min = 0;
         _loc1_.labelWidth = 20;
         _loc1_.titleTxt = "C";
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__cSide_valueCommit);
         _loc1_.id = "cSide";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cSide = _loc1_;
         BindingManager.executeBindings(this,"cSide",this.cSide);
         return _loc1_;
      }
      
      public function __cSide_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTrigCalc_Button1_i() : Button
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
      
      private function _GWizTrigCalc_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Specify 1 angle and 1 side OR 2 sides.";
         _loc1_.x = 10;
         _loc1_.y = 240;
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
      
      public function ___GWizTrigCalc_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.restoreViewData();
      }
      
      private function _GWizTrigCalc_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Function
         {
            return drawShape;
         },null,"gridArea.drawFunc");
         result[1] = new Binding(this,function():Number
         {
            return gridArea.xOrigin;
         },null,"yAngleLabel.x");
         result[2] = new Binding(this,function():Number
         {
            return Math.min(yTop - 22,gridArea.yOrigin - (gridArea.yOrigin - yTop) / 2 - 22);
         },null,"yAngleLabel.y");
         result[3] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + 2;
         },null,"aSideLabel.x");
         result[4] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - (gridArea.yOrigin - yTop) / 2 - 2;
         },null,"aSideLabel.y");
         result[5] = new Binding(this,function():Number
         {
            return Math.max(gridArea.xOrigin,(xRight - gridArea.xOrigin) / 2 + gridArea.xOrigin);
         },null,"bSideLabel.x");
         result[6] = new Binding(this,function():Number
         {
            return gridArea.yOrigin + 3;
         },null,"bSideLabel.y");
         result[7] = new Binding(this,function():Number
         {
            return Math.min(xRight + 5,gridArea.width - xAngleLabel.width - 20);
         },null,"xAngleLabel.x");
         result[8] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - 15;
         },null,"xAngleLabel.y");
         result[9] = new Binding(this,function():Number
         {
            return (xRight - gridArea.xOrigin) / 2 + gridArea.xOrigin;
         },null,"cSideLabel.x");
         result[10] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - (gridArea.yOrigin - yTop) / 2 - 30;
         },null,"cSideLabel.y");
         result[11] = new Binding(this,function():Boolean
         {
            return drawDefault;
         },null,"messageLabel.visible");
         result[12] = new Binding(this,function():Number
         {
            return gridArea.xOrigin - 20;
         },null,"messageLabel.width");
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
      public function get aSide() : GWizNumStepOvr
      {
         return this._92158296aSide;
      }
      
      public function set aSide(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._92158296aSide;
         if(_loc2_ !== param1)
         {
            this._92158296aSide = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"aSide",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get aSideLabel() : Label
      {
         return this._1744540548aSideLabel;
      }
      
      public function set aSideLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1744540548aSideLabel;
         if(_loc2_ !== param1)
         {
            this._1744540548aSideLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"aSideLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get bSide() : GWizNumStepOvr
      {
         return this._93081817bSide;
      }
      
      public function set bSide(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._93081817bSide;
         if(_loc2_ !== param1)
         {
            this._93081817bSide = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"bSide",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get bSideLabel() : Label
      {
         return this._1941054053bSideLabel;
      }
      
      public function set bSideLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1941054053bSideLabel;
         if(_loc2_ !== param1)
         {
            this._1941054053bSideLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"bSideLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cSide() : GWizNumStepOvr
      {
         return this._94005338cSide;
      }
      
      public function set cSide(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._94005338cSide;
         if(_loc2_ !== param1)
         {
            this._94005338cSide = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cSide",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cSideLabel() : Label
      {
         return this._2137567558cSideLabel;
      }
      
      public function set cSideLabel(param1:Label) : void
      {
         var _loc2_:Object = this._2137567558cSideLabel;
         if(_loc2_ !== param1)
         {
            this._2137567558cSideLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cSideLabel",_loc2_,param1));
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
      public function get xAngle() : GWizNumStepOvr
      {
         return this._796060869xAngle;
      }
      
      public function set xAngle(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._796060869xAngle;
         if(_loc2_ !== param1)
         {
            this._796060869xAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get xAngleLabel() : Label
      {
         return this._1420904569xAngleLabel;
      }
      
      public function set xAngleLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1420904569xAngleLabel;
         if(_loc2_ !== param1)
         {
            this._1420904569xAngleLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xAngleLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get yAngle() : GWizNumStepOvr
      {
         return this._767431718yAngle;
      }
      
      public function set yAngle(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._767431718yAngle;
         if(_loc2_ !== param1)
         {
            this._767431718yAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"yAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get yAngleLabel() : Label
      {
         return this._376046790yAngleLabel;
      }
      
      public function set yAngleLabel(param1:Label) : void
      {
         var _loc2_:Object = this._376046790yAngleLabel;
         if(_loc2_ !== param1)
         {
            this._376046790yAngleLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"yAngleLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get yTop() : Number
      {
         return this._3688988yTop;
      }
      
      private function set yTop(param1:Number) : void
      {
         var _loc2_:Object = this._3688988yTop;
         if(_loc2_ !== param1)
         {
            this._3688988yTop = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"yTop",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get xRight() : Number
      {
         return this._780510076xRight;
      }
      
      private function set xRight(param1:Number) : void
      {
         var _loc2_:Object = this._780510076xRight;
         if(_loc2_ !== param1)
         {
            this._780510076xRight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xRight",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get drawDefault() : Boolean
      {
         return this._686853213drawDefault;
      }
      
      private function set drawDefault(param1:Boolean) : void
      {
         var _loc2_:Object = this._686853213drawDefault;
         if(_loc2_ !== param1)
         {
            this._686853213drawDefault = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"drawDefault",_loc2_,param1));
            }
         }
      }
   }
}
