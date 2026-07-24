package utils
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.core.IMXMLObject;
   import mx.core.Singleton;
   import mx.styles.CSSStyleDeclaration;
   import mx.styles.IStyleManager2;
   
   public class StylesheetMixin implements IMXMLObject
   {
       
      
      private var _palettes:Array;
      
      private var timer:Sprite;
      
      public function StylesheetMixin()
      {
         this.timer = new Sprite();
         super();
      }
      
      public function get palettes() : Array
      {
         return this._palettes;
      }
      
      public function set palettes(param1:Array) : void
      {
         this._palettes = param1;
      }
      
      public function setStyles() : void
      {
         var _loc3_:CSSStyleDeclaration = null;
         var _loc1_:IStyleManager2 = this.getStyleManager();
         var _loc2_:Array = _loc1_.selectors;
         var _loc4_:int = 0;
         var _loc5_:int = _loc2_.length;
         while(_loc4_ < _loc5_)
         {
            _loc3_ = _loc1_.getStyleDeclaration(_loc2_[_loc4_]);
            this.setProperties(_loc3_);
            _loc4_++;
         }
      }
      
      protected function getStyleManager() : IStyleManager2
      {
         var application:* = undefined;
         try
         {
            application = getDefinitionByName("mx.core::FlexGlobals")["topLevelApplication"];
            if(application)
            {
               return application.styleManager as IStyleManager2;
            }
         }
         catch(error:Error)
         {
            application = getDefinitionByName("mx.core::Application")["application"];
            if(application)
            {
               return IStyleManager2(Singleton.getInstance("mx.styles::IStyleManager2"));
            }
         }
         return null;
      }
      
      protected function setProperties(param1:CSSStyleDeclaration) : void
      {
         var _loc3_:* = null;
         var _loc2_:Object = this.getDeclarationToken(param1);
         for(_loc3_ in _loc2_)
         {
            this.setProperty(param1,_loc3_,_loc2_[_loc3_]);
         }
      }
      
      public function getDeclarationToken(param1:CSSStyleDeclaration) : Object
      {
         var _loc2_:Object = {"factory":param1.factory};
         if(typeof _loc2_.factory != "function" || _loc2_.factory == null)
         {
            return null;
         }
         _loc2_.factory();
         delete _loc2_.factory;
         return _loc2_;
      }
      
      public function setProperty(param1:CSSStyleDeclaration, param2:String, param3:*) : *
      {
         var _loc4_:* = undefined;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc5_:Boolean = false;
         if(param3 is Array)
         {
            _loc6_ = 0;
            _loc7_ = param3.length;
            while(_loc6_ < _loc7_)
            {
               if(_loc4_ = this.getPaletteItem(param3[_loc6_]))
               {
                  _loc5_ = true;
                  param3[_loc6_] = _loc4_;
               }
               _loc6_++;
            }
         }
         else if(param3 is String)
         {
            if(_loc4_ = this.getPaletteItem(param3))
            {
               param3 = _loc4_;
               _loc5_ = true;
            }
         }
         if(_loc5_)
         {
            param1.setStyle(param2,param3);
         }
      }
      
      public function getPaletteItem(param1:String) : *
      {
         var _loc4_:Object = null;
         var _loc2_:int = 0;
         var _loc3_:int = this.palettes.length;
         while(_loc2_ < _loc3_)
         {
            if((_loc4_ = this.palettes[_loc2_])[param1])
            {
               return _loc4_[param1];
            }
            _loc2_++;
         }
         return null;
      }
      
      public function initialized(param1:Object, param2:String) : void
      {
         var handler:Function = null;
         var document:Object = param1;
         var id:String = param2;
         handler = function(param1:Event):void
         {
            timer.removeEventListener(Event.ENTER_FRAME,handler);
            timer = null;
            setStyles();
         };
         this.timer.addEventListener(Event.ENTER_FRAME,handler);
      }
   }
}
