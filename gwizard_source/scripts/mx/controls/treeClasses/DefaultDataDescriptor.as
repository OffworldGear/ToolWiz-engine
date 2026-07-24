package mx.controls.treeClasses
{
   import flash.utils.Dictionary;
   import mx.collections.ArrayCollection;
   import mx.collections.CursorBookmark;
   import mx.collections.ICollectionView;
   import mx.collections.IList;
   import mx.collections.IViewCursor;
   import mx.collections.XMLListCollection;
   import mx.controls.menuClasses.IMenuDataDescriptor;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class DefaultDataDescriptor implements ITreeDataDescriptor2, IMenuDataDescriptor
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var ChildCollectionCache:Dictionary;
      
      public function DefaultDataDescriptor()
      {
         this.ChildCollectionCache = new Dictionary(true);
         super();
      }
      
      public function getChildren(param1:Object, param2:Object = null) : ICollectionView
      {
         var _loc3_:* = undefined;
         var _loc4_:ICollectionView = null;
         var _loc5_:ArrayCollection = null;
         var _loc6_:XMLListCollection = null;
         var _loc7_:* = undefined;
         var _loc8_:Array = null;
         if(param1 == null)
         {
            return null;
         }
         if(param1 is XML)
         {
            _loc3_ = param1.*;
         }
         else if(param1 is Object)
         {
            try
            {
               _loc3_ = param1.children;
            }
            catch(e:Error)
            {
            }
         }
         if(_loc3_ == undefined && !(_loc3_ is XMLList))
         {
            return null;
         }
         if(_loc3_ is ICollectionView)
         {
            _loc4_ = ICollectionView(_loc3_);
         }
         else if(_loc3_ is Array)
         {
            if(!(_loc5_ = this.ChildCollectionCache[param1]))
            {
               _loc4_ = new ArrayCollection(_loc3_);
               this.ChildCollectionCache[param1] = _loc4_;
            }
            else
            {
               _loc4_ = _loc5_;
               ArrayCollection(_loc4_).dispatchResetEvent = false;
               ArrayCollection(_loc4_).source = _loc3_;
            }
         }
         else if(_loc3_ is XMLList)
         {
            if(!(_loc6_ = this.ChildCollectionCache[param1]))
            {
               for(_loc7_ in this.ChildCollectionCache)
               {
                  if(_loc7_ === param1)
                  {
                     _loc6_ = this.ChildCollectionCache[_loc7_];
                     break;
                  }
               }
            }
            if(!_loc6_)
            {
               _loc4_ = new XMLListCollection(_loc3_);
               this.ChildCollectionCache[param1] = _loc4_;
            }
            else
            {
               _loc4_ = _loc6_;
               XMLListCollection(_loc4_).dispatchResetEvent = false;
               XMLListCollection(_loc4_).source = _loc3_;
            }
         }
         else if((_loc8_ = new Array(_loc3_)) != null)
         {
            _loc4_ = new ArrayCollection(_loc8_);
         }
         return _loc4_;
      }
      
      public function hasChildren(param1:Object, param2:Object = null) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         var _loc3_:ICollectionView = this.getChildren(param1,param2);
         try
         {
            if(_loc3_.length > 0)
            {
               return true;
            }
         }
         catch(e:Error)
         {
         }
         return false;
      }
      
      public function isBranch(param1:Object, param2:Object = null) : Boolean
      {
         var _loc4_:XMLList = null;
         var _loc5_:XMLList = null;
         if(param1 == null)
         {
            return false;
         }
         var _loc3_:Boolean = false;
         if(param1 is XML)
         {
            _loc4_ = param1.children();
            if((_loc5_ = param1.@isBranch).length() == 1)
            {
               if(_loc5_[0] == "true")
               {
                  _loc3_ = true;
               }
            }
            else if(_loc4_.length() != 0)
            {
               _loc3_ = true;
            }
         }
         else if(param1 is Object)
         {
            try
            {
               if(param1.children != undefined)
               {
                  _loc3_ = true;
               }
            }
            catch(e:Error)
            {
            }
         }
         return _loc3_;
      }
      
      public function getData(param1:Object, param2:Object = null) : Object
      {
         return Object(param1);
      }
      
      public function addChildAt(param1:Object, param2:Object, param3:int, param4:Object = null) : Boolean
      {
         var _loc5_:IViewCursor = null;
         var _loc6_:ICollectionView = null;
         var _loc7_:XMLList = null;
         if(!param1)
         {
            try
            {
               if(param3 > param4.length)
               {
                  param3 = param4.length;
               }
               if(param4 is IList)
               {
                  IList(param4).addItemAt(param2,param3);
               }
               else
               {
                  (_loc5_ = param4.createCursor()).seek(CursorBookmark.FIRST,param3);
                  _loc5_.insert(param2);
               }
               return true;
            }
            catch(e:Error)
            {
            }
         }
         else
         {
            if(!(_loc6_ = ICollectionView(this.getChildren(param1,param4))))
            {
               if(param1 is XML)
               {
                  _loc7_ = new XMLList();
                  XML(param1).appendChild(_loc7_);
                  _loc6_ = new XMLListCollection(param1.children());
               }
               else if(param1 is Object)
               {
                  param1.children = new ArrayCollection();
                  _loc6_ = param1.children;
               }
            }
            try
            {
               if(param3 > _loc6_.length)
               {
                  param3 = _loc6_.length;
               }
               if(_loc6_ is IList)
               {
                  IList(_loc6_).addItemAt(param2,param3);
               }
               else
               {
                  (_loc5_ = _loc6_.createCursor()).seek(CursorBookmark.FIRST,param3);
                  _loc5_.insert(param2);
               }
               return true;
            }
            catch(e:Error)
            {
            }
         }
         return false;
      }
      
      public function removeChildAt(param1:Object, param2:Object, param3:int, param4:Object = null) : Boolean
      {
         var _loc5_:IViewCursor = null;
         var _loc6_:ICollectionView = null;
         if(!param1)
         {
            try
            {
               if(param3 > param4.length)
               {
                  param3 = param4.length;
               }
               if(param4 is IList)
               {
                  param4.removeItemAt(param3);
               }
               else
               {
                  (_loc5_ = param4.createCursor()).seek(CursorBookmark.FIRST,param3);
                  _loc5_.remove();
               }
               return true;
            }
            catch(e:Error)
            {
            }
         }
         else
         {
            _loc6_ = ICollectionView(this.getChildren(param1,param4));
            try
            {
               if(param3 > _loc6_.length)
               {
                  param3 = _loc6_.length;
               }
               if(_loc6_ is IList)
               {
                  IList(_loc6_).removeItemAt(param3);
               }
               else
               {
                  (_loc5_ = _loc6_.createCursor()).seek(CursorBookmark.FIRST,param3);
                  _loc5_.remove();
               }
               return true;
            }
            catch(e:Error)
            {
            }
         }
         return false;
      }
      
      public function getType(param1:Object) : String
      {
         if(param1 is XML)
         {
            return String(param1.@type);
         }
         if(param1 is Object)
         {
            try
            {
               return String(param1.type);
            }
            catch(e:Error)
            {
            }
         }
         return "";
      }
      
      public function isEnabled(param1:Object) : Boolean
      {
         var _loc2_:* = undefined;
         if(param1 is XML)
         {
            _loc2_ = param1.@enabled;
            if(_loc2_[0] == false)
            {
               return false;
            }
         }
         else if(param1 is Object)
         {
            try
            {
               return "false" != String(param1.enabled);
            }
            catch(e:Error)
            {
            }
         }
         return true;
      }
      
      public function setEnabled(param1:Object, param2:Boolean) : void
      {
         if(param1 is XML)
         {
            param1.@enabled = param2;
         }
         else if(param1 is Object)
         {
            try
            {
               param1.enabled = param2;
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public function isToggled(param1:Object) : Boolean
      {
         var _loc2_:* = undefined;
         if(param1 is XML)
         {
            _loc2_ = param1.@toggled;
            if(_loc2_[0] == true)
            {
               return true;
            }
         }
         else if(param1 is Object)
         {
            try
            {
               return Boolean(param1.toggled);
            }
            catch(e:Error)
            {
            }
         }
         return false;
      }
      
      public function setToggled(param1:Object, param2:Boolean) : void
      {
         if(param1 is XML)
         {
            param1.@toggled = param2;
         }
         else if(param1 is Object)
         {
            try
            {
               param1.toggled = param2;
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public function getGroupName(param1:Object) : String
      {
         if(param1 is XML)
         {
            return param1.@groupName;
         }
         if(param1 is Object)
         {
            try
            {
               return param1.groupName;
            }
            catch(e:Error)
            {
            }
         }
         return "";
      }
      
      public function getHierarchicalCollectionAdaptor(param1:ICollectionView, param2:Function, param3:Object, param4:Object = null) : ICollectionView
      {
         return new HierarchicalCollectionView(param1,this,param2,param3);
      }
      
      public function getNodeDepth(param1:Object, param2:IViewCursor, param3:Object = null) : int
      {
         if(param1 == param2.current)
         {
            return HierarchicalViewCursor(param2).currentDepth;
         }
         return -1;
      }
      
      public function getParent(param1:Object, param2:ICollectionView, param3:Object = null) : Object
      {
         return HierarchicalCollectionView(param2).getParentItem(param1);
      }
   }
}
