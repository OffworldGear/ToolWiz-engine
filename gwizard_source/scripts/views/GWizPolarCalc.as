package views
{
   import comps.GridComponent;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import skins.GridSkin;
   import spark.components.Button;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.components.TextInput;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizPolarCalc extends Group implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _63408307Angle:TextInput;
      
      private var _88X:TextInput;
      
      private var _89Y:TextInput;
      
      public var _GWizPolarCalc_RadioButton2:RadioButton;
      
      private var _309139820angleGroup:RadioButtonGroup;
      
      private var _1546218279degrees:RadioButton;
      
      private var _317504755gridArea:GridComponent;
      
      private var _114r:TextInput;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizPolarCalc()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizPolarCalc_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_views_GWizPolarCalcWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizPolarCalc[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContent = [this._GWizPolarCalc_GridComponent1_i()];
         this._GWizPolarCalc_RadioButtonGroup1_i();
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizPolarCalc._watcherSetupUtil = param1;
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
      
      private function toRect() : void
      {
         var _loc1_:Number = Number(this.r.text);
         var _loc2_:Number = Number(this.Angle.text);
         if(!isNaN(_loc1_))
         {
            if(!isNaN(_loc2_))
            {
               if(this.degrees.selected)
               {
                  _loc2_ = GWizUtils.radians(_loc2_);
               }
               this.X.text = String(GWizUtils.roundTenths(_loc1_ * Math.cos(_loc2_)));
               this.Y.text = String(GWizUtils.roundTenths(_loc1_ * Math.sin(_loc2_)));
            }
         }
      }
      
      private function toPolar() : void
      {
         var _loc3_:Number = NaN;
         var _loc1_:Number = Number(this.X.text);
         var _loc2_:Number = Number(this.Y.text);
         if(!isNaN(_loc1_))
         {
            if(!isNaN(_loc2_))
            {
               this.r.text = String(GWizUtils.roundTenths(Math.sqrt(_loc1_ * _loc1_ + _loc2_ * _loc2_)));
               _loc3_ = Math.atan2(_loc2_,_loc1_);
               if(this.degrees.selected)
               {
                  _loc3_ = GWizUtils.degrees(_loc3_);
               }
               this.Angle.text = String(GWizUtils.roundTenths(_loc3_));
            }
         }
      }
      
      private function _GWizPolarCalc_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"angleGroup");
         this.angleGroup = _loc1_;
         BindingManager.executeBindings(this,"angleGroup",this.angleGroup);
         return _loc1_;
      }
      
      private function _GWizPolarCalc_GridComponent1_i() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.showXAxis = false;
         _loc1_.showYAxis = false;
         _loc1_.top = 10;
         _loc1_.bottom = 10;
         _loc1_.left = 10;
         _loc1_.right = 10;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizPolarCalc_Array2_c);
         _loc1_.setStyle("skinClass",GridSkin);
         _loc1_.id = "gridArea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gridArea = _loc1_;
         BindingManager.executeBindings(this,"gridArea",this.gridArea);
         return _loc1_;
      }
      
      private function _GWizPolarCalc_Array2_c() : Array
      {
         return [this._GWizPolarCalc_VGroup1_c()];
      }
      
      private function _GWizPolarCalc_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.x = 10;
         _loc1_.y = 10;
         _loc1_.gap = 5;
         _loc1_.mxmlContent = [this._GWizPolarCalc_Label1_c(),this._GWizPolarCalc_Label2_c(),this._GWizPolarCalc_Label3_c(),this._GWizPolarCalc_HGroup1_c(),this._GWizPolarCalc_Button1_c(),this._GWizPolarCalc_Label6_c(),this._GWizPolarCalc_Label7_c(),this._GWizPolarCalc_HGroup2_c(),this._GWizPolarCalc_Button2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPolarCalc_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Convert between polar and rectangular coordinates.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPolarCalc_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",16);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPolarCalc_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Rectangular";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",16);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPolarCalc_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizPolarCalc_Label4_c(),this._GWizPolarCalc_TextInput1_i(),this._GWizPolarCalc_Label5_c(),this._GWizPolarCalc_TextInput2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPolarCalc_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "X=";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPolarCalc_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.id = "X";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.X = _loc1_;
         BindingManager.executeBindings(this,"X",this.X);
         return _loc1_;
      }
      
      private function _GWizPolarCalc_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Y=";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPolarCalc_TextInput2_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.id = "Y";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Y = _loc1_;
         BindingManager.executeBindings(this,"Y",this.Y);
         return _loc1_;
      }
      
      private function _GWizPolarCalc_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "To Polar";
         _loc1_.addEventListener("click",this.___GWizPolarCalc_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizPolarCalc_Button1_click(param1:MouseEvent) : void
      {
         this.toPolar();
      }
      
      private function _GWizPolarCalc_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " ";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",16);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPolarCalc_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Polar";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",16);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPolarCalc_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizPolarCalc_Label8_c(),this._GWizPolarCalc_TextInput3_i(),this._GWizPolarCalc_Label9_c(),this._GWizPolarCalc_TextInput4_i(),this._GWizPolarCalc_RadioButton1_i(),this._GWizPolarCalc_RadioButton2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPolarCalc_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "r=";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPolarCalc_TextInput3_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.id = "r";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.r = _loc1_;
         BindingManager.executeBindings(this,"r",this.r);
         return _loc1_;
      }
      
      private function _GWizPolarCalc_Label9_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Angle=";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPolarCalc_TextInput4_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.id = "Angle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Angle = _loc1_;
         BindingManager.executeBindings(this,"Angle",this.Angle);
         return _loc1_;
      }
      
      private function _GWizPolarCalc_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Degrees";
         _loc1_.selected = true;
         _loc1_.id = "degrees";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.degrees = _loc1_;
         BindingManager.executeBindings(this,"degrees",this.degrees);
         return _loc1_;
      }
      
      private function _GWizPolarCalc_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Radians";
         _loc1_.id = "_GWizPolarCalc_RadioButton2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizPolarCalc_RadioButton2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizPolarCalc_RadioButton2",this._GWizPolarCalc_RadioButton2);
         return _loc1_;
      }
      
      private function _GWizPolarCalc_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "To Rectangular";
         _loc1_.addEventListener("click",this.___GWizPolarCalc_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizPolarCalc_Button2_click(param1:MouseEvent) : void
      {
         this.toRect();
      }
      
      private function _GWizPolarCalc_bindingsSetup() : Array
      {
         var _loc1_:Array = [];
         _loc1_[0] = new Binding(this,null,null,"degrees.group","angleGroup");
         _loc1_[1] = new Binding(this,null,null,"_GWizPolarCalc_RadioButton2.group","angleGroup");
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get Angle() : TextInput
      {
         return this._63408307Angle;
      }
      
      public function set Angle(param1:TextInput) : void
      {
         var _loc2_:Object = this._63408307Angle;
         if(_loc2_ !== param1)
         {
            this._63408307Angle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Angle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get X() : TextInput
      {
         return this._88X;
      }
      
      public function set X(param1:TextInput) : void
      {
         var _loc2_:Object = this._88X;
         if(_loc2_ !== param1)
         {
            this._88X = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"X",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Y() : TextInput
      {
         return this._89Y;
      }
      
      public function set Y(param1:TextInput) : void
      {
         var _loc2_:Object = this._89Y;
         if(_loc2_ !== param1)
         {
            this._89Y = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Y",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get angleGroup() : RadioButtonGroup
      {
         return this._309139820angleGroup;
      }
      
      public function set angleGroup(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._309139820angleGroup;
         if(_loc2_ !== param1)
         {
            this._309139820angleGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"angleGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get degrees() : RadioButton
      {
         return this._1546218279degrees;
      }
      
      public function set degrees(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1546218279degrees;
         if(_loc2_ !== param1)
         {
            this._1546218279degrees = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"degrees",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gridArea() : GridComponent
      {
         return this._317504755gridArea;
      }
      
      public function set gridArea(param1:GridComponent) : void
      {
         var _loc2_:Object = this._317504755gridArea;
         if(_loc2_ !== param1)
         {
            this._317504755gridArea = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gridArea",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get r() : TextInput
      {
         return this._114r;
      }
      
      public function set r(param1:TextInput) : void
      {
         var _loc2_:Object = this._114r;
         if(_loc2_ !== param1)
         {
            this._114r = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"r",_loc2_,param1));
            }
         }
      }
   }
}
