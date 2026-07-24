package mx.containers.accordionClasses
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import mx.containers.Accordion;
   import mx.controls.Button;
   import mx.core.IDataRenderer;
   import mx.core.IFlexDisplayObject;
   import mx.core.mx_internal;
   import mx.styles.ISimpleStyleClient;
   
   use namespace mx_internal;
   
   public class AccordionHeader extends Button implements IDataRenderer
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      mx_internal static var createAccessibilityImplementation:Function;
       
      
      private var focusObj:DisplayObject;
      
      private var focusSkin:IFlexDisplayObject;
      
      private var _data:Object;
      
      public function AccordionHeader()
      {
         super();
         toggleChanged = false;
         mouseFocusEnabled = false;
         tabEnabled = false;
         tabFocusEnabled = false;
      }
      
      override public function get data() : Object
      {
         return this._data;
      }
      
      override public function set data(param1:Object) : void
      {
         this._data = param1;
      }
      
      override public function set selected(param1:Boolean) : void
      {
         _selected = param1;
         invalidateDisplayList();
      }
      
      override protected function initializeAccessibility() : void
      {
         if(AccordionHeader.createAccessibilityImplementation != null)
         {
            AccordionHeader.createAccessibilityImplementation(this);
         }
      }
      
      override public function drawFocus(param1:Boolean) : void
      {
         var _loc2_:Class = null;
         var _loc3_:ISimpleStyleClient = null;
         if(param1 && !mx_internal::isEffectStarted)
         {
            if(!this.focusObj)
            {
               _loc2_ = getStyle("focusSkin");
               this.focusObj = new _loc2_();
               _loc3_ = this.focusObj as ISimpleStyleClient;
               if(_loc3_)
               {
                  _loc3_.styleName = this;
               }
               addChild(this.focusObj);
               this.focusSkin = this.focusObj as IFlexDisplayObject;
            }
            if(this.focusSkin)
            {
               this.focusSkin.move(0,0);
               this.focusSkin.setActualSize(unscaledWidth,unscaledHeight);
            }
            this.focusObj.visible = true;
            dispatchEvent(new Event("focusDraw"));
         }
         else if(this.focusObj)
         {
            this.focusObj.visible = false;
         }
      }
      
      override mx_internal function layoutContents(param1:Number, param2:Number, param3:Boolean) : void
      {
         super.layoutContents(param1,param2,param3);
         if(this.focusObj)
         {
            setChildIndex(this.focusObj,numChildren - 1);
         }
      }
      
      override protected function rollOverHandler(param1:MouseEvent) : void
      {
         super.rollOverHandler(param1);
         var _loc2_:Accordion = Accordion(parent);
         if(_loc2_.enabled)
         {
            _loc2_.rawChildren.setChildIndex(this,_loc2_.rawChildren.numChildren - 1);
         }
      }
   }
}
