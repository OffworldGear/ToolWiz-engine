package spark.components
{
   import flash.events.Event;
   import mx.core.ContainerCreationPolicy;
   import mx.core.IDeferredContentOwner;
   import mx.core.INavigatorContent;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class NavigatorContent extends SkinnableContainer implements INavigatorContent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _icon:Class = null;
      
      private var _label:String = "";
      
      public function NavigatorContent()
      {
         super();
      }
      
      [Bindable("iconChanged")]
      public function get icon() : Class
      {
         return this._icon;
      }
      
      public function set icon(param1:Class) : void
      {
         this._icon = param1;
         dispatchEvent(new Event("iconChanged"));
      }
      
      [Bindable("labelChanged")]
      public function get label() : String
      {
         return this._label;
      }
      
      public function set label(param1:String) : void
      {
         this._label = param1;
         dispatchEvent(new Event("labelChanged"));
      }
      
      override protected function createChildren() : void
      {
         var _loc1_:String = null;
         if(creationPolicy == ContainerCreationPolicy.AUTO)
         {
            if(parent is IDeferredContentOwner)
            {
               _loc1_ = IDeferredContentOwner(parent).creationPolicy;
               creationPolicy = _loc1_ == ContainerCreationPolicy.ALL ? ContainerCreationPolicy.ALL : ContainerCreationPolicy.NONE;
            }
         }
         super.createChildren();
      }
   }
}
