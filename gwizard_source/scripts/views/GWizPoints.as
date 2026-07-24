package views
{
   import comps.GWizNumStep;
   import comps.GridComponent;
   import flash.display.Graphics;
   import flash.events.Event;
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
   import mx.events.PropertyChangeEvent;
   import skins.GridSkin;
   import spark.components.Button;
   import spark.components.Label;
   import spark.components.VGroup;
   import utils.GWizUtils;
   import utils.GraphicsUtil;
   
   use namespace mx_internal;
   
   public class GWizPoints extends VGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _65A:Label;
      
      private var _66B:Label;
      
      private var _67C:Label;
      
      private var _65193517Clear:Button;
      
      private var _2196DX:Label;
      
      private var _2197DY:Label;
      
      private var _2198DZ:Label;
      
      private var _567551945P1P2Dist:Label;
      
      private var _78487P1X:GWizNumStep;
      
      private var _78488P1Y:GWizNumStep;
      
      private var _78489P1Z:GWizNumStep;
      
      private var _78518P2X:GWizNumStep;
      
      private var _78519P2Y:GWizNumStep;
      
      private var _78520P2Z:GWizNumStep;
      
      public var _GWizPoints_Label1:Label;
      
      public var _GWizPoints_Label2:Label;
      
      public var _GWizPoints_Label3:Label;
      
      public var _GWizPoints_Label4:Label;
      
      public var _GWizPoints_Label5:Label;
      
      public var _GWizPoints_Label6:Label;
      
      public var _GWizPoints_Label7:Label;
      
      public var _GWizPoints_Label8:Label;
      
      private var _317504755gridArea:GridComponent;
      
      private var _119159xyX:Label;
      
      private var _119160xyY:Label;
      
      private var _3695071xyzX:Label;
      
      private var _3695072xyzY:Label;
      
      private var _3695073xyzZ:Label;
      
      private var _119190xzX:Label;
      
      private var _119192xzZ:Label;
      
      private var _120152yzY:Label;
      
      private var _120153yzZ:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var aDegrees:Number = 0;
      
      private var bDegrees:Number = 0;
      
      private var cDegrees:Number = 0;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizPoints()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizPoints_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_views_GWizPointsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizPoints[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.paddingBottom = 10;
         this.paddingLeft = 10;
         this.paddingRight = 10;
         this.paddingTop = 10;
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContent = [this._GWizPoints_GridComponent1_i()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizPoints._watcherSetupUtil = param1;
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
      
      private function recalc() : void
      {
         var _loc1_:Number = GWizUtils.roundTenths(Math.abs(this.P1X.getVal() - this.P2X.getVal()));
         var _loc2_:Number = GWizUtils.roundTenths(Math.abs(this.P1Y.getVal() - this.P2Y.getVal()));
         var _loc3_:Number = GWizUtils.roundTenths(Math.abs(this.P1Z.getVal() - this.P2Z.getVal()));
         this.DX.text = String(_loc1_);
         this.DY.text = String(_loc2_);
         this.DZ.text = String(_loc3_);
         this.P1P2Dist.text = GWizUtils.sroundTenths(String(Math.sqrt(_loc1_ * _loc1_ + _loc2_ * _loc2_ + _loc3_ * _loc3_)));
         this.C.text = GWizUtils.roundTenths2Str(this.cDegrees = GWizUtils.degrees(Math.atan(_loc2_ / _loc1_))) + "°";
         this.B.text = GWizUtils.roundTenths2Str(this.bDegrees = GWizUtils.degrees(Math.atan(_loc1_ / _loc3_))) + "°";
         this.A.text = GWizUtils.roundTenths2Str(this.aDegrees = GWizUtils.degrees(Math.atan(_loc3_ / _loc2_))) + "°";
         this.gridArea.redraw();
      }
      
      private function clear() : void
      {
         this.P1X.setVal(0);
         this.P1Y.setVal(0);
         this.P1Z.setVal(0);
         this.P2X.setVal(0);
         this.P2Y.setVal(0);
         this.P2Z.setVal(0);
         this.recalc();
      }
      
      private function drawVisuals(param1:Graphics) : void
      {
         param1.lineStyle(1,0,1);
         param1.drawCircle(this.gridArea.xOrigin - 100,this.gridArea.yOrigin + 50,3);
         param1.drawCircle(this.gridArea.xOrigin + 120,this.gridArea.yOrigin - 50,3);
         param1.moveTo(this.gridArea.xOrigin - 100,this.gridArea.yOrigin + 50);
         param1.lineTo(this.gridArea.xOrigin + 120,this.gridArea.yOrigin - 50);
         var _loc2_:Point = new Point(GridComponent.gridSpacing,Math.round((this.gridArea.height - GridComponent.gridSpacing) / GridComponent.gridSpacing) * GridComponent.gridSpacing);
         var _loc3_:Point = new Point(GridComponent.gridSpacing * 5,Math.round((this.gridArea.height - GridComponent.gridSpacing * 4) / GridComponent.gridSpacing) * GridComponent.gridSpacing);
         var _loc4_:Point = new Point(GridComponent.gridSpacing * 5,Math.round((this.gridArea.height - GridComponent.gridSpacing) / GridComponent.gridSpacing) * GridComponent.gridSpacing);
         var _loc5_:Point = new Point(GridComponent.gridSpacing,Math.round((this.gridArea.height - GridComponent.gridSpacing * 4) / GridComponent.gridSpacing) * GridComponent.gridSpacing);
         this.drawSmallAxes(param1,_loc2_,!isNaN(this.bDegrees),this.bDegrees);
         param1.lineStyle(1,0,1);
         this.drawSmallAxes(param1,_loc5_);
         param1.moveTo(_loc5_.x,_loc5_.y);
         param1.lineTo(_loc5_.x + GridComponent.gridSpacing,_loc5_.y - GridComponent.gridSpacing);
         param1.lineStyle(1,0,1);
         this.drawSmallAxes(param1,_loc4_,!isNaN(this.aDegrees),this.aDegrees);
         param1.lineStyle(1,0,1);
         this.drawSmallAxes(param1,_loc3_,!isNaN(this.cDegrees),this.cDegrees);
         this.A.x = _loc4_.x + GridComponent.gridSpacing + 5;
         this.A.y = _loc4_.y - GridComponent.gridSpacing / 2;
         this.B.x = _loc2_.x + GridComponent.gridSpacing + 5;
         this.B.y = _loc2_.y - GridComponent.gridSpacing / 2;
         this.C.x = _loc3_.x + GridComponent.gridSpacing + 5;
         this.C.y = _loc3_.y - GridComponent.gridSpacing / 2;
         this.xyzX.x = _loc5_.x + GridComponent.gridSpacing * 2 + 4;
         this.xyzX.y = _loc5_.y - 5;
         this.xyzZ.x = _loc5_.x - this.xyzY.width / 2;
         this.xyzZ.y = _loc5_.y - (GridComponent.gridSpacing * 2 + this.xyzY.height);
         this.xyzY.x = _loc5_.x + GridComponent.gridSpacing + 4;
         this.xyzY.y = _loc5_.y - (GridComponent.gridSpacing + this.xyzY.height);
         this.xyX.x = _loc3_.x + GridComponent.gridSpacing * 2 + 4;
         this.xyX.y = _loc3_.y - 5;
         this.xyY.x = _loc3_.x - this.xyY.width / 2;
         this.xyY.y = _loc3_.y - (GridComponent.gridSpacing * 2 + this.xyY.height);
         this.xzX.x = _loc2_.x + GridComponent.gridSpacing * 2 + 4;
         this.xzX.y = _loc2_.y - 5;
         this.xzZ.x = _loc2_.x - this.xzZ.width / 2;
         this.xzZ.y = _loc2_.y - (GridComponent.gridSpacing * 2 + this.xzZ.height);
         this.yzY.x = _loc4_.x + GridComponent.gridSpacing * 2 + 4;
         this.yzY.y = _loc4_.y - 5;
         this.yzZ.x = _loc4_.x - this.yzZ.width / 2;
         this.yzZ.y = _loc4_.y - (GridComponent.gridSpacing * 2 + this.yzZ.height);
      }
      
      private function drawSmallAxes(param1:Graphics, param2:Point, param3:Boolean = false, param4:Number = 90) : void
      {
         var _loc6_:Number = NaN;
         var _loc5_:Number = GridComponent.gridSpacing * 2;
         param1.moveTo(param2.x,param2.y - _loc5_);
         param1.lineTo(param2.x,param2.y);
         param1.lineTo(param2.x + _loc5_,param2.y);
         if(param3)
         {
            param1.lineStyle(1,255,1);
            _loc6_ = GWizUtils.radians(param4);
            GraphicsUtil.drawArc(param1,param2,GridComponent.gridSpacing,360 - (param4 + 4),4);
            param1.moveTo(param2.x + Math.cos(_loc6_) * _loc5_,param2.y - Math.sin(_loc6_) * _loc5_);
            param1.lineTo(param2.x,param2.y);
            param1.lineTo(param2.x + _loc5_,param2.y);
         }
      }
      
      private function _GWizPoints_GridComponent1_i() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.xOriginPos = 20;
         _loc1_.yOriginPos = 30;
         _loc1_.drawFunc = this.drawVisuals;
         _loc1_.hideNegativeAxis = true;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizPoints_Array2_c);
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
      
      private function _GWizPoints_Array2_c() : Array
      {
         return [this._GWizPoints_Label1_i(),this._GWizPoints_Label2_i(),this._GWizPoints_GWizNumStep1_i(),this._GWizPoints_Label3_i(),this._GWizPoints_GWizNumStep2_i(),this._GWizPoints_Label4_i(),this._GWizPoints_GWizNumStep3_i(),this._GWizPoints_Label5_i(),this._GWizPoints_Label6_i(),this._GWizPoints_GWizNumStep4_i(),this._GWizPoints_Label7_i(),this._GWizPoints_GWizNumStep5_i(),this._GWizPoints_Label8_i(),this._GWizPoints_GWizNumStep6_i(),this._GWizPoints_Label9_i(),this._GWizPoints_Label10_i(),this._GWizPoints_Label11_i(),this._GWizPoints_Label12_i(),this._GWizPoints_Label13_c(),this._GWizPoints_Label14_c(),this._GWizPoints_Label15_i(),this._GWizPoints_Label16_c(),this._GWizPoints_Label17_i(),this._GWizPoints_Label18_c(),this._GWizPoints_Label19_i(),this._GWizPoints_Label20_c(),this._GWizPoints_Label21_i(),this._GWizPoints_Label22_i(),this._GWizPoints_Label23_i(),this._GWizPoints_Label24_i(),this._GWizPoints_Label25_i(),this._GWizPoints_Label26_i(),this._GWizPoints_Label27_i(),this._GWizPoints_Label28_i(),this._GWizPoints_Label29_i(),this._GWizPoints_Button1_i()];
      }
      
      private function _GWizPoints_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "P2";
         _loc1_.setStyle("textDecoration","underline");
         _loc1_.id = "_GWizPoints_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizPoints_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizPoints_Label1",this._GWizPoints_Label1);
         return _loc1_;
      }
      
      private function _GWizPoints_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "X";
         _loc1_.id = "_GWizPoints_Label2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizPoints_Label2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizPoints_Label2",this._GWizPoints_Label2);
         return _loc1_;
      }
      
      private function _GWizPoints_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.width = 77;
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__P2X_change);
         _loc1_.id = "P2X";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.P2X = _loc1_;
         BindingManager.executeBindings(this,"P2X",this.P2X);
         return _loc1_;
      }
      
      public function __P2X_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizPoints_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Y";
         _loc1_.id = "_GWizPoints_Label3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizPoints_Label3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizPoints_Label3",this._GWizPoints_Label3);
         return _loc1_;
      }
      
      private function _GWizPoints_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.width = 77;
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__P2Y_change);
         _loc1_.id = "P2Y";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.P2Y = _loc1_;
         BindingManager.executeBindings(this,"P2Y",this.P2Y);
         return _loc1_;
      }
      
      public function __P2Y_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizPoints_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Z";
         _loc1_.id = "_GWizPoints_Label4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizPoints_Label4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizPoints_Label4",this._GWizPoints_Label4);
         return _loc1_;
      }
      
      private function _GWizPoints_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.width = 77;
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__P2Z_change);
         _loc1_.id = "P2Z";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.P2Z = _loc1_;
         BindingManager.executeBindings(this,"P2Z",this.P2Z);
         return _loc1_;
      }
      
      public function __P2Z_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizPoints_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 10;
         _loc1_.text = "P1";
         _loc1_.setStyle("textDecoration","underline");
         _loc1_.id = "_GWizPoints_Label5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizPoints_Label5 = _loc1_;
         BindingManager.executeBindings(this,"_GWizPoints_Label5",this._GWizPoints_Label5);
         return _loc1_;
      }
      
      private function _GWizPoints_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 10;
         _loc1_.text = "X";
         _loc1_.id = "_GWizPoints_Label6";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizPoints_Label6 = _loc1_;
         BindingManager.executeBindings(this,"_GWizPoints_Label6",this._GWizPoints_Label6);
         return _loc1_;
      }
      
      private function _GWizPoints_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.x = 25;
         _loc1_.width = 77;
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__P1X_change);
         _loc1_.id = "P1X";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.P1X = _loc1_;
         BindingManager.executeBindings(this,"P1X",this.P1X);
         return _loc1_;
      }
      
      public function __P1X_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizPoints_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 10;
         _loc1_.text = "Y";
         _loc1_.id = "_GWizPoints_Label7";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizPoints_Label7 = _loc1_;
         BindingManager.executeBindings(this,"_GWizPoints_Label7",this._GWizPoints_Label7);
         return _loc1_;
      }
      
      private function _GWizPoints_GWizNumStep5_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.x = 25;
         _loc1_.width = 77;
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__P1Y_change);
         _loc1_.id = "P1Y";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.P1Y = _loc1_;
         BindingManager.executeBindings(this,"P1Y",this.P1Y);
         return _loc1_;
      }
      
      public function __P1Y_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizPoints_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 10;
         _loc1_.text = "Z";
         _loc1_.id = "_GWizPoints_Label8";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizPoints_Label8 = _loc1_;
         BindingManager.executeBindings(this,"_GWizPoints_Label8",this._GWizPoints_Label8);
         return _loc1_;
      }
      
      private function _GWizPoints_GWizNumStep6_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.x = 25;
         _loc1_.width = 77;
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__P1Z_change);
         _loc1_.id = "P1Z";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.P1Z = _loc1_;
         BindingManager.executeBindings(this,"P1Z",this.P1Z);
         return _loc1_;
      }
      
      public function __P1Z_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizPoints_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 266;
         _loc1_.y = 280;
         _loc1_.width = 77;
         _loc1_.id = "C";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.C = _loc1_;
         BindingManager.executeBindings(this,"C",this.C);
         return _loc1_;
      }
      
      private function _GWizPoints_Label10_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 61;
         _loc1_.y = 395;
         _loc1_.width = 77;
         _loc1_.id = "B";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.B = _loc1_;
         BindingManager.executeBindings(this,"B",this.B);
         return _loc1_;
      }
      
      private function _GWizPoints_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 266;
         _loc1_.y = 395;
         _loc1_.width = 77;
         _loc1_.id = "A";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.A = _loc1_;
         BindingManager.executeBindings(this,"A",this.A);
         return _loc1_;
      }
      
      private function _GWizPoints_Label12_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 462;
         _loc1_.y = 306;
         _loc1_.width = 77;
         _loc1_.id = "P1P2Dist";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.P1P2Dist = _loc1_;
         BindingManager.executeBindings(this,"P1P2Dist",this.P1P2Dist);
         return _loc1_;
      }
      
      private function _GWizPoints_Label13_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 399;
         _loc1_.y = 280;
         _loc1_.text = "Distances:";
         _loc1_.setStyle("textDecoration","underline");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPoints_Label14_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 399;
         _loc1_.y = 306;
         _loc1_.text = "P1 - P2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPoints_Label15_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 462;
         _loc1_.y = 334;
         _loc1_.width = 77;
         _loc1_.id = "DX";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DX = _loc1_;
         BindingManager.executeBindings(this,"DX",this.DX);
         return _loc1_;
      }
      
      private function _GWizPoints_Label16_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 399;
         _loc1_.y = 334;
         _loc1_.text = "DX";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPoints_Label17_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 462;
         _loc1_.y = 362;
         _loc1_.width = 77;
         _loc1_.id = "DY";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DY = _loc1_;
         BindingManager.executeBindings(this,"DY",this.DY);
         return _loc1_;
      }
      
      private function _GWizPoints_Label18_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 399;
         _loc1_.y = 362;
         _loc1_.text = "DY";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPoints_Label19_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 462;
         _loc1_.y = 390;
         _loc1_.width = 77;
         _loc1_.id = "DZ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DZ = _loc1_;
         BindingManager.executeBindings(this,"DZ",this.DZ);
         return _loc1_;
      }
      
      private function _GWizPoints_Label20_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 399;
         _loc1_.y = 390;
         _loc1_.text = "DZ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPoints_Label21_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "X";
         _loc1_.id = "xyzX";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xyzX = _loc1_;
         BindingManager.executeBindings(this,"xyzX",this.xyzX);
         return _loc1_;
      }
      
      private function _GWizPoints_Label22_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Y";
         _loc1_.id = "xyzY";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xyzY = _loc1_;
         BindingManager.executeBindings(this,"xyzY",this.xyzY);
         return _loc1_;
      }
      
      private function _GWizPoints_Label23_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Z";
         _loc1_.id = "xyzZ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xyzZ = _loc1_;
         BindingManager.executeBindings(this,"xyzZ",this.xyzZ);
         return _loc1_;
      }
      
      private function _GWizPoints_Label24_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "X";
         _loc1_.id = "xyX";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xyX = _loc1_;
         BindingManager.executeBindings(this,"xyX",this.xyX);
         return _loc1_;
      }
      
      private function _GWizPoints_Label25_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Y";
         _loc1_.id = "xyY";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xyY = _loc1_;
         BindingManager.executeBindings(this,"xyY",this.xyY);
         return _loc1_;
      }
      
      private function _GWizPoints_Label26_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Y";
         _loc1_.id = "yzY";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.yzY = _loc1_;
         BindingManager.executeBindings(this,"yzY",this.yzY);
         return _loc1_;
      }
      
      private function _GWizPoints_Label27_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Z";
         _loc1_.id = "yzZ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.yzZ = _loc1_;
         BindingManager.executeBindings(this,"yzZ",this.yzZ);
         return _loc1_;
      }
      
      private function _GWizPoints_Label28_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "X";
         _loc1_.id = "xzX";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xzX = _loc1_;
         BindingManager.executeBindings(this,"xzX",this.xzX);
         return _loc1_;
      }
      
      private function _GWizPoints_Label29_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Z";
         _loc1_.id = "xzZ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xzZ = _loc1_;
         BindingManager.executeBindings(this,"xzZ",this.xzZ);
         return _loc1_;
      }
      
      private function _GWizPoints_Button1_i() : Button
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
      
      private function _GWizPoints_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + 120;
         },null,"_GWizPoints_Label1.x");
         result[1] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - 45;
         },null,"_GWizPoints_Label1.y");
         result[2] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + 120;
         },null,"_GWizPoints_Label2.x");
         result[3] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - 19;
         },null,"_GWizPoints_Label2.y");
         result[4] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + 135;
         },null,"P2X.x");
         result[5] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - 25;
         },null,"P2X.y");
         result[6] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + 120;
         },null,"_GWizPoints_Label3.x");
         result[7] = new Binding(this,function():Number
         {
            return gridArea.yOrigin + 9;
         },null,"_GWizPoints_Label3.y");
         result[8] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + 135;
         },null,"P2Y.x");
         result[9] = new Binding(this,function():Number
         {
            return gridArea.yOrigin + 3;
         },null,"P2Y.y");
         result[10] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + 120;
         },null,"_GWizPoints_Label4.x");
         result[11] = new Binding(this,function():Number
         {
            return gridArea.yOrigin + 37;
         },null,"_GWizPoints_Label4.y");
         result[12] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + 135;
         },null,"P2Z.x");
         result[13] = new Binding(this,function():Number
         {
            return gridArea.yOrigin + 31;
         },null,"P2Z.y");
         result[14] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - 73;
         },null,"_GWizPoints_Label5.y");
         result[15] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - 48;
         },null,"_GWizPoints_Label6.y");
         result[16] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - 52;
         },null,"P1X.y");
         result[17] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - 20;
         },null,"_GWizPoints_Label7.y");
         result[18] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - 24;
         },null,"P1Y.y");
         result[19] = new Binding(this,function():Number
         {
            return gridArea.yOrigin + 8;
         },null,"_GWizPoints_Label8.y");
         result[20] = new Binding(this,function():Number
         {
            return gridArea.yOrigin + 4;
         },null,"P1Z.y");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get A() : Label
      {
         return this._65A;
      }
      
      public function set A(param1:Label) : void
      {
         var _loc2_:Object = this._65A;
         if(_loc2_ !== param1)
         {
            this._65A = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"A",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get B() : Label
      {
         return this._66B;
      }
      
      public function set B(param1:Label) : void
      {
         var _loc2_:Object = this._66B;
         if(_loc2_ !== param1)
         {
            this._66B = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"B",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get C() : Label
      {
         return this._67C;
      }
      
      public function set C(param1:Label) : void
      {
         var _loc2_:Object = this._67C;
         if(_loc2_ !== param1)
         {
            this._67C = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"C",_loc2_,param1));
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
      public function get DX() : Label
      {
         return this._2196DX;
      }
      
      public function set DX(param1:Label) : void
      {
         var _loc2_:Object = this._2196DX;
         if(_loc2_ !== param1)
         {
            this._2196DX = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DX",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get DY() : Label
      {
         return this._2197DY;
      }
      
      public function set DY(param1:Label) : void
      {
         var _loc2_:Object = this._2197DY;
         if(_loc2_ !== param1)
         {
            this._2197DY = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DY",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get DZ() : Label
      {
         return this._2198DZ;
      }
      
      public function set DZ(param1:Label) : void
      {
         var _loc2_:Object = this._2198DZ;
         if(_loc2_ !== param1)
         {
            this._2198DZ = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DZ",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get P1P2Dist() : Label
      {
         return this._567551945P1P2Dist;
      }
      
      public function set P1P2Dist(param1:Label) : void
      {
         var _loc2_:Object = this._567551945P1P2Dist;
         if(_loc2_ !== param1)
         {
            this._567551945P1P2Dist = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"P1P2Dist",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get P1X() : GWizNumStep
      {
         return this._78487P1X;
      }
      
      public function set P1X(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._78487P1X;
         if(_loc2_ !== param1)
         {
            this._78487P1X = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"P1X",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get P1Y() : GWizNumStep
      {
         return this._78488P1Y;
      }
      
      public function set P1Y(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._78488P1Y;
         if(_loc2_ !== param1)
         {
            this._78488P1Y = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"P1Y",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get P1Z() : GWizNumStep
      {
         return this._78489P1Z;
      }
      
      public function set P1Z(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._78489P1Z;
         if(_loc2_ !== param1)
         {
            this._78489P1Z = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"P1Z",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get P2X() : GWizNumStep
      {
         return this._78518P2X;
      }
      
      public function set P2X(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._78518P2X;
         if(_loc2_ !== param1)
         {
            this._78518P2X = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"P2X",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get P2Y() : GWizNumStep
      {
         return this._78519P2Y;
      }
      
      public function set P2Y(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._78519P2Y;
         if(_loc2_ !== param1)
         {
            this._78519P2Y = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"P2Y",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get P2Z() : GWizNumStep
      {
         return this._78520P2Z;
      }
      
      public function set P2Z(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._78520P2Z;
         if(_loc2_ !== param1)
         {
            this._78520P2Z = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"P2Z",_loc2_,param1));
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
      public function get xyX() : Label
      {
         return this._119159xyX;
      }
      
      public function set xyX(param1:Label) : void
      {
         var _loc2_:Object = this._119159xyX;
         if(_loc2_ !== param1)
         {
            this._119159xyX = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xyX",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get xyY() : Label
      {
         return this._119160xyY;
      }
      
      public function set xyY(param1:Label) : void
      {
         var _loc2_:Object = this._119160xyY;
         if(_loc2_ !== param1)
         {
            this._119160xyY = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xyY",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get xyzX() : Label
      {
         return this._3695071xyzX;
      }
      
      public function set xyzX(param1:Label) : void
      {
         var _loc2_:Object = this._3695071xyzX;
         if(_loc2_ !== param1)
         {
            this._3695071xyzX = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xyzX",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get xyzY() : Label
      {
         return this._3695072xyzY;
      }
      
      public function set xyzY(param1:Label) : void
      {
         var _loc2_:Object = this._3695072xyzY;
         if(_loc2_ !== param1)
         {
            this._3695072xyzY = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xyzY",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get xyzZ() : Label
      {
         return this._3695073xyzZ;
      }
      
      public function set xyzZ(param1:Label) : void
      {
         var _loc2_:Object = this._3695073xyzZ;
         if(_loc2_ !== param1)
         {
            this._3695073xyzZ = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xyzZ",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get xzX() : Label
      {
         return this._119190xzX;
      }
      
      public function set xzX(param1:Label) : void
      {
         var _loc2_:Object = this._119190xzX;
         if(_loc2_ !== param1)
         {
            this._119190xzX = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xzX",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get xzZ() : Label
      {
         return this._119192xzZ;
      }
      
      public function set xzZ(param1:Label) : void
      {
         var _loc2_:Object = this._119192xzZ;
         if(_loc2_ !== param1)
         {
            this._119192xzZ = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xzZ",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get yzY() : Label
      {
         return this._120152yzY;
      }
      
      public function set yzY(param1:Label) : void
      {
         var _loc2_:Object = this._120152yzY;
         if(_loc2_ !== param1)
         {
            this._120152yzY = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"yzY",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get yzZ() : Label
      {
         return this._120153yzZ;
      }
      
      public function set yzZ(param1:Label) : void
      {
         var _loc2_:Object = this._120153yzZ;
         if(_loc2_ !== param1)
         {
            this._120153yzZ = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"yzZ",_loc2_,param1));
            }
         }
      }
   }
}
