package mx.accessibility
{
   import flash.accessibility.Accessibility;
   import flash.events.Event;
   import mx.collections.CursorBookmark;
   import mx.collections.IViewCursor;
   import mx.controls.DataGrid;
   import mx.controls.listClasses.IListItemRenderer;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.events.DataGridEvent;
   
   use namespace mx_internal;
   
   public class DataGridAccImpl extends ListBaseAccImpl
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function DataGridAccImpl(param1:UIComponent)
      {
         super(param1);
      }
      
      public static function enableAccessibility() : void
      {
         DataGrid.createAccessibilityImplementation = mx_internal::createAccessibilityImplementation;
      }
      
      mx_internal static function createAccessibilityImplementation(param1:UIComponent) : void
      {
         param1.accessibilityImplementation = new DataGridAccImpl(param1);
      }
      
      override protected function get eventsToHandle() : Array
      {
         return super.eventsToHandle.concat([DataGridEvent.ITEM_FOCUS_IN]);
      }
      
      override public function get_accRole(param1:uint) : uint
      {
         return param1 == 0 ? uint(role) : uint(AccConst.ROLE_SYSTEM_LISTITEM);
      }
      
      override public function get_accState(param1:uint) : uint
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:IListItemRenderer = null;
         var _loc8_:Object = null;
         var _loc2_:DataGrid = DataGrid(master);
         var _loc3_:uint = getState(param1);
         if(param1 > 0)
         {
            _loc6_ = param1 - 1;
            if(!_loc2_.editable)
            {
               if((_loc4_ = _loc6_) < _loc2_.verticalScrollPosition || _loc4_ >= _loc2_.verticalScrollPosition + _loc2_.rowCount - (!!_loc2_.headerVisible ? 1 : 0))
               {
                  _loc3_ |= AccConst.STATE_SYSTEM_OFFSCREEN | AccConst.STATE_SYSTEM_INVISIBLE;
               }
               else
               {
                  _loc3_ |= AccConst.STATE_SYSTEM_SELECTABLE;
                  if((_loc7_ = _loc2_.itemToItemRenderer(this.getItemAt(_loc4_))) && _loc2_.isItemSelected(_loc7_.data))
                  {
                     _loc3_ |= AccConst.STATE_SYSTEM_SELECTED | AccConst.STATE_SYSTEM_FOCUSED;
                  }
               }
            }
            else
            {
               _loc4_ = Math.floor(_loc6_ / _loc2_.columns.length);
               _loc5_ = _loc6_ % _loc2_.columns.length;
               if(_loc4_ < _loc2_.verticalScrollPosition || _loc4_ >= _loc2_.verticalScrollPosition + _loc2_.rowCount - (!!_loc2_.headerVisible ? 1 : 0))
               {
                  _loc3_ |= AccConst.STATE_SYSTEM_OFFSCREEN | AccConst.STATE_SYSTEM_INVISIBLE;
               }
               else if(_loc2_.columns[_loc5_].editable)
               {
                  _loc3_ |= AccConst.STATE_SYSTEM_SELECTABLE;
                  if((_loc8_ = _loc2_.editedItemPosition) && _loc8_.rowIndex == _loc4_ && _loc8_.columnIndex == _loc5_)
                  {
                     _loc3_ |= AccConst.STATE_SYSTEM_SELECTED | AccConst.STATE_SYSTEM_FOCUSED;
                  }
               }
            }
         }
         return _loc3_;
      }
      
      override public function accDoDefaultAction(param1:uint) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:DataGrid = DataGrid(master);
         if(param1 > 0)
         {
            _loc3_ = param1 - 1;
            if(!_loc2_.editable)
            {
               _loc2_.selectedIndex = _loc3_;
            }
            else
            {
               _loc4_ = Math.floor(_loc3_ / _loc2_.columns.length);
               _loc5_ = _loc3_ % _loc2_.columns.length;
               _loc2_.editedItemPosition = {
                  "rowIndex":_loc4_,
                  "columnIndex":_loc5_
               };
            }
         }
      }
      
      override public function getChildIDArray() : Array
      {
         var _loc1_:int = 0;
         var _loc2_:DataGrid = DataGrid(master);
         if(_loc2_.dataProvider)
         {
            if(!_loc2_.editable)
            {
               _loc1_ = _loc2_.dataProvider.length;
            }
            else
            {
               _loc1_ = _loc2_.columns.length * _loc2_.dataProvider.length;
            }
         }
         return createChildIDArray(_loc1_);
      }
      
      override public function accLocation(param1:uint) : *
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:DataGrid = DataGrid(master);
         var _loc3_:int = param1 - 1;
         var _loc6_:int = !!_loc2_.headerVisible ? 1 : 0;
         if(!_loc2_.editable)
         {
            if((_loc4_ = _loc3_ + _loc6_) < _loc2_.verticalScrollPosition || _loc4_ >= _loc2_.verticalScrollPosition + _loc2_.rowCount)
            {
               return null;
            }
            return _loc2_.indicesToItemRenderer(_loc4_ - _loc2_.verticalScrollPosition,0);
         }
         _loc4_ = Math.floor(_loc3_ / _loc2_.columns.length) + _loc6_;
         _loc5_ = _loc3_ % _loc2_.columns.length;
         if(_loc4_ < _loc2_.verticalScrollPosition || _loc4_ >= _loc2_.verticalScrollPosition + _loc2_.rowCount)
         {
            return null;
         }
         return _loc2_.indicesToItemRenderer(_loc4_ - _loc2_.verticalScrollPosition,_loc5_);
      }
      
      override public function get_accFocus() : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc1_:DataGrid = DataGrid(master);
         if(!_loc1_.editable)
         {
            _loc2_ = _loc1_.selectedIndex;
            return _loc2_ >= 0 ? uint(_loc2_ + 1) : uint(0);
         }
         _loc3_ = _loc1_.editedItemPosition;
         if(!_loc3_)
         {
            return 0;
         }
         _loc4_ = _loc3_.rowIndex;
         _loc5_ = _loc3_.columnIndex;
         return _loc1_.columns.length * _loc4_ + _loc5_ + 1;
      }
      
      override protected function getName(param1:uint) : String
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         var _loc12_:String = null;
         if(param1 == 0)
         {
            return "";
         }
         var _loc2_:DataGrid = DataGrid(master);
         if(param1 > 0)
         {
            _loc4_ = param1 - 1;
            if(!_loc2_.editable)
            {
               _loc5_ = _loc4_;
               if((_loc6_ = this.getItemAt(_loc4_)) is String)
               {
                  _loc3_ = "Row " + (_loc5_ + 1) + " of " + _loc2_.dataProvider.length + " " + _loc6_;
               }
               else
               {
                  _loc3_ = "Row " + (_loc5_ + 1) + " of " + _loc2_.dataProvider.length;
                  _loc8_ = (_loc7_ = _loc2_.columns).length;
                  _loc9_ = 0;
                  while(_loc9_ < _loc8_)
                  {
                     _loc3_ += " " + _loc7_[_loc9_].headerText + " " + _loc7_[_loc9_].itemToLabel(_loc6_);
                     _loc9_++;
                  }
               }
            }
            else
            {
               _loc5_ = Math.floor(_loc4_ / _loc2_.columns.length);
               _loc10_ = _loc4_ % _loc2_.columns.length;
               if((_loc6_ = this.getItemAt(_loc5_)) is String)
               {
                  _loc3_ = "Row " + (_loc5_ + 1) + " of " + _loc2_.dataProvider.length + " " + _loc6_;
               }
               else
               {
                  _loc11_ = (_loc7_ = _loc2_.columns)[_loc9_].itemToLabel(_loc6_);
                  _loc12_ = _loc7_[_loc10_].headerText;
                  _loc3_ = "Row " + (_loc5_ + 1) + " of " + _loc2_.dataProvider.length;
                  _loc8_ = _loc7_.length;
                  _loc9_ = 0;
                  while(_loc9_ < _loc7_.length)
                  {
                     _loc3_ += " " + _loc7_[_loc9_].headerText + " " + _loc7_[_loc9_].itemToLabel(_loc6_);
                     _loc9_++;
                  }
                  _loc3_ += ", Editing " + _loc12_ + " " + _loc11_;
               }
            }
         }
         return _loc3_;
      }
      
      override protected function eventHandler(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc4_:uint = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         $eventHandler(param1);
         var _loc2_:DataGrid = DataGrid(master);
         switch(param1.type)
         {
            case "change":
               if(!_loc2_.editable)
               {
                  _loc3_ = _loc2_.selectedIndex;
                  if(_loc3_ >= 0)
                  {
                     _loc4_ = _loc3_ + 1;
                     Accessibility.sendEvent(_loc2_,_loc4_,AccConst.EVENT_OBJECT_FOCUS);
                     Accessibility.sendEvent(_loc2_,_loc4_,AccConst.EVENT_OBJECT_SELECTION);
                  }
               }
               break;
            case DataGridEvent.ITEM_FOCUS_IN:
               if(_loc2_.editable)
               {
                  _loc5_ = DataGridEvent(param1).rowIndex;
                  _loc6_ = DataGridEvent(param1).columnIndex;
                  Accessibility.sendEvent(_loc2_,_loc2_.columns.length * _loc5_ + _loc6_ + 1,AccConst.EVENT_OBJECT_FOCUS);
                  Accessibility.sendEvent(_loc2_,_loc2_.columns.length * _loc5_ + _loc6_ + 1,AccConst.EVENT_OBJECT_SELECTION);
               }
         }
      }
      
      private function getItemAt(param1:int) : Object
      {
         var _loc2_:IViewCursor = DataGrid(master).collectionIterator;
         _loc2_.seek(CursorBookmark.FIRST,param1);
         return _loc2_.current;
      }
   }
}
