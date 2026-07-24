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
   
   public class GWizTrigCalcOblique extends VGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1924303122AAngle:GWizNumStepOvr;
      
      private var _1468981506AAngleLabel:Label;
      
      private var _1952932273BAngle:GWizNumStepOvr;
      
      private var _327969853BAngleLabel:Label;
      
      private var _1981561424CAngle:GWizNumStepOvr;
      
      private var _2124921212CAngleLabel:Label;
      
      private var _65193517Clear:Button;
      
      private var _92158296aSide:GWizNumStepOvr;
      
      private var _1744540548aSideLabel:Label;
      
      private var _93081817bSide:GWizNumStepOvr;
      
      private var _1941054053bSideLabel:Label;
      
      private var _94005338cSide:GWizNumStepOvr;
      
      private var _2137567558cSideLabel:Label;
      
      private var _317504755gridArea:GridComponent;
      
      private var _1304200403messageLabel:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _686853213drawDefault:Boolean = true;
      
      private var _114284sx1:Number;
      
      private var _114285sx2:Number;
      
      private var _114286sx3:Number;
      
      private var _114315sy1:Number;
      
      private var _114316sy2:Number;
      
      private var _114317sy3:Number;
      
      private var lastDrawDefault:Boolean = true;
      
      private var sideOffset:int = -20;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizTrigCalcOblique()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizTrigCalcOblique_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_views_GWizTrigCalcObliqueWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizTrigCalcOblique[param1];
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
         this.mxmlContent = [this._GWizTrigCalcOblique_VGroup2_c()];
         this.addEventListener("creationComplete",this.___GWizTrigCalcOblique_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizTrigCalcOblique._watcherSetupUtil = param1;
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
         var _loc5_:Boolean = false;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:String = null;
         var _loc13_:int = 0;
         var _loc1_:Number = 0;
         var _loc2_:Number = 0;
         var _loc3_:* = "";
         var _loc4_:* = "";
         var _loc14_:Number = 0;
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
         if(this.AAngle.isOverridden())
         {
            _loc2_++;
            _loc4_ += "A";
            _loc14_ += this.AAngle.getVal();
         }
         if(this.BAngle.isOverridden())
         {
            _loc2_++;
            _loc4_ += "B";
            _loc14_ += this.BAngle.getVal();
         }
         if(this.CAngle.isOverridden())
         {
            _loc2_++;
            _loc4_ += "C";
            _loc14_ += this.CAngle.getVal();
         }
         _loc6_ = this.aSide.getVal();
         _loc7_ = this.bSide.getVal();
         _loc8_ = this.cSide.getVal();
         _loc9_ = GWizUtils.radians(this.AAngle.getVal());
         _loc10_ = GWizUtils.radians(this.BAngle.getVal());
         _loc11_ = GWizUtils.radians(this.CAngle.getVal());
         if(_loc1_ + _loc2_ != 3)
         {
            if(_loc1_ + _loc2_ > 3)
            {
               this.messageLabel.text = "Error: Too many values specified.  Please clear some of the overridden values by pressing the lock button.";
               this.messageLabel.setStyle("color",GWizUtils.ERROR_COLOR);
            }
            else
            {
               this.messageLabel.text = "Specify 2 angles and 1 side OR 2 sides and 1 angle.";
               this.messageLabel.setStyle("color",GWizUtils.MESSAGE_COLOR);
            }
            this.drawDefault = true;
         }
         else if(_loc14_ >= 180)
         {
            this.messageLabel.text = "Error: Total of angles too great.  Specified angles should add up to less than 180.";
            this.messageLabel.setStyle("color",GWizUtils.ERROR_COLOR);
            this.drawDefault = true;
         }
         else
         {
            _loc5_ = true;
            while((_loc2_ < 3 || _loc1_ < 3) && _loc5_)
            {
               _loc5_ = false;
               if(_loc2_ == 2)
               {
                  switch(_loc4_)
                  {
                     case "AB":
                        _loc11_ = Math.PI - (_loc9_ + _loc10_);
                        _loc2_++;
                        _loc4_ = "ABC";
                        _loc5_ = true;
                        break;
                     case "AC":
                        _loc10_ = Math.PI - (_loc9_ + _loc11_);
                        _loc2_++;
                        _loc4_ = "ABC";
                        _loc5_ = true;
                        break;
                     case "BC":
                        _loc9_ = Math.PI - (_loc10_ + _loc11_);
                        _loc2_++;
                        _loc4_ = "ABC";
                        break;
                     default:
                        GWizUtils.assert(false);
                        this.drawDefault = true;
                        _loc5_ = true;
                  }
               }
               _loc13_ = 1;
               while(_loc13_ <= _loc4_.length && _loc1_ < 3)
               {
                  if((_loc12_ = _loc4_.charAt(_loc13_ - 1)) == "A")
                  {
                     if(_loc3_.indexOf("bc") >= 0)
                     {
                        _loc6_ = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_ - 2 * _loc7_ * _loc8_ * Math.cos(_loc9_));
                        _loc1_++;
                        _loc5_ = true;
                        _loc3_ = "abc";
                     }
                  }
                  else if(_loc12_ == "B")
                  {
                     if(_loc3_.indexOf("ac") >= 0)
                     {
                        _loc7_ = Math.sqrt(_loc6_ * _loc6_ + _loc8_ * _loc8_ - 2 * _loc6_ * _loc8_ * Math.cos(_loc10_));
                        _loc1_++;
                        _loc5_ = true;
                        _loc3_ = "abc";
                     }
                  }
                  else if(_loc12_ == "C")
                  {
                     if(_loc3_.indexOf("ab") >= 0)
                     {
                        _loc8_ = Math.sqrt(_loc7_ * _loc7_ + _loc6_ * _loc6_ - 2 * _loc7_ * _loc6_ * Math.cos(_loc11_));
                        _loc1_++;
                        _loc5_ = true;
                        _loc3_ = "abc";
                     }
                  }
                  _loc13_++;
               }
               if(_loc2_ >= 2 && _loc1_ > 0)
               {
                  if(_loc3_.indexOf("a") == -1)
                  {
                     if(_loc4_.indexOf("A") != -1)
                     {
                        if(_loc4_.indexOf("B") != -1 && _loc3_.indexOf("b") != -1)
                        {
                           _loc6_ = _loc7_ * Math.sin(_loc9_) / Math.sin(_loc10_);
                           _loc5_ = true;
                           _loc1_++;
                           _loc3_ = "a" + _loc3_;
                        }
                        else if(_loc4_.indexOf("C") != -1 && _loc3_.indexOf("c") != -1)
                        {
                           _loc6_ = _loc8_ * Math.sin(_loc9_) / Math.sin(_loc11_);
                           _loc5_ = true;
                           _loc1_++;
                           _loc3_ = "a" + _loc3_;
                        }
                     }
                  }
                  else if(_loc3_.indexOf("b") == -1)
                  {
                     if(_loc4_.indexOf("B") != -1)
                     {
                        if(_loc4_.indexOf("A") != -1 && _loc3_.indexOf("a") != -1)
                        {
                           _loc7_ = _loc6_ * Math.sin(_loc10_) / Math.sin(_loc9_);
                           _loc5_ = true;
                           _loc1_++;
                           switch(_loc3_)
                           {
                              case "a":
                                 _loc3_ = "ab";
                                 break;
                              case "ac":
                                 _loc3_ = "abc";
                                 break;
                              case "c":
                                 _loc3_ = "bc";
                                 break;
                              default:
                                 this.drawDefault = true;
                                 GWizUtils.assert(false);
                           }
                        }
                        else if(_loc4_.indexOf("C") != -1 && _loc3_.indexOf("c") != -1)
                        {
                           _loc7_ = _loc8_ * Math.sin(_loc10_) / Math.sin(_loc11_);
                           _loc5_ = true;
                           _loc1_++;
                           switch(_loc3_)
                           {
                              case "a":
                                 _loc3_ = "ab";
                                 break;
                              case "ac":
                                 _loc3_ = "abc";
                                 break;
                              case "c":
                                 _loc3_ = "bc";
                                 break;
                              default:
                                 this.drawDefault = true;
                                 GWizUtils.assert(false);
                           }
                        }
                     }
                  }
                  else if(_loc3_.indexOf("c") == -1)
                  {
                     if(_loc4_.indexOf("C") != -1)
                     {
                        if(_loc4_.indexOf("B") != -1 && _loc3_.indexOf("b") != -1)
                        {
                           _loc8_ = _loc7_ * Math.sin(_loc11_) / Math.sin(_loc10_);
                           _loc5_ = true;
                           _loc1_++;
                           _loc3_ += "c";
                        }
                        else if(_loc4_.indexOf("A") != -1 && _loc3_.indexOf("a") != -1)
                        {
                           _loc8_ = _loc6_ * Math.sin(_loc11_) / Math.sin(_loc9_);
                           _loc5_ = true;
                           _loc1_++;
                           _loc3_ += "c";
                        }
                     }
                  }
               }
               if(_loc1_ == 3)
               {
                  if(_loc4_.indexOf("A") == -1)
                  {
                     _loc9_ = Math.acos((_loc6_ * _loc6_ - _loc7_ * _loc7_ - _loc8_ * _loc8_) / (-2 * _loc7_ * _loc8_));
                     _loc5_ = true;
                     _loc4_ = "A" + _loc4_;
                     _loc2_++;
                  }
                  if(_loc4_.indexOf("B") == -1)
                  {
                     _loc10_ = Math.acos((_loc7_ * _loc7_ - _loc8_ * _loc8_ - _loc6_ * _loc6_) / (-2 * _loc6_ * _loc8_));
                     _loc5_ = true;
                     if(_loc4_ == "A")
                     {
                        _loc4_ = "AB";
                     }
                     else if(_loc4_ == "AC")
                     {
                        _loc4_ = "ABC";
                     }
                     else if(_loc4_ == "C")
                     {
                        _loc4_ = "BC";
                     }
                     _loc2_++;
                  }
                  if(_loc4_.indexOf("C") == -1)
                  {
                     _loc11_ = Math.acos((_loc8_ * _loc8_ - _loc6_ * _loc6_ - _loc7_ * _loc7_) / (-2 * _loc6_ * _loc7_));
                     _loc5_ = true;
                     _loc4_ += "C";
                     _loc2_++;
                  }
               }
            }
            this.aSide.setVal(_loc6_);
            this.bSide.setVal(_loc7_);
            this.cSide.setVal(_loc8_);
            this.AAngle.setVal(GWizUtils.degrees(_loc9_));
            this.BAngle.setVal(GWizUtils.degrees(_loc10_));
            this.CAngle.setVal(GWizUtils.degrees(_loc11_));
            if(_loc2_ < 3 || _loc1_ < 3)
            {
               this.messageLabel.text = "Error: No valid solution.  When specifying 1 angle the 2 adjacent sides must be specified.";
               this.messageLabel.setStyle("color",GWizUtils.ERROR_COLOR);
               this.drawDefault = true;
            }
         }
         this.gridArea.redraw();
         this.updateLabels();
      }
      
      private function clearAll() : void
      {
         this.aSide.resetOverride(true);
         this.bSide.resetOverride(true);
         this.cSide.resetOverride(true);
         this.AAngle.resetOverride(true);
         this.BAngle.resetOverride(true);
         this.CAngle.resetOverride(true);
         this.drawDefault = true;
         this.gridArea.redraw();
         this.updateLabels();
      }
      
      public function drawShape(param1:Graphics) : void
      {
         var _loc2_:Number = !!this.drawDefault ? Number(60) : Number(this.AAngle.getVal());
         var _loc3_:Number = !!this.drawDefault ? Number(60) : Number(this.BAngle.getVal());
         var _loc4_:Number = !!this.drawDefault ? Number(60) : Number(this.CAngle.getVal());
         var _loc5_:Number = !!this.drawDefault ? Number(1) : Number(this.aSide.getVal());
         var _loc6_:Number = !!this.drawDefault ? Number(1) : Number(this.bSide.getVal());
         var _loc7_:Number = !!this.drawDefault ? Number(1) : Number(this.cSide.getVal());
         var _loc8_:Number = 0;
         var _loc9_:Number = 0;
         var _loc10_:Number = 0;
         var _loc11_:Number = _loc6_;
         var _loc12_:Number = Math.abs(Math.sin(_loc4_ * Math.PI / 180)) * _loc5_;
         var _loc13_:Number = Math.sqrt(_loc5_ * _loc5_ - _loc12_ * _loc12_);
         if(_loc4_ > 90)
         {
            _loc8_ += _loc13_;
            _loc11_ += _loc13_;
            _loc13_ = 0;
         }
         var _loc14_:Number = Math.max(_loc11_,_loc13_);
         var _loc15_:Number = Math.min(this.gridArea.xMax / _loc14_,this.gridArea.yMax / _loc12_);
         this.sx1 = this.gridArea.xOrigin + _loc8_ * _loc15_;
         this.sy1 = this.gridArea.yOrigin - _loc9_ * _loc15_;
         this.sx2 = this.gridArea.xOrigin + _loc11_ * _loc15_;
         this.sy2 = this.gridArea.yOrigin - _loc10_ * _loc15_;
         this.sx3 = this.gridArea.xOrigin + _loc13_ * _loc15_;
         this.sy3 = this.gridArea.yOrigin - _loc12_ * _loc15_;
         param1.beginFill(0,0.2);
         param1.lineStyle(1,5592405,1);
         param1.moveTo(this.sx1,this.sy1);
         param1.lineTo(this.sx2,this.sy2);
         param1.lineTo(this.sx3,this.sy3);
         param1.lineTo(this.sx1,this.sy1);
         param1.endFill();
         this.sideOffset = _loc4_ > 90 ? 20 : -20;
      }
      
      private function updateLabels() : void
      {
         this.AAngleLabel.text = this.AAngle.getVal() > 0 ? "∠a = " + this.AAngle.getVal().toString() + "°" : "∠a";
         this.BAngleLabel.text = this.BAngle.getVal() > 0 ? "∠b = " + this.BAngle.getVal().toString() + "°" : "∠b";
         this.CAngleLabel.text = this.CAngle.getVal() > 0 ? "∠c = " + this.CAngle.getVal().toString() + "°" : "∠c";
         this.aSideLabel.text = this.aSide.getVal() > 0 ? "A = " + this.aSide.getVal().toString() : "A";
         this.bSideLabel.text = this.bSide.getVal() > 0 ? "B = " + this.bSide.getVal().toString() : "B";
         this.cSideLabel.text = this.cSide.getVal() > 0 ? "C = " + this.cSide.getVal().toString() : "C";
      }
      
      private function clear() : void
      {
         this.AAngle.resetOverride(true);
         this.BAngle.resetOverride(true);
         this.CAngle.resetOverride(true);
         this.aSide.resetOverride(true);
         this.bSide.resetOverride(true);
         this.cSide.resetOverride(true);
         this.recalc();
      }
      
      private function _GWizTrigCalcOblique_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.gap = 0;
         _loc1_.alpha = 1;
         _loc1_.mxmlContent = [this._GWizTrigCalcOblique_GridComponent1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTrigCalcOblique_GridComponent1_i() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.xOrigin = 150;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizTrigCalcOblique_Array3_c);
         _loc1_.id = "gridArea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gridArea = _loc1_;
         BindingManager.executeBindings(this,"gridArea",this.gridArea);
         return _loc1_;
      }
      
      private function _GWizTrigCalcOblique_Array3_c() : Array
      {
         return [this._GWizTrigCalcOblique_Label1_i(),this._GWizTrigCalcOblique_Label2_i(),this._GWizTrigCalcOblique_Label3_i(),this._GWizTrigCalcOblique_Label4_i(),this._GWizTrigCalcOblique_Label5_i(),this._GWizTrigCalcOblique_Label6_i(),this._GWizTrigCalcOblique_GWizNumStepOvr1_i(),this._GWizTrigCalcOblique_GWizNumStepOvr2_i(),this._GWizTrigCalcOblique_GWizNumStepOvr3_i(),this._GWizTrigCalcOblique_GWizNumStepOvr4_i(),this._GWizTrigCalcOblique_GWizNumStepOvr5_i(),this._GWizTrigCalcOblique_GWizNumStepOvr6_i(),this._GWizTrigCalcOblique_Button1_i(),this._GWizTrigCalcOblique_Label7_i()];
      }
      
      private function _GWizTrigCalcOblique_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "∠a";
         _loc1_.id = "AAngleLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.AAngleLabel = _loc1_;
         BindingManager.executeBindings(this,"AAngleLabel",this.AAngleLabel);
         return _loc1_;
      }
      
      private function _GWizTrigCalcOblique_Label2_i() : Label
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
      
      private function _GWizTrigCalcOblique_Label3_i() : Label
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
      
      private function _GWizTrigCalcOblique_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "∠b";
         _loc1_.id = "BAngleLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.BAngleLabel = _loc1_;
         BindingManager.executeBindings(this,"BAngleLabel",this.BAngleLabel);
         return _loc1_;
      }
      
      private function _GWizTrigCalcOblique_Label5_i() : Label
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
      
      private function _GWizTrigCalcOblique_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "∠c";
         _loc1_.id = "CAngleLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CAngleLabel = _loc1_;
         BindingManager.executeBindings(this,"CAngleLabel",this.CAngleLabel);
         return _loc1_;
      }
      
      private function _GWizTrigCalcOblique_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "∠a";
         _loc1_.noUnits = true;
         _loc1_.labelWidth = 20;
         _loc1_.x = 10;
         _loc1_.y = 20;
         _loc1_.steps = 0.0001;
         _loc1_.min = 0;
         _loc1_.max = 180;
         _loc1_.suffix = "°";
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__AAngle_valueCommit);
         _loc1_.id = "AAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.AAngle = _loc1_;
         BindingManager.executeBindings(this,"AAngle",this.AAngle);
         return _loc1_;
      }
      
      public function __AAngle_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTrigCalcOblique_GWizNumStepOvr2_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "∠b";
         _loc1_.noUnits = true;
         _loc1_.labelWidth = 20;
         _loc1_.x = 10;
         _loc1_.y = 50;
         _loc1_.steps = 0.0001;
         _loc1_.min = 0;
         _loc1_.max = 180;
         _loc1_.suffix = "°";
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__BAngle_valueCommit);
         _loc1_.id = "BAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.BAngle = _loc1_;
         BindingManager.executeBindings(this,"BAngle",this.BAngle);
         return _loc1_;
      }
      
      public function __BAngle_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTrigCalcOblique_GWizNumStepOvr3_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "∠c";
         _loc1_.noUnits = true;
         _loc1_.labelWidth = 20;
         _loc1_.x = 10;
         _loc1_.y = 80;
         _loc1_.steps = 0.0001;
         _loc1_.min = 0;
         _loc1_.max = 180;
         _loc1_.suffix = "°";
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__CAngle_valueCommit);
         _loc1_.id = "CAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CAngle = _loc1_;
         BindingManager.executeBindings(this,"CAngle",this.CAngle);
         return _loc1_;
      }
      
      public function __CAngle_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTrigCalcOblique_GWizNumStepOvr4_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "A";
         _loc1_.labelWidth = 20;
         _loc1_.x = 10;
         _loc1_.y = 130;
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.min = 0;
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
      
      private function _GWizTrigCalcOblique_GWizNumStepOvr5_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "B";
         _loc1_.labelWidth = 20;
         _loc1_.x = 10;
         _loc1_.y = 160;
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.min = 0;
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
      
      private function _GWizTrigCalcOblique_GWizNumStepOvr6_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "C";
         _loc1_.labelWidth = 20;
         _loc1_.x = 10;
         _loc1_.y = 190;
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.min = 0;
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
      
      private function _GWizTrigCalcOblique_Button1_i() : Button
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
      
      private function _GWizTrigCalcOblique_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Specify 2 angles and 1 side OR 2 sides and 1 angle.";
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
      
      public function ___GWizTrigCalcOblique_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.restoreViewData();
      }
      
      private function _GWizTrigCalcOblique_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Function
         {
            return drawShape;
         },null,"gridArea.drawFunc");
         result[1] = new Binding(this,function():Number
         {
            return Math.min(sx2 + 5,gridArea.width - (AAngleLabel.width + 20));
         },null,"AAngleLabel.x");
         result[2] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - 15;
         },null,"AAngleLabel.y");
         result[3] = new Binding(this,function():Number
         {
            return Math.min(gridArea.width - bSideLabel.width,(sx1 + sx2) / 2 - 20);
         },null,"bSideLabel.x");
         result[4] = new Binding(this,function():Number
         {
            return gridArea.yOrigin + 3;
         },null,"bSideLabel.y");
         result[5] = new Binding(this,function():Number
         {
            return Math.min(gridArea.width - aSideLabel.width,(sx1 + sx3) / 2 - (aSideLabel.width + 3));
         },null,"aSideLabel.x");
         result[6] = new Binding(this,function():Number
         {
            return (sy1 + sy3) / 2 + (CAngle.getVal() > 90 ? 15 : -15);
         },null,"aSideLabel.y");
         result[7] = new Binding(this,function():Number
         {
            return Math.min(sx3 + 5,gridArea.width - (BAngleLabel.width + 20));
         },null,"BAngleLabel.x");
         result[8] = new Binding(this,function():Number
         {
            return sy3 - 15;
         },null,"BAngleLabel.y");
         result[9] = new Binding(this,function():Number
         {
            return Math.min(gridArea.width - cSideLabel.width,(sx2 + sx3) / 2 + 5);
         },null,"cSideLabel.x");
         result[10] = new Binding(this,function():Number
         {
            return (sy2 + sy3) / 2 + (AAngle.getVal() > 90 ? 15 : -15);
         },null,"cSideLabel.y");
         result[11] = new Binding(this,function():Number
         {
            return Math.max(sx1 - (CAngleLabel.width + 20),0);
         },null,"CAngleLabel.x");
         result[12] = new Binding(this,function():Number
         {
            return gridArea.yOrigin + 3;
         },null,"CAngleLabel.y");
         result[13] = new Binding(this,function():Boolean
         {
            return drawDefault;
         },null,"messageLabel.visible");
         result[14] = new Binding(this,function():Number
         {
            return gridArea.xOrigin - 20;
         },null,"messageLabel.width");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get AAngle() : GWizNumStepOvr
      {
         return this._1924303122AAngle;
      }
      
      public function set AAngle(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1924303122AAngle;
         if(_loc2_ !== param1)
         {
            this._1924303122AAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"AAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get AAngleLabel() : Label
      {
         return this._1468981506AAngleLabel;
      }
      
      public function set AAngleLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1468981506AAngleLabel;
         if(_loc2_ !== param1)
         {
            this._1468981506AAngleLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"AAngleLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get BAngle() : GWizNumStepOvr
      {
         return this._1952932273BAngle;
      }
      
      public function set BAngle(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1952932273BAngle;
         if(_loc2_ !== param1)
         {
            this._1952932273BAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"BAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get BAngleLabel() : Label
      {
         return this._327969853BAngleLabel;
      }
      
      public function set BAngleLabel(param1:Label) : void
      {
         var _loc2_:Object = this._327969853BAngleLabel;
         if(_loc2_ !== param1)
         {
            this._327969853BAngleLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"BAngleLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CAngle() : GWizNumStepOvr
      {
         return this._1981561424CAngle;
      }
      
      public function set CAngle(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1981561424CAngle;
         if(_loc2_ !== param1)
         {
            this._1981561424CAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CAngleLabel() : Label
      {
         return this._2124921212CAngleLabel;
      }
      
      public function set CAngleLabel(param1:Label) : void
      {
         var _loc2_:Object = this._2124921212CAngleLabel;
         if(_loc2_ !== param1)
         {
            this._2124921212CAngleLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CAngleLabel",_loc2_,param1));
            }
         }
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
      
      [Bindable(event="propertyChange")]
      private function get sx1() : Number
      {
         return this._114284sx1;
      }
      
      private function set sx1(param1:Number) : void
      {
         var _loc2_:Object = this._114284sx1;
         if(_loc2_ !== param1)
         {
            this._114284sx1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sx1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get sx2() : Number
      {
         return this._114285sx2;
      }
      
      private function set sx2(param1:Number) : void
      {
         var _loc2_:Object = this._114285sx2;
         if(_loc2_ !== param1)
         {
            this._114285sx2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sx2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get sx3() : Number
      {
         return this._114286sx3;
      }
      
      private function set sx3(param1:Number) : void
      {
         var _loc2_:Object = this._114286sx3;
         if(_loc2_ !== param1)
         {
            this._114286sx3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sx3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get sy1() : Number
      {
         return this._114315sy1;
      }
      
      private function set sy1(param1:Number) : void
      {
         var _loc2_:Object = this._114315sy1;
         if(_loc2_ !== param1)
         {
            this._114315sy1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sy1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get sy2() : Number
      {
         return this._114316sy2;
      }
      
      private function set sy2(param1:Number) : void
      {
         var _loc2_:Object = this._114316sy2;
         if(_loc2_ !== param1)
         {
            this._114316sy2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sy2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get sy3() : Number
      {
         return this._114317sy3;
      }
      
      private function set sy3(param1:Number) : void
      {
         var _loc2_:Object = this._114317sy3;
         if(_loc2_ !== param1)
         {
            this._114317sy3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sy3",_loc2_,param1));
            }
         }
      }
   }
}
