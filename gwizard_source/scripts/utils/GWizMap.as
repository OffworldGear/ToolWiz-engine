package utils
{
   import mx.utils.ObjectUtil;
   
   public class GWizMap
   {
      
      public static const EmptyMap:GWizMap = new GWizMap();
       
      
      protected var byKey:Object;
      
      protected var count:int;
      
      public function GWizMap()
      {
         super();
         this.byKey = new Object();
         this.count = 0;
      }
      
      public static function fromArray(param1:Array, param2:String) : GWizMap
      {
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc3_:GWizMap = new GWizMap();
         if(param1 == null)
         {
            return _loc3_;
         }
         for each(_loc4_ in param1)
         {
            if((_loc5_ = param2 == null || param2 == "" ? _loc4_ : _loc4_[param2]) == null)
            {
               return null;
            }
            _loc6_ = _loc5_ is String ? _loc5_ as String : _loc5_.toString();
            _loc3_.add(_loc6_,_loc4_);
         }
         return _loc3_;
      }
      
      public static function fromGWizMap(param1:GWizMap, param2:String) : GWizMap
      {
         if(param1 == null)
         {
            return null;
         }
         return fromArray(param1.toArray(),param2);
      }
      
      public static function getSimpleObjectClones(param1:GWizMap) : GWizMap
      {
         var _loc2_:GWizMap = new GWizMap();
         if(param1 == null)
         {
            return _loc2_;
         }
         _loc2_.byKey = ObjectUtil.clone(param1.byKey);
         return _loc2_;
      }
      
      public function toArray() : Array
      {
         var _loc2_:Object = null;
         var _loc1_:Array = new Array();
         for each(_loc2_ in this.byKey)
         {
            _loc1_.push(_loc2_);
         }
         return _loc1_;
      }
      
      public function hasKey(param1:String) : Boolean
      {
         return this.byKey && this.byKey.hasOwnProperty(param1);
      }
      
      public function getByKey(param1:String) : Object
      {
         return !!this.hasKey(param1) ? this.byKey[param1] : null;
      }
      
      public function add(param1:String, param2:Object) : void
      {
         GWizUtils.assert(this.hasKey(param1) == false);
         this.byKey[param1] = param2;
         ++this.count;
      }
      
      public function update(param1:String, param2:Object) : void
      {
         GWizUtils.assert(this.hasKey(param1));
         this.byKey[param1] = param2;
      }
      
      public function ensure(param1:String, param2:Object) : void
      {
         var _loc3_:Boolean = this.hasKey(param1);
         this.byKey[param1] = param2;
         if(!_loc3_)
         {
            ++this.count;
         }
      }
      
      public function remove(param1:String) : Object
      {
         if(!this.hasKey(param1))
         {
            return null;
         }
         var _loc2_:Object = this.byKey[param1];
         delete this.byKey[param1];
         --this.count;
         return _loc2_;
      }
      
      public function removeAll() : void
      {
         this.byKey = new Object();
         this.count = 0;
      }
      
      public function getKeySetAsMap() : GWizMap
      {
         var _loc2_:* = null;
         var _loc1_:GWizMap = new GWizMap();
         for(_loc2_ in this.byKey)
         {
            _loc1_.add(_loc2_,null);
         }
         return _loc1_;
      }
      
      public function getKeySetAsArray() : Array
      {
         var _loc2_:* = null;
         var _loc1_:Array = new Array();
         for(_loc2_ in this.byKey)
         {
            _loc1_.push(_loc2_);
         }
         return _loc1_;
      }
      
      public function get length() : int
      {
         return this.byKey == null ? 0 : int(this.count);
      }
      
      public function forEach(param1:Function) : void
      {
         var _loc2_:* = null;
         for(_loc2_ in this.byKey)
         {
            param1(_loc2_,this.byKey[_loc2_]);
         }
      }
   }
}
