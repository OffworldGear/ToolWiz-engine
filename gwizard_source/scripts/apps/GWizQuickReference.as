package apps
{
   import comps.GWizWeightsVolumes;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.containers.ViewStack;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponentDescriptor;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.IndexChangedEvent;
   import mx.events.PropertyChangeEvent;
   import notebook.GWizNotebook;
   import skins.GWizTabBarSkin;
   import spark.components.Group;
   import spark.components.NavigatorContent;
   import spark.components.TabBar;
   import tools.GWizDrillChart;
   import utils.ColorPalette;
   import utils.GATracker;
   import views.GWizElectricalCalc;
   import views.GWizMotorCalc;
   
   use namespace mx_internal;
   
   public class GWizQuickReference extends Group implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1646200315Notebook:GWizNotebook;
      
      public var _GWizQuickReference_NavigatorContent1:NavigatorContent;
      
      public var _GWizQuickReference_NavigatorContent10:NavigatorContent;
      
      public var _GWizQuickReference_NavigatorContent11:NavigatorContent;
      
      public var _GWizQuickReference_NavigatorContent12:NavigatorContent;
      
      public var _GWizQuickReference_NavigatorContent2:NavigatorContent;
      
      public var _GWizQuickReference_NavigatorContent3:NavigatorContent;
      
      public var _GWizQuickReference_NavigatorContent4:NavigatorContent;
      
      public var _GWizQuickReference_NavigatorContent5:NavigatorContent;
      
      public var _GWizQuickReference_NavigatorContent6:NavigatorContent;
      
      public var _GWizQuickReference_NavigatorContent7:NavigatorContent;
      
      public var _GWizQuickReference_NavigatorContent8:NavigatorContent;
      
      public var _GWizQuickReference_NavigatorContent9:NavigatorContent;
      
      private var _3199dc:GWizDrillChart;
      
      private var _881406642tabNav:ViewStack;
      
      private var _3552126tabs:TabBar;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizQuickReference()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizQuickReference_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_apps_GWizQuickReferenceWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizQuickReference[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContent = [this._GWizQuickReference_ViewStack1_i(),this._GWizQuickReference_TabBar1_i()];
         this.addEventListener("creationComplete",this.___GWizQuickReference_Group1_creationComplete);
         this.addEventListener("show",this.___GWizQuickReference_Group1_show);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizQuickReference._watcherSetupUtil = param1;
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
      
      private function onCC() : void
      {
         if(!this.Notebook)
         {
            this.callLater(this.onCC);
            return;
         }
         this.defaultNotebookPages();
      }
      
      public function showMe() : void
      {
         this.tabChanged();
      }
      
      public function hideMe() : void
      {
         if(this.Notebook)
         {
            this.Notebook.onHide();
         }
      }
      
      private function defaultNotebookPages() : void
      {
         GWizSettings.refNotebook = this.Notebook;
         this.Notebook.addNotebookPage("Documentation","WebPage","http://www.cnccookbook.com/GWCalcFeedsSpeeds.htm");
         this.Notebook.addNotebookPage("Release Notes","WebPage","http://www.cnccookbook.com/CCGWizardChangeLog.htm");
      }
      
      private function checkUnits(param1:Event) : void
      {
         this.tabNav.selectedChild.dispatchEvent(param1);
      }
      
      private function tabChanged() : void
      {
         if(this.tabNav.selectedChild.label == "Notebook")
         {
            this.Notebook.onShow();
         }
         else if(this.Notebook)
         {
            this.Notebook.onHide();
         }
         GATracker.logPageView("QuickRef/" + this.tabNav.selectedChild.label,"QuickRef: " + this.tabNav.selectedChild.label);
      }
      
      private function _GWizQuickReference_ViewStack1_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.right = 0;
         temp.left = 0;
         temp.bottom = 0;
         temp.addEventListener("change",this.__tabNav_change);
         temp.id = "tabNav";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"tabNav",
            "events":{"change":"__tabNav_change"},
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizQuickReference_NavigatorContent1",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Drill Chart",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizQuickReference_Array2_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizQuickReference_NavigatorContent2",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Fasteners",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizQuickReference_Array3_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizQuickReference_NavigatorContent3",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Weights",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizQuickReference_Array4_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizQuickReference_NavigatorContent4",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Thermal",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizQuickReference_Array5_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizQuickReference_NavigatorContent5",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "label":"Electrical",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizQuickReference_Array6_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizQuickReference_NavigatorContent6",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Motor",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizQuickReference_Array7_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizQuickReference_NavigatorContent7",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"G and M-Codes",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizQuickReference_Array8_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizQuickReference_NavigatorContent8",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Hardness",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizQuickReference_Array9_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizQuickReference_NavigatorContent9",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Rigidity",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizQuickReference_Array10_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizQuickReference_NavigatorContent10",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Chatter",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizQuickReference_Array11_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizQuickReference_NavigatorContent11",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"GD&T",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizQuickReference_Array12_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"_GWizQuickReference_NavigatorContent12",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Notebook",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizQuickReference_Array13_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.tabNav = temp;
         BindingManager.executeBindings(this,"tabNav",this.tabNav);
         return temp;
      }
      
      public function __tabNav_change(param1:IndexChangedEvent) : void
      {
         this.tabChanged();
      }
      
      private function _GWizQuickReference_Array2_c() : Array
      {
         return [this._GWizQuickReference_GWizDrillChart1_i()];
      }
      
      private function _GWizQuickReference_GWizDrillChart1_i() : GWizDrillChart
      {
         var _loc1_:GWizDrillChart = new GWizDrillChart();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "dc";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.dc = _loc1_;
         BindingManager.executeBindings(this,"dc",this.dc);
         return _loc1_;
      }
      
      private function _GWizQuickReference_Array3_c() : Array
      {
         return [this._GWizQuickReference_GWizSHCSData1_c()];
      }
      
      private function _GWizQuickReference_GWizSHCSData1_c() : GWizSHCSData
      {
         var _loc1_:GWizSHCSData = new GWizSHCSData();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizQuickReference_Array4_c() : Array
      {
         return [this._GWizQuickReference_GWizWeightsVolumes1_c()];
      }
      
      private function _GWizQuickReference_GWizWeightsVolumes1_c() : GWizWeightsVolumes
      {
         var _loc1_:GWizWeightsVolumes = new GWizWeightsVolumes();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizQuickReference_Array5_c() : Array
      {
         return [this._GWizQuickReference_GWizThermalExp1_c()];
      }
      
      private function _GWizQuickReference_GWizThermalExp1_c() : GWizThermalExp
      {
         var _loc1_:GWizThermalExp = new GWizThermalExp();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizQuickReference_Array6_c() : Array
      {
         return [this._GWizQuickReference_GWizElectricalCalc1_c()];
      }
      
      private function _GWizQuickReference_GWizElectricalCalc1_c() : GWizElectricalCalc
      {
         var _loc1_:GWizElectricalCalc = new GWizElectricalCalc();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizQuickReference_Array7_c() : Array
      {
         return [this._GWizQuickReference_GWizMotorCalc1_c()];
      }
      
      private function _GWizQuickReference_GWizMotorCalc1_c() : GWizMotorCalc
      {
         var _loc1_:GWizMotorCalc = new GWizMotorCalc();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizQuickReference_Array8_c() : Array
      {
         return [this._GWizQuickReference_GWizGMCodeReference1_c()];
      }
      
      private function _GWizQuickReference_GWizGMCodeReference1_c() : GWizGMCodeReference
      {
         var _loc1_:GWizGMCodeReference = new GWizGMCodeReference();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizQuickReference_Array9_c() : Array
      {
         return [this._GWizQuickReference_GWizHardness1_c()];
      }
      
      private function _GWizQuickReference_GWizHardness1_c() : GWizHardness
      {
         var _loc1_:GWizHardness = new GWizHardness();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizQuickReference_Array10_c() : Array
      {
         return [this._GWizQuickReference_GWizRigidity1_c()];
      }
      
      private function _GWizQuickReference_GWizRigidity1_c() : GWizRigidity
      {
         var _loc1_:GWizRigidity = new GWizRigidity();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizQuickReference_Array11_c() : Array
      {
         return [this._GWizQuickReference_GWizChatterPitch1_c()];
      }
      
      private function _GWizQuickReference_GWizChatterPitch1_c() : GWizChatterPitch
      {
         var _loc1_:GWizChatterPitch = new GWizChatterPitch();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizQuickReference_Array12_c() : Array
      {
         return [this._GWizQuickReference_GWizGDandT1_c()];
      }
      
      private function _GWizQuickReference_GWizGDandT1_c() : GWizGDandT
      {
         var _loc1_:GWizGDandT = new GWizGDandT();
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizQuickReference_Array13_c() : Array
      {
         return [this._GWizQuickReference_GWizNotebook1_i()];
      }
      
      private function _GWizQuickReference_GWizNotebook1_i() : GWizNotebook
      {
         var _loc1_:GWizNotebook = new GWizNotebook();
         _loc1_.id = "Notebook";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Notebook = _loc1_;
         BindingManager.executeBindings(this,"Notebook",this.Notebook);
         return _loc1_;
      }
      
      private function _GWizQuickReference_TabBar1_i() : TabBar
      {
         var _loc1_:TabBar = new TabBar();
         _loc1_.styleName = "tabHeader";
         _loc1_.top = 9;
         _loc1_.setStyle("skinClass",GWizTabBarSkin);
         _loc1_.id = "tabs";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tabs = _loc1_;
         BindingManager.executeBindings(this,"tabs",this.tabs);
         return _loc1_;
      }
      
      public function ___GWizQuickReference_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      public function ___GWizQuickReference_Group1_show(param1:FlexEvent) : void
      {
         this.checkUnits(param1);
      }
      
      private function _GWizQuickReference_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Object
         {
            return tabs.height + 8;
         },null,"tabNav.top");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb1;
         },function(param1:uint):void
         {
            _GWizQuickReference_NavigatorContent1.setStyle("backgroundColor",param1);
         },"_GWizQuickReference_NavigatorContent1.backgroundColor");
         result[2] = new Binding(this,function():int
         {
            return ColorPalette.alternateb5;
         },null,"dc.topLineColor");
         result[3] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb1;
         },function(param1:uint):void
         {
            _GWizQuickReference_NavigatorContent2.setStyle("backgroundColor",param1);
         },"_GWizQuickReference_NavigatorContent2.backgroundColor");
         result[4] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb1;
         },function(param1:uint):void
         {
            _GWizQuickReference_NavigatorContent3.setStyle("backgroundColor",param1);
         },"_GWizQuickReference_NavigatorContent3.backgroundColor");
         result[5] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb1;
         },function(param1:uint):void
         {
            _GWizQuickReference_NavigatorContent4.setStyle("backgroundColor",param1);
         },"_GWizQuickReference_NavigatorContent4.backgroundColor");
         result[6] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb1;
         },function(param1:uint):void
         {
            _GWizQuickReference_NavigatorContent5.setStyle("backgroundColor",param1);
         },"_GWizQuickReference_NavigatorContent5.backgroundColor");
         result[7] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb1;
         },function(param1:uint):void
         {
            _GWizQuickReference_NavigatorContent6.setStyle("backgroundColor",param1);
         },"_GWizQuickReference_NavigatorContent6.backgroundColor");
         result[8] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb1;
         },function(param1:uint):void
         {
            _GWizQuickReference_NavigatorContent7.setStyle("backgroundColor",param1);
         },"_GWizQuickReference_NavigatorContent7.backgroundColor");
         result[9] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb1;
         },function(param1:uint):void
         {
            _GWizQuickReference_NavigatorContent8.setStyle("backgroundColor",param1);
         },"_GWizQuickReference_NavigatorContent8.backgroundColor");
         result[10] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb1;
         },function(param1:uint):void
         {
            _GWizQuickReference_NavigatorContent9.setStyle("backgroundColor",param1);
         },"_GWizQuickReference_NavigatorContent9.backgroundColor");
         result[11] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb1;
         },function(param1:uint):void
         {
            _GWizQuickReference_NavigatorContent10.setStyle("backgroundColor",param1);
         },"_GWizQuickReference_NavigatorContent10.backgroundColor");
         result[12] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb1;
         },function(param1:uint):void
         {
            _GWizQuickReference_NavigatorContent11.setStyle("backgroundColor",param1);
         },"_GWizQuickReference_NavigatorContent11.backgroundColor");
         result[13] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb1;
         },function(param1:uint):void
         {
            _GWizQuickReference_NavigatorContent12.setStyle("backgroundColor",param1);
         },"_GWizQuickReference_NavigatorContent12.backgroundColor");
         result[14] = new Binding(this,null,null,"tabs.dataProvider","tabNav");
         result[15] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb1;
         },function(param1:uint):void
         {
            tabs.setStyle("chromeColor",param1);
         },"tabs.chromeColor");
         result[16] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },function(param1:uint):void
         {
            tabs.setStyle("color",param1);
         },"tabs.color");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Notebook() : GWizNotebook
      {
         return this._1646200315Notebook;
      }
      
      public function set Notebook(param1:GWizNotebook) : void
      {
         var _loc2_:Object = this._1646200315Notebook;
         if(_loc2_ !== param1)
         {
            this._1646200315Notebook = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Notebook",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get dc() : GWizDrillChart
      {
         return this._3199dc;
      }
      
      public function set dc(param1:GWizDrillChart) : void
      {
         var _loc2_:Object = this._3199dc;
         if(_loc2_ !== param1)
         {
            this._3199dc = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"dc",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tabNav() : ViewStack
      {
         return this._881406642tabNav;
      }
      
      public function set tabNav(param1:ViewStack) : void
      {
         var _loc2_:Object = this._881406642tabNav;
         if(_loc2_ !== param1)
         {
            this._881406642tabNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tabNav",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tabs() : TabBar
      {
         return this._3552126tabs;
      }
      
      public function set tabs(param1:TabBar) : void
      {
         var _loc2_:Object = this._3552126tabs;
         if(_loc2_ !== param1)
         {
            this._3552126tabs = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tabs",_loc2_,param1));
            }
         }
      }
   }
}
