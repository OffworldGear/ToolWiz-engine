package comps
{
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.events.MouseEvent;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizLogo extends UIComponent
   {
      
      private static const log:ILogger = Log.getLogger("GWizLogo");
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var config:XML = null;
      
      public var adjustX:int = 0;
      
      public var adjustY:int = 0;
      
      private var _splash:Boolean = false;
      
      private var _logo:String = "";
      
      public function GWizLogo()
      {
         super();
         this.addEventListener("click",this.___GWizLogo_UIComponent1_click);
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
      
      private function doClick() : void
      {
         log.debug("Click on GWizLogo");
      }
      
      private function buildConfig(param1:Boolean) : void
      {
         var _loc2_:* = "";
         var _loc3_:Array = GWizSettings.loginBar.appLongNameParm.split(" ");
         _loc2_ += "<config width=\"512\" height=\"300\" centered=\"true\">\n";
         _loc2_ += "\t<transition duration=\"2\" font=\"Arial\" size=\"100\" delay=\"1\">\n";
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc2_ += "<item>" + _loc3_[_loc4_] + "</item>\n";
            if(param1)
            {
               break;
            }
            _loc4_++;
         }
         _loc2_ += "\t</transition>\n";
         _loc2_ += "</config>\n";
         this.config = new XML(_loc2_);
      }
      
      public function playLogo(param1:Boolean = false) : void
      {
         this._splash = param1;
         this._logo = GWizAbstractPrefs.logoStr;
         if(param1)
         {
            this.playLogoAux();
         }
         else
         {
            this.callLater(this.playLogoAux);
         }
      }
      
      private function playLogoAux() : void
      {
      }
      
      public function stopLogo() : void
      {
      }
      
      public function adjustOffsets() : void
      {
      }
      
      public function ___GWizLogo_UIComponent1_click(param1:MouseEvent) : void
      {
         this.doClick();
      }
   }
}
