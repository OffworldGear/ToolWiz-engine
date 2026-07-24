package mx.controls
{
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.ui.Keyboard;
   import mx.core.IFlexDisplayObject;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   
   use namespace mx_internal;
   
   public class ToggleButtonBar extends ButtonBar
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var initializeSelectedButton:Boolean = true;
      
      mx_internal var selectedButtonTextStyleNameProp:String = "selectedButtonTextStyleName";
      
      private var _selectedIndex:int = -2;
      
      private var selectedIndexChanged:Boolean = false;
      
      private var _toggleOnClick:Boolean = false;
      
      public function ToggleButtonBar()
      {
         super();
      }
      
      [Bindable("valueCommit")]
      [Bindable("click")]
      override public function get selectedIndex() : int
      {
         return super.selectedIndex;
      }
      
      override public function set selectedIndex(param1:int) : void
      {
         if(param1 == this.selectedIndex && param1 != -1)
         {
            return;
         }
         if(numChildren == 0)
         {
            this._selectedIndex = param1;
            this.selectedIndexChanged = true;
         }
         if(param1 < numChildren)
         {
            this._selectedIndex = param1;
            this.selectedIndexChanged = true;
            invalidateProperties();
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
         }
      }
      
      public function get toggleOnClick() : Boolean
      {
         return this._toggleOnClick;
      }
      
      public function set toggleOnClick(param1:Boolean) : void
      {
         this._toggleOnClick = param1;
      }
      
      override protected function commitProperties() : void
      {
         super.commitProperties();
         if(this.selectedIndexChanged)
         {
            this.hiliteSelectedNavItem(this._selectedIndex);
            super.selectedIndex = this._selectedIndex;
            this.selectedIndexChanged = false;
         }
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:int = 0;
         super.updateDisplayList(param1,param2);
         if(this.initializeSelectedButton)
         {
            this.initializeSelectedButton = false;
            _loc3_ = this._selectedIndex;
            if(_loc3_ == -2)
            {
               if(numChildren > 0)
               {
                  _loc3_ = 0;
               }
               else
               {
                  _loc3_ = -1;
               }
            }
            this.hiliteSelectedNavItem(_loc3_);
         }
      }
      
      override public function styleChanged(param1:String) : void
      {
         var _loc3_:Button = null;
         var _loc4_:String = null;
         var _loc2_:Boolean = param1 == null || param1 == "styleName";
         super.styleChanged(param1);
         if(_loc2_ || param1 == this.selectedButtonTextStyleNameProp)
         {
            if(this.selectedIndex != -1 && this.selectedIndex < numChildren)
            {
               _loc3_ = Button(getChildAt(this.selectedIndex));
               if(_loc3_)
               {
                  _loc4_ = getStyle(this.selectedButtonTextStyleNameProp);
                  _loc3_.getTextField().styleName = !!_loc4_ ? _loc4_ : "activeButtonStyle";
               }
            }
         }
      }
      
      override protected function createNavItem(param1:String, param2:Class = null) : IFlexDisplayObject
      {
         var _loc3_:Button = Button(super.createNavItem(param1,param2));
         _loc3_.toggle = true;
         return _loc3_;
      }
      
      override protected function hiliteSelectedNavItem(param1:int) : void
      {
         var _loc2_:Button = null;
         var _loc3_:String = null;
         if(this.selectedIndex != -1 && this.selectedIndex < numChildren)
         {
            _loc2_ = Button(getChildAt(this.selectedIndex));
            _loc2_.selected = false;
            _loc2_.getTextField().styleName = _loc2_;
            _loc2_.invalidateDisplayList();
            _loc2_.invalidateSize();
         }
         super.selectedIndex = param1;
         this._selectedIndex = param1;
         if(param1 > -1)
         {
            _loc2_ = Button(getChildAt(this.selectedIndex));
            _loc2_.selected = true;
            _loc3_ = getStyle(this.selectedButtonTextStyleNameProp);
            _loc2_.getTextField().styleName = !!_loc3_ ? _loc3_ : "activeButtonStyle";
            _loc2_.invalidateDisplayList();
         }
      }
      
      override protected function resetNavItems() : void
      {
         var _loc4_:Button = null;
         var _loc1_:String = getStyle(this.selectedButtonTextStyleNameProp);
         var _loc2_:int = numChildren;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = Button(getChildAt(_loc3_));
            if(_loc3_ == this.selectedIndex)
            {
               _loc4_.selected = true;
               _loc4_.getTextField().styleName = !!_loc1_ ? _loc1_ : "activeButtonStyle";
            }
            else
            {
               _loc4_.selected = false;
               _loc4_.getTextField().styleName = _loc4_;
            }
            _loc3_++;
         }
         super.resetNavItems();
      }
      
      mx_internal function selectButton(param1:int, param2:Boolean = false, param3:Event = null) : void
      {
         this._selectedIndex = param1;
         if(param2)
         {
            drawButtonFocus(mx_internal::focusedIndex,false);
            focusedIndex = param1;
            drawButtonFocus(mx_internal::focusedIndex,false);
         }
         var _loc4_:Button = Button(getChildAt(param1));
         simulatedClickTriggerEvent = param3;
         _loc4_.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
         simulatedClickTriggerEvent = null;
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         var _loc2_:int = -1;
         var _loc3_:Boolean = true;
         var _loc4_:int = numChildren;
         switch(param1.keyCode)
         {
            case Keyboard.PAGE_DOWN:
               _loc2_ = nextIndex(this.selectedIndex);
               break;
            case Keyboard.PAGE_UP:
               if(this.selectedIndex != -1)
               {
                  _loc2_ = prevIndex(this.selectedIndex);
               }
               else if(_loc4_ > 0)
               {
                  _loc2_ = 0;
               }
               break;
            case Keyboard.HOME:
               if(_loc4_ > 0)
               {
                  _loc2_ = 0;
               }
               break;
            case Keyboard.END:
               if(_loc4_ > 0)
               {
                  _loc2_ = _loc4_ - 1;
               }
               break;
            case Keyboard.SPACE:
            case Keyboard.ENTER:
               if(mx_internal::focusedIndex != -1)
               {
                  _loc2_ = mx_internal::focusedIndex;
                  _loc3_ = false;
               }
               break;
            default:
               super.keyDownHandler(param1);
         }
         if(_loc2_ != -1)
         {
            this.selectButton(_loc2_,_loc3_,param1);
         }
         param1.stopPropagation();
      }
      
      override protected function keyUpHandler(param1:KeyboardEvent) : void
      {
      }
      
      override protected function clickHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = getChildIndex(Button(param1.currentTarget));
         this._selectedIndex = _loc2_;
         if(this._toggleOnClick && _loc2_ == this.selectedIndex)
         {
            this.selectedIndex = -1;
            this.hiliteSelectedNavItem(-1);
         }
         else
         {
            this.hiliteSelectedNavItem(_loc2_);
         }
         super.clickHandler(param1);
      }
   }
}
