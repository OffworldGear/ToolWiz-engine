package mx.controls.menuClasses
{
   import flash.display.DisplayObject;
   import mx.controls.MenuBar;
   import mx.core.IFlexDisplayObject;
   import mx.core.IFlexModuleFactory;
   import mx.core.IFontContextComponent;
   import mx.core.IProgrammaticSkin;
   import mx.core.IStateClient;
   import mx.core.IUITextField;
   import mx.core.UIComponent;
   import mx.core.UITextField;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.styles.CSSStyleDeclaration;
   import mx.styles.ISimpleStyleClient;
   
   use namespace mx_internal;
   
   public class MenuBarItem extends UIComponent implements IMenuBarItemRenderer, IFontContextComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var leftMargin:int = 20;
      
      mx_internal var currentSkin:IFlexDisplayObject;
      
      protected var icon:IFlexDisplayObject;
      
      protected var label:IUITextField;
      
      mx_internal var skinName:String = "itemSkin";
      
      private var defaultSkinUsesStates:Boolean = false;
      
      private var checkedDefaultSkin:Boolean = false;
      
      private var enabledChanged:Boolean = false;
      
      private var _data:Object;
      
      private var _menuBar:MenuBar;
      
      private var _menuBarItemIndex:int = -1;
      
      private var _menuBarItemState:String;
      
      private var _dataProvider:Object;
      
      public function MenuBarItem()
      {
         super();
         mouseChildren = false;
      }
      
      override public function get baselinePosition() : Number
      {
         if(!validateBaselinePosition())
         {
            return NaN;
         }
         return this.label.y + this.label.baselinePosition;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         if(super.enabled == param1)
         {
            return;
         }
         super.enabled = param1;
         this.enabledChanged = true;
         invalidateProperties();
      }
      
      [Bindable("dataChange")]
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
         invalidateProperties();
         dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
      }
      
      public function get fontContext() : IFlexModuleFactory
      {
         return moduleFactory;
      }
      
      public function set fontContext(param1:IFlexModuleFactory) : void
      {
         this.moduleFactory = param1;
      }
      
      public function get menuBar() : MenuBar
      {
         return this._menuBar;
      }
      
      public function set menuBar(param1:MenuBar) : void
      {
         this._menuBar = param1;
      }
      
      public function get menuBarItemIndex() : int
      {
         return this._menuBarItemIndex;
      }
      
      public function set menuBarItemIndex(param1:int) : void
      {
         this._menuBarItemIndex = param1;
      }
      
      public function get menuBarItemState() : String
      {
         return this._menuBarItemState;
      }
      
      public function set menuBarItemState(param1:String) : void
      {
         this._menuBarItemState = param1;
         this.viewSkin(this._menuBarItemState);
      }
      
      public function get dataProvider() : Object
      {
         return this._dataProvider;
      }
      
      public function set dataProvider(param1:Object) : void
      {
         this._dataProvider = param1;
         invalidateProperties();
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         var styleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration(null,styleManager);
         styleDeclaration.factory = function():void
         {
            this.borderStyle = "none";
         };
         this.createLabel(-1);
      }
      
      override protected function commitProperties() : void
      {
         var _loc1_:Class = null;
         var _loc2_:int = 0;
         var _loc3_:String = null;
         super.commitProperties();
         if(hasFontContextChanged() && this.label != null)
         {
            _loc2_ = getChildIndex(DisplayObject(this.label));
            this.removeLabel();
            this.createLabel(_loc2_);
         }
         if(this.enabledChanged)
         {
            this.enabledChanged = false;
            if(this.label)
            {
               this.label.enabled = enabled;
            }
            if(!enabled)
            {
               this.menuBarItemState = "itemUpSkin";
            }
         }
         if(this.icon)
         {
            removeChild(DisplayObject(this.icon));
            this.icon = null;
         }
         if(this._data)
         {
            _loc1_ = this.menuBar.itemToIcon(this.data);
            if(_loc1_)
            {
               this.icon = new _loc1_();
               addChild(DisplayObject(this.icon));
            }
            this.label.visible = true;
            if(this.menuBar.labelFunction != null)
            {
               _loc3_ = this.menuBar.labelFunction(this._data);
            }
            if(_loc3_ == null)
            {
               _loc3_ = this.menuBar.itemToLabel(this._data);
            }
            this.label.text = _loc3_;
            this.label.enabled = enabled;
         }
         else
         {
            this.label.text = " ";
         }
         invalidateDisplayList();
      }
      
      override protected function measure() : void
      {
         super.measure();
         if(this.icon && this.leftMargin < this.icon.measuredWidth)
         {
            this.leftMargin = this.icon.measuredWidth;
         }
         measuredWidth = this.label.getExplicitOrMeasuredWidth() + this.leftMargin;
         measuredHeight = this.label.getExplicitOrMeasuredHeight();
         if(this.icon && this.icon.measuredHeight > measuredHeight)
         {
            measuredHeight = this.icon.measuredHeight + 2;
         }
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         if(this.icon)
         {
            this.icon.x = (this.leftMargin - this.icon.measuredWidth) / 2;
            this.icon.setActualSize(this.icon.measuredWidth,this.icon.measuredHeight);
            this.label.x = this.leftMargin;
         }
         else
         {
            this.label.x = this.leftMargin / 2;
         }
         this.label.setActualSize(param1 - this.leftMargin,this.label.getExplicitOrMeasuredHeight());
         this.label.y = (param2 - this.label.height) / 2;
         if(this.icon)
         {
            this.icon.y = (param2 - this.icon.height) / 2;
         }
         this.menuBarItemState = "itemUpSkin";
      }
      
      mx_internal function createLabel(param1:int) : void
      {
         if(!this.label)
         {
            this.label = IUITextField(createInFontContext(UITextField));
            this.label.styleName = this;
            this.label.selectable = false;
            if(param1 == -1)
            {
               addChild(DisplayObject(this.label));
            }
            else
            {
               addChildAt(DisplayObject(this.label),param1);
            }
         }
      }
      
      mx_internal function removeLabel() : void
      {
         if(this.label)
         {
            removeChild(DisplayObject(this.label));
            this.label = null;
         }
      }
      
      private function viewSkin(param1:String) : void
      {
         var _loc3_:IFlexDisplayObject = null;
         var _loc2_:Class = Class(getStyle(param1));
         var _loc4_:String = "";
         if(!_loc2_)
         {
            _loc2_ = Class(getStyle(this.skinName));
            if(param1 == "itemDownSkin")
            {
               _loc4_ = "down";
            }
            else if(param1 == "itemOverSkin")
            {
               _loc4_ = "over";
            }
            else if(param1 == "itemUpSkin")
            {
               _loc4_ = "up";
            }
            if(this.defaultSkinUsesStates)
            {
               param1 = this.skinName;
            }
            if(!this.checkedDefaultSkin && _loc2_)
            {
               _loc3_ = IFlexDisplayObject(new _loc2_());
               if(!(_loc3_ is IProgrammaticSkin) && _loc3_ is IStateClient)
               {
                  this.defaultSkinUsesStates = true;
                  param1 = this.skinName;
               }
               if(_loc3_)
               {
                  this.checkedDefaultSkin = true;
               }
            }
         }
         _loc3_ = IFlexDisplayObject(getChildByName(param1));
         if(!_loc3_)
         {
            if(_loc2_)
            {
               _loc3_ = new _loc2_();
               DisplayObject(_loc3_).name = param1;
               if(_loc3_ is ISimpleStyleClient)
               {
                  ISimpleStyleClient(_loc3_).styleName = this;
               }
               addChildAt(DisplayObject(_loc3_),0);
            }
         }
         _loc3_.setActualSize(unscaledWidth,unscaledHeight);
         if(this.currentSkin)
         {
            this.currentSkin.visible = false;
         }
         if(_loc3_)
         {
            _loc3_.visible = true;
         }
         this.currentSkin = _loc3_;
         if(this.defaultSkinUsesStates && this.currentSkin is IStateClient)
         {
            IStateClient(this.currentSkin).currentState = _loc4_;
         }
      }
      
      mx_internal function getLabel() : IUITextField
      {
         return this.label;
      }
   }
}
