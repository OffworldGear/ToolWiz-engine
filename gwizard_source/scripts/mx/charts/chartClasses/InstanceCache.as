package mx.charts.chartClasses
{
   import flash.text.TextFormat;
   import mx.core.ClassFactory;
   import mx.core.ContextualClassFactory;
   import mx.core.IFactory;
   import mx.core.IFlexModuleFactory;
   import mx.core.IUITextField;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class InstanceCache
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _parent:Object;
      
      private var _class:Class = null;
      
      private var _insertPosition:int;
      
      private var _count:int = 0;
      
      public var creationCallback:Function;
      
      public var discard:Boolean = false;
      
      private var _factory:IFactory;
      
      private var _format:TextFormat;
      
      public var hide:Boolean = true;
      
      private var _instances:Array;
      
      private var _properties:Object;
      
      public var remove:Boolean = false;
      
      public function InstanceCache(param1:Object, param2:Object = null, param3:int = -1, param4:IFlexModuleFactory = null)
      {
         this._instances = [];
         this._properties = {};
         super();
         this._parent = param2;
         if(param1 is IFactory)
         {
            this._factory = IFactory(param1);
         }
         else if(param1 is Class)
         {
            this._class = Class(param1);
            this._factory = new ContextualClassFactory(Class(param1),param4);
         }
         this._insertPosition = param3;
      }
      
      public function get count() : int
      {
         return this._count;
      }
      
      public function set count(param1:int) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         if(param1 == this._count)
         {
            return;
         }
         var _loc2_:int = param1;
         var _loc3_:int = this._count;
         var _loc4_:int = this._instances.length;
         if(this._parent != null)
         {
            _loc5_ = Math.min(this._insertPosition,this._parent.numChildren - _loc4_);
         }
         if(_loc2_ > _loc3_)
         {
            if(!this._factory)
            {
               param1 = 0;
            }
            else
            {
               _loc6_ = _loc3_;
               while(_loc6_ < _loc2_ && _loc6_ < _loc4_)
               {
                  if(this.hide)
                  {
                     this._instances[_loc6_].visible = true;
                  }
                  if(this._parent && this.remove)
                  {
                     if(_loc5_ >= 0)
                     {
                        this._parent.addChildAt(this._instances[_loc6_],_loc5_ + _loc6_);
                     }
                     else
                     {
                        this._parent.addChild(this._instances[_loc6_]);
                     }
                  }
                  _loc6_++;
               }
               while(_loc6_ < _loc2_)
               {
                  _loc7_ = this._factory.newInstance();
                  if(this._parent)
                  {
                     if(_loc5_ > 0)
                     {
                        this._parent.addChildAt(_loc7_,_loc5_ + _loc6_);
                     }
                     else
                     {
                        this._parent.addChild(_loc7_);
                     }
                  }
                  if(this.creationCallback != null)
                  {
                     this.creationCallback(_loc7_,this);
                  }
                  this._instances.push(_loc7_);
                  _loc6_++;
               }
               this.applyProperties(_loc4_,_loc2_);
               if(this._format)
               {
                  this.applyFormat(_loc4_,_loc2_);
               }
            }
         }
         else if(_loc2_ < _loc3_)
         {
            if(this.remove)
            {
               _loc6_ = _loc2_;
               while(_loc6_ < _loc3_)
               {
                  this._parent.removeChild(this._instances[_loc6_]);
                  _loc6_++;
               }
            }
            if(this.hide)
            {
               _loc6_ = _loc2_;
               while(_loc6_ < _loc3_)
               {
                  this._instances[_loc6_].visible = false;
                  _loc6_++;
               }
            }
            if(this.discard)
            {
               this._instances = this._instances.slice(0,_loc2_);
            }
         }
         this._count = param1;
      }
      
      public function get factory() : IFactory
      {
         return this._factory;
      }
      
      public function set factory(param1:IFactory) : void
      {
         if(param1 == this._factory || param1 is ClassFactory && this._factory is ClassFactory && ClassFactory(this._factory).generator == ClassFactory(param1).generator && !(param1 is ContextualClassFactory))
         {
            return;
         }
         this._factory = param1;
         this._class = null;
         var _loc2_:Number = this._count;
         this.count = 0;
         this.count = _loc2_;
      }
      
      public function get format() : TextFormat
      {
         return this._format;
      }
      
      public function set format(param1:TextFormat) : void
      {
         this._format = param1;
         if(this._format)
         {
            this.applyFormat(0,this._instances.length);
         }
      }
      
      public function set insertPosition(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1 != this._insertPosition)
         {
            this._insertPosition = param1;
            if(this._parent)
            {
               _loc2_ = this._instances.length;
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  this._parent.setChildIndex(this._instances[_loc3_],_loc3_ + this._insertPosition);
                  _loc3_++;
               }
            }
         }
      }
      
      public function get instances() : Array
      {
         return this._instances;
      }
      
      public function get properties() : Object
      {
         return this._properties;
      }
      
      public function set properties(param1:Object) : void
      {
         this._properties = param1;
         this.applyProperties(0,this._instances.length);
      }
      
      private function applyProperties(param1:int, param2:int) : void
      {
         var _loc4_:Object = null;
         var _loc5_:* = null;
         var _loc3_:int = param1;
         while(_loc3_ < param2)
         {
            _loc4_ = this._instances[_loc3_];
            for(_loc5_ in this._properties)
            {
               _loc4_[_loc5_] = this._properties[_loc5_];
            }
            _loc3_++;
         }
      }
      
      private function applyFormat(param1:int, param2:int) : void
      {
         var _loc4_:IUITextField = null;
         var _loc3_:int = param1;
         while(_loc3_ < param2)
         {
            (_loc4_ = this._instances[_loc3_]).setTextFormat(this._format);
            _loc4_.defaultTextFormat = this._format;
            _loc3_++;
         }
      }
   }
}
