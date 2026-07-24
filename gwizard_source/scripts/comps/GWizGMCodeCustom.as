package comps
{
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import post.GWizGCParseData;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.components.TextInput;
   import spark.components.VGroup;
   
   use namespace mx_internal;
   
   public class GWizGMCodeCustom extends GWizPopUp implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _2105869Code:NumericStepper;
      
      private var _803318041CodeType:DropDownList;
      
      private var _55059233Enabled:RadioButton;
      
      private var _2249383Hint:TextInput;
      
      private var _2106529294Ignore:RadioButton;
      
      private var _74099628Macro:RadioButton;
      
      private var _851043415MacroName:TextInput;
      
      private var _785607795NewCode:HGroup;
      
      private var _76884455Parms:TextInput;
      
      private var _1002405936Unavailable:RadioButton;
      
      public var _GWizGMCodeCustom_Label3:Label;
      
      private var _164873549radiogroup1:RadioButtonGroup;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var response:Function = null;
      
      private var newCode:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizGMCodeCustom()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizGMCodeCustom_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizGMCodeCustomWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizGMCodeCustom[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Customize G/M-Code";
         this.okLabel = "Save";
         this.width = 450;
         this.height = 318;
         this.horizontalAlign = "center";
         this.mxmlContent = [this._GWizGMCodeCustom_VGroup1_c()];
         this._GWizGMCodeCustom_RadioButtonGroup1_i();
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizGMCodeCustom._watcherSetupUtil = param1;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      public function setCustom(param1:int, param2:String, param3:String, param4:String, param5:String, param6:Function, param7:Boolean) : void
      {
         if(param3)
         {
            switch(param3)
            {
               case "yes":
                  this.Enabled.selected = true;
                  break;
               case "no":
               case "":
                  this.Unavailable.selected = true;
                  break;
               case "ignore":
                  this.Ignore.selected = true;
                  break;
               default:
                  this.Unavailable.selected = true;
            }
         }
         else
         {
            this.Unavailable.selected = true;
         }
         if(param4)
         {
            this.Hint.text = param4;
         }
         else
         {
            this.Hint.text = "";
         }
         if(param5)
         {
            this.Parms.text = param5;
         }
         else
         {
            this.Parms.text = "";
         }
         this.response = param6;
         this.newCode = param7;
         this.Code.value = param1;
         var _loc8_:int;
         if((_loc8_ = GWizGCParseData.typeIndex(param2)) >= 0)
         {
            this.CodeType.selectedIndex = _loc8_;
         }
      }
      
      public function giveResponse() : void
      {
         var _loc1_:* = null;
         if(this.response != null)
         {
            _loc1_ = "";
            switch(this.radiogroup1.selection)
            {
               case this.Enabled:
                  _loc1_ = "yes";
                  break;
               case this.Unavailable:
                  _loc1_ = "no";
                  break;
               case this.Ignore:
                  _loc1_ = "ignore";
                  break;
               case this.Macro:
                  _loc1_ = GWizGCParseData.MACRO_FILE_MACRO_PREFIX + "(" + this.MacroName.text + ")";
            }
            this.response(_loc1_,this.Hint.text,this.Parms.text,this.Code.value,this.CodeType.selectedItem,this.newCode);
         }
      }
      
      private function doOKCancel(param1:Boolean) : void
      {
         if(param1)
         {
            this.giveResponse();
         }
         super.close();
      }
      
      override public function onOk(param1:Event) : void
      {
         this.doOKCancel(true);
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.doOKCancel(false);
      }
      
      private function _GWizGMCodeCustom_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"radiogroup1");
         this.radiogroup1 = _loc1_;
         BindingManager.executeBindings(this,"radiogroup1",this.radiogroup1);
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingTop = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingBottom = 5;
         _loc1_.mxmlContent = [this._GWizGMCodeCustom_Spacer1_c(),this._GWizGMCodeCustom_HGroup1_i(),this._GWizGMCodeCustom_Spacer2_c(),this._GWizGMCodeCustom_RadioButton1_i(),this._GWizGMCodeCustom_RadioButton2_i(),this._GWizGMCodeCustom_RadioButton3_i(),this._GWizGMCodeCustom_RadioButton4_i(),this._GWizGMCodeCustom_HGroup2_c(),this._GWizGMCodeCustom_HGroup3_c(),this._GWizGMCodeCustom_HGroup4_c()];
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 3;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_HGroup1_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 90;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGMCodeCustom_Label1_c(),this._GWizGMCodeCustom_NumericStepper1_i(),this._GWizGMCodeCustom_Label2_c(),this._GWizGMCodeCustom_DropDownList1_i()];
         _loc1_.id = "NewCode";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.NewCode = _loc1_;
         BindingManager.executeBindings(this,"NewCode",this.NewCode);
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Code #";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 99999;
         _loc1_.stepSize = 1;
         _loc1_.id = "Code";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Code = _loc1_;
         BindingManager.executeBindings(this,"Code",this.Code);
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Type";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.id = "CodeType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CodeType = _loc1_;
         BindingManager.executeBindings(this,"CodeType",this.CodeType);
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Enabled (\"yes\")";
         _loc1_.groupName = "radiogroup1";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Enabled";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Enabled = _loc1_;
         BindingManager.executeBindings(this,"Enabled",this.Enabled);
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Unavailable (\"no\")";
         _loc1_.groupName = "radiogroup1";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Unavailable";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Unavailable = _loc1_;
         BindingManager.executeBindings(this,"Unavailable",this.Unavailable);
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_RadioButton3_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Ignore (\"ignore\")";
         _loc1_.groupName = "radiogroup1";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Ignore";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Ignore = _loc1_;
         BindingManager.executeBindings(this,"Ignore",this.Ignore);
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_RadioButton4_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Macro (\"<Macro>?\")";
         _loc1_.groupName = "radiogroup1";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Macro";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Macro = _loc1_;
         BindingManager.executeBindings(this,"Macro",this.Macro);
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizGMCodeCustom_Label3_i(),this._GWizGMCodeCustom_TextInput1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "    Macro Name";
         _loc1_.id = "_GWizGMCodeCustom_Label3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGMCodeCustom_Label3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGMCodeCustom_Label3",this._GWizGMCodeCustom_Label3);
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.setStyle("color",0);
         _loc1_.id = "MacroName";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MacroName = _loc1_;
         BindingManager.executeBindings(this,"MacroName",this.MacroName);
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizGMCodeCustom_Label4_c(),this._GWizGMCodeCustom_TextInput2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hint";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_TextInput2_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "Hint tells the purpose of the code";
         _loc1_.setStyle("color",0);
         _loc1_.id = "Hint";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Hint = _loc1_;
         BindingManager.executeBindings(this,"Hint",this.Hint);
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizGMCodeCustom_Label5_c(),this._GWizGMCodeCustom_TextInput3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Parameters";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_TextInput3_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.percentWidth = 100;
         _loc1_.toolTip = "Parameters are hints on which parameters to use with the code";
         _loc1_.setStyle("color",0);
         _loc1_.id = "Parms";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Parms = _loc1_;
         BindingManager.executeBindings(this,"Parms",this.Parms);
         return _loc1_;
      }
      
      private function _GWizGMCodeCustom_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return new ArrayCollection(GWizGCParseData.CodeTypes);
         },null,"CodeType.dataProvider");
         result[1] = new Binding(this,function():Boolean
         {
            return Macro.selected;
         },null,"_GWizGMCodeCustom_Label3.enabled");
         result[2] = new Binding(this,function():Boolean
         {
            return Macro.selected;
         },null,"MacroName.enabled");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Code() : NumericStepper
      {
         return this._2105869Code;
      }
      
      public function set Code(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._2105869Code;
         if(_loc2_ !== param1)
         {
            this._2105869Code = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Code",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CodeType() : DropDownList
      {
         return this._803318041CodeType;
      }
      
      public function set CodeType(param1:DropDownList) : void
      {
         var _loc2_:Object = this._803318041CodeType;
         if(_loc2_ !== param1)
         {
            this._803318041CodeType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CodeType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Enabled() : RadioButton
      {
         return this._55059233Enabled;
      }
      
      public function set Enabled(param1:RadioButton) : void
      {
         var _loc2_:Object = this._55059233Enabled;
         if(_loc2_ !== param1)
         {
            this._55059233Enabled = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Enabled",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Hint() : TextInput
      {
         return this._2249383Hint;
      }
      
      public function set Hint(param1:TextInput) : void
      {
         var _loc2_:Object = this._2249383Hint;
         if(_loc2_ !== param1)
         {
            this._2249383Hint = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Hint",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Ignore() : RadioButton
      {
         return this._2106529294Ignore;
      }
      
      public function set Ignore(param1:RadioButton) : void
      {
         var _loc2_:Object = this._2106529294Ignore;
         if(_loc2_ !== param1)
         {
            this._2106529294Ignore = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Ignore",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Macro() : RadioButton
      {
         return this._74099628Macro;
      }
      
      public function set Macro(param1:RadioButton) : void
      {
         var _loc2_:Object = this._74099628Macro;
         if(_loc2_ !== param1)
         {
            this._74099628Macro = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Macro",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MacroName() : TextInput
      {
         return this._851043415MacroName;
      }
      
      public function set MacroName(param1:TextInput) : void
      {
         var _loc2_:Object = this._851043415MacroName;
         if(_loc2_ !== param1)
         {
            this._851043415MacroName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MacroName",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get NewCode() : HGroup
      {
         return this._785607795NewCode;
      }
      
      public function set NewCode(param1:HGroup) : void
      {
         var _loc2_:Object = this._785607795NewCode;
         if(_loc2_ !== param1)
         {
            this._785607795NewCode = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"NewCode",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Parms() : TextInput
      {
         return this._76884455Parms;
      }
      
      public function set Parms(param1:TextInput) : void
      {
         var _loc2_:Object = this._76884455Parms;
         if(_loc2_ !== param1)
         {
            this._76884455Parms = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Parms",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Unavailable() : RadioButton
      {
         return this._1002405936Unavailable;
      }
      
      public function set Unavailable(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1002405936Unavailable;
         if(_loc2_ !== param1)
         {
            this._1002405936Unavailable = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Unavailable",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get radiogroup1() : RadioButtonGroup
      {
         return this._164873549radiogroup1;
      }
      
      public function set radiogroup1(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._164873549radiogroup1;
         if(_loc2_ !== param1)
         {
            this._164873549radiogroup1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"radiogroup1",_loc2_,param1));
            }
         }
      }
   }
}
