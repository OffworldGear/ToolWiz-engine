package mx.controls
{
   import flash.accessibility.AccessibilityProperties;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.TextEvent;
   import flash.system.IME;
   import flash.system.IMEConversionMode;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.text.TextLineMetrics;
   import flash.ui.Keyboard;
   import mx.controls.listClasses.BaseListData;
   import mx.core.EdgeMetrics;
   import mx.core.IFlexDisplayObject;
   import mx.core.IFlexModuleFactory;
   import mx.core.IInvalidating;
   import mx.core.IRectangularBorder;
   import mx.core.ITextInput;
   import mx.core.IUITextField;
   import mx.core.UIComponent;
   import mx.core.UITextField;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.managers.IFocusManager;
   import mx.managers.IFocusManagerComponent;
   import mx.styles.ISimpleStyleClient;
   
   use namespace mx_internal;
   
   public class TextInput extends UIComponent implements ITextInput
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      mx_internal var border:IFlexDisplayObject;
      
      private var textSet:Boolean;
      
      private var selectionChanged:Boolean = false;
      
      private var errorCaught:Boolean = false;
      
      private var _accessibilityProperties:AccessibilityProperties;
      
      private var accessibilityPropertiesChanged:Boolean = false;
      
      private var enabledChanged:Boolean = false;
      
      private var _tabIndex:int = -1;
      
      private var tabIndexChanged:Boolean = false;
      
      private var _condenseWhite:Boolean = false;
      
      private var condenseWhiteChanged:Boolean = false;
      
      private var _data:Object;
      
      private var _displayAsPassword:Boolean = false;
      
      private var displayAsPasswordChanged:Boolean = false;
      
      private var _editable:Boolean = true;
      
      private var editableChanged:Boolean = false;
      
      private var _horizontalScrollPosition:Number = 0;
      
      private var horizontalScrollPositionChanged:Boolean = false;
      
      private var _htmlText:String = "";
      
      private var htmlTextChanged:Boolean = false;
      
      private var explicitHTMLText:String = null;
      
      private var _imeMode:String = null;
      
      private var _listData:BaseListData;
      
      private var _maxChars:int = 0;
      
      private var maxCharsChanged:Boolean = false;
      
      private var _parentDrawsFocus:Boolean = false;
      
      private var _restrict:String;
      
      private var restrictChanged:Boolean = false;
      
      private var _selectable:Boolean = true;
      
      private var selectableChanged:Boolean = false;
      
      private var _selectionBeginIndex:int = 0;
      
      private var _selectionEndIndex:int = 0;
      
      private var _text:String = "";
      
      private var textChanged:Boolean = false;
      
      protected var textField:IUITextField;
      
      private var _textHeight:Number;
      
      private var _textWidth:Number;
      
      public function TextInput()
      {
         super();
      }
      
      override public function get accessibilityProperties() : AccessibilityProperties
      {
         return this._accessibilityProperties;
      }
      
      override public function set accessibilityProperties(param1:AccessibilityProperties) : void
      {
         if(param1 == this._accessibilityProperties)
         {
            return;
         }
         this._accessibilityProperties = param1;
         this.accessibilityPropertiesChanged = true;
         invalidateProperties();
      }
      
      override public function get baselinePosition() : Number
      {
         if(!validateBaselinePosition())
         {
            return NaN;
         }
         return this.textField.y + this.textField.baselinePosition;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         if(param1 == enabled)
         {
            return;
         }
         super.enabled = param1;
         this.enabledChanged = true;
         invalidateProperties();
         if(this.border && this.border is IInvalidating)
         {
            IInvalidating(this.border).invalidateDisplayList();
         }
      }
      
      public function get fontContext() : IFlexModuleFactory
      {
         return moduleFactory;
      }
      
      public function set fontContext(param1:IFlexModuleFactory) : void
      {
         this.moduleFactory = param1;
      }
      
      override public function get tabIndex() : int
      {
         return this._tabIndex;
      }
      
      override public function set tabIndex(param1:int) : void
      {
         if(param1 == this._tabIndex)
         {
            return;
         }
         this._tabIndex = param1;
         this.tabIndexChanged = true;
         invalidateProperties();
      }
      
      [Bindable("condenseWhiteChanged")]
      public function get condenseWhite() : Boolean
      {
         return this._condenseWhite;
      }
      
      public function set condenseWhite(param1:Boolean) : void
      {
         if(param1 == this._condenseWhite)
         {
            return;
         }
         this._condenseWhite = param1;
         this.condenseWhiteChanged = true;
         if(this.isHTML)
         {
            this.htmlTextChanged = true;
         }
         invalidateProperties();
         invalidateSize();
         invalidateDisplayList();
         dispatchEvent(new Event("condenseWhiteChanged"));
      }
      
      [Bindable("dataChange")]
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         var _loc2_:* = undefined;
         this._data = param1;
         if(this._listData)
         {
            _loc2_ = this._listData.label;
         }
         else if(this._data != null)
         {
            if(this._data is String)
            {
               _loc2_ = String(this._data);
            }
            else
            {
               _loc2_ = this._data.toString();
            }
         }
         if(_loc2_ !== undefined && !this.textSet)
         {
            this.text = _loc2_;
            this.textSet = false;
            this.textField.setSelection(0,0);
         }
         dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
      }
      
      [Bindable("displayAsPasswordChanged")]
      public function get displayAsPassword() : Boolean
      {
         return this._displayAsPassword;
      }
      
      public function set displayAsPassword(param1:Boolean) : void
      {
         if(param1 == this._displayAsPassword)
         {
            return;
         }
         this._displayAsPassword = param1;
         this.displayAsPasswordChanged = true;
         invalidateProperties();
         invalidateSize();
         invalidateDisplayList();
         dispatchEvent(new Event("displayAsPasswordChanged"));
      }
      
      [Bindable("editableChanged")]
      public function get editable() : Boolean
      {
         return this._editable;
      }
      
      public function set editable(param1:Boolean) : void
      {
         if(param1 == this._editable)
         {
            return;
         }
         this._editable = param1;
         this.editableChanged = true;
         invalidateProperties();
         dispatchEvent(new Event("editableChanged"));
      }
      
      public function get enableIME() : Boolean
      {
         return this.editable;
      }
      
      [Bindable("horizontalScrollPositionChanged")]
      public function get horizontalScrollPosition() : Number
      {
         return this._horizontalScrollPosition;
      }
      
      public function set horizontalScrollPosition(param1:Number) : void
      {
         if(param1 == this._horizontalScrollPosition)
         {
            return;
         }
         this._horizontalScrollPosition = param1;
         this.horizontalScrollPositionChanged = true;
         invalidateProperties();
         dispatchEvent(new Event("horizontalScrollPositionChanged"));
      }
      
      [NonCommittingChangeEvent("change")]
      [Bindable("htmlTextChanged")]
      public function get htmlText() : String
      {
         return this._htmlText;
      }
      
      public function set htmlText(param1:String) : void
      {
         this.textSet = true;
         if(!param1)
         {
            param1 = "";
         }
         this._htmlText = param1;
         this.htmlTextChanged = true;
         this._text = null;
         this.explicitHTMLText = param1;
         invalidateProperties();
         invalidateSize();
         invalidateDisplayList();
         dispatchEvent(new Event("htmlTextChanged"));
      }
      
      public function get imeMode() : String
      {
         return this._imeMode;
      }
      
      public function set imeMode(param1:String) : void
      {
         this._imeMode = param1;
      }
      
      private function get isHTML() : Boolean
      {
         return this.explicitHTMLText != null;
      }
      
      public function get length() : int
      {
         return this.text != null ? int(this.text.length) : -1;
      }
      
      [Bindable("dataChange")]
      public function get listData() : BaseListData
      {
         return this._listData;
      }
      
      public function set listData(param1:BaseListData) : void
      {
         this._listData = param1;
      }
      
      [Bindable("maxCharsChanged")]
      public function get maxChars() : int
      {
         return this._maxChars;
      }
      
      public function set maxChars(param1:int) : void
      {
         if(param1 == this._maxChars)
         {
            return;
         }
         this._maxChars = param1;
         this.maxCharsChanged = true;
         invalidateProperties();
         dispatchEvent(new Event("maxCharsChanged"));
      }
      
      public function get maxHorizontalScrollPosition() : Number
      {
         return !!this.textField ? Number(this.textField.maxScrollH) : Number(0);
      }
      
      public function get parentDrawsFocus() : Boolean
      {
         return this._parentDrawsFocus;
      }
      
      public function set parentDrawsFocus(param1:Boolean) : void
      {
         this._parentDrawsFocus = param1;
      }
      
      [Bindable("restrictChanged")]
      public function get restrict() : String
      {
         return this._restrict;
      }
      
      public function set restrict(param1:String) : void
      {
         if(param1 == this._restrict)
         {
            return;
         }
         this._restrict = param1;
         this.restrictChanged = true;
         invalidateProperties();
         dispatchEvent(new Event("restrictChanged"));
      }
      
      public function get selectable() : Boolean
      {
         return this._selectable;
      }
      
      public function set selectable(param1:Boolean) : void
      {
         if(this._selectable == param1)
         {
            return;
         }
         this._selectable = param1;
         this.selectableChanged = true;
         invalidateProperties();
      }
      
      public function get selectionBeginIndex() : int
      {
         return !!this.textField ? int(this.textField.selectionBeginIndex) : int(this._selectionBeginIndex);
      }
      
      public function set selectionBeginIndex(param1:int) : void
      {
         this._selectionBeginIndex = param1;
         this.selectionChanged = true;
         invalidateProperties();
      }
      
      public function get selectionEndIndex() : int
      {
         return !!this.textField ? int(this.textField.selectionEndIndex) : int(this._selectionEndIndex);
      }
      
      public function set selectionEndIndex(param1:int) : void
      {
         this._selectionEndIndex = param1;
         this.selectionChanged = true;
         invalidateProperties();
      }
      
      [NonCommittingChangeEvent("change")]
      [Bindable("textChanged")]
      public function get text() : String
      {
         return this._text;
      }
      
      public function set text(param1:String) : void
      {
         this.textSet = true;
         if(!param1)
         {
            param1 = "";
         }
         if(!this.isHTML && param1 == this._text)
         {
            return;
         }
         this._text = param1;
         this.textChanged = true;
         this._htmlText = null;
         this.explicitHTMLText = null;
         invalidateProperties();
         invalidateSize();
         invalidateDisplayList();
         dispatchEvent(new Event("textChanged"));
         dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
      }
      
      public function get textHeight() : Number
      {
         return this._textHeight;
      }
      
      public function get textWidth() : Number
      {
         return this._textWidth;
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         this.createBorder();
         this.createTextField(-1);
      }
      
      override protected function commitProperties() : void
      {
         var _loc1_:int = 0;
         super.commitProperties();
         if(hasFontContextChanged() && this.textField != null)
         {
            _loc1_ = getChildIndex(DisplayObject(this.textField));
            this.removeTextField();
            this.createTextField(_loc1_);
            this.accessibilityPropertiesChanged = true;
            this.condenseWhiteChanged = true;
            this.displayAsPasswordChanged = true;
            this.enabledChanged = true;
            this.maxCharsChanged = true;
            this.restrictChanged = true;
            this.tabIndexChanged = true;
            this.textChanged = true;
            this.selectionChanged = true;
            this.horizontalScrollPositionChanged = true;
         }
         if(this.accessibilityPropertiesChanged)
         {
            this.textField.accessibilityProperties = this._accessibilityProperties;
            this.accessibilityPropertiesChanged = false;
         }
         if(this.condenseWhiteChanged)
         {
            this.textField.condenseWhite = this._condenseWhite;
            this.condenseWhiteChanged = false;
         }
         if(this.displayAsPasswordChanged)
         {
            this.textField.displayAsPassword = this._displayAsPassword;
            this.displayAsPasswordChanged = false;
         }
         if(this.enabledChanged || this.editableChanged)
         {
            this.textField.type = enabled && this._editable ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
            if(this.enabledChanged)
            {
               if(this.textField.enabled != enabled)
               {
                  this.textField.enabled = enabled;
               }
               this.enabledChanged = false;
            }
            this.selectableChanged = true;
            this.editableChanged = false;
         }
         if(this.selectableChanged)
         {
            if(this._editable)
            {
               this.textField.selectable = enabled;
            }
            else
            {
               this.textField.selectable = enabled && this._selectable;
            }
            this.selectableChanged = false;
         }
         if(this.maxCharsChanged)
         {
            this.textField.maxChars = this._maxChars;
            this.maxCharsChanged = false;
         }
         if(this.restrictChanged)
         {
            this.textField.restrict = this._restrict;
            this.restrictChanged = false;
         }
         if(this.tabIndexChanged)
         {
            this.textField.tabIndex = this._tabIndex;
            this.tabIndexChanged = false;
         }
         if(this.textChanged || this.htmlTextChanged)
         {
            if(this.isHTML)
            {
               this.textField.htmlText = this.explicitHTMLText;
            }
            else
            {
               this.textField.text = this._text;
            }
            this.textFieldChanged(false,true);
            this.textChanged = false;
            this.htmlTextChanged = false;
         }
         if(this.selectionChanged)
         {
            this.textField.setSelection(this._selectionBeginIndex,this._selectionEndIndex);
            this.selectionChanged = false;
         }
         if(this.horizontalScrollPositionChanged)
         {
            this.textField.scrollH = this._horizontalScrollPosition;
            this.horizontalScrollPositionChanged = false;
         }
      }
      
      override protected function measure() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:TextLineMetrics = null;
         super.measure();
         var _loc1_:EdgeMetrics = this.border && this.border is IRectangularBorder ? IRectangularBorder(this.border).borderMetrics : EdgeMetrics.EMPTY;
         measuredWidth = DEFAULT_MEASURED_WIDTH;
         if(this.maxChars)
         {
            measuredWidth = Math.min(measuredWidth,measureText("W").width * this.maxChars + _loc1_.left + _loc1_.right + 8);
         }
         if(!this.text || this.text == "")
         {
            _loc2_ = DEFAULT_MEASURED_MIN_WIDTH;
            _loc3_ = measureText(" ").height + _loc1_.top + _loc1_.bottom + UITextField.TEXT_HEIGHT_PADDING;
            _loc3_ += getStyle("paddingTop") + getStyle("paddingBottom");
         }
         else
         {
            _loc2_ = (_loc4_ = measureText(this.text)).width + _loc1_.left + _loc1_.right + 8;
            _loc3_ = _loc4_.height + _loc1_.top + _loc1_.bottom + UITextField.TEXT_HEIGHT_PADDING;
            _loc2_ += getStyle("paddingLeft") + getStyle("paddingRight");
            _loc3_ += getStyle("paddingTop") + getStyle("paddingBottom");
         }
         measuredWidth = Math.max(_loc2_,measuredWidth);
         measuredHeight = Math.max(_loc3_,DEFAULT_MEASURED_HEIGHT);
         measuredMinWidth = DEFAULT_MEASURED_MIN_WIDTH;
         measuredMinHeight = DEFAULT_MEASURED_MIN_HEIGHT;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:EdgeMetrics = null;
         super.updateDisplayList(param1,param2);
         if(this.border)
         {
            this.border.setActualSize(param1,param2);
            _loc3_ = this.border is IRectangularBorder ? IRectangularBorder(this.border).borderMetrics : EdgeMetrics.EMPTY;
         }
         else
         {
            _loc3_ = EdgeMetrics.EMPTY;
         }
         var _loc4_:Number = getStyle("paddingLeft");
         var _loc5_:Number = getStyle("paddingRight");
         var _loc6_:Number = getStyle("paddingTop");
         var _loc7_:Number = getStyle("paddingBottom");
         var _loc8_:Number = _loc3_.left + _loc3_.right;
         var _loc9_:Number = _loc3_.top + _loc3_.bottom + 1;
         this.textField.x = _loc3_.left;
         this.textField.y = _loc3_.top;
         this.textField.x += _loc4_;
         this.textField.y += _loc6_;
         _loc8_ += _loc4_ + _loc5_;
         _loc9_ += _loc6_ + _loc7_;
         this.textField.width = Math.max(0,param1 - _loc8_);
         this.textField.height = Math.max(0,param2 - _loc9_);
      }
      
      override public function setFocus() : void
      {
         this.textField.setFocus();
      }
      
      override protected function isOurFocus(param1:DisplayObject) : Boolean
      {
         return param1 == this.textField || super.isOurFocus(param1);
      }
      
      override public function drawFocus(param1:Boolean) : void
      {
         if(this._parentDrawsFocus)
         {
            IFocusManagerComponent(parent).drawFocus(param1);
            return;
         }
         super.drawFocus(param1);
      }
      
      override public function styleChanged(param1:String) : void
      {
         var _loc2_:Boolean = param1 == null || param1 == "styleName";
         super.styleChanged(param1);
         if(_loc2_ || param1 == "borderSkin")
         {
            if(this.border)
            {
               removeChild(DisplayObject(this.border));
               this.border = null;
               this.createBorder();
            }
         }
      }
      
      mx_internal function createTextField(param1:int) : void
      {
         if(!this.textField)
         {
            this.textField = IUITextField(createInFontContext(UITextField));
            this.textField.autoSize = TextFieldAutoSize.NONE;
            this.textField.enabled = enabled;
            this.textField.ignorePadding = false;
            this.textField.multiline = false;
            this.textField.tabEnabled = true;
            this.textField.wordWrap = false;
            this.textField.addEventListener(Event.CHANGE,this.textField_changeHandler);
            this.textField.addEventListener(TextEvent.TEXT_INPUT,this.textField_textInputHandler);
            this.textField.addEventListener(Event.SCROLL,this.textField_scrollHandler);
            this.textField.addEventListener("textFieldStyleChange",this.textField_textFieldStyleChangeHandler);
            this.textField.addEventListener("textFormatChange",this.textField_textFormatChangeHandler);
            this.textField.addEventListener("textInsert",this.textField_textModifiedHandler);
            this.textField.addEventListener("textReplace",this.textField_textModifiedHandler);
            this.textField.addEventListener("nativeDragDrop",this.textField_nativeDragDropHandler);
            if(param1 == -1)
            {
               addChild(DisplayObject(this.textField));
            }
            else
            {
               addChildAt(DisplayObject(this.textField),param1);
            }
         }
      }
      
      mx_internal function removeTextField() : void
      {
         if(this.textField)
         {
            this.textField.removeEventListener(Event.CHANGE,this.textField_changeHandler);
            this.textField.removeEventListener(TextEvent.TEXT_INPUT,this.textField_textInputHandler);
            this.textField.removeEventListener(Event.SCROLL,this.textField_scrollHandler);
            this.textField.removeEventListener("textFieldStyleChange",this.textField_textFieldStyleChangeHandler);
            this.textField.removeEventListener("textFormatChange",this.textField_textFormatChangeHandler);
            this.textField.removeEventListener("textInsert",this.textField_textModifiedHandler);
            this.textField.removeEventListener("textReplace",this.textField_textModifiedHandler);
            this.textField.removeEventListener("nativeDragDrop",this.textField_nativeDragDropHandler);
            removeChild(DisplayObject(this.textField));
            this.textField = null;
         }
      }
      
      protected function createBorder() : void
      {
         var _loc1_:Class = null;
         if(!this.border)
         {
            _loc1_ = getStyle("borderSkin");
            if(_loc1_ != null)
            {
               this.border = new _loc1_();
               if(this.border is ISimpleStyleClient)
               {
                  ISimpleStyleClient(this.border).styleName = this;
               }
               addChildAt(DisplayObject(this.border),0);
               invalidateDisplayList();
            }
         }
      }
      
      public function getLineMetrics(param1:int) : TextLineMetrics
      {
         return !!this.textField ? this.textField.getLineMetrics(param1) : null;
      }
      
      public function setSelection(param1:int, param2:int) : void
      {
         this._selectionBeginIndex = param1;
         this._selectionEndIndex = param2;
         this.selectionChanged = true;
         invalidateProperties();
      }
      
      private function textFieldChanged(param1:Boolean, param2:Boolean) : void
      {
         var _loc3_:* = false;
         var _loc4_:* = false;
         if(!param1)
         {
            _loc3_ = this._text != this.textField.text;
            this._text = this.textField.text;
         }
         _loc4_ = this._htmlText != this.textField.htmlText;
         this._htmlText = this.textField.htmlText;
         if(_loc3_)
         {
            dispatchEvent(new Event("textChanged"));
            if(param2)
            {
               dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            }
         }
         if(_loc4_)
         {
            dispatchEvent(new Event("htmlTextChanged"));
         }
         this._textWidth = this.textField.textWidth;
         this._textHeight = this.textField.textHeight;
      }
      
      mx_internal function getTextField() : IUITextField
      {
         return this.textField;
      }
      
      public function get selectionActivePosition() : int
      {
         return this.selectionEndIndex;
      }
      
      public function get selectionAnchorPosition() : int
      {
         return this.selectionBeginIndex;
      }
      
      public function showBorderAndBackground(param1:Boolean) : void
      {
         if(this.border)
         {
            this.border.visible = param1;
         }
      }
      
      public function selectRange(param1:int, param2:int) : void
      {
         this.textField.setSelection(param1,param2);
      }
      
      override protected function focusInHandler(param1:FocusEvent) : void
      {
         var message:String = null;
         var event:FocusEvent = param1;
         if(event.target == this)
         {
            systemManager.stage.focus = TextField(this.textField);
         }
         var fm:IFocusManager = focusManager;
         if(this.editable && fm)
         {
            fm.showFocusIndicator = true;
            if(this.textField.selectable && this._selectionBeginIndex == this._selectionEndIndex)
            {
               this.textField.setSelection(0,this.textField.length);
            }
         }
         super.focusInHandler(event);
         if(this._imeMode != null && this._editable)
         {
            try
            {
               if(!this.errorCaught && IME.conversionMode != IMEConversionMode.UNKNOWN)
               {
                  IME.conversionMode = this._imeMode;
               }
               this.errorCaught = false;
            }
            catch(e:Error)
            {
               errorCaught = true;
               message = resourceManager.getString("controls","unsupportedMode",[_imeMode]);
               throw new Error(message);
            }
         }
      }
      
      override protected function focusOutHandler(param1:FocusEvent) : void
      {
         super.focusOutHandler(param1);
         dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case Keyboard.ENTER:
               dispatchEvent(new FlexEvent(FlexEvent.ENTER));
               if(this.textChanged || this.htmlTextChanged)
               {
                  validateNow();
               }
         }
      }
      
      private function textField_changeHandler(param1:Event) : void
      {
         this.textFieldChanged(false,false);
         this.textChanged = false;
         this.htmlTextChanged = false;
         param1.stopImmediatePropagation();
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      private function textField_nativeDragDropHandler(param1:Event) : void
      {
         this.textField_changeHandler(param1);
      }
      
      private function textField_textInputHandler(param1:TextEvent) : void
      {
         param1.stopImmediatePropagation();
         var _loc2_:TextEvent = new TextEvent(TextEvent.TEXT_INPUT,false,true);
         _loc2_.text = param1.text;
         dispatchEvent(_loc2_);
         if(_loc2_.isDefaultPrevented())
         {
            param1.preventDefault();
         }
      }
      
      private function textField_scrollHandler(param1:Event) : void
      {
         this._horizontalScrollPosition = this.textField.scrollH;
      }
      
      private function textField_textFieldStyleChangeHandler(param1:Event) : void
      {
         this.textFieldChanged(true,false);
      }
      
      private function textField_textFormatChangeHandler(param1:Event) : void
      {
         this.textFieldChanged(true,false);
      }
      
      private function textField_textModifiedHandler(param1:Event) : void
      {
         this.textFieldChanged(false,true);
      }
   }
}
