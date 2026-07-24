package mx.controls.menuClasses
{
   import flash.display.DisplayObject;
   import flash.utils.getDefinitionByName;
   import mx.controls.Menu;
   import mx.controls.listClasses.BaseListData;
   import mx.controls.listClasses.IDropInListItemRenderer;
   import mx.controls.listClasses.IListItemRenderer;
   import mx.controls.listClasses.ListData;
   import mx.core.IDataRenderer;
   import mx.core.IFlexDisplayObject;
   import mx.core.IFlexModuleFactory;
   import mx.core.IFontContextComponent;
   import mx.core.IUITextField;
   import mx.core.UIComponent;
   import mx.core.UITextField;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   
   use namespace mx_internal;
   
   public class MenuItemRenderer extends UIComponent implements IDataRenderer, IListItemRenderer, IMenuItemRenderer, IDropInListItemRenderer, IFontContextComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      protected var branchIcon:IFlexDisplayObject;
      
      private var _data:Object;
      
      private var _icon:IFlexDisplayObject;
      
      protected var label:IUITextField;
      
      private var _listData:ListData;
      
      private var _menu:Menu;
      
      protected var separatorIcon:IFlexDisplayObject;
      
      protected var typeIcon:IFlexDisplayObject;
      
      public function MenuItemRenderer()
      {
         super();
      }
      
      override public function get baselinePosition() : Number
      {
         if(!validateBaselinePosition())
         {
            return NaN;
         }
         return this.label.y + this.label.baselinePosition;
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
         invalidateSize();
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
      
      protected function get icon() : IFlexDisplayObject
      {
         return this._icon;
      }
      
      protected function set icon(param1:IFlexDisplayObject) : void
      {
         this._icon = param1;
      }
      
      [Bindable("dataChange")]
      public function get listData() : BaseListData
      {
         return this._listData;
      }
      
      public function set listData(param1:BaseListData) : void
      {
         this._listData = ListData(param1);
         invalidateProperties();
      }
      
      public function get menu() : Menu
      {
         return this._menu;
      }
      
      public function set menu(param1:Menu) : void
      {
         this._menu = param1;
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         this.createLabel(-1);
      }
      
      override protected function commitProperties() : void
      {
         var _loc1_:Class = null;
         var _loc2_:Class = null;
         var _loc3_:Class = null;
         var _loc4_:Class = null;
         var _loc5_:int = 0;
         var _loc6_:IMenuDataDescriptor = null;
         var _loc7_:Boolean = false;
         var _loc8_:String = null;
         var _loc9_:Object = null;
         var _loc10_:String = null;
         super.commitProperties();
         if(hasFontContextChanged() && this.label != null)
         {
            _loc5_ = getChildIndex(DisplayObject(this.label));
            this.removeLabel();
            this.createLabel(_loc5_);
         }
         if(this._icon)
         {
            removeChild(DisplayObject(this._icon));
            this._icon = null;
         }
         if(this.typeIcon)
         {
            removeChild(DisplayObject(this.typeIcon));
            this.typeIcon = null;
         }
         if(this.separatorIcon)
         {
            removeChild(DisplayObject(this.separatorIcon));
            this.separatorIcon = null;
         }
         if(this.branchIcon)
         {
            removeChild(DisplayObject(this.branchIcon));
            this.branchIcon = null;
         }
         if(this._data)
         {
            _loc7_ = (_loc6_ = Menu(this._listData.owner).dataDescriptor).isEnabled(this._data);
            if((_loc8_ = _loc6_.getType(this._data)).toLowerCase() == "separator")
            {
               this.label.text = "";
               this.label.visible = false;
               _loc3_ = getStyle("separatorSkin");
               this.separatorIcon = new _loc3_();
               addChild(DisplayObject(this.separatorIcon));
               return;
            }
            this.label.visible = true;
            if(this._listData.icon)
            {
               if((_loc9_ = this._listData.icon) is Class)
               {
                  _loc1_ = Class(_loc9_);
               }
               else if(_loc9_ is String)
               {
                  _loc1_ = Class(getDefinitionByName(String(_loc9_)));
               }
               this._icon = new _loc1_();
               addChild(DisplayObject(this._icon));
            }
            this.label.text = this._listData.label;
            this.label.enabled = _loc7_;
            if(_loc6_.isToggled(this._data))
            {
               if(_loc10_ = _loc6_.getType(this._data))
               {
                  if((_loc10_ = _loc10_.toLowerCase()) == "radio")
                  {
                     _loc2_ = getStyle(!!_loc7_ ? "radioIcon" : "radioDisabledIcon");
                  }
                  else if(_loc10_ == "check")
                  {
                     _loc2_ = getStyle(!!_loc7_ ? "checkIcon" : "checkDisabledIcon");
                  }
                  if(_loc2_)
                  {
                     this.typeIcon = new _loc2_();
                     addChild(DisplayObject(this.typeIcon));
                  }
               }
            }
            if(_loc6_.isBranch(this._data))
            {
               if(_loc4_ = getStyle(!!_loc7_ ? "branchIcon" : "branchDisabledIcon"))
               {
                  this.branchIcon = new _loc4_();
                  addChild(DisplayObject(this.branchIcon));
               }
            }
         }
         else
         {
            this.label.text = " ";
         }
         invalidateDisplayList();
      }
      
      override protected function measure() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Boolean = false;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         super.measure();
         if(this.separatorIcon)
         {
            measuredWidth = this.separatorIcon.measuredWidth;
            measuredHeight = this.separatorIcon.measuredHeight;
            return;
         }
         if(this._listData)
         {
            _loc1_ = MenuListData(this._listData).maxMeasuredIconWidth;
            _loc2_ = MenuListData(this._listData).maxMeasuredTypeIconWidth;
            _loc3_ = MenuListData(this._listData).maxMeasuredBranchIconWidth;
            _loc4_ = MenuListData(this._listData).useTwoColumns;
            _loc5_ = Math.max(getStyle("leftIconGap"),!!_loc4_ ? Number(_loc1_ + _loc2_) : Number(Math.max(_loc1_,_loc2_)));
            _loc6_ = Math.max(getStyle("rightIconGap"),_loc3_);
            if(isNaN(explicitWidth))
            {
               measuredWidth = this.label.measuredWidth + _loc5_ + _loc6_ + 7;
            }
            else
            {
               this.label.width = explicitWidth - _loc5_ - _loc6_;
            }
            measuredHeight = this.label.measuredHeight;
            if(this._icon && this._icon.measuredHeight > measuredHeight)
            {
               measuredHeight = this._icon.measuredHeight;
            }
            if(this.typeIcon && this.typeIcon.measuredHeight > measuredHeight)
            {
               measuredHeight = this.typeIcon.measuredHeight;
            }
            if(this.branchIcon && this.branchIcon.measuredHeight > measuredHeight)
            {
               measuredHeight = this.branchIcon.measuredHeight;
            }
         }
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Boolean = false;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:String = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         super.updateDisplayList(param1,param2);
         if(this._listData)
         {
            if(Menu(this._listData.owner).dataDescriptor.getType(this._data).toLowerCase() == "separator")
            {
               if(this.separatorIcon)
               {
                  this.separatorIcon.x = 2;
                  this.separatorIcon.y = (param2 - this.separatorIcon.measuredHeight) / 2;
                  this.separatorIcon.setActualSize(param1 - 4,this.separatorIcon.measuredHeight);
               }
               return;
            }
            _loc3_ = MenuListData(this._listData).maxMeasuredIconWidth;
            _loc4_ = MenuListData(this._listData).maxMeasuredTypeIconWidth;
            _loc5_ = MenuListData(this._listData).maxMeasuredBranchIconWidth;
            _loc6_ = MenuListData(this._listData).useTwoColumns;
            _loc7_ = Math.max(getStyle("leftIconGap"),!!_loc6_ ? Number(_loc3_ + _loc4_) : Number(Math.max(_loc3_,_loc4_)));
            _loc8_ = Math.max(getStyle("rightIconGap"),_loc5_);
            if(_loc6_)
            {
               _loc11_ = (_loc7_ - (_loc3_ + _loc4_)) / 2;
               if(this._icon)
               {
                  this._icon.x = _loc11_ + (_loc3_ - this._icon.measuredWidth) / 2;
                  this._icon.setActualSize(this._icon.measuredWidth,this._icon.measuredHeight);
               }
               if(this.typeIcon)
               {
                  this.typeIcon.x = _loc11_ + _loc3_ + (_loc4_ - this.typeIcon.measuredWidth) / 2;
                  this.typeIcon.setActualSize(this.typeIcon.measuredWidth,this.typeIcon.measuredHeight);
               }
            }
            else
            {
               if(this._icon)
               {
                  this._icon.x = (_loc7_ - this._icon.measuredWidth) / 2;
                  this._icon.setActualSize(this._icon.measuredWidth,this._icon.measuredHeight);
               }
               if(this.typeIcon)
               {
                  this.typeIcon.x = (_loc7_ - this.typeIcon.measuredWidth) / 2;
                  this.typeIcon.setActualSize(this.typeIcon.measuredWidth,this.typeIcon.measuredHeight);
               }
            }
            if(this.branchIcon)
            {
               this.branchIcon.x = param1 - _loc8_ + (_loc8_ - this.branchIcon.measuredWidth) / 2;
               this.branchIcon.setActualSize(this.branchIcon.measuredWidth,this.branchIcon.measuredHeight);
            }
            this.label.x = _loc7_;
            this.label.setActualSize(param1 - _loc7_ - _loc8_,this.label.getExplicitOrMeasuredHeight());
            if(this._listData && !Menu(this._listData.owner).showDataTips)
            {
               this.label.text = this._listData.label;
               if(this.label.truncateToFit())
               {
                  toolTip = this._listData.label;
               }
               else
               {
                  toolTip = null;
               }
            }
            if((_loc9_ = getStyle("verticalAlign")) == "top")
            {
               this.label.y = 0;
               if(this._icon)
               {
                  this._icon.y = 0;
               }
               if(this.typeIcon)
               {
                  this.typeIcon.y = 0;
               }
               if(this.branchIcon)
               {
                  this.branchIcon.y = 0;
               }
            }
            else if(_loc9_ == "bottom")
            {
               this.label.y = param2 - this.label.height + 2;
               if(this._icon)
               {
                  this._icon.y = param2 - this._icon.height;
               }
               if(this.typeIcon)
               {
                  this.typeIcon.y = param2 - this.typeIcon.height;
               }
               if(this.branchIcon)
               {
                  this.branchIcon.y = param2 - this.branchIcon.height;
               }
            }
            else
            {
               this.label.y = (param2 - this.label.height) / 2;
               if(this._icon)
               {
                  this._icon.y = (param2 - this._icon.height) / 2;
               }
               if(this.typeIcon)
               {
                  this.typeIcon.y = (param2 - this.typeIcon.height) / 2;
               }
               if(this.branchIcon)
               {
                  this.branchIcon.y = (param2 - this.branchIcon.height) / 2;
               }
            }
            if(this.data && parent)
            {
               if(!enabled)
               {
                  _loc10_ = getStyle("disabledColor");
               }
               else if(Menu(this.listData.owner).isItemHighlighted(this.listData.uid))
               {
                  _loc10_ = getStyle("textRollOverColor");
               }
               else if(Menu(this.listData.owner).isItemSelected(this.listData.uid))
               {
                  _loc10_ = getStyle("textSelectedColor");
               }
               else
               {
                  _loc10_ = getStyle("color");
               }
               this.label.setColor(_loc10_);
            }
         }
      }
      
      override public function styleChanged(param1:String) : void
      {
         super.styleChanged(param1);
         if(!param1 || param1 == "styleName" || param1.toLowerCase().indexOf("icon") != -1)
         {
            invalidateSize();
            invalidateDisplayList();
         }
      }
      
      mx_internal function createLabel(param1:int) : void
      {
         if(!this.label)
         {
            this.label = IUITextField(createInFontContext(UITextField));
            this.label.styleName = this;
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
      
      mx_internal function getLabel() : IUITextField
      {
         return this.label;
      }
      
      public function get measuredIconWidth() : Number
      {
         var _loc1_:Number = getStyle("horizontalGap");
         return !!this._icon ? Number(this._icon.measuredWidth + _loc1_) : Number(0);
      }
      
      public function get measuredTypeIconWidth() : Number
      {
         var _loc2_:Class = null;
         var _loc3_:IMenuDataDescriptor = null;
         var _loc4_:Boolean = false;
         var _loc5_:String = null;
         var _loc6_:Number = NaN;
         var _loc1_:Number = getStyle("horizontalGap");
         if(this.typeIcon)
         {
            return this.typeIcon.measuredWidth + _loc1_;
         }
         if(this._data)
         {
            _loc3_ = Menu(this._listData.owner).dataDescriptor;
            _loc4_ = _loc3_.isEnabled(this._data);
            if(_loc5_ = _loc3_.getType(this._data))
            {
               if((_loc5_ = _loc5_.toLowerCase()) == "radio")
               {
                  _loc2_ = getStyle(!!_loc4_ ? "radioIcon" : "radioDisabledIcon");
               }
               else if(_loc5_ == "check")
               {
                  _loc2_ = getStyle(!!_loc4_ ? "checkIcon" : "checkDisabledIcon");
               }
               if(_loc2_)
               {
                  this.typeIcon = new _loc2_();
                  _loc6_ = this.typeIcon.measuredWidth;
                  this.typeIcon = null;
                  return _loc6_ + _loc1_;
               }
            }
         }
         return 0;
      }
      
      public function get measuredBranchIconWidth() : Number
      {
         var _loc1_:Number = getStyle("horizontalGap");
         return !!this.branchIcon ? Number(this.branchIcon.measuredWidth + _loc1_) : Number(0);
      }
   }
}
