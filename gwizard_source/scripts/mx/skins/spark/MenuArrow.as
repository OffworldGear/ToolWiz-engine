package mx.skins.spark
{
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.GradientEntry;
   import mx.graphics.RadialGradient;
   import spark.primitives.Path;
   import spark.skins.SparkSkin;
   
   public class MenuArrow extends SparkSkin
   {
      
      private static const symbols:Array = ["arrowFill1","arrowFill2","arrowFill3"];
       
      
      private var _93090825arrow:Path;
      
      private var _1752992635arrowFill1:GradientEntry;
      
      private var _1752992634arrowFill2:GradientEntry;
      
      private var _1752992633arrowFill3:GradientEntry;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function MenuArrow()
      {
         super();
         mx_internal::_document = this;
         this.mxmlContent = [this._MenuArrow_Path1_i()];
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
      
      override public function get symbolItems() : Array
      {
         return symbols;
      }
      
      private function _MenuArrow_Path1_i() : Path
      {
         var _loc1_:Path = new Path();
         _loc1_.data = "M 5 4 L 4 4 L 4 3 L 3 3 L 3 2 L 2 2 L 2 1 L 1 1 L 1 0 L 0 0 L 0 9 L 1 9 L 1 8 L 2 8 L 2 7 L 3 7 L 3 6 L 4 6 L 4 5 L 5 5 L 5 4 Z";
         _loc1_.fill = this._MenuArrow_RadialGradient1_c();
         _loc1_.initialized(this,"arrow");
         this.arrow = _loc1_;
         BindingManager.executeBindings(this,"arrow",this.arrow);
         return _loc1_;
      }
      
      private function _MenuArrow_RadialGradient1_c() : RadialGradient
      {
         var _loc1_:RadialGradient = new RadialGradient();
         _loc1_.rotation = 135;
         _loc1_.focalPointRatio = -0.7;
         _loc1_.x = 0;
         _loc1_.y = 5;
         _loc1_.scaleX = 7;
         _loc1_.entries = [this._MenuArrow_GradientEntry1_i(),this._MenuArrow_GradientEntry2_i(),this._MenuArrow_GradientEntry3_i()];
         return _loc1_;
      }
      
      private function _MenuArrow_GradientEntry1_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.45;
         _loc1_.ratio = 0;
         this.arrowFill1 = _loc1_;
         BindingManager.executeBindings(this,"arrowFill1",this.arrowFill1);
         return _loc1_;
      }
      
      private function _MenuArrow_GradientEntry2_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.55;
         _loc1_.ratio = 0.9;
         this.arrowFill2 = _loc1_;
         BindingManager.executeBindings(this,"arrowFill2",this.arrowFill2);
         return _loc1_;
      }
      
      private function _MenuArrow_GradientEntry3_i() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.75;
         _loc1_.ratio = 1;
         this.arrowFill3 = _loc1_;
         BindingManager.executeBindings(this,"arrowFill3",this.arrowFill3);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get arrow() : Path
      {
         return this._93090825arrow;
      }
      
      public function set arrow(param1:Path) : void
      {
         var _loc2_:Object = this._93090825arrow;
         if(_loc2_ !== param1)
         {
            this._93090825arrow = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"arrow",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get arrowFill1() : GradientEntry
      {
         return this._1752992635arrowFill1;
      }
      
      public function set arrowFill1(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1752992635arrowFill1;
         if(_loc2_ !== param1)
         {
            this._1752992635arrowFill1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"arrowFill1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get arrowFill2() : GradientEntry
      {
         return this._1752992634arrowFill2;
      }
      
      public function set arrowFill2(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1752992634arrowFill2;
         if(_loc2_ !== param1)
         {
            this._1752992634arrowFill2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"arrowFill2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get arrowFill3() : GradientEntry
      {
         return this._1752992633arrowFill3;
      }
      
      public function set arrowFill3(param1:GradientEntry) : void
      {
         var _loc2_:Object = this._1752992633arrowFill3;
         if(_loc2_ !== param1)
         {
            this._1752992633arrowFill3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"arrowFill3",_loc2_,param1));
            }
         }
      }
   }
}
