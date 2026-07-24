package material
{
   import comps.GWizForePanel;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import machines.GWizMachSelector2;
   import machines.GWizMachSettings;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.utils.ChangeWatcher;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import skins.GWizStylePalette;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.VGroup;
   import utils.ColorPalette;
   
   use namespace mx_internal;
   
   public class GWizFSMachineMaterialSelector extends HGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizFSMachineMaterialSelector");
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1805001689Machine:GWizMachSelector2;
      
      private var _1243041755MatChooser:GWizMaterialChooser;
      
      private var _1567738209chiploadAdjust:Label;
      
      private var _1467266933machPanel:GWizForePanel;
      
      private var _279171204matPanel:GWizForePanel;
      
      private var _1992185569safeModeIndicator:Label;
      
      private var _817612602secondRow:HGroup;
      
      private var _115663703sfmAdjust:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1424449122onChangeFcn:Function;
      
      private var _835562194hideLabel:Boolean = false;
      
      private var _110371416title:String = "";
      
      private var _1657211086labelWidth:int;
      
      private var _193361929gapSize:int;
      
      private var _186804323firstColWd:int;
      
      private var _239444057secondColWd:int;
      
      private var _1008240571nativeWin:DisplayObject = null;
      
      public var theOwner:String = "";
      
      private var widthWatch:ChangeWatcher;
      
      private var heightWatch:ChangeWatcher;
      
      private var resizeExecuting:Boolean = false;
      
      private var lastSFMAdjust:Number = -1;
      
      private var lastIPTAdjust:Number = -1;
      
      private var lastSafeMode:String = "";
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizFSMachineMaterialSelector()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizFSMachineMaterialSelector_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_material_GWizFSMachineMaterialSelectorWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizFSMachineMaterialSelector[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.gap = 1;
         this.mxmlContent = [this._GWizFSMachineMaterialSelector_GWizForePanel1_i(),this._GWizFSMachineMaterialSelector_GWizForePanel2_i()];
         this.addEventListener("creationComplete",this.___GWizFSMachineMaterialSelector_HGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizFSMachineMaterialSelector._watcherSetupUtil = param1;
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
         GWizAbstractPrefs.powerUserCC.addFunction("GWizFSMachineMaterialSelector",this.powerUserChanged,false);
         this.powerUserChanged();
         GWizMachSettings.selectMachineCC.addFunction("GWizFSMachineMaterialSelector",this.updateSafeModeViaCC,false);
         this.widthWatch = ChangeWatcher.watch(this,"width",this.onResize);
         this.heightWatch = ChangeWatcher.watch(this,"height",this.onResize);
         this.handleResize();
      }
      
      public function onResize(param1:Event) : void
      {
         if(!this.resizeExecuting)
         {
            this.callLater(this.handleResize);
         }
         this.resizeExecuting = true;
      }
      
      public function updateSafeMode(param1:Number, param2:Number) : void
      {
         if(this.lastSFMAdjust != param1 || this.lastIPTAdjust != param2 || this.lastSafeMode != this.safeModeIndicator.text)
         {
            this.sfmAdjust.text = "SFM " + String(param1) + "%";
            this.chiploadAdjust.text = "IPT " + String(param2) + "%";
            this.safeModeIndicator.text = "";
            if(GWizMachSettings.currMachineSafeMode())
            {
               this.safeModeIndicator.text = "Safe Mode";
            }
            this.lastSFMAdjust = param1;
            this.lastIPTAdjust = param2;
            this.lastSafeMode = this.safeModeIndicator.text;
         }
      }
      
      public function updateSafeModeViaCC(param1:Object = null) : Boolean
      {
         var _loc2_:Object = GWizMachSettings.lookupMachine(GWizMachSettings.currMachine);
         this.updateSafeMode(_loc2_.sfmAdjust,_loc2_.chiploadAdjust);
         return true;
      }
      
      private function handleResize() : void
      {
         invalidateDisplayList();
         this.resizeExecuting = false;
      }
      
      private function powerUserChanged(param1:Object = null) : Boolean
      {
         this.sfmAdjust.visible = GWizSettings.prefs.powerUser;
         this.chiploadAdjust.visible = GWizSettings.prefs.powerUser;
         return true;
      }
      
      private function _GWizFSMachineMaterialSelector_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFSMachineMaterialSelector_Array2_c);
         _loc1_.id = "machPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machPanel = _loc1_;
         BindingManager.executeBindings(this,"machPanel",this.machPanel);
         return _loc1_;
      }
      
      private function _GWizFSMachineMaterialSelector_Array2_c() : Array
      {
         return [this._GWizFSMachineMaterialSelector_VGroup1_c()];
      }
      
      private function _GWizFSMachineMaterialSelector_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizFSMachineMaterialSelector_GWizMachSelector21_i(),this._GWizFSMachineMaterialSelector_HGroup2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFSMachineMaterialSelector_GWizMachSelector21_i() : GWizMachSelector2
      {
         var _loc1_:GWizMachSelector2 = new GWizMachSelector2();
         _loc1_.percentWidth = 100;
         _loc1_.id = "Machine";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Machine = _loc1_;
         BindingManager.executeBindings(this,"Machine",this.Machine);
         return _loc1_;
      }
      
      private function _GWizFSMachineMaterialSelector_HGroup2_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFSMachineMaterialSelector_Label1_i(),this._GWizFSMachineMaterialSelector_Label2_i(),this._GWizFSMachineMaterialSelector_Label3_i()];
         _loc1_.id = "secondRow";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.secondRow = _loc1_;
         BindingManager.executeBindings(this,"secondRow",this.secondRow);
         return _loc1_;
      }
      
      private function _GWizFSMachineMaterialSelector_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "SFM 100%";
         _loc1_.id = "sfmAdjust";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sfmAdjust = _loc1_;
         BindingManager.executeBindings(this,"sfmAdjust",this.sfmAdjust);
         return _loc1_;
      }
      
      private function _GWizFSMachineMaterialSelector_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "IPT 100%";
         _loc1_.id = "chiploadAdjust";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.chiploadAdjust = _loc1_;
         BindingManager.executeBindings(this,"chiploadAdjust",this.chiploadAdjust);
         return _loc1_;
      }
      
      private function _GWizFSMachineMaterialSelector_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.id = "safeModeIndicator";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.safeModeIndicator = _loc1_;
         BindingManager.executeBindings(this,"safeModeIndicator",this.safeModeIndicator);
         return _loc1_;
      }
      
      private function _GWizFSMachineMaterialSelector_GWizForePanel2_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFSMachineMaterialSelector_Array5_c);
         _loc1_.id = "matPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.matPanel = _loc1_;
         BindingManager.executeBindings(this,"matPanel",this.matPanel);
         return _loc1_;
      }
      
      private function _GWizFSMachineMaterialSelector_Array5_c() : Array
      {
         return [this._GWizFSMachineMaterialSelector_GWizMaterialChooser1_i()];
      }
      
      private function _GWizFSMachineMaterialSelector_GWizMaterialChooser1_i() : GWizMaterialChooser
      {
         var _loc1_:GWizMaterialChooser = new GWizMaterialChooser();
         _loc1_.id = "MatChooser";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MatChooser = _loc1_;
         BindingManager.executeBindings(this,"MatChooser",this.MatChooser);
         return _loc1_;
      }
      
      public function ___GWizFSMachineMaterialSelector_HGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizFSMachineMaterialSelector_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,null,null,"machPanel.width","firstColWd");
         result[1] = new Binding(this,function():Number
         {
            return this.height;
         },null,"machPanel.height");
         result[2] = new Binding(this,null,null,"machPanel.title","title");
         result[3] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"machPanel.labelBackgroundColor");
         result[4] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"machPanel.labelColor");
         result[5] = new Binding(this,function():int
         {
            return this.labelWidth;
         },null,"machPanel.labelWidth");
         result[6] = new Binding(this,function():int
         {
            return this.gapSize;
         },null,"machPanel.gapSize");
         result[7] = new Binding(this,function():DisplayObject
         {
            return this.nativeWin;
         },null,"Machine.nativeWin");
         result[8] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            sfmAdjust.setStyle("color",param1);
         },"sfmAdjust.color");
         result[9] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            chiploadAdjust.setStyle("color",param1);
         },"chiploadAdjust.color");
         result[10] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            safeModeIndicator.setStyle("color",param1);
         },"safeModeIndicator.color");
         result[11] = new Binding(this,null,null,"matPanel.width","secondColWd");
         result[12] = new Binding(this,function():Number
         {
            return this.height;
         },null,"matPanel.height");
         result[13] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"matPanel.labelBackgroundColor");
         result[14] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"matPanel.labelColor");
         result[15] = new Binding(this,function():int
         {
            return this.labelWidth;
         },null,"matPanel.labelWidth");
         result[16] = new Binding(this,function():int
         {
            return this.gapSize;
         },null,"matPanel.gapSize");
         result[17] = new Binding(this,function():Number
         {
            return matPanel.width;
         },null,"MatChooser.width");
         result[18] = new Binding(this,function():Function
         {
            return this.onChangeFcn;
         },null,"MatChooser.onChangeFcn");
         result[19] = new Binding(this,function():String
         {
            var _loc1_:* = GWizStylePalette.textColor;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"MatChooser.labColor");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Machine() : GWizMachSelector2
      {
         return this._1805001689Machine;
      }
      
      public function set Machine(param1:GWizMachSelector2) : void
      {
         var _loc2_:Object = this._1805001689Machine;
         if(_loc2_ !== param1)
         {
            this._1805001689Machine = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Machine",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MatChooser() : GWizMaterialChooser
      {
         return this._1243041755MatChooser;
      }
      
      public function set MatChooser(param1:GWizMaterialChooser) : void
      {
         var _loc2_:Object = this._1243041755MatChooser;
         if(_loc2_ !== param1)
         {
            this._1243041755MatChooser = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MatChooser",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get chiploadAdjust() : Label
      {
         return this._1567738209chiploadAdjust;
      }
      
      public function set chiploadAdjust(param1:Label) : void
      {
         var _loc2_:Object = this._1567738209chiploadAdjust;
         if(_loc2_ !== param1)
         {
            this._1567738209chiploadAdjust = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"chiploadAdjust",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machPanel() : GWizForePanel
      {
         return this._1467266933machPanel;
      }
      
      public function set machPanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._1467266933machPanel;
         if(_loc2_ !== param1)
         {
            this._1467266933machPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get matPanel() : GWizForePanel
      {
         return this._279171204matPanel;
      }
      
      public function set matPanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._279171204matPanel;
         if(_loc2_ !== param1)
         {
            this._279171204matPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"matPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get safeModeIndicator() : Label
      {
         return this._1992185569safeModeIndicator;
      }
      
      public function set safeModeIndicator(param1:Label) : void
      {
         var _loc2_:Object = this._1992185569safeModeIndicator;
         if(_loc2_ !== param1)
         {
            this._1992185569safeModeIndicator = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"safeModeIndicator",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get secondRow() : HGroup
      {
         return this._817612602secondRow;
      }
      
      public function set secondRow(param1:HGroup) : void
      {
         var _loc2_:Object = this._817612602secondRow;
         if(_loc2_ !== param1)
         {
            this._817612602secondRow = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"secondRow",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sfmAdjust() : Label
      {
         return this._115663703sfmAdjust;
      }
      
      public function set sfmAdjust(param1:Label) : void
      {
         var _loc2_:Object = this._115663703sfmAdjust;
         if(_loc2_ !== param1)
         {
            this._115663703sfmAdjust = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sfmAdjust",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get onChangeFcn() : Function
      {
         return this._1424449122onChangeFcn;
      }
      
      public function set onChangeFcn(param1:Function) : void
      {
         var _loc2_:Object = this._1424449122onChangeFcn;
         if(_loc2_ !== param1)
         {
            this._1424449122onChangeFcn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"onChangeFcn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hideLabel() : Boolean
      {
         return this._835562194hideLabel;
      }
      
      public function set hideLabel(param1:Boolean) : void
      {
         var _loc2_:Object = this._835562194hideLabel;
         if(_loc2_ !== param1)
         {
            this._835562194hideLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hideLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get title() : String
      {
         return this._110371416title;
      }
      
      public function set title(param1:String) : void
      {
         var _loc2_:Object = this._110371416title;
         if(_loc2_ !== param1)
         {
            this._110371416title = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"title",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labelWidth() : int
      {
         return this._1657211086labelWidth;
      }
      
      public function set labelWidth(param1:int) : void
      {
         var _loc2_:Object = this._1657211086labelWidth;
         if(_loc2_ !== param1)
         {
            this._1657211086labelWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labelWidth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gapSize() : int
      {
         return this._193361929gapSize;
      }
      
      public function set gapSize(param1:int) : void
      {
         var _loc2_:Object = this._193361929gapSize;
         if(_loc2_ !== param1)
         {
            this._193361929gapSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gapSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get firstColWd() : int
      {
         return this._186804323firstColWd;
      }
      
      public function set firstColWd(param1:int) : void
      {
         var _loc2_:Object = this._186804323firstColWd;
         if(_loc2_ !== param1)
         {
            this._186804323firstColWd = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"firstColWd",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get secondColWd() : int
      {
         return this._239444057secondColWd;
      }
      
      public function set secondColWd(param1:int) : void
      {
         var _loc2_:Object = this._239444057secondColWd;
         if(_loc2_ !== param1)
         {
            this._239444057secondColWd = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"secondColWd",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get nativeWin() : DisplayObject
      {
         return this._1008240571nativeWin;
      }
      
      public function set nativeWin(param1:DisplayObject) : void
      {
         var _loc2_:Object = this._1008240571nativeWin;
         if(_loc2_ !== param1)
         {
            this._1008240571nativeWin = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"nativeWin",_loc2_,param1));
            }
         }
      }
   }
}
