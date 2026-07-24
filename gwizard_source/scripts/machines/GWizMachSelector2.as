package machines
{
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.HGroup;
   
   public class GWizMachSelector2 extends HGroup
   {
      
      private static const log:ILogger = Log.getLogger("GWizMachSelector2");
      
      private static const USE_CUSTOM_DROPDOWN:Boolean = true;
       
      
      private var _433014735dropDown:GWizMachSelector;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1008240571nativeWin:DisplayObject = null;
      
      public function GWizMachSelector2()
      {
         super();
         mx_internal::_document = this;
         this.percentWidth = 100;
         this.toolTip = "Select which machine you\'re running";
         this.mxmlContent = [this._GWizMachSelector2_GWizMachSelector1_i()];
         this.addEventListener("creationComplete",this.___GWizMachSelector2_HGroup1_creationComplete);
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
      
      public function selectedName() : String
      {
         if(this.dropDown.selectedIndex < 0)
         {
            this.dropDown.selectedIndex = 0;
         }
         return this.dropDown.selectedItem.name;
      }
      
      private function onCC() : void
      {
         if(USE_CUSTOM_DROPDOWN)
         {
            this.addEventListener(MouseEvent.MOUSE_DOWN,this.clickHandler,true);
         }
      }
      
      protected function clickHandler(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         param1.preventDefault();
         this.doMachBrowse(this.nativeWin);
      }
      
      public function doMachBrowse(param1:DisplayObject = null) : void
      {
         GWizMachBrowser.machBrowse(GWizMachSettings.MachinesList,GWizMachSettings.MyShopMachinesList,this.dropDown.selectedIndex,this.x,this.y,param1);
      }
      
      private function _GWizMachSelector2_GWizMachSelector1_i() : GWizMachSelector
      {
         var _loc1_:GWizMachSelector = new GWizMachSelector();
         _loc1_.percentWidth = 100;
         _loc1_.id = "dropDown";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.dropDown = _loc1_;
         BindingManager.executeBindings(this,"dropDown",this.dropDown);
         return _loc1_;
      }
      
      public function ___GWizMachSelector2_HGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      [Bindable(event="propertyChange")]
      public function get dropDown() : GWizMachSelector
      {
         return this._433014735dropDown;
      }
      
      public function set dropDown(param1:GWizMachSelector) : void
      {
         var _loc2_:Object = this._433014735dropDown;
         if(_loc2_ !== param1)
         {
            this._433014735dropDown = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"dropDown",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get nativeWin() : DisplayObject
      {
         return this._1008240571nativeWin;
      }
      
      public function set nativeWin(param1:DisplayObject) : void
      {
         var _loc2_:Object = this._1008240571nativeWin;
         if(_loc2_ !== param1)
         {
            this._1008240571nativeWin = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"nativeWin",_loc2_,param1));
            }
         }
      }
   }
}
