package skins
{
   import comps.GridComponent;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.events.PropertyChangeEvent;
   import mx.states.SetProperty;
   import mx.states.State;
   import spark.components.Group;
   import spark.components.Image;
   import spark.components.supportClasses.Skin;
   import spark.layouts.BasicLayout;
   
   public class GridSkin extends Skin implements IStateClient2
   {
       
      
      private var _84872558bkImage:Image;
      
      private var _809612678contentGroup:Group;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _embed_mxml____assets_GridBackground_png_1849046176:Class;
      
      private var _213507019hostComponent:GridComponent;
      
      public function GridSkin()
      {
         this._embed_mxml____assets_GridBackground_png_1849046176 = GridSkin__embed_mxml____assets_GridBackground_png_1849046176;
         super();
         mx_internal::_document = this;
         this.mxmlContent = [this._GridSkin_Image1_i(),this._GridSkin_Group1_i()];
         this.currentState = "normal";
         states = [new State({
            "name":"normal",
            "overrides":[]
         }),new State({
            "name":"disabled",
            "overrides":[new SetProperty().initializeFromObject({
               "name":"alpha",
               "value":0.5
            })]
         })];
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
      
      private function _GridSkin_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.source = this._embed_mxml____assets_GridBackground_png_1849046176;
         _loc1_.width = 80;
         _loc1_.height = 80;
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.smooth = true;
         _loc1_.fillMode = "repeat";
         _loc1_.scaleX = 0.5;
         _loc1_.scaleY = 0.5;
         _loc1_.alpha = 0.1;
         _loc1_.setStyle("smoothingQuality","high");
         _loc1_.id = "bkImage";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.bkImage = _loc1_;
         BindingManager.executeBindings(this,"bkImage",this.bkImage);
         return _loc1_;
      }
      
      private function _GridSkin_Group1_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.minWidth = 0;
         _loc1_.minHeight = 0;
         _loc1_.layout = this._GridSkin_BasicLayout1_c();
         _loc1_.id = "contentGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.contentGroup = _loc1_;
         BindingManager.executeBindings(this,"contentGroup",this.contentGroup);
         return _loc1_;
      }
      
      private function _GridSkin_BasicLayout1_c() : BasicLayout
      {
         return new BasicLayout();
      }
      
      [Bindable(event="propertyChange")]
      public function get bkImage() : Image
      {
         return this._84872558bkImage;
      }
      
      public function set bkImage(param1:Image) : void
      {
         var _loc2_:Object = this._84872558bkImage;
         if(_loc2_ !== param1)
         {
            this._84872558bkImage = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"bkImage",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get contentGroup() : Group
      {
         return this._809612678contentGroup;
      }
      
      public function set contentGroup(param1:Group) : void
      {
         var _loc2_:Object = this._809612678contentGroup;
         if(_loc2_ !== param1)
         {
            this._809612678contentGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"contentGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hostComponent() : GridComponent
      {
         return this._213507019hostComponent;
      }
      
      public function set hostComponent(param1:GridComponent) : void
      {
         var _loc2_:Object = this._213507019hostComponent;
         if(_loc2_ !== param1)
         {
            this._213507019hostComponent = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hostComponent",_loc2_,param1));
            }
         }
      }
   }
}
