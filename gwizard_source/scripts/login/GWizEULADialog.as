package login
{
   import comps.GWizPopUp;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flashx.textLayout.conversion.TextConverter;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.TextArea;
   
   public class GWizEULADialog extends GWizPopUp
   {
      
      private static const log:ILogger = Log.getLogger("GWizEULADialog");
      
      private static var thisWindow:GWizEULADialog = null;
      
      public static var eulaAccepted:Function = null;
       
      
      private var _1399083509eulaTxt:TextArea;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizEULADialog()
      {
         super();
         mx_internal::_document = this;
         this.okLabel = "Accept";
         this.cancelLabel = "Reject";
         this.width = 516;
         this.height = 430;
         this.horizontalAlign = "center";
         this.verticalAlign = "middle";
         this.mxmlContent = [this._GWizEULADialog_TextArea1_i()];
         this.addEventListener("creationComplete",this.___GWizEULADialog_GWizPopUp1_creationComplete);
      }
      
      private static function completeHandler(param1:Event) : void
      {
         if(!thisWindow)
         {
            return;
         }
         var _loc2_:URLLoader = URLLoader(param1.target);
         thisWindow.eulaTxt.textFlow = TextConverter.importToFlow(_loc2_.data,TextConverter.TEXT_FIELD_HTML_FORMAT);
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
         log.debug("Accepted EULA");
         thisWindow = null;
         super.close();
         if(eulaAccepted != null)
         {
            eulaAccepted(true);
         }
      }
      
      override public function onCancel(param1:Event) : void
      {
         log.debug("Rejected EULA");
         thisWindow = null;
         super.close();
         if(eulaAccepted != null)
         {
            eulaAccepted(false);
         }
      }
      
      private function loadEULA() : void
      {
         thisWindow = this;
         var request:URLRequest = new URLRequest("http://www.cnccookbook.com/GWizard/EULA.htm");
         var loader:URLLoader = new URLLoader();
         loader.dataFormat = URLLoaderDataFormat.TEXT;
         loader.addEventListener(Event.COMPLETE,completeHandler);
         try
         {
            loader.load(request);
         }
         catch(error:Error)
         {
            log.debug("Unable to load URL: " + error);
         }
      }
      
      private function _GWizEULADialog_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.editable = false;
         _loc1_.setStyle("verticalScrollPolicy","on");
         _loc1_.id = "eulaTxt";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.eulaTxt = _loc1_;
         BindingManager.executeBindings(this,"eulaTxt",this.eulaTxt);
         return _loc1_;
      }
      
      public function ___GWizEULADialog_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.loadEULA();
      }
      
      [Bindable(event="propertyChange")]
      public function get eulaTxt() : TextArea
      {
         return this._1399083509eulaTxt;
      }
      
      public function set eulaTxt(param1:TextArea) : void
      {
         var _loc2_:Object = this._1399083509eulaTxt;
         if(_loc2_ !== param1)
         {
            this._1399083509eulaTxt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"eulaTxt",_loc2_,param1));
            }
         }
      }
   }
}
