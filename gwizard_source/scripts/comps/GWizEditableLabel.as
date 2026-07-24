package comps
{
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Label;
   import spark.components.TextInput;
   
   public class GWizEditableLabel extends Label
   {
      
      private static const log:ILogger = Log.getLogger("GWizEditableLabel");
       
      
      private var _isLinkLabel:Boolean = false;
      
      private var _clickListener:Function;
      
      private var _mouseOverListener:Function;
      
      private var _mouseOutListener:Function;
      
      private var editableAuxValue:Boolean = false;
      
      private var _textInput:DisplayObject;
      
      private var _editable:Boolean = false;
      
      public function GWizEditableLabel()
      {
         super();
         this.setEditableAux();
      }
      
      override public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         super.addEventListener(param1,param2,param3,param4,param5);
         if(param1 == MouseEvent.CLICK)
         {
            this._clickListener = param2;
            if(this._isLinkLabel && this._clickListener && this._textInput)
            {
               TextInput(this._textInput).addEventListener(MouseEvent.CLICK,this._clickListener);
            }
         }
         if(param1 == MouseEvent.MOUSE_OVER)
         {
            this._mouseOverListener = param2;
            if(this._isLinkLabel && this._mouseOverListener && this._textInput)
            {
               TextInput(this._textInput).addEventListener(MouseEvent.MOUSE_OVER,this._mouseOverListener);
            }
         }
         if(param1 == MouseEvent.MOUSE_OUT)
         {
            this._mouseOutListener = param2;
            if(this._isLinkLabel && this._mouseOutListener && this._textInput)
            {
               TextInput(this._textInput).addEventListener(MouseEvent.MOUSE_OUT,this._mouseOutListener);
            }
         }
      }
      
      private function copyListeners() : void
      {
         if(this._isLinkLabel && this._clickListener && this._textInput)
         {
            TextInput(this._textInput).addEventListener(MouseEvent.CLICK,this._clickListener);
         }
         if(this._isLinkLabel && this._mouseOverListener && this._textInput)
         {
            TextInput(this._textInput).addEventListener(MouseEvent.MOUSE_OVER,this._mouseOverListener);
         }
         if(this._isLinkLabel && this._mouseOutListener && this._textInput)
         {
            TextInput(this._textInput).addEventListener(MouseEvent.MOUSE_OUT,this._mouseOutListener);
         }
      }
      
      public function isLinkLabel(param1:Boolean) : void
      {
         this._isLinkLabel = param1;
         if(this._isLinkLabel)
         {
            this.setStyle("textDecoration","underline");
         }
      }
      
      private function setEditableAux() : void
      {
         if(this.parent)
         {
            this.editable = this.editableAuxValue;
         }
         else
         {
            this.callLater(this.setEditableAux);
         }
      }
      
      public function set editable(param1:Boolean) : void
      {
         this._editable = param1;
         this.editableAuxValue = param1;
         this.updateDisplayList(unscaledWidth,unscaledHeight);
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:TextInput = null;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         super.updateDisplayList(param1,param2);
         if(this._textInput != null)
         {
            this.text = TextInput(this._textInput).text;
            Object(this.parent).removeElement(this._textInput);
            this._textInput = null;
         }
         if(this._editable)
         {
            _loc4_ = new TextInput();
            _loc5_ = this.getStyle("fontSize");
            _loc6_ = this.getStyle("fontWeight");
            _loc4_.setStyle("fontSize",_loc5_);
            _loc4_.setStyle("fontWeight",_loc6_);
            _loc4_.text = this.text;
            _loc3_ = this.parent.getChildIndex(this);
            this._textInput = Object(this.parent).addElementAt(_loc4_,_loc3_);
            this.copyListeners();
            TextInput(this._textInput).percentHeight = this.percentHeight;
            TextInput(this._textInput).percentWidth = this.percentWidth;
            this.includeInLayout = false;
            this.visible = false;
            this.callLater(_loc4_.setFocus);
         }
         else
         {
            this._textInput = null;
            this.includeInLayout = true;
            this.visible = true;
            this.setFocus();
         }
      }
   }
}
