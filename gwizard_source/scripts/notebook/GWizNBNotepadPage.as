package notebook
{
   import comps.GWizPopUpManager;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.TextArea;
   import spark.components.VGroup;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   public class GWizNBNotepadPage extends VGroup
   {
       
      
      private var _1004197030textArea:TextArea;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var url:String;
      
      private var creationComplete:Boolean = false;
      
      public function GWizNBNotepadPage()
      {
         super();
         mx_internal::_document = this;
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContent = [this._GWizNBNotepadPage_TextArea1_i()];
         this.addEventListener("creationComplete",this.___GWizNBNotepadPage_VGroup1_creationComplete);
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
      
      protected function creationCompleteHandler(param1:FlexEvent) : void
      {
         this.creationComplete = true;
         if(this.url != null)
         {
            this.loadURL();
         }
      }
      
      public function setURL(param1:String) : void
      {
         this.url = param1;
         if(!this.creationComplete)
         {
            this.loadURL();
         }
      }
      
      private function loadURL() : void
      {
         var stream:FileStream = null;
         var buffer:String = null;
         if(GWizStringUtils.isBlank(this.url))
         {
            return;
         }
         var nbFile:File = new File(this.url);
         var error:Boolean = true;
         try
         {
            stream = new FileStream();
            if(nbFile.exists)
            {
               stream.open(nbFile,FileMode.READ);
               buffer = stream.readUTFBytes(stream.bytesAvailable);
               stream.close();
               this.textArea.text = buffer;
               error = false;
            }
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Notebook page \'" + url + "\' could not be loaded.");
         }
         if(error)
         {
            GWizPopUpManager.Show("Notebook page \'" + this.url + "\' could not be loaded.","Error: Page Load Failed",GWizPopUpManager.ERROR);
         }
      }
      
      private function _GWizNBNotepadPage_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "textArea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.textArea = _loc1_;
         BindingManager.executeBindings(this,"textArea",this.textArea);
         return _loc1_;
      }
      
      public function ___GWizNBNotepadPage_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.creationCompleteHandler(param1);
      }
      
      [Bindable(event="propertyChange")]
      public function get textArea() : TextArea
      {
         return this._1004197030textArea;
      }
      
      public function set textArea(param1:TextArea) : void
      {
         var _loc2_:Object = this._1004197030textArea;
         if(_loc2_ !== param1)
         {
            this._1004197030textArea = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"textArea",_loc2_,param1));
            }
         }
      }
   }
}
