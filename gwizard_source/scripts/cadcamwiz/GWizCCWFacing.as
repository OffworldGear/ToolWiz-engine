package cadcamwiz
{
   import configinfo.GWizLatheTools;
   import configinfo.GWizSettings;
   import machines.GWizMachSettings;
   import mx.core.IFlexModuleFactory;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizGeomUtils;
   
   public class GWizCCWFacing extends GWizCCWGenericWizard
   {
      
      private static const log:ILogger = Log.getLogger("GWizCCWFacing");
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var facingInputs:GWizCCWFacingInputs;
      
      private var odtOpts:GWizCCWODTurnOptions;
      
      public function GWizCCWFacing()
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
         this.facingInputs = new GWizCCWFacingInputs();
         inputs = this.facingInputs;
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
         if(!this.odtOpts || !this.odtOpts.roughingInsType || this.odtOpts.roughingInsType.selectedIndex < 0 || GWizCadCam.currWizard != "Face")
         {
            return;
         }
         if(recalcPrefix("Lathe"))
         {
            return;
         }
         var _loc4_:Number = 0;
         _loc4_ = this.facing(this.facingInputs.xStart.getVal(),this.facingInputs.xEnd.getVal(),Math.abs(this.facingInputs.zStart.getVal() - this.facingInputs.zEnd.getVal()));
         addDFMHint("Use CSS and program speed using Surface Speed.");
         recalcSuffix(_loc4_);
      }
      
      public function facing(param1:Number, param2:Number, param3:Number) : Number
      {
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:String = null;
         var _loc9_:GWizCCWEstRecord = null;
         var _loc4_:Object = GWizLatheTools.turningCutDepth(GWizLatheTools.insTypes.getItemAt(this.odtOpts.roughingInsType.selectedIndex),this.odtOpts.roughingInsSize.selectedIndex,GWizLatheTools.CUT_TYPE_ROUGH,this.odtOpts.roughLeadAngle.value);
         if(this.odtOpts.doFinishPass.selected)
         {
            _loc6_ = param3 - this.odtOpts.FinishPass.getVal();
         }
         else
         {
            _loc6_ = param3;
         }
         var _loc8_:GWizCCWEstRecord = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,GWizCCWEstRecord.CCE_LATHE_FACING);
         _loc4_.doc = GWizSettings.FeedsSpeedsApp.api.SetupTurningUI(GWizMachSettings.currMachine,GWizCadCam.CADCAMWiz.MatChooser.Selection,"Turning: Carbide",param1,_loc4_.doc,GWizCadCam.CADCAMWiz.ccwOptions.GasPedal.value,true);
         _loc8_.op = "Rough Face from OD " + inchesToDispUnits(param1) + " to ID " + inchesToDispUnits(param2) + ", len = " + inchesToDispUnits(_loc6_);
         _loc8_.opTime = 0;
         _loc8_.width = 0;
         _loc8_.height = _loc4_.doc;
         _loc8_.tool = "Turning: Carbide";
         _loc8_.toolOther = GWizLatheTools.getInsertDesc(GWizLatheTools.insTypes.getItemAt(this.odtOpts.roughingInsType.selectedIndex),this.odtOpts.roughingInsSize.selectedIndex,this.odtOpts.roughLeadAngle.value);
         _loc8_.roughing = String(true);
         _loc8_.toolDia = param1;
         _loc8_.mrr = GWizSettings.FeedsSpeedsApp.api.getMRR();
         _loc8_.rpm = GWizSettings.FeedsSpeedsApp.api.getRPM();
         _loc8_.sfm = GWizSettings.FeedsSpeedsApp.api.getSFM();
         _loc8_.feedrate = GWizSettings.FeedsSpeedsApp.api.getFeed();
         _loc8_.ipr = GWizSettings.FeedsSpeedsApp.api.getIPR();
         _loc8_.workcenter = GWizMachSettings.currMachine;
         _loc8_.hourly = GWizCadCam.CADCAMWiz.getHourly();
         _loc8_.addHints(GWizSettings.FeedsSpeedsApp);
         if((_loc7_ = GWizSettings.FeedsSpeedsApp.api.cuttingErr()) != "")
         {
            _loc8_.mrr = NaN;
            _loc8_.dfm = _loc7_;
         }
         _loc5_ = Math.ceil(_loc6_ / _loc4_.doc);
         _loc8_.passes = _loc5_;
         _loc8_.volume = GWizGeomUtils.cylinderVolume(param1 / 2,_loc6_) - GWizGeomUtils.cylinderVolume(param2 / 2,_loc6_);
         _loc8_.opTime += _loc6_ / _loc8_.feedrate * _loc5_;
         results.addItem(_loc8_);
         if(this.odtOpts.doFinishPass.selected)
         {
            GWizSettings.FeedsSpeedsApp.api.SetupTurningUI(GWizMachSettings.currMachine,GWizCadCam.CADCAMWiz.MatChooser.Selection,"Turning: Carbide",param1,this.odtOpts.FinishPass.getVal(),1,false);
            (_loc9_ = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,GWizCCWEstRecord.CCE_LATHE_FACING)).op = "Finish Face from OD " + inchesToDispUnits(param1) + " to ID " + inchesToDispUnits(param2) + ", len = " + inchesToDispUnits(param3);
            _loc9_.opTime = 0;
            _loc9_.width = 0;
            _loc9_.height = this.odtOpts.FinishPass.getVal();
            _loc9_.tool = "Turning: Carbide";
            _loc9_.toolOther = GWizLatheTools.getInsertDesc(GWizLatheTools.insTypes.getItemAt(this.odtOpts.finishingInsType.selectedIndex),this.odtOpts.finishingInsSize.selectedIndex,this.odtOpts.finishLeadAngle.value);
            _loc9_.roughing = String(false);
            _loc9_.toolDia = param1;
            _loc9_.mrr = GWizSettings.FeedsSpeedsApp.api.getMRR();
            _loc9_.rpm = GWizSettings.FeedsSpeedsApp.api.getRPM();
            _loc9_.sfm = GWizSettings.FeedsSpeedsApp.api.getSFM();
            _loc9_.feedrate = GWizSettings.FeedsSpeedsApp.api.getFeed();
            _loc9_.ipr = GWizSettings.FeedsSpeedsApp.api.getIPR();
            _loc9_.workcenter = GWizMachSettings.currMachine;
            _loc9_.hourly = GWizCadCam.CADCAMWiz.getHourly();
            _loc9_.addHints(GWizSettings.FeedsSpeedsApp);
            if((_loc7_ = GWizSettings.FeedsSpeedsApp.api.cuttingErr()) != "")
            {
               _loc9_.mrr = NaN;
               _loc9_.dfm = _loc7_;
            }
            _loc9_.passes = 1;
            _loc9_.volume = GWizGeomUtils.cylinderVolume(param1 / 2,param3) - GWizGeomUtils.cylinderVolume(param2 / 2,param3);
            _loc9_.opTime += param3 / _loc9_.feedrate;
            results.addItem(_loc9_);
         }
         return (!!_loc8_ ? _loc8_.opTime : 0) + (!!_loc9_ ? _loc9_.opTime : 0);
      }
   }
}
