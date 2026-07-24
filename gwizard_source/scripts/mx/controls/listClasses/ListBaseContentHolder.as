package mx.controls.listClasses
{
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import mx.collections.IViewCursor;
   import mx.core.FlexShape;
   import mx.core.FlexSprite;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class ListBaseContentHolder extends UIComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public var selectionLayer:Sprite;
      
      public var visibleData:Object;
      
      public var listItems:Array;
      
      public var rowInfo:Array;
      
      public var iterator:IViewCursor;
      
      private var parentList:ListBase;
      
      private var maskShape:Shape;
      
      mx_internal var allowItemSizeChangeNotification:Boolean = true;
      
      public var leftOffset:Number = 0;
      
      public var topOffset:Number = 0;
      
      public var rightOffset:Number = 0;
      
      public var bottomOffset:Number = 0;
      
      public function ListBaseContentHolder(param1:ListBase)
      {
         var _loc2_:Graphics = null;
         this.visibleData = {};
         this.listItems = [];
         this.rowInfo = [];
         super();
         this.parentList = param1;
         setStyle("backgroundColor","");
         setStyle("borderStyle","none");
         setStyle("borderSkin",null);
         if(!this.selectionLayer)
         {
            this.selectionLayer = new FlexSprite();
            this.selectionLayer.name = "selectionLayer";
            this.selectionLayer.mouseEnabled = false;
            addChild(this.selectionLayer);
            _loc2_ = this.selectionLayer.graphics;
            _loc2_.beginFill(0,0);
            _loc2_.drawRect(0,0,10,10);
            _loc2_.endFill();
         }
      }
      
      override public function set focusPane(param1:Sprite) : void
      {
         var _loc2_:Graphics = null;
         if(param1)
         {
            if(!this.maskShape)
            {
               this.maskShape = new FlexShape();
               this.maskShape.name = "mask";
               _loc2_ = this.maskShape.graphics;
               _loc2_.beginFill(16777215);
               _loc2_.drawRect(-2,-2,this.parentList.width + 2,this.parentList.height + 2);
               _loc2_.endFill();
               addChild(this.maskShape);
            }
            this.maskShape.visible = false;
            param1.mask = this.maskShape;
         }
         else if(this.parentList.focusPane.mask == this.maskShape)
         {
            this.parentList.focusPane.mask = null;
         }
         this.parentList.focusPane = param1;
         param1.x = x;
         param1.y = y;
      }
      
      override public function invalidateSize() : void
      {
         if(this.allowItemSizeChangeNotification)
         {
            this.parentList.invalidateList();
         }
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         var _loc3_:Graphics = this.selectionLayer.graphics;
         _loc3_.clear();
         if(param1 > 0 && param2 > 0)
         {
            _loc3_.beginFill(8421504,0);
            _loc3_.drawRect(0,0,param1,param2);
            _loc3_.endFill();
         }
         if(this.maskShape)
         {
            this.maskShape.width = param1;
            this.maskShape.height = param2;
         }
      }
      
      mx_internal function getParentList() : ListBase
      {
         return this.parentList;
      }
      
      public function get heightExcludingOffsets() : Number
      {
         return height + this.topOffset - this.bottomOffset;
      }
      
      public function get widthExcludingOffsets() : Number
      {
         return width + this.leftOffset - this.rightOffset;
      }
   }
}
