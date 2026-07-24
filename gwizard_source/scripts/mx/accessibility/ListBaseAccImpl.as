package mx.accessibility
{
   import flash.accessibility.Accessibility;
   import flash.events.Event;
   import mx.collections.CursorBookmark;
   import mx.collections.IViewCursor;
   import mx.controls.listClasses.IListItemRenderer;
   import mx.controls.listClasses.ListBase;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class ListBaseAccImpl extends AccImpl
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function ListBaseAccImpl(param1:UIComponent)
      {
         super(param1);
         role = AccConst.ROLE_SYSTEM_LIST;
      }
      
      public static function enableAccessibility() : void
      {
         ListBase.createAccessibilityImplementation = mx_internal::createAccessibilityImplementation;
      }
      
      mx_internal static function createAccessibilityImplementation(param1:UIComponent) : void
      {
         param1.accessibilityImplementation = new ListBaseAccImpl(param1);
      }
      
      override protected function get eventsToHandle() : Array
      {
         return super.eventsToHandle.concat(["change"]);
      }
      
      override public function get_accRole(param1:uint) : uint
      {
         return param1 == 0 ? uint(role) : uint(AccConst.ROLE_SYSTEM_LISTITEM);
      }
      
      override public function get_accState(param1:uint) : uint
      {
         var _loc3_:ListBase = null;
         var _loc4_:uint = 0;
         var _loc5_:Object = null;
         var _loc6_:IListItemRenderer = null;
         var _loc2_:uint = getState(param1);
         if(param1 > 0)
         {
            _loc3_ = ListBase(master);
            if((_loc4_ = param1 - 1) < _loc3_.verticalScrollPosition || _loc4_ >= _loc3_.verticalScrollPosition + _loc3_.rowCount)
            {
               _loc2_ |= AccConst.STATE_SYSTEM_OFFSCREEN | AccConst.STATE_SYSTEM_INVISIBLE;
            }
            else
            {
               _loc2_ |= AccConst.STATE_SYSTEM_SELECTABLE;
               _loc5_ = this.getItemAt(_loc4_);
               if((_loc6_ = _loc3_.itemToItemRenderer(_loc5_)) != null && _loc3_.isItemSelected(_loc6_.data))
               {
                  _loc2_ |= AccConst.STATE_SYSTEM_SELECTED | AccConst.STATE_SYSTEM_FOCUSED;
               }
            }
         }
         return _loc2_;
      }
      
      override public function get_accDefaultAction(param1:uint) : String
      {
         if(param1 == 0)
         {
            return null;
         }
         return "Double Click";
      }
      
      override public function accDoDefaultAction(param1:uint) : void
      {
         if(param1 > 0)
         {
            ListBase(master).selectedIndex = param1 - 1;
         }
      }
      
      override public function getChildIDArray() : Array
      {
         var _loc1_:int = !!ListBase(master).dataProvider ? int(ListBase(master).dataProvider.length) : 0;
         return createChildIDArray(_loc1_);
      }
      
      override public function accLocation(param1:uint) : *
      {
         var _loc2_:ListBase = ListBase(master);
         var _loc3_:uint = param1 - 1;
         if(_loc3_ < _loc2_.verticalScrollPosition || _loc3_ >= _loc2_.verticalScrollPosition + _loc2_.rowCount)
         {
            return null;
         }
         var _loc4_:Object = this.getItemAt(_loc3_);
         return _loc2_.itemToItemRenderer(_loc4_);
      }
      
      override public function get_accSelection() : Array
      {
         var _loc1_:Array = [];
         var _loc2_:Array = ListBase(master).selectedIndices;
         var _loc3_:int = _loc2_.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc1_[_loc4_] = _loc2_[_loc4_] + 1;
            _loc4_++;
         }
         return _loc1_;
      }
      
      override public function get_accFocus() : uint
      {
         var _loc1_:uint = ListBase(master).selectedIndex;
         return _loc1_ >= 0 ? uint(_loc1_ + 1) : uint(0);
      }
      
      override public function accSelect(param1:uint, param2:uint) : void
      {
         var _loc3_:ListBase = ListBase(master);
         var _loc4_:uint;
         if((_loc4_ = param2 - 1) >= 0 && _loc4_ < _loc3_.dataProvider.length)
         {
            _loc3_.selectedIndex = _loc4_;
         }
      }
      
      override protected function getName(param1:uint) : String
      {
         if(param1 == 0)
         {
            return "";
         }
         var _loc2_:ListBase = ListBase(master);
         var _loc3_:Object = this.getItemAt(param1 - 1);
         return _loc2_.itemToLabel(_loc3_);
      }
      
      override protected function eventHandler(param1:Event) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         $eventHandler(param1);
         switch(param1.type)
         {
            case "change":
               _loc2_ = ListBase(master).selectedIndex;
               if(_loc2_ >= 0)
               {
                  _loc3_ = _loc2_ + 1;
                  Accessibility.sendEvent(master,_loc3_,AccConst.EVENT_OBJECT_FOCUS);
                  Accessibility.sendEvent(master,_loc3_,AccConst.EVENT_OBJECT_SELECTION);
               }
         }
      }
      
      private function getItemAt(param1:int) : Object
      {
         var _loc2_:IViewCursor = ListBase(master).collectionIterator;
         _loc2_.seek(CursorBookmark.FIRST,param1);
         return _loc2_.current;
      }
   }
}
