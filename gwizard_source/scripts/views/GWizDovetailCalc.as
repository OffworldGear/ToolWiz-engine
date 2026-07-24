package views
{
   import comps.GWizNumStepOvr;
   import comps.GridComponent;
   import flash.accessibility.*;
   import flash.data.*;
   import flash.debugger.*;
   import flash.desktop.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filesystem.*;
   import flash.geom.*;
   import flash.html.*;
   import flash.html.script.*;
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
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.events.ResizeEvent;
   import mx.filters.*;
   import mx.graphics.SolidColorStroke;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.styles.*;
   import skins.GridSkin;
   import spark.components.Button;
   import spark.components.Group;
   import spark.components.Label;
   import spark.components.VGroup;
   import spark.layouts.VerticalLayout;
   import spark.primitives.Rect;
   import utils.GWizUtils;
   import utils.GraphicsUtil;
   
   use namespace mx_internal;
   
   public class GWizDovetailCalc extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizBoltCircles");
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _65193517Clear:Button;
      
      private var _1413176898angle1:GWizNumStepOvr;
      
      private var _1413176897angle2:GWizNumStepOvr;
      
      private var _3083061dia1:GWizNumStepOvr;
      
      private var _3083062dia2:GWizNumStepOvr;
      
      private var _263817256diaLabel:Label;
      
      private var _317504755gridArea:GridComponent;
      
      private var _1252712863gridArea2:GridComponent;
      
      private var _100355670inner:GWizNumStepOvr;
      
      private var _528013325innerRoll:GWizNumStepOvr;
      
      private var _106111099outer:GWizNumStepOvr;
      
      private var _1856987032outerRoll:GWizNumStepOvr;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var lastDrawDefault:Boolean = true;
      
      private var _1427080253scaledPlatformHeight1:Number = 10;
      
      private var _1427080254scaledPlatformHeight2:Number = 10;
      
      private var _1289531087scaledPlatformCenter1:Number = 200;
      
      private var _1289531088scaledPlatformCenter2:Number = 200;
      
      private var _1200461142scaledDoveHeight1:Number;
      
      private var _1200461143scaledDoveHeight2:Number;
      
      private var doveHeight:Number;
      
      private var platformWidth:Number;
      
      private var a1:Number = 45;
      
      private var a2:Number = 45;
      
      private var d1:Number = 1;
      
      private var d2:Number = 1;
      
      private var outroll:Number = 11.4;
      
      private var inroll:Number = 7.6;
      
      private var inlen:Number = 8;
      
      private var outlen:Number = 11;
      
      private var drawReady:Boolean = false;
      
      private var _1160712663leftOuterRollOrigin:Point;
      
      private var rightOuterRollOrigin:Point;
      
      private var leftInnerRollOrigin:Point;
      
      private var rightInnerRollOrigin:Point;
      
      private var drawCommands:Vector.<int>;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizDovetailCalc()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._1160712663leftOuterRollOrigin = new Point();
         this.rightOuterRollOrigin = new Point();
         this.leftInnerRollOrigin = new Point();
         this.rightInnerRollOrigin = new Point();
         this.drawCommands = new <int>[1,2,2,2,2,2,2,2,2];
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizDovetailCalc_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_views_GWizDovetailCalcWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizDovetailCalc[param1];
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
         this.mxmlContent = [this._GWizDovetailCalc_VGroup2_c()];
         this.addEventListener("creationComplete",this.___GWizDovetailCalc_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizDovetailCalc._watcherSetupUtil = param1;
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
      
      private function checkUnits() : void
      {
         this.recalc();
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
         var _loc1_:Number = NaN;
         this.drawReady = true;
         log.debug("Dovetail.recalc");
         _loc1_ = GWizUtils.radians(this.angle1.getVal() / 2);
         if(!this.outerRoll.isOverridden() && this.dia1.isOverridden() && _loc1_ > 0 && this.inner.isOverridden())
         {
            this.outerRoll.setVal(this.dia1.getVal() * (1 + Math.cos(_loc1_) / Math.sin(_loc1_)) + this.inner.getVal());
         }
         else if(!this.inner.isOverridden() && this.outerRoll.isOverridden() && this.dia1.isOverridden() && _loc1_ > 0)
         {
            this.inner.setVal(this.outerRoll.getVal() - this.dia1.getVal() * (1 + Math.cos(_loc1_) / Math.sin(_loc1_)));
         }
         _loc1_ = GWizUtils.radians(this.angle2.getVal() / 2);
         if(!this.innerRoll.isOverridden() && this.outer.isOverridden() && this.dia2.isOverridden() && _loc1_ > 0)
         {
            this.innerRoll.setVal(this.outer.getVal() - this.dia2.getVal() * (1 + Math.cos(_loc1_) / Math.sin(_loc1_)));
         }
         else if(!this.outer.isOverridden() && this.innerRoll.isOverridden() && this.dia2.isOverridden() && _loc1_ > 0)
         {
            this.outer.setVal(this.innerRoll.getVal() + this.dia2.getVal() * (1 + Math.cos(_loc1_) / Math.sin(_loc1_)));
         }
         this.redraw();
      }
      
      private function clearAll() : void
      {
         this.angle1.resetOverride(true);
         this.angle2.resetOverride(true);
         this.inner.resetOverride(true);
         this.outer.resetOverride(true);
         this.dia1.resetOverride(true);
         this.dia2.resetOverride(true);
         this.outerRoll.resetOverride(true);
         this.innerRoll.resetOverride(true);
         this.redraw();
      }
      
      private function redraw() : void
      {
         this.calcImagePoints();
         this.gridArea.redraw();
         this.gridArea2.redraw();
      }
      
      private function calcImagePoints() : void
      {
         this.a1 = 45;
         this.a2 = 45;
         this.d1 = 1;
         this.d2 = 1;
         this.outroll = 11.4;
         this.inroll = 7.6;
         this.inlen = 8;
         this.outlen = 11;
         if(this.angle1.getVal() > 0 && this.angle2.getVal() > 0 && this.dia1.getVal() > 0 && this.dia2.getVal() > 0 && this.outerRoll.getVal() > 0 && this.innerRoll.getVal() > 0 && this.inner.getVal() > 0 && this.outer.getVal() > 0)
         {
            this.a1 = this.angle1.getVal();
            this.a2 = this.angle2.getVal();
            this.d1 = this.dia1.getVal();
            this.d2 = this.dia2.getVal();
            this.outroll = this.outerRoll.getVal();
            this.inroll = this.innerRoll.getVal();
            this.inlen = this.inner.getVal();
            this.outlen = this.outer.getVal();
         }
         this.platformWidth = Math.max(this.inlen,this.outlen) * 1.5;
         this.doveHeight = Math.tan(GWizUtils.radians(this.a1)) * Math.abs((this.outlen - this.inlen) / 2);
      }
      
      private function drawOuterDoves(param1:Graphics) : void
      {
         if(!this.drawReady)
         {
            return;
         }
         this.scaledPlatformHeight1 = this.gridArea.height / 4;
         var _loc2_:Number = Math.min(this.gridArea.xMax / this.platformWidth,(this.gridArea.yMax - this.scaledPlatformHeight1) / this.doveHeight);
         this.scaledPlatformCenter1 = this.platformWidth / 2 * _loc2_;
         var _loc3_:Number = this.platformWidth * _loc2_;
         var _loc4_:Number = this.d1 * _loc2_;
         var _loc5_:Number = this.outroll * _loc2_;
         var _loc6_:Number = this.inlen * _loc2_;
         var _loc7_:Number = this.outlen * _loc2_;
         this.scaledDoveHeight1 = this.doveHeight * _loc2_;
         var _loc8_:Vector.<Number>;
         (_loc8_ = new Vector.<Number>(18,true))[0] = this.gridArea.xOrigin;
         _loc8_[1] = this.gridArea.yOrigin;
         _loc8_[2] = this.gridArea.xOrigin;
         _loc8_[3] = this.gridArea.yOrigin - this.scaledPlatformHeight1;
         _loc8_[4] = this.gridArea.xOrigin + (_loc3_ - _loc6_) / 2;
         _loc8_[5] = _loc8_[3];
         _loc8_[6] = this.gridArea.xOrigin + (_loc3_ - _loc7_) / 2;
         _loc8_[7] = this.gridArea.yOrigin - (this.scaledPlatformHeight1 + this.scaledDoveHeight1);
         _loc8_[8] = _loc8_[6] + _loc7_;
         _loc8_[9] = _loc8_[7];
         _loc8_[10] = _loc8_[4] + _loc6_;
         _loc8_[11] = _loc8_[3];
         _loc8_[12] = this.gridArea.xOrigin + _loc3_;
         _loc8_[13] = _loc8_[3];
         _loc8_[14] = _loc8_[12];
         _loc8_[15] = _loc8_[1];
         _loc8_[16] = _loc8_[0];
         _loc8_[17] = _loc8_[1];
         this.leftOuterRollOrigin = new Point(this.gridArea.xOrigin + ((_loc3_ - _loc5_) / 2 + _loc4_ / 2),this.gridArea.yOrigin - (this.scaledPlatformHeight1 + _loc4_ / 2));
         this.rightOuterRollOrigin = new Point(this.gridArea.xOrigin + _loc3_ - ((_loc3_ - _loc5_) / 2 + _loc4_ / 2),this.gridArea.yOrigin - (this.scaledPlatformHeight1 + _loc4_ / 2));
         param1.beginFill(0,0.2);
         param1.lineStyle(1,5592405,1);
         param1.drawPath(this.drawCommands,_loc8_);
         param1.endFill();
         param1.lineStyle(1,4473924);
         param1.drawCircle(this.leftOuterRollOrigin.x,this.leftOuterRollOrigin.y,_loc4_ / 2 - 1);
         param1.drawCircle(this.rightOuterRollOrigin.x,this.rightOuterRollOrigin.y,_loc4_ / 2 - 1);
         param1.lineStyle(1,14540287);
         param1.moveTo(this.leftOuterRollOrigin.x - _loc4_ / 2 + 1,this.leftOuterRollOrigin.y);
         param1.lineTo(this.leftOuterRollOrigin.x + _loc4_ / 2 - 1,this.leftOuterRollOrigin.y);
         param1.lineStyle(1,4473924);
         param1.moveTo(this.gridArea.xOrigin + (_loc3_ - _loc5_) / 2,this.gridArea.yOrigin - (this.scaledPlatformHeight1 + _loc4_ / 2));
         param1.lineTo(this.gridArea.xOrigin + (_loc3_ - _loc5_) / 2,this.gridArea.yOrigin - (this.scaledPlatformHeight1 - 50));
         param1.lineTo(this.gridArea.xOrigin + _loc3_ - (_loc3_ - _loc5_) / 2,this.gridArea.yOrigin - (this.scaledPlatformHeight1 - 50));
         param1.lineTo(this.gridArea.xOrigin + _loc3_ - (_loc3_ - _loc5_) / 2,this.gridArea.yOrigin - (this.scaledPlatformHeight1 + _loc4_ / 2));
         param1.moveTo(_loc8_[4],_loc8_[5]);
         param1.lineTo(_loc8_[4],_loc8_[5] + 10);
         param1.moveTo(_loc8_[10],_loc8_[11] + 10);
         param1.lineTo(_loc8_[10],_loc8_[11]);
         param1.beginFill(4473924,1);
         param1.lineStyle(0);
         GraphicsUtil.drawArrows(param1,new Point(this.gridArea.xOrigin + (_loc3_ - _loc5_) / 2,this.gridArea.yOrigin - (this.scaledPlatformHeight1 - 50)),new Point(this.gridArea.xOrigin + _loc3_ - (_loc3_ - _loc5_) / 2,this.gridArea.yOrigin - (this.scaledPlatformHeight1 - 50)));
         GraphicsUtil.drawArrows(param1,new Point(_loc8_[4],_loc8_[5] + 10),new Point(_loc8_[10],_loc8_[11] + 10));
         param1.endFill();
      }
      
      private function drawInnerDoves(param1:Graphics) : void
      {
         if(!this.drawReady)
         {
            return;
         }
         this.scaledPlatformHeight2 = this.gridArea2.height / 4;
         var _loc2_:Number = Math.min(this.gridArea2.xMax / this.platformWidth,(this.gridArea2.yMax - this.scaledPlatformHeight2) / this.doveHeight);
         this.scaledPlatformCenter2 = this.platformWidth / 2 * _loc2_;
         var _loc3_:Number = this.platformWidth * _loc2_;
         var _loc4_:Number = this.d2 * _loc2_;
         var _loc5_:Number = this.inroll * _loc2_;
         var _loc6_:Number = this.inlen * _loc2_;
         var _loc7_:Number = this.outlen * _loc2_;
         this.scaledDoveHeight2 = this.doveHeight * _loc2_;
         var _loc8_:Vector.<Number>;
         (_loc8_ = new Vector.<Number>(18,true))[0] = this.gridArea2.xOrigin;
         _loc8_[1] = this.gridArea2.yOrigin - (this.scaledPlatformHeight2 + this.scaledDoveHeight2);
         _loc8_[2] = this.gridArea2.xOrigin;
         _loc8_[3] = this.gridArea2.yOrigin;
         _loc8_[4] = this.gridArea2.xOrigin + (_loc3_ - _loc6_) / 2;
         _loc8_[5] = _loc8_[3];
         _loc8_[6] = this.gridArea2.xOrigin + (_loc3_ - _loc7_) / 2;
         _loc8_[7] = this.gridArea2.yOrigin - this.scaledDoveHeight2;
         _loc8_[8] = _loc8_[6] + _loc7_;
         _loc8_[9] = _loc8_[7];
         _loc8_[10] = _loc8_[4] + _loc6_;
         _loc8_[11] = _loc8_[3];
         _loc8_[12] = this.gridArea2.xOrigin + _loc3_;
         _loc8_[13] = _loc8_[3];
         _loc8_[14] = _loc8_[12];
         _loc8_[15] = _loc8_[1];
         _loc8_[16] = _loc8_[0];
         _loc8_[17] = _loc8_[1];
         this.leftInnerRollOrigin = new Point(this.gridArea2.xOrigin + ((_loc3_ - _loc5_) / 2 - _loc4_ / 2),this.gridArea2.yOrigin - (this.scaledDoveHeight2 - _loc4_ / 2));
         this.rightInnerRollOrigin = new Point(this.gridArea2.xOrigin + _loc3_ - ((_loc3_ - _loc5_) / 2 - _loc4_ / 2),this.gridArea2.yOrigin - (this.scaledDoveHeight2 - _loc4_ / 2));
         param1.beginFill(0,0.2);
         param1.lineStyle(1,5592405,1);
         param1.drawPath(this.drawCommands,_loc8_);
         param1.endFill();
         param1.lineStyle(1,4473924);
         param1.drawCircle(this.leftInnerRollOrigin.x,this.leftInnerRollOrigin.y,_loc4_ / 2 - 1);
         param1.drawCircle(this.rightInnerRollOrigin.x,this.rightInnerRollOrigin.y,_loc4_ / 2 - 1);
         param1.lineStyle(1,14540287);
         param1.moveTo(this.rightInnerRollOrigin.x - _loc4_ / 2 + 1,this.rightInnerRollOrigin.y);
         param1.lineTo(this.rightInnerRollOrigin.x + _loc4_ / 2 - 1,this.rightInnerRollOrigin.y);
         param1.lineStyle(1,4473924);
         param1.moveTo(this.gridArea2.xOrigin + (_loc3_ + _loc5_) / 2,this.gridArea2.yOrigin - (this.scaledDoveHeight2 - _loc4_ / 2));
         param1.lineTo(this.gridArea2.xOrigin + (_loc3_ + _loc5_) / 2,this.gridArea2.yOrigin - (this.scaledDoveHeight2 + 10));
         param1.lineTo(this.gridArea2.xOrigin + _loc3_ - (_loc3_ + _loc5_) / 2,this.gridArea2.yOrigin - (this.scaledDoveHeight2 + 10));
         param1.lineTo(this.gridArea2.xOrigin + _loc3_ - (_loc3_ + _loc5_) / 2,this.gridArea2.yOrigin - (this.scaledDoveHeight2 - _loc4_ / 2));
         param1.moveTo(_loc8_[6],_loc8_[7]);
         param1.lineTo(_loc8_[6],_loc8_[7] - 50);
         param1.moveTo(_loc8_[8],_loc8_[9] - 50);
         param1.lineTo(_loc8_[8],_loc8_[9]);
         param1.beginFill(4473924,1);
         param1.lineStyle(0);
         GraphicsUtil.drawArrows(param1,new Point(this.gridArea2.xOrigin + (_loc3_ + _loc5_) / 2,this.gridArea2.yOrigin - (this.scaledDoveHeight2 + 10)),new Point(this.gridArea2.xOrigin + _loc3_ - (_loc3_ + _loc5_) / 2,this.gridArea2.yOrigin - (this.scaledDoveHeight2 + 10)));
         GraphicsUtil.drawArrows(param1,new Point(_loc8_[6],_loc8_[7] - 50),new Point(_loc8_[8],_loc8_[9] - 50));
         param1.endFill();
         this.diaLabel.x = this.leftOuterRollOrigin.x - this.diaLabel.width / 2;
         this.diaLabel.y = this.leftOuterRollOrigin.y - 10;
      }
      
      private function clear() : void
      {
         this.angle1.resetOverride(true);
         this.inner.resetOverride(true);
         this.dia1.resetOverride(true);
         this.outerRoll.resetOverride(true);
         this.angle2.resetOverride(true);
         this.outer.resetOverride(true);
         this.dia2.resetOverride(true);
         this.innerRoll.resetOverride(true);
         this.recalc();
      }
      
      private function _GWizDovetailCalc_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.paddingBottom = 0;
         _loc1_.paddingLeft = 0;
         _loc1_.paddingRight = 0;
         _loc1_.paddingTop = 0;
         _loc1_.gap = 0;
         _loc1_.mxmlContent = [this._GWizDovetailCalc_Group1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizDovetailCalc_Group1_c() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.layout = this._GWizDovetailCalc_VerticalLayout1_c();
         _loc1_.mxmlContent = [this._GWizDovetailCalc_Group2_c(),this._GWizDovetailCalc_Group3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizDovetailCalc_VerticalLayout1_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.gap = 10;
         return _loc1_;
      }
      
      private function _GWizDovetailCalc_Group2_c() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizDovetailCalc_Rect1_c(),this._GWizDovetailCalc_GridComponent1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizDovetailCalc_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.stroke = this._GWizDovetailCalc_SolidColorStroke1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizDovetailCalc_SolidColorStroke1_c() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.color = 14150102;
         return _loc1_;
      }
      
      private function _GWizDovetailCalc_GridComponent1_i() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizDovetailCalc_Array5_c);
         _loc1_.setStyle("skinClass",GridSkin);
         _loc1_.addEventListener("resize",this.__gridArea_resize);
         _loc1_.id = "gridArea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gridArea = _loc1_;
         BindingManager.executeBindings(this,"gridArea",this.gridArea);
         return _loc1_;
      }
      
      private function _GWizDovetailCalc_Array5_c() : Array
      {
         return [this._GWizDovetailCalc_GWizNumStepOvr1_i(),this._GWizDovetailCalc_GWizNumStepOvr2_i(),this._GWizDovetailCalc_GWizNumStepOvr3_i(),this._GWizDovetailCalc_GWizNumStepOvr4_i(),this._GWizDovetailCalc_Label1_i(),this._GWizDovetailCalc_Button1_i()];
      }
      
      private function _GWizDovetailCalc_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "∠a (Reqd)";
         _loc1_.suffix = "°";
         _loc1_.min = 0;
         _loc1_.max = 360;
         _loc1_.steps = 0.0001;
         _loc1_.noUnits = true;
         _loc1_.horizontalLayout = false;
         _loc1_.addEventListener("valueCommit",this.__angle1_valueCommit);
         _loc1_.id = "angle1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.angle1 = _loc1_;
         BindingManager.executeBindings(this,"angle1",this.angle1);
         return _loc1_;
      }
      
      public function __angle1_valueCommit(param1:FlexEvent) : void
      {
         if(this.angle1.isOverridden())
         {
            this.angle2.setValOverride(this.angle1.getVal());
         }
         else
         {
            this.angle2.resetOverride(true);
         }
         this.recalc();
      }
      
      private function _GWizDovetailCalc_GWizNumStepOvr2_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Length";
         _loc1_.min = -100;
         _loc1_.steps = 0.0001;
         _loc1_.max = 100;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__inner_valueCommit);
         _loc1_.id = "inner";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.inner = _loc1_;
         BindingManager.executeBindings(this,"inner",this.inner);
         return _loc1_;
      }
      
      public function __inner_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizDovetailCalc_GWizNumStepOvr3_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Roll Diameter (Reqd)";
         _loc1_.y = 10;
         _loc1_.min = -100;
         _loc1_.steps = 0.0001;
         _loc1_.max = 100;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__dia1_valueCommit);
         _loc1_.id = "dia1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.dia1 = _loc1_;
         BindingManager.executeBindings(this,"dia1",this.dia1);
         return _loc1_;
      }
      
      public function __dia1_valueCommit(param1:FlexEvent) : void
      {
         if(this.dia1.isOverridden())
         {
            this.dia2.setValOverride(this.dia1.getVal());
         }
         else
         {
            this.dia2.resetOverride(true);
         }
         this.recalc();
      }
      
      private function _GWizDovetailCalc_GWizNumStepOvr4_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Distance";
         _loc1_.min = -100;
         _loc1_.steps = 0.0001;
         _loc1_.max = 100;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__outerRoll_valueCommit);
         _loc1_.id = "outerRoll";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.outerRoll = _loc1_;
         BindingManager.executeBindings(this,"outerRoll",this.outerRoll);
         return _loc1_;
      }
      
      public function __outerRoll_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizDovetailCalc_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "d";
         _loc1_.styleName = "fontSizeDelta-2";
         _loc1_.setStyle("fontStyle","italic");
         _loc1_.id = "diaLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.diaLabel = _loc1_;
         BindingManager.executeBindings(this,"diaLabel",this.diaLabel);
         return _loc1_;
      }
      
      private function _GWizDovetailCalc_Button1_i() : Button
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
      
      public function __gridArea_resize(param1:ResizeEvent) : void
      {
         this.redraw();
      }
      
      private function _GWizDovetailCalc_Group3_c() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizDovetailCalc_Rect2_c(),this._GWizDovetailCalc_GridComponent2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizDovetailCalc_Rect2_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.stroke = this._GWizDovetailCalc_SolidColorStroke2_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizDovetailCalc_SolidColorStroke2_c() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.color = 14150102;
         return _loc1_;
      }
      
      private function _GWizDovetailCalc_GridComponent2_i() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizDovetailCalc_Array7_c);
         _loc1_.setStyle("skinClass",GridSkin);
         _loc1_.addEventListener("resize",this.__gridArea2_resize);
         _loc1_.id = "gridArea2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gridArea2 = _loc1_;
         BindingManager.executeBindings(this,"gridArea2",this.gridArea2);
         return _loc1_;
      }
      
      private function _GWizDovetailCalc_Array7_c() : Array
      {
         return [this._GWizDovetailCalc_GWizNumStepOvr5_i(),this._GWizDovetailCalc_GWizNumStepOvr6_i(),this._GWizDovetailCalc_GWizNumStepOvr7_i(),this._GWizDovetailCalc_GWizNumStepOvr8_i()];
      }
      
      private function _GWizDovetailCalc_GWizNumStepOvr5_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "∠a (Reqd)";
         _loc1_.suffix = "°";
         _loc1_.min = 0;
         _loc1_.max = 360;
         _loc1_.steps = 0.0001;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__angle2_valueCommit);
         _loc1_.id = "angle2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.angle2 = _loc1_;
         BindingManager.executeBindings(this,"angle2",this.angle2);
         return _loc1_;
      }
      
      public function __angle2_valueCommit(param1:FlexEvent) : void
      {
         if(this.angle2.isOverridden())
         {
            this.angle1.setValOverride(this.angle2.getVal());
         }
         else
         {
            this.angle1.resetOverride(true);
         }
         this.recalc();
      }
      
      private function _GWizDovetailCalc_GWizNumStepOvr6_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Length";
         _loc1_.min = -100;
         _loc1_.steps = 0.0001;
         _loc1_.max = 100;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__outer_valueCommit);
         _loc1_.id = "outer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.outer = _loc1_;
         BindingManager.executeBindings(this,"outer",this.outer);
         return _loc1_;
      }
      
      public function __outer_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizDovetailCalc_GWizNumStepOvr7_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Roll Diameter (Reqd)";
         _loc1_.min = -100;
         _loc1_.steps = 0.0001;
         _loc1_.max = 100;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__dia2_valueCommit);
         _loc1_.id = "dia2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.dia2 = _loc1_;
         BindingManager.executeBindings(this,"dia2",this.dia2);
         return _loc1_;
      }
      
      public function __dia2_valueCommit(param1:FlexEvent) : void
      {
         if(this.dia2.isOverridden())
         {
            this.dia1.setValOverride(this.dia2.getVal());
         }
         else
         {
            this.dia1.resetOverride(true);
         }
         this.recalc();
      }
      
      private function _GWizDovetailCalc_GWizNumStepOvr8_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Distance";
         _loc1_.min = -100;
         _loc1_.steps = 0.0001;
         _loc1_.max = 100;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__innerRoll_valueCommit);
         _loc1_.id = "innerRoll";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.innerRoll = _loc1_;
         BindingManager.executeBindings(this,"innerRoll",this.innerRoll);
         return _loc1_;
      }
      
      public function __innerRoll_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      public function __gridArea2_resize(param1:ResizeEvent) : void
      {
         this.gridArea2.redraw();
      }
      
      public function ___GWizDovetailCalc_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.restoreViewData();
      }
      
      private function _GWizDovetailCalc_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Function
         {
            return drawOuterDoves;
         },null,"gridArea.drawFunc");
         result[1] = new Binding(this,function():Number
         {
            return gridArea.width - angle1.width - 10;
         },null,"angle1.x");
         result[2] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - scaledPlatformHeight1 - 50;
         },null,"angle1.y");
         result[3] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + scaledPlatformCenter1 - inner.width / 2;
         },null,"inner.x");
         result[4] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - scaledPlatformHeight1 + 15;
         },null,"inner.y");
         result[5] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + 2;
         },null,"dia1.x");
         result[6] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + scaledPlatformCenter1 - outerRoll.width / 2;
         },null,"outerRoll.x");
         result[7] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - scaledPlatformHeight1 + 55;
         },null,"outerRoll.y");
         result[8] = new Binding(this,function():Function
         {
            return drawInnerDoves;
         },null,"gridArea2.drawFunc");
         result[9] = new Binding(this,function():Number
         {
            return scaledPlatformCenter2;
         },null,"angle2.x");
         result[10] = new Binding(this,function():Number
         {
            return gridArea2.yOrigin + 5;
         },null,"angle2.y");
         result[11] = new Binding(this,function():Number
         {
            return gridArea2.xOrigin + scaledPlatformCenter2 - outer.width / 2;
         },null,"outer.x");
         result[12] = new Binding(this,function():Number
         {
            return gridArea2.yOrigin - (scaledDoveHeight2 + 78);
         },null,"outer.y");
         result[13] = new Binding(this,function():Number
         {
            return gridArea2.width - dia2.width - 2;
         },null,"dia2.x");
         result[14] = new Binding(this,function():Number
         {
            return gridArea2.yOrigin + 5;
         },null,"dia2.y");
         result[15] = new Binding(this,function():Number
         {
            return gridArea2.xOrigin + scaledPlatformCenter2 - innerRoll.width / 2;
         },null,"innerRoll.x");
         result[16] = new Binding(this,function():Number
         {
            return gridArea2.yOrigin - (scaledDoveHeight2 + 38);
         },null,"innerRoll.y");
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
      public function get angle1() : GWizNumStepOvr
      {
         return this._1413176898angle1;
      }
      
      public function set angle1(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1413176898angle1;
         if(_loc2_ !== param1)
         {
            this._1413176898angle1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"angle1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get angle2() : GWizNumStepOvr
      {
         return this._1413176897angle2;
      }
      
      public function set angle2(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1413176897angle2;
         if(_loc2_ !== param1)
         {
            this._1413176897angle2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"angle2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get dia1() : GWizNumStepOvr
      {
         return this._3083061dia1;
      }
      
      public function set dia1(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._3083061dia1;
         if(_loc2_ !== param1)
         {
            this._3083061dia1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"dia1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get dia2() : GWizNumStepOvr
      {
         return this._3083062dia2;
      }
      
      public function set dia2(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._3083062dia2;
         if(_loc2_ !== param1)
         {
            this._3083062dia2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"dia2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get diaLabel() : Label
      {
         return this._263817256diaLabel;
      }
      
      public function set diaLabel(param1:Label) : void
      {
         var _loc2_:Object = this._263817256diaLabel;
         if(_loc2_ !== param1)
         {
            this._263817256diaLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"diaLabel",_loc2_,param1));
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
      public function get gridArea2() : GridComponent
      {
         return this._1252712863gridArea2;
      }
      
      public function set gridArea2(param1:GridComponent) : void
      {
         var _loc2_:Object = this._1252712863gridArea2;
         if(_loc2_ !== param1)
         {
            this._1252712863gridArea2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gridArea2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get inner() : GWizNumStepOvr
      {
         return this._100355670inner;
      }
      
      public function set inner(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._100355670inner;
         if(_loc2_ !== param1)
         {
            this._100355670inner = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"inner",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get innerRoll() : GWizNumStepOvr
      {
         return this._528013325innerRoll;
      }
      
      public function set innerRoll(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._528013325innerRoll;
         if(_loc2_ !== param1)
         {
            this._528013325innerRoll = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"innerRoll",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get outer() : GWizNumStepOvr
      {
         return this._106111099outer;
      }
      
      public function set outer(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._106111099outer;
         if(_loc2_ !== param1)
         {
            this._106111099outer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"outer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get outerRoll() : GWizNumStepOvr
      {
         return this._1856987032outerRoll;
      }
      
      public function set outerRoll(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1856987032outerRoll;
         if(_loc2_ !== param1)
         {
            this._1856987032outerRoll = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"outerRoll",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get scaledPlatformHeight1() : Number
      {
         return this._1427080253scaledPlatformHeight1;
      }
      
      private function set scaledPlatformHeight1(param1:Number) : void
      {
         var _loc2_:Object = this._1427080253scaledPlatformHeight1;
         if(_loc2_ !== param1)
         {
            this._1427080253scaledPlatformHeight1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"scaledPlatformHeight1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get scaledPlatformHeight2() : Number
      {
         return this._1427080254scaledPlatformHeight2;
      }
      
      private function set scaledPlatformHeight2(param1:Number) : void
      {
         var _loc2_:Object = this._1427080254scaledPlatformHeight2;
         if(_loc2_ !== param1)
         {
            this._1427080254scaledPlatformHeight2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"scaledPlatformHeight2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get scaledPlatformCenter1() : Number
      {
         return this._1289531087scaledPlatformCenter1;
      }
      
      private function set scaledPlatformCenter1(param1:Number) : void
      {
         var _loc2_:Object = this._1289531087scaledPlatformCenter1;
         if(_loc2_ !== param1)
         {
            this._1289531087scaledPlatformCenter1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"scaledPlatformCenter1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get scaledPlatformCenter2() : Number
      {
         return this._1289531088scaledPlatformCenter2;
      }
      
      private function set scaledPlatformCenter2(param1:Number) : void
      {
         var _loc2_:Object = this._1289531088scaledPlatformCenter2;
         if(_loc2_ !== param1)
         {
            this._1289531088scaledPlatformCenter2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"scaledPlatformCenter2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get scaledDoveHeight1() : Number
      {
         return this._1200461142scaledDoveHeight1;
      }
      
      private function set scaledDoveHeight1(param1:Number) : void
      {
         var _loc2_:Object = this._1200461142scaledDoveHeight1;
         if(_loc2_ !== param1)
         {
            this._1200461142scaledDoveHeight1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"scaledDoveHeight1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get scaledDoveHeight2() : Number
      {
         return this._1200461143scaledDoveHeight2;
      }
      
      private function set scaledDoveHeight2(param1:Number) : void
      {
         var _loc2_:Object = this._1200461143scaledDoveHeight2;
         if(_loc2_ !== param1)
         {
            this._1200461143scaledDoveHeight2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"scaledDoveHeight2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get leftOuterRollOrigin() : Point
      {
         return this._1160712663leftOuterRollOrigin;
      }
      
      private function set leftOuterRollOrigin(param1:Point) : void
      {
         var _loc2_:Object = this._1160712663leftOuterRollOrigin;
         if(_loc2_ !== param1)
         {
            this._1160712663leftOuterRollOrigin = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"leftOuterRollOrigin",_loc2_,param1));
            }
         }
      }
   }
}
