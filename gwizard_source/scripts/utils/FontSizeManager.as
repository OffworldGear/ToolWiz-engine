package utils
{
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.ui.Keyboard;
   import mx.core.FlexGlobals;
   import mx.events.FlexEvent;
   import mx.managers.ICursorManager;
   import mx.styles.CSSStyleDeclaration;
   import mx.styles.IStyleManager2;
   
   public class FontSizeManager extends EventDispatcher
   {
      
      public static const SMALL_FONT:Number = 12;
      
      public static const MEDIUM_FONT:Number = 14;
      
      public static const LARGE_FONT:Number = 16;
      
      public static const DEFAULT_FONT_SIZE:Number = 12;
      
      public static const MAX_FONT_SIZE:Number = 50;
      
      public static const MIN_FONT_SIZE:Number = 8;
      
      public static const AMOUNT_OF_STYLE_CLASSES:Number = 10;
      
      public static const SCALE_FONT_SIZES:Boolean = true;
       
      
      private var application;
      
      private var styleManager:IStyleManager2;
      
      private var cursorManager:ICursorManager;
      
      private var declarations:Vector.<CSSStyleDeclaration>;
      
      private var global:CSSStyleDeclaration;
      
      private var globalDefaultFontSize:Number;
      
      private var stages:Vector.<Stage>;
      
      private var changing:Boolean = false;
      
      private var pending:Boolean = false;
      
      private var _fontSize:Number = 12;
      
      public function FontSizeManager()
      {
         this.stages = new Vector.<Stage>();
         super();
         this.initialize();
      }
      
      [Bindable("fontSizeChange")]
      public function get fontSize() : Number
      {
         return this._fontSize;
      }
      
      public function set fontSize(param1:Number) : void
      {
         param1 = Math.max(param1,MIN_FONT_SIZE);
         param1 = Math.min(param1,MAX_FONT_SIZE);
         if(this._fontSize == param1)
         {
            return;
         }
         this._fontSize = param1;
         this.setFontSizeToStyles();
         dispatchEvent(new Event("fontSizeChange"));
      }
      
      private function initialize() : void
      {
         var _loc4_:String = null;
         var _loc5_:CSSStyleDeclaration = null;
         this.application = FlexGlobals.topLevelApplication;
         this.styleManager = this.application.styleManager;
         this.cursorManager = this.application.cursorManager;
         this.declarations = new Vector.<CSSStyleDeclaration>();
         var _loc1_:int = AMOUNT_OF_STYLE_CLASSES;
         var _loc2_:int = -_loc1_;
         while(_loc2_ <= _loc1_)
         {
            if(_loc2_ != 0)
            {
               _loc4_ = ".fontSizeDelta" + _loc2_;
               _loc5_ = new CSSStyleDeclaration(_loc4_,this.styleManager,false);
               this.declarations.push(_loc5_);
               this.styleManager.setStyleDeclaration(_loc4_,_loc5_,false);
            }
            _loc2_++;
         }
         this.global = this.styleManager.getStyleDeclaration("global");
         this.globalDefaultFontSize = this.global.getStyle("fontSize");
         this.setFontSizeToStyles();
         var _loc3_:Stage = this.application.stage;
         if(_loc3_)
         {
            this.addStage(_loc3_);
         }
         else
         {
            this.application.addEventListener(Event.ADDED_TO_STAGE,this.application_addedToStage);
         }
      }
      
      private function setFontSizeToStyles() : void
      {
         var _loc2_:CSSStyleDeclaration = null;
         var _loc3_:String = null;
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         if(this.changing)
         {
            this.pending = true;
            return;
         }
         this.changing = true;
         this.pending = false;
         var _loc1_:int = this.declarations.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc1_)
         {
            _loc2_ = this.declarations[_loc4_];
            _loc3_ = _loc2_.selector.toString();
            _loc8_ = int(_loc3_.substr(".fontSizeDelta".length));
            _loc2_.setStyle("fontSize",this.getFontSizeForDelta(_loc8_));
            this.styleManager.setStyleDeclaration(_loc3_,_loc2_,false);
            _loc4_++;
         }
         var _loc5_:Array;
         var _loc6_:int = (_loc5_ = this.styleManager.selectors).length;
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc3_ = _loc5_[_loc7_];
            _loc2_ = this.styleManager.getStyleDeclaration(_loc3_);
            _loc9_ = _loc2_.getStyle("fontSizeDelta");
            if(!(isNaN(_loc9_) || _loc9_ == 0))
            {
               _loc2_.setStyle("fontSize",this.getFontSizeForDelta(_loc9_));
               this.styleManager.setStyleDeclaration(_loc3_,_loc2_,false);
            }
            _loc7_++;
         }
         this.global.setStyle("fontSize",this._fontSize);
         this.styleManager.setStyleDeclaration("global",this.global,true);
         this.application.addEventListener(FlexEvent.UPDATE_COMPLETE,this.application_updateCompleteHandler);
         this.cursorManager.setBusyCursor();
      }
      
      private function getFontSizeForDelta(param1:Number) : Number
      {
         var _loc2_:Number = NaN;
         if(SCALE_FONT_SIZES)
         {
            _loc2_ = this._fontSize * (DEFAULT_FONT_SIZE + param1) / DEFAULT_FONT_SIZE;
         }
         else
         {
            _loc2_ = this._fontSize + param1;
         }
         _loc2_ = Math.max(_loc2_,MIN_FONT_SIZE);
         return Math.min(_loc2_,MAX_FONT_SIZE);
      }
      
      public function addStage(param1:Stage) : void
      {
         if(this.stages.indexOf(param1) >= 0)
         {
            return;
         }
         param1.addEventListener(KeyboardEvent.KEY_UP,this.stage_keyUpHandler);
         param1.addEventListener(MouseEvent.MOUSE_WHEEL,this.stage_mouseWheelHandler);
         this.stages.push(param1);
      }
      
      public function removeStage(param1:Stage) : void
      {
         if(this.stages.indexOf(param1) == -1)
         {
            return;
         }
         param1.removeEventListener(MouseEvent.MOUSE_WHEEL,this.stage_mouseWheelHandler);
         param1.removeEventListener(KeyboardEvent.KEY_UP,this.stage_keyUpHandler);
         this.stages.splice(this.stages.indexOf(param1),1);
      }
      
      public function destroy() : void
      {
         var _loc5_:CSSStyleDeclaration = null;
         var _loc6_:String = null;
         var _loc11_:Number = NaN;
         this.application.removeEventListener(Event.ADDED_TO_STAGE,this.application_addedToStage);
         this.application.removeEventListener(FlexEvent.UPDATE_COMPLETE,this.application_updateCompleteHandler);
         var _loc1_:Vector.<Stage> = this.stages.concat();
         var _loc2_:int = _loc1_.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            this.removeStage(_loc1_[_loc3_]);
            _loc3_++;
         }
         this.stages = null;
         this.global.setStyle("fontSize",this.globalDefaultFontSize);
         this.styleManager.setStyleDeclaration("global",this.global,false);
         this.global = null;
         var _loc4_:Array;
         var _loc7_:int = (_loc4_ = this.styleManager.selectors).length;
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_)
         {
            _loc6_ = _loc4_[_loc8_];
            _loc11_ = (_loc5_ = this.styleManager.getStyleDeclaration(_loc6_)).getStyle("fontSizeDelta");
            if(!(isNaN(_loc11_) || _loc11_ == 0))
            {
               _loc5_.clearStyle("fontSize");
               this.styleManager.setStyleDeclaration(_loc6_,_loc5_,false);
            }
            _loc8_++;
         }
         var _loc9_:int = this.declarations.length;
         var _loc10_:int = 0;
         while(_loc10_ < _loc9_)
         {
            _loc6_ = (_loc5_ = this.declarations[_loc10_]).selector.toString();
            this.styleManager.clearStyleDeclaration(_loc6_,_loc10_ == _loc9_ - 1);
            _loc10_++;
         }
         this.declarations = null;
         this.styleManager = null;
         this.cursorManager = null;
         this.application = null;
      }
      
      private function stage_keyUpHandler(param1:KeyboardEvent) : void
      {
         if(!param1.ctrlKey)
         {
            return;
         }
         var _loc2_:uint = param1.keyCode;
         if(_loc2_ == Keyboard.NUMPAD_ADD || _loc2_ == Keyboard.PAGE_UP || _loc2_ == 187)
         {
            trace("Font Size: " + this.fontSize);
            ++this.fontSize;
         }
         else if(_loc2_ == Keyboard.NUMPAD_SUBTRACT || _loc2_ == Keyboard.PAGE_DOWN || _loc2_ == 189)
         {
            --this.fontSize;
         }
      }
      
      private function stage_mouseWheelHandler(param1:MouseEvent) : void
      {
         if(!param1.ctrlKey)
         {
            return;
         }
         if(param1.delta > 0)
         {
            ++this.fontSize;
         }
         else
         {
            --this.fontSize;
         }
      }
      
      private function application_updateCompleteHandler(param1:FlexEvent) : void
      {
         this.application.removeEventListener(FlexEvent.UPDATE_COMPLETE,this.application_updateCompleteHandler);
         this.cursorManager.removeBusyCursor();
         this.changing = false;
         if(this.pending)
         {
            this.setFontSizeToStyles();
         }
      }
      
      private function application_addedToStage(param1:Event) : void
      {
         this.application.removeEventListener(Event.ADDED_TO_STAGE,this.application_addedToStage);
         this.addStage(param1.target.stage);
      }
   }
}
