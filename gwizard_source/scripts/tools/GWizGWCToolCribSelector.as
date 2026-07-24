package tools
{
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import spark.components.DropDownList;
   import spark.events.IndexChangeEvent;
   
   public class GWizGWCToolCribSelector extends DropDownList
   {
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var changeFcn:Function;
      
      public var valueCommitFcn:Function;
      
      public function GWizGWCToolCribSelector()
      {
         super();
         this.percentWidth = 100;
         this.labelField = "tabname";
         this.addEventListener("change",this.___GWizGWCToolCribSelector_DropDownList1_change);
         this.addEventListener("valueCommit",this.___GWizGWCToolCribSelector_DropDownList1_valueCommit);
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
      
      private function doChange() : void
      {
         if(this.changeFcn != null)
         {
            this.changeFcn();
         }
      }
      
      private function doValueCommit() : void
      {
         if(this.valueCommitFcn != null)
         {
            this.valueCommitFcn();
         }
      }
      
      public function ___GWizGWCToolCribSelector_DropDownList1_change(param1:IndexChangeEvent) : void
      {
         this.doChange();
      }
      
      public function ___GWizGWCToolCribSelector_DropDownList1_valueCommit(param1:FlexEvent) : void
      {
         this.doValueCommit();
      }
   }
}
