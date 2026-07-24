package tools
{
   import comps.GWizNumStep;
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizToolMenuPopup extends GWizPopUp
   {
      
      private static const log:ILogger = Log.getLogger("GWizToolMenuPopup");
      
      public static var isActive:Boolean = false;
      
      private static var menuHandler:Function = null;
      
      private static var changeMenuXML:Function = null;
       
      
      private var _1236641812gtMenu:GWizGraphicToolMenu;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var cc:Boolean = false;
      
      private var initTD:GWizToolDef = null;
      
      private const TOOL_MENU_PREFIX:String = "Tool Menu: ";
      
      public function GWizToolMenuPopup()
      {
         super();
         mx_internal::_document = this;
         this.title = "Tool Menu...";
         this.cancelLabel = "";
         this.fullScreen = true;
         this.maxWidth = 1024;
         this.maxHeight = 700;
         this.mxmlContent = [this._GWizToolMenuPopup_GWizGraphicToolMenu1_i()];
         this.addEventListener("creationComplete",this.___GWizToolMenuPopup_GWizPopUp1_creationComplete);
      }
      
      public static function toolMenuPopUp(param1:DisplayObject, param2:Function, param3:Function, param4:Function) : GWizToolMenuPopup
      {
         if(GWizSettings.FeedsSpeedsApp)
         {
            log.debug("cribTbl.selectedIndex = " + GWizSettings.FeedsSpeedsApp.cribTbl.selectedIndex + ", tabname = " + GWizSettings.FeedsSpeedsApp.cribTbl.selectedItem.tabname);
         }
         param2 = param2;
         param3 = param3;
         var _loc5_:GWizToolMenuPopup;
         (_loc5_ = GWizToolMenuPopup(GWizPopUpManager.createPopUp(param1,GWizToolMenuPopup,true))).gtMenu.setFunctions = param4;
         return _loc5_;
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
      
      override public function close() : void
      {
         this.gtMenu.close();
         if(GWizSettings.FeedsSpeedsApp && GWizSettings.FeedsSpeedsApp.Tool)
         {
            GWizSettings.FeedsSpeedsApp.Tool.selectedLabel = title;
         }
         GWizNumStep.keystrokeRecalc = false;
         super.close();
         isActive = false;
      }
      
      public function setToolParms(param1:GWizToolDef, param2:XMLList, param3:int, param4:int) : void
      {
         this.gtMenu.setToolParms(param1,param2,param3,param4,this.resetTitle);
      }
      
      private function onCC() : void
      {
         this.cc = true;
         isActive = true;
         GWizNumStep.keystrokeRecalc = true;
         if(GWizSettings.FeedsSpeedsApp)
         {
            log.debug("cribTbl.selectedIndex = " + GWizSettings.FeedsSpeedsApp.cribTbl.selectedIndex + ", tabname = " + GWizSettings.FeedsSpeedsApp.cribTbl.selectedItem.tabname);
         }
      }
      
      private function resetTitle(param1:String) : void
      {
         this.title = this.TOOL_MENU_PREFIX + param1;
      }
      
      private function _GWizToolMenuPopup_GWizGraphicToolMenu1_i() : GWizGraphicToolMenu
      {
         var _loc1_:GWizGraphicToolMenu = new GWizGraphicToolMenu();
         _loc1_.id = "gtMenu";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gtMenu = _loc1_;
         BindingManager.executeBindings(this,"gtMenu",this.gtMenu);
         return _loc1_;
      }
      
      public function ___GWizToolMenuPopup_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      [Bindable(event="propertyChange")]
      public function get gtMenu() : GWizGraphicToolMenu
      {
         return this._1236641812gtMenu;
      }
      
      public function set gtMenu(param1:GWizGraphicToolMenu) : void
      {
         var _loc2_:Object = this._1236641812gtMenu;
         if(_loc2_ !== param1)
         {
            this._1236641812gtMenu = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gtMenu",_loc2_,param1));
            }
         }
      }
   }
}
