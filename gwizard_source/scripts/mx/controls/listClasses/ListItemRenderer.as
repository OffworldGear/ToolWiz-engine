package mx.controls.listClasses
{
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import mx.core.IDataRenderer;
   import mx.core.IFlexDisplayObject;
   import mx.core.IFlexModuleFactory;
   import mx.core.IFontContextComponent;
   import mx.core.IToolTip;
   import mx.core.IUITextField;
   import mx.core.UIComponent;
   import mx.core.UITextField;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.ToolTipEvent;
   import mx.utils.PopUpUtil;
   
   use namespace mx_internal;
   
   public class ListItemRenderer extends UIComponent implements IDataRenderer, IDropInListItemRenderer, IListItemRenderer, IFontContextComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var listOwner:ListBase;
      
      private var _data:Object;
      
      protected var icon:IFlexDisplayObject;
      
      protected var label:IUITextField;
      
      private var _listData:ListData;
      
      public function ListItemRenderer()
      {
         super();
         addEventListener(ToolTipEvent.TOOL_TIP_SHOW,this.toolTipShowHandler);
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
      
      override protected function createChildren() : void
      {
         super.createChildren();
         if(!this.label)
         {
            this.label = IUITextField(createInFontContext(UITextField));
            this.label.styleName = this;
            addChild(DisplayObject(this.label));
         }
      }
      
      override protected function commitProperties() : void
      {
         var _loc2_:Class = null;
         super.commitProperties();
         var _loc1_:int = -1;
         if(hasFontContextChanged() && this.label != null)
         {
            _loc1_ = getChildIndex(DisplayObject(this.label));
            removeChild(DisplayObject(this.label));
            this.label = null;
         }
         if(!this.label)
         {
            this.label = IUITextField(createInFontContext(UITextField));
            this.label.styleName = this;
            if(_loc1_ == -1)
            {
               addChild(DisplayObject(this.label));
            }
            else
            {
               addChildAt(DisplayObject(this.label),_loc1_);
            }
         }
         if(this.icon)
         {
            removeChild(DisplayObject(this.icon));
            this.icon = null;
         }
         if(this._data != null)
         {
            this.listOwner = ListBase(this._listData.owner);
            if(this._listData.icon)
            {
               _loc2_ = this._listData.icon;
               this.icon = new _loc2_();
               addChild(DisplayObject(this.icon));
            }
            this.label.text = !!this._listData.label ? this._listData.label : " ";
            this.label.multiline = this.listOwner.variableRowHeight;
            this.label.wordWrap = this.listOwner.wordWrap;
            if(this.listOwner.showDataTips)
            {
               if(this.label.textWidth > this.label.width || this.listOwner.dataTipFunction != null)
               {
                  toolTip = this.listOwner.itemToDataTip(this._data);
               }
               else
               {
                  toolTip = null;
               }
            }
            else
            {
               toolTip = null;
            }
         }
         else
         {
            this.label.text = " ";
            toolTip = null;
         }
      }
      
      override protected function measure() : void
      {
         super.measure();
         var _loc1_:Number = 0;
         if(this.icon)
         {
            _loc1_ = this.icon.measuredWidth;
         }
         if(this.label.width < 4 || this.label.height < 4)
         {
            this.label.width = 4;
            this.label.height = 16;
         }
         if(isNaN(explicitWidth))
         {
            _loc1_ += this.label.getExplicitOrMeasuredWidth();
            measuredWidth = _loc1_;
            measuredHeight = this.label.getExplicitOrMeasuredHeight();
         }
         else
         {
            measuredWidth = explicitWidth;
            this.label.setActualSize(Math.max(explicitWidth - _loc1_,4),this.label.height);
            measuredHeight = this.label.getExplicitOrMeasuredHeight();
            if(this.icon && this.icon.measuredHeight > measuredHeight)
            {
               measuredHeight = this.icon.measuredHeight;
            }
         }
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc5_:Number = NaN;
         super.updateDisplayList(param1,param2);
         var _loc3_:Number = 0;
         if(this.icon)
         {
            this.icon.x = _loc3_;
            _loc3_ = this.icon.x + this.icon.measuredWidth;
            this.icon.setActualSize(this.icon.measuredWidth,this.icon.measuredHeight);
         }
         this.label.x = _loc3_;
         this.label.setActualSize(param1 - _loc3_,measuredHeight);
         var _loc4_:String;
         if((_loc4_ = getStyle("verticalAlign")) == "top")
         {
            this.label.y = 0;
            if(this.icon)
            {
               this.icon.y = 0;
            }
         }
         else if(_loc4_ == "bottom")
         {
            this.label.y = param2 - this.label.height + 2;
            if(this.icon)
            {
               this.icon.y = param2 - this.icon.height;
            }
         }
         else
         {
            this.label.y = (param2 - this.label.height) / 2;
            if(this.icon)
            {
               this.icon.y = (param2 - this.icon.height) / 2;
            }
         }
         if(this.data && parent)
         {
            if(!enabled)
            {
               _loc5_ = getStyle("disabledColor");
            }
            else if(this.listOwner.isItemHighlighted(this.listData.uid))
            {
               _loc5_ = getStyle("textRollOverColor");
            }
            else if(this.listOwner.isItemSelected(this.listData.uid))
            {
               _loc5_ = getStyle("textSelectedColor");
            }
            else
            {
               _loc5_ = getStyle("color");
            }
            this.label.setColor(_loc5_);
         }
      }
      
      protected function toolTipShowHandler(param1:ToolTipEvent) : void
      {
         var _loc2_:IToolTip = param1.toolTip;
         var _loc3_:Point = PopUpUtil.positionOverComponent(DisplayObject(this.label),systemManager,_loc2_.width,_loc2_.height,height / 2);
         _loc2_.move(_loc3_.x,_loc3_.y);
      }
      
      mx_internal function getLabel() : IUITextField
      {
         return this.label;
      }
   }
}
