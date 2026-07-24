package cadcamwiz
{
   import configinfo.GWizConfigData;
   import configinfo.GWizSettings;
   import machines.GWizMachSettings;
   import mx.core.IFlexModuleFactory;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizCCWThreading extends GWizCCWGenericWizard
   {
      
      private static const log:ILogger = Log.getLogger("GWizCCWFacing");
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var tInputs:GWizCCWThreadingInputs;
      
      private var tOpts:GWizCCWThreadingOptions;
      
      public function GWizCCWThreading()
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
         this.tInputs = new GWizCCWThreadingInputs();
         inputs = this.tInputs;
         inputs.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         this.installInputs(inputs);
         this.tOpts = new GWizCCWThreadingOptions();
         options = this.tOpts;
         options.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         this.installOptions(options);
         FeedsBox.WidthColumn.visible = false;
         GWizSettings.threadingCCW = this;
      }
      
      override public function opType() : String
      {
         return GWizCCWEstRecord.CCE_LATHE_THREADPART;
      }
      
      override public function recalcAux(param1:Boolean = false, param2:Number = 100.0, param3:Boolean = false) : void
      {
         if(!this.tOpts || !this.tOpts.isCarbide || GWizCadCam.currWizard != "Thread")
         {
            return;
         }
         if(recalcPrefix("Lathe"))
         {
            return;
         }
         var _loc4_:Number = 0;
         _loc4_ = this.threadpart(this.tInputs.stockDia.getVal(),this.tInputs.threadDepth.getVal(),this.tInputs.threadPitch.getVal(),this.tInputs.threadLen.getVal());
         recalcSuffix(_loc4_);
      }
      
      public function threadpart(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         var _loc5_:String = null;
         var _loc6_:String = "Threading";
         if(this.tOpts.isCarbide.selected)
         {
            _loc6_ = "Carbide " + _loc6_;
         }
         else
         {
            _loc6_ = "HSS " + _loc6_;
         }
         var _loc7_:int = GWizConfigData.threadPasses(param3);
         var _loc8_:Number = GWizConfigData.firstThreadPass(param2,_loc7_);
         GWizSettings.FeedsSpeedsApp.api.SetupTurningUI(GWizMachSettings.currMachine,GWizCadCam.CADCAMWiz.MatChooser.Selection,_loc6_,param1,_loc8_,GWizCadCam.CADCAMWiz.ccwOptions.GasPedal.value,true);
         var _loc9_:GWizCCWEstRecord;
         (_loc9_ = new GWizCCWEstRecord(GWizCCWEstRecord.MACHINING_TYPE,GWizCCWEstRecord.CCE_LATHE_THREADPART)).op = "Threading";
         _loc9_.opTime = 0;
         _loc9_.width = 0;
         _loc9_.height = _loc8_;
         _loc9_.tool = _loc6_;
         _loc9_.toolOther = "";
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
         if((_loc5_ = GWizSettings.FeedsSpeedsApp.api.cuttingErr()) != "")
         {
            _loc9_.mrr = NaN;
            _loc9_.dfm = _loc5_;
         }
         _loc9_.passes = _loc7_;
         _loc9_.volume = 0;
         _loc9_.perimeter = param4 * _loc7_;
         _loc9_.opTime += _loc9_.perimeter / _loc9_.feedrate;
         if(!isFinite(_loc9_.mrr) || !isFinite(_loc9_.height) || _loc9_.rpm <= 0)
         {
            this.addDFMHint("Error: No feasible solution for these inputs.\n","Threading: ");
         }
         results.addItem(_loc9_);
         return !!_loc9_ ? Number(_loc9_.opTime) : Number(0);
      }
   }
}
