package apps
{
   import comps.GWizLinkImage;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import login.GWizCredentials;
   import login.GWizOfferBtn;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.containers.ViewStack;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponentDescriptor;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.Group;
   import spark.components.Label;
   import spark.components.NavigatorContent;
   import spark.components.VGroup;
   import utils.GATracker;
   import utils.GWizCSVUtils;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizCNCSpecialOffer extends Group implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizCNCSpecialOffer");
      
      private static const SALE_URL:String = "https://www.cnccookbook.com/cnc-software-sale/";
      
      private static var _116079url:String = SALE_URL;
      
      private static var personalURL:String = SALE_URL;
      
      private static var urlPersonalized:Boolean = false;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _78135OEM:NavigatorContent;
      
      private var _93721616Personalized:NavigatorContent;
      
      private var _2569319Sale:NavigatorContent;
      
      public var _GWizCNCSpecialOffer_Button1:Button;
      
      public var _GWizCNCSpecialOffer_Button2:Button;
      
      public var _GWizCNCSpecialOffer_Button3:Button;
      
      private var _280343272graphic:GWizLinkImage;
      
      private var _2130028965offerSelector:ViewStack;
      
      private var _322477192personalGraphic:GWizLinkImage;
      
      private var _1865677985saleGraphic:GWizLinkImage;
      
      private var _836044556usedBy:Label;
      
      private var _147577410usedBy2:Label;
      
      private var _147577409usedBy3:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _embed_mxml____assets_GoodListener_jpg_517935779:Class;
      
      private var _embed_mxml____assets_FreeOffer_jpg_769280227:Class;
      
      private var _embed_mxml____assets_Eclipse2017_jpg_738794913:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCNCSpecialOffer()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._embed_mxml____assets_GoodListener_jpg_517935779 = GWizCNCSpecialOffer__embed_mxml____assets_GoodListener_jpg_517935779;
         this._embed_mxml____assets_FreeOffer_jpg_769280227 = GWizCNCSpecialOffer__embed_mxml____assets_FreeOffer_jpg_769280227;
         this._embed_mxml____assets_Eclipse2017_jpg_738794913 = GWizCNCSpecialOffer__embed_mxml____assets_Eclipse2017_jpg_738794913;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCNCSpecialOffer_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_apps_GWizCNCSpecialOfferWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCNCSpecialOffer[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContent = [this._GWizCNCSpecialOffer_ViewStack1_i()];
         this.addEventListener("creationComplete",this.___GWizCNCSpecialOffer_Group1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCNCSpecialOffer._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      private static function get url() : String
      {
         return GWizCNCSpecialOffer._116079url;
      }
      
      private static function set url(param1:String) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCNCSpecialOffer._116079url;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCNCSpecialOffer,"url",_loc2_,param1));
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
      
      private function onCC() : void
      {
         if(!GWizAbstractPrefs.isOEM)
         {
            GWizCSVUtils.downloadCSV("http://cnccookbook.com/GWizard/SpecialOffers.csv",this.gotOfferInfo);
         }
         else
         {
            url = GWizAbstractPrefs.oemInfo(GWizAbstractPrefs.SPECIAL_OFFER);
            personalURL = url;
         }
      }
      
      private function gotOfferInfo(param1:ArrayCollection) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(param1)
         {
            _loc2_ = "billing@stealthmachine.co";
            _loc2_ = GWizCredentials.hashedLogin();
            _loc3_ = 0;
            while(_loc3_ < param1.length)
            {
               if((_loc4_ = param1.getItemAt(_loc3_)).Key == _loc2_ && _loc4_.hasOwnProperty("Offer") && _loc4_.Offer != "")
               {
                  personalURL = _loc4_.Offer;
                  urlPersonalized = true;
                  break;
               }
               _loc3_++;
            }
         }
      }
      
      private function doClick() : void
      {
         GATracker.logPageView("Special Offer","Sent to " + url);
         GWizUtils.doWebPage(url);
      }
      
      public function noSpecialOffer() : Boolean
      {
         var _loc1_:* = false;
         if(!GWizAbstractPrefs.isOEM)
         {
            this.offerSelector.selectedIndex = 2;
            url = "https://www.cnccookbook.com/cnc-software-sale/";
            _loc1_ = !GWizOfferBtn.theInstance.visible;
            if(_loc1_)
            {
               _loc1_ = Boolean(urlPersonalized);
               _loc1_ = Boolean(_loc1_ && GWizSettings.prefs.logins > 2);
               _loc1_ = !_loc1_;
               log.debug("Logins: " + GWizSettings.prefs.logins);
               if(!_loc1_)
               {
                  this.offerSelector.selectedIndex = 1;
                  url = personalURL;
               }
            }
            return _loc1_;
         }
         this.offerSelector.selectedIndex = 0;
         return false;
      }
      
      private function _GWizCNCSpecialOffer_ViewStack1_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.id = "offerSelector";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"offerSelector",
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"OEM",
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {"mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCNCSpecialOffer_Array2_c)};
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Personalized",
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {"mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCNCSpecialOffer_Array4_c)};
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Sale",
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 0;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {"mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCNCSpecialOffer_Array6_c)};
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.offerSelector = temp;
         BindingManager.executeBindings(this,"offerSelector",this.offerSelector);
         return temp;
      }
      
      private function _GWizCNCSpecialOffer_Array2_c() : Array
      {
         return [this._GWizCNCSpecialOffer_VGroup1_c()];
      }
      
      private function _GWizCNCSpecialOffer_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "center";
         _loc1_.paddingTop = 10;
         _loc1_.paddingBottom = 10;
         _loc1_.mxmlContent = [this._GWizCNCSpecialOffer_Label1_c(),this._GWizCNCSpecialOffer_Label2_c(),this._GWizCNCSpecialOffer_GWizLinkImage1_i(),this._GWizCNCSpecialOffer_Label3_i(),this._GWizCNCSpecialOffer_Button1_i()];
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCNCSpecialOffer_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "G-Wizard Special Offer!";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",28);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCNCSpecialOffer_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Unlock the full power of G-Wizard.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",16);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCNCSpecialOffer_GWizLinkImage1_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml____assets_FreeOffer_jpg_769280227;
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "graphic";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.graphic = _loc1_;
         BindingManager.executeBindings(this,"graphic",this.graphic);
         return _loc1_;
      }
      
      private function _GWizCNCSpecialOffer_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "G-Wizard is used by tens of thousands of CNC\'ers at the world\'s best manufacturers.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",16);
         _loc1_.id = "usedBy";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.usedBy = _loc1_;
         BindingManager.executeBindings(this,"usedBy",this.usedBy);
         return _loc1_;
      }
      
      private function _GWizCNCSpecialOffer_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Start Now, It\'s Free!";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("click",this.___GWizCNCSpecialOffer_Button1_click);
         _loc1_.id = "_GWizCNCSpecialOffer_Button1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCNCSpecialOffer_Button1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCNCSpecialOffer_Button1",this._GWizCNCSpecialOffer_Button1);
         return _loc1_;
      }
      
      public function ___GWizCNCSpecialOffer_Button1_click(param1:MouseEvent) : void
      {
         this.doClick();
      }
      
      private function _GWizCNCSpecialOffer_Array4_c() : Array
      {
         return [this._GWizCNCSpecialOffer_VGroup2_c()];
      }
      
      private function _GWizCNCSpecialOffer_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "center";
         _loc1_.paddingTop = 10;
         _loc1_.paddingBottom = 10;
         _loc1_.mxmlContent = [this._GWizCNCSpecialOffer_Label4_c(),this._GWizCNCSpecialOffer_Label5_c(),this._GWizCNCSpecialOffer_GWizLinkImage2_i(),this._GWizCNCSpecialOffer_Label6_i(),this._GWizCNCSpecialOffer_Button2_i()];
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCNCSpecialOffer_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "CNCCookbook Special Offer!";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",28);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCNCSpecialOffer_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "As a valued customer, we have a secret deal just for you.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",16);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCNCSpecialOffer_GWizLinkImage2_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml____assets_GoodListener_jpg_517935779;
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "personalGraphic";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.personalGraphic = _loc1_;
         BindingManager.executeBindings(this,"personalGraphic",this.personalGraphic);
         return _loc1_;
      }
      
      private function _GWizCNCSpecialOffer_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Click here to see your Secret Deal!";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",16);
         _loc1_.id = "usedBy2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.usedBy2 = _loc1_;
         BindingManager.executeBindings(this,"usedBy2",this.usedBy2);
         return _loc1_;
      }
      
      private function _GWizCNCSpecialOffer_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Secret Deal!";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("click",this.___GWizCNCSpecialOffer_Button2_click);
         _loc1_.id = "_GWizCNCSpecialOffer_Button2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCNCSpecialOffer_Button2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCNCSpecialOffer_Button2",this._GWizCNCSpecialOffer_Button2);
         return _loc1_;
      }
      
      public function ___GWizCNCSpecialOffer_Button2_click(param1:MouseEvent) : void
      {
         this.doClick();
      }
      
      private function _GWizCNCSpecialOffer_Array6_c() : Array
      {
         return [this._GWizCNCSpecialOffer_VGroup3_c()];
      }
      
      private function _GWizCNCSpecialOffer_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "center";
         _loc1_.paddingTop = 10;
         _loc1_.paddingBottom = 10;
         _loc1_.mxmlContent = [this._GWizCNCSpecialOffer_Label7_c(),this._GWizCNCSpecialOffer_Label8_c(),this._GWizCNCSpecialOffer_GWizLinkImage3_i(),this._GWizCNCSpecialOffer_Label9_i(),this._GWizCNCSpecialOffer_Button3_i()];
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCNCSpecialOffer_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "CNCCookbook is running a Big Sale!";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",28);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCNCSpecialOffer_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Come check it out.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",16);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCNCSpecialOffer_GWizLinkImage3_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml____assets_Eclipse2017_jpg_738794913;
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "saleGraphic";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.saleGraphic = _loc1_;
         BindingManager.executeBindings(this,"saleGraphic",this.saleGraphic);
         return _loc1_;
      }
      
      private function _GWizCNCSpecialOffer_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Click here to Save.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",16);
         _loc1_.id = "usedBy3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.usedBy3 = _loc1_;
         BindingManager.executeBindings(this,"usedBy3",this.usedBy3);
         return _loc1_;
      }
      
      private function _GWizCNCSpecialOffer_Button3_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Sale Details!";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("click",this.___GWizCNCSpecialOffer_Button3_click);
         _loc1_.id = "_GWizCNCSpecialOffer_Button3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCNCSpecialOffer_Button3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCNCSpecialOffer_Button3",this._GWizCNCSpecialOffer_Button3);
         return _loc1_;
      }
      
      public function ___GWizCNCSpecialOffer_Button3_click(param1:MouseEvent) : void
      {
         this.doClick();
      }
      
      public function ___GWizCNCSpecialOffer_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizCNCSpecialOffer_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():String
         {
            var _loc1_:* = url;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"graphic.url");
         result[1] = new Binding(this,function():Number
         {
            return usedBy.width;
         },null,"_GWizCNCSpecialOffer_Button1.width");
         result[2] = new Binding(this,function():String
         {
            var _loc1_:* = url;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"personalGraphic.url");
         result[3] = new Binding(this,function():Number
         {
            return usedBy2.width;
         },null,"_GWizCNCSpecialOffer_Button2.width");
         result[4] = new Binding(this,function():String
         {
            var _loc1_:* = url;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"saleGraphic.url");
         result[5] = new Binding(this,function():Number
         {
            return usedBy2.width;
         },null,"_GWizCNCSpecialOffer_Button3.width");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get OEM() : NavigatorContent
      {
         return this._78135OEM;
      }
      
      public function set OEM(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._78135OEM;
         if(_loc2_ !== param1)
         {
            this._78135OEM = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"OEM",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Personalized() : NavigatorContent
      {
         return this._93721616Personalized;
      }
      
      public function set Personalized(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._93721616Personalized;
         if(_loc2_ !== param1)
         {
            this._93721616Personalized = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Personalized",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Sale() : NavigatorContent
      {
         return this._2569319Sale;
      }
      
      public function set Sale(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._2569319Sale;
         if(_loc2_ !== param1)
         {
            this._2569319Sale = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Sale",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get graphic() : GWizLinkImage
      {
         return this._280343272graphic;
      }
      
      public function set graphic(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._280343272graphic;
         if(_loc2_ !== param1)
         {
            this._280343272graphic = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"graphic",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get offerSelector() : ViewStack
      {
         return this._2130028965offerSelector;
      }
      
      public function set offerSelector(param1:ViewStack) : void
      {
         var _loc2_:Object = this._2130028965offerSelector;
         if(_loc2_ !== param1)
         {
            this._2130028965offerSelector = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"offerSelector",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get personalGraphic() : GWizLinkImage
      {
         return this._322477192personalGraphic;
      }
      
      public function set personalGraphic(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._322477192personalGraphic;
         if(_loc2_ !== param1)
         {
            this._322477192personalGraphic = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"personalGraphic",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get saleGraphic() : GWizLinkImage
      {
         return this._1865677985saleGraphic;
      }
      
      public function set saleGraphic(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._1865677985saleGraphic;
         if(_loc2_ !== param1)
         {
            this._1865677985saleGraphic = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"saleGraphic",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get usedBy() : Label
      {
         return this._836044556usedBy;
      }
      
      public function set usedBy(param1:Label) : void
      {
         var _loc2_:Object = this._836044556usedBy;
         if(_loc2_ !== param1)
         {
            this._836044556usedBy = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"usedBy",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get usedBy2() : Label
      {
         return this._147577410usedBy2;
      }
      
      public function set usedBy2(param1:Label) : void
      {
         var _loc2_:Object = this._147577410usedBy2;
         if(_loc2_ !== param1)
         {
            this._147577410usedBy2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"usedBy2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get usedBy3() : Label
      {
         return this._147577409usedBy3;
      }
      
      public function set usedBy3(param1:Label) : void
      {
         var _loc2_:Object = this._147577409usedBy3;
         if(_loc2_ !== param1)
         {
            this._147577409usedBy3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"usedBy3",_loc2_,param1));
            }
         }
      }
   }
}
