package mx.managers
{
   import flash.display.DisplayObject;
   import flash.display.LoaderInfo;
   import flash.utils.Dictionary;
   import mx.core.FlexGlobals;
   import mx.core.mx_internal;
   import mx.events.BrowserChangeEvent;
   
   use namespace mx_internal;
   
   public class HistoryManagerImpl implements IHistoryManager
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static const HANDSHAKE_INTERVAL:int = 500;
      
      private static const MAX_HANDSHAKE_TRIES:int = 100;
      
      private static const ID_NAME_SEPARATOR:String = "-";
      
      private static const NAME_VALUE_SEPARATOR:String = "=";
      
      private static const PROPERTY_SEPARATOR:String = "&";
      
      private static var systemManager:ISystemManager;
      
      private static var instance:IHistoryManager;
      
      private static var appID:String;
      
      private static var historyURL:String;
       
      
      private var registeredObjects:Array;
      
      private var registrationMap:Dictionary;
      
      private var pendingStates:Object;
      
      private var pendingQueryString:String;
      
      public function HistoryManagerImpl()
      {
         var _loc1_:LoaderInfo = null;
         var _loc2_:String = null;
         this.registeredObjects = [];
         this.pendingStates = {};
         super();
         if(instance)
         {
            throw new Error("Instance already exists.");
         }
         if(appID)
         {
            return;
         }
         if(!("historyManagementEnabled" in FlexGlobals.topLevelApplication) || !FlexGlobals.topLevelApplication.historyManagementEnabled)
         {
            return;
         }
         if(HistoryManagerGlobals.loaderInfo)
         {
            _loc1_ = HistoryManagerGlobals.loaderInfo;
         }
         else
         {
            _loc1_ = DisplayObject(systemManager).loaderInfo;
         }
         if(HistoryManagerGlobals.loaderInfo)
         {
            _loc2_ = HistoryManagerGlobals.loaderInfo.url;
         }
         else
         {
            _loc2_ = DisplayObject(systemManager).loaderInfo.url;
         }
         appID = this.calcCRC(_loc2_);
         BrowserManager.getInstance().addEventListener(BrowserChangeEvent.BROWSER_URL_CHANGE,this.browserURLChangeHandler);
         BrowserManager.getInstance().initForHistoryManager();
      }
      
      public static function getInstance() : IHistoryManager
      {
         if(!instance)
         {
            systemManager = SystemManagerGlobals.topLevelSystemManagers[0];
            instance = new HistoryManagerImpl();
         }
         return instance;
      }
      
      public function register(param1:IHistoryManagerClient) : void
      {
         if(!("historyManagementEnabled" in FlexGlobals.topLevelApplication) || !FlexGlobals.topLevelApplication.historyManagementEnabled)
         {
            return;
         }
         this.unregister(param1);
         this.registeredObjects.push(param1);
         var _loc2_:String = this.getPath(param1);
         var _loc3_:String = this.calcCRC(_loc2_);
         var _loc4_:int = this.calcDepth(_loc2_);
         if(!this.registrationMap)
         {
            this.registrationMap = new Dictionary(true);
         }
         this.registrationMap[param1] = new RegistrationInfo(_loc3_,_loc4_);
         this.registeredObjects.sort(this.depthCompare);
         if(this.pendingStates[_loc3_])
         {
            param1.loadState(this.pendingStates[_loc3_]);
            delete this.pendingStates[_loc3_];
         }
      }
      
      private function getPath(param1:IHistoryManagerClient) : String
      {
         return param1.toString();
      }
      
      private function calcCRC(param1:String) : String
      {
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc2_:uint = 65535;
         var _loc3_:int = param1.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc6_ = (_loc5_ = param1.charCodeAt(_loc4_)) & 255;
            if((_loc7_ = _loc5_ >> 8) != 0)
            {
               _loc2_ = this.updateCRC(_loc2_,_loc7_);
            }
            _loc2_ = this.updateCRC(_loc2_,_loc6_);
            _loc4_++;
         }
         _loc2_ = this.updateCRC(_loc2_,0);
         _loc2_ = this.updateCRC(_loc2_,0);
         return _loc2_.toString(16);
      }
      
      private function updateCRC(param1:uint, param2:uint) : uint
      {
         var _loc6_:* = false;
         var _loc3_:uint = 4129;
         var _loc4_:uint = 128;
         var _loc5_:int = 0;
         while(_loc5_ < 8)
         {
            _loc6_ = (param1 & 32768) != 0;
            param1 <<= 1;
            param1 &= 65535;
            if((param2 & _loc4_) != 0)
            {
               param1++;
            }
            if(_loc6_)
            {
               param1 ^= _loc3_;
            }
            _loc4_ >>= 1;
            _loc5_++;
         }
         return param1;
      }
      
      private function calcDepth(param1:String) : int
      {
         return param1.split(".").length;
      }
      
      private function depthCompare(param1:Object, param2:Object) : int
      {
         var _loc3_:RegistrationInfo = this.getRegistrationInfo(IHistoryManagerClient(param1));
         var _loc4_:RegistrationInfo = this.getRegistrationInfo(IHistoryManagerClient(param2));
         if(!_loc3_ || !_loc4_)
         {
            return 0;
         }
         if(_loc3_.depth > _loc4_.depth)
         {
            return 1;
         }
         if(_loc3_.depth < _loc4_.depth)
         {
            return -1;
         }
         return 0;
      }
      
      private function getRegistrationInfo(param1:IHistoryManagerClient) : RegistrationInfo
      {
         return !!this.registrationMap ? this.registrationMap[param1] : null;
      }
      
      public function unregister(param1:IHistoryManagerClient) : void
      {
         if(!("historyManagementEnabled" in FlexGlobals.topLevelApplication) || !FlexGlobals.topLevelApplication.historyManagementEnabled)
         {
            return;
         }
         var _loc2_:int = -1;
         var _loc3_:int = this.registeredObjects.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(this.registeredObjects[_loc4_] == param1)
            {
               _loc2_ = _loc4_;
               break;
            }
            _loc4_++;
         }
         if(_loc2_ >= 0)
         {
            this.registeredObjects.splice(_loc2_,1);
         }
         if(param1 && this.registrationMap)
         {
            delete this.registrationMap[param1];
         }
      }
      
      public function save() : void
      {
         var _loc5_:IHistoryManagerClient = null;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:* = null;
         var _loc9_:Object = null;
         if(!("historyManagementEnabled" in FlexGlobals.topLevelApplication) || !FlexGlobals.topLevelApplication.historyManagementEnabled)
         {
            return;
         }
         var _loc1_:Boolean = false;
         var _loc2_:String = "app=" + appID;
         var _loc3_:int = this.registeredObjects.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc6_ = (_loc5_ = this.registeredObjects[_loc4_]).saveState();
            _loc7_ = this.getRegistrationInfo(_loc5_).crc;
            for(_loc8_ in _loc6_)
            {
               _loc9_ = _loc6_[_loc8_];
               if(_loc2_.length > 0)
               {
                  _loc2_ += PROPERTY_SEPARATOR;
               }
               _loc2_ += _loc7_;
               _loc2_ += ID_NAME_SEPARATOR;
               _loc2_ += escape(_loc8_);
               _loc2_ += NAME_VALUE_SEPARATOR;
               _loc2_ += escape(_loc9_.toString());
               _loc1_ = true;
            }
            _loc4_++;
         }
         if(_loc1_)
         {
            this.pendingQueryString = _loc2_;
            FlexGlobals.topLevelApplication.callLater(this.submitQuery);
         }
      }
      
      private function submitQuery() : void
      {
         if(this.pendingQueryString)
         {
            BrowserManager.getInstance().setFragment(this.pendingQueryString);
            this.pendingQueryString = null;
            if("resetHistory" in FlexGlobals.topLevelApplication)
            {
               FlexGlobals.topLevelApplication.resetHistory = true;
            }
         }
      }
      
      public function browserURLChangeHandler(param1:BrowserChangeEvent) : void
      {
         var _loc2_:* = null;
         var _loc3_:String = null;
         var _loc9_:Array = null;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         var _loc12_:Object = null;
         var _loc13_:IHistoryManagerClient = null;
         if(!("historyManagementEnabled" in FlexGlobals.topLevelApplication) || !FlexGlobals.topLevelApplication.historyManagementEnabled)
         {
            return;
         }
         var _loc4_:Array = param1.url.split(PROPERTY_SEPARATOR);
         var _loc5_:Object = {};
         var _loc6_:int = _loc4_.length;
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc9_ = _loc4_[_loc7_].split(NAME_VALUE_SEPARATOR);
            _loc5_[_loc9_[0]] = this.parseString(_loc9_[1]);
            _loc7_++;
         }
         var _loc8_:Object = {};
         for(_loc2_ in _loc5_)
         {
            if((_loc10_ = _loc2_.indexOf(ID_NAME_SEPARATOR)) > -1)
            {
               _loc3_ = _loc2_.substr(0,_loc10_);
               _loc11_ = _loc2_.substr(_loc10_ + 1,_loc2_.length);
               _loc12_ = _loc5_[_loc2_];
               if(!_loc8_[_loc3_])
               {
                  _loc8_[_loc3_] = {};
               }
               _loc8_[_loc3_][_loc11_] = _loc12_;
            }
         }
         _loc6_ = this.registeredObjects.length;
         _loc7_ = 0;
         while(_loc7_ < _loc6_)
         {
            _loc13_ = this.registeredObjects[_loc7_];
            _loc3_ = this.getRegistrationInfo(_loc13_).crc;
            _loc13_.loadState(_loc8_[_loc3_]);
            delete _loc8_[_loc3_];
            _loc7_++;
         }
         for(_loc2_ in _loc8_)
         {
            this.pendingStates[_loc2_] = _loc8_[_loc2_];
         }
      }
      
      private function parseString(param1:String) : Object
      {
         if(param1 == "true")
         {
            return true;
         }
         if(param1 == "false")
         {
            return false;
         }
         var _loc2_:int = parseInt(param1);
         if(_loc2_.toString() == param1)
         {
            return _loc2_;
         }
         var _loc3_:Number = parseFloat(param1);
         if(_loc3_.toString() == param1)
         {
            return _loc3_;
         }
         return param1;
      }
   }
}

import mx.core.mx_internal;

use namespace mx_internal;

class RegistrationInfo
{
   
   mx_internal static const VERSION:String = "4.6.0.23201";
    
   
   public var crc:String;
   
   public var depth:int;
   
   function RegistrationInfo(param1:String, param2:int)
   {
      super();
      this.crc = param1;
      this.depth = param2;
   }
}
