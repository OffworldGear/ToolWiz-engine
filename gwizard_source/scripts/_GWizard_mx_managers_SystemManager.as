package
{
   import flash.display.LoaderInfo;
   import flash.system.ApplicationDomain;
   import flash.system.Security;
   import flash.utils.Dictionary;
   import flashx.textLayout.compose.ISWFContext;
   import mx.core.IFlexModule;
   import mx.core.IFlexModuleFactory;
   import mx.events.RSLEvent;
   import mx.managers.SystemManager;
   import mx.preloaders.SparkDownloadProgressBar;
   
   public class _GWizard_mx_managers_SystemManager extends SystemManager implements IFlexModuleFactory, ISWFContext
   {
       
      
      private var _info:Object;
      
      private var _preloadedRSLs:Dictionary;
      
      private var _allowDomainParameters:Vector.<Array>;
      
      private var _allowInsecureDomainParameters:Vector.<Array>;
      
      public function _GWizard_mx_managers_SystemManager()
      {
         super();
      }
      
      override public function callInContext(param1:Function, param2:Object, param3:Array, param4:Boolean = true) : *
      {
         if(param4)
         {
            return param1.apply(param2,param3);
         }
         param1.apply(param2,param3);
      }
      
      override public function create(... rest) : Object
      {
         if(rest.length > 0 && !(rest[0] is String))
         {
            return super.create.apply(this,rest);
         }
         var _loc2_:String = rest.length == 0 ? "GWizard" : String(rest[0]);
         var _loc3_:Class = Class(getDefinitionByName(_loc2_));
         if(!_loc3_)
         {
            return null;
         }
         var _loc4_:Object;
         if((_loc4_ = new _loc3_()) is IFlexModule)
         {
            IFlexModule(_loc4_).moduleFactory = this;
         }
         return _loc4_;
      }
      
      override public function info() : Object
      {
         if(!this._info)
         {
            this._info = {
               "applicationComplete":"appInit();",
               "compiledLocales":["en_US"],
               "compiledResourceBundleNames":["SharedResources","charts","collections","components","containers","controls","core","effects","formatters","layout","logging","messaging","rpc","skins","sparkEffects","styles","textLayout"],
               "creationComplete":"onCreationComplete();",
               "currentDomain":ApplicationDomain.currentDomain,
               "displayStateChange":"this.callLater(onResize);",
               "initialize":"init();",
               "mainClassName":"GWizard",
               "mixins":["_GWizard_FlexInit","_GWizard_Styles","mx.managers.systemClasses.ActiveWindowManager","logger.GWizEarlyBird","mx.messaging.config.LoaderConfig"],
               "preloader":SparkDownloadProgressBar,
               "title":"GWizard: Machinist\'s Calculator",
               "visible":"false"
            };
         }
         return this._info;
      }
      
      override public function get preloadedRSLs() : Dictionary
      {
         if(this._preloadedRSLs == null)
         {
            this._preloadedRSLs = new Dictionary(true);
         }
         return this._preloadedRSLs;
      }
      
      override public function allowDomain(... rest) : void
      {
         var _loc2_:* = null;
         Security.allowDomain.apply(null,rest);
         for(_loc2_ in this._preloadedRSLs)
         {
            if(_loc2_.content && "allowDomainInRSL" in _loc2_.content)
            {
               _loc2_.content["allowDomainInRSL"].apply(null,rest);
            }
         }
         if(!this._allowDomainParameters)
         {
            this._allowDomainParameters = new Vector.<Array>();
         }
         this._allowDomainParameters.push(rest);
         addEventListener(RSLEvent.RSL_ADD_PRELOADED,this.addPreloadedRSLHandler,false,50);
      }
      
      override public function allowInsecureDomain(... rest) : void
      {
         var _loc2_:* = null;
         Security.allowInsecureDomain.apply(null,rest);
         for(_loc2_ in this._preloadedRSLs)
         {
            if(_loc2_.content && "allowInsecureDomainInRSL" in _loc2_.content)
            {
               _loc2_.content["allowInsecureDomainInRSL"].apply(null,rest);
            }
         }
         if(!this._allowInsecureDomainParameters)
         {
            this._allowInsecureDomainParameters = new Vector.<Array>();
         }
         this._allowInsecureDomainParameters.push(rest);
         addEventListener(RSLEvent.RSL_ADD_PRELOADED,this.addPreloadedRSLHandler,false,50);
      }
      
      private function addPreloadedRSLHandler(param1:RSLEvent) : void
      {
         var _loc3_:Array = null;
         var _loc2_:LoaderInfo = param1.loaderInfo;
         if(!_loc2_ || !_loc2_.content)
         {
            return;
         }
         if(allowDomainsInNewRSLs && this._allowDomainParameters)
         {
            for each(_loc3_ in this._allowDomainParameters)
            {
               if("allowDomainInRSL" in _loc2_.content)
               {
                  _loc2_.content["allowDomainInRSL"].apply(null,_loc3_);
               }
            }
         }
         if(allowInsecureDomainsInNewRSLs && this._allowInsecureDomainParameters)
         {
            for each(_loc3_ in this._allowInsecureDomainParameters)
            {
               if("allowInsecureDomainInRSL" in _loc2_.content)
               {
                  _loc2_.content["allowInsecureDomainInRSL"].apply(null,_loc3_);
               }
            }
         }
      }
   }
}
