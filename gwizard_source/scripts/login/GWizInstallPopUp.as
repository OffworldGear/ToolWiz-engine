package login
{
   import comps.GWizPopUp;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.TextArea;
   
   public class GWizInstallPopUp extends GWizPopUp
   {
       
      
      private var _108417msg:TextArea;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var browserFcn:Function;
      
      public function GWizInstallPopUp()
      {
         super();
         mx_internal::_document = this;
         this.title = "New Version Installer";
         this.width = 400;
         this.height = 150;
         this.okLabel = "Browser";
         this.cancelLabel = "Cancel";
         this.mxmlContent = [this._GWizInstallPopUp_TextArea1_i()];
         this.addEventListener("creationComplete",this.___GWizInstallPopUp_GWizPopUp1_creationComplete);
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
      
      private function onCC() : void
      {
         this.msg.text = "There is a newer version of the software available. Click the Browser ";
         this.msg.text += "button to popup a browser and visit the download page where you can ";
         this.msg.text += "get the new version.  If you get a certificate error, uninstall the current ";
         this.msg.text += "version via Windows Control Panel before installing the new version.";
      }
      
      override public function onOk(param1:Event) : void
      {
         super.onOk(param1);
         if(this.browserFcn != null)
         {
            this.browserFcn();
         }
      }
      
      private function _GWizInstallPopUp_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.editable = false;
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "msg";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.msg = _loc1_;
         BindingManager.executeBindings(this,"msg",this.msg);
         return _loc1_;
      }
      
      public function ___GWizInstallPopUp_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      [Bindable(event="propertyChange")]
      public function get msg() : TextArea
      {
         return this._108417msg;
      }
      
      public function set msg(param1:TextArea) : void
      {
         var _loc2_:Object = this._108417msg;
         if(_loc2_ !== param1)
         {
            this._108417msg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"msg",_loc2_,param1));
            }
         }
      }
   }
}
