package spark.components
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import mx.core.FlexGlobals;
   import mx.core.IFlexDisplayObject;
   import mx.core.IMXMLObject;
   import mx.core.IVisualElement;
   import mx.core.IVisualElementContainer;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.utils.NameUtil;
   
   use namespace mx_internal;
   
   public class RadioButtonGroup extends EventDispatcher implements IMXMLObject
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _name:String;
      
      private var document:IFlexDisplayObject;
      
      private var radioButtons:Array;
      
      private var _enabled:Boolean = true;
      
      private var _selectedValue:Object;
      
      private var _selection:RadioButton;
      
      private var aSbRoot:DisplayObject;
      
      private var bSbRoot:DisplayObject;
      
      public function RadioButtonGroup(param1:IFlexDisplayObject = null)
      {
         this.radioButtons = [];
         super();
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(this._enabled == param1)
         {
            return;
         }
         this._enabled = param1;
         var _loc2_:int = 0;
         while(_loc2_ < this.numRadioButtons)
         {
            this.getRadioButtonAt(_loc2_).invalidateSkinState();
            _loc2_++;
         }
      }
      
      [Bindable("numRadioButtonsChanged")]
      public function get numRadioButtons() : int
      {
         return this.radioButtons.length;
      }
      
      [Bindable("valueCommit")]
      [Bindable("change")]
      public function get selectedValue() : Object
      {
         if(this.selection)
         {
            return this.selection.value != null ? this.selection.value : this.selection.label;
         }
         return null;
      }
      
      public function set selectedValue(param1:Object) : void
      {
         var _loc4_:RadioButton = null;
         this._selectedValue = param1;
         if(param1 == null)
         {
            this.setSelection(null,false);
            return;
         }
         var _loc2_:int = this.numRadioButtons;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if((_loc4_ = this.getRadioButtonAt(_loc3_)).value == param1 || _loc4_.label == param1)
            {
               this.changeSelection(_loc3_,false);
               this._selectedValue = null;
               dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
               break;
            }
            _loc3_++;
         }
      }
      
      [Bindable("valueCommit")]
      [Bindable("change")]
      public function get selection() : RadioButton
      {
         return this._selection;
      }
      
      public function set selection(param1:RadioButton) : void
      {
         if(this._selection == param1)
         {
            return;
         }
         this.setSelection(param1,false);
      }
      
      public function initialized(param1:Object, param2:String) : void
      {
         this._name = param2;
         this.document = !!param1 ? IFlexDisplayObject(param1) : IFlexDisplayObject(FlexGlobals.topLevelApplication);
      }
      
      public function getRadioButtonAt(param1:int) : RadioButton
      {
         if(param1 >= 0 && param1 < this.numRadioButtons)
         {
            return this.radioButtons[param1];
         }
         return null;
      }
      
      mx_internal function get name() : String
      {
         if(this._name == null)
         {
            this._name = NameUtil.createUniqueName(this);
         }
         return this._name;
      }
      
      mx_internal function addInstance(param1:RadioButton) : void
      {
         param1.addEventListener(Event.REMOVED,this.radioButton_removedHandler);
         this.radioButtons.push(param1);
         this.radioButtons.sort(this.breadthOrderCompare);
         var _loc2_:int = 0;
         while(_loc2_ < this.radioButtons.length)
         {
            this.radioButtons[_loc2_].indexNumber = _loc2_;
            _loc2_++;
         }
         if(this._selectedValue != null)
         {
            this.selectedValue = this._selectedValue;
         }
         if(param1.selected == true)
         {
            this.selection = param1;
         }
         param1.radioButtonGroup = this;
         param1.invalidateSkinState();
         dispatchEvent(new Event("numRadioButtonsChanged"));
      }
      
      private function removeInstance(param1:RadioButton) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:RadioButton = null;
         if(param1)
         {
            _loc2_ = false;
            _loc3_ = 0;
            while(_loc3_ < this.numRadioButtons)
            {
               _loc4_ = this.getRadioButtonAt(_loc3_);
               if(_loc2_)
               {
                  --_loc4_.indexNumber;
               }
               else if(_loc4_ == param1)
               {
                  param1.addEventListener(Event.ADDED,this.radioButton_addedHandler);
                  if(param1 == this._selection)
                  {
                     this._selection = null;
                  }
                  param1.radioButtonGroup = null;
                  param1.invalidateSkinState();
                  this.radioButtons.splice(_loc3_,1);
                  _loc2_ = true;
                  _loc3_--;
               }
               _loc3_++;
            }
            if(_loc2_)
            {
               dispatchEvent(new Event("numRadioButtonsChanged"));
            }
         }
      }
      
      mx_internal function setSelection(param1:RadioButton, param2:Boolean = true) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this._selection == param1)
         {
            return;
         }
         if(param1 == null)
         {
            if(this.selection != null)
            {
               this._selection.selected = false;
               this._selection = null;
               if(param2)
               {
                  dispatchEvent(new Event(Event.CHANGE));
               }
            }
         }
         else
         {
            _loc3_ = this.numRadioButtons;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(param1 == this.getRadioButtonAt(_loc4_))
               {
                  this.changeSelection(_loc4_,param2);
                  break;
               }
               _loc4_++;
            }
         }
         dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
      }
      
      private function changeSelection(param1:int, param2:Boolean = true) : void
      {
         var _loc3_:RadioButton = this.getRadioButtonAt(param1);
         if(_loc3_ && _loc3_ != this._selection)
         {
            if(this._selection)
            {
               this._selection.selected = false;
            }
            this._selection = _loc3_;
            this._selection.selected = true;
            if(param2)
            {
               dispatchEvent(new Event(Event.CHANGE));
            }
         }
      }
      
      private function breadthOrderCompare(param1:DisplayObject, param2:DisplayObject) : Number
      {
         var _loc3_:DisplayObjectContainer = param1.parent;
         var _loc4_:DisplayObjectContainer = param2.parent;
         if(!_loc3_ || !_loc4_)
         {
            return 0;
         }
         if(param1 is RadioButton)
         {
            this.aSbRoot = RadioButton(param1).systemManager.getSandboxRoot();
         }
         if(param2 is RadioButton)
         {
            this.bSbRoot = RadioButton(param2).systemManager.getSandboxRoot();
         }
         if(_loc3_ == this.aSbRoot || _loc4_ == this.bSbRoot)
         {
            return 0;
         }
         var _loc5_:int = param1 is UIComponent ? int(UIComponent(param1).nestLevel) : -1;
         var _loc6_:int = param2 is UIComponent ? int(UIComponent(param2).nestLevel) : -1;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(_loc3_ == _loc4_)
         {
            if(_loc3_ is IVisualElementContainer && param1 is IVisualElement)
            {
               _loc7_ = IVisualElementContainer(_loc3_).getElementIndex(IVisualElement(param1));
            }
            else
            {
               _loc7_ = DisplayObjectContainer(_loc3_).getChildIndex(param1);
            }
            if(_loc4_ is IVisualElementContainer && param2 is IVisualElement)
            {
               _loc8_ = IVisualElementContainer(_loc4_).getElementIndex(IVisualElement(param2));
            }
            else
            {
               _loc8_ = DisplayObjectContainer(_loc4_).getChildIndex(param2);
            }
         }
         if(_loc5_ > _loc6_ || _loc7_ > _loc8_)
         {
            return 1;
         }
         if(_loc5_ < _loc6_ || _loc8_ > _loc7_)
         {
            return -1;
         }
         if(param1 == param2)
         {
            return 0;
         }
         return this.breadthOrderCompare(_loc3_,_loc4_);
      }
      
      private function radioButton_addedHandler(param1:Event) : void
      {
         var _loc2_:RadioButton = param1.target as RadioButton;
         if(_loc2_)
         {
            _loc2_.removeEventListener(Event.ADDED,this.radioButton_addedHandler);
            this.addInstance(_loc2_);
         }
      }
      
      private function radioButton_removedHandler(param1:Event) : void
      {
         var _loc2_:RadioButton = param1.target as RadioButton;
         if(_loc2_)
         {
            _loc2_.removeEventListener(Event.REMOVED,this.radioButton_removedHandler);
            this.removeInstance(_loc2_);
         }
      }
   }
}
