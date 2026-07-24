package comps
{
   import flash.display.Graphics;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.events.ResizeEvent;
   import skins.GridSkin;
   import spark.components.SkinnableContainer;
   
   public class GridComponent extends SkinnableContainer
   {
      
      public static var gridSpacing:int = 40;
      
      public static var innerGridSpacing:int = 8;
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var drawFunc:Function = null;
      
      public var xOriginPos:int = 0;
      
      public var yOriginPos:int = 0;
      
      public var showXAxis:Boolean = true;
      
      public var showYAxis:Boolean = true;
      
      private var absoluteY:Boolean = false;
      
      private var _yOrigin:int = 0;
      
      private var _xOrigin:int = 0;
      
      private var _3652044xMax:int;
      
      private var _3681835yMax:int;
      
      private var _202660904hideNegativeAxis:Boolean = false;
      
      public var isReady:Boolean = false;
      
      public function GridComponent()
      {
         super();
         mx_internal::_document = this;
         this.addEventListener("creationComplete",this.___GridComponent_SkinnableContainer1_creationComplete);
         this.addEventListener("resize",this.___GridComponent_SkinnableContainer1_resize);
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         var factory:IFlexModuleFactory = param1;
         super.moduleFactory = factory;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
         if(!this.styleDeclaration)
         {
            this.styleDeclaration = new CSSStyleDeclaration(null,styleManager);
         }
         this.styleDeclaration.defaultFactory = function():void
         {
            this.skinClass = GridSkin;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      [Bindable(event="propertyChange")]
      public function get xOrigin() : int
      {
         return this._xOrigin;
      }
      
      private function set _1496474046xOrigin(param1:int) : void
      {
         this._xOrigin = param1;
      }
      
      [Bindable(event="propertyChange")]
      public function get yOrigin() : int
      {
         return this._yOrigin;
      }
      
      private function set _1910989569yOrigin(param1:int) : void
      {
         this._yOrigin = param1;
      }
      
      private function init() : void
      {
         this.isReady = true;
         this.recalcOrigins();
      }
      
      private function recalcOrigins() : void
      {
         if(this.isReady)
         {
            if(this.xOriginPos > 0)
            {
               this.xOrigin = width * this.xOriginPos / 100;
            }
            else if(this.xOrigin == 0)
            {
               this.xOrigin = gridSpacing;
            }
            if(this.yOriginPos > 0)
            {
               this.yOrigin = height * this.yOriginPos / 100;
            }
            else if(this.yOrigin == 0 || this.absoluteY)
            {
               this.yOrigin = height - gridSpacing;
               this.absoluteY = true;
            }
            this.xOrigin = Math.round(this.xOrigin / gridSpacing) * gridSpacing;
            this.yOrigin = Math.round(this.yOrigin / gridSpacing) * gridSpacing;
            this.yMax = this.yOrigin - gridSpacing;
            this.xMax = width - (this.xOrigin + gridSpacing);
            this.redraw();
         }
      }
      
      public function redraw() : void
      {
         var _loc1_:Graphics = this.contentGroup.graphics;
         _loc1_.clear();
         if(this.showXAxis)
         {
            _loc1_.lineStyle(1,16711680,1);
            _loc1_.moveTo(!!this.hideNegativeAxis ? Number(this.xOrigin) : Number(0),this.yOrigin);
            _loc1_.lineTo(width,this.yOrigin);
         }
         if(this.showYAxis)
         {
            _loc1_.lineStyle(1,65280,1);
            _loc1_.moveTo(this.xOrigin,0);
            _loc1_.lineTo(this.xOrigin,!!this.hideNegativeAxis ? Number(this.yOrigin) : Number(height));
         }
         if(this.drawFunc != null)
         {
            this.drawFunc(_loc1_);
         }
      }
      
      public function ___GridComponent_SkinnableContainer1_creationComplete(param1:FlexEvent) : void
      {
         this.init();
      }
      
      public function ___GridComponent_SkinnableContainer1_resize(param1:ResizeEvent) : void
      {
         this.recalcOrigins();
      }
      
      [Bindable(event="propertyChange")]
      public function get xMax() : int
      {
         return this._3652044xMax;
      }
      
      public function set xMax(param1:int) : void
      {
         var _loc2_:Object = this._3652044xMax;
         if(_loc2_ !== param1)
         {
            this._3652044xMax = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xMax",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get yMax() : int
      {
         return this._3681835yMax;
      }
      
      public function set yMax(param1:int) : void
      {
         var _loc2_:Object = this._3681835yMax;
         if(_loc2_ !== param1)
         {
            this._3681835yMax = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"yMax",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hideNegativeAxis() : Boolean
      {
         return this._202660904hideNegativeAxis;
      }
      
      public function set hideNegativeAxis(param1:Boolean) : void
      {
         var _loc2_:Object = this._202660904hideNegativeAxis;
         if(_loc2_ !== param1)
         {
            this._202660904hideNegativeAxis = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hideNegativeAxis",_loc2_,param1));
            }
         }
      }
      
      public function set xOrigin(param1:int) : void
      {
         var _loc2_:Object = this.xOrigin;
         if(_loc2_ !== param1)
         {
            this._1496474046xOrigin = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xOrigin",_loc2_,param1));
            }
         }
      }
      
      public function set yOrigin(param1:int) : void
      {
         var _loc2_:Object = this.yOrigin;
         if(_loc2_ !== param1)
         {
            this._1910989569yOrigin = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"yOrigin",_loc2_,param1));
            }
         }
      }
   }
}
