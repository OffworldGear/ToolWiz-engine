package cadcamwiz
{
   import feedsspeeds.GWizFeedSpeedMath;
   import machines.GWizMachSettings;
   import mx.core.IFlexModuleFactory;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import tools.GWizToolChooser;
   
   public class GWizCCWHole extends GWizCCWGenericWizard
   {
      
      private static const log:ILogger = Log.getLogger("GWizCCWHole");
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var drillOptions:Boolean = true;
      
      private var parabolic:Boolean = false;
      
      public function GWizCCWHole()
      {
         super();
         mx_internal::_document = this;
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
         inputs = new GWizCCWHoleInputs();
         inputs.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         inputs.interpOptionsFcn = this.interpOptions;
         this.installInputs(inputs);
         GWizCCWHoleInputs(inputs).onCC();
         options = new GWizCCWHoleOptions();
         options.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         this.installOptions(options);
         FeedsBox.WidthColumn.headerText = "Peck Depth";
         this.interpOptions();
      }
      
      override public function opType() : String
      {
         return GWizCCWEstRecord.CCE_MILL_HOLE;
      }
      
      override public function recalcAux(param1:Boolean = false, param2:Number = 100.0, param3:Boolean = false) : void
      {
         var _loc5_:GWizCCWEstRecord = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:GWizCCWEstRecord = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Object = null;
         var _loc14_:Number = NaN;
         var _loc15_:GWizCCWEstRecord = null;
         var _loc16_:GWizCCWEstRecord = null;
         var _loc17_:GWizCCWEstRecord = null;
         var _loc18_:GWizCCWEstRecord = null;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:GWizCCWEstRecord = null;
         var _loc24_:Number = NaN;
         if(recalcPrefix(""))
         {
            return;
         }
         var _loc4_:Number = 0;
         var _loc6_:Number = inputs.HoleDia.getVal();
         if(!inputs.Interpolate.selected)
         {
            if(inputs.SpotDrill.selected)
            {
               _loc10_ = GWizCadCam.recalcEngine.spotDrill(this.opType(),_loc6_,0,0,false,this.TimeFactor.value,false);
               _loc10_.opTime += GWizMachSettings.getToolChangeTime();
               _loc10_.var1 = this.TimeFactor.value;
               results.addItem(_loc10_);
               _loc4_ += _loc10_.opTime;
               this.addDFMHint(GWizCadCam.recalcEngine.drillDFM,"Spot Drill ");
            }
            if(inputs.Ream.selected)
            {
               _loc11_ = _loc6_ - 0.05 * _loc6_;
               _loc12_ = _loc6_ - 0.02 * _loc6_;
               if((_loc14_ = (_loc13_ = GWizToolChooser.findDrillEntry(_loc12_)).inch) > _loc12_ || _loc14_ < _loc11_)
               {
                  this.addDFMHint("Available Twist Drill sizes are not ideal for this reamer. Should be 2-5% smaller diameter than the reamer.");
               }
               _loc6_ = _loc14_;
            }
            _loc8_ = inputs.Depth.getVal() / _loc6_;
            this.parabolic = false;
            _loc9_ = NaN;
            if(_loc8_ > 20)
            {
               this.addDFMHint("This hole is too deep: it\'ll require proprietary development work or special tooling.");
            }
            else
            {
               if(_loc8_ > 7)
               {
                  this.parabolic = true;
               }
               _loc9_ = GWizFeedSpeedMath.peckDepth(_loc6_,inputs.Depth.getVal(),options.HSS.selected || options.CarbideHP.selected,options.Carbide.selected || options.CarbideHP.selected || options.Indexable.selected);
               GWizToolChooser.setDrillStr(options.HSS.selected,options.HSSHP.selected,options.Cobalt.selected,options.Carbide.selected,options.CarbideHP.selected,options.Indexable.selected);
               _loc5_ = GWizCadCam.recalcEngine.drillMRR(this.opType(),_loc6_,inputs.Depth.getVal(),this.parabolic,_loc9_,GWizCCWMillOptions.usePremiumCoolantOptions);
               this.addDFMHint(GWizCadCam.recalcEngine.drillDFM,"Drill ");
               _loc5_.var1 = this.TimeFactor.value;
               _loc4_ += _loc5_.opTime;
               results.addItem(_loc5_);
               if(inputs.Ream.selected)
               {
                  (_loc15_ = GWizCadCam.recalcEngine.reamMRR(inputs.HoleDia.getVal(),inputs.Depth.getVal())).var1 = this.TimeFactor.value;
                  results.addItem(_loc15_);
                  _loc4_ += _loc15_.opTime;
                  this.addDFMHint(GWizCadCam.recalcEngine.drillDFM,"Reamer ");
               }
               if(inputs.Chamfer.selected)
               {
                  (_loc16_ = GWizCadCam.recalcEngine.spotDrill(this.opType(),inputs.HoleDia.getVal(),inputs.ChamferSize.getVal(),_loc6_ * Math.PI,false,this.TimeFactor.value,false)).op = GWizCCWEstRecord.CCE_SPOT_DRILL;
                  _loc16_.var1 = this.TimeFactor.value;
                  results.addItem(_loc16_);
                  _loc4_ += _loc16_.opTime;
                  this.addDFMHint(GWizCadCam.recalcEngine.drillDFM,"Chamfer ");
               }
               if(inputs.Threading.selected)
               {
                  if(inputs.ThreadMill.selected)
                  {
                     (_loc17_ = GWizCadCam.recalcEngine.threadMillMRR(inputs.HoleDia.getVal(),inputs.ThreadPitch.value,inputs.Depth.getVal())).op = "Thread Mill";
                     _loc17_.var1 = this.TimeFactor.value;
                     _loc17_.opTime += GWizMachSettings.getToolChangeTime();
                     results.addItem(_loc17_);
                     _loc4_ += _loc17_.opTime;
                  }
                  else
                  {
                     (_loc18_ = GWizCadCam.recalcEngine.tappingMRR(inputs.CutTap.selected,inputs.CarbideTool.selected,inputs.HoleDia.getVal(),inputs.ThreadPitch.value,inputs.Depth.getVal())).var1 = this.TimeFactor.value;
                     _loc18_.opTime += GWizMachSettings.getToolChangeTime();
                     _loc18_.perimeter = inputs.Depth.getVal();
                     _loc18_.op = GWizCCWEstRecord.CCE_TAP;
                     results.addItem(_loc18_);
                     _loc4_ += _loc18_.opTime;
                  }
               }
            }
         }
         else
         {
            if(inputs.HoleDia.getVal() <= 0.5)
            {
               this.addDFMHint("It\'s usually faster to use a Twist Drill than interpolation for smaller holes.");
            }
            GWizToolChooser.setToolStr(options.interpOptions.Carbide.selected,options.interpOptions.HSS.selected,options.interpOptions.HSSHP.selected,options.interpOptions.CarbideHP.selected,options.interpOptions.CarbideTiAlN.selected,options.interpOptions.roughStrat.selectedItem && options.interpOptions.roughStrat.selectedItem.name.toUpperCase().indexOf("INDEXABLE") >= 0,false);
            options.interpOptions.Flutes.setVal(GWizToolChooser.calcFlutes());
            _loc19_ = 0.625;
            _loc20_ = GWizToolChooser.calcToolDia(GWizToolChooser.toolStr,_loc6_ / 2 * _loc19_,options.interpOptions.Flutes.value,_loc6_,_loc6_,options.interpOptions.ToolDia,true,true,false);
            options.interpOptions.ToolDia.setVal(_loc20_);
            if(inputs.Depth.getVal() > 2 * _loc20_)
            {
               this.addDFMHint("Try to avoid interpolating more than 2 diameters deep due to chip clearing problems.");
            }
            options.interpOptions.Stickout.setVal(inputs.Depth.getVal() + _loc20_);
            _loc5_ = GWizCadCam.recalcEngine.recalcProfilePass(GWizCCWEstRecord.CCE_MILL_POCKET,2 * _loc20_ / 3,inputs.Depth.getVal(),_loc24_,options.interpOptions.ToolDia.getVal(),options.interpOptions.Flutes.getVal(),options.interpOptions.Stickout.getVal(),false,false,false,GWizCCWMillOptions.usePremiumCoolantOptions);
            _loc21_ = 0;
            if(inputs.finishPassGrp.useFinish.selected)
            {
               _loc21_ = 2 * inputs.finishPassGrp.FinishPass.getVal();
            }
            _loc22_ = _loc6_ - _loc21_;
            _loc5_.volume = Math.PI * (_loc22_ / 2) * (_loc22_ / 2) * inputs.Depth.getVal();
            _loc5_.opTime = _loc5_.timeByType();
            _loc4_ += _loc5_.opTime;
            _loc5_.var1 = this.TimeFactor.value;
            _loc5_.tool = GWizToolChooser.getToolDesc(true,false,options.interpOptions.ToolDia.getVal(),options.interpOptions.Flutes.getVal());
            if(_loc5_)
            {
               _loc5_.op = "Rough";
               _loc5_.passes = Math.ceil(inputs.Depth.getVal() / (_loc20_ / 2));
               results.addItem(_loc5_);
            }
            _loc23_ = null;
            if(inputs.finishPassGrp.useFinish.selected)
            {
               GWizToolChooser.setToolStr(options.interpOptions.Carbide.selected,options.interpOptions.HSS.selected,options.interpOptions.HSSHP.selected,options.interpOptions.CarbideHP.selected,options.interpOptions.CarbideTiAlN.selected,false,false);
               _loc24_ = _loc6_ * Math.PI;
               (_loc23_ = GWizCadCam.recalcEngine.recalcProfilePass(GWizCCWEstRecord.CCE_MILL_2DProfile,inputs.finishPassGrp.FinishPass.getVal(),inputs.Depth.getVal(),_loc24_,options.interpOptions.ToolDia.getVal(),options.interpOptions.Flutes.getVal(),options.interpOptions.Stickout.getVal(),true,false,false,false)).perimeter = _loc24_;
               _loc23_.var1 = this.TimeFactor.value;
               _loc23_.opTime = _loc23_.timeByType();
               _loc4_ += _loc23_.opTime;
            }
            if(_loc23_)
            {
               _loc23_.op = "Finish";
               results.addItem(_loc23_);
            }
         }
         var _loc7_:Date = new Date();
         if(this.dfmNum <= 1)
         {
            dfmHints(_loc5_,null,_loc23_,start,_loc7_);
         }
         else
         {
            endDFMHints();
         }
         recalcSuffix(_loc4_);
      }
      
      private function interpOptions() : void
      {
         if(!inputs.Interpolate.selected)
         {
            FeedsBox.WidthColumn.headerText = "Peck Depth";
            inputs.HoleOpsGrp.enabled = true;
            (options as GWizCCWHoleOptions).selectedChild = options.drillOptions;
         }
         else
         {
            FeedsBox.WidthColumn.headerText = "Cut Width";
            inputs.HoleOpsGrp.enabled = false;
            (options as GWizCCWHoleOptions).selectedChild = options.interpOptions;
            options.interpOptions.roughLbl.visible = false;
            options.interpOptions.roughStrat.visible = false;
         }
      }
   }
}
