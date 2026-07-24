package cadcamwiz
{
   import feedsspeeds.GWizSurfaceFinishMill;
   import mx.core.IFlexModuleFactory;
   
   public class GWizCCW3DSurface extends GWizCCWGenericWizard
   {
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizCCW3DSurface()
      {
         super();
         mx_internal::_document = this;
      }
      
      public static function finishPathLen(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number) : Number
      {
         var _loc6_:Number = Math.ceil(param1 / param4);
         var _loc7_:Number = Math.ceil(param2 / param4);
         var _loc8_:Number = Math.ceil(param3 / param5);
         _loc6_ = Math.ceil(_loc6_ / 2);
         _loc7_ = Math.ceil(_loc7_ / 2);
         var _loc9_:Number;
         var _loc10_:Number = (_loc10_ = (_loc9_ = Math.ceil(_loc6_ * _loc7_)) * 4 * _loc8_) + _loc8_ * 2;
         return Number(param4 * _loc10_);
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
         inputs = new GWizCCW3DSurfaceInputs();
         inputs.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         this.installInputs(inputs);
         options = getPocketOptions();
         var _loc1_:GWizCCPocketOptions = options as GWizCCPocketOptions;
         GWizCCPocketOptions.showEntry = false;
         options.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         installOptions(options);
      }
      
      override public function recalcAux(param1:Boolean = false, param2:Number = 100.0, param3:Boolean = false) : void
      {
         var _loc4_:Number = NaN;
         if(!recalcPrefix("Mill"))
         {
            _loc4_ = GWizSurfaceFinishMill.stepover(inputs.MaxToolDia.value,inputs.Tolerance.value);
            inputs.finishPassGrp.FinishPass.setVal(Math.min(_loc4_,0.1));
            super.recalcAux(true,GWizCCW3DSurfaceInputs(inputs).PctRemoved.value,true);
         }
      }
      
      override public function opType() : String
      {
         return GWizCCWEstRecord.CCE_MILL_3DSURFACE;
      }
   }
}
