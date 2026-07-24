package tools
{
   import comps.GWizLinkImage;
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.Label;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizOEMOfferPopup extends GWizPopUp implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _280343272graphic:GWizLinkImage;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private const OFFER_URL:String = "http://www.cnccookbook.com/FeedSpeedsCalculator/CCGWizardMill.html";
      
      private var _embed_mxml____assets_FreeOffer_jpg_867513754:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizOEMOfferPopup()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._embed_mxml____assets_FreeOffer_jpg_867513754 = GWizOEMOfferPopup__embed_mxml____assets_FreeOffer_jpg_867513754;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizOEMOfferPopup_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_tools_GWizOEMOfferPopupWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizOEMOfferPopup[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "G-Wizard Special Offer...";
         this.width = 400;
         this.height = 300;
         this.fullScreen = true;
         this.okLabel = "Start Now, It\'s Free!";
         this.cancelLabel = "";
         this.mxmlContent = [this._GWizOEMOfferPopup_VGroup1_c()];
         this.addEventListener("creationComplete",this.___GWizOEMOfferPopup_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function OEMOfferPopup() : GWizOEMOfferPopup
      {
         return GWizOEMOfferPopup(GWizPopUpManager.createPopUp(null,GWizOEMOfferPopup,true));
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizOEMOfferPopup._watcherSetupUtil = param1;
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
      }
      
      override public function onOk(param1:Event) : void
      {
         GWizUtils.doWebPage(this.OFFER_URL);
         super.onOk(param1);
      }
      
      private function _GWizOEMOfferPopup_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizOEMOfferPopup_Label1_c(),this._GWizOEMOfferPopup_Label2_c(),this._GWizOEMOfferPopup_GWizLinkImage1_i(),this._GWizOEMOfferPopup_Label3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizOEMOfferPopup_Label1_c() : Label
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
      
      private function _GWizOEMOfferPopup_Label2_c() : Label
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
      
      private function _GWizOEMOfferPopup_GWizLinkImage1_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml____assets_FreeOffer_jpg_867513754;
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
      
      private function _GWizOEMOfferPopup_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "G-Wizard is used by tens of thousands of CNC\'ers at the world\'s best manufacturers.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",16);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizOEMOfferPopup_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizOEMOfferPopup_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():String
         {
            var _loc1_:* = OFFER_URL;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"graphic.url");
         return result;
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
   }
}
