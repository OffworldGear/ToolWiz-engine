package mx.collections
{
   import flash.events.EventDispatcher;
   import flash.utils.getQualifiedClassName;
   import mx.core.mx_internal;
   import mx.events.CollectionEvent;
   import mx.events.CollectionEventKind;
   import mx.events.PropertyChangeEvent;
   import mx.events.PropertyChangeEventKind;
   import mx.resources.IResourceManager;
   import mx.resources.ResourceManager;
   import mx.utils.IXMLNotifiable;
   import mx.utils.UIDUtil;
   import mx.utils.XMLNotifier;
   
   use namespace mx_internal;
   
   public class XMLListAdapter extends EventDispatcher implements IList, IXMLNotifiable
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var resourceManager:IResourceManager;
      
      private var _source:XMLList;
      
      private var _dispatchEvents:int = 0;
      
      private var _busy:int = 0;
      
      private var seedUID:String;
      
      private var uidCounter:int = 0;
      
      public function XMLListAdapter(param1:XMLList = null)
      {
         this.resourceManager = ResourceManager.getInstance();
         super();
         this.disableEvents();
         this.source = param1;
         this.enableEvents();
      }
      
      public function get length() : int
      {
         return this.source.length();
      }
      
      public function get source() : XMLList
      {
         return this._source;
      }
      
      public function set source(param1:XMLList) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:CollectionEvent = null;
         if(this._source && this._source.length())
         {
            _loc3_ = this._source.length();
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               this.stopTrackUpdates(this._source[_loc2_]);
               _loc2_++;
            }
         }
         this._source = !!param1 ? param1 : XMLList(new XMLList(""));
         this.seedUID = UIDUtil.createUID();
         this.uidCounter = 0;
         _loc3_ = this._source.length();
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            this.startTrackUpdates(this._source[_loc2_],this.seedUID + this.uidCounter.toString());
            ++this.uidCounter;
            _loc2_++;
         }
         if(this._dispatchEvents == 0)
         {
            (_loc4_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE)).kind = CollectionEventKind.RESET;
            dispatchEvent(_loc4_);
         }
      }
      
      public function addItem(param1:Object) : void
      {
         this.addItemAt(param1,this.length);
      }
      
      public function addItemAt(param1:Object, param2:int) : void
      {
         var _loc3_:String = null;
         var _loc4_:CollectionEvent = null;
         if(param2 < 0 || param2 > this.length)
         {
            _loc3_ = this.resourceManager.getString("collections","outOfBounds",[param2]);
            throw new RangeError(_loc3_);
         }
         if(!(param1 is XML) && !(param1 is XMLList && param1.length() == 1))
         {
            _loc3_ = this.resourceManager.getString("collections","invalidType");
            throw new Error(_loc3_);
         }
         this.setBusy();
         if(param2 == 0)
         {
            this.source[0] = this.length > 0 ? param1 + this.source[0] : param1;
         }
         else
         {
            this.source[param2 - 1] += param1;
         }
         this.startTrackUpdates(param1,this.seedUID + this.uidCounter.toString());
         ++this.uidCounter;
         if(this._dispatchEvents == 0)
         {
            (_loc4_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE)).kind = CollectionEventKind.ADD;
            _loc4_.items.push(param1);
            _loc4_.location = param2;
            dispatchEvent(_loc4_);
         }
         this.clearBusy();
      }
      
      public function getItemAt(param1:int, param2:int = 0) : Object
      {
         var _loc3_:String = null;
         if(param1 < 0 || param1 >= this.length)
         {
            _loc3_ = this.resourceManager.getString("collections","outOfBounds",[param1]);
            throw new RangeError(_loc3_);
         }
         return this.source[param1];
      }
      
      public function getItemIndex(param1:Object) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(param1 is XML && this.source.contains(XML(param1)))
         {
            _loc2_ = this.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if((_loc4_ = this.source[_loc3_]) === param1)
               {
                  return _loc3_;
               }
               _loc3_++;
            }
         }
         return -1;
      }
      
      public function itemUpdated(param1:Object, param2:Object = null, param3:Object = null, param4:Object = null) : void
      {
         var _loc5_:PropertyChangeEvent;
         (_loc5_ = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE)).kind = PropertyChangeEventKind.UPDATE;
         _loc5_.source = param1;
         _loc5_.property = param2;
         _loc5_.oldValue = param3;
         _loc5_.newValue = param4;
         this.itemUpdateHandler(_loc5_);
      }
      
      public function removeAll() : void
      {
         var _loc1_:int = 0;
         var _loc2_:CollectionEvent = null;
         if(this.length > 0)
         {
            _loc1_ = this.length - 1;
            while(_loc1_ >= 0)
            {
               this.stopTrackUpdates(this.source[_loc1_]);
               delete this.source[_loc1_];
               _loc1_--;
            }
            if(this._dispatchEvents == 0)
            {
               _loc2_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
               _loc2_.kind = CollectionEventKind.RESET;
               dispatchEvent(_loc2_);
            }
         }
      }
      
      public function removeItemAt(param1:int) : Object
      {
         var _loc3_:String = null;
         var _loc4_:CollectionEvent = null;
         if(param1 < 0 || param1 >= this.length)
         {
            _loc3_ = this.resourceManager.getString("collections","outOfBounds",[param1]);
            throw new RangeError(_loc3_);
         }
         this.setBusy();
         var _loc2_:Object = this.source[param1];
         delete this.source[param1];
         this.stopTrackUpdates(_loc2_);
         if(this._dispatchEvents == 0)
         {
            (_loc4_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE)).kind = CollectionEventKind.REMOVE;
            _loc4_.location = param1;
            _loc4_.items.push(_loc2_);
            dispatchEvent(_loc4_);
         }
         this.clearBusy();
         return _loc2_;
      }
      
      public function setItemAt(param1:Object, param2:int) : Object
      {
         var _loc4_:String = null;
         var _loc5_:CollectionEvent = null;
         var _loc6_:PropertyChangeEvent = null;
         if(param2 < 0 || param2 >= this.length)
         {
            _loc4_ = this.resourceManager.getString("collections","outOfBounds",[param2]);
            throw new RangeError(_loc4_);
         }
         var _loc3_:Object = this.source[param2];
         this.source[param2] = param1;
         this.stopTrackUpdates(_loc3_);
         this.startTrackUpdates(param1,this.seedUID + this.uidCounter.toString());
         ++this.uidCounter;
         if(this._dispatchEvents == 0)
         {
            (_loc5_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE)).kind = CollectionEventKind.REPLACE;
            (_loc6_ = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE)).kind = PropertyChangeEventKind.UPDATE;
            _loc6_.oldValue = _loc3_;
            _loc6_.newValue = param1;
            _loc5_.location = param2;
            _loc5_.items.push(_loc6_);
            dispatchEvent(_loc5_);
         }
         return _loc3_;
      }
      
      public function toArray() : Array
      {
         var _loc1_:XMLList = this.source;
         var _loc2_:int = _loc1_.length();
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_[_loc4_] = _loc1_[_loc4_];
            _loc4_++;
         }
         return _loc3_;
      }
      
      override public function toString() : String
      {
         if(this.source)
         {
            return this.source.toString();
         }
         return getQualifiedClassName(this);
      }
      
      public function busy() : Boolean
      {
         return this._busy != 0;
      }
      
      protected function enableEvents() : void
      {
         ++this._dispatchEvents;
         if(this._dispatchEvents > 0)
         {
            this._dispatchEvents = 0;
         }
      }
      
      protected function disableEvents() : void
      {
         --this._dispatchEvents;
      }
      
      private function clearBusy() : void
      {
         ++this._busy;
         if(this._busy > 0)
         {
            this._busy = 0;
         }
      }
      
      private function setBusy() : void
      {
         --this._busy;
      }
      
      protected function itemUpdateHandler(param1:PropertyChangeEvent) : void
      {
         var _loc2_:CollectionEvent = null;
         if(this._dispatchEvents == 0)
         {
            _loc2_ = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
            _loc2_.kind = CollectionEventKind.UPDATE;
            _loc2_.items.push(param1);
            dispatchEvent(_loc2_);
         }
      }
      
      public function xmlNotification(param1:Object, param2:String, param3:Object, param4:Object, param5:Object) : void
      {
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         var _loc9_:* = undefined;
         var _loc10_:* = undefined;
         if(param1 === param3)
         {
            switch(param2)
            {
               case "attributeAdded":
                  _loc6_ = "@" + String(param4);
                  _loc8_ = param5;
                  break;
               case "attributeChanged":
                  _loc6_ = "@" + String(param4);
                  _loc7_ = param5;
                  _loc8_ = param3[_loc6_];
                  break;
               case "attributeRemoved":
                  _loc6_ = "@" + String(param4);
                  _loc7_ = param5;
                  break;
               case "nodeAdded":
                  _loc6_ = param4.localName();
                  _loc8_ = param4;
                  break;
               case "nodeChanged":
                  _loc6_ = param4.localName();
                  _loc7_ = param5;
                  _loc8_ = param4;
                  break;
               case "nodeRemoved":
                  _loc6_ = param4.localName();
                  _loc7_ = param4;
                  break;
               case "textSet":
                  _loc6_ = String(param4);
                  _loc8_ = String(param3[_loc6_]);
                  _loc7_ = param5;
            }
         }
         else if(param2 == "textSet")
         {
            if((_loc9_ = param3.parent()) != undefined)
            {
               if((_loc10_ = _loc9_.parent()) === param1)
               {
                  _loc6_ = _loc9_.name().toString();
                  _loc8_ = param4;
                  _loc7_ = param5;
               }
            }
         }
         this.itemUpdated(param1,_loc6_,_loc7_,_loc8_);
      }
      
      protected function startTrackUpdates(param1:Object, param2:String) : void
      {
         XMLNotifier.getInstance().watchXML(param1,this,param2);
      }
      
      protected function stopTrackUpdates(param1:Object) : void
      {
         XMLNotifier.getInstance().unwatchXML(param1,this);
      }
   }
}
