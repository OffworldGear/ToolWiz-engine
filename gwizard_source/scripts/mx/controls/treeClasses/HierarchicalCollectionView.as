package mx.controls.treeClasses
{
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import mx.collections.ICollectionView;
   import mx.collections.ISort;
   import mx.collections.IViewCursor;
   import mx.collections.XMLListAdapter;
   import mx.collections.XMLListCollection;
   import mx.collections.errors.ItemPendingError;
   import mx.core.EventPriority;
   import mx.core.mx_internal;
   import mx.events.CollectionEvent;
   import mx.events.CollectionEventKind;
   import mx.events.PropertyChangeEvent;
   import mx.utils.IXMLNotifiable;
   import mx.utils.XMLNotifier;
   
   use namespace mx_internal;
   
   public class HierarchicalCollectionView extends EventDispatcher implements ICollectionView, IXMLNotifiable
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var dataDescriptor:ITreeDataDescriptor;
      
      private var treeData:ICollectionView;
      
      private var cursor:HierarchicalViewCursor;
      
      private var currentLength:int;
      
      public var openNodes:Object;
      
      public var parentMap:Object;
      
      private var parentNode:XML;
      
      private var childrenMap:Dictionary;
      
      private var itemToUID:Function;
      
      public function HierarchicalCollectionView(param1:ICollectionView, param2:ITreeDataDescriptor, param3:Function, param4:Object = null)
      {
         super();
         this.parentMap = {};
         this.childrenMap = new Dictionary(true);
         this.treeData = param1;
         this.treeData.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler,false,EventPriority.DEFAULT_HANDLER,true);
         addEventListener(CollectionEvent.COLLECTION_CHANGE,this.expandEventHandler,false,0,true);
         this.dataDescriptor = param2;
         this.itemToUID = param3;
         this.openNodes = param4;
         this.currentLength = this.calculateLength();
      }
      
      public function get filterFunction() : Function
      {
         return null;
      }
      
      public function set filterFunction(param1:Function) : void
      {
      }
      
      public function get length() : int
      {
         return this.currentLength;
      }
      
      public function get sort() : ISort
      {
         return null;
      }
      
      public function set sort(param1:ISort) : void
      {
      }
      
      public function getParentItem(param1:Object) : *
      {
         var _loc2_:String = this.itemToUID(param1);
         if(this.parentMap.hasOwnProperty(_loc2_))
         {
            return this.parentMap[_loc2_];
         }
         return undefined;
      }
      
      public function calculateLength(param1:Object = null, param2:Object = null) : int
      {
         var length:int = 0;
         var childNodes:ICollectionView = null;
         var modelOffset:int = 0;
         var modelCursor:IViewCursor = null;
         var parNode:* = undefined;
         var uid:String = null;
         var numChildren:int = 0;
         var i:int = 0;
         var node:Object = param1;
         var parent:Object = param2;
         length = 0;
         var firstNode:Boolean = true;
         if(node == null)
         {
            modelOffset = 0;
            modelCursor = this.treeData.createCursor();
            if(modelCursor.beforeFirst)
            {
               return this.treeData.length;
            }
            while(!modelCursor.afterLast)
            {
               node = modelCursor.current;
               if(node is XML)
               {
                  if(firstNode)
                  {
                     firstNode = false;
                     parNode = node.parent();
                     if(parNode)
                     {
                        this.startTrackUpdates(parNode);
                        this.childrenMap[parNode] = this.treeData;
                        this.parentNode = parNode;
                     }
                  }
                  this.startTrackUpdates(node);
               }
               if(node === null)
               {
                  length += 1;
               }
               else
               {
                  length += this.calculateLength(node,null) + 1;
               }
               modelOffset++;
               try
               {
                  modelCursor.moveNext();
               }
               catch(e:ItemPendingError)
               {
                  length += treeData.length - modelOffset;
                  return length;
               }
            }
         }
         else
         {
            uid = this.itemToUID(node);
            this.parentMap[uid] = parent;
            if(node != null && this.openNodes[uid] && this.dataDescriptor.isBranch(node,this.treeData) && this.dataDescriptor.hasChildren(node,this.treeData))
            {
               childNodes = this.getChildren(node);
               if(childNodes != null)
               {
                  numChildren = childNodes.length;
                  i = 0;
                  while(i < numChildren)
                  {
                     if(node is XML)
                     {
                        this.startTrackUpdates(childNodes[i]);
                     }
                     length += this.calculateLength(childNodes[i],node) + 1;
                     i++;
                  }
               }
            }
         }
         return length;
      }
      
      public function describeData() : Object
      {
         return null;
      }
      
      public function createCursor() : IViewCursor
      {
         return new HierarchicalViewCursor(this,this.treeData,this.dataDescriptor,this.itemToUID,this.openNodes);
      }
      
      public function contains(param1:Object) : Boolean
      {
         var _loc2_:IViewCursor = this.createCursor();
         var _loc3_:Boolean = false;
         while(!_loc3_)
         {
            if(_loc2_.current == param1)
            {
               return true;
            }
            _loc3_ = _loc2_.moveNext();
         }
         return false;
      }
      
      public function disableAutoUpdate() : void
      {
      }
      
      public function enableAutoUpdate() : void
      {
      }
      
      public function itemUpdated(param1:Object, param2:Object = null, param3:Object = null, param4:Object = null) : void
      {
         var _loc5_:CollectionEvent;
         (_loc5_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE)).kind = CollectionEventKind.UPDATE;
         var _loc6_:PropertyChangeEvent;
         (_loc6_ = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE)).property = param2;
         _loc6_.oldValue = param3;
         _loc6_.newValue = param4;
         _loc5_.items.push(_loc6_);
         dispatchEvent(_loc5_);
      }
      
      public function refresh() : Boolean
      {
         var _loc1_:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
         _loc1_.kind = CollectionEventKind.REFRESH;
         dispatchEvent(_loc1_);
         return true;
      }
      
      private function getChildren(param1:Object) : ICollectionView
      {
         var _loc2_:ICollectionView = this.dataDescriptor.getChildren(param1,this.treeData);
         var _loc3_:ICollectionView = this.childrenMap[param1];
         if(_loc3_ != _loc2_)
         {
            if(_loc3_ != null)
            {
               _loc3_.removeEventListener(CollectionEvent.COLLECTION_CHANGE,this.nestedCollectionChangeHandler);
            }
            if(_loc2_)
            {
               _loc2_.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.nestedCollectionChangeHandler,false,0,true);
               this.childrenMap[param1] = _loc2_;
            }
            else
            {
               delete this.childrenMap[param1];
            }
         }
         return _loc2_;
      }
      
      private function updateLength(param1:Object = null, param2:Object = null) : void
      {
         this.currentLength = this.calculateLength();
      }
      
      private function getVisibleNodes(param1:Object, param2:Object, param3:Array) : void
      {
         var _loc4_:ICollectionView = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         param3.push(param1);
         var _loc5_:String = this.itemToUID(param1);
         this.parentMap[_loc5_] = param2;
         if(this.openNodes[_loc5_] && this.dataDescriptor.isBranch(param1,this.treeData) && this.dataDescriptor.hasChildren(param1,this.treeData))
         {
            if((_loc4_ = this.getChildren(param1)) != null)
            {
               _loc6_ = _loc4_.length;
               _loc7_ = 0;
               while(_loc7_ < _loc6_)
               {
                  this.getVisibleNodes(_loc4_[_loc7_],param1,param3);
                  _loc7_++;
               }
            }
         }
      }
      
      private function getVisibleLocation(param1:int) : int
      {
         var _loc2_:int = 0;
         var _loc3_:IViewCursor = this.treeData.createCursor();
         var _loc4_:int = 0;
         while(_loc4_ < param1 && !_loc3_.afterLast)
         {
            _loc2_ += this.calculateLength(_loc3_.current,null) + 1;
            _loc3_.moveNext();
            _loc4_++;
         }
         return _loc2_;
      }
      
      private function getVisibleLocationInSubCollection(param1:Object, param2:int) : int
      {
         var _loc5_:ICollectionView = null;
         var _loc6_:IViewCursor = null;
         var _loc3_:int = param2;
         var _loc4_:Object = param1;
         param1 = this.getParentItem(param1);
         while(param1 != null)
         {
            _loc6_ = (_loc5_ = this.childrenMap[param1]).createCursor();
            while(!_loc6_.afterLast)
            {
               if(_loc6_.current == _loc4_)
               {
                  _loc3_++;
                  break;
               }
               _loc3_ += this.calculateLength(_loc6_.current,param1) + 1;
               _loc6_.moveNext();
            }
            _loc4_ = param1;
            param1 = this.getParentItem(param1);
         }
         _loc6_ = this.treeData.createCursor();
         while(!_loc6_.afterLast)
         {
            if(_loc6_.current == _loc4_)
            {
               _loc3_++;
               break;
            }
            _loc3_ += this.calculateLength(_loc6_.current,param1) + 1;
            _loc6_.moveNext();
         }
         return _loc3_;
      }
      
      public function collectionChangeHandler(param1:CollectionEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:Object = null;
         var _loc8_:Array = null;
         var _loc9_:CollectionEvent = null;
         var _loc10_:CollectionEvent = null;
         var _loc11_:int = 0;
         if(param1 is CollectionEvent)
         {
            if((_loc10_ = CollectionEvent(param1)).kind == CollectionEventKind.RESET)
            {
               this.updateLength();
               dispatchEvent(param1);
            }
            else if(_loc10_.kind == CollectionEventKind.ADD)
            {
               _loc3_ = _loc10_.items.length;
               (_loc9_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,false,true,_loc10_.kind)).location = this.getVisibleLocation(_loc10_.location);
               _loc2_ = 0;
               while(_loc2_ < _loc3_)
               {
                  if((_loc7_ = _loc10_.items[_loc2_]) is XML)
                  {
                     this.startTrackUpdates(_loc7_);
                  }
                  this.getVisibleNodes(_loc7_,null,_loc9_.items);
                  _loc2_++;
               }
               this.currentLength += _loc9_.items.length;
               dispatchEvent(_loc9_);
            }
            else if(_loc10_.kind == CollectionEventKind.REMOVE)
            {
               _loc3_ = _loc10_.items.length;
               (_loc9_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,false,true,_loc10_.kind)).location = this.getVisibleLocation(_loc10_.location);
               _loc2_ = 0;
               while(_loc2_ < _loc3_)
               {
                  if((_loc7_ = _loc10_.items[_loc2_]) is XML)
                  {
                     this.stopTrackUpdates(_loc7_);
                  }
                  this.getVisibleNodes(_loc7_,null,_loc9_.items);
                  _loc2_++;
               }
               this.currentLength -= _loc9_.items.length;
               dispatchEvent(_loc9_);
            }
            else if(_loc10_.kind == CollectionEventKind.UPDATE)
            {
               dispatchEvent(param1);
            }
            else if(_loc10_.kind == CollectionEventKind.REPLACE)
            {
               _loc3_ = _loc10_.items.length;
               _loc9_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,false,true,CollectionEventKind.REMOVE);
               _loc2_ = 0;
               while(_loc2_ < _loc3_)
               {
                  if((_loc7_ = _loc10_.items[_loc2_].oldValue) is XML)
                  {
                     this.stopTrackUpdates(_loc7_);
                  }
                  this.getVisibleNodes(_loc7_,null,_loc9_.items);
                  _loc2_++;
               }
               _loc11_ = 0;
               _loc2_ = 0;
               while(_loc2_ < _loc3_)
               {
                  _loc7_ = _loc10_.items[_loc2_].oldValue;
                  while(_loc9_.items[_loc11_] != _loc7_)
                  {
                     _loc11_++;
                  }
                  _loc9_.items.splice(_loc11_,1);
                  _loc2_++;
               }
               if(_loc9_.items.length)
               {
                  this.currentLength -= _loc9_.items.length;
                  dispatchEvent(_loc9_);
               }
               dispatchEvent(param1);
            }
         }
      }
      
      public function nestedCollectionChangeHandler(param1:CollectionEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:Object = null;
         var _loc8_:Array = null;
         var _loc9_:CollectionEvent = null;
         var _loc10_:CollectionEvent = null;
         var _loc11_:int = 0;
         if(param1 is CollectionEvent)
         {
            if((_loc10_ = CollectionEvent(param1)).kind == CollectionEventKind.EXPAND)
            {
               param1.stopImmediatePropagation();
            }
            else if(_loc10_.kind == CollectionEventKind.ADD)
            {
               this.updateLength();
               _loc3_ = _loc10_.items.length;
               _loc9_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,false,true,_loc10_.kind);
               _loc2_ = 0;
               while(_loc2_ < _loc3_)
               {
                  if((_loc7_ = _loc10_.items[_loc2_]) is XML)
                  {
                     this.startTrackUpdates(_loc7_);
                  }
                  if((_loc6_ = this.getParentItem(_loc7_)) != null)
                  {
                     this.getVisibleNodes(_loc7_,_loc6_,_loc9_.items);
                  }
                  _loc2_++;
               }
               _loc9_.location = this.getVisibleLocationInSubCollection(_loc6_,_loc10_.location);
               dispatchEvent(_loc9_);
            }
            else if(_loc10_.kind == CollectionEventKind.REMOVE)
            {
               _loc3_ = _loc10_.items.length;
               _loc9_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,false,true,_loc10_.kind);
               _loc2_ = 0;
               while(_loc2_ < _loc3_)
               {
                  if((_loc7_ = _loc10_.items[_loc2_]) is XML)
                  {
                     this.stopTrackUpdates(_loc7_);
                  }
                  if((_loc6_ = this.getParentItem(_loc7_)) != null)
                  {
                     this.getVisibleNodes(_loc7_,_loc6_,_loc9_.items);
                  }
                  _loc2_++;
               }
               _loc9_.location = this.getVisibleLocationInSubCollection(_loc6_,_loc10_.location);
               this.currentLength -= _loc9_.items.length;
               dispatchEvent(_loc9_);
            }
            else if(_loc10_.kind == CollectionEventKind.UPDATE)
            {
               dispatchEvent(param1);
            }
            else if(_loc10_.kind == CollectionEventKind.REPLACE)
            {
               _loc3_ = _loc10_.items.length;
               _loc9_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,false,true,CollectionEventKind.REMOVE);
               _loc2_ = 0;
               while(_loc2_ < _loc3_)
               {
                  _loc7_ = _loc10_.items[_loc2_].oldValue;
                  if((_loc6_ = this.getParentItem(_loc7_)) != null)
                  {
                     this.getVisibleNodes(_loc7_,_loc6_,_loc9_.items);
                  }
                  _loc2_++;
               }
               _loc11_ = 0;
               _loc2_ = 0;
               while(_loc2_ < _loc3_)
               {
                  if((_loc7_ = _loc10_.items[_loc2_].oldValue) is XML)
                  {
                     this.stopTrackUpdates(_loc7_);
                  }
                  while(_loc9_.items[_loc11_] != _loc7_)
                  {
                     _loc11_++;
                  }
                  _loc9_.items.splice(_loc11_,1);
                  _loc2_++;
               }
               if(_loc9_.items.length)
               {
                  this.currentLength -= _loc9_.items.length;
                  dispatchEvent(_loc9_);
               }
               dispatchEvent(param1);
            }
            else if(_loc10_.kind == CollectionEventKind.RESET)
            {
               this.updateLength();
               _loc9_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,false,true,CollectionEventKind.REFRESH);
               dispatchEvent(_loc9_);
            }
         }
      }
      
      public function xmlNotification(param1:Object, param2:String, param3:Object, param4:Object, param5:Object) : void
      {
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         var _loc9_:XMLListCollection = null;
         var _loc10_:int = 0;
         var _loc11_:CollectionEvent = null;
         var _loc12_:XMLListAdapter = null;
         var _loc13_:* = undefined;
         var _loc14_:* = undefined;
         var _loc15_:XMLList = null;
         var _loc16_:XMLListCollection = null;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         if(param1 === param3)
         {
            switch(param2)
            {
               case "nodeAdded":
                  for(_loc13_ in this.childrenMap)
                  {
                     if(_loc13_ === param1)
                     {
                        _loc12_ = this.childrenMap[_loc13_].list as XMLListAdapter;
                        break;
                     }
                  }
                  if(!_loc12_ && param3 is XML && XML(param3).children().length() == 1)
                  {
                     _loc12_ = (this.getChildren(param3) as XMLListCollection).list as XMLListAdapter;
                  }
                  if(_loc12_ && !_loc12_.busy())
                  {
                     if(this.childrenMap[_loc13_] === this.treeData)
                     {
                        _loc9_ = this.treeData as XMLListCollection;
                        if(this.parentNode)
                        {
                           _loc9_.dispatchResetEvent = false;
                           _loc9_.source = this.parentNode.*;
                        }
                     }
                     else
                     {
                        _loc9_ = this.getChildren(_loc13_) as XMLListCollection;
                     }
                     if(_loc9_)
                     {
                        _loc10_ = param4.childIndex();
                        (_loc11_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE)).kind = CollectionEventKind.ADD;
                        _loc11_.location = _loc10_;
                        _loc11_.items = [param4];
                        _loc9_.dispatchEvent(_loc11_);
                     }
                  }
                  break;
               case "nodeRemoved":
                  for(_loc14_ in this.childrenMap)
                  {
                     if(_loc14_ === param1)
                     {
                        if((_loc12_ = (_loc9_ = this.childrenMap[_loc14_]).list as XMLListAdapter) && !_loc12_.busy())
                        {
                           _loc15_ = _loc9_.source as XMLList;
                           if(this.childrenMap[_loc14_] === this.treeData)
                           {
                              _loc9_ = this.treeData as XMLListCollection;
                              if(this.parentNode)
                              {
                                 _loc9_.dispatchResetEvent = false;
                                 _loc9_.source = this.parentNode.*;
                              }
                           }
                           else
                           {
                              _loc16_ = _loc9_;
                              if(!(_loc9_ = this.getChildren(_loc14_) as XMLListCollection))
                              {
                                 _loc16_.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.nestedCollectionChangeHandler,false,0,true);
                                 (_loc11_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE)).kind = CollectionEventKind.REMOVE;
                                 _loc11_.location = 0;
                                 _loc11_.items = [param4];
                                 _loc16_.dispatchEvent(_loc11_);
                                 _loc16_.removeEventListener(CollectionEvent.COLLECTION_CHANGE,this.nestedCollectionChangeHandler);
                              }
                           }
                           if(_loc9_)
                           {
                              _loc17_ = _loc15_.length();
                              _loc18_ = 0;
                              while(_loc18_ < _loc17_)
                              {
                                 if(_loc15_[_loc18_] === param4)
                                 {
                                    (_loc11_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE)).kind = CollectionEventKind.REMOVE;
                                    _loc11_.location = _loc10_;
                                    _loc11_.items = [param4];
                                    _loc9_.dispatchEvent(_loc11_);
                                    break;
                                 }
                                 _loc18_++;
                              }
                           }
                        }
                        break;
                     }
                  }
            }
         }
      }
      
      private function startTrackUpdates(param1:Object) : void
      {
         XMLNotifier.getInstance().watchXML(param1,this);
      }
      
      private function stopTrackUpdates(param1:Object) : void
      {
         XMLNotifier.getInstance().unwatchXML(param1,this);
      }
      
      public function expandEventHandler(param1:CollectionEvent) : void
      {
         var _loc2_:CollectionEvent = null;
         if(param1 is CollectionEvent)
         {
            _loc2_ = CollectionEvent(param1);
            if(_loc2_.kind == CollectionEventKind.EXPAND)
            {
               param1.stopImmediatePropagation();
               this.updateLength();
            }
         }
      }
   }
}
