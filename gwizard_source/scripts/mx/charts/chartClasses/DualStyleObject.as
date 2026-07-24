package mx.charts.chartClasses
{
   import mx.core.IFlexDisplayObject;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.styles.CSSStyleDeclaration;
   import mx.styles.IStyleClient;
   import mx.styles.StyleProtoChain;
   
   use namespace mx_internal;
   
   public class DualStyleObject extends UIComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _internalStyleName:Object;
      
      public function DualStyleObject()
      {
         super();
      }
      
      public function get internalStyleName() : Object
      {
         return this._internalStyleName;
      }
      
      public function set internalStyleName(param1:Object) : void
      {
         if(this._internalStyleName == param1)
         {
            return;
         }
         this._internalStyleName = param1;
         if(inheritingStyles != StyleProtoChain.STYLE_UNINITIALIZED)
         {
            regenerateStyleCache(true);
            initThemeColor();
            styleChanged("internalStyleName");
            styleChanged("styleName");
            notifyStyleChangeInChildren("styleName",true);
         }
      }
      
      override mx_internal function initProtoChain() : void
      {
         var _loc1_:CSSStyleDeclaration = null;
         var _loc2_:CSSStyleDeclaration = null;
         var _loc8_:Object = null;
         var _loc9_:CSSStyleDeclaration = null;
         if(styleName)
         {
            if(styleName is CSSStyleDeclaration)
            {
               _loc1_ = CSSStyleDeclaration(styleName);
            }
            else
            {
               if(styleName is IFlexDisplayObject)
               {
                  StyleProtoChain.initProtoChainForUIComponentStyleName(this);
                  return;
               }
               if(styleName is String)
               {
                  _loc1_ = styleManager.getStyleDeclaration("." + styleName);
               }
            }
         }
         if(this.internalStyleName)
         {
            if(this.internalStyleName is CSSStyleDeclaration)
            {
               _loc2_ = CSSStyleDeclaration(this.internalStyleName);
            }
            else
            {
               if(this.internalStyleName is IFlexDisplayObject)
               {
                  StyleProtoChain.initProtoChainForUIComponentStyleName(this);
                  return;
               }
               if(this.internalStyleName is String)
               {
                  _loc2_ = styleManager.getStyleDeclaration("." + this.internalStyleName);
               }
            }
         }
         var _loc3_:Object = styleManager.stylesRoot;
         if(_loc3_.effects)
         {
            registerEffects(_loc3_.effects);
         }
         var _loc4_:IStyleClient;
         if(_loc4_ = parent as IStyleClient)
         {
            if((_loc8_ = _loc4_.inheritingStyles) == StyleProtoChain.STYLE_UNINITIALIZED)
            {
               _loc8_ = _loc3_;
            }
         }
         else
         {
            _loc8_ = styleManager.stylesRoot;
         }
         var _loc5_:Array;
         var _loc6_:int = (_loc5_ = getClassStyleDeclarations()).length;
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc8_ = (_loc9_ = _loc5_[_loc7_]).addStyleToProtoChain(_loc8_,this);
            _loc3_ = _loc9_.addStyleToProtoChain(_loc3_,this);
            if(_loc9_.effects)
            {
               registerEffects(_loc9_.effects);
            }
            _loc7_++;
         }
         if(_loc2_)
         {
            _loc8_ = _loc2_.addStyleToProtoChain(_loc8_,this);
            _loc3_ = _loc2_.addStyleToProtoChain(_loc3_,this);
            if(_loc2_.effects)
            {
               registerEffects(_loc2_.effects);
            }
         }
         if(_loc1_)
         {
            _loc8_ = _loc1_.addStyleToProtoChain(_loc8_,this);
            _loc3_ = _loc1_.addStyleToProtoChain(_loc3_,this);
            if(_loc1_.effects)
            {
               registerEffects(_loc1_.effects);
            }
         }
         inheritingStyles = !!styleDeclaration ? styleDeclaration.addStyleToProtoChain(_loc8_,this) : _loc8_;
         nonInheritingStyles = !!styleDeclaration ? styleDeclaration.addStyleToProtoChain(_loc3_,this) : _loc3_;
      }
   }
}
