package feedsspeeds
{
   import comps.GWizForePanel;
   import comps.GWizNumStepOvr;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import flash.utils.getDefinitionByName;
   import material.GWizMaterialsDB;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import skins.GWizStylePalette;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.TextInput;
   import spark.components.VGroup;
   import spark.skins.spark.ComboBoxButtonSkin;
   import tools.GWizCribToolEditor;
   import utils.ColorPalette;
   import utils.GATracker;
   import utils.GWizCSVUtils;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizMfgCutterSpecs extends HGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizMfgCutterSpecs");
      
      public static const GENERIC_FAMILY:String = "Generic";
      
      private static var _1112298178lockForToolCrib:Boolean = false;
      
      private static var _768651500familyListData:ArrayCollection = new ArrayCollection();
      
      private static var _797302045sfmExamples:ArrayCollection = new ArrayCollection([{
         "family":"Seco Jabro-Solid2 JS520 (general)",
         "material":"Aluminum - Wrought (6061)",
         "sfm":2461
      },{
         "family":"Lakeshore Carbide VFA - 1 Example",
         "material":"Aluminum - Wrought (6061)",
         "sfm":2000
      },{
         "family":"Lakeshore Carbide VFA",
         "material":"Aluminum - Wrought (6061)",
         "sfm":2000
      },{
         "family":"Lakeshore Carbide VFA",
         "material":"Brass",
         "sfm":1500
      },{
         "family":"Lakeshore Carbide VFA",
         "material":"Copper - Wrought",
         "sfm":1200
      },{
         "family":"Lakeshore Carbide VFA",
         "material":"Plastics: Hard (ABS, Nylon, Foam Bd)",
         "sfm":1600
      },{
         "family":"Lakeshore Carbide VFA",
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "sfm":1600
      },{
         "family":"Whiteside 6210",
         "material":"Wood: Hardwood",
         "sfm":5350
      },{
         "family":"Whiteside 6210",
         "material":"Wood: MDF",
         "sfm":5350
      },{
         "family":"Whiteside 6210",
         "material":"Wood: Plywood",
         "sfm":5350
      },{
         "family":"Whiteside 6210",
         "material":"Wood: Softwood",
         "sfm":5350
      },{
         "family":"Whiteside 6220",
         "material":"Wood: Hardwood",
         "sfm":7900
      },{
         "family":"Whiteside 6220",
         "material":"Wood: MDF",
         "sfm":7900
      },{
         "family":"Whiteside 6220",
         "material":"Wood: Plywood",
         "sfm":7900
      },{
         "family":"Whiteside 6220",
         "material":"Wood: Softwood",
         "sfm":7900
      },{
         "family":"Amana RC-2249",
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "sfm":7070
      },{
         "family":"Amana RC-2249",
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "sfm":7070
      },{
         "family":"Amana RC-2249",
         "material":"Wood: Hardwood",
         "sfm":7070
      },{
         "family":"Amana RC-2249",
         "material":"Wood: MDF",
         "sfm":7070
      },{
         "family":"Amana RC-2249",
         "material":"Wood: Plywood",
         "sfm":7070
      },{
         "family":"Amana RC-2249",
         "material":"Wood: Softwood",
         "sfm":7070
      },{
         "family":"Amana RC-2250",
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "sfm":7070
      },{
         "family":"Amana RC-2250",
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "sfm":7070
      },{
         "family":"Amana RC-2250",
         "material":"Wood: Hardwood",
         "sfm":7070
      },{
         "family":"Amana RC-2250",
         "material":"Wood: MDF",
         "sfm":7070
      },{
         "family":"Amana RC-2250",
         "material":"Wood: Plywood",
         "sfm":7070
      },{
         "family":"Amana RC-2250",
         "material":"Wood: Softwood",
         "sfm":7070
      },{
         "family":"Amana RC-2255",
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "sfm":9430
      },{
         "family":"Amana RC-2255",
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "sfm":9430
      },{
         "family":"Amana RC-2255",
         "material":"Wood: Hardwood",
         "sfm":9430
      },{
         "family":"Amana RC-2255",
         "material":"Wood: MDF",
         "sfm":9430
      },{
         "family":"Amana RC-2255",
         "material":"Wood: Plywood",
         "sfm":9430
      },{
         "family":"Amana RC-2255",
         "material":"Wood: Softwood",
         "sfm":9430
      },{
         "family":"Amana RC-2252",
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "sfm":11790
      },{
         "family":"Amana RC-2252",
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "sfm":11790
      },{
         "family":"Amana RC-2252",
         "material":"Wood: Hardwood",
         "sfm":11790
      },{
         "family":"Amana RC-2252",
         "material":"Wood: MDF",
         "sfm":11790
      },{
         "family":"Amana RC-2252",
         "material":"Wood: Plywood",
         "sfm":11790
      },{
         "family":"Amana RC-2252",
         "material":"Wood: Softwood",
         "sfm":11790
      }]);
      
      private static var _2044232091chiploadExamples:ArrayCollection = new ArrayCollection([{
         "family":"Seco Jabro-Solid2 JS520 (general)",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.078740157480315,
         "chipload":0.000866141732283465
      },{
         "family":"Seco Jabro-Solid2 JS520 (general)",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.118110236220472,
         "chipload":0.00133858267716535
      },{
         "family":"Seco Jabro-Solid2 JS520 (general)",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.15748031496063,
         "chipload":0.00177165354330709
      },{
         "family":"Seco Jabro-Solid2 JS520 (general)",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.196850393700787,
         "chipload":0.00220472440944882
      },{
         "family":"Seco Jabro-Solid2 JS520 (general)",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.236220472440945,
         "chipload":0.00263779527559055
      },{
         "family":"Seco Jabro-Solid2 JS520 (general)",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.31496062992126,
         "chipload":0.00350393700787402
      },{
         "family":"Seco Jabro-Solid2 JS520 (general)",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.393700787401575,
         "chipload":0.00440944881889764
      },{
         "family":"Seco Jabro-Solid2 JS520 (general)",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.47244094488189,
         "chipload":0.0052755905511811
      },{
         "family":"Seco Jabro-Solid2 JS520 (general)",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.62992125984252,
         "chipload":0.00704724409448819
      },{
         "family":"Seco Jabro-Solid2 JS520 (general)",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.78740157480315,
         "chipload":0.00877952755905512
      },{
         "family":"Seco Jabro-Solid2 JS520 (general)",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.984251968503937,
         "chipload":0.0109842519685039
      },{
         "family":"Lakeshore Carbide VFA - 1 Example",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.25,
         "chipload":0.003
      },{
         "family":"Lakeshore Carbide VFA",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.3125,
         "chipload":0.004
      },{
         "family":"Lakeshore Carbide VFA",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.375,
         "chipload":0.005
      },{
         "family":"Lakeshore Carbide VFA",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.5,
         "chipload":0.006
      },{
         "family":"Lakeshore Carbide VFA",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.625,
         "chipload":0.007
      },{
         "family":"Lakeshore Carbide VFA",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.75,
         "chipload":0.008
      },{
         "family":"Lakeshore Carbide VFA",
         "material":"Aluminum - Wrought (6061)",
         "diameter":0.25,
         "chipload":0.003
      },{
         "family":"Lakeshore Carbide VFA",
         "material":"Aluminum - Wrought (6061)",
         "diameter":1,
         "chipload":0.01
      },{
         "family":"Whiteside 6210",
         "material":"Wood: Hardwood",
         "diameter":1,
         "chipload":0.0022
      },{
         "family":"Whiteside 6210",
         "material":"Wood: MDF",
         "diameter":1,
         "chipload":0.0022
      },{
         "family":"Whiteside 6210",
         "material":"Wood: Plywood",
         "diameter":1,
         "chipload":0.0022
      },{
         "family":"Whiteside 6210",
         "material":"Wood: Softwood",
         "diameter":1,
         "chipload":0.0022
      },{
         "family":"Whiteside 6210",
         "material":"Wood: Hardwood",
         "diameter":1.25,
         "chipload":0.0027
      },{
         "family":"Whiteside 6210",
         "material":"Wood: MDF",
         "diameter":1.25,
         "chipload":0.0027
      },{
         "family":"Whiteside 6210",
         "material":"Wood: Plywood",
         "diameter":1.25,
         "chipload":0.0027
      },{
         "family":"Whiteside 6210",
         "material":"Wood: Softwood",
         "diameter":1.25,
         "chipload":0.0027
      },{
         "family":"Whiteside 6220",
         "material":"Wood: Hardwood",
         "diameter":2,
         "chipload":0.0033
      },{
         "family":"Whiteside 6220",
         "material":"Wood: MDF",
         "diameter":2,
         "chipload":0.0033
      },{
         "family":"Whiteside 6220",
         "material":"Wood: Plywood",
         "diameter":2,
         "chipload":0.0033
      },{
         "family":"Whiteside 6220",
         "material":"Wood: Softwood",
         "diameter":2,
         "chipload":0.0033
      },{
         "family":"Amana RC-2249",
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "diameter":1.5,
         "chipload":0.0042
      },{
         "family":"Amana RC-2249",
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "diameter":1.5,
         "chipload":0.0042
      },{
         "family":"Amana RC-2249",
         "material":"Wood: Hardwood",
         "diameter":1.5,
         "chipload":0.0026
      },{
         "family":"Amana RC-2249",
         "material":"Wood: MDF",
         "diameter":1.5,
         "chipload":0.0053
      },{
         "family":"Amana RC-2249",
         "material":"Wood: Plywood",
         "diameter":1.5,
         "chipload":0.0032
      },{
         "family":"Amana RC-2249",
         "material":"Wood: Softwood",
         "diameter":1.5,
         "chipload":0.0063
      },{
         "family":"Amana RC-2250",
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "diameter":1.5,
         "chipload":0.0011
      },{
         "family":"Amana RC-2250",
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "diameter":1.5,
         "chipload":0.0011
      },{
         "family":"Amana RC-2250",
         "material":"Wood: Hardwood",
         "diameter":1.5,
         "chipload":0.0067
      },{
         "family":"Amana RC-2250",
         "material":"Wood: MDF",
         "diameter":1.5,
         "chipload":0.014
      },{
         "family":"Amana RC-2250",
         "material":"Wood: Plywood",
         "diameter":1.5,
         "chipload":0.0081
      },{
         "family":"Amana RC-2250",
         "material":"Wood: Softwood",
         "diameter":1.5,
         "chipload":0.016
      },{
         "family":"Amana RC-2255",
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "diameter":2,
         "chipload":0.009
      },{
         "family":"Amana RC-2255",
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "diameter":2,
         "chipload":0.009
      },{
         "family":"Amana RC-2255",
         "material":"Wood: Hardwood",
         "diameter":2,
         "chipload":0.006
      },{
         "family":"Amana RC-2255",
         "material":"Wood: MDF",
         "diameter":2,
         "chipload":0.012
      },{
         "family":"Amana RC-2255",
         "material":"Wood: Plywood",
         "diameter":2,
         "chipload":0.007
      },{
         "family":"Amana RC-2255",
         "material":"Wood: Softwood",
         "diameter":2,
         "chipload":0.014
      },{
         "family":"Amana RC-2252",
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "diameter":3.1496,
         "chipload":0.005
      },{
         "family":"Amana RC-2252",
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "diameter":3.1496,
         "chipload":0.005
      },{
         "family":"Amana RC-2252",
         "material":"Wood: Hardwood",
         "diameter":3.1496,
         "chipload":0.0037
      },{
         "family":"Amana RC-2252",
         "material":"Wood: MDF",
         "diameter":3.1496,
         "chipload":0.0062
      },{
         "family":"Amana RC-2252",
         "material":"Wood: Plywood",
         "diameter":3.1496,
         "chipload":0.0037
      },{
         "family":"Amana RC-2252",
         "material":"Wood: Softwood",
         "diameter":3.1496,
         "chipload":0.0075
      }]);
      
      private static var familiesEnabled:Boolean = true;
      
      private static var meOhMiOh:GWizMfgCutterSpecs;
      
      private static const SFM_EXAMPLES_NAME:String = "sfmexamples.csv";
      
      private static const IPT_EXAMPLES_NAME:String = "iptexamples.csv";
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      public var _GWizMfgCutterSpecs_GWizForePanel1:GWizForePanel;
      
      public var _GWizMfgCutterSpecs_GWizForePanel2:GWizForePanel;
      
      public var _GWizMfgCutterSpecs_GWizForePanel3:GWizForePanel;
      
      public var _GWizMfgCutterSpecs_Label1:Label;
      
      private var _90337836_Text:TextInput;
      
      private var _1077049505mfgIPT:GWizNumStepOvr;
      
      private var _1077040212mfgSFM:GWizNumStepOvr;
      
      private var _761230628optLabelGrp:VGroup;
      
      private var _672848025popupGrp:HGroup;
      
      private var _3536189tPop:Button;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var ignoreForePanelThemes:Boolean = true;
      
      private var _166064001labelWidths:int = 90;
      
      private var _1699252388gapSizes:int = 10;
      
      public var recalcFcn:Function;
      
      private var sfmExamplesFieldList:Array;
      
      private var chiploadExamplesFieldList:Array;
      
      private var noSavedFamilies:Boolean = false;
      
      private var _186804323firstColWd:int;
      
      private var _239444057secondColWd:int;
      
      private var _981532858thirdColWd:int;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizMfgCutterSpecs()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this.sfmExamplesFieldList = ["family","material","sfm"];
         this.chiploadExamplesFieldList = ["family","material","diameter","chipload"];
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizMfgCutterSpecs_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_feedsspeeds_GWizMfgCutterSpecsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizMfgCutterSpecs[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.verticalAlign = "middle";
         this.horizontalAlign = "center";
         this.gap = 1;
         this.mxmlContent = [this._GWizMfgCutterSpecs_GWizForePanel1_i(),this._GWizMfgCutterSpecs_GWizForePanel2_i(),this._GWizMfgCutterSpecs_GWizForePanel3_i()];
         this.addEventListener("creationComplete",this.___GWizMfgCutterSpecs_HGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function rebuildFamilyList() : void
      {
         meOhMiOh.invalidateProperties();
      }
      
      public static function familySFM(param1:Number, param2:String) : Number
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc3_:String = meOhMiOh._Text.text;
         if(familiesEnabled && _loc3_ != GWizMfgCutterSpecs.GENERIC_FAMILY && param2 && param2 != "")
         {
            _loc4_ = 0;
            while(_loc4_ < sfmExamples.length)
            {
               if((_loc5_ = sfmExamples.getItemAt(_loc4_)).family == _loc3_ && _loc5_.material == param2)
               {
                  if(param1 != Number(_loc5_.sfm))
                  {
                     param1 = Number(_loc5_.sfm);
                  }
                  break;
               }
               if(_loc4_ > sfmExamples.length)
               {
               }
               _loc4_++;
            }
         }
         return param1;
      }
      
      public static function familyIPT(param1:Number, param2:String, param3:Number) : Number
      {
         var _loc5_:int = 0;
         var _loc6_:Boolean = false;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Object = null;
         var _loc12_:Number = NaN;
         var _loc13_:Object = null;
         var _loc4_:String = meOhMiOh._Text.text;
         if(familiesEnabled && _loc4_ != GWizMfgCutterSpecs.GENERIC_FAMILY && param2 && param2 != "")
         {
            _loc5_ = 0;
            _loc6_ = false;
            while(_loc5_ < chiploadExamples.length && !_loc6_)
            {
               if((_loc11_ = chiploadExamples.getItemAt(_loc5_)).family == _loc4_ && _loc11_.material == param2)
               {
                  _loc6_ = true;
                  while(_loc11_.family == _loc4_ && _loc11_.material == param2 && Number(_loc11_.diameter) < param3 && _loc5_ < chiploadExamples.length)
                  {
                     _loc11_ = chiploadExamples.getItemAt(_loc5_);
                     _loc5_++;
                  }
                  while(_loc5_ > 0 && (_loc11_.family != _loc4_ || _loc11_.material != param2))
                  {
                     _loc5_--;
                     _loc11_ = chiploadExamples.getItemAt(_loc5_);
                  }
                  if((Math.abs(_loc11_.diameter - param3) <= 0.0005 || Number(_loc11_.diameter) >= param3) && _loc11_.family == _loc4_ && _loc11_.material == param2)
                  {
                     _loc9_ = _loc11_.chipload;
                     _loc10_ = _loc11_.diameter;
                     _loc5_--;
                  }
                  if(_loc5_ > 0)
                  {
                     if((_loc13_ = chiploadExamples.getItemAt(_loc5_ - 1)).family == _loc4_ && _loc13_.material == param2)
                     {
                        _loc7_ = _loc13_.chipload;
                        _loc8_ = _loc13_.diameter;
                     }
                  }
                  if(isNaN(_loc7_))
                  {
                     if(!isNaN(_loc9_))
                     {
                        if((_loc12_ = Math.abs(_loc10_ - param3) / param3) < 0.05)
                        {
                           param1 = _loc9_;
                        }
                        else if(_loc12_ < 0.25)
                        {
                           param1 = (param1 + _loc9_) / 2;
                        }
                     }
                  }
                  else if(isNaN(_loc9_))
                  {
                     if(Math.abs(_loc10_ - param3) / param3 < 0.25)
                     {
                        param1 = (param1 + _loc7_) / 2;
                     }
                  }
                  else
                  {
                     if(false && GWizUtils.debug)
                     {
                        GWizUtils.assert(_loc8_ <= param3 && param3 <= _loc10_);
                     }
                     param1 = GWizUtils.interpolate(_loc8_,_loc7_,param3,_loc10_,_loc9_);
                  }
               }
               _loc5_++;
            }
            if(_loc6_)
            {
            }
         }
         return param1;
      }
      
      private static function addAllFamilies() : void
      {
         var _loc1_:Object = new Object();
         addAllFamiliesAux(sfmExamples,_loc1_);
         addAllFamiliesAux(chiploadExamples,_loc1_);
         familyListData.refresh();
      }
      
      private static function addAllFamiliesAux(param1:ArrayCollection, param2:Object) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1.getItemAt(_loc3_);
            if(!param2.hasOwnProperty(_loc4_.family))
            {
               param2[_loc4_.family] = true;
               (_loc5_ = new Object()).label = _loc4_.family;
               familyListData.addItem(_loc5_);
            }
            _loc3_++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizMfgCutterSpecs._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get lockForToolCrib() : Boolean
      {
         return GWizMfgCutterSpecs._1112298178lockForToolCrib;
      }
      
      public static function set lockForToolCrib(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizMfgCutterSpecs._1112298178lockForToolCrib;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizMfgCutterSpecs,"lockForToolCrib",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get familyListData() : ArrayCollection
      {
         return GWizMfgCutterSpecs._768651500familyListData;
      }
      
      public static function set familyListData(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizMfgCutterSpecs._768651500familyListData;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizMfgCutterSpecs,"familyListData",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get sfmExamples() : ArrayCollection
      {
         return GWizMfgCutterSpecs._797302045sfmExamples;
      }
      
      public static function set sfmExamples(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizMfgCutterSpecs._797302045sfmExamples;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizMfgCutterSpecs,"sfmExamples",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get chiploadExamples() : ArrayCollection
      {
         return GWizMfgCutterSpecs._2044232091chiploadExamples;
      }
      
      public static function set chiploadExamples(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizMfgCutterSpecs._2044232091chiploadExamples;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizMfgCutterSpecs,"chiploadExamples",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
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
      
      public function resetFamily() : void
      {
         if(this._Text.text != GENERIC_FAMILY)
         {
            this._Text.text = GENERIC_FAMILY;
         }
      }
      
      override protected function commitProperties() : void
      {
         super.commitProperties();
         familyListData.removeAll();
         var _loc1_:Function = sfmExamples.filterFunction;
         var _loc2_:Function = chiploadExamples.filterFunction;
         if(_loc1_ != null)
         {
            sfmExamples.filterFunction = null;
            sfmExamples.refresh();
            chiploadExamples.filterFunction = null;
            chiploadExamples.refresh();
         }
         addAllFamilies();
         if(_loc1_ != null)
         {
            sfmExamples.filterFunction = _loc1_;
            sfmExamples.refresh();
            chiploadExamples.filterFunction = _loc2_;
            chiploadExamples.refresh();
         }
         GWizUtils.arrayCollectionSort(familyListData,"label",false);
         var _loc3_:ArrayCollection = new ArrayCollection();
         var _loc4_:Object;
         (_loc4_ = new Object()).label = GENERIC_FAMILY;
         _loc3_.addItem(_loc4_);
         var _loc5_:int = 0;
         while(_loc5_ < familyListData.length)
         {
            _loc3_.addItem(familyListData.getItemAt(_loc5_));
            _loc5_++;
         }
         familyListData = _loc3_;
      }
      
      private function onCC() : void
      {
         meOhMiOh = this;
         if(false && !GWizUtils.debug)
         {
            this.removeElement(this.popupGrp);
            familiesEnabled = false;
         }
         this.loadToolFamilies();
         invalidateProperties();
      }
      
      private function mfgPageView(param1:String) : void
      {
         GATracker.logPageView("/Feeds/Speeds/Mfg/" + param1,"/Feeds/Speeds/Mfg/" + param1);
      }
      
      private function recalc() : void
      {
         if(this.recalcFcn != null)
         {
            this.recalcFcn();
         }
         if(this._Text.text != GENERIC_FAMILY)
         {
            this.mfgPageView("ToolFamilySet");
         }
      }
      
      private function doPopup() : void
      {
         var _loc1_:GWizMfgFamilyPopup = GWizMfgFamilyPopup.mfgFamilyPopUp(DisplayObject(this.parentApplication),this._Text,this.saveToolFamilies);
      }
      
      private function set listBuilder(param1:Object) : void
      {
         this.invalidateProperties();
      }
      
      private function loadToolFamilies() : void
      {
         sfmExamples = this.csvPrefLoad(GWizAbstractPrefs.getShareablePrefsFile(SFM_EXAMPLES_NAME),null,sfmExamples);
         chiploadExamples = this.csvPrefLoad(GWizAbstractPrefs.getShareablePrefsFile(IPT_EXAMPLES_NAME),null,chiploadExamples);
         invalidateProperties();
         if(!this.noSavedFamilies)
         {
            this.callLater(this.saveToolFamilies);
            this.noSavedFamilies = false;
         }
      }
      
      private function csvPrefLoad(param1:File, param2:Function = null, param3:ArrayCollection = null) : ArrayCollection
      {
         var _loc5_:FileStream = null;
         var _loc4_:ArrayCollection = null;
         try
         {
            _loc5_ = new FileStream();
            if(param1.exists)
            {
               if(GWizSettings.DEBUG_SHARING)
               {
                  log.debug("Examples File \'" + param1.nativePath + "\'");
               }
               if((_loc4_ = GWizCSVUtils.loadCSVFile(param1,true,true)) && param2 != null)
               {
                  param2(_loc4_);
               }
               else if(!_loc4_)
               {
                  if(param1.exists)
                  {
                     param1.deleteFile();
                  }
               }
            }
            else
            {
               _loc4_ = param3;
               this.noSavedFamilies = true;
            }
         }
         catch(e:Error)
         {
         }
         return _loc4_;
      }
      
      public function saveToolFamilies() : void
      {
         if(sfmExamples)
         {
            sfmExamples.filterFunction = null;
            sfmExamples.refresh();
            GWizCSVUtils.saveCSVFileURL(GWizAbstractPrefs.getShareablePrefsFile(SFM_EXAMPLES_NAME).url,sfmExamples,this.sfmExamplesFieldList);
         }
         if(chiploadExamples)
         {
            chiploadExamples.filterFunction = null;
            chiploadExamples.refresh();
            GWizCSVUtils.saveCSVFileURL(GWizAbstractPrefs.getShareablePrefsFile(IPT_EXAMPLES_NAME).url,chiploadExamples,this.chiploadExamplesFieldList);
         }
      }
      
      public function set ToolFamily(param1:String) : void
      {
         if(!param1 || param1.length <= 0)
         {
            param1 = GENERIC_FAMILY;
         }
         this._Text.text = param1;
         this._Text.invalidateDisplayList();
      }
      
      public function get ToolFamily() : String
      {
         return this._Text.text;
      }
      
      public function clearLocks() : void
      {
         var _loc1_:Boolean = false;
         if(this.mfgSFM && this.mfgIPT)
         {
            if(true || !lockForToolCrib)
            {
               _loc1_ = this.mfgSFM.enabled;
               this.mfgSFM.enabled = true;
               this.mfgIPT.enabled = true;
               this.mfgSFM.resetOverride();
               this.mfgSFM.invalidateDisplayList();
               this.mfgIPT.resetOverride();
               this.mfgIPT.invalidateDisplayList();
               this.mfgSFM.enabled = _loc1_;
               this.mfgIPT.enabled = _loc1_;
            }
         }
      }
      
      public function resetOverride() : void
      {
         this.mfgSFM.resetOverride();
         this.mfgIPT.resetOverride();
      }
      
      private function _GWizMfgCutterSpecs_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.title = "Mfg";
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMfgCutterSpecs_Array2_c);
         _loc1_.id = "_GWizMfgCutterSpecs_GWizForePanel1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMfgCutterSpecs_GWizForePanel1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMfgCutterSpecs_GWizForePanel1",this._GWizMfgCutterSpecs_GWizForePanel1);
         return _loc1_;
      }
      
      private function _GWizMfgCutterSpecs_Array2_c() : Array
      {
         return [this._GWizMfgCutterSpecs_VGroup1_i()];
      }
      
      private function _GWizMfgCutterSpecs_VGroup1_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMfgCutterSpecs_GWizNumStepOvr1_i()];
         _loc1_.id = "optLabelGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.optLabelGrp = _loc1_;
         BindingManager.executeBindings(this,"optLabelGrp",this.optLabelGrp);
         return _loc1_;
      }
      
      private function _GWizMfgCutterSpecs_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Sfc Speed";
         _loc1_.fatSpacer = false;
         _loc1_.stepByPercent = true;
         _loc1_.min = 0;
         _loc1_.max = 50000;
         _loc1_.steps = 1;
         _loc1_.UnitLabel = "sfm";
         _loc1_.toolTip = "Manufacturer\'s recommended surface speed in feet per minute or meters per minute. Orange = custom tool data. This is an optional field. G-Wizard\'s defaults are conservative.";
         _loc1_.addEventListener("change",this.__mfgSFM_change);
         _loc1_.id = "mfgSFM";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.mfgSFM = _loc1_;
         BindingManager.executeBindings(this,"mfgSFM",this.mfgSFM);
         return _loc1_;
      }
      
      public function __mfgSFM_change(param1:Event) : void
      {
         this.mfgPageView("SFM");
         this.recalc();
      }
      
      private function _GWizMfgCutterSpecs_GWizForePanel2_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.labelWidth = 0;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMfgCutterSpecs_Array4_c);
         _loc1_.id = "_GWizMfgCutterSpecs_GWizForePanel2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMfgCutterSpecs_GWizForePanel2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMfgCutterSpecs_GWizForePanel2",this._GWizMfgCutterSpecs_GWizForePanel2);
         return _loc1_;
      }
      
      private function _GWizMfgCutterSpecs_Array4_c() : Array
      {
         return [this._GWizMfgCutterSpecs_GWizNumStepOvr2_i()];
      }
      
      private function _GWizMfgCutterSpecs_GWizNumStepOvr2_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.percentWidth = 100;
         _loc1_.min = 0;
         _loc1_.max = 2;
         _loc1_.steps = 0.00001;
         _loc1_.stepByPercent = true;
         _loc1_.UnitLabel = "ipt";
         _loc1_.fatSpacer = false;
         _loc1_.toolTip = "Manufacturer\'s recommended chipload in inches \ror mm per tooth. Orange = custom tool data. This is an optional field. G-Wizard\'s defaults are conservative.";
         _loc1_.addEventListener("change",this.__mfgIPT_change);
         _loc1_.id = "mfgIPT";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.mfgIPT = _loc1_;
         BindingManager.executeBindings(this,"mfgIPT",this.mfgIPT);
         return _loc1_;
      }
      
      public function __mfgIPT_change(param1:Event) : void
      {
         this.mfgPageView("IPT");
         this.recalc();
      }
      
      private function _GWizMfgCutterSpecs_GWizForePanel3_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.labelWidth = 0;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizMfgCutterSpecs_Array5_c);
         _loc1_.id = "_GWizMfgCutterSpecs_GWizForePanel3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMfgCutterSpecs_GWizForePanel3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMfgCutterSpecs_GWizForePanel3",this._GWizMfgCutterSpecs_GWizForePanel3);
         return _loc1_;
      }
      
      private function _GWizMfgCutterSpecs_Array5_c() : Array
      {
         return [this._GWizMfgCutterSpecs_HGroup2_i()];
      }
      
      private function _GWizMfgCutterSpecs_HGroup2_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.gap = 0;
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizMfgCutterSpecs_Label1_i(),this._GWizMfgCutterSpecs_TextInput1_i(),this._GWizMfgCutterSpecs_Button1_i()];
         _loc1_.id = "popupGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.popupGrp = _loc1_;
         BindingManager.executeBindings(this,"popupGrp",this.popupGrp);
         return _loc1_;
      }
      
      private function _GWizMfgCutterSpecs_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Family: ";
         _loc1_.id = "_GWizMfgCutterSpecs_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizMfgCutterSpecs_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizMfgCutterSpecs_Label1",this._GWizMfgCutterSpecs_Label1);
         return _loc1_;
      }
      
      private function _GWizMfgCutterSpecs_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.editable = false;
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.text = "Generic";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.___Text_valueCommit);
         _loc1_.id = "_Text";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._Text = _loc1_;
         BindingManager.executeBindings(this,"_Text",this._Text);
         return _loc1_;
      }
      
      public function ___Text_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizMfgCutterSpecs_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentHeight = 100;
         _loc1_.setStyle("skinClass",ComboBoxButtonSkin);
         _loc1_.addEventListener("click",this.__tPop_click);
         _loc1_.id = "tPop";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tPop = _loc1_;
         BindingManager.executeBindings(this,"tPop",this.tPop);
         return _loc1_;
      }
      
      public function __tPop_click(param1:MouseEvent) : void
      {
         this.doPopup();
      }
      
      public function ___GWizMfgCutterSpecs_HGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizMfgCutterSpecs_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():*
         {
            return sfmExamples;
         },function(param1:*):void
         {
            listBuilder = param1;
         },"listBuilder");
         result[1] = new Binding(this,function():*
         {
            return chiploadExamples;
         },function(param1:*):void
         {
            listBuilder = param1;
         },"listBuilder");
         result[2] = new Binding(this,null,null,"_GWizMfgCutterSpecs_GWizForePanel1.width","firstColWd");
         result[3] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizMfgCutterSpecs_GWizForePanel1.labelBackgroundColor");
         result[4] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizMfgCutterSpecs_GWizForePanel1.labelColor");
         result[5] = new Binding(this,null,null,"_GWizMfgCutterSpecs_GWizForePanel1.labelWidth","labelWidths");
         result[6] = new Binding(this,null,null,"_GWizMfgCutterSpecs_GWizForePanel1.gapSize","gapSizes");
         result[7] = new Binding(this,function():String
         {
            var _loc1_:* = GWizUtils.FEET_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"mfgSFM.impUnits");
         result[8] = new Binding(this,function():String
         {
            var _loc1_:* = GWizUtils.M_UNITS;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"mfgSFM.metUnits");
         result[9] = new Binding(this,function():Boolean
         {
            return !lockForToolCrib || GWizCribToolEditor.ignoreLockForToolCrib;
         },null,"mfgSFM.enabled");
         result[10] = new Binding(this,null,null,"_GWizMfgCutterSpecs_GWizForePanel2.width","secondColWd");
         result[11] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizMfgCutterSpecs_GWizForePanel2.labelBackgroundColor");
         result[12] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizMfgCutterSpecs_GWizForePanel2.labelColor");
         result[13] = new Binding(this,null,null,"_GWizMfgCutterSpecs_GWizForePanel2.gapSize","gapSizes");
         result[14] = new Binding(this,function():Boolean
         {
            return !lockForToolCrib || GWizCribToolEditor.ignoreLockForToolCrib;
         },null,"mfgIPT.enabled");
         result[15] = new Binding(this,null,null,"_GWizMfgCutterSpecs_GWizForePanel3.width","thirdColWd");
         result[16] = new Binding(this,function():uint
         {
            return ColorPalette.primary3;
         },null,"_GWizMfgCutterSpecs_GWizForePanel3.labelBackgroundColor");
         result[17] = new Binding(this,function():uint
         {
            return ColorPalette.primary5;
         },null,"_GWizMfgCutterSpecs_GWizForePanel3.labelColor");
         result[18] = new Binding(this,null,null,"_GWizMfgCutterSpecs_GWizForePanel3.gapSize","gapSizes");
         result[19] = new Binding(this,function():Boolean
         {
            return !lockForToolCrib || GWizCribToolEditor.ignoreLockForToolCrib;
         },null,"popupGrp.enabled");
         result[20] = new Binding(this,function():uint
         {
            return GWizStylePalette.textColor;
         },function(param1:uint):void
         {
            _GWizMfgCutterSpecs_Label1.setStyle("color",param1);
         },"_GWizMfgCutterSpecs_Label1.color");
         return result;
      }
      
      private function _GWizMfgCutterSpecs_bindingExprs() : void
      {
         var _loc1_:* = undefined;
         this.listBuilder = sfmExamples;
         this.listBuilder = chiploadExamples;
      }
      
      [Bindable(event="propertyChange")]
      public function get _Text() : TextInput
      {
         return this._90337836_Text;
      }
      
      public function set _Text(param1:TextInput) : void
      {
         var _loc2_:Object = this._90337836_Text;
         if(_loc2_ !== param1)
         {
            this._90337836_Text = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_Text",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get mfgIPT() : GWizNumStepOvr
      {
         return this._1077049505mfgIPT;
      }
      
      public function set mfgIPT(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1077049505mfgIPT;
         if(_loc2_ !== param1)
         {
            this._1077049505mfgIPT = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"mfgIPT",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get mfgSFM() : GWizNumStepOvr
      {
         return this._1077040212mfgSFM;
      }
      
      public function set mfgSFM(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1077040212mfgSFM;
         if(_loc2_ !== param1)
         {
            this._1077040212mfgSFM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"mfgSFM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get optLabelGrp() : VGroup
      {
         return this._761230628optLabelGrp;
      }
      
      public function set optLabelGrp(param1:VGroup) : void
      {
         var _loc2_:Object = this._761230628optLabelGrp;
         if(_loc2_ !== param1)
         {
            this._761230628optLabelGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"optLabelGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get popupGrp() : HGroup
      {
         return this._672848025popupGrp;
      }
      
      public function set popupGrp(param1:HGroup) : void
      {
         var _loc2_:Object = this._672848025popupGrp;
         if(_loc2_ !== param1)
         {
            this._672848025popupGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"popupGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tPop() : Button
      {
         return this._3536189tPop;
      }
      
      public function set tPop(param1:Button) : void
      {
         var _loc2_:Object = this._3536189tPop;
         if(_loc2_ !== param1)
         {
            this._3536189tPop = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tPop",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labelWidths() : int
      {
         return this._166064001labelWidths;
      }
      
      public function set labelWidths(param1:int) : void
      {
         var _loc2_:Object = this._166064001labelWidths;
         if(_loc2_ !== param1)
         {
            this._166064001labelWidths = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labelWidths",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gapSizes() : int
      {
         return this._1699252388gapSizes;
      }
      
      public function set gapSizes(param1:int) : void
      {
         var _loc2_:Object = this._1699252388gapSizes;
         if(_loc2_ !== param1)
         {
            this._1699252388gapSizes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gapSizes",_loc2_,param1));
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
      public function get thirdColWd() : int
      {
         return this._981532858thirdColWd;
      }
      
      public function set thirdColWd(param1:int) : void
      {
         var _loc2_:Object = this._981532858thirdColWd;
         if(_loc2_ !== param1)
         {
            this._981532858thirdColWd = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"thirdColWd",_loc2_,param1));
            }
         }
      }
   }
}
