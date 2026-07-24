package login
{
   import comps.GWizPopUp;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import spark.components.Label;
   import spark.components.VGroup;
   
   public class GWizVerDetails extends GWizPopUp
   {
       
      
      private var _736019638fileDate:Label;
      
      private var _1081445399manVer:Label;
      
      private var _1010155536optVer:Label;
      
      private var _88844982outerDocument:GWizLoginBar;
      
      private var _454913447siloDate:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizVerDetails()
      {
         super();
         mx_internal::_document = this;
         this.mxmlContent = [this._GWizVerDetails_VGroup1_c()];
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
      
      private function _GWizVerDetails_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizVerDetails_Label1_i(),this._GWizVerDetails_Label2_i(),this._GWizVerDetails_Label3_i(),this._GWizVerDetails_Label4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizVerDetails_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "fileDate";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fileDate = _loc1_;
         BindingManager.executeBindings(this,"fileDate",this.fileDate);
         return _loc1_;
      }
      
      private function _GWizVerDetails_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "siloDate";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.siloDate = _loc1_;
         BindingManager.executeBindings(this,"siloDate",this.siloDate);
         return _loc1_;
      }
      
      private function _GWizVerDetails_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "optVer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.optVer = _loc1_;
         BindingManager.executeBindings(this,"optVer",this.optVer);
         return _loc1_;
      }
      
      private function _GWizVerDetails_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "manVer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.manVer = _loc1_;
         BindingManager.executeBindings(this,"manVer",this.manVer);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get fileDate() : Label
      {
         return this._736019638fileDate;
      }
      
      public function set fileDate(param1:Label) : void
      {
         var _loc2_:Object = this._736019638fileDate;
         if(_loc2_ !== param1)
         {
            this._736019638fileDate = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fileDate",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get manVer() : Label
      {
         return this._1081445399manVer;
      }
      
      public function set manVer(param1:Label) : void
      {
         var _loc2_:Object = this._1081445399manVer;
         if(_loc2_ !== param1)
         {
            this._1081445399manVer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"manVer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get optVer() : Label
      {
         return this._1010155536optVer;
      }
      
      public function set optVer(param1:Label) : void
      {
         var _loc2_:Object = this._1010155536optVer;
         if(_loc2_ !== param1)
         {
            this._1010155536optVer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"optVer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizLoginBar
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizLoginBar) : void
      {
         var _loc2_:Object = this._88844982outerDocument;
         if(_loc2_ !== param1)
         {
            this._88844982outerDocument = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"outerDocument",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get siloDate() : Label
      {
         return this._454913447siloDate;
      }
      
      public function set siloDate(param1:Label) : void
      {
         var _loc2_:Object = this._454913447siloDate;
         if(_loc2_ !== param1)
         {
            this._454913447siloDate = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"siloDate",_loc2_,param1));
            }
         }
      }
   }
}
