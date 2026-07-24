package post
{
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import machines.GWizMachSettings;
   import mx.collections.ArrayCollection;
   import mx.collections.Sort;
   import mx.collections.SortField;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizCSVUtils;
   import utils.GWizCallChain;
   import utils.GWizUtils;
   
   public class GWizMacroVariables implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizMacroVariables");
      
      private static const NO_TYPE:String = "None";
      
      public static const LVAR_TYPE:String = "LocalVars";
      
      public static const WK_COORD_TYPE:String = "WorkCoord";
      
      public static const WK_COORD48_TYPE:String = "WorkCoord48";
      
      public static const WK_COORD300_TYPE:String = "WorkCoord300";
      
      public static const SYSVAR_TYPE:String = "SysVars";
      
      public static const TOOLTAB_TYPE:String = "ToolTable";
      
      public static const PARAM_TYPE:String = "CallParms";
      
      public static const COMMON_TYPE:String = "CommonVars";
      
      public static var getMacroVarCC:GWizCallChain = new GWizCallChain();
      
      public static var setMacroVarCC:GWizCallChain = new GWizCallChain();
      
      private static var clearMacroVarsCC:GWizCallChain = new GWizCallChain();
      
      public static var getSystemVar:Function = null;
      
      public static var macroValuesDirty:Boolean = false;
      
      public static const G53_XAXIS_VAR:int = 5201;
      
      public static const PLUS48_XAXIS_VAR:int = 6981;
      
      public static const PLUS300_XAXIS_VAR:int = 14001 - 20;
      
      private static var _1268980505varTable:ArrayCollection = new ArrayCollection();
      
      public static var varMap:Object = new Object();
      
      private static var lastSymPound:int = -1;
      
      private static var forcedSyms:ArrayCollection = new ArrayCollection();
      
      private static const MACHINE_INIT_X:Number = 0;
      
      private static const MACHINE_INIT_Y:Number = 0;
      
      private static const MACHINE_INIT_Z:Number = 0;
      
      private static var fieldList:Array = ["number","description","value"];
      
      private static var thisMachine:String = GWizMachSettings.currMachine;
      
      private static var firstLoad:Boolean = true;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var theVariables:ArrayCollection;
      
      private var isWorkOffset:Object;
      
      private var gcodeVarsFile:File;
      
      private var _256977705gcodeVarsXML:XML;
      
      private var dirtyBit:Boolean = false;
      
      private var lastObj:Object = null;
      
      private var sendUpGet:Boolean = true;
      
      private var sendUpSet:Boolean = true;
      
      private var workOffsetAliases:Object;
      
      private var dumpVar:int = 5221;
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizMacroVariables()
      {
         this.isWorkOffset = new Object();
         this.workOffsetAliases = new Object();
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
         this.theVariables = new ArrayCollection();
         this.addItemAux({
            "number":0,
            "description":"Always empty or vacant - NaN",
            "value":NaN
         },NO_TYPE,true);
         this.addItemAux({
            "number":1,
            "description":"A",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":2,
            "description":"B",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":3,
            "description":"C",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":4,
            "description":"I",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":5,
            "description":"J",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":6,
            "description":"K",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":7,
            "description":"D",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":8,
            "description":"E",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":9,
            "description":"F",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":10,
            "description":"G x",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":11,
            "description":"H",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":12,
            "description":"L x",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":13,
            "description":"M",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":14,
            "description":"N x",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":15,
            "description":"O x",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":16,
            "description":"P x",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":17,
            "description":"Q",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":18,
            "description":"R",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":19,
            "description":"S",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":20,
            "description":"T",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":21,
            "description":"U",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":22,
            "description":"V",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":23,
            "description":"W",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":24,
            "description":"X",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":25,
            "description":"Y",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":26,
            "description":"Z",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":27,
            "description":"Local Var",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":28,
            "description":"Local Var",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":29,
            "description":"Local Var",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":30,
            "description":"Local Var",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":31,
            "description":"Local Var",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":32,
            "description":"Local Var",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":33,
            "description":"Local Var",
            "value":NaN
         },LVAR_TYPE);
         this.addItemAux({
            "number":1032,
            "description":"Unified input of UI000 to UI015",
            "value":NaN
         },SYSVAR_TYPE);
         this.addItemAux({
            "number":1132,
            "description":"Unified output of Uo000 to UO015",
            "value":NaN
         },SYSVAR_TYPE);
         this.addItemAux({
            "number":1133,
            "description":"Unified output of UO100 to UO131",
            "value":NaN
         },SYSVAR_TYPE);
         this.addItemAux({
            "number":3000,
            "description":"Alarm",
            "value":NaN
         },SYSVAR_TYPE);
         this.addItemAux({
            "number":3001,
            "description":"Clock 1 (unit: 1ms)",
            "value":0
         },SYSVAR_TYPE);
         this.addItemAux({
            "number":3002,
            "description":"Clock 2 (unit: 1 hour)",
            "value":NaN
         },SYSVAR_TYPE);
         this.addItemAux({
            "number":3003,
            "description":"Automatic Operation Control: Single Blk",
            "value":0
         },SYSVAR_TYPE);
         this.addItemAux({
            "number":3004,
            "description":"Automatic Operation Control: Feed Hold",
            "value":0
         },SYSVAR_TYPE);
         this.addItemAux({
            "number":3005,
            "description":"Settings Read/Write Mode",
            "value":NaN
         },SYSVAR_TYPE);
         this.addItemAux({
            "number":3007,
            "description":"Mirror Image Status of the Axes",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":3011,
            "description":"Clock:  Year, month, day",
            "value":NaN
         },SYSVAR_TYPE);
         this.addItemAux({
            "number":3012,
            "description":"Clock:  Hour, minute, second",
            "value":NaN
         },SYSVAR_TYPE);
         this.addItemAux({
            "number":3402,
            "description":"Selected plane: 0=G17, 1=G18, 2=G19",
            "value":NaN
         },SYSVAR_TYPE);
         this.addItemAux({
            "number":3901,
            "description":"No. of parts machined",
            "value":NaN
         },SYSVAR_TYPE);
         this.addItemAux({
            "number":3902,
            "description":"No. of parts required",
            "value":NaN
         },SYSVAR_TYPE);
         this.addItemAux({
            "number":4001,
            "description":"Modal Info: G code group 01",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4002,
            "description":"Modal Info: G code group 02",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4003,
            "description":"Modal Info: G code group 03",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4004,
            "description":"Modal Info: G code group 04",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4005,
            "description":"Modal Info: G code group 05",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4006,
            "description":"Modal Info: G code group 06",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4007,
            "description":"Modal Info: G code group 07",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4008,
            "description":"Modal Info: G code group 08",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4009,
            "description":"Modal Info: G code group 09",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4010,
            "description":"Modal Info: G code group 10",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4011,
            "description":"Modal Info: G code group 11",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4012,
            "description":"Modal Info: G code group 12",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4013,
            "description":"Modal Info: G code group 13",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4014,
            "description":"Modal Info: G code group 14",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4015,
            "description":"Modal Info: G code group 15",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4016,
            "description":"Modal Info: G code group 16",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4017,
            "description":"Modal Info: G code group 17",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4018,
            "description":"Modal Info: G code group 18",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4019,
            "description":"Modal Info: G code group 19",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4020,
            "description":"Modal Info: G code group 20",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4021,
            "description":"Modal Info: G code group 21",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4022,
            "description":"Modal Info: G code group 22",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4102,
            "description":"Modal Info: B code",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4107,
            "description":"Modal Info: D code",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4109,
            "description":"Modal Info: F code",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4111,
            "description":"Modal Info: H code",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4113,
            "description":"Modal Info: M code",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4114,
            "description":"Sequence number",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4115,
            "description":"Program number",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4119,
            "description":"Modal Info: S code",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4120,
            "description":"Modal Info: T code",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.addItemAux({
            "number":4130,
            "description":"Modal Info: P code",
            "value":NaN
         },SYSVAR_TYPE,true);
         this.initEntries();
         this.setVolatility(null,100000);
         GWizMachSettings.deleteMachineCC.addFunction("GWizMacroVariables",this.deleteMachine);
         GWizMachSettings.selectMachineCC.addFunction("GWizMacroVariables",this.selectMachine);
      }
      
      public static function workOffsetVariable(param1:int, param2:int) : int
      {
         return param2 + param1 * 20;
      }
      
      public static function varName(param1:Number) : String
      {
         var _loc3_:Object = null;
         var _loc2_:* = "";
         if(param1 == 0)
         {
            _loc2_ = "Always null";
         }
         else if(0 < param1 && param1 < GWizSettings.post.GCodeVariables.theVariables.length)
         {
            _loc3_ = GWizSettings.post.GCodeVariables.getMacroVar(param1);
            if(_loc3_ && _loc3_.hasOwnProperty("description"))
            {
               _loc2_ = _loc3_.description;
            }
         }
         else if(GWizSettings.post.LinuxCNCNamedParms && param1 >= GWizSettings.post.LinuxCNCFirstNamedParm)
         {
            _loc2_ = lookupNameFromVarNumber(String(param1));
         }
         if(_loc2_.length > 0)
         {
            _loc2_ = "(" + _loc2_ + ")";
         }
         return _loc2_;
      }
      
      public static function macVarChange(param1:Object) : Boolean
      {
         if(param1 && param1.hasOwnProperty("number") && param1.hasOwnProperty("value"))
         {
            if(!param1.hasOwnProperty("gcode") || param1.gcode)
            {
               addVar(param1.number,param1.value);
            }
         }
         return true;
      }
      
      public static function addVar(param1:int, param2:Number, param3:String = "") : void
      {
         var _loc4_:Object = null;
         if(!varMap.hasOwnProperty(String(param1)))
         {
            (_loc4_ = new Object()).pound = param1;
            _loc4_.value = param2;
            _loc4_.name = param3;
            varTable.addItemAt(_loc4_,varTable.length);
            varMap[String(param1)] = varTable.length - 1;
         }
         _loc4_ = varTable.getItemAt(varMap[String(param1)]);
         GWizUtils.assert(_loc4_.pound == param1);
         if(param3 != "")
         {
            _loc4_.name = param3;
         }
         else
         {
            _loc4_.value = param2;
         }
         varTable.refresh();
      }
      
      public static function clearLinuxCNCSymbolCounter() : void
      {
         lastSymPound = -1;
      }
      
      public static function allocNewSymbol(param1:String, param2:int = -1) : int
      {
         var _loc3_:int = 0;
         if(param2 == -1)
         {
            if(lastSymPound < 0)
            {
               lastSymPound = GWizSettings.post.LinuxCNCFirstNamedParm - 1;
            }
            ++lastSymPound;
            _loc3_ = lastSymPound;
         }
         else
         {
            registerForcedSymbol(param1,param2);
            _loc3_ = param2;
         }
         addVar(_loc3_,NaN,param1);
         return _loc3_;
      }
      
      public static function lookupVar(param1:String, param2:Boolean = true) : int
      {
         var _loc5_:Object = null;
         var _loc3_:int = -1;
         var _loc4_:int = 0;
         while(_loc4_ < varTable.length)
         {
            if((_loc5_ = varTable.getItemAt(_loc4_)).name == param1)
            {
               _loc3_ = _loc5_.pound;
               break;
            }
            _loc4_++;
         }
         if(_loc3_ < 0 && param2)
         {
            _loc3_ = allocNewSymbol(param1);
         }
         return _loc3_;
      }
      
      public static function lookupNameFromVarNumber(param1:String) : String
      {
         var _loc5_:Object = null;
         var _loc2_:int = int(Number(param1));
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         while(_loc4_ < varTable.length)
         {
            if((_loc5_ = varTable.getItemAt(_loc4_)).pound == _loc2_)
            {
               param1 = _loc5_.name;
               break;
            }
            _loc4_++;
         }
         return param1;
      }
      
      public static function addSETVN(param1:String, param2:int) : void
      {
         addVar(param2,NaN,param1);
      }
      
      private static function registerForcedSymbol(param1:String, param2:int) : void
      {
         var _loc3_:Object = {
            "name":param1,
            "pound":param2
         };
         forcedSyms.addItem(_loc3_);
      }
      
      public static function clearVars() : void
      {
         var _loc1_:ArrayCollection = null;
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(GWizSettings.post.LinuxCNCNamedParms)
         {
            _loc1_ = new ArrayCollection();
            _loc3_ = 0;
            while(_loc3_ < varTable.length)
            {
               _loc2_ = varTable.getItemAt(_loc3_);
               if(_loc2_.hasOwnProperty("name"))
               {
                  _loc1_.addItem(_loc2_);
               }
               _loc3_++;
            }
         }
         varTable.removeAll();
         varTable = null;
         varMap = null;
         varTable = new ArrayCollection();
         varMap = new Object();
         _loc3_ = 0;
         while(_loc3_ < forcedSyms.length)
         {
            _loc4_ = forcedSyms.getItemAt(_loc3_);
            allocNewSymbol(_loc4_.name,_loc4_.pound);
            _loc3_++;
         }
         if(_loc1_)
         {
            clearLinuxCNCSymbolCounter();
            _loc3_ = 0;
            while(_loc3_ < _loc1_.length)
            {
               _loc2_ = _loc1_.getItemAt(_loc3_);
               if(_loc2_.hasOwnProperty("name") && _loc2_.name != "" && _loc2_.pound >= GWizSettings.post.LinuxCNCFirstNamedParm)
               {
                  allocNewSymbol(_loc2_.name);
                  if(false && GWizUtils.debug)
                  {
                     log.debug("Saving named parm \'" + _loc4_.name + "\' = #" + _loc4_.pound);
                  }
               }
               _loc3_++;
            }
            _loc1_.removeAll();
            _loc1_ = null;
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get varTable() : ArrayCollection
      {
         return GWizMacroVariables._1268980505varTable;
      }
      
      public static function set varTable(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizMacroVariables._1268980505varTable;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizMacroVariables,"varTable",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      public function setVolatility(param1:ArrayCollection, param2:int = 999) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc5_:int = Math.min(this.theVariables.length,param2);
         _loc3_ = 0;
         while(_loc3_ < _loc5_)
         {
            if(!(_loc4_ = this.theVariables.getItemAt(_loc3_)).volatile)
            {
               _loc4_.volatile = true;
            }
            _loc3_++;
         }
         if(param1)
         {
            _loc6_ = 0;
            while(_loc6_ < param1.length)
            {
               _loc8_ = (_loc7_ = param1.getItemAt(_loc6_)).first;
               _loc9_ = _loc7_.last;
               _loc3_ = _loc8_;
               while(_loc3_ <= _loc9_)
               {
                  if(0 <= _loc3_ && _loc3_ < this.theVariables.length)
                  {
                     (_loc4_ = this.theVariables.getItemAt(_loc3_)).volatile = false;
                  }
                  _loc3_++;
               }
               _loc6_++;
            }
         }
      }
      
      public function forceSaveVariables(param1:Boolean = false) : void
      {
         if(param1)
         {
            this.setDirty();
         }
         this.saveVariables(thisMachine);
      }
      
      public function setDirty() : void
      {
         this.dirtyBit = true;
      }
      
      public function resetMacVars() : void
      {
         GWizSettings.saveGCVars = false;
         this.gcodeVarsFile.deleteFile();
         GWizPopUpManager.Show("Please Exit and Restart to load the reset macro variables.","Reset Complete");
      }
      
      public function clearMacroVars() : void
      {
         clearMacroVarsCC.callChain(null);
      }
      
      public function getVar(param1:int, param2:Boolean) : Number
      {
         var _loc4_:Number = NaN;
         var _loc3_:Object = this.getMacroVar(param1);
         if(!_loc3_ || !_loc3_.hasOwnProperty("value"))
         {
            _loc4_ = NaN;
            if(this.isWorkOffset.hasOwnProperty(String(param1)))
            {
               _loc4_ = 0;
            }
         }
         else
         {
            _loc4_ = _loc3_.value;
         }
         if(this.sendUpGet && _loc3_)
         {
            _loc3_.gcode = param2;
            getMacroVarCC.callChain(_loc3_);
         }
         return _loc4_;
      }
      
      public function setVar(param1:int, param2:Number, param3:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         if(!isNaN(param1))
         {
            _loc4_ = this.lookupMacroVarNum(param1);
            _loc5_ = null;
            if(_loc4_ != -1)
            {
               (_loc5_ = this.theVariables.getItemAt(_loc4_)).number = param1;
               _loc5_.value = param2;
            }
            else
            {
               _loc5_ = this.addMacVar(param1,param2);
            }
            if(this.sendUpSet)
            {
               _loc5_.gcode = param3;
               setMacroVarCC.callChain(_loc5_);
            }
            macroValuesDirty = true;
         }
      }
      
      public function setWearOffset(param1:int, param2:Number, param3:Boolean) : void
      {
         if(param1 == 0)
         {
            return;
         }
         this.setDirty();
         param1 += 12000;
         this.setVar(param1,param2,param3);
      }
      
      public function setLengthOffset(param1:int, param2:Number, param3:Boolean) : void
      {
         if(param1 == 0)
         {
            return;
         }
         this.setDirty();
         param1 += 11000;
         this.setVar(param1,param2,param3);
      }
      
      public function getLengthOffset(param1:int, param2:Boolean) : Number
      {
         if(param1 == 0)
         {
            return 0;
         }
         var _loc3_:* = param1 < 0;
         param1 = Math.abs(param1);
         param1 += 11000;
         var _loc4_:Number = this.getVar(param1,param2);
         if(_loc3_)
         {
            _loc4_ = -_loc4_;
         }
         return _loc4_;
      }
      
      public function getWearOffset(param1:int, param2:Boolean) : Number
      {
         if(param1 == 0)
         {
            return 0;
         }
         param1 += 12000;
         return this.getVar(param1,param2);
      }
      
      public function setWorkOffset(param1:int, param2:int, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number, param9:Boolean) : void
      {
         var _loc10_:int = workOffsetVariable(param1,param2);
         this.setValueIfNotNaN(_loc10_,param3,param9);
         this.setValueIfNotNaN(_loc10_ + 1,param4,param9);
         this.setValueIfNotNaN(_loc10_ + 2,param5,param9);
         this.setValueIfNotNaN(_loc10_ + 3,param6,param9);
         this.setValueIfNotNaN(_loc10_ + 4,param7,param9);
         this.setValueIfNotNaN(_loc10_ + 5,param8,param9);
      }
      
      public function getItemAt(param1:int) : Object
      {
         return this.theVariables.getItemAt(param1);
      }
      
      public function refresh() : Boolean
      {
         return this.theVariables.refresh();
      }
      
      public function get length() : int
      {
         return this.theVariables.length;
      }
      
      public function dataProvider() : ArrayCollection
      {
         return this.theVariables;
      }
      
      public function set filterFunction(param1:Function) : void
      {
         this.theVariables.filterFunction = param1;
      }
      
      private function getGenericDesc(param1:int) : String
      {
         var _loc2_:String = "";
         if(1 <= param1 && param1 <= 33)
         {
            _loc2_ = "Local Var";
         }
         else if(100 <= param1 && param1 <= 199 || 500 <= param1 && param1 <= 999)
         {
            _loc2_ = "Common Var";
         }
         else if(param1 > 1000)
         {
            _loc2_ = "System Var";
         }
         else
         {
            _loc2_ = "Other";
         }
         return _loc2_;
      }
      
      private function setValueIfNotNaN(param1:int, param2:Number, param3:Boolean) : void
      {
         if(!isNaN(param2))
         {
            this.setVar(param1,param2,param3);
         }
      }
      
      private function addItemAux(param1:Object, param2:String = "None", param3:Boolean = false) : void
      {
         param1.type = param2;
         param1.ro = param3;
         this.theVariables.addItem(param1);
      }
      
      private function loadVariablesAux(param1:int, param2:int, param3:String, param4:int, param5:String = "None") : void
      {
         var _loc6_:Object = null;
         (_loc6_ = new Object()).number = param1 + param4;
         _loc6_.description = param3 + param2;
         _loc6_.value = NaN;
         this.addItemAux(_loc6_,param5);
      }
      
      private function loadVariablesAuxEP(param1:int, param2:String, param3:String, param4:String = "None", param5:Boolean = false, param6:Number = NaN) : void
      {
         var _loc7_:Object = null;
         (_loc7_ = new Object()).number = param1;
         _loc7_.description = param2 + param3;
         _loc7_.value = param6;
         this.addItemAux(_loc7_,param4,param5);
      }
      
      private function loadVariablesAuxWO(param1:int, param2:String, param3:String = "None") : void
      {
         this.isWorkOffset[String(param1)] = true;
         this.isWorkOffset[String(param1 + 1)] = true;
         this.isWorkOffset[String(param1 + 2)] = true;
         this.isWorkOffset[String(param1 + 3)] = true;
         this.loadVariablesAuxEP(param1,param2," workpiece zero point offset X",param3,false,0);
         this.loadVariablesAuxEP(param1 + 1,param2," workpiece zero point offset Y",param3,false,0);
         this.loadVariablesAuxEP(param1 + 2,param2," workpiece zero point offset Z",param3,false,0);
         this.loadVariablesAuxEP(param1 + 3,param2," workpiece zero point offset 4th axis",param3,false,0);
      }
      
      private function initEntries() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc4_:int = 0;
         _loc1_ = 100;
         while(_loc1_ <= 199)
         {
            _loc2_ = new Object();
            _loc2_.number = _loc1_;
            _loc2_.description = "Volatile Common Variable";
            _loc2_.value = NaN;
            this.addItemAux(_loc2_,COMMON_TYPE);
            _loc1_++;
         }
         _loc1_ = 500;
         while(_loc1_ <= 999)
         {
            _loc2_ = new Object();
            _loc2_.number = _loc1_;
            _loc2_.description = "Non-volatile Common Variable";
            _loc2_.value = NaN;
            this.addItemAux(_loc2_,COMMON_TYPE);
            _loc1_++;
         }
         _loc1_ = 1000;
         while(_loc1_ <= 1015)
         {
            _loc2_ = new Object();
            _loc2_.number = _loc1_;
            _loc2_.description = "Interface Input Signals corresponding to UI000 to UI015";
            _loc2_.value = NaN;
            this.addItemAux(_loc2_,SYSVAR_TYPE,true);
            _loc1_++;
         }
         _loc2_ = new Object();
         _loc2_.number = 1032;
         _loc2_.description = "Interface Input Signals for all bits in UI000 to UI015";
         _loc2_.value = NaN;
         this.addItemAux(_loc2_,SYSVAR_TYPE,true);
         _loc1_ = 1100;
         while(_loc1_ <= 1115)
         {
            _loc2_ = new Object();
            _loc2_.number = _loc1_;
            _loc2_.description = "Interface Output Signals corresponding to UO000 to UO015";
            _loc2_.value = NaN;
            this.addItemAux(_loc2_,SYSVAR_TYPE);
            _loc1_++;
         }
         _loc2_ = new Object();
         _loc2_.number = 1132;
         _loc2_.description = "Interface Output Signals for all bits in UO000 to UO015";
         _loc2_.value = NaN;
         this.addItemAux(_loc2_,SYSVAR_TYPE);
         _loc2_ = new Object();
         _loc2_.number = 1133;
         _loc2_.description = "Interface Output Signals for all bits in UO000 to UO032";
         _loc2_.value = NaN;
         this.addItemAux(_loc2_,SYSVAR_TYPE);
         var _loc3_:int = 1;
         _loc1_ = 1;
         while(_loc1_ <= 99)
         {
            if(_loc1_ <= 64)
            {
               this.loadVariablesAux(_loc1_,_loc3_,"X-Axis wear offset values (offsets 1-64), offset ",2000,SYSVAR_TYPE);
               this.loadVariablesAux(_loc1_,_loc3_,"Z-Axis wear offset values (offsets 1-64), offset ",2100,SYSVAR_TYPE);
               this.loadVariablesAux(_loc1_,_loc3_,"Tool nose radius compensation (wear offsets 1-64), offset ",2200,SYSVAR_TYPE);
               this.loadVariablesAux(_loc1_,_loc3_,"Tool nose radius compensation (geometry offsets 1-64), offset ",2900,SYSVAR_TYPE);
               this.loadVariablesAux(_loc1_,_loc3_,"Imaginary tool tip position (offsets 1-64), offset ",2300,SYSVAR_TYPE);
            }
            if(_loc1_ <= 49)
            {
               this.loadVariablesAux(_loc1_,_loc3_,"X-Axis geometry offset values (offsets 1-49), offset ",2700,SYSVAR_TYPE);
               this.loadVariablesAux(_loc1_,_loc3_,"Z-Axis geometry offset values (offsets 1-49), offset ",2800,SYSVAR_TYPE);
               this.loadVariablesAux(_loc1_,_loc3_,"Y-Axis wear offset values (offsets 1-49), offset ",2400,SYSVAR_TYPE);
               this.loadVariablesAux(_loc1_,_loc3_,"Y-Axis geometry offset values (offsets 1-49), offset ",2450,SYSVAR_TYPE);
            }
            if(_loc1_ <= 99)
            {
               this.loadVariablesAux(_loc1_,_loc3_,"X-Axis wear offset values (offsets 1-99), offset ",10000,SYSVAR_TYPE);
               this.loadVariablesAux(_loc1_,_loc3_,"X-Axis geometry offset values (offsets 1-99), offset ",15000,SYSVAR_TYPE);
               this.loadVariablesAux(_loc1_,_loc3_,"Z-Axis geometry offset values (offsets 1-99), offset ",16000,SYSVAR_TYPE);
               this.loadVariablesAux(_loc1_,_loc3_,"Tool nose radius compensation (geometry offsets 1-99), offset ",17000,SYSVAR_TYPE);
               this.loadVariablesAux(_loc1_,_loc3_,"Imaginary tool tip position (offsets 1-99), offset ",13000,SYSVAR_TYPE);
               this.loadVariablesAux(_loc1_,_loc3_,"Y-Axis wear offset values (offsets 1-99), offset ",14000,SYSVAR_TYPE);
               this.loadVariablesAux(_loc1_,_loc3_,"Y-Axis geometry offset values (offsets 1-99), offset ",19000,SYSVAR_TYPE);
            }
            _loc3_++;
            _loc1_++;
         }
         _loc3_ = 1;
         _loc1_ = 1;
         while(_loc1_ <= 400)
         {
            this.loadVariablesAux(_loc1_,_loc3_,"Tool length offset values, T",11000,TOOLTAB_TYPE);
            this.loadVariablesAux(_loc1_,_loc3_,"Tool comp wear offset values, T",12000,TOOLTAB_TYPE);
            _loc3_++;
            _loc1_++;
         }
         this.loadVariablesAuxEP(5001,"Block end position (workpiece coordinate), ","X",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5002,"Block end position (workpiece coordinate), ","Y",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5003,"Block end position (workpiece coordinate), ","Z",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5021,"Current position (machine coordinate), ","X",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5022,"Current position (machine coordinate), ","Y",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5023,"Current position (machine coordinate), ","Z",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5041,"Current position (workpiece coordinate), ","X",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5042,"Current position (workpiece coordinate), ","Y",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5043,"Current position (workpiece coordinate), ","Z",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5061,"Skip signal position (workpiece coordinate), ","X",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5062,"Skip signal position (workpiece coordinate), ","Y",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5063,"Skip signal position (workpiece coordinate), ","Z",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5081,"Tool offset value, ","X",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5082,"Tool offset value, ","Y",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5083,"Tool offset value, ","Z",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5101,"Servo position deviation, ","X",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5102,"Servo position deviation, ","Y",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5103,"Servo position deviation, ","Z",SYSVAR_TYPE,true);
         this.loadVariablesAuxEP(5161,"G28 Home, ","X",SYSVAR_TYPE,false,MACHINE_INIT_X);
         this.loadVariablesAuxEP(5162,"G28 Home, ","Y",SYSVAR_TYPE,false,MACHINE_INIT_Y);
         this.loadVariablesAuxEP(5163,"G28 Home, ","Z",SYSVAR_TYPE,false,MACHINE_INIT_Z);
         this.loadVariablesAuxEP(5164,"G28 Home, ","A",SYSVAR_TYPE,false,0);
         this.loadVariablesAuxEP(5165,"G28 Home, ","B",SYSVAR_TYPE,false,0);
         this.loadVariablesAuxEP(5166,"G28 Home, ","C",SYSVAR_TYPE,false,0);
         this.loadVariablesAuxEP(5181,"G30 Home, ","X",SYSVAR_TYPE,false,0);
         this.loadVariablesAuxEP(5182,"G30 Home, ","Y",SYSVAR_TYPE,false,0);
         this.loadVariablesAuxEP(5183,"G30 Home, ","Z",SYSVAR_TYPE,false,1);
         this.loadVariablesAuxEP(5184,"G30 Home, ","A",SYSVAR_TYPE,false,0);
         this.loadVariablesAuxEP(5185,"G30 Home, ","B",SYSVAR_TYPE,false,0);
         this.loadVariablesAuxEP(5186,"G30 Home, ","C",SYSVAR_TYPE,false,0);
         this.loadVariablesAuxEP(5201,"External workpiece zero point offset, ","X",SYSVAR_TYPE);
         this.loadVariablesAuxEP(5202,"External workpiece zero point offset, ","Y",SYSVAR_TYPE);
         this.loadVariablesAuxEP(5203,"External workpiece zero point offset, ","Z",SYSVAR_TYPE);
         this.loadVariablesAuxEP(5211,"G92 offset, ","X",SYSVAR_TYPE);
         this.loadVariablesAuxEP(5212,"G92 offset, ","Y",SYSVAR_TYPE);
         this.loadVariablesAuxEP(5213,"G92 offset, ","Z",SYSVAR_TYPE);
         this.loadVariablesAuxEP(5214,"G92 offset, ","A",SYSVAR_TYPE);
         this.loadVariablesAuxEP(5215,"G92 offset, ","B",SYSVAR_TYPE);
         this.loadVariablesAuxEP(5216,"G92 offset, ","C",SYSVAR_TYPE);
         this.loadVariablesAuxEP(5220,"Selected coordinate system","",SYSVAR_TYPE);
         _loc1_ = 0;
         while(_loc1_ <= 9)
         {
            this.loadVariablesAux(_loc1_,_loc1_ + 9010,"Macro call using G-code O",6050,PARAM_TYPE);
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ <= 9)
         {
            this.loadVariablesAux(_loc1_,_loc1_ + 9000,"Sub-Program call using M-code O",6070,PARAM_TYPE);
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ <= 9)
         {
            this.loadVariablesAux(_loc1_,_loc1_ + 9020,"Macro call using M-code O",6080,PARAM_TYPE);
            _loc1_++;
         }
         this.initWOAliases();
         _loc1_ = 0;
         while(_loc1_ < 7)
         {
            _loc4_ = 5200 + _loc1_ * 20 + 1;
            this.loadVariablesAuxWO(_loc4_,"G" + String(53 + _loc1_),WK_COORD_TYPE);
            _loc1_++;
         }
         _loc1_ = 1;
         while(_loc1_ <= 48)
         {
            _loc4_ = 6981 + _loc1_ * 20;
            this.loadVariablesAuxWO(_loc4_,"G54.1 P" + String(_loc1_),WK_COORD48_TYPE);
            _loc1_++;
         }
         _loc1_ = 1;
         while(_loc1_ <= 300)
         {
            this.loadVariablesAuxWO(14001 + _loc1_ * 20,"G54.1 P" + String(_loc1_),WK_COORD300_TYPE);
            _loc1_++;
         }
         var _loc5_:SortField;
         (_loc5_ = new SortField()).name = "number";
         _loc5_.numeric = true;
         var _loc6_:Sort;
         (_loc6_ = new Sort()).fields = [_loc5_];
         this.theVariables.sort = _loc6_;
         this.theVariables.refresh();
      }
      
      private function deleteMachine(param1:String) : Boolean
      {
         return true;
      }
      
      private function selectMachine(param1:String) : Boolean
      {
         if(param1.length > 0)
         {
            if(param1 != thisMachine && !firstLoad)
            {
               this.saveVariables(thisMachine);
            }
            thisMachine = param1;
            this.loadVariables(param1);
            firstLoad = false;
         }
         return true;
      }
      
      private function loadVariables(param1:String) : void
      {
         var stream:FileStream = null;
         var machine:String = param1;
         if(!GWizMachSettings.MachinesList || GWizSettings.loginBar.appNameParm != "GWizardE")
         {
            return;
         }
         var csvFormat:Boolean = true;
         this.gcodeVarsFile = GWizSettings.getPrefsFile("gcvars" + GWizMachSettings.controllerFor(machine) + ".csv");
         if(!this.gcodeVarsFile.exists && false)
         {
            csvFormat = false;
            this.gcodeVarsFile = GWizSettings.getPrefsFile("gcvars" + GWizMachSettings.controllerFor(machine) + ".xml");
         }
         try
         {
            stream = new FileStream();
            if(this.gcodeVarsFile.exists)
            {
               stream.open(this.gcodeVarsFile,FileMode.READ);
               if(csvFormat)
               {
                  this.processCSVData(this.gcodeVarsFile);
               }
               else
               {
                  this.processXMLData(stream);
                  this.dirtyBit = true;
               }
               stream.close();
            }
            else
            {
               this.dirtyBit = true;
               this.saveVariables(machine);
            }
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error loading g-code macro variables.");
         }
         this.forceSaveVariables(true);
      }
      
      private function processXMLData(param1:FileStream) : void
      {
         var _loc4_:Object = null;
         this.gcodeVarsXML = XML(param1.readUTFBytes(param1.bytesAvailable));
         param1.close();
         var _loc2_:ArrayCollection = GWizUtils.XMLToArrayCollection(this.gcodeVarsXML);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_.getItemAt(_loc3_);
            if(!this.isAliased(_loc4_.number))
            {
               this.setVar(_loc4_.number,_loc4_.value,false);
            }
            _loc3_++;
         }
      }
      
      private function processCSVData(param1:File) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc2_:ArrayCollection = GWizCSVUtils.loadCSVFile(param1,true,false,fieldList,"This file keeps the values of your macro variables. You can ignore the error and it\'ll reset next time you start up.");
         if(_loc2_)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               _loc4_ = _loc2_.getItemAt(_loc3_);
               if(!this.isAliased(_loc4_.number))
               {
                  this.setVar(_loc4_.number,_loc4_.value,false);
               }
               _loc3_++;
            }
         }
      }
      
      private function saveVariables(param1:String) : void
      {
         var item:Object = null;
         var stream:FileStream = null;
         var machine:String = param1;
         if(!GWizSettings.saveGCVars || !this.dirtyBit || GWizSettings.loginBar.appNameParm != "GWizardE")
         {
            return;
         }
         var ac:ArrayCollection = new ArrayCollection();
         var i:int = 0;
         while(i < this.theVariables.length)
         {
            item = this.theVariables.getItemAt(i);
            if((item.volatile == false || item.number > 999) && !isNaN(item.value) && !this.isAliased(item.number))
            {
               if(!this.isWorkOffset.hasOwnProperty(String(item.number)) || item.value != 0)
               {
                  ac.addItem(item);
               }
            }
            i++;
         }
         var buffer:String = GWizCSVUtils.arrayColToCSV(ac,",",fieldList);
         try
         {
            if(buffer != "")
            {
               this.gcodeVarsFile = GWizSettings.getPrefsFile("gcvars" + GWizMachSettings.controllerFor(machine) + ".csv");
               stream = new FileStream();
               stream.open(this.gcodeVarsFile,FileMode.WRITE);
               stream.writeUTFBytes(buffer);
               stream.close();
            }
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error saving g-code macro variables.");
            log.debug("Error saving macro vars: " + e.message);
         }
         this.dirtyBit = false;
      }
      
      private function saveVariablesXML(param1:String) : void
      {
         var item:Object = null;
         var stream:FileStream = null;
         var machine:String = param1;
         if(!GWizSettings.saveGCVars || !this.dirtyBit)
         {
            return;
         }
         var outputString:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
         outputString += "<root>\n";
         var i:int = 0;
         while(i < this.theVariables.length)
         {
            item = this.theVariables.getItemAt(i);
            if((item.volatile == false || i > 999) && !isNaN(item.value))
            {
               outputString += "  <item>\n";
               outputString += "    <number>" + item.number + "</number>\n";
               outputString += "    <description>" + item.description + "</description>\n";
               outputString += "    <value>" + item.value + "</value>\n";
               outputString += "  </item>\n";
            }
            i++;
         }
         outputString += "</root>\n";
         outputString = outputString.replace(/\n/g,File.lineEnding);
         try
         {
            this.gcodeVarsFile = GWizSettings.getPrefsFile("gcvars" + GWizMachSettings.controllerFor(machine) + ".xml");
            stream = new FileStream();
            stream.open(this.gcodeVarsFile,FileMode.WRITE);
            stream.writeUTFBytes(outputString);
            stream.close();
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error saving g-code macro variables.");
         }
         this.dirtyBit = false;
      }
      
      private function lookupMacroVarNum(param1:int) : int
      {
         var _loc3_:Object = null;
         param1 = this.getWOAlias(param1);
         this.lastObj = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.theVariables.length)
         {
            _loc3_ = this.theVariables.getItemAt(_loc2_);
            if(_loc3_.hasOwnProperty("number") && _loc3_.number == param1)
            {
               if(3000 <= param1 && param1 <= 5100 && getSystemVar != null)
               {
                  _loc3_.value = getSystemVar(param1);
               }
               this.lastObj = _loc3_;
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      private function getMacroVar(param1:int) : Object
      {
         if(param1 != 0 && this.lookupMacroVarNum(param1) != -1)
         {
            return this.lastObj;
         }
         return null;
      }
      
      private function addMacVar(param1:int, param2:Number) : Object
      {
         var _loc3_:Object = null;
         var _loc4_:String;
         if((_loc4_ = this.getGenericDesc(param1)).length > 0)
         {
            _loc3_ = new Object();
            _loc3_.number = param1;
            _loc3_.value = param2;
            _loc3_.description = _loc4_;
            this.theVariables.addItem(_loc3_);
         }
         return _loc3_;
      }
      
      private function setVolatile(param1:int, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(!isNaN(param1) && param1 != 0)
         {
            _loc3_ = this.lookupMacroVarNum(param1);
            _loc4_ = null;
            if(_loc3_ != -1)
            {
               (_loc4_ = this.theVariables.getItemAt(_loc3_)).volatile = param2;
            }
            else
            {
               GWizUtils.assert(false);
            }
            this.debugDump();
         }
      }
      
      private function getWOAlias(param1:int) : int
      {
         if(this.workOffsetAliases.hasOwnProperty(String(param1)))
         {
            return this.workOffsetAliases[String(param1)];
         }
         return param1;
      }
      
      private function isAliased(param1:int) : Boolean
      {
         var _loc2_:int = this.getWOAlias(param1);
         return _loc2_ != param1;
      }
      
      private function initWOAliases() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < 7)
         {
            _loc1_ = 5200 + _loc2_ * 20 + 1;
            this.workOffsetAliases[String(2500 + _loc2_)] = _loc1_;
            this.workOffsetAliases[String(2600 + _loc2_)] = _loc1_ + 1;
            this.workOffsetAliases[String(2700 + _loc2_)] = _loc1_ + 2;
            this.workOffsetAliases[String(2800 + _loc2_)] = _loc1_ + 3;
            _loc2_++;
         }
         _loc2_ = 1;
         while(_loc2_ <= 48)
         {
            _loc1_ = 6981 + _loc2_ * 20;
            this.workOffsetAliases[String(13981 + _loc2_ * 20)] = _loc1_;
            this.workOffsetAliases[String(13981 + _loc2_ * 20 + 1)] = _loc1_ + 1;
            this.workOffsetAliases[String(13981 + _loc2_ * 20 + 2)] = _loc1_ + 2;
            this.workOffsetAliases[String(13981 + _loc2_ * 20 + 3)] = _loc1_ + 3;
            _loc2_++;
         }
      }
      
      private function debugDump() : void
      {
         var _loc2_:Object = null;
      }
      
      private function debugVar(param1:Object) : void
      {
         log.debug("debugVar " + param1.number + " (" + param1.description + "): " + "value = " + param1.value + ", volatile = " + param1.volatile);
      }
      
      [Bindable(event="propertyChange")]
      private function get gcodeVarsXML() : XML
      {
         return this._256977705gcodeVarsXML;
      }
      
      private function set gcodeVarsXML(param1:XML) : void
      {
         var _loc2_:Object = this._256977705gcodeVarsXML;
         if(_loc2_ !== param1)
         {
            this._256977705gcodeVarsXML = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gcodeVarsXML",_loc2_,param1));
            }
         }
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this._bindingEventDispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this._bindingEventDispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this._bindingEventDispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.willTrigger(param1);
      }
   }
}
