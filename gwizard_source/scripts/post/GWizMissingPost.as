package post
{
   import comps.GWizPopUp;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.Label;
   import spark.components.TextArea;
   
   public class GWizMissingPost extends GWizPopUp
   {
       
      
      private var _88844982outerDocument:GWizPostFileBrowser;
      
      private var _37092978requestMsg:TextArea;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizMissingPost()
      {
         super();
         mx_internal::_document = this;
         this.title = "Request Post...";
         this.width = 500;
         this.height = 200;
         this.mxmlContent = [this._GWizMissingPost_Label1_c(),this._GWizMissingPost_TextArea1_i()];
         this.addEventListener("creationComplete",this.___GWizMissingPost_GWizPopUp1_creationComplete);
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
      
      override public function onOk(param1:Event) : void
      {
         super.close();
      }
      
      private function setMsg() : void
      {
         this.requestMsg.text = "Many controls are compatible with the existing posts even if they are made by a different manufacturer.  ";
         this.requestMsg.text += "The trick is to find the closest post for your machine and work from there.  You can access information on ";
         this.requestMsg.text += "configuring custom posts via this page:\n\n";
         this.requestMsg.text += "http://www.cnccookbook.com/GWECustomPosts.html\n\n";
         this.requestMsg.text += "There is a survey on that page that will let you indicate what post you are missing as well.  Periodically we review ";
         this.requestMsg.text += "The most popular posts we\'re missing and use that to guide new post development, so be sure to get yours listed if it isn\'t ";
         this.requestMsg.text += "already!\n";
      }
      
      private function _GWizMissingPost_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Request a Post";
         _loc1_.setStyle("fontSize",12);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMissingPost_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.text = "Request Msg";
         _loc1_.editable = false;
         _loc1_.id = "requestMsg";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.requestMsg = _loc1_;
         BindingManager.executeBindings(this,"requestMsg",this.requestMsg);
         return _loc1_;
      }
      
      public function ___GWizMissingPost_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.setMsg();
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizPostFileBrowser
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizPostFileBrowser) : void
      {
         var _loc2_:Object = this._88844982outerDocument;
         if(_loc2_ !== param1)
         {
            this._88844982outerDocument = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"outerDocument",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get requestMsg() : TextArea
      {
         return this._37092978requestMsg;
      }
      
      public function set requestMsg(param1:TextArea) : void
      {
         var _loc2_:Object = this._37092978requestMsg;
         if(_loc2_ !== param1)
         {
            this._37092978requestMsg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"requestMsg",_loc2_,param1));
            }
         }
      }
   }
}
