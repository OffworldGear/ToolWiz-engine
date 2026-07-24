package mx.skins.spark
{
   import mx.binding.BindingManager;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.SolidColor;
   import mx.states.AddItems;
   import mx.states.SetProperty;
   import mx.states.State;
   import spark.components.supportClasses.Skin;
   import spark.primitives.Rect;
   
   public class MenuItemSkin extends Skin implements IStateClient2
   {
       
      
      public var _MenuItemSkin_Rect1:Rect;
      
      public var _MenuItemSkin_Rect2:Rect;
      
      private var _57880440_MenuItemSkin_SolidColor1:SolidColor;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function MenuItemSkin()
      {
         super();
         mx_internal::_document = this;
         this.minWidth = 21;
         this.minHeight = 21;
         this.mxmlContent = [];
         this.currentState = "up";
         var _loc1_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._MenuItemSkin_Rect1_i);
         var _loc2_:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(this._MenuItemSkin_Rect2_i);
         states = [new State({
            "name":"up",
            "overrides":[]
         }),new State({
            "name":"over",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"first"
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"first"
            }),new SetProperty().initializeFromObject({
               "target":"_MenuItemSkin_SolidColor1",
               "name":"color",
               "value":2722303
            }),new SetProperty().initializeFromObject({
               "target":"_MenuItemSkin_SolidColor1",
               "name":"alpha",
               "value":0.15
            })]
         }),new State({
            "name":"down",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"first"
            }),new AddItems().initializeFromObject({
               "itemsFactory":_loc1_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"first"
            }),new SetProperty().initializeFromObject({
               "target":"_MenuItemSkin_SolidColor1",
               "name":"color",
               "value":2722303
            }),new SetProperty().initializeFromObject({
               "target":"_MenuItemSkin_SolidColor1",
               "name":"alpha",
               "value":0.4
            })]
         }),new State({
            "name":"disabled",
            "overrides":[new AddItems().initializeFromObject({
               "itemsFactory":_loc2_,
               "destination":null,
               "propertyName":"mxmlContent",
               "position":"first"
            }),new SetProperty().initializeFromObject({
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
      
      private function _MenuItemSkin_Rect1_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 1;
         _loc1_.bottom = 1;
         _loc1_.fill = this._MenuItemSkin_SolidColor1_i();
         _loc1_.initialized(this,"_MenuItemSkin_Rect1");
         this._MenuItemSkin_Rect1 = _loc1_;
         BindingManager.executeBindings(this,"_MenuItemSkin_Rect1",this._MenuItemSkin_Rect1);
         return _loc1_;
      }
      
      private function _MenuItemSkin_SolidColor1_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         this._MenuItemSkin_SolidColor1 = _loc1_;
         BindingManager.executeBindings(this,"_MenuItemSkin_SolidColor1",this._MenuItemSkin_SolidColor1);
         return _loc1_;
      }
      
      private function _MenuItemSkin_Rect2_i() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 1;
         _loc1_.height = 9;
         _loc1_.fill = this._MenuItemSkin_SolidColor2_c();
         _loc1_.initialized(this,"_MenuItemSkin_Rect2");
         this._MenuItemSkin_Rect2 = _loc1_;
         BindingManager.executeBindings(this,"_MenuItemSkin_Rect2",this._MenuItemSkin_Rect2);
         return _loc1_;
      }
      
      private function _MenuItemSkin_SolidColor2_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.33;
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get _MenuItemSkin_SolidColor1() : SolidColor
      {
         return this._57880440_MenuItemSkin_SolidColor1;
      }
      
      public function set _MenuItemSkin_SolidColor1(param1:SolidColor) : void
      {
         var _loc2_:Object = this._57880440_MenuItemSkin_SolidColor1;
         if(_loc2_ !== param1)
         {
            this._57880440_MenuItemSkin_SolidColor1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_MenuItemSkin_SolidColor1",_loc2_,param1));
            }
         }
      }
   }
}
