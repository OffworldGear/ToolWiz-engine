package mx.controls.treeClasses
{
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import mx.collections.CursorBookmark;
   import mx.collections.ICollectionView;
   import mx.collections.IViewCursor;
   import mx.core.mx_internal;
   import mx.events.CollectionEvent;
   import mx.events.CollectionEventKind;
   
   use namespace mx_internal;
   
   public class HierarchicalViewCursor extends EventDispatcher implements IViewCursor
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var dataDescriptor:ITreeDataDescriptor;
      
      private var currentIndex:int = 0;
      
      private var currentChildIndex:int = 0;
      
      private var _currentDepth:int = 1;
      
      private var childNodes:Object;
      
      private var parentNodes:Array;
      
      private var childIndexStack:Array;
      
      private var model:ICollectionView;
      
      private var collection:HierarchicalCollectionView;
      
      private var openNodes:Object;
      
      private var more:Boolean;
      
      private var modelCursor:IViewCursor;
      
      private var itemToUID:Function;
      
      public function HierarchicalViewCursor(param1:HierarchicalCollectionView, param2:ICollectionView, param3:ITreeDataDescriptor, param4:Function, param5:Object)
      {
         this.childNodes = [];
         this.parentNodes = [];
         this.childIndexStack = [];
         super();
         this.collection = param1;
         this.model = param2;
         this.dataDescriptor = param3;
         this.itemToUID = param4;
         this.openNodes = param5;
         param1.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler,false,0,true);
         this.modelCursor = param2.createCursor();
         if(param2.length > 1)
         {
            this.more = true;
         }
         else
         {
            this.more = false;
         }
      }
      
      public function get index() : int
      {
         return this.currentIndex;
      }
      
      public function get bookmark() : CursorBookmark
      {
         return new CursorBookmark(this.currentIndex.toString());
      }
      
      public function get current() : Object
      {
         try
         {
            if(this.childIndexStack.length == 0)
            {
               return this.modelCursor.current;
            }
            return this.childNodes[this.currentChildIndex];
         }
         catch(e:RangeError)
         {
            return null;
         }
      }
      
      public function get currentDepth() : int
      {
         return this._currentDepth;
      }
      
      public function get beforeFirst() : Boolean
      {
         return this.currentIndex <= this.collection.length && this.current == null;
      }
      
      public function get afterLast() : Boolean
      {
         return this.currentIndex >= this.collection.length && this.current == null;
      }
      
      public function get view() : ICollectionView
      {
         return this.model;
      }
      
      private function isItemVisible(param1:Object) : Boolean
      {
         var _loc2_:Object = this.collection.getParentItem(param1);
         while(_loc2_ != null)
         {
            if(this.openNodes[this.itemToUID(_loc2_)] == null)
            {
               return false;
            }
            _loc2_ = this.collection.getParentItem(_loc2_);
         }
         return true;
      }
      
      private function getParentStack(param1:Object) : Array
      {
         var _loc2_:Array = [];
         var _loc3_:Object = this.collection.getParentItem(param1);
         while(_loc3_ != null)
         {
            _loc2_.unshift(_loc3_);
            _loc3_ = this.collection.getParentItem(_loc3_);
         }
         return _loc2_;
      }
      
      private function isNodeBefore(param1:Object, param2:Object) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:ICollectionView = null;
         var _loc6_:Object = null;
         var _loc9_:Object = null;
         var _loc10_:Object = null;
         var _loc11_:Object = null;
         if(param2 == null)
         {
            return false;
         }
         var _loc7_:Array = this.getParentStack(param1);
         var _loc8_:Array = this.getParentStack(param2);
         while(_loc7_.length && _loc8_.length)
         {
            _loc9_ = _loc7_.shift();
            _loc10_ = _loc8_.shift();
            if(_loc9_ != _loc10_)
            {
               if((_loc6_ = this.collection.getParentItem(_loc9_)) != null && this.dataDescriptor.isBranch(_loc6_,this.model) && this.dataDescriptor.hasChildren(_loc6_,this.model))
               {
                  _loc5_ = this.dataDescriptor.getChildren(_loc6_,this.model);
               }
               else
               {
                  _loc5_ = this.model;
               }
               _loc3_ = _loc5_.length;
               if((_loc11_ = _loc5_[_loc4_]) == _loc10_)
               {
                  return false;
               }
               if(_loc11_ == _loc9_)
               {
                  return true;
               }
            }
         }
         if(_loc7_.length)
         {
            param1 = _loc7_.shift();
         }
         if(_loc8_.length)
         {
            param2 = _loc8_.shift();
         }
         _loc3_ = (_loc5_ = this.model).length;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            if((_loc11_ = _loc5_[_loc4_]) == param2)
            {
               return false;
            }
            if(_loc11_ == param1)
            {
               return true;
            }
            _loc4_++;
         }
         return false;
      }
      
      public function findAny(param1:Object) : Boolean
      {
         var _loc3_:Object = null;
         var _loc4_:Boolean = false;
         var _loc5_:* = null;
         this.seek(CursorBookmark.FIRST);
         var _loc2_:Boolean = false;
         while(true)
         {
            if(_loc2_)
            {
               return false;
            }
            _loc3_ = this.dataDescriptor.getData(this.current);
            _loc4_ = true;
            for(_loc5_ in param1)
            {
               if(_loc3_[_loc5_] != param1[_loc5_])
               {
                  _loc4_ = false;
                  break;
               }
            }
            if(_loc4_)
            {
               break;
            }
            _loc2_ = this.moveNext();
         }
         return true;
      }
      
      public function findFirst(param1:Object) : Boolean
      {
         return this.findAny(param1);
      }
      
      public function findLast(param1:Object) : Boolean
      {
         var _loc3_:Object = null;
         var _loc4_:Boolean = false;
         var _loc5_:* = null;
         this.seek(CursorBookmark.LAST);
         var _loc2_:Boolean = false;
         while(true)
         {
            if(_loc2_)
            {
               return false;
            }
            _loc3_ = this.current;
            _loc4_ = true;
            for(_loc5_ in param1)
            {
               if(_loc3_[_loc5_] != param1[_loc5_])
               {
                  _loc4_ = false;
                  break;
               }
            }
            if(_loc4_)
            {
               break;
            }
            _loc2_ = this.movePrevious();
         }
         return true;
      }
      
      public function moveNext() : Boolean
      {
         var previousChildNodes:Object = null;
         var grandParent:Object = null;
         var currentNode:Object = this.current;
         if(currentNode == null)
         {
            return false;
         }
         var uid:String = this.itemToUID(currentNode);
         if(!this.collection.parentMap.hasOwnProperty(uid))
         {
            this.collection.parentMap[uid] = this.parentNodes[this.parentNodes.length - 1];
         }
         if(this.openNodes[uid] && this.dataDescriptor.isBranch(currentNode,this.model) && this.dataDescriptor.hasChildren(currentNode,this.model))
         {
            previousChildNodes = this.childNodes;
            this.childNodes = this.dataDescriptor.getChildren(currentNode,this.model);
            if(this.childNodes.length > 0)
            {
               this.childIndexStack.push(this.currentChildIndex);
               this.parentNodes.push(currentNode);
               this.currentChildIndex = 0;
               currentNode = this.childNodes[0];
               ++this.currentIndex;
               ++this._currentDepth;
               return true;
            }
            this.childNodes = previousChildNodes;
         }
         while(this.childNodes != null && this.childNodes.length > 0 && this.currentChildIndex >= Math.max(this.childNodes.length - 1,0))
         {
            if(this.childIndexStack.length < 1 && !this.more)
            {
               currentNode = null;
               ++this.currentIndex;
               this._currentDepth = 1;
               return false;
            }
            currentNode = this.parentNodes.pop();
            grandParent = this.parentNodes[this.parentNodes.length - 1];
            if(grandParent != null && this.dataDescriptor.isBranch(grandParent,this.model) && this.dataDescriptor.hasChildren(grandParent,this.model))
            {
               this.childNodes = this.dataDescriptor.getChildren(grandParent,this.model);
            }
            else
            {
               this.childNodes = [];
            }
            this.currentChildIndex = this.childIndexStack.pop();
            --this._currentDepth;
         }
         if(this.childIndexStack.length == 0)
         {
            this._currentDepth = 1;
            this.more = this.modelCursor.moveNext();
            if(!this.more)
            {
               this._currentDepth = 1;
               ++this.currentIndex;
               currentNode = null;
               return false;
            }
            currentNode = this.modelCursor.current;
         }
         else
         {
            try
            {
               currentNode = this.childNodes[++this.currentChildIndex];
            }
            catch(e:RangeError)
            {
               return false;
            }
         }
         ++this.currentIndex;
         return true;
      }
      
      public function movePrevious() : Boolean
      {
         var grandParent:Object = null;
         var previousChildNodes:Object = null;
         var currentNode:Object = this.current;
         if(currentNode == null)
         {
            return false;
         }
         if(this.parentNodes && this.parentNodes.length > 0)
         {
            if(this.currentChildIndex == 0)
            {
               currentNode = this.parentNodes.pop();
               this.currentChildIndex = this.childIndexStack.pop();
               grandParent = this.parentNodes[this.parentNodes.length - 1];
               if(grandParent != null && this.dataDescriptor.isBranch(grandParent,this.model) && this.dataDescriptor.hasChildren(grandParent,this.model))
               {
                  this.childNodes = this.dataDescriptor.getChildren(grandParent,this.model);
               }
               else
               {
                  this.childNodes = [];
               }
               --this._currentDepth;
               --this.currentIndex;
               return true;
            }
            try
            {
               currentNode = this.childNodes[--this.currentChildIndex];
            }
            catch(e:RangeError)
            {
               return false;
            }
         }
         else
         {
            this.more = this.modelCursor.movePrevious();
            if(!this.more)
            {
               this.currentIndex = -1;
               currentNode = null;
               return false;
            }
            currentNode = this.modelCursor.current;
         }
         while(this.openNodes[this.itemToUID(currentNode)] && this.dataDescriptor.isBranch(currentNode,this.model) && this.dataDescriptor.hasChildren(currentNode,this.model))
         {
            previousChildNodes = this.childNodes;
            this.childNodes = this.dataDescriptor.getChildren(currentNode,this.model);
            if(this.childNodes.length <= 0)
            {
               this.childNodes = previousChildNodes;
            }
            this.childIndexStack.push(this.currentChildIndex);
            this.parentNodes.push(currentNode);
            this.currentChildIndex = this.childNodes.length - 1;
            currentNode = this.childNodes[this.currentChildIndex];
            ++this._currentDepth;
         }
         --this.currentIndex;
         return true;
      }
      
      public function seek(param1:CursorBookmark, param2:int = 0, param3:int = 0) : void
      {
         var _loc4_:int = 0;
         if(param1 == CursorBookmark.FIRST)
         {
            _loc4_ = 0;
         }
         else if(param1 == CursorBookmark.CURRENT)
         {
            _loc4_ = this.currentIndex;
         }
         else if(param1 == CursorBookmark.LAST)
         {
            _loc4_ = this.collection.length - 1;
         }
         else
         {
            _loc4_ = int(param1.value);
         }
         _loc4_ = Math.max(Math.min(_loc4_ + param2,this.collection.length),0);
         var _loc5_:int = Math.abs(this.currentIndex - _loc4_);
         var _loc6_:int = Math.abs(this.collection.length - _loc4_);
         var _loc7_:* = true;
         if(_loc5_ < _loc4_)
         {
            if(_loc6_ < _loc5_)
            {
               this.moveToLast();
               if(_loc6_ == 0)
               {
                  this.moveNext();
                  _loc4_ = 0;
               }
               else
               {
                  _loc4_ = _loc6_ - 1;
               }
               _loc7_ = false;
            }
            else
            {
               _loc7_ = this.currentIndex < _loc4_;
               _loc4_ = _loc5_;
               if(this.currentIndex == this.collection.length)
               {
                  _loc4_--;
                  this.moveToLast();
               }
            }
         }
         else if(_loc6_ < _loc4_)
         {
            this.moveToLast();
            if(_loc6_ == 0)
            {
               this.moveNext();
               _loc4_ = 0;
            }
            else
            {
               _loc4_ = _loc6_ - 1;
            }
            _loc7_ = false;
         }
         else
         {
            this.moveToFirst();
         }
         if(_loc7_)
         {
            while(_loc4_ && _loc4_ > 0)
            {
               this.moveNext();
               _loc4_--;
            }
         }
         else
         {
            while(_loc4_ && _loc4_ > 0)
            {
               this.movePrevious();
               _loc4_--;
            }
         }
      }
      
      private function moveToFirst() : void
      {
         this.childNodes = [];
         this.modelCursor.seek(CursorBookmark.FIRST,0);
         if(this.model.length > 1)
         {
            this.more = true;
         }
         else
         {
            this.more = false;
         }
         this.currentChildIndex = 0;
         this.parentNodes = [];
         this.childIndexStack = [];
         this.currentIndex = 0;
         this._currentDepth = 1;
      }
      
      public function moveToLast() : void
      {
         var _loc3_:Object = null;
         this.childNodes = [];
         this.childIndexStack = [];
         this._currentDepth = 1;
         this.parentNodes = [];
         var _loc1_:Boolean = false;
         this.modelCursor.seek(CursorBookmark.LAST,0);
         var _loc2_:Object = this.modelCursor.current;
         while(this.openNodes[this.itemToUID(_loc2_)] && this.dataDescriptor.isBranch(_loc2_,this.model) && this.dataDescriptor.hasChildren(_loc2_,this.model))
         {
            _loc3_ = this.childNodes;
            this.childNodes = this.dataDescriptor.getChildren(_loc2_,this.model);
            if(!(this.childNodes != null && this.childNodes.length > 0))
            {
               this.childNodes = _loc3_;
            }
            this.parentNodes.push(_loc2_);
            this.childIndexStack.push(this.currentChildIndex);
            _loc2_ = this.childNodes[this.childNodes.length - 1];
            this.currentChildIndex = this.childNodes.length - 1;
            ++this._currentDepth;
         }
         this.currentIndex = this.collection.length - 1;
      }
      
      public function insert(param1:Object) : void
      {
      }
      
      public function remove() : Object
      {
         return null;
      }
      
      public function collectionChangeHandler(param1:CollectionEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         var _loc7_:Array = null;
         var _loc8_:Dictionary = null;
         var _loc10_:int = 0;
         var _loc9_:Boolean = false;
         _loc7_ = this.getParentStack(this.current);
         _loc8_ = new Dictionary();
         _loc3_ = _loc7_.length;
         _loc2_ = 0;
         while(_loc2_ < _loc3_ - 1)
         {
            _loc8_[_loc7_[_loc2_]] = _loc2_ + 1;
            _loc2_++;
         }
         _loc6_ = _loc7_[_loc7_.length - 1];
         if(param1.kind == CollectionEventKind.ADD)
         {
            _loc3_ = param1.items.length;
            if(param1.location <= this.currentIndex)
            {
               this.currentIndex += _loc3_;
               _loc9_ = true;
            }
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               _loc4_ = param1.items[_loc2_];
               if(_loc9_)
               {
                  if((_loc5_ = this.collection.getParentItem(_loc4_)) == _loc6_)
                  {
                     ++this.currentChildIndex;
                  }
                  else if(_loc8_[_loc5_] != null)
                  {
                     ++this.childIndexStack[_loc8_[_loc5_]];
                  }
               }
               _loc2_++;
            }
         }
         else if(param1.kind == CollectionEventKind.REMOVE)
         {
            _loc3_ = param1.items.length;
            if(param1.location <= this.currentIndex)
            {
               if(param1.location + _loc3_ >= this.currentIndex)
               {
                  _loc10_ = param1.location;
                  this.moveToFirst();
                  this.seek(CursorBookmark.FIRST,_loc10_);
                  _loc2_ = 0;
                  while(_loc2_ < _loc3_)
                  {
                     _loc4_ = param1.items[_loc2_];
                     delete this.collection.parentMap[this.itemToUID(_loc4_)];
                     _loc2_++;
                  }
                  return;
               }
               this.currentIndex -= _loc3_;
               _loc9_ = true;
            }
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               _loc4_ = param1.items[_loc2_];
               if(_loc9_)
               {
                  if((_loc5_ = this.collection.getParentItem(_loc4_)) == _loc6_)
                  {
                     --this.currentChildIndex;
                  }
                  else if(_loc8_[_loc5_] != null)
                  {
                     --this.childIndexStack[_loc8_[_loc5_]];
                  }
               }
               delete this.collection.parentMap[this.itemToUID(_loc4_)];
               _loc2_++;
            }
         }
      }
   }
}
