package spark.components
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.ui.Keyboard;
   import mx.core.IFlexDisplayObject;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.ItemClickEvent;
   import mx.managers.IFocusManager;
   import mx.managers.IFocusManagerGroup;
   import spark.components.supportClasses.ToggleButtonBase;
   
   use namespace mx_internal;
   
   public class RadioButton extends ToggleButtonBase implements IFocusManagerGroup
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      mx_internal static var createAccessibilityImplementation:Function;
      
      private static const focusExclusions:Array = ["labelDisplay"];
       
      
      mx_internal var indexNumber:int = 0;
      
      mx_internal var radioButtonGroup:RadioButtonGroup = null;
      
      private var _group:RadioButtonGroup;
      
      private var _groupName:String;
      
      private var groupChanged:Boolean = false;
      
      private var _value:Object;
      
      public function RadioButton()
      {
         super();
         this.groupName = "radioGroup";
      }
      
      override public function get enabled() : Boolean
      {
         if(!super.enabled)
         {
            return false;
         }
         return !this.radioButtonGroup || this.radioButtonGroup.enabled;
      }
      
      override public function get suggestedFocusSkinExclusions() : Array
      {
         return focusExclusions;
      }
      
      private function get autoGroupIndex() : String
      {
         return "_spark_" + this.groupName;
      }
      
      public function get group() : RadioButtonGroup
      {
         var g:RadioButtonGroup = null;
         if(!document)
         {
            return this._group;
         }
         if(!this._group)
         {
            if(this.groupName && this.groupName != "")
            {
               try
               {
                  g = RadioButtonGroup(document[this.groupName]);
               }
               catch(e:Error)
               {
                  if(document.automaticRadioButtonGroups && document.automaticRadioButtonGroups[autoGroupIndex])
                  {
                     g = RadioButtonGroup(document.automaticRadioButtonGroups[autoGroupIndex]);
                  }
               }
               if(!g)
               {
                  g = new RadioButtonGroup(IFlexDisplayObject(document));
                  if(!document.automaticRadioButtonGroups)
                  {
                     document.automaticRadioButtonGroups = [];
                  }
                  document.automaticRadioButtonGroups[this.autoGroupIndex] = g;
               }
               else if(!(g is RadioButtonGroup))
               {
                  return null;
               }
               this._group = g;
            }
         }
         return this._group;
      }
      
      public function set group(param1:RadioButtonGroup) : void
      {
         if(this._group == param1)
         {
            return;
         }
         this.removeFromGroup();
         this._group = param1;
         this._groupName = !!param1 ? this.group.name : "radioGroup";
         this.groupChanged = true;
         invalidateProperties();
         invalidateDisplayList();
      }
      
      public function get groupName() : String
      {
         return this._groupName;
      }
      
      public function set groupName(param1:String) : void
      {
         if(!param1 || param1 == "")
         {
            return;
         }
         this.removeFromGroup();
         this._groupName = param1;
         this._group = null;
         this.groupChanged = true;
         invalidateProperties();
         invalidateDisplayList();
      }
      
      override public function set selected(param1:Boolean) : void
      {
         super.selected = param1;
         invalidateDisplayList();
      }
      
      [Bindable("valueChanged")]
      [Bindable("change")]
      public function get value() : Object
      {
         return this._value;
      }
      
      public function set value(param1:Object) : void
      {
         if(this._value == param1)
         {
            return;
         }
         this._value = param1;
         if(selected && this.group)
         {
            this.group.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
         }
      }
      
      override protected function initializeAccessibility() : void
      {
         if(RadioButton.createAccessibilityImplementation != null)
         {
            RadioButton.createAccessibilityImplementation(this);
         }
      }
      
      override protected function commitProperties() : void
      {
         if(this.groupChanged)
         {
            this.addToGroup();
            this.groupChanged = false;
         }
         super.commitProperties();
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         if(this.group)
         {
            if(selected)
            {
               this._group.selection = this;
            }
            else if(this.group.selection == this)
            {
               this._group.selection = null;
            }
         }
      }
      
      override protected function buttonReleased() : void
      {
         if(!this.enabled || selected)
         {
            return;
         }
         if(!this.radioButtonGroup)
         {
            this.addToGroup();
         }
         super.buttonReleased();
         this.group.setSelection(this);
         var _loc1_:ItemClickEvent = new ItemClickEvent(ItemClickEvent.ITEM_CLICK);
         _loc1_.label = label;
         _loc1_.index = this.indexNumber;
         _loc1_.relatedObject = this;
         _loc1_.item = this.value;
         this.group.dispatchEvent(_loc1_);
      }
      
      private function addToGroup() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = this.group;
         if(_loc1_)
         {
            _loc1_.addInstance(this);
         }
         return _loc1_;
      }
      
      private function removeFromGroup() : void
      {
         this.dispatchEvent(new Event(Event.REMOVED));
         try
         {
            if(document.automaticRadioButtonGroups[this.autoGroupIndex].numRadioButtons == 0)
            {
               delete document.automaticRadioButtonGroups[this.autoGroupIndex];
            }
         }
         catch(e:Error)
         {
         }
      }
      
      private function setPrev(param1:Boolean = true) : void
      {
         var _loc5_:RadioButton = null;
         var _loc2_:RadioButtonGroup = this.group;
         var _loc3_:IFocusManager = focusManager;
         if(_loc3_)
         {
            _loc3_.showFocusIndicator = true;
         }
         var _loc4_:int = 1;
         while(_loc4_ <= this.indexNumber)
         {
            if((_loc5_ = _loc2_.getRadioButtonAt(this.indexNumber - _loc4_)) && this.isRadioButtonEnabled(_loc5_))
            {
               if(param1)
               {
                  _loc2_.setSelection(_loc5_);
               }
               _loc5_.setFocus();
               return;
            }
            _loc4_++;
         }
         if(param1 && _loc2_.getRadioButtonAt(this.indexNumber) != _loc2_.selection)
         {
            _loc2_.setSelection(this);
         }
         this.drawFocus(true);
      }
      
      private function setNext(param1:Boolean = true) : void
      {
         var _loc5_:RadioButton = null;
         var _loc2_:RadioButtonGroup = this.group;
         var _loc3_:IFocusManager = focusManager;
         if(_loc3_)
         {
            _loc3_.showFocusIndicator = true;
         }
         var _loc4_:int = this.indexNumber + 1;
         while(_loc4_ < _loc2_.numRadioButtons)
         {
            if((_loc5_ = _loc2_.getRadioButtonAt(_loc4_)) && this.isRadioButtonEnabled(_loc5_))
            {
               if(param1)
               {
                  _loc2_.setSelection(_loc5_);
               }
               _loc5_.setFocus();
               return;
            }
            _loc4_++;
         }
         if(param1 && _loc2_.getRadioButtonAt(this.indexNumber) != _loc2_.selection)
         {
            _loc2_.setSelection(this);
         }
         this.drawFocus(true);
      }
      
      private function isRadioButtonEnabled(param1:RadioButton) : Boolean
      {
         if(!param1.enabled)
         {
            return false;
         }
         var _loc2_:DisplayObject = param1.systemManager.getSandboxRoot();
         var _loc3_:DisplayObject = param1.parent;
         while(_loc3_ && _loc3_ != _loc2_)
         {
            if(_loc3_ is UIComponent && !UIComponent(_loc3_).enabled)
            {
               return false;
            }
            _loc3_ = _loc3_.parent;
         }
         return true;
      }
      
      private function setThis() : void
      {
         if(!this.radioButtonGroup)
         {
            this.addToGroup();
         }
         var _loc1_:RadioButtonGroup = this.group;
         if(_loc1_.selection != this)
         {
            _loc1_.setSelection(this);
         }
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.isDefaultPrevented())
         {
            return;
         }
         var _loc2_:uint = mapKeycodeForLayoutDirection(param1);
         switch(_loc2_)
         {
            case Keyboard.DOWN:
               this.setNext(!param1.ctrlKey);
               param1.preventDefault();
               break;
            case Keyboard.UP:
               this.setPrev(!param1.ctrlKey);
               param1.preventDefault();
               break;
            case Keyboard.LEFT:
               this.setPrev(!param1.ctrlKey);
               param1.preventDefault();
               break;
            case Keyboard.RIGHT:
               this.setNext(!param1.ctrlKey);
               param1.preventDefault();
               break;
            case Keyboard.SPACE:
               this.setThis();
            default:
               super.keyDownHandler(param1);
         }
      }
   }
}
