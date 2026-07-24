package cadcamwiz
{
   import mx.core.IFlexModuleFactory;
   
   public class GWizCCWFaceMill extends GWizCCWGenericWizard
   {
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizCCWFaceMill()
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
         inputs = new GWizCCWFaceMillInputs();
         inputs.recalc = GWizCadCam.CADCAMWiz.requestRecalc;
         this.installInputs(inputs);
         this.removeOptions();
         useFacemill = true;
      }
      
      override public function initStrategies(param1:Object) : void
      {
         useHSM = false;
         useLarge = false;
         useCorncob = false;
         useIndexable = false;
         useFacemill = true;
      }
      
      override public function hasOptions() : Boolean
      {
         return false;
      }
      
      override public function opType() : String
      {
         return GWizCCWEstRecord.CCE_MILL_FACEMILL;
      }
   }
}
