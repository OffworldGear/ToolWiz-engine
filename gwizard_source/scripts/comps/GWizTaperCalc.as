package comps
{
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
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.VGroup;
   import utils.GWizGeomUtils;
   import utils.GWizUtils;
   import utils.GraphicsUtil;
   
   use namespace mx_internal;
   
   public class GWizTaperCalc extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizBoltCircles");
      
      private static const shapeMargin:int = 150;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _63357246Alpha:GWizNumStepOvr;
      
      private var _1964074676Alpha2:GWizNumStepOvr;
      
      private var _1399011488Alpha2Label:Label;
      
      private var _762504278AlphaLabel:Label;
      
      private var _66B:Label;
      
      private var _1989631963BigEnd:GWizNumStepOvr;
      
      private var _1505894439BigEndLabel:Label;
      
      private var _788769799BigSmall:HGroup;
      
      private var _65193517Clear:Button;
      
      private var _76L:GWizNumStepOvr;
      
      private var _2045977080LLabel:Label;
      
      private var _538567928LenAlongTaper:Label;
      
      private var _541921676SmallEnd:GWizNumStepOvr;
      
      private var _188778720SmallEndLabel:Label;
      
      private var _317504755gridArea:GridComponent;
      
      private var _873112108messageText:Label;
      
      private var _863243670stdTapersBtn:Button;
      
      private var _863252720stdTapersLbl:Label;
      
      private var _147477866taperLength:HGroup;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _686853213drawDefault:Boolean = true;
      
      private var stdTapersCallout:GWizTaperPicker;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizTaperCalc()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizTaperCalc_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizTaperCalcWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizTaperCalc[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.gap = 0;
         this.alpha = 1;
         this.styleName = "geoView";
         this.percentHeight = 100;
         this.percentWidth = 100;
         this.paddingBottom = 10;
         this.paddingLeft = 10;
         this.paddingRight = 10;
         this.paddingTop = 10;
         this.mxmlContent = [this._GWizTaperCalc_GridComponent1_i()];
         this.addEventListener("creationComplete",this.___GWizTaperCalc_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizTaperCalc._watcherSetupUtil = param1;
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
      
      private function valueModified() : void
      {
         this.stdTapersLbl.text = "";
         this.recalc();
      }
      
      private function recalc() : void
      {
         this.drawDefault = true;
         GWizGeomUtils.taperAlpha = !!this.Alpha.isOverridden() ? Number(this.Alpha.value) : Number(NaN);
         GWizGeomUtils.taperAlpha2 = !!this.Alpha2.isOverridden() ? Number(this.Alpha2.value) : Number(NaN);
         GWizGeomUtils.taperSmallEnd = !!this.SmallEnd.isOverridden() ? Number(this.SmallEnd.value) : Number(NaN);
         GWizGeomUtils.taperBigEnd = !!this.BigEnd.isOverridden() ? Number(this.BigEnd.value) : Number(NaN);
         GWizGeomUtils.taperL = !!this.L.isOverridden() ? Number(this.L.value) : Number(NaN);
         GWizGeomUtils.specAngles = 0;
         GWizGeomUtils.specLens = 0;
         GWizGeomUtils.taperCalc();
         if(GWizGeomUtils.specAngles < 2 && GWizGeomUtils.specLens + GWizGeomUtils.specAngles == 3)
         {
            this.Alpha.setVal(GWizGeomUtils.taperAlpha);
            this.Alpha2.setVal(this.Alpha.getVal() / 2);
            this.SmallEnd.setVal(GWizGeomUtils.taperSmallEnd);
            this.BigEnd.setVal(GWizGeomUtils.taperBigEnd);
            this.L.setVal(GWizGeomUtils.taperL);
            this.B.text = GWizUtils.sroundTenths(String((this.BigEnd.getVal() - this.SmallEnd.getVal()) / 2));
            this.LenAlongTaper.text = String(GWizUtils.roundTenths(this.L.getVal() / Math.cos(GWizUtils.radians(this.Alpha2.getVal()))));
            this.drawDefault = false;
         }
         else if(GWizGeomUtils.specAngles == 2)
         {
            this.messageText.text = "Error: Too many angles specified.  Please clear one of the overridden values by pressing the lock button.";
            this.messageText.setStyle("color",GWizUtils.ERROR_COLOR);
         }
         else if(GWizGeomUtils.specAngles + GWizGeomUtils.specLens > 3)
         {
            this.messageText.text = "Error: Too many values specified.  Please clear one of the overridden values by pressing the lock button.";
            this.messageText.setStyle("color",GWizUtils.ERROR_COLOR);
         }
         else
         {
            this.messageText.text = "Specify 1 angle and 2 lengths OR 3 lengths.";
            this.messageText.setStyle("color",GWizUtils.MESSAGE_COLOR);
         }
         this.gridArea.redraw();
      }
      
      private function clearAll() : void
      {
         this.Alpha.resetOverride(true);
         this.Alpha2.resetOverride(true);
         this.SmallEnd.resetOverride(true);
         this.BigEnd.resetOverride(true);
         this.L.resetOverride(true);
         this.LenAlongTaper.text = "";
         this.B.text = "";
         this.gridArea.redraw();
      }
      
      private function drawTapers(param1:Graphics) : void
      {
         var _loc7_:Point = null;
         var _loc2_:Number = !!this.drawDefault ? Number(1) : Number(this.BigEnd.getVal());
         var _loc3_:Number = !!this.drawDefault ? Number(_loc2_ * 0.9) : Number(this.SmallEnd.getVal());
         var _loc4_:Number = !!this.drawDefault ? Number((_loc2_ - _loc3_) * 50) : Number(this.L.getVal());
         var _loc5_:Number = Math.min((this.gridArea.width - (this.gridArea.xOrigin + shapeMargin)) / _loc4_,(this.gridArea.height - shapeMargin * 2) / _loc2_);
         var _loc6_:Array;
         (_loc6_ = new Array()).push(new Point(0,_loc2_ / 2));
         _loc6_.push(new Point(_loc4_,_loc3_ / 2));
         _loc6_.push(new Point(_loc4_,-_loc3_ / 2));
         _loc6_.push(new Point(0,-_loc2_ / 2));
         for each(_loc7_ in _loc6_)
         {
            _loc7_.x = _loc7_.x * _loc5_ + this.gridArea.xOrigin;
            _loc7_.y = _loc7_.y * _loc5_ + this.gridArea.yOrigin;
         }
         param1.beginFill(0,0.2);
         param1.lineStyle(1,5592405,1);
         param1.moveTo(_loc6_[0].x,_loc6_[0].y);
         param1.lineTo(_loc6_[1].x,_loc6_[1].y);
         param1.lineTo(_loc6_[2].x,_loc6_[2].y);
         param1.lineTo(_loc6_[3].x,_loc6_[3].y);
         param1.endFill();
         param1.lineStyle(1,4473924);
         param1.moveTo(_loc6_[2].x + 25,_loc6_[2].y);
         param1.lineTo(_loc6_[0].x,_loc6_[2].y);
         param1.moveTo(_loc6_[1].x + 25,_loc6_[1].y);
         param1.lineTo(_loc6_[1].x,_loc6_[1].y);
         param1.moveTo(_loc6_[3].x - 25,_loc6_[3].y);
         param1.lineTo(_loc6_[3].x,_loc6_[3].y);
         param1.moveTo(_loc6_[0].x - 25,_loc6_[0].y);
         param1.lineTo(_loc6_[0].x,_loc6_[0].y);
         param1.moveTo(_loc6_[1].x,_loc6_[1].y);
         param1.lineTo(_loc6_[1].x,_loc6_[0].y + 25);
         param1.moveTo(_loc6_[0].x,_loc6_[0].y);
         param1.lineTo(_loc6_[0].x,_loc6_[0].y + 25);
         param1.beginFill(4473924,1);
         param1.lineStyle(0);
         GraphicsUtil.drawArrows(param1,new Point(_loc6_[3].x - 25,_loc6_[3].y),new Point(_loc6_[0].x - 25,_loc6_[0].y));
         GraphicsUtil.drawArrows(param1,new Point(_loc6_[2].x + 25,_loc6_[2].y),new Point(_loc6_[1].x + 25,_loc6_[1].y));
         GraphicsUtil.drawArrows(param1,new Point(_loc6_[1].x,_loc6_[0].y + 25),new Point(_loc6_[0].x,_loc6_[0].y + 25));
         param1.endFill();
         this.AlphaLabel.y = _loc6_[2].y - 30;
         this.Alpha2Label.y = _loc6_[2].y - 30;
         this.AlphaLabel.x = this.gridArea.width / 3 * 2;
         this.Alpha2Label.x = this.gridArea.width / 3;
         this.BigEndLabel.x = _loc6_[3].x - (28 + this.BigEndLabel.width);
         this.SmallEndLabel.x = _loc6_[1].x + 28;
         this.LLabel.x = (_loc6_[1].x + _loc6_[0].x) / 2 - this.LLabel.width / 2;
         this.LLabel.y = _loc6_[0].y + 22 - this.LLabel.height;
         this.BigSmall.y = _loc6_[0].y + 60;
         this.taperLength.y = _loc6_[0].y + 40;
      }
      
      protected function commitTapersHandler() : void
      {
         if(this.stdTapersCallout.tapers.selectedIndex > -1)
         {
            this.Alpha.resetOverride(true);
            this.L.resetOverride(true);
            this.Alpha2.setValOverride(this.stdTapersCallout.Angle);
            this.SmallEnd.setValOverride(this.stdTapersCallout.SmallEnd);
            this.BigEnd.setValOverride(this.stdTapersCallout.LargeEnd);
            this.stdTapersLbl.text = this.stdTapersCallout.TaperName;
            this.recalc();
         }
      }
      
      private function clear() : void
      {
         this.Alpha2.resetOverride(true);
         this.Alpha.resetOverride(true);
         this.BigEnd.resetOverride(true);
         this.L.resetOverride(true);
         this.SmallEnd.resetOverride(true);
         this.stdTapersLbl.text = "";
         this.recalc();
      }
      
      private function _GWizTaperCalc_GridComponent1_i() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.drawFunc = this.drawTapers;
         _loc1_.yOriginPos = 50;
         _loc1_.showYAxis = false;
         _loc1_.xOriginPos = 20;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizTaperCalc_Array2_c);
         _loc1_.id = "gridArea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gridArea = _loc1_;
         BindingManager.executeBindings(this,"gridArea",this.gridArea);
         return _loc1_;
      }
      
      private function _GWizTaperCalc_Array2_c() : Array
      {
         return [this._GWizTaperCalc_Label1_i(),this._GWizTaperCalc_Label2_i(),this._GWizTaperCalc_Label3_i(),this._GWizTaperCalc_Label4_i(),this._GWizTaperCalc_Label5_i(),this._GWizTaperCalc_Label6_i(),this._GWizTaperCalc_GWizNumStepOvr1_i(),this._GWizTaperCalc_GWizNumStepOvr2_i(),this._GWizTaperCalc_GWizNumStepOvr3_i(),this._GWizTaperCalc_GWizNumStepOvr4_i(),this._GWizTaperCalc_GWizNumStepOvr5_i(),this._GWizTaperCalc_HGroup1_i(),this._GWizTaperCalc_HGroup2_i(),this._GWizTaperCalc_Button1_i(),this._GWizTaperCalc_Label11_i(),this._GWizTaperCalc_Button2_i()];
      }
      
      private function _GWizTaperCalc_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.y = 20;
         _loc1_.text = "Specify 1 angle and 2 lengths OR 3 lengths.";
         _loc1_.setStyle("color",2237064);
         _loc1_.id = "messageText";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.messageText = _loc1_;
         BindingManager.executeBindings(this,"messageText",this.messageText);
         return _loc1_;
      }
      
      private function _GWizTaperCalc_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Angle";
         _loc1_.x = 500;
         _loc1_.y = 400;
         _loc1_.id = "Alpha2Label";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Alpha2Label = _loc1_;
         BindingManager.executeBindings(this,"Alpha2Label",this.Alpha2Label);
         return _loc1_;
      }
      
      private function _GWizTaperCalc_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Included Angle";
         _loc1_.x = 300;
         _loc1_.y = 400;
         _loc1_.id = "AlphaLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.AlphaLabel = _loc1_;
         BindingManager.executeBindings(this,"AlphaLabel",this.AlphaLabel);
         return _loc1_;
      }
      
      private function _GWizTaperCalc_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Small End";
         _loc1_.id = "SmallEndLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SmallEndLabel = _loc1_;
         BindingManager.executeBindings(this,"SmallEndLabel",this.SmallEndLabel);
         return _loc1_;
      }
      
      private function _GWizTaperCalc_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Big End";
         _loc1_.id = "BigEndLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.BigEndLabel = _loc1_;
         BindingManager.executeBindings(this,"BigEndLabel",this.BigEndLabel);
         return _loc1_;
      }
      
      private function _GWizTaperCalc_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Length";
         _loc1_.x = 300;
         _loc1_.y = 490;
         _loc1_.id = "LLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.LLabel = _loc1_;
         BindingManager.executeBindings(this,"LLabel",this.LLabel);
         return _loc1_;
      }
      
      private function _GWizTaperCalc_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Angle";
         _loc1_.suffix = "°";
         _loc1_.noUnits = true;
         _loc1_.y = 50;
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.max = 180;
         _loc1_.addEventListener("change",this.__Alpha2_change);
         _loc1_.id = "Alpha2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Alpha2 = _loc1_;
         BindingManager.executeBindings(this,"Alpha2",this.Alpha2);
         return _loc1_;
      }
      
      public function __Alpha2_change(param1:Event) : void
      {
         this.valueModified();
      }
      
      private function _GWizTaperCalc_GWizNumStepOvr2_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Included Angle";
         _loc1_.suffix = "°";
         _loc1_.noUnits = true;
         _loc1_.y = 50;
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.max = 180;
         _loc1_.addEventListener("change",this.__Alpha_change);
         _loc1_.id = "Alpha";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Alpha = _loc1_;
         BindingManager.executeBindings(this,"Alpha",this.Alpha);
         return _loc1_;
      }
      
      public function __Alpha_change(param1:Event) : void
      {
         this.valueModified();
      }
      
      private function _GWizTaperCalc_GWizNumStepOvr3_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Big End";
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.addEventListener("change",this.__BigEnd_change);
         _loc1_.id = "BigEnd";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.BigEnd = _loc1_;
         BindingManager.executeBindings(this,"BigEnd",this.BigEnd);
         return _loc1_;
      }
      
      public function __BigEnd_change(param1:Event) : void
      {
         this.valueModified();
      }
      
      private function _GWizTaperCalc_GWizNumStepOvr4_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Length";
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.addEventListener("change",this.__L_change);
         _loc1_.id = "L";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.L = _loc1_;
         BindingManager.executeBindings(this,"L",this.L);
         return _loc1_;
      }
      
      public function __L_change(param1:Event) : void
      {
         this.valueModified();
      }
      
      private function _GWizTaperCalc_GWizNumStepOvr5_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Small End";
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.max = 1000000000;
         _loc1_.addEventListener("change",this.__SmallEnd_change);
         _loc1_.id = "SmallEnd";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SmallEnd = _loc1_;
         BindingManager.executeBindings(this,"SmallEnd",this.SmallEnd);
         return _loc1_;
      }
      
      public function __SmallEnd_change(param1:Event) : void
      {
         this.valueModified();
      }
      
      private function _GWizTaperCalc_HGroup1_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.y = 550;
         _loc1_.mxmlContent = [this._GWizTaperCalc_Label7_c(),this._GWizTaperCalc_Label8_i()];
         _loc1_.setStyle("color",6710886);
         _loc1_.id = "taperLength";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.taperLength = _loc1_;
         BindingManager.executeBindings(this,"taperLength",this.taperLength);
         return _loc1_;
      }
      
      private function _GWizTaperCalc_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Length Along Taper:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTaperCalc_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "LenAlongTaper";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.LenAlongTaper = _loc1_;
         BindingManager.executeBindings(this,"LenAlongTaper",this.LenAlongTaper);
         return _loc1_;
      }
      
      private function _GWizTaperCalc_HGroup2_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.y = 570;
         _loc1_.mxmlContent = [this._GWizTaperCalc_Label9_c(),this._GWizTaperCalc_Label10_i()];
         _loc1_.setStyle("color",6710886);
         _loc1_.id = "BigSmall";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.BigSmall = _loc1_;
         BindingManager.executeBindings(this,"BigSmall",this.BigSmall);
         return _loc1_;
      }
      
      private function _GWizTaperCalc_Label9_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "(Big - Small) / 2 =";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTaperCalc_Label10_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "B";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.B = _loc1_;
         BindingManager.executeBindings(this,"B",this.B);
         return _loc1_;
      }
      
      private function _GWizTaperCalc_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Standard Tapers";
         _loc1_.x = 10;
         _loc1_.y = 20;
         _loc1_.addEventListener("click",this.__stdTapersBtn_click);
         _loc1_.id = "stdTapersBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.stdTapersBtn = _loc1_;
         BindingManager.executeBindings(this,"stdTapersBtn",this.stdTapersBtn);
         return _loc1_;
      }
      
      public function __stdTapersBtn_click(param1:MouseEvent) : void
      {
         this.stdTapersCallout = GWizTaperPicker.selectTaper(this.commitTapersHandler);
      }
      
      private function _GWizTaperCalc_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.x = 10;
         _loc1_.y = 50;
         _loc1_.id = "stdTapersLbl";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.stdTapersLbl = _loc1_;
         BindingManager.executeBindings(this,"stdTapersLbl",this.stdTapersLbl);
         return _loc1_;
      }
      
      private function _GWizTaperCalc_Button2_i() : Button
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
      
      public function ___GWizTaperCalc_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizTaperCalc_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + 10;
         },null,"messageText.x");
         result[1] = new Binding(this,function():Boolean
         {
            return drawDefault;
         },null,"messageText.visible");
         result[2] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - (SmallEnd.height + 2);
         },null,"SmallEndLabel.y");
         result[3] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - (BigEnd.height + 2);
         },null,"BigEndLabel.y");
         result[4] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + 10;
         },null,"Alpha2.x");
         result[5] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + 210;
         },null,"Alpha.x");
         result[6] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + 10;
         },null,"BigEnd.x");
         result[7] = new Binding(this,function():Number
         {
            return gridArea.height - 30;
         },null,"BigEnd.y");
         result[8] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + 210;
         },null,"L.x");
         result[9] = new Binding(this,function():Number
         {
            return gridArea.height - 30;
         },null,"L.y");
         result[10] = new Binding(this,function():Number
         {
            return gridArea.xOrigin + 410;
         },null,"SmallEnd.x");
         result[11] = new Binding(this,function():Number
         {
            return gridArea.height - 30;
         },null,"SmallEnd.y");
         result[12] = new Binding(this,function():Number
         {
            return (gridArea.width - taperLength.width) / 2;
         },null,"taperLength.x");
         result[13] = new Binding(this,function():Number
         {
            return (gridArea.width - BigSmall.width) / 2;
         },null,"BigSmall.x");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Alpha() : GWizNumStepOvr
      {
         return this._63357246Alpha;
      }
      
      public function set Alpha(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._63357246Alpha;
         if(_loc2_ !== param1)
         {
            this._63357246Alpha = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Alpha",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Alpha2() : GWizNumStepOvr
      {
         return this._1964074676Alpha2;
      }
      
      public function set Alpha2(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1964074676Alpha2;
         if(_loc2_ !== param1)
         {
            this._1964074676Alpha2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Alpha2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Alpha2Label() : Label
      {
         return this._1399011488Alpha2Label;
      }
      
      public function set Alpha2Label(param1:Label) : void
      {
         var _loc2_:Object = this._1399011488Alpha2Label;
         if(_loc2_ !== param1)
         {
            this._1399011488Alpha2Label = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Alpha2Label",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get AlphaLabel() : Label
      {
         return this._762504278AlphaLabel;
      }
      
      public function set AlphaLabel(param1:Label) : void
      {
         var _loc2_:Object = this._762504278AlphaLabel;
         if(_loc2_ !== param1)
         {
            this._762504278AlphaLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"AlphaLabel",_loc2_,param1));
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
      public function get BigEnd() : GWizNumStepOvr
      {
         return this._1989631963BigEnd;
      }
      
      public function set BigEnd(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1989631963BigEnd;
         if(_loc2_ !== param1)
         {
            this._1989631963BigEnd = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"BigEnd",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get BigEndLabel() : Label
      {
         return this._1505894439BigEndLabel;
      }
      
      public function set BigEndLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1505894439BigEndLabel;
         if(_loc2_ !== param1)
         {
            this._1505894439BigEndLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"BigEndLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get BigSmall() : HGroup
      {
         return this._788769799BigSmall;
      }
      
      public function set BigSmall(param1:HGroup) : void
      {
         var _loc2_:Object = this._788769799BigSmall;
         if(_loc2_ !== param1)
         {
            this._788769799BigSmall = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"BigSmall",_loc2_,param1));
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
      public function get L() : GWizNumStepOvr
      {
         return this._76L;
      }
      
      public function set L(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._76L;
         if(_loc2_ !== param1)
         {
            this._76L = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"L",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LLabel() : Label
      {
         return this._2045977080LLabel;
      }
      
      public function set LLabel(param1:Label) : void
      {
         var _loc2_:Object = this._2045977080LLabel;
         if(_loc2_ !== param1)
         {
            this._2045977080LLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LenAlongTaper() : Label
      {
         return this._538567928LenAlongTaper;
      }
      
      public function set LenAlongTaper(param1:Label) : void
      {
         var _loc2_:Object = this._538567928LenAlongTaper;
         if(_loc2_ !== param1)
         {
            this._538567928LenAlongTaper = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LenAlongTaper",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SmallEnd() : GWizNumStepOvr
      {
         return this._541921676SmallEnd;
      }
      
      public function set SmallEnd(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._541921676SmallEnd;
         if(_loc2_ !== param1)
         {
            this._541921676SmallEnd = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SmallEnd",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SmallEndLabel() : Label
      {
         return this._188778720SmallEndLabel;
      }
      
      public function set SmallEndLabel(param1:Label) : void
      {
         var _loc2_:Object = this._188778720SmallEndLabel;
         if(_loc2_ !== param1)
         {
            this._188778720SmallEndLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SmallEndLabel",_loc2_,param1));
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
      public function get messageText() : Label
      {
         return this._873112108messageText;
      }
      
      public function set messageText(param1:Label) : void
      {
         var _loc2_:Object = this._873112108messageText;
         if(_loc2_ !== param1)
         {
            this._873112108messageText = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"messageText",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stdTapersBtn() : Button
      {
         return this._863243670stdTapersBtn;
      }
      
      public function set stdTapersBtn(param1:Button) : void
      {
         var _loc2_:Object = this._863243670stdTapersBtn;
         if(_loc2_ !== param1)
         {
            this._863243670stdTapersBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stdTapersBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stdTapersLbl() : Label
      {
         return this._863252720stdTapersLbl;
      }
      
      public function set stdTapersLbl(param1:Label) : void
      {
         var _loc2_:Object = this._863252720stdTapersLbl;
         if(_loc2_ !== param1)
         {
            this._863252720stdTapersLbl = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stdTapersLbl",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get taperLength() : HGroup
      {
         return this._147477866taperLength;
      }
      
      public function set taperLength(param1:HGroup) : void
      {
         var _loc2_:Object = this._147477866taperLength;
         if(_loc2_ !== param1)
         {
            this._147477866taperLength = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"taperLength",_loc2_,param1));
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
