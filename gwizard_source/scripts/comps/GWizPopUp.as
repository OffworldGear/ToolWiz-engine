package comps
{
   import flash.events.Event;
   import mx.core.FlexGlobals;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import spark.components.TitleWindow;
   import spark.components.VGroup;
   
   public class GWizPopUp extends VGroup
   {
      
      public static var padWidth:int = 50;
      
      public static var padHeight:int = 100;
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _title:String = "CNCCookbook";
      
      private var _1429812616okLabel:String = "OK";
      
      private var _1206778427okEnabled:Boolean = true;
      
      private var _1589748582cancelLabel:String = "Cancel";
      
      private var _1287124693backgroundColor:String = "black";
      
      private var _339191842showHelp:Boolean = false;
      
      private var _2144232107resizable:Boolean = false;
      
      private var _806066213fullScreen:Boolean = false;
      
      public var popupWindow:TitleWindow = null;
      
      public function GWizPopUp()
      {
         super();
         mx_internal::_document = this;
         this.paddingBottom = 10;
         this.paddingLeft = 10;
         this.paddingRight = 10;
         this.paddingTop = 10;
         this.percentWidth = 100;
         this.percentHeight = 100;
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
            this.color = 16777215;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      public function set title(param1:String) : void
      {
         this._title = param1;
         if(this.popupWindow)
         {
            this.popupWindow.title = param1;
         }
      }
      
      public function get title() : String
      {
         return this._title;
      }
      
      public function set showCloseButton(param1:Boolean) : void
      {
         if(this.popupWindow)
         {
            this.popupWindow.closeButton.visible = param1;
         }
      }
      
      public function set borderVisible(param1:Boolean) : void
      {
         if(this.popupWindow)
         {
            this.popupWindow.setStyle("borderVisible",param1);
         }
      }
      
      public function close() : void
      {
         GWizPopUpManager.removePopUp(this);
      }
      
      public function onOk(param1:Event) : void
      {
         this.close();
      }
      
      public function onCancel(param1:Event) : void
      {
         this.close();
      }
      
      public function onHelp(param1:Event) : void
      {
      }
      
      override public function set visible(param1:Boolean) : void
      {
         owner.visible = param1;
      }
      
      override public function get visible() : Boolean
      {
         return owner.visible;
      }
      
      public function centerPopUp() : void
      {
         GWizPopUpManager.centerPopUp(this);
      }
      
      public function resizeFullScreen() : void
      {
         this.width = Math.min(this.maxWidth,FlexGlobals.topLevelApplication.width - padWidth);
         this.height = Math.min(this.maxHeight,FlexGlobals.topLevelApplication.height - padHeight);
      }
      
      [Bindable(event="propertyChange")]
      public function get okLabel() : String
      {
         return this._1429812616okLabel;
      }
      
      public function set okLabel(param1:String) : void
      {
         var _loc2_:Object = this._1429812616okLabel;
         if(_loc2_ !== param1)
         {
            this._1429812616okLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"okLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get okEnabled() : Boolean
      {
         return this._1206778427okEnabled;
      }
      
      public function set okEnabled(param1:Boolean) : void
      {
         var _loc2_:Object = this._1206778427okEnabled;
         if(_loc2_ !== param1)
         {
            this._1206778427okEnabled = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"okEnabled",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cancelLabel() : String
      {
         return this._1589748582cancelLabel;
      }
      
      public function set cancelLabel(param1:String) : void
      {
         var _loc2_:Object = this._1589748582cancelLabel;
         if(_loc2_ !== param1)
         {
            this._1589748582cancelLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cancelLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get backgroundColor() : String
      {
         return this._1287124693backgroundColor;
      }
      
      public function set backgroundColor(param1:String) : void
      {
         var _loc2_:Object = this._1287124693backgroundColor;
         if(_loc2_ !== param1)
         {
            this._1287124693backgroundColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"backgroundColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get showHelp() : Boolean
      {
         return this._339191842showHelp;
      }
      
      public function set showHelp(param1:Boolean) : void
      {
         var _loc2_:Object = this._339191842showHelp;
         if(_loc2_ !== param1)
         {
            this._339191842showHelp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"showHelp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get resizable() : Boolean
      {
         return this._2144232107resizable;
      }
      
      public function set resizable(param1:Boolean) : void
      {
         var _loc2_:Object = this._2144232107resizable;
         if(_loc2_ !== param1)
         {
            this._2144232107resizable = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"resizable",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fullScreen() : Boolean
      {
         return this._806066213fullScreen;
      }
      
      public function set fullScreen(param1:Boolean) : void
      {
         var _loc2_:Object = this._806066213fullScreen;
         if(_loc2_ !== param1)
         {
            this._806066213fullScreen = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fullScreen",_loc2_,param1));
            }
         }
      }
   }
}
