package threads2
{
   import comps.GWizForePanel;
   import configinfo.GWizAbstractPrefs;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import spark.components.Button;
   import spark.components.ButtonBar;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.events.IndexChangeEvent;
   
   use namespace mx_internal;
   
   public class GWizThreadCalcBanner extends GWizForePanel implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1320558765CADCAMBtn:Button;
      
      public var _GWizThreadCalcBanner_Label2:Label;
      
      private var _2130030565gwThreadLogo:Label;
      
      private var _250452492intExtType:ButtonBar;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var onIntExtTypeClickFcn:Function;
      
      public var doCCWFcn:Function;
      
      private var _780123145threadSelector:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizThreadCalcBanner()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizThreadCalcBanner_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_threads2_GWizThreadCalcBannerWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizThreadCalcBanner[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizThreadCalcBanner_Array1_c);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizThreadCalcBanner._watcherSetupUtil = param1;
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
      
      private function _GWizThreadCalcBanner_Array1_c() : Array
      {
         return [this._GWizThreadCalcBanner_HGroup1_c()];
      }
      
      private function _GWizThreadCalcBanner_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizThreadCalcBanner_ButtonBar1_i(),this._GWizThreadCalcBanner_Button1_i(),this._GWizThreadCalcBanner_Spacer1_c(),this._GWizThreadCalcBanner_Label1_i(),this._GWizThreadCalcBanner_Label2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadCalcBanner_ButtonBar1_i() : ButtonBar
      {
         var _loc1_:ButtonBar = new ButtonBar();
         _loc1_.selectedIndex = 0;
         _loc1_.requireSelection = true;
         _loc1_.dataProvider = this._GWizThreadCalcBanner_ArrayCollection1_c();
         _loc1_.addEventListener("change",this.__intExtType_change);
         _loc1_.id = "intExtType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.intExtType = _loc1_;
         BindingManager.executeBindings(this,"intExtType",this.intExtType);
         return _loc1_;
      }
      
      private function _GWizThreadCalcBanner_ArrayCollection1_c() : ArrayCollection
      {
         var _loc1_:ArrayCollection = new ArrayCollection();
         _loc1_.source = ["Internal","External"];
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      public function __intExtType_change(param1:IndexChangeEvent) : void
      {
         this.onIntExtTypeClickFcn(param1);
      }
      
      private function _GWizThreadCalcBanner_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "CADCAM Thread Wizard";
         _loc1_.toolTip = "Use this thread\'s specs in Threading Wizard";
         _loc1_.addEventListener("click",this.__CADCAMBtn_click);
         _loc1_.id = "CADCAMBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CADCAMBtn = _loc1_;
         BindingManager.executeBindings(this,"CADCAMBtn",this.CADCAMBtn);
         return _loc1_;
      }
      
      public function __CADCAMBtn_click(param1:MouseEvent) : void
      {
         this.doCCWFcn();
      }
      
      private function _GWizThreadCalcBanner_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizThreadCalcBanner_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "G-Wizard Thread Calculator";
         _loc1_.setStyle("fontSize",24);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontStyle","italic");
         _loc1_.id = "gwThreadLogo";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gwThreadLogo = _loc1_;
         BindingManager.executeBindings(this,"gwThreadLogo",this.gwThreadLogo);
         return _loc1_;
      }
      
      private function _GWizThreadCalcBanner_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = " Premium";
         _loc1_.setStyle("fontSize",24);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontStyle","italic");
         _loc1_.id = "_GWizThreadCalcBanner_Label2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizThreadCalcBanner_Label2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizThreadCalcBanner_Label2",this._GWizThreadCalcBanner_Label2);
         return _loc1_;
      }
      
      private function _GWizThreadCalcBanner_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Boolean
         {
            return GWizAbstractThreadEngine.hasExternalThreads;
         },null,"intExtType.enabled");
         result[1] = new Binding(this,function():Boolean
         {
            return !threadSelector;
         },null,"CADCAMBtn.visible");
         result[2] = new Binding(this,function():Boolean
         {
            return GWizAbstractPrefs.ThreadCalcEnabled;
         },null,"_GWizThreadCalcBanner_Label2.visible");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get CADCAMBtn() : Button
      {
         return this._1320558765CADCAMBtn;
      }
      
      public function set CADCAMBtn(param1:Button) : void
      {
         var _loc2_:Object = this._1320558765CADCAMBtn;
         if(_loc2_ !== param1)
         {
            this._1320558765CADCAMBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CADCAMBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gwThreadLogo() : Label
      {
         return this._2130030565gwThreadLogo;
      }
      
      public function set gwThreadLogo(param1:Label) : void
      {
         var _loc2_:Object = this._2130030565gwThreadLogo;
         if(_loc2_ !== param1)
         {
            this._2130030565gwThreadLogo = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gwThreadLogo",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get intExtType() : ButtonBar
      {
         return this._250452492intExtType;
      }
      
      public function set intExtType(param1:ButtonBar) : void
      {
         var _loc2_:Object = this._250452492intExtType;
         if(_loc2_ !== param1)
         {
            this._250452492intExtType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"intExtType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get threadSelector() : Boolean
      {
         return this._780123145threadSelector;
      }
      
      public function set threadSelector(param1:Boolean) : void
      {
         var _loc2_:Object = this._780123145threadSelector;
         if(_loc2_ !== param1)
         {
            this._780123145threadSelector = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"threadSelector",_loc2_,param1));
            }
         }
      }
   }
}
