package mx.containers
{
   import flash.events.Event;
   import mx.core.FlexVersion;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.styles.CSSStyleDeclaration;
   import mx.styles.IStyleClient;
   
   use namespace mx_internal;
   
   public class ApplicationControlBar extends ControlBar
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var dockChanged:Boolean = false;
      
      private var _dock:Boolean = false;
      
      public function ApplicationControlBar()
      {
         super();
      }
      
      [Bindable("dockChanged")]
      public function get dock() : Boolean
      {
         return this._dock;
      }
      
      public function set dock(param1:Boolean) : void
      {
         if(this._dock != param1)
         {
            this._dock = param1;
            this.dockChanged = true;
            invalidateProperties();
            dispatchEvent(new Event("dockChanged"));
         }
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         var _loc2_:Object = mx_internal::blocker;
         super.enabled = param1;
         if(mx_internal::blocker && mx_internal::blocker != _loc2_)
         {
            if(mx_internal::blocker is IStyleClient)
            {
               IStyleClient(mx_internal::blocker).setStyle("borderStyle","applicationControlBar");
            }
         }
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         var _loc2_:CSSStyleDeclaration = null;
         super.moduleFactory = param1;
         if(FlexVersion.compatibilityVersion >= FlexVersion.VERSION_4_0)
         {
            _loc2_ = styleManager.getStyleDeclaration("mx.containers.ApplicationControlBar");
            if(_loc2_)
            {
               if(_loc2_.getStyle("borderStyle") === undefined)
               {
                  _loc2_.setStyle("borderStyle","applicationControlBar");
               }
               if(_loc2_.getStyle("docked") === undefined)
               {
                  _loc2_.setStyle("docked",false);
               }
               if(_loc2_.getStyle("dropShadowEnabled") === undefined)
               {
                  _loc2_.setStyle("dropShadowEnabled",true);
               }
               if(_loc2_.getStyle("shadowDistance") === undefined)
               {
                  _loc2_.setStyle("shadowDistance",5);
               }
            }
         }
      }
      
      override protected function commitProperties() : void
      {
         var _loc1_:Class = null;
         super.commitProperties();
         if(this.dockChanged)
         {
            this.dockChanged = false;
            _loc1_ = Class(systemManager.getDefinitionByName("mx.core::Application"));
            if(_loc1_ && parent is _loc1_)
            {
               _loc1_(parent).dockControlBar(this,this._dock);
            }
         }
      }
      
      public function resetDock(param1:Boolean) : void
      {
         this._dock = !param1;
         this.dock = param1;
      }
   }
}
