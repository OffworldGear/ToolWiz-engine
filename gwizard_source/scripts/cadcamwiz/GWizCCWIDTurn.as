package cadcamwiz
{
   import configinfo.GWizLatheTools;
   import configinfo.GWizSettings;
   import machines.GWizMachSettings;
   import mx.core.IFlexModuleFactory;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizGeomUtils;
   
   public class GWizCCWIDTurn extends GWizCCWGenericWizard
   {
      
      private static const log:ILogger = Log.getLogger("GWizCCWFacing");
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var idInputs:GWizCCWIDTurnInputs;
      
      private var odtOpts:GWizCCWODTurnOptions;
      
      public function GWizCCWIDTurn()
      {
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
         this.idInputs = new GWizCCWIDTurnInputs();
         inputs = this.idInputs;
         inputs.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         this.installInputs(inputs);
         this.odtOpts = new GWizCCWODTurnOptions();
         options = this.odtOpts;
         options.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         this.installOptions(options);
         FeedsBox.WidthColumn.visible = false;
      }
      
      override public function opType() : String
      {
         return GWizCCWEstRecord.CCE_LATHE_FACING;
      }
      
      override public function recalcAux(param1:Boolean = false, param2:Number = 100.0, param3:Boolean = false) : void
      {
         if(!this.odtOpts || !this.odtOpts.roughingInsType || this.odtOpts.roughingInsType.selectedIndex < 0 || GWizCadCam.currWizard != "ID Turn")
         {
            return;
         }
         if(recalcPrefix("Lathe"))
         {
            return;
         }
         var _loc4_:Number = 0;
         var _loc5_:Number = Math.abs(this.idInputs.zStart.getVal() - this.idInputs.zEnd.getVal());
         _loc4_ = this.boring(this.idInputs.xStart.getVal(),this.idInputs.xEnd.getVal(),_loc5_);
         var _loc6_:Number;
         var _loc7_:Number = (_loc6_ = this.idInputs.xEnd.getVal() * 0.8) * 4;
         var _loc8_:Number = _loc6_ * 8;
         if(this.idInputs.EstimatorInputs.visible)
         {
            if(_loc5_ > _loc8_)
            {
               this.addDFMHint("Bore is too long relative to ID diameter. A carbide boring bar can do 8 diameters in length.");
            }
            else if(_loc5_ > _loc7_)
            {
               this.addDFMHint("Bore requires a carbide boring bar.");
            }
         }
         recalcSuffix(_loc4_);
      }
      
      public function boring(param1:Number, param2:Number, param3:Number) : Number
      {
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:String = null;
         var _loc10_:GWizCCWEstRecord = null;
         var _loc4_:Object = GWizLatheTools.turningCutDepth(GWizLatheTools.insTypes.getItemAt(this.odtOpts.roughingInsType.selectedIndex),this.odtOpts.roughingInsSize.selectedIndex,GWizLatheTools.CUT_TYPE_ROUGH,this.odtOpts.roughLeadAngle.value);
         _loc7_ = param1 - param2;
         if(this.odtOpts.doFinishPass.selected)
         {
            _loc7_ -= this.odtOpts.FinishPass.getVal();
         }
         _loc5_ = _loc4_.doc;
         if((_loc6_ = int(_loc7_ / _loc5_)) * _loc5_ < _loc7_)
         {
            _loc6_++;
            _loc5_ = _loc7_ / _loc6_;
            _loc4_.doc = _loc5_;
         }
         _loc4_.doc = GWizSettings.FeedsSpeedsApp.api.SetupTurningUI(GWizMachSettings.currMachine,GWizCadCam.CADCAMWiz.MatChooser.Selection,"Turning: Carbide",param1,_loc4_.doc,GWizCadCam.CADCAMWiz.ccwOptions.GasPedal.value,true);
         var _loc9_:GWizCCWEstRecord;
         (_loc9_ = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,GWizCCWEstRecord.CCE_LATHE_IDTURN)).op = "Rough bore from ID " + inchesToDispUnits(param2) + " to OD " + inchesToDispUnits(param1) + ", len = " + inchesToDispUnits(param3);
         _loc9_.opTime = 0;
         _loc9_.width = 0;
         _loc9_.height = _loc4_.doc;
         _loc9_.tool = "Turning: Carbide";
         _loc9_.toolOther = GWizLatheTools.getInsertDesc(GWizLatheTools.insTypes.getItemAt(this.odtOpts.roughingInsType.selectedIndex),this.odtOpts.roughingInsSize.selectedIndex,this.odtOpts.roughLeadAngle.value);
         _loc9_.roughing = String(true);
         _loc9_.toolDia = param1;
         _loc9_.mrr = GWizSettings.FeedsSpeedsApp.api.getMRR();
         _loc9_.rpm = GWizSettings.FeedsSpeedsApp.api.getRPM();
         _loc9_.sfm = GWizSettings.FeedsSpeedsApp.api.getSFM();
         _loc9_.feedrate = GWizSettings.FeedsSpeedsApp.api.getFeed();
         _loc9_.ipr = GWizSettings.FeedsSpeedsApp.api.getIPR();
         _loc9_.workcenter = GWizMachSettings.currMachine;
         _loc9_.hourly = GWizCadCam.CADCAMWiz.getHourly();
         _loc9_.addHints(GWizSettings.FeedsSpeedsApp);
         if((_loc8_ = GWizSettings.FeedsSpeedsApp.api.cuttingErr()) != "")
         {
            _loc9_.mrr = NaN;
            _loc9_.dfm = _loc8_;
         }
         _loc9_.passes = _loc6_;
         _loc9_.volume = GWizGeomUtils.cylinderVolume(param1 / 2,param3) - GWizGeomUtils.cylinderVolume(param2 / 2,param3);
         _loc9_.opTime += param3 / _loc9_.feedrate * _loc6_;
         results.addItem(_loc9_);
         if(this.odtOpts.doFinishPass.selected)
         {
            GWizSettings.FeedsSpeedsApp.api.SetupTurningUI(GWizMachSettings.currMachine,GWizCadCam.CADCAMWiz.MatChooser.Selection,"Turning: Carbide",param1,this.odtOpts.FinishPass.getVal(),1);
            (_loc10_ = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,GWizCCWEstRecord.CCE_LATHE_IDTURN)).op = "Finish bore from ID " + inchesToDispUnits(param2) + " to OD " + inchesToDispUnits(param1) + ", len = " + inchesToDispUnits(param3);
            _loc10_.opTime = 0;
            _loc10_.width = 0;
            _loc10_.height = this.odtOpts.FinishPass.getVal();
            _loc10_.tool = "Turning: Carbide";
            _loc10_.toolOther = GWizLatheTools.getInsertDesc(GWizLatheTools.insTypes.getItemAt(this.odtOpts.finishingInsType.selectedIndex),this.odtOpts.finishingInsSize.selectedIndex,this.odtOpts.finishLeadAngle.value);
            _loc10_.roughing = String(false);
            _loc10_.toolDia = param1;
            _loc10_.mrr = GWizSettings.FeedsSpeedsApp.api.getMRR();
            _loc10_.rpm = GWizSettings.FeedsSpeedsApp.api.getRPM();
            _loc10_.sfm = GWizSettings.FeedsSpeedsApp.api.getSFM();
            _loc10_.feedrate = GWizSettings.FeedsSpeedsApp.api.getFeed();
            _loc10_.ipr = GWizSettings.FeedsSpeedsApp.api.getIPR();
            _loc10_.workcenter = GWizMachSettings.currMachine;
            _loc10_.hourly = GWizCadCam.CADCAMWiz.getHourly();
            _loc10_.addHints(GWizSettings.FeedsSpeedsApp);
            if((_loc8_ = GWizSettings.FeedsSpeedsApp.api.cuttingErr()) != "")
            {
               _loc10_.mrr = NaN;
               _loc10_.dfm = _loc8_;
            }
            _loc10_.passes = 1;
            _loc10_.volume = GWizGeomUtils.cylinderVolume(param1 / 2,param3) - GWizGeomUtils.cylinderVolume(param2 / 2,param3);
            _loc10_.opTime += param3 / _loc10_.feedrate;
            results.addItem(_loc10_);
         }
         return (!!_loc9_ ? _loc9_.opTime : 0) + (!!_loc10_ ? _loc10_.opTime : 0);
      }
   }
}
