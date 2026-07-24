package machines
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import comps.GWizPopUp;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.CheckBox;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   public class GWizMachHourly extends GWizPopUp
   {
       
      
      private var _1595818997AnnInterest:GWizNumStep;
      
      private var _805312080Consumables:GWizNumStep;
      
      private var _635073189ConsumablesBox:GWizForePanel;
      
      private var _365913731DaysPerYear:GWizNumStep;
      
      private var _1075859842Deposit:GWizNumStep;
      
      private var _1492695695Downtime:GWizNumStep;
      
      private var _811395002Finance:CheckBox;
      
      private var _2127559023Hourly:Label;
      
      private var _594246926HoursPerDay:GWizNumStep;
      
      private var _1885226085LaborBox:GWizForePanel;
      
      private var _1687996688LaborRate:GWizNumStep;
      
      private var _2368284Life:GWizNumStep;
      
      private var _1834138895LifeBox:GWizForePanel;
      
      private var _1919478172LoanTerm:GWizNumStep;
      
      private var _185295908MachineBox:GWizForePanel;
      
      private var _1997438392Markup:GWizNumStep;
      
      private var _77381929Price:GWizNumStep;
      
      private var _1422498325ResultsBox:GWizForePanel;
      
      private var _82880TCO:Label;
      
      private var _597281161TradeIn:GWizNumStep;
      
      private var _570402602interest:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var setHourlyRate:Function;
      
      public function GWizMachHourly()
      {
         super();
         mx_internal::_document = this;
         this.width = 600;
         this.height = 650;
         this.title = "Machine Hourly Rate Calculator";
         this.mxmlContent = [this._GWizMachHourly_GWizForePanel1_i(),this._GWizMachHourly_GWizForePanel2_i(),this._GWizMachHourly_GWizForePanel3_i(),this._GWizMachHourly_GWizForePanel4_i(),this._GWizMachHourly_GWizForePanel5_i()];
         this.addEventListener("creationComplete",this.___GWizMachHourly_GWizPopUp1_creationComplete);
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
      
      private function doSave(param1:Boolean) : void
      {
         if(param1 && this.setHourlyRate != null)
         {
            this.setHourlyRate(Number(this.Hourly.text));
         }
         super.close();
      }
      
      private function init() : void
      {
         this.Finance.selected = false;
         this.Price.setVal(50000);
         this.Life.setVal(4);
         this.TradeIn.setVal(5000);
         this.Consumables.setVal(50000 / 4 * 0.2);
         this.HoursPerDay.setVal(8);
         this.DaysPerYear.setVal(50 * 5);
         this.Downtime.setVal(20);
         this.Markup.setVal(0);
      }
      
      private function recalc() : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         this.Deposit.enabled = this.Finance.selected;
         this.LoanTerm.enabled = this.Finance.selected;
         this.AnnInterest.enabled = this.Finance.selected;
         var _loc1_:Number = this.Price.getVal();
         var _loc2_:Number = 0;
         if(this.Finance.selected)
         {
            _loc5_ = this.Price.getVal() - this.Deposit.getVal();
            _loc6_ = this.AnnInterest.getVal() / 100 / 12;
            _loc7_ = this.LoanTerm.getVal() * 12;
            _loc2_ = (_loc8_ = _loc6_ * _loc5_ / (1 - Math.pow(1 + _loc6_,-_loc7_))) * _loc7_ - _loc5_;
            this.interest.text = String(GWizUtils.roundHundredths(_loc2_));
         }
         else
         {
            _loc2_ = 0;
            this.interest.text = "0.00";
         }
         _loc1_ += _loc2_;
         _loc1_ -= this.TradeIn.getVal();
         _loc1_ += this.Consumables.getVal() * this.Life.getVal();
         var _loc3_:Number = this.HoursPerDay.getVal() * this.DaysPerYear.getVal() * this.Life.getVal();
         _loc3_ *= 1 - this.Downtime.getVal() / 100;
         var _loc4_:Number = (_loc4_ = _loc3_) * this.LaborRate.getVal();
         _loc1_ += _loc4_;
         this.TCO.text = String(GWizUtils.roundHundredths(_loc1_));
         this.Hourly.text = String(GWizUtils.roundHundredths(_loc1_ / _loc3_ * (1 + this.Markup.getVal() / 100)));
      }
      
      override public function onOk(param1:Event) : void
      {
         this.doSave(true);
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.doSave(false);
      }
      
      private function _GWizMachHourly_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Machine";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMachHourly_Array2_c);
         _loc1_.id = "MachineBox";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MachineBox = _loc1_;
         BindingManager.executeBindings(this,"MachineBox",this.MachineBox);
         return _loc1_;
      }
      
      private function _GWizMachHourly_Array2_c() : Array
      {
         return [this._GWizMachHourly_VGroup1_c()];
      }
      
      private function _GWizMachHourly_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachHourly_GWizNumStep1_i(),this._GWizMachHourly_CheckBox1_i(),this._GWizMachHourly_GWizNumStep2_i(),this._GWizMachHourly_GWizNumStep3_i(),this._GWizMachHourly_GWizNumStep4_i(),this._GWizMachHourly_HGroup1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Purchase Price (Machine + Tooling)";
         _loc1_.min = 0;
         _loc1_.max = 10000000;
         _loc1_.steps = 0.01;
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__Price_change);
         _loc1_.id = "Price";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Price = _loc1_;
         BindingManager.executeBindings(this,"Price",this.Price);
         return _loc1_;
      }
      
      public function __Price_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMachHourly_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Finance";
         _loc1_.selected = false;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("change",this.__Finance_change);
         _loc1_.id = "Finance";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Finance = _loc1_;
         BindingManager.executeBindings(this,"Finance",this.Finance);
         return _loc1_;
      }
      
      public function __Finance_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMachHourly_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "    Deposit";
         _loc1_.min = 0;
         _loc1_.max = 10000000;
         _loc1_.steps = 0.01;
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__Deposit_change);
         _loc1_.id = "Deposit";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Deposit = _loc1_;
         BindingManager.executeBindings(this,"Deposit",this.Deposit);
         return _loc1_;
      }
      
      public function __Deposit_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMachHourly_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "    Loan Term (yrs)";
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.01;
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__LoanTerm_change);
         _loc1_.id = "LoanTerm";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.LoanTerm = _loc1_;
         BindingManager.executeBindings(this,"LoanTerm",this.LoanTerm);
         return _loc1_;
      }
      
      public function __LoanTerm_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMachHourly_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "    Annual Interest (%)";
         _loc1_.min = 0;
         _loc1_.max = 100;
         _loc1_.steps = 0.001;
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__AnnInterest_change);
         _loc1_.id = "AnnInterest";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.AnnInterest = _loc1_;
         BindingManager.executeBindings(this,"AnnInterest",this.AnnInterest);
         return _loc1_;
      }
      
      public function __AnnInterest_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMachHourly_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachHourly_Label1_c(),this._GWizMachHourly_Spacer1_c(),this._GWizMachHourly_Label2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "    Total loan interest paid:";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.00";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "interest";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.interest = _loc1_;
         BindingManager.executeBindings(this,"interest",this.interest);
         return _loc1_;
      }
      
      private function _GWizMachHourly_GWizForePanel2_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Life";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMachHourly_Array5_c);
         _loc1_.id = "LifeBox";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.LifeBox = _loc1_;
         BindingManager.executeBindings(this,"LifeBox",this.LifeBox);
         return _loc1_;
      }
      
      private function _GWizMachHourly_Array5_c() : Array
      {
         return [this._GWizMachHourly_VGroup2_c()];
      }
      
      private function _GWizMachHourly_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachHourly_GWizNumStep5_i(),this._GWizMachHourly_GWizNumStep6_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_GWizNumStep5_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Useful Life (yrs)";
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.01;
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__Life_change);
         _loc1_.id = "Life";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Life = _loc1_;
         BindingManager.executeBindings(this,"Life",this.Life);
         return _loc1_;
      }
      
      public function __Life_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMachHourly_GWizNumStep6_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Trade-in Value (End of Life)";
         _loc1_.min = 0;
         _loc1_.max = 10000000;
         _loc1_.steps = 0.01;
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__TradeIn_change);
         _loc1_.id = "TradeIn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TradeIn = _loc1_;
         BindingManager.executeBindings(this,"TradeIn",this.TradeIn);
         return _loc1_;
      }
      
      public function __TradeIn_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMachHourly_GWizForePanel3_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Consumables";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMachHourly_Array7_c);
         _loc1_.id = "ConsumablesBox";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ConsumablesBox = _loc1_;
         BindingManager.executeBindings(this,"ConsumablesBox",this.ConsumablesBox);
         return _loc1_;
      }
      
      private function _GWizMachHourly_Array7_c() : Array
      {
         return [this._GWizMachHourly_VGroup3_c()];
      }
      
      private function _GWizMachHourly_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachHourly_GWizNumStep7_i(),this._GWizMachHourly_Label3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_GWizNumStep7_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Annual Consumables Cost";
         _loc1_.min = 0;
         _loc1_.max = 10000000;
         _loc1_.steps = 0.01;
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__Consumables_change);
         _loc1_.id = "Consumables";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Consumables = _loc1_;
         BindingManager.executeBindings(this,"Consumables",this.Consumables);
         return _loc1_;
      }
      
      public function __Consumables_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMachHourly_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Tooling, Coolant, Lubricants, Repairs, Spare Parts, etc.";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_GWizForePanel4_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Labor";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMachHourly_Array9_c);
         _loc1_.id = "LaborBox";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.LaborBox = _loc1_;
         BindingManager.executeBindings(this,"LaborBox",this.LaborBox);
         return _loc1_;
      }
      
      private function _GWizMachHourly_Array9_c() : Array
      {
         return [this._GWizMachHourly_VGroup4_c()];
      }
      
      private function _GWizMachHourly_VGroup4_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachHourly_GWizNumStep8_i(),this._GWizMachHourly_GWizNumStep9_i(),this._GWizMachHourly_GWizNumStep10_i(),this._GWizMachHourly_GWizNumStep11_i(),this._GWizMachHourly_Label4_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_GWizNumStep8_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Operator Rate/Hr";
         _loc1_.min = 0;
         _loc1_.max = 10000000;
         _loc1_.steps = 0.01;
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__LaborRate_change);
         _loc1_.id = "LaborRate";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.LaborRate = _loc1_;
         BindingManager.executeBindings(this,"LaborRate",this.LaborRate);
         return _loc1_;
      }
      
      public function __LaborRate_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMachHourly_GWizNumStep9_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Working Hours/Day";
         _loc1_.min = 0;
         _loc1_.max = 24;
         _loc1_.steps = 0.01;
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__HoursPerDay_change);
         _loc1_.id = "HoursPerDay";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HoursPerDay = _loc1_;
         BindingManager.executeBindings(this,"HoursPerDay",this.HoursPerDay);
         return _loc1_;
      }
      
      public function __HoursPerDay_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMachHourly_GWizNumStep10_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Working Days/Year";
         _loc1_.min = 0;
         _loc1_.max = 365;
         _loc1_.steps = 0.01;
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__DaysPerYear_change);
         _loc1_.id = "DaysPerYear";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DaysPerYear = _loc1_;
         BindingManager.executeBindings(this,"DaysPerYear",this.DaysPerYear);
         return _loc1_;
      }
      
      public function __DaysPerYear_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMachHourly_GWizNumStep11_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Downtime (%)";
         _loc1_.min = 0;
         _loc1_.max = 100;
         _loc1_.steps = 0.001;
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("change",this.__Downtime_change);
         _loc1_.id = "Downtime";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Downtime = _loc1_;
         BindingManager.executeBindings(this,"Downtime",this.Downtime);
         return _loc1_;
      }
      
      public function __Downtime_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMachHourly_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Actual expected use: be conservative!";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_GWizForePanel5_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Results";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMachHourly_Array11_c);
         _loc1_.id = "ResultsBox";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ResultsBox = _loc1_;
         BindingManager.executeBindings(this,"ResultsBox",this.ResultsBox);
         return _loc1_;
      }
      
      private function _GWizMachHourly_Array11_c() : Array
      {
         return [this._GWizMachHourly_VGroup5_c()];
      }
      
      private function _GWizMachHourly_VGroup5_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachHourly_HGroup2_c(),this._GWizMachHourly_GWizNumStep12_i(),this._GWizMachHourly_HGroup3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachHourly_Label5_c(),this._GWizMachHourly_Spacer2_c(),this._GWizMachHourly_Label6_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Total cost of ownership:";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.00";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         _loc1_.id = "TCO";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TCO = _loc1_;
         BindingManager.executeBindings(this,"TCO",this.TCO);
         return _loc1_;
      }
      
      private function _GWizMachHourly_GWizNumStep12_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Markup (%)";
         _loc1_.min = 0;
         _loc1_.max = 100;
         _loc1_.steps = 0.001;
         _loc1_.percentWidth = 100;
         _loc1_.usesMetric = false;
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         _loc1_.addEventListener("change",this.__Markup_change);
         _loc1_.id = "Markup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Markup = _loc1_;
         BindingManager.executeBindings(this,"Markup",this.Markup);
         return _loc1_;
      }
      
      public function __Markup_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizMachHourly_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMachHourly_Label7_c(),this._GWizMachHourly_Spacer3_c(),this._GWizMachHourly_Label8_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hourly Cost w/ Labor:";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachHourly_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.00";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         _loc1_.id = "Hourly";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Hourly = _loc1_;
         BindingManager.executeBindings(this,"Hourly",this.Hourly);
         return _loc1_;
      }
      
      public function ___GWizMachHourly_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.init();
         this.recalc();
      }
      
      [Bindable(event="propertyChange")]
      public function get AnnInterest() : GWizNumStep
      {
         return this._1595818997AnnInterest;
      }
      
      public function set AnnInterest(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1595818997AnnInterest;
         if(_loc2_ !== param1)
         {
            this._1595818997AnnInterest = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"AnnInterest",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Consumables() : GWizNumStep
      {
         return this._805312080Consumables;
      }
      
      public function set Consumables(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._805312080Consumables;
         if(_loc2_ !== param1)
         {
            this._805312080Consumables = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Consumables",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ConsumablesBox() : GWizForePanel
      {
         return this._635073189ConsumablesBox;
      }
      
      public function set ConsumablesBox(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._635073189ConsumablesBox;
         if(_loc2_ !== param1)
         {
            this._635073189ConsumablesBox = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ConsumablesBox",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get DaysPerYear() : GWizNumStep
      {
         return this._365913731DaysPerYear;
      }
      
      public function set DaysPerYear(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._365913731DaysPerYear;
         if(_loc2_ !== param1)
         {
            this._365913731DaysPerYear = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DaysPerYear",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Deposit() : GWizNumStep
      {
         return this._1075859842Deposit;
      }
      
      public function set Deposit(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1075859842Deposit;
         if(_loc2_ !== param1)
         {
            this._1075859842Deposit = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Deposit",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Downtime() : GWizNumStep
      {
         return this._1492695695Downtime;
      }
      
      public function set Downtime(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1492695695Downtime;
         if(_loc2_ !== param1)
         {
            this._1492695695Downtime = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Downtime",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Finance() : CheckBox
      {
         return this._811395002Finance;
      }
      
      public function set Finance(param1:CheckBox) : void
      {
         var _loc2_:Object = this._811395002Finance;
         if(_loc2_ !== param1)
         {
            this._811395002Finance = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Finance",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Hourly() : Label
      {
         return this._2127559023Hourly;
      }
      
      public function set Hourly(param1:Label) : void
      {
         var _loc2_:Object = this._2127559023Hourly;
         if(_loc2_ !== param1)
         {
            this._2127559023Hourly = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Hourly",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HoursPerDay() : GWizNumStep
      {
         return this._594246926HoursPerDay;
      }
      
      public function set HoursPerDay(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._594246926HoursPerDay;
         if(_loc2_ !== param1)
         {
            this._594246926HoursPerDay = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HoursPerDay",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LaborBox() : GWizForePanel
      {
         return this._1885226085LaborBox;
      }
      
      public function set LaborBox(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._1885226085LaborBox;
         if(_loc2_ !== param1)
         {
            this._1885226085LaborBox = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LaborBox",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LaborRate() : GWizNumStep
      {
         return this._1687996688LaborRate;
      }
      
      public function set LaborRate(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1687996688LaborRate;
         if(_loc2_ !== param1)
         {
            this._1687996688LaborRate = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LaborRate",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Life() : GWizNumStep
      {
         return this._2368284Life;
      }
      
      public function set Life(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._2368284Life;
         if(_loc2_ !== param1)
         {
            this._2368284Life = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Life",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LifeBox() : GWizForePanel
      {
         return this._1834138895LifeBox;
      }
      
      public function set LifeBox(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._1834138895LifeBox;
         if(_loc2_ !== param1)
         {
            this._1834138895LifeBox = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LifeBox",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LoanTerm() : GWizNumStep
      {
         return this._1919478172LoanTerm;
      }
      
      public function set LoanTerm(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1919478172LoanTerm;
         if(_loc2_ !== param1)
         {
            this._1919478172LoanTerm = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LoanTerm",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MachineBox() : GWizForePanel
      {
         return this._185295908MachineBox;
      }
      
      public function set MachineBox(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._185295908MachineBox;
         if(_loc2_ !== param1)
         {
            this._185295908MachineBox = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MachineBox",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Markup() : GWizNumStep
      {
         return this._1997438392Markup;
      }
      
      public function set Markup(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1997438392Markup;
         if(_loc2_ !== param1)
         {
            this._1997438392Markup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Markup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Price() : GWizNumStep
      {
         return this._77381929Price;
      }
      
      public function set Price(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._77381929Price;
         if(_loc2_ !== param1)
         {
            this._77381929Price = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Price",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ResultsBox() : GWizForePanel
      {
         return this._1422498325ResultsBox;
      }
      
      public function set ResultsBox(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._1422498325ResultsBox;
         if(_loc2_ !== param1)
         {
            this._1422498325ResultsBox = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ResultsBox",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TCO() : Label
      {
         return this._82880TCO;
      }
      
      public function set TCO(param1:Label) : void
      {
         var _loc2_:Object = this._82880TCO;
         if(_loc2_ !== param1)
         {
            this._82880TCO = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TCO",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TradeIn() : GWizNumStep
      {
         return this._597281161TradeIn;
      }
      
      public function set TradeIn(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._597281161TradeIn;
         if(_loc2_ !== param1)
         {
            this._597281161TradeIn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TradeIn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get interest() : Label
      {
         return this._570402602interest;
      }
      
      public function set interest(param1:Label) : void
      {
         var _loc2_:Object = this._570402602interest;
         if(_loc2_ !== param1)
         {
            this._570402602interest = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"interest",_loc2_,param1));
            }
         }
      }
   }
}
