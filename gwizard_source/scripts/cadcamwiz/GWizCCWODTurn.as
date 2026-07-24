package cadcamwiz
{
   import comps.GWizPopUpManager;
   import configinfo.GWizLatheTools;
   import configinfo.GWizSettings;
   import machines.GWizMachSettings;
   import mx.collections.ArrayCollection;
   import mx.core.IFlexModuleFactory;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizGeomUtils;
   import utils.GWizUtils;
   
   public class GWizCCWODTurn extends GWizCCWGenericWizard
   {
      
      private static const log:ILogger = Log.getLogger("GWizODTurn");
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var odtInputs:GWizCCWODTurnInputs;
      
      private var odtOpts:GWizCCWODTurnOptions;
      
      private var defODTurningPlan:ArrayCollection;
      
      private var roughStockOD:Number;
      
      public function GWizCCWODTurn()
      {
         this.defODTurningPlan = new ArrayCollection([{
            "num":1,
            "dia":0,
            "len":0,
            "face":true,
            "chamRound":"None",
            "radius":0
         },{
            "num":2,
            "dia":0,
            "len":0,
            "face":true,
            "chamRound":"None",
            "radius":0
         },{
            "num":3,
            "dia":0,
            "len":0,
            "face":true,
            "chamRound":"None",
            "radius":0
         },{
            "num":4,
            "dia":0,
            "len":0,
            "face":true,
            "chamRound":"None",
            "radius":0
         },{
            "num":5,
            "dia":0,
            "len":0,
            "face":true,
            "chamRound":"None",
            "radius":0
         }]);
         super();
         mx_internal::_document = this;
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.gap = 1;
         this.paddingLeft = 0;
         this.paddingRight = 0;
         this.paddingTop = 0;
         this.paddingBottom = 0;
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
      
      override public function onCC() : void
      {
         this.odtInputs = new GWizCCWODTurnInputs();
         inputs = this.odtInputs;
         inputs.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         this.installInputs(inputs);
         this.odtInputs._odTurnGrid.turningPlan = this.defODTurningPlan;
         GWizCCWODTurnGrid.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         this.odtOpts = new GWizCCWODTurnOptions();
         options = this.odtOpts;
         options.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         this.installOptions(options);
         FeedsBox.WidthColumn.visible = false;
         GWizCadCam.CADCAMWiz.requestRecalc();
      }
      
      override public function opType() : String
      {
         return GWizCCWEstRecord.CCE_LATHE_ODTURN;
      }
      
      override public function recalcAux(param1:Boolean = false, param2:Number = 100.0, param3:Boolean = false) : void
      {
         if(!this.odtOpts || !this.odtOpts.roughingInsType || this.odtOpts.roughingInsType.selectedIndex < 0 || GWizCadCam.currWizard != "OD Turn")
         {
            log.debug("GWizCadCam.CADCAMWiz.currWizard = " + GWizCadCam.currWizard);
            return;
         }
         if(recalcPrefix("Lathe"))
         {
            return;
         }
         var _loc4_:Number = 0;
         this.roughStockOD = this.odtInputs.stockOD();
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         while(_loc8_ < this.odtInputs.numODs())
         {
            if(this.odtInputs.diam(_loc8_) >= this.roughStockOD)
            {
               GWizPopUpManager.Show("Sorry, OD #" + (_loc8_ + 1) + " must be less than rough stock OD.","Error: Rough Stock OD",GWizPopUpManager.ERROR);
            }
            if(this.odtInputs.len(_loc8_) <= 0)
            {
               break;
            }
            _loc4_ += this.processDiam(this.odtInputs.diam(_loc8_),this.odtInputs.len(_loc8_),this.odtInputs.face(_loc8_),this.odtInputs.chamRound(_loc8_),this.odtInputs.radius(_loc8_));
            _loc5_ += this.odtInputs.len(_loc8_);
            _loc6_ += this.odtInputs.diam(_loc8_);
            _loc7_++;
            _loc8_++;
         }
         var _loc9_:Number = _loc6_ / _loc7_;
         var _loc10_:Number = 4.5;
         var _loc11_:Number;
         if((_loc11_ = _loc5_ / _loc9_) > _loc10_)
         {
            addDFMHint("Avg length to dia ration of " + GWizUtils.roundBigTenths(String(_loc11_)) + " requires tailstock, box cutter, or Swiss machine for accuracy.\n");
         }
         recalcSuffix(_loc4_);
      }
      
      private function cornerDesc(param1:String, param2:String, param3:String) : String
      {
         var _loc4_:* = "";
         if(param1 == "true")
         {
            _loc4_ += ", Face side";
            if(param2 != "None")
            {
               _loc4_ += " and " + param2 + " of " + GWizUtils.roundThousandths(Number(param3));
            }
         }
         return _loc4_;
      }
      
      public function processDiam(param1:Number, param2:Number, param3:String, param4:String, param5:String) : Number
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:String = null;
         var _loc12_:GWizCCWEstRecord = null;
         var _loc13_:GWizCCWEstRecord = null;
         var _loc6_:Object = GWizLatheTools.turningCutDepth(GWizLatheTools.insTypes.getItemAt(this.odtOpts.roughingInsType.selectedIndex),this.odtOpts.roughingInsSize.selectedIndex,GWizLatheTools.CUT_TYPE_ROUGH,this.odtOpts.roughLeadAngle.value);
         if(this.odtOpts.doFinishPass.selected)
         {
            _loc7_ = param1 + this.odtOpts.FinishPass.getVal();
         }
         else
         {
            _loc7_ = param1;
         }
         if(_loc7_ < this.roughStockOD)
         {
            _loc8_ = _loc6_.doc;
            _loc9_ = Math.ceil((this.roughStockOD - _loc7_) / (2 * _loc8_));
            _loc6_.doc = (this.roughStockOD - _loc7_) / 2;
            _loc6_.doc /= _loc9_;
            _loc10_ = param2 + (this.roughStockOD - param1);
            _loc6_.doc = GWizSettings.FeedsSpeedsApp.api.SetupTurningUI(GWizMachSettings.currMachine,GWizCadCam.CADCAMWiz.MatChooser.Selection,"Turning: Carbide",this.roughStockOD,_loc6_.doc,GWizCadCam.CADCAMWiz.ccwOptions.GasPedal.value,true);
            (_loc13_ = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,GWizCCWEstRecord.CCE_LATHE_ODTURN)).op = "Rough OD to " + inchesToDispUnits(_loc7_) + ", len = " + inchesToDispUnits(param2) + this.cornerDesc(param3,param4,param5);
            _loc13_.opTime = 0;
            _loc13_.width = 0;
            _loc13_.tool = "Turning: Carbide";
            _loc13_.toolOther = GWizLatheTools.getInsertDesc(GWizLatheTools.insTypes.getItemAt(this.odtOpts.roughingInsType.selectedIndex),this.odtOpts.roughingInsSize.selectedIndex,this.odtOpts.roughLeadAngle.value);
            _loc13_.roughing = String(true);
            _loc13_.toolDia = this.roughStockOD;
            _loc13_.mrr = GWizSettings.FeedsSpeedsApp.api.getMRR();
            _loc13_.rpm = GWizSettings.FeedsSpeedsApp.api.getRPM();
            _loc13_.sfm = GWizSettings.FeedsSpeedsApp.api.getSFM();
            _loc13_.feedrate = GWizSettings.FeedsSpeedsApp.api.getFeed();
            _loc13_.ipr = GWizSettings.FeedsSpeedsApp.api.getIPR();
            _loc13_.workcenter = GWizMachSettings.currMachine;
            _loc13_.hourly = GWizCadCam.CADCAMWiz.getHourly();
            _loc13_.addHints(GWizSettings.FeedsSpeedsApp);
            if((_loc11_ = GWizSettings.FeedsSpeedsApp.api.cuttingErr()) != "")
            {
               _loc13_.mrr = NaN;
               _loc13_.dfm = _loc11_;
            }
            _loc9_ = Math.ceil((this.roughStockOD - _loc7_) / (2 * _loc6_.doc));
            _loc13_.passes = _loc9_;
            _loc6_.doc = (this.roughStockOD - _loc7_) / 2;
            _loc6_.doc /= _loc9_;
            _loc13_.height = _loc6_.doc;
            _loc13_.volume = GWizGeomUtils.cylinderVolume(this.roughStockOD / 2,param2) - GWizGeomUtils.cylinderVolume(_loc7_ / 2,param2);
            _loc13_.opTime += param2 / _loc13_.feedrate * _loc9_;
            results.addItem(_loc13_);
         }
         if(this.odtOpts.doFinishPass.selected && _loc7_ < this.roughStockOD)
         {
            _loc10_ = param2 + (this.roughStockOD - param1);
            GWizSettings.FeedsSpeedsApp.api.SetupTurningUI(GWizMachSettings.currMachine,GWizCadCam.CADCAMWiz.MatChooser.Selection,"Turning: Carbide",param1,this.odtOpts.FinishPass.getVal() / 2,1);
            (_loc12_ = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,GWizCCWEstRecord.CCE_LATHE_ODTURN)).op = "Finish OD to " + inchesToDispUnits(param1) + ", len = " + inchesToDispUnits(param2) + this.cornerDesc(param3,param4,param5);
            _loc12_.opTime = 0;
            _loc12_.width = 0;
            _loc12_.height = this.odtOpts.FinishPass.getVal() / 2;
            _loc12_.tool = "Turning: Carbide";
            _loc12_.toolOther = GWizLatheTools.getInsertDesc(GWizLatheTools.insTypes.getItemAt(this.odtOpts.finishingInsType.selectedIndex),this.odtOpts.finishingInsSize.selectedIndex,this.odtOpts.finishLeadAngle.value);
            _loc12_.roughing = String(false);
            _loc12_.toolDia = param1;
            _loc12_.mrr = GWizSettings.FeedsSpeedsApp.api.getMRR();
            _loc12_.rpm = GWizSettings.FeedsSpeedsApp.api.getRPM();
            _loc12_.sfm = GWizSettings.FeedsSpeedsApp.api.getSFM();
            _loc12_.feedrate = GWizSettings.FeedsSpeedsApp.api.getFeed();
            _loc12_.ipr = GWizSettings.FeedsSpeedsApp.api.getIPR();
            _loc12_.workcenter = GWizMachSettings.currMachine;
            _loc12_.hourly = GWizCadCam.CADCAMWiz.getHourly();
            _loc12_.addHints(GWizSettings.FeedsSpeedsApp);
            if((_loc11_ = GWizSettings.FeedsSpeedsApp.api.cuttingErr()) != "")
            {
               _loc12_.mrr = NaN;
               _loc12_.dfm = _loc11_;
            }
            _loc12_.passes = 1;
            _loc12_.volume = GWizGeomUtils.cylinderVolume(_loc7_ / 2,param2) - GWizGeomUtils.cylinderVolume(param1 / 2,param2);
            _loc12_.opTime += param2 / _loc12_.feedrate * _loc12_.passes;
            results.addItem(_loc12_);
         }
         return (!!_loc13_ ? _loc13_.opTime : 0) + (!!_loc12_ ? _loc12_.opTime : 0);
      }
   }
}
