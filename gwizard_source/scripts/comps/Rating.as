package comps
{
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.HGroup;
   import spark.components.Image;
   
   use namespace mx_internal;
   
   public class Rating extends HGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _109757471star1:Image;
      
      private var _109757472star2:Image;
      
      private var _109757473star3:Image;
      
      private var _109757474star4:Image;
      
      private var _109757475star5:Image;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _value:int = 0;
      
      private var valueInvalidatedFlag:Boolean = true;
      
      private var lastShownValue:int;
      
      public var editable:Boolean = false;
      
      public var smallSize:Boolean = false;
      
      private const StarImage:Class = Rating_StarImage;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function Rating()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.lastShownValue = this.value;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._Rating_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_RatingWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return Rating[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.verticalAlign = "top";
         this.horizontalAlign = "left";
         this.gap = 1;
         this.mxmlContent = [this._Rating_Image1_i(),this._Rating_Image2_i(),this._Rating_Image3_i(),this._Rating_Image4_i(),this._Rating_Image5_i()];
         this.addEventListener("creationComplete",this.___Rating_HGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         Rating._watcherSetupUtil = param1;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function onCC() : void
      {
         if(this.smallSize)
         {
            this.star1.height = this.star1.width = this.star2.height = this.star2.width = this.star3.height = this.star3.width = this.star4.height = this.star4.width = this.star5.height = this.star5.width = 8;
         }
         else
         {
            gap = 3;
            this.star1.height = this.star1.width = this.star2.height = this.star2.width = this.star3.height = this.star3.width = this.star4.height = this.star4.width = this.star5.height = this.star5.width = 16;
         }
      }
      
      public function get value() : int
      {
         return this._value;
      }
      
      private function set _111972721value(param1:int) : void
      {
         this._value = param1;
         this.valueInvalidatedFlag = true;
         invalidateProperties();
      }
      
      override protected function commitProperties() : void
      {
         if(this.valueInvalidatedFlag)
         {
            this.valueInvalidatedFlag = false;
            this.showRating(this._value);
         }
      }
      
      private function setRating(param1:int) : void
      {
         if(this.editable)
         {
            this._value = param1;
            this.showRating(param1);
         }
      }
      
      private function showRating(param1:int) : void
      {
         this.lastShownValue = param1;
         this.star1.alpha = param1 >= 1 ? Number(1) : Number(0.1);
         this.star2.alpha = param1 >= 2 ? Number(1) : Number(0.1);
         this.star3.alpha = param1 >= 3 ? Number(1) : Number(0.1);
         this.star4.alpha = param1 >= 4 ? Number(1) : Number(0.1);
         this.star5.alpha = param1 >= 5 ? Number(1) : Number(0.1);
      }
      
      private function _Rating_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.alpha = 0.1;
         _loc1_.addEventListener("click",this.__star1_click);
         _loc1_.id = "star1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.star1 = _loc1_;
         BindingManager.executeBindings(this,"star1",this.star1);
         return _loc1_;
      }
      
      public function __star1_click(param1:MouseEvent) : void
      {
         this.setRating(1);
      }
      
      private function _Rating_Image2_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.alpha = 0.1;
         _loc1_.addEventListener("click",this.__star2_click);
         _loc1_.id = "star2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.star2 = _loc1_;
         BindingManager.executeBindings(this,"star2",this.star2);
         return _loc1_;
      }
      
      public function __star2_click(param1:MouseEvent) : void
      {
         this.setRating(2);
      }
      
      private function _Rating_Image3_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.alpha = 0.1;
         _loc1_.addEventListener("click",this.__star3_click);
         _loc1_.id = "star3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.star3 = _loc1_;
         BindingManager.executeBindings(this,"star3",this.star3);
         return _loc1_;
      }
      
      public function __star3_click(param1:MouseEvent) : void
      {
         this.setRating(3);
      }
      
      private function _Rating_Image4_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.alpha = 0.1;
         _loc1_.addEventListener("click",this.__star4_click);
         _loc1_.id = "star4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.star4 = _loc1_;
         BindingManager.executeBindings(this,"star4",this.star4);
         return _loc1_;
      }
      
      public function __star4_click(param1:MouseEvent) : void
      {
         this.setRating(4);
      }
      
      private function _Rating_Image5_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.alpha = 0.1;
         _loc1_.addEventListener("click",this.__star5_click);
         _loc1_.id = "star5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.star5 = _loc1_;
         BindingManager.executeBindings(this,"star5",this.star5);
         return _loc1_;
      }
      
      public function __star5_click(param1:MouseEvent) : void
      {
         this.setRating(5);
      }
      
      public function ___Rating_HGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _Rating_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Object
         {
            return StarImage;
         },null,"star1.source");
         result[1] = new Binding(this,function():Object
         {
            return StarImage;
         },null,"star2.source");
         result[2] = new Binding(this,function():Object
         {
            return StarImage;
         },null,"star3.source");
         result[3] = new Binding(this,function():Object
         {
            return StarImage;
         },null,"star4.source");
         result[4] = new Binding(this,function():Object
         {
            return StarImage;
         },null,"star5.source");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get star1() : Image
      {
         return this._109757471star1;
      }
      
      public function set star1(param1:Image) : void
      {
         var _loc2_:Object = this._109757471star1;
         if(_loc2_ !== param1)
         {
            this._109757471star1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"star1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get star2() : Image
      {
         return this._109757472star2;
      }
      
      public function set star2(param1:Image) : void
      {
         var _loc2_:Object = this._109757472star2;
         if(_loc2_ !== param1)
         {
            this._109757472star2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"star2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get star3() : Image
      {
         return this._109757473star3;
      }
      
      public function set star3(param1:Image) : void
      {
         var _loc2_:Object = this._109757473star3;
         if(_loc2_ !== param1)
         {
            this._109757473star3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"star3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get star4() : Image
      {
         return this._109757474star4;
      }
      
      public function set star4(param1:Image) : void
      {
         var _loc2_:Object = this._109757474star4;
         if(_loc2_ !== param1)
         {
            this._109757474star4 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"star4",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get star5() : Image
      {
         return this._109757475star5;
      }
      
      public function set star5(param1:Image) : void
      {
         var _loc2_:Object = this._109757475star5;
         if(_loc2_ !== param1)
         {
            this._109757475star5 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"star5",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function set value(param1:int) : void
      {
         var _loc2_:Object = this.value;
         if(_loc2_ !== param1)
         {
            this._111972721value = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"value",_loc2_,param1));
            }
         }
      }
   }
}
