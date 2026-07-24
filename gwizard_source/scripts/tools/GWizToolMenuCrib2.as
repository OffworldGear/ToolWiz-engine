package tools
{
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import utils.GWizDebugUtils;
   
   public class GWizToolMenuCrib2 extends GWizPopUp
   {
       
      
      private var _1350939175theCrib:GWizToolCrib;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1934722163cribName:String;
      
      private var setMenuPickFcn:Function;
      
      public function GWizToolMenuCrib2()
      {
         super();
         mx_internal::_document = this;
         this.fullScreen = true;
         this.title = "Select Tool from Crib...";
         this.mxmlContent = [this._GWizToolMenuCrib2_GWizToolCrib1_i()];
      }
      
      public static function cribMenuPopUp(param1:DisplayObject, param2:String, param3:Function) : void
      {
         var _loc4_:GWizToolMenuCrib2;
         (_loc4_ = GWizToolMenuCrib2(GWizPopUpManager.createPopUp(param1,GWizToolMenuCrib2,true))).theCrib.chooseCrib(param2);
         _loc4_.setMenuPickFcn = param3;
         _loc4_.theCrib.doubleClickFcn = _loc4_.onOk;
         GWizDebugUtils.timeIt("cribMenuPopUp finishes:");
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
         var _loc2_:int = 0;
         this.theCrib.closePopUp();
         super.close();
         if(this.setMenuPickFcn != null)
         {
            _loc2_ = Math.max(this.theCrib.toolList.selectedIndex,0);
            this.setMenuPickFcn(this.theCrib.toolList.selectedItem.description,_loc2_,this.theCrib.toolList.selectedItem.guid);
         }
      }
      
      override public function close() : void
      {
         this.theCrib.closePopUp();
         super.close();
         if(this.setMenuPickFcn != null)
         {
            this.setMenuPickFcn("",-1);
         }
      }
      
      private function _GWizToolMenuCrib2_GWizToolCrib1_i() : GWizToolCrib
      {
         var _loc1_:GWizToolCrib = new GWizToolCrib();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.isTabbed = false;
         _loc1_.id = "theCrib";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theCrib = _loc1_;
         BindingManager.executeBindings(this,"theCrib",this.theCrib);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get theCrib() : GWizToolCrib
      {
         return this._1350939175theCrib;
      }
      
      public function set theCrib(param1:GWizToolCrib) : void
      {
         var _loc2_:Object = this._1350939175theCrib;
         if(_loc2_ !== param1)
         {
            this._1350939175theCrib = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theCrib",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get cribName() : String
      {
         return this._1934722163cribName;
      }
      
      private function set cribName(param1:String) : void
      {
         var _loc2_:Object = this._1934722163cribName;
         if(_loc2_ !== param1)
         {
            this._1934722163cribName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cribName",_loc2_,param1));
            }
         }
      }
   }
}
