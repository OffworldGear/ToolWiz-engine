package spark.components.windowClasses
{
   import flash.display.DisplayObject;
   import flash.display.NativeWindowDisplayState;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.NativeWindowDisplayStateEvent;
   import flash.system.Capabilities;
   import mx.core.IWindow;
   import mx.core.mx_internal;
   import spark.components.Button;
   import spark.components.supportClasses.SkinnableComponent;
   import spark.components.supportClasses.TextBase;
   import spark.events.SkinPartEvent;
   import spark.primitives.BitmapImage;
   import spark.skins.spark.windowChrome.MacTitleBarSkin;
   import spark.skins.spark.windowChrome.TitleBarSkin;
   
   use namespace mx_internal;
   
   public class TitleBar extends SkinnableComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      mx_internal var titleIconObject:Object;
      
      [SkinPart(required="true")]
      public var closeButton:Button;
      
      [SkinPart(required="false")]
      public var maximizeButton:Button;
      
      [SkinPart(required="false")]
      public var minimizeButton:Button;
      
      [SkinPart(required="false")]
      public var titleIconImage:BitmapImage;
      
      [SkinPart(required="false")]
      public var titleText:TextBase;
      
      private var _title:String = "";
      
      private var titleChanged:Boolean = false;
      
      private var _titleIcon:Class;
      
      private var titleIconChanged:Boolean = false;
      
      public function TitleBar()
      {
         super();
         doubleClickEnabled = true;
         addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         addEventListener(MouseEvent.DOUBLE_CLICK,this.doubleClickHandler);
      }
      
      private static function isMac() : Boolean
      {
         return Capabilities.os.substring(0,3) == "Mac";
      }
      
      public function get title() : String
      {
         return this._title;
      }
      
      public function set title(param1:String) : void
      {
         this._title = param1;
         this.titleChanged = true;
         invalidateProperties();
         invalidateSize();
         invalidateDisplayList();
      }
      
      public function get titleIcon() : Class
      {
         return this._titleIcon;
      }
      
      public function set titleIcon(param1:Class) : void
      {
         this._titleIcon = param1;
         this.titleIconChanged = true;
         invalidateProperties();
         invalidateSize();
      }
      
      private function get window() : IWindow
      {
         var _loc1_:DisplayObject = parent;
         while(_loc1_ && !(_loc1_ is IWindow))
         {
            _loc1_ = _loc1_.parent;
         }
         return IWindow(_loc1_);
      }
      
      override protected function attachSkin() : void
      {
         if(isMac() && getStyle("skinClass") == TitleBarSkin)
         {
            setStyle("skinClass",MacTitleBarSkin);
         }
         super.attachSkin();
      }
      
      override protected function partAdded(param1:String, param2:Object) : void
      {
         var _loc3_:DisplayObject = null;
         super.partAdded(param1,param2);
         if(param2 == this.titleText)
         {
            this.titleText.text = this.title;
         }
         else if(param2 == this.closeButton)
         {
            this.closeButton.focusEnabled = false;
            this.closeButton.addEventListener(MouseEvent.MOUSE_DOWN,this.button_mouseDownHandler);
            this.closeButton.addEventListener(MouseEvent.CLICK,this.closeButton_clickHandler);
         }
         else if(param2 == this.minimizeButton)
         {
            this.minimizeButton.focusEnabled = false;
            this.minimizeButton.enabled = this.window.minimizable;
            this.minimizeButton.addEventListener(MouseEvent.MOUSE_DOWN,this.button_mouseDownHandler);
            this.minimizeButton.addEventListener(MouseEvent.CLICK,this.minimizeButton_clickHandler);
         }
         else if(param2 == this.maximizeButton)
         {
            this.maximizeButton.focusEnabled = false;
            this.maximizeButton.enabled = this.window.maximizable;
            this.maximizeButton.addEventListener(MouseEvent.MOUSE_DOWN,this.button_mouseDownHandler);
            this.maximizeButton.addEventListener(MouseEvent.CLICK,this.maximizeButton_clickHandler);
            _loc3_ = DisplayObject(this.window);
            _loc3_.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,this.window_displayStateChangeHandler,false,0,true);
            _loc3_.addEventListener(SkinPartEvent.PART_REMOVED,this.partRemovedHandler,false,0,true);
         }
      }
      
      override protected function partRemoved(param1:String, param2:Object) : void
      {
         var _loc3_:DisplayObject = null;
         super.partRemoved(param1,param2);
         if(param2 == this.closeButton)
         {
            this.closeButton.removeEventListener(MouseEvent.CLICK,this.closeButton_clickHandler);
         }
         else if(param2 == this.minimizeButton)
         {
            this.minimizeButton.removeEventListener(MouseEvent.MOUSE_DOWN,this.button_mouseDownHandler);
            this.minimizeButton.removeEventListener(MouseEvent.CLICK,this.minimizeButton_clickHandler);
         }
         else if(param2 == this.maximizeButton)
         {
            this.maximizeButton.removeEventListener(MouseEvent.MOUSE_DOWN,this.button_mouseDownHandler);
            this.maximizeButton.removeEventListener(MouseEvent.CLICK,this.maximizeButton_clickHandler);
            _loc3_ = DisplayObject(this.window);
            _loc3_.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,this.window_displayStateChangeHandler);
            _loc3_.removeEventListener(SkinPartEvent.PART_REMOVED,this.partRemovedHandler);
         }
      }
      
      override protected function commitProperties() : void
      {
         super.commitProperties();
         if(this.titleChanged)
         {
            this.titleText.text = this._title;
            this.titleChanged = false;
         }
         if(this.titleIconChanged)
         {
            if(this.titleIconObject)
            {
               this.titleIconImage.source = null;
               this.titleIconObject = null;
            }
            if(this._titleIcon && this.titleIconImage)
            {
               this.titleIconObject = new this._titleIcon();
               this.titleIconImage.source = this.titleIconObject;
            }
            this.titleIconChanged = false;
         }
      }
      
      override protected function getCurrentSkinState() : String
      {
         if(!this.window.nativeWindow.closed && this.window.nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED)
         {
            return !!enabled ? "normalAndMaximized" : "disabledAndMaximized";
         }
         return !!enabled ? "normal" : "disabled";
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         this.window.nativeWindow.startMove();
         param1.stopPropagation();
      }
      
      protected function doubleClickHandler(param1:MouseEvent) : void
      {
         if(isMac())
         {
            this.window.minimize();
         }
         else if(this.window.nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED)
         {
            this.window.restore();
         }
         else
         {
            this.window.maximize();
         }
      }
      
      private function button_mouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function minimizeButton_clickHandler(param1:Event) : void
      {
         this.window.minimize();
      }
      
      private function maximizeButton_clickHandler(param1:Event) : void
      {
         if(this.window.nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED)
         {
            this.window.restore();
         }
         else
         {
            this.window.maximize();
         }
         this.maximizeButton.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT));
      }
      
      private function closeButton_clickHandler(param1:Event) : void
      {
         this.window.close();
      }
      
      private function window_displayStateChangeHandler(param1:NativeWindowDisplayStateEvent) : void
      {
         if(param1.afterDisplayState == NativeWindowDisplayState.MAXIMIZED || param1.afterDisplayState == NativeWindowDisplayState.NORMAL)
         {
            invalidateSkinState();
         }
      }
      
      private function partRemovedHandler(param1:SkinPartEvent) : void
      {
         var _loc2_:DisplayObject = null;
         if(param1.instance == this)
         {
            _loc2_ = DisplayObject(this.window);
            _loc2_.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,this.window_displayStateChangeHandler);
            _loc2_.removeEventListener(SkinPartEvent.PART_REMOVED,this.partRemovedHandler);
         }
      }
   }
}
