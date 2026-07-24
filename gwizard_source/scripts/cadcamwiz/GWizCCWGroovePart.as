package cadcamwiz
{
   import configinfo.GWizSettings;
   import machines.GWizMachSettings;
   import mx.core.IFlexModuleFactory;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizGeomUtils;
   
   public class GWizCCWGroovePart extends GWizCCWGenericWizard
   {
      
      private static const log:ILogger = Log.getLogger("GWizCCWFacing");
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var gpInputs:GWizCCWGroovePartInputs;
      
      private var gpOpts:GWizCCWGroovePartOptions;
      
      public function GWizCCWGroovePart()
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
         this.gpInputs = new GWizCCWGroovePartInputs();
         inputs = this.gpInputs;
         inputs.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         this.installInputs(inputs);
         this.gpOpts = new GWizCCWGroovePartOptions();
         options = this.gpOpts;
         options.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         this.installOptions(options);
         FeedsBox.WidthColumn.visible = false;
      }
      
      override public function opType() : String
      {
         return GWizCCWEstRecord.CCE_LATHE_GROOVEPART;
      }
      
      override public function recalcAux(param1:Boolean = false, param2:Number = 100.0, param3:Boolean = false) : void
      {
         if(!this.gpOpts || !this.gpOpts.toolWidth || GWizCadCam.currWizard != "Groove/Part")
         {
            return;
         }
         if(recalcPrefix("Lathe"))
         {
            return;
         }
         var _loc4_:Number = 0;
         _loc4_ = this.groovepart(this.gpInputs.xStart.getVal(),this.gpInputs.xEnd.getVal(),Math.abs(0 - this.gpOpts.toolWidth.getVal()));
         addDFMHint("Use CSS and program speed using Surface Speed.  Parting may need a 2nd slower pass when almost done to catch part.");
         recalcSuffix(_loc4_);
      }
      
      public function groovepart(param1:Number, param2:Number, param3:Number) : Number
      {
         var _loc4_:String = null;
         var _loc5_:String = "Parting/Grooving";
         if(this.gpOpts.isCarbide.selected)
         {
            _loc5_ = "Carbide " + _loc5_;
         }
         else
         {
            _loc5_ = "HSS " + _loc5_;
         }
         GWizSettings.FeedsSpeedsApp.api.SetupTurningUI(GWizMachSettings.currMachine,GWizCadCam.CADCAMWiz.MatChooser.Selection,_loc5_,param1,this.gpOpts.toolWidth.getVal(),GWizCadCam.CADCAMWiz.ccwOptions.GasPedal.value);
         var _loc6_:GWizCCWEstRecord;
         (_loc6_ = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,GWizCCWEstRecord.CCE_LATHE_GROOVEPART)).op = "Groove/Part from OD " + inchesToDispUnits(param1) + " to ID " + inchesToDispUnits(param2);
         _loc6_.opTime = 0;
         _loc6_.width = 0;
         _loc6_.height = this.gpOpts.toolWidth.getVal();
         _loc6_.tool = _loc5_ + ", " + this.gpOpts.toolWidth.getVal() + "in. wide.";
         _loc6_.toolOther = "";
         _loc6_.roughing = String(true);
         _loc6_.toolDia = param1;
         _loc6_.mrr = GWizSettings.FeedsSpeedsApp.api.getMRR();
         _loc6_.rpm = GWizSettings.FeedsSpeedsApp.api.getRPM();
         _loc6_.sfm = GWizSettings.FeedsSpeedsApp.api.getSFM();
         _loc6_.feedrate = GWizSettings.FeedsSpeedsApp.api.getFeed();
         _loc6_.ipr = GWizSettings.FeedsSpeedsApp.api.getIPR();
         _loc6_.workcenter = GWizMachSettings.currMachine;
         _loc6_.hourly = GWizCadCam.CADCAMWiz.getHourly();
         _loc6_.addHints(GWizSettings.FeedsSpeedsApp);
         if((_loc4_ = GWizSettings.FeedsSpeedsApp.api.cuttingErr()) != "")
         {
            _loc6_.mrr = NaN;
            _loc6_.dfm = _loc4_;
            this.addDFMHint(_loc4_,"Part/Groove: ");
         }
         var _loc7_:Number = 20 * this.gpOpts.toolWidth.getVal();
         if(param1 - param2 > _loc7_)
         {
            _loc6_.dfm += "Recommend not parting/grooving deeper than 10x tool width\n";
            this.addDFMHint("Recommend not parting/grooving deeper than 10x tool width\n","Part/Groove: ");
         }
         _loc6_.passes = 1;
         _loc6_.volume = GWizGeomUtils.cylinderVolume(param1 / 2,this.gpOpts.toolWidth.getVal());
         var _loc8_:Number = Math.max(1,Math.ceil(this.gpInputs.grooveWidth.value / this.gpOpts.toolWidth.value));
         _loc6_.opTime += param1 / 2 / _loc6_.feedrate * _loc8_;
         results.addItem(_loc6_);
         return !!_loc6_ ? Number(_loc6_.opTime) : Number(0);
      }
   }
}
