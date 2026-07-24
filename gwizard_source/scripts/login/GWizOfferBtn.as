package login
{
   import bubbletip.GWizStartWizard;
   import comps.GWizPopUpManager;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import mx.binding.BindingManager;
   import mx.core.ClassFactory;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   import mx.rpc.http.HTTPService;
   import spark.components.Button;
   import spark.components.HGroup;
   import tools.GWizOEMCribList;
   import tools.GWizOEMOfferPopup;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   public class GWizOfferBtn extends Button
   {
      
      private static const log:ILogger = Log.getLogger("GWizOfferBtn");
      
      public static var testFcn:Function = null;
      
      public static var enableTestFcn:Boolean = true;
      
      public static var gotoSpecialOfferTab:Function = null;
      
      public static var theInstance:GWizOfferBtn = null;
      
      public static var saleURL:String = null;
      
      private static var startDate:Date = null;
      
      private static var endDate:Date = null;
      
      public static var flashSales:Boolean = false;
      
      public static var exitToFlashSale:Boolean = false;
      
      public static var offersChecked:Boolean = false;
      
      public static var didOfferPop:Boolean = false;
       
      
      public var _GWizOfferBtn_ClassFactory1:ClassFactory;
      
      public var _GWizOfferBtn_ClassFactory2:ClassFactory;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private const NOTHANKS_TIMEOUT:int = 30;
      
      public var myBar:HGroup;
      
      private var testHidden:Boolean = false;
      
      public function GWizOfferBtn()
      {
         super();
         this.label = "Offers";
         this.visible = false;
         this._GWizOfferBtn_ClassFactory1_i();
         this._GWizOfferBtn_ClassFactory2_i();
         this.addEventListener("click",this.___GWizOfferBtn_Button1_click);
         this.addEventListener("creationComplete",this.___GWizOfferBtn_Button1_creationComplete);
      }
      
      public static function getOffers() : void
      {
         var event:FaultEvent = null;
         var versionRPC:HTTPService = null;
         var offerURL:String = null;
         var justASec:GWizJustASec = null;
         if(theInstance)
         {
            try
            {
               versionRPC = new HTTPService();
               offerURL = "offers.xml";
               if(GWizAbstractPrefs.isOEM)
               {
                  offerURL = GWizAbstractPrefs.oemStr + offerURL;
               }
               versionRPC.url = "http://www.cnccookbook.com/GWizard/" + offerURL;
               versionRPC.addEventListener("result",offersRPCResult);
               versionRPC.addEventListener("fault",noOffersConnection);
               versionRPC.requestTimeout = 0;
               versionRPC.send();
            }
            catch(e:Error)
            {
               log.debug("Can\'t get offers file. Error e = " + e);
               log.debug("Offers file = \'" + versionRPC.url);
               noOffersConnection(event);
            }
            GWizOEMCribList.getCribs();
         }
         else
         {
            justASec = new GWizJustASec(getOffers);
         }
      }
      
      private static function offersRPCResult(param1:ResultEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:Date = null;
         if(param1.result.hasOwnProperty("offers"))
         {
            _loc2_ = param1.result.offers;
            _loc3_ = param1.result.offers;
            if(_loc2_.hasOwnProperty("url") && _loc2_.hasOwnProperty("starts") && _loc2_.hasOwnProperty("ends"))
            {
               startDate = new Date(String(_loc2_.starts));
               endDate = new Date(String(_loc2_.ends));
               saleURL = _loc2_.url;
               if(_loc2_.hasOwnProperty("label"))
               {
                  theInstance.label = String(_loc2_.label);
               }
               theInstance.checkOffers();
            }
            else
            {
               log.debug("Bad offers RPC result");
               theInstance.HideOfferBtn();
            }
            if(_loc2_.hasOwnProperty("flashSale"))
            {
               _loc3_ = _loc2_.flashSale;
               flashSales = _loc3_ == "true";
               _loc4_ = new Date();
               flashSales = flashSales && (startDate.valueOf() > _loc4_.valueOf() || _loc4_.valueOf() > endDate.valueOf());
               if(GWizSettings.loginBar.appNameParm != "GWizard")
               {
                  flashSales = false;
               }
               else
               {
                  saleURL = "https://www.cnccookbook.com/g-wizard-calculator-pricing-trial-flash/";
               }
            }
         }
      }
      
      private static function noOffersConnection(param1:FaultEvent) : void
      {
         log.debug("No Offers Connection:" + param1.message);
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         var factory:IFlexModuleFactory = param1;
         super.moduleFactory = factory;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
         if(!this.styleDeclaration)
         {
            this.styleDeclaration = new CSSStyleDeclaration(null,styleManager);
         }
         this.styleDeclaration.defaultFactory = function():void
         {
            this.chromeColor = 2344171;
            this.color = 16777215;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function offerFlashSale() : Boolean
      {
         exitToFlashSale = false;
         if(flashSales)
         {
            if(!GWizLoginMgr.currentOrPastSubscriber() && 1 < GWizSettings.prefs.trialLogins && GWizSettings.prefs.trialLogins <= 7)
            {
               exitToFlashSale = true;
            }
         }
         return exitToFlashSale;
      }
      
      private function postSaleUpsell() : Boolean
      {
         return false;
      }
      
      private function postSaleCrossSell() : Boolean
      {
         return false;
      }
      
      private function postTrialDiscount() : Boolean
      {
         return false;
      }
      
      private function renewalDiscount() : Boolean
      {
         return false;
      }
      
      private function checkOffers(param1:Boolean = false) : void
      {
         var _loc2_:Date = null;
         var _loc3_:GWizSaleBlurb = null;
         var _loc4_:GWizFlashSaleBlurb = null;
         if(GWizStartWizard.userOnboard())
         {
            if(!GWizAbstractPrefs.auxPrefsSet && !param1)
            {
               this.callLater(this.checkOffers);
               return;
            }
            offersChecked = true;
            _loc2_ = new Date();
            if(GWizAbstractPrefs.isOEM)
            {
               this.visible = true;
               if(param1)
               {
                  GWizUtils.doWebPage(GWizOfferBtn.saleURL);
               }
            }
            else if(saleURL && startDate && endDate && startDate.valueOf() <= _loc2_.valueOf() && _loc2_.valueOf() <= endDate.valueOf())
            {
               this.visible = true;
               this.label = "Sale!";
               if(this.checkPop("bigSalePop",2,param1))
               {
                  if(gotoSpecialOfferTab != null)
                  {
                     gotoSpecialOfferTab();
                  }
                  else
                  {
                     _loc3_ = GWizSaleBlurb(GWizPopUpManager.createPopUp(DisplayObject(GWizSettings.docWindow),GWizSaleBlurb,true));
                  }
               }
            }
            else if(this.offerFlashSale())
            {
               if(!GWizSettings.prefs.flashSaleShown)
               {
                  _loc4_ = GWizFlashSaleBlurb(GWizPopUpManager.createPopUp(DisplayObject(GWizSettings.docWindow),GWizFlashSaleBlurb,true));
                  GWizSettings.prefs.flashSaleShown = true;
               }
            }
            else if(GWizAbstractPrefs.auxPrefsSet && GWizAbstractPrefs.isOEM)
            {
               this.visible = true;
               this.label = "Special Offer";
               if(param1)
               {
                  GWizOEMOfferPopup.OEMOfferPopup();
               }
            }
            else if(this.postSaleUpsell())
            {
               if(!this.checkPop("upsellPop",this.NOTHANKS_TIMEOUT,param1))
               {
               }
            }
            else if(this.postSaleCrossSell())
            {
               if(!this.checkPop("crossSellPop",this.NOTHANKS_TIMEOUT,param1))
               {
               }
            }
            else if(this.postTrialDiscount())
            {
               if(!this.checkPop("trialDiscountPop",this.NOTHANKS_TIMEOUT,param1))
               {
               }
            }
            else if(this.renewalDiscount())
            {
               if(!this.checkPop("renewalDiscountPop",this.NOTHANKS_TIMEOUT,param1))
               {
               }
            }
            else if(enableTestFcn && GWizUtils.debug && testFcn != null)
            {
            }
         }
         if(!this.visible)
         {
            this.HideOfferBtn();
         }
      }
      
      private function checkPop(param1:String, param2:int, param3:Boolean) : Boolean
      {
         var _loc4_:Date = null;
         var _loc5_:Date = null;
         var _loc6_:String = null;
         var _loc7_:Date = null;
         if(GWizSettings.prefs && GWizSettings.prefs.hasOwnProperty(param1))
         {
            _loc5_ = new Date();
            if((_loc6_ = GWizSettings.prefs[param1] as String) && _loc6_ != "null")
            {
               _loc4_ = new Date(_loc6_);
            }
            if(!_loc4_)
            {
               GWizSettings.prefs[param1] = _loc5_;
               didOfferPop = true;
               return true;
            }
            (_loc7_ = new Date()).date = _loc4_.date + param2;
            if(param3 || _loc5_.valueOf() > _loc7_.valueOf())
            {
               GWizSettings.prefs[param1] = String(_loc5_);
               didOfferPop = true;
               return true;
            }
         }
         return false;
      }
      
      private function HideOfferBtn() : void
      {
         if(!this.testHidden)
         {
            if(this.myBar)
            {
               this.myBar.removeElement(this);
               this.testHidden = true;
            }
            else
            {
               this.callLater(this.HideOfferBtn);
            }
         }
      }
      
      private function _GWizOfferBtn_ClassFactory1_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizSaleBlurb;
         _loc1_.properties = {"outerDocument":this};
         this._GWizOfferBtn_ClassFactory1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizOfferBtn_ClassFactory1",this._GWizOfferBtn_ClassFactory1);
         return _loc1_;
      }
      
      private function _GWizOfferBtn_ClassFactory2_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizFlashSaleBlurb;
         _loc1_.properties = {"outerDocument":this};
         this._GWizOfferBtn_ClassFactory2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizOfferBtn_ClassFactory2",this._GWizOfferBtn_ClassFactory2);
         return _loc1_;
      }
      
      public function ___GWizOfferBtn_Button1_click(param1:MouseEvent) : void
      {
         this.checkOffers(true);
      }
      
      public function ___GWizOfferBtn_Button1_creationComplete(param1:FlexEvent) : void
      {
         theInstance = this;
      }
   }
}
