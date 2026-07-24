package cadcamwiz
{
   import comps.GWizForePanel;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.IVisualElement;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.CheckBox;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.components.VGroup;
   
   use namespace mx_internal;
   
   public class GWizCCWHoleOptions extends Group implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _2076430148Carbide:RadioButton;
      
      private var _1710422724CarbideHP:RadioButton;
      
      private var _2023680147Cobalt:RadioButton;
      
      private var _71848HSS:RadioButton;
      
      private var _69048240HSSHP:RadioButton;
      
      private var _1196827916Indexable:RadioButton;
      
      private var _101156413drillOptions:GWizForePanel;
      
      private var _1939240726interpOptions:GWizCCPocketOptions;
      
      private var _1944592185parabolic:CheckBox;
      
      private var _1365780766placeholder1:CheckBox;
      
      private var _1365780767placeholder2:CheckBox;
      
      private var _1365780768placeholder3:CheckBox;
      
      private var _164873550radiogroup2:RadioButtonGroup;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _934922488recalc:Function = null;
      
      private var _97483395theLabelWidth:int = 90;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCWHoleOptions()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCWHoleOptions_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCWHoleOptionsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCWHoleOptions[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this._GWizCCWHoleOptions_GWizForePanel1_i();
         this._GWizCCWHoleOptions_GWizCCPocketOptions1_i();
         this._GWizCCWHoleOptions_RadioButtonGroup1_i();
         this.addEventListener("creationComplete",this.___GWizCCWHoleOptions_Group1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCWHoleOptions._watcherSetupUtil = param1;
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
      
      public function onCC() : void
      {
         this.selectedChild = this.drillOptions;
         GWizCCPocketOptions.showEntry = false;
      }
      
      public function set selectedChild(param1:IVisualElement) : void
      {
         this.removeAllElements();
         this.addElement(param1);
         (param1 as GWizForePanel).labelWidth = this.theLabelWidth;
      }
      
      private function _GWizCCWHoleOptions_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Options";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCCWHoleOptions_Array1_c);
         _loc1_.id = "drillOptions";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.drillOptions = _loc1_;
         BindingManager.executeBindings(this,"drillOptions",this.drillOptions);
         return _loc1_;
      }
      
      private function _GWizCCWHoleOptions_Array1_c() : Array
      {
         return [this._GWizCCWHoleOptions_VGroup1_c()];
      }
      
      private function _GWizCCWHoleOptions_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWHoleOptions_HGroup1_c(),this._GWizCCWHoleOptions_CheckBox1_i(),this._GWizCCWHoleOptions_CheckBox2_i(),this._GWizCCWHoleOptions_CheckBox3_i(),this._GWizCCWHoleOptions_CheckBox4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWHoleOptions_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizCCWHoleOptions_Label1_c(),this._GWizCCWHoleOptions_RadioButton1_i(),this._GWizCCWHoleOptions_RadioButton2_i(),this._GWizCCWHoleOptions_RadioButton3_i(),this._GWizCCWHoleOptions_RadioButton4_i(),this._GWizCCWHoleOptions_RadioButton5_i(),this._GWizCCWHoleOptions_RadioButton6_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWHoleOptions_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Twist Drill:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWHoleOptions_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "HSS";
         _loc1_.groupName = "radiogroup2";
         _loc1_.selected = true;
         _loc1_.id = "HSS";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HSS = _loc1_;
         BindingManager.executeBindings(this,"HSS",this.HSS);
         return _loc1_;
      }
      
      private function _GWizCCWHoleOptions_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "HSS HP";
         _loc1_.groupName = "radiogroup2";
         _loc1_.id = "HSSHP";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HSSHP = _loc1_;
         BindingManager.executeBindings(this,"HSSHP",this.HSSHP);
         return _loc1_;
      }
      
      private function _GWizCCWHoleOptions_RadioButton3_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Cobalt";
         _loc1_.groupName = "radiogroup2";
         _loc1_.id = "Cobalt";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Cobalt = _loc1_;
         BindingManager.executeBindings(this,"Cobalt",this.Cobalt);
         return _loc1_;
      }
      
      private function _GWizCCWHoleOptions_RadioButton4_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Carbide";
         _loc1_.groupName = "radiogroup2";
         _loc1_.id = "Carbide";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Carbide = _loc1_;
         BindingManager.executeBindings(this,"Carbide",this.Carbide);
         return _loc1_;
      }
      
      private function _GWizCCWHoleOptions_RadioButton5_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Carbide HP";
         _loc1_.groupName = "radiogroup2";
         _loc1_.id = "CarbideHP";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CarbideHP = _loc1_;
         BindingManager.executeBindings(this,"CarbideHP",this.CarbideHP);
         return _loc1_;
      }
      
      private function _GWizCCWHoleOptions_RadioButton6_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Indexable";
         _loc1_.groupName = "radiogroup2";
         _loc1_.id = "Indexable";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Indexable = _loc1_;
         BindingManager.executeBindings(this,"Indexable",this.Indexable);
         return _loc1_;
      }
      
      private function _GWizCCWHoleOptions_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Parabolic Flutes:";
         _loc1_.selected = false;
         _loc1_.id = "parabolic";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.parabolic = _loc1_;
         BindingManager.executeBindings(this,"parabolic",this.parabolic);
         return _loc1_;
      }
      
      private function _GWizCCWHoleOptions_CheckBox2_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.visible = false;
         _loc1_.selected = false;
         _loc1_.id = "placeholder1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.placeholder1 = _loc1_;
         BindingManager.executeBindings(this,"placeholder1",this.placeholder1);
         return _loc1_;
      }
      
      private function _GWizCCWHoleOptions_CheckBox3_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.visible = false;
         _loc1_.selected = false;
         _loc1_.id = "placeholder2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.placeholder2 = _loc1_;
         BindingManager.executeBindings(this,"placeholder2",this.placeholder2);
         return _loc1_;
      }
      
      private function _GWizCCWHoleOptions_CheckBox4_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.visible = false;
         _loc1_.selected = false;
         _loc1_.id = "placeholder3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.placeholder3 = _loc1_;
         BindingManager.executeBindings(this,"placeholder3",this.placeholder3);
         return _loc1_;
      }
      
      private function _GWizCCWHoleOptions_GWizCCPocketOptions1_i() : GWizCCPocketOptions
      {
         var _loc1_:GWizCCPocketOptions = new GWizCCPocketOptions();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "interpOptions";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.interpOptions = _loc1_;
         BindingManager.executeBindings(this,"interpOptions",this.interpOptions);
         return _loc1_;
      }
      
      private function _GWizCCWHoleOptions_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.addEventListener("change",this.__radiogroup2_change);
         _loc1_.initialized(this,"radiogroup2");
         this.radiogroup2 = _loc1_;
         BindingManager.executeBindings(this,"radiogroup2",this.radiogroup2);
         return _loc1_;
      }
      
      public function __radiogroup2_change(param1:Event) : void
      {
         this.recalc();
      }
      
      public function ___GWizCCWHoleOptions_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizCCWHoleOptions_bindingsSetup() : Array
      {
         var _loc1_:Array = [];
         _loc1_[0] = new Binding(this,null,null,"interpOptions.recalc","recalc");
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get Carbide() : RadioButton
      {
         return this._2076430148Carbide;
      }
      
      public function set Carbide(param1:RadioButton) : void
      {
         var _loc2_:Object = this._2076430148Carbide;
         if(_loc2_ !== param1)
         {
            this._2076430148Carbide = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Carbide",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CarbideHP() : RadioButton
      {
         return this._1710422724CarbideHP;
      }
      
      public function set CarbideHP(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1710422724CarbideHP;
         if(_loc2_ !== param1)
         {
            this._1710422724CarbideHP = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CarbideHP",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Cobalt() : RadioButton
      {
         return this._2023680147Cobalt;
      }
      
      public function set Cobalt(param1:RadioButton) : void
      {
         var _loc2_:Object = this._2023680147Cobalt;
         if(_loc2_ !== param1)
         {
            this._2023680147Cobalt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Cobalt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HSS() : RadioButton
      {
         return this._71848HSS;
      }
      
      public function set HSS(param1:RadioButton) : void
      {
         var _loc2_:Object = this._71848HSS;
         if(_loc2_ !== param1)
         {
            this._71848HSS = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HSS",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HSSHP() : RadioButton
      {
         return this._69048240HSSHP;
      }
      
      public function set HSSHP(param1:RadioButton) : void
      {
         var _loc2_:Object = this._69048240HSSHP;
         if(_loc2_ !== param1)
         {
            this._69048240HSSHP = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HSSHP",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Indexable() : RadioButton
      {
         return this._1196827916Indexable;
      }
      
      public function set Indexable(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1196827916Indexable;
         if(_loc2_ !== param1)
         {
            this._1196827916Indexable = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Indexable",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get drillOptions() : GWizForePanel
      {
         return this._101156413drillOptions;
      }
      
      public function set drillOptions(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._101156413drillOptions;
         if(_loc2_ !== param1)
         {
            this._101156413drillOptions = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"drillOptions",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get interpOptions() : GWizCCPocketOptions
      {
         return this._1939240726interpOptions;
      }
      
      public function set interpOptions(param1:GWizCCPocketOptions) : void
      {
         var _loc2_:Object = this._1939240726interpOptions;
         if(_loc2_ !== param1)
         {
            this._1939240726interpOptions = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"interpOptions",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get parabolic() : CheckBox
      {
         return this._1944592185parabolic;
      }
      
      public function set parabolic(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1944592185parabolic;
         if(_loc2_ !== param1)
         {
            this._1944592185parabolic = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"parabolic",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get placeholder1() : CheckBox
      {
         return this._1365780766placeholder1;
      }
      
      public function set placeholder1(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1365780766placeholder1;
         if(_loc2_ !== param1)
         {
            this._1365780766placeholder1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"placeholder1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get placeholder2() : CheckBox
      {
         return this._1365780767placeholder2;
      }
      
      public function set placeholder2(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1365780767placeholder2;
         if(_loc2_ !== param1)
         {
            this._1365780767placeholder2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"placeholder2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get placeholder3() : CheckBox
      {
         return this._1365780768placeholder3;
      }
      
      public function set placeholder3(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1365780768placeholder3;
         if(_loc2_ !== param1)
         {
            this._1365780768placeholder3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"placeholder3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get radiogroup2() : RadioButtonGroup
      {
         return this._164873550radiogroup2;
      }
      
      public function set radiogroup2(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._164873550radiogroup2;
         if(_loc2_ !== param1)
         {
            this._164873550radiogroup2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"radiogroup2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get recalc() : Function
      {
         return this._934922488recalc;
      }
      
      public function set recalc(param1:Function) : void
      {
         var _loc2_:Object = this._934922488recalc;
         if(_loc2_ !== param1)
         {
            this._934922488recalc = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"recalc",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get theLabelWidth() : int
      {
         return this._97483395theLabelWidth;
      }
      
      public function set theLabelWidth(param1:int) : void
      {
         var _loc2_:Object = this._97483395theLabelWidth;
         if(_loc2_ !== param1)
         {
            this._97483395theLabelWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theLabelWidth",_loc2_,param1));
            }
         }
      }
   }
}
