package spark.skins.spark.windowChrome
{
   import mx.binding.BindingManager;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.events.PropertyChangeEvent;
   import mx.states.AddItems;
   import mx.states.State;
   import spark.components.Button;
   import spark.components.supportClasses.Skin;
   import spark.primitives.BitmapImage;
   
   public class RestoreButtonSkin extends Skin implements IStateClient2
   {
       
      
      public var _RestoreButtonSkin_BitmapImage1:BitmapImage;
      
      public var _RestoreButtonSkin_BitmapImage2:BitmapImage;
      
      public var _RestoreButtonSkin_BitmapImage3:BitmapImage;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _embed_mxml________________assets_win_restore_down_png_1856788178:Class;
      
      private var _embed_mxml________________assets_win_restore_over_png_1985754978:Class;
      
      private var _embed_mxml________________assets_win_restore_up_png_1708109980:Class;
      
      private var _213507019hostComponent:Button;
      
      public function RestoreButtonSkin()
      {
         this._embed_mxml________________assets_win_restore_down_png_1856788178 = RestoreButtonSkin__embed_mxml________________assets_win_restore_down_png_1856788178;
         this._embed_mxml________________assets_win_restore_over_png_1985754978 = RestoreButtonSkin__embed_mxml________________assets_win_restore_over_png_1985754978;
         this._embed_mxml________________assets_win_restore_up_png_1708109980 = RestoreButtonSkin__embed_mxml________________assets_win_restore_up_png_1708109980;
         super();
         mx_internal::_document = this;
         this.minWidth = 12;
         this.minHeight = 13;
         this.mxmlContent = [];
         this.currentState = "up";
         var _loc1_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._RestoreButtonSkin_BitmapImage1_i);
         var _loc2_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._RestoreButtonSkin_BitmapImage2_i);
         var _loc3_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._RestoreButtonSkin_BitmapImage3_i);
         states = [new State({
            "name":"up",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"first"
            })]
         }),new State({
            "name":"over",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"first"
            })]
         }),new State({
            "name":"down",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc3_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"first"
            })]
         }),new State({
            "name":"disabled",
            "overrides":[]
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
      
      private function _RestoreButtonSkin_BitmapImage1_i() : BitmapImage
      {
         var _loc1_:BitmapImage = new BitmapImage();
         _loc1_.source = this._embed_mxml________________assets_win_restore_up_png_1708109980;
         _loc1_.left = 0;
         _loc1_.verticalCenter = 0;
         _loc1_.fillMode = "clip";
         _loc1_.initialized(this,"_RestoreButtonSkin_BitmapImage1");
         this._RestoreButtonSkin_BitmapImage1 = _loc1_;
         BindingManager.executeBindings(this,"_RestoreButtonSkin_BitmapImage1",this._RestoreButtonSkin_BitmapImage1);
         return _loc1_;
      }
      
      private function _RestoreButtonSkin_BitmapImage2_i() : BitmapImage
      {
         var _loc1_:BitmapImage = new BitmapImage();
         _loc1_.source = this._embed_mxml________________assets_win_restore_over_png_1985754978;
         _loc1_.left = 0;
         _loc1_.verticalCenter = 0;
         _loc1_.fillMode = "clip";
         _loc1_.initialized(this,"_RestoreButtonSkin_BitmapImage2");
         this._RestoreButtonSkin_BitmapImage2 = _loc1_;
         BindingManager.executeBindings(this,"_RestoreButtonSkin_BitmapImage2",this._RestoreButtonSkin_BitmapImage2);
         return _loc1_;
      }
      
      private function _RestoreButtonSkin_BitmapImage3_i() : BitmapImage
      {
         var _loc1_:BitmapImage = new BitmapImage();
         _loc1_.source = this._embed_mxml________________assets_win_restore_down_png_1856788178;
         _loc1_.left = 0;
         _loc1_.verticalCenter = 0;
         _loc1_.fillMode = "clip";
         _loc1_.initialized(this,"_RestoreButtonSkin_BitmapImage3");
         this._RestoreButtonSkin_BitmapImage3 = _loc1_;
         BindingManager.executeBindings(this,"_RestoreButtonSkin_BitmapImage3",this._RestoreButtonSkin_BitmapImage3);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get hostComponent() : Button
      {
         return this._213507019hostComponent;
      }
      
      public function set hostComponent(param1:Button) : void
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
