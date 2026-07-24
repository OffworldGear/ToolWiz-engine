package mx.collections
{
   import flash.events.Event;
   import flash.utils.Dictionary;
   import mx.collections.errors.CollectionViewError;
   import mx.core.mx_internal;
   import mx.events.CollectionEvent;
   import mx.events.CollectionEventKind;
   import mx.events.PropertyChangeEvent;
   import mx.resources.IResourceManager;
   import mx.resources.ResourceManager;
   
   use namespace mx_internal;
   
   public class ModifiedCollectionView implements ICollectionView
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      public static const REMOVED:String = "removed";
      
      public static const ADDED:String = "added";
      
      public static const REPLACED:String = "replaced";
      
      public static const REPLACEMENT:String = "replacement";
       
      
      private var resourceManager:IResourceManager;
      
      private var list:ICollectionView;
      
      private var deltaLength:int = 0;
      
      private var deltas:Array;
      
      private var removedItems:Dictionary;
      
      private var addedItems:Dictionary;
      
      private var replacedItems:Dictionary;
      
      private var replacementItems:Dictionary;
      
      private var itemWrappersByIndex:Array;
      
      private var itemWrappersByCollectionMod:Dictionary;
      
      private var _showPreserved:Boolean = false;
      
      public function ModifiedCollectionView(param1:ICollectionView)
      {
         this.resourceManager = ResourceManager.getInstance();
         this.deltas = [];
         this.removedItems = new Dictionary(true);
         this.addedItems = new Dictionary(true);
         this.replacedItems = new Dictionary(true);
         this.replacementItems = new Dictionary(true);
         this.itemWrappersByIndex = [];
         this.itemWrappersByCollectionMod = new Dictionary(true);
         super();
         this.list = param1;
      }
      
      public function get length() : int
      {
         return this.list.length + (!!this._showPreserved ? this.deltaLength : 0);
      }
      
      public function get filterFunction() : Function
      {
         return null;
      }
      
      public function set filterFunction(param1:Function) : void
      {
      }
      
      public function disableAutoUpdate() : void
      {
      }
      
      public function createCursor() : IViewCursor
      {
         var _loc1_:IViewCursor = this.list.createCursor();
         var _loc2_:Object = _loc1_.current;
         return new ModifiedCollectionViewCursor(this,_loc1_,_loc2_);
      }
      
      public function contains(param1:Object) : Boolean
      {
         return false;
      }
      
      public function get sort() : ISort
      {
         return null;
      }
      
      public function set sort(param1:ISort) : void
      {
      }
      
      public function itemUpdated(param1:Object, param2:Object = null, param3:Object = null, param4:Object = null) : void
      {
      }
      
      public function refresh() : Boolean
      {
         return false;
      }
      
      public function enableAutoUpdate() : void
      {
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return false;
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return false;
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0.0, param5:Boolean = false) : void
      {
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return false;
      }
      
      mx_internal function getBookmark(param1:ModifiedCollectionViewCursor) : ModifiedCollectionViewBookmark
      {
         var _loc4_:String = null;
         var _loc2_:int = param1.currentIndex;
         if(_loc2_ < 0 || _loc2_ > this.length)
         {
            _loc4_ = this.resourceManager.getString("collections","invalidIndex",[_loc2_]);
            throw new CollectionViewError(_loc4_);
         }
         var _loc3_:Object = param1.current;
         return new ModifiedCollectionViewBookmark(_loc3_,this,0,_loc2_,param1.internalCursor.bookmark,param1.internalIndex);
      }
      
      mx_internal function getBookmarkIndex(param1:CursorBookmark) : int
      {
         var _loc3_:String = null;
         if(!(param1 is ModifiedCollectionViewBookmark) || ModifiedCollectionViewBookmark(param1).view != this)
         {
            _loc3_ = this.resourceManager.getString("collections","bookmarkNotFound");
            throw new CollectionViewError(_loc3_);
         }
         var _loc2_:ModifiedCollectionViewBookmark = ModifiedCollectionViewBookmark(param1);
         return _loc2_.index;
      }
      
      mx_internal function getWrappedItemUsingCursor(param1:ModifiedCollectionViewCursor, param2:int) : Object
      {
         var _loc6_:CollectionModification = null;
         var _loc9_:Object = null;
         var _loc3_:int = param2;
         var _loc4_:Object = null;
         var _loc5_:CollectionModification = null;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         while(_loc8_ < this.deltas.length)
         {
            _loc6_ = this.deltas[_loc8_];
            if(_loc3_ < _loc6_.index)
            {
               break;
            }
            if(_loc6_.modificationType == CollectionModification.REPLACE)
            {
               if(_loc3_ == _loc6_.index && _loc6_.showOldReplace && this._showPreserved)
               {
                  _loc5_ = _loc6_;
                  break;
               }
               if(_loc3_ == _loc6_.index + 1 && _loc6_.showOldReplace && _loc6_.showNewReplace && this._showPreserved)
               {
                  _loc3_--;
                  _loc7_ = true;
                  break;
               }
               if(_loc3_ == _loc6_.index && (!_loc6_.showOldReplace && _loc6_.showNewReplace || !this._showPreserved))
               {
                  _loc7_ = true;
                  break;
               }
               _loc3_ -= _loc6_.modCount;
            }
            else if(this.isActive(_loc6_))
            {
               if(_loc3_ == _loc6_.index && _loc6_.isRemove)
               {
                  _loc5_ = _loc6_;
                  break;
               }
               if(_loc3_ >= _loc6_.index)
               {
                  _loc3_ -= _loc6_.modCount;
               }
            }
            _loc8_++;
         }
         if(_loc5_)
         {
            _loc4_ = _loc5_.item;
         }
         else
         {
            param1.internalCursor.seek(CursorBookmark.CURRENT,_loc3_ - param1.internalIndex);
            _loc4_ = param1.internalCursor.current;
            param1.internalIndex = _loc3_;
         }
         if(_loc6_ && _loc3_ == _loc6_.index && _loc6_.modificationType == CollectionModification.ADD)
         {
            _loc9_ = this.getUniqueItemWrapper(_loc4_,_loc6_,_loc3_);
         }
         else
         {
            _loc9_ = this.getUniqueItemWrapper(_loc4_,_loc5_,_loc3_);
         }
         return _loc9_;
      }
      
      public function get showPreservedState() : Boolean
      {
         return this._showPreserved;
      }
      
      public function set showPreservedState(param1:Boolean) : void
      {
         this._showPreserved = param1;
      }
      
      public function getSemantics(param1:ItemWrapper) : String
      {
         if(this.removedItems[param1])
         {
            return ModifiedCollectionView.REMOVED;
         }
         if(this.addedItems[param1])
         {
            return ModifiedCollectionView.ADDED;
         }
         if(this.replacedItems[param1])
         {
            return ModifiedCollectionView.REPLACED;
         }
         if(this.replacementItems[param1])
         {
            return ModifiedCollectionView.REPLACEMENT;
         }
         return null;
      }
      
      public function processCollectionEvent(param1:CollectionEvent, param2:int, param3:int) : void
      {
         switch(param1.kind)
         {
            case CollectionEventKind.ADD:
               this.integrateAddedElements(param1,param2,param3);
               break;
            case CollectionEventKind.REMOVE:
               this.integrateRemovedElements(param1,param2,param3);
               break;
            case CollectionEventKind.REPLACE:
               this.integrateReplacedElements(param1,param2,param3);
         }
      }
      
      public function removeItem(param1:ItemWrapper) : void
      {
         var _loc2_:CollectionModification = this.removedItems[param1] as CollectionModification;
         if(!_loc2_)
         {
            _loc2_ = this.replacedItems[param1] as CollectionModification;
            if(_loc2_)
            {
               delete this.replacedItems[param1];
               _loc2_.stopShowingReplacedValue();
               --this.deltaLength;
               if(_loc2_.modCount == 0)
               {
                  this.removeModification(_loc2_);
               }
            }
         }
         else if(this.removeModification(_loc2_))
         {
            delete this.removedItems[param1];
            --this.deltaLength;
         }
      }
      
      public function addItem(param1:ItemWrapper) : void
      {
         var _loc2_:CollectionModification = this.addedItems[param1] as CollectionModification;
         if(!_loc2_)
         {
            _loc2_ = this.replacementItems[param1] as CollectionModification;
            if(_loc2_)
            {
               _loc2_.startShowingReplacementValue();
               ++this.deltaLength;
               if(_loc2_.modCount == 0)
               {
                  this.removeModification(_loc2_);
               }
            }
         }
         else if(this.removeModification(_loc2_))
         {
            ++this.deltaLength;
         }
      }
      
      private function isActive(param1:CollectionModification) : Boolean
      {
         return this._showPreserved;
      }
      
      private function removeModification(param1:CollectionModification) : Boolean
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.deltas.length)
         {
            if(this.deltas[_loc2_] == param1)
            {
               this.deltas.splice(_loc2_,1);
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      private function integrateRemovedElements(param1:CollectionEvent, param2:int, param3:int) : void
      {
         var _loc9_:CollectionModification = null;
         var _loc10_:CollectionModification = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = param1.items.length;
         var _loc8_:int = 0;
         while(_loc4_ < this.deltas.length && _loc5_ < _loc7_)
         {
            _loc9_ = CollectionModification(this.deltas[_loc4_]);
            _loc10_ = new CollectionModification(param1.location,param1.items[_loc5_],CollectionModification.REMOVE);
            this.removedItems[this.getUniqueItemWrapper(param1.items[_loc5_],_loc10_,0)] = _loc10_;
            if(_loc8_ != 0)
            {
               _loc9_.index += _loc8_;
            }
            if(_loc9_.isRemove && _loc9_.index <= _loc10_.index || !_loc9_.isRemove && _loc9_.index < _loc10_.index)
            {
               _loc4_++;
            }
            else
            {
               if(!_loc9_.isRemove && _loc9_.index == _loc10_.index)
               {
                  this.deltas.splice(_loc4_ + _loc5_,1);
               }
               else
               {
                  this.deltas.splice(_loc4_ + _loc5_,0,_loc10_);
                  _loc4_++;
               }
               _loc8_--;
               _loc5_++;
            }
         }
         while(_loc4_ < this.deltas.length)
         {
            _loc9_ = CollectionModification(this.deltas[_loc4_++]);
            _loc9_.index += _loc8_;
         }
         while(_loc5_ < _loc7_)
         {
            this.deltas.push(_loc10_ = new CollectionModification(param1.location,param1.items[_loc5_],CollectionModification.REMOVE));
            this.removedItems[this.getUniqueItemWrapper(param1.items[_loc5_],_loc10_,0)] = _loc10_;
            _loc5_++;
         }
         this.deltaLength += param1.items.length - _loc6_;
      }
      
      private function integrateAddedElements(param1:CollectionEvent, param2:int, param3:int) : void
      {
         var _loc9_:CollectionModification = null;
         var _loc10_:CollectionModification = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Boolean = false;
         var _loc7_:int = param1.items.length;
         var _loc8_:int = 0;
         while(_loc4_ < this.deltas.length && _loc5_ < _loc7_)
         {
            _loc9_ = CollectionModification(this.deltas[_loc4_]);
            _loc10_ = new CollectionModification(param1.location + _loc5_,null,CollectionModification.ADD);
            this.addedItems[this.getUniqueItemWrapper(param1.items[_loc5_],_loc10_,0)] = _loc10_;
            if(_loc9_.isRemove && _loc9_.index <= _loc10_.index || !_loc9_.isRemove && _loc9_.index < _loc10_.index)
            {
               _loc4_++;
            }
            else
            {
               this.deltas.splice(_loc4_ + _loc5_,0,_loc10_);
               _loc8_++;
               _loc5_++;
               _loc4_++;
            }
         }
         while(_loc4_ < this.deltas.length)
         {
            _loc9_ = CollectionModification(this.deltas[_loc4_++]);
            _loc9_.index += _loc8_;
         }
         while(_loc5_ < _loc7_)
         {
            this.deltas.push(_loc10_ = new CollectionModification(param1.location + _loc5_,null,CollectionModification.ADD));
            this.addedItems[this.getUniqueItemWrapper(param1.items[_loc5_],_loc10_,0)] = _loc10_;
            _loc5_++;
         }
         this.deltaLength -= param1.items.length;
      }
      
      private function integrateReplacedElements(param1:CollectionEvent, param2:int, param3:int) : void
      {
         var _loc9_:Object = null;
         var _loc10_:Object = null;
         var _loc11_:CollectionModification = null;
         var _loc12_:CollectionModification = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Boolean = false;
         var _loc7_:int = param1.items.length;
         var _loc8_:int = 0;
         while(_loc4_ < this.deltas.length && _loc5_ < _loc7_)
         {
            _loc9_ = PropertyChangeEvent(param1.items[_loc5_]).oldValue;
            _loc10_ = PropertyChangeEvent(param1.items[_loc5_]).newValue;
            _loc11_ = CollectionModification(this.deltas[_loc4_]);
            _loc12_ = new CollectionModification(param1.location + _loc5_,_loc9_,CollectionModification.REPLACE);
            if(_loc11_.isRemove && _loc11_.index <= _loc12_.index || !_loc11_.isRemove && _loc11_.index < _loc12_.index)
            {
               _loc4_++;
            }
            else if((_loc11_.modificationType == CollectionModification.ADD || _loc11_.modificationType == CollectionModification.REPLACE) && _loc11_.index == _loc12_.index)
            {
               _loc4_++;
               _loc5_++;
            }
            else
            {
               this.deltas.splice(_loc4_ + _loc5_,0,_loc12_);
               this.replacedItems[this.getUniqueItemWrapper(_loc9_,_loc12_,param1.location + _loc5_)] = _loc12_;
               this.replacementItems[this.getUniqueItemWrapper(_loc10_,_loc12_,param1.location + _loc5_,true)] = _loc12_;
               _loc5_++;
               _loc4_++;
            }
         }
         while(_loc5_ < _loc7_)
         {
            _loc9_ = PropertyChangeEvent(param1.items[_loc5_]).oldValue;
            _loc10_ = PropertyChangeEvent(param1.items[_loc5_]).newValue;
            this.deltas.push(_loc12_ = new CollectionModification(param1.location + _loc5_,_loc9_,CollectionModification.REPLACE));
            this.replacedItems[this.getUniqueItemWrapper(_loc9_,_loc12_,param1.location + _loc5_)] = _loc12_;
            this.replacementItems[this.getUniqueItemWrapper(_loc10_,_loc12_,param1.location + _loc5_,true)] = _loc12_;
            _loc5_++;
         }
      }
      
      private function getUniqueItemWrapper(param1:Object, param2:CollectionModification, param3:int, param4:Boolean = false) : Object
      {
         if(param2 && (param2.isRemove || param2.modificationType == CollectionModification.REPLACE && !param4))
         {
            if(!this.itemWrappersByCollectionMod[param2])
            {
               this.itemWrappersByCollectionMod[param2] = new ItemWrapper(param1);
            }
            return this.itemWrappersByCollectionMod[param2];
         }
         if(param2 && param2.modificationType == CollectionModification.ADD)
         {
            param3 = param2.index;
         }
         if(!this.itemWrappersByIndex[param3])
         {
            this.itemWrappersByIndex[param3] = new ItemWrapper(param1);
         }
         return this.itemWrappersByIndex[param3];
      }
   }
}

import flash.events.EventDispatcher;
import mx.collections.CursorBookmark;
import mx.collections.ICollectionView;
import mx.collections.IViewCursor;
import mx.collections.ModifiedCollectionView;
import mx.collections.errors.CollectionViewError;
import mx.collections.errors.CursorError;
import mx.collections.errors.ItemPendingError;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

use namespace mx_internal;

class ModifiedCollectionViewCursor extends EventDispatcher implements IViewCursor
{
   
   private static const BEFORE_FIRST_INDEX:int = -1;
   
   private static const AFTER_LAST_INDEX:int = -2;
    
   
   private var _view:ModifiedCollectionView;
   
   public var internalCursor:IViewCursor;
   
   mx_internal var currentIndex:int;
   
   public var internalIndex:int;
   
   private var currentValue:Object;
   
   private var invalid:Boolean;
   
   private var resourceManager:IResourceManager;
   
   function ModifiedCollectionViewCursor(param1:ModifiedCollectionView, param2:IViewCursor, param3:Object)
   {
      var view:ModifiedCollectionView = param1;
      var cursor:IViewCursor = param2;
      var current:Object = param3;
      this.resourceManager = ResourceManager.getInstance();
      super();
      this._view = view;
      this.internalCursor = cursor;
      if(cursor.beforeFirst && !current)
      {
         this.internalIndex = BEFORE_FIRST_INDEX;
      }
      else if(cursor.afterLast && !current)
      {
         this.internalIndex = AFTER_LAST_INDEX;
      }
      else
      {
         this.internalIndex = 0;
      }
      this.currentIndex = view.length > 0 ? 0 : int(AFTER_LAST_INDEX);
      if(this.currentIndex == 0)
      {
         try
         {
            this.setCurrent(current,false);
         }
         catch(e:ItemPendingError)
         {
            currentIndex = BEFORE_FIRST_INDEX;
            setCurrent(null,false);
         }
      }
   }
   
   public function get view() : ICollectionView
   {
      this.checkValid();
      return this._view;
   }
   
   [Bindable("cursorUpdate")]
   public function get current() : Object
   {
      this.checkValid();
      return this.currentValue;
   }
   
   [Bindable("cursorUpdate")]
   public function get bookmark() : CursorBookmark
   {
      this.checkValid();
      if(this.view.length == 0 || this.beforeFirst)
      {
         return CursorBookmark.FIRST;
      }
      if(this.afterLast)
      {
         return CursorBookmark.LAST;
      }
      return ModifiedCollectionView(this.view).getBookmark(this);
   }
   
   [Bindable("cursorUpdate")]
   public function get beforeFirst() : Boolean
   {
      this.checkValid();
      return this.currentIndex == BEFORE_FIRST_INDEX || this.view.length == 0;
   }
   
   [Bindable("cursorUpdate")]
   public function get afterLast() : Boolean
   {
      this.checkValid();
      return this.currentIndex == AFTER_LAST_INDEX || this.view.length == 0;
   }
   
   public function findAny(param1:Object) : Boolean
   {
      return false;
   }
   
   public function findFirst(param1:Object) : Boolean
   {
      return false;
   }
   
   public function findLast(param1:Object) : Boolean
   {
      return false;
   }
   
   public function insert(param1:Object) : void
   {
   }
   
   public function moveNext() : Boolean
   {
      if(this.afterLast)
      {
         return false;
      }
      var _loc1_:int = !!this.beforeFirst ? 0 : int(this.currentIndex + 1);
      if(_loc1_ >= this.view.length)
      {
         _loc1_ = AFTER_LAST_INDEX;
         this.setCurrent(null);
      }
      else
      {
         this.setCurrent(ModifiedCollectionView(this.view).getWrappedItemUsingCursor(this,_loc1_));
      }
      this.currentIndex = _loc1_;
      return !this.afterLast;
   }
   
   public function movePrevious() : Boolean
   {
      if(this.beforeFirst)
      {
         return false;
      }
      var _loc1_:int = !!this.afterLast ? int(this.view.length - 1) : int(this.currentIndex - 1);
      if(_loc1_ == -1)
      {
         _loc1_ = BEFORE_FIRST_INDEX;
         this.setCurrent(null);
      }
      else
      {
         this.setCurrent(ModifiedCollectionView(this.view).getWrappedItemUsingCursor(this,_loc1_));
      }
      this.currentIndex = _loc1_;
      return !this.beforeFirst;
   }
   
   public function remove() : Object
   {
      return null;
   }
   
   public function seek(param1:CursorBookmark, param2:int = 0, param3:int = 0) : void
   {
      var message:String = null;
      var mcvBookmark:ModifiedCollectionViewBookmark = null;
      var bookmark:CursorBookmark = param1;
      var offset:int = param2;
      var prefetch:int = param3;
      this.checkValid();
      if(this.view.length == 0)
      {
         this.currentIndex = AFTER_LAST_INDEX;
         this.setCurrent(null,false);
         return;
      }
      var newIndex:int = this.currentIndex;
      if(bookmark == CursorBookmark.FIRST)
      {
         newIndex = 0;
         this.internalIndex = 0;
         this.internalCursor.seek(CursorBookmark.FIRST);
      }
      else if(bookmark == CursorBookmark.LAST)
      {
         newIndex = this.view.length - 1;
         this.internalCursor.seek(CursorBookmark.LAST);
      }
      else if(bookmark != CursorBookmark.CURRENT)
      {
         try
         {
            mcvBookmark = bookmark as ModifiedCollectionViewBookmark;
            newIndex = ModifiedCollectionView(this.view).getBookmarkIndex(bookmark);
            if(!mcvBookmark || newIndex < 0)
            {
               this.setCurrent(null);
               message = this.resourceManager.getString("collections","bookmarkInvalid");
               throw new CursorError(message);
            }
            this.internalIndex = mcvBookmark.internalIndex;
            this.internalCursor.seek(mcvBookmark.internalBookmark);
         }
         catch(bmError:CollectionViewError)
         {
            message = resourceManager.getString("collections","bookmarkInvalid");
            throw new CursorError(message);
         }
      }
      newIndex += offset;
      var newCurrent:Object = null;
      if(newIndex >= this.view.length)
      {
         this.currentIndex = AFTER_LAST_INDEX;
      }
      else if(newIndex < 0)
      {
         this.currentIndex = BEFORE_FIRST_INDEX;
      }
      else
      {
         newCurrent = ModifiedCollectionView(this.view).getWrappedItemUsingCursor(this,newIndex);
         this.currentIndex = newIndex;
      }
      this.setCurrent(newCurrent);
   }
   
   private function checkValid() : void
   {
      var _loc1_:String = null;
      if(this.invalid)
      {
         _loc1_ = this.resourceManager.getString("collections","invalidCursor");
         throw new CursorError(_loc1_);
      }
   }
   
   private function setCurrent(param1:Object, param2:Boolean = true) : void
   {
      this.currentValue = param1;
      if(param2)
      {
         dispatchEvent(new FlexEvent(FlexEvent.CURSOR_UPDATE));
      }
   }
}

import mx.collections.CursorBookmark;
import mx.collections.ModifiedCollectionView;
import mx.core.mx_internal;

use namespace mx_internal;

class ModifiedCollectionViewBookmark extends CursorBookmark
{
    
   
   mx_internal var index:int;
   
   mx_internal var view:ModifiedCollectionView;
   
   mx_internal var viewRevision:int;
   
   mx_internal var internalBookmark:CursorBookmark;
   
   mx_internal var internalIndex:int;
   
   function ModifiedCollectionViewBookmark(param1:Object, param2:ModifiedCollectionView, param3:int, param4:int, param5:CursorBookmark, param6:int)
   {
      super(param1);
      this.view = param2;
      this.viewRevision = param3;
      this.index = param4;
      this.internalBookmark = param5;
      this.internalIndex = param6;
   }
   
   override public function getViewIndex() : int
   {
      return this.view.getBookmarkIndex(this);
   }
}

class CollectionModification
{
   
   public static const REMOVE:String = "remove";
   
   public static const ADD:String = "add";
   
   public static const REPLACE:String = "replace";
    
   
   public var index:int;
   
   public var item:Object = null;
   
   public var modificationType:String = null;
   
   private var _modCount:int = 0;
   
   public var showOldReplace:Boolean = true;
   
   public var showNewReplace:Boolean = false;
   
   function CollectionModification(param1:int, param2:Object, param3:String)
   {
      super();
      this.index = param1;
      this.modificationType = param3;
      if(param3 != CollectionModification.ADD)
      {
         this.item = param2;
      }
      if(param3 == CollectionModification.REMOVE)
      {
         this._modCount = 1;
      }
      else if(param3 == CollectionModification.ADD)
      {
         this._modCount = -1;
      }
   }
   
   public function get isRemove() : Boolean
   {
      return this.modificationType == CollectionModification.REMOVE;
   }
   
   public function startShowingReplacementValue() : void
   {
      this.showNewReplace = true;
      ++this._modCount;
   }
   
   public function stopShowingReplacedValue() : void
   {
      this.showOldReplace = false;
      --this._modCount;
   }
   
   public function get modCount() : int
   {
      return this._modCount;
   }
}
