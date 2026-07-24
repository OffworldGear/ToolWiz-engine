package comps
{
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import skins.GWizForePanelSkin;
   import skins.GWizStylePalette;
   import spark.components.Panel;
   import utils.ColorPalette;
   
   use namespace mx_internal;
   
   public class GWizForePanel extends Panel implements IBindingClient
   {
      
      public static const DEF_LABEL_WIDTH:int = 90;
      
      public static const DEF_GAP_SIZE:int = 10;
      
      public static var metalBackgroundTexture:Class = GWizForePanel_metalBackgroundTexture;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var trackThemeStyles:Boolean = true;
      
      private var _835562194hideLabel:Boolean = false;
      
      private var _1657211086labelWidth:int = 90;
      
      private var _209262271labelBackgroundColor:uint;
      
      private var _1675495217labelColor:uint;
      
      private var _193361929gapSize:int = 10;
      
      private var _1296639716contentBackgroundColor:uint;
      
      private var _975087906contentFillAlpha:Number = 0.3;
      
      private var _1397355668contentBackgroundTexture:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizForePanel()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._209262271labelBackgroundColor = ColorPalette.gray3;
         this._1675495217labelColor = ColorPalette.primary5;
         this._1296639716contentBackgroundColor = ColorPalette.gray4;
         this._1397355668contentBackgroundTexture = metalBackgroundTexture;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizForePanel_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizForePanelWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizForePanel[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.addEventListener("creationComplete",this.___GWizForePanel_Panel1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizForePanel._watcherSetupUtil = param1;
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
            this.skinClass = GWizForePanelSkin;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function onCC() : void
      {
         if(true || GWizStylePalette.currTheme != GWizStylePalette.ORIGINAL_FLAVA)
         {
            GWizNumStep.checkUnitsCC.addFunction("GWizForePanel",this.checkUnits,false);
            this.checkUnits();
         }
      }
      
      private function checkUnits(param1:Object = null) : Boolean
      {
         if(this.trackThemeStyles)
         {
            GWizStylePalette.refreshThemeProperties(this);
            if(GWizStylePalette.currTheme != GWizStylePalette.ORIGINAL_FLAVA)
            {
               this.labelBackgroundColor = GWizStylePalette.BKGD_LVL_0;
               this.labelColor = GWizStylePalette.BkgdBlue;
               this.contentBackgroundColor = GWizStylePalette.BKGD_LVL_1;
               this.contentFillAlpha = 1;
               this.contentBackgroundTexture = null;
            }
            else
            {
               this.labelBackgroundColor = ColorPalette.gray3;
               this.labelColor = ColorPalette.primary5;
               this.contentBackgroundColor = ColorPalette.gray4;
               this.contentFillAlpha = 0.3;
               this.contentBackgroundTexture = metalBackgroundTexture;
            }
            this.invalidateDisplayList();
         }
         return true;
      }
      
      public function ___GWizForePanel_Panel1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizForePanel_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return GWizStylePalette.borderColor;
         },function(param1:uint):void
         {
            this.setStyle("borderColor",param1);
         },"this.borderColor");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get hideLabel() : Boolean
      {
         return this._835562194hideLabel;
      }
      
      public function set hideLabel(param1:Boolean) : void
      {
         var _loc2_:Object = this._835562194hideLabel;
         if(_loc2_ !== param1)
         {
            this._835562194hideLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hideLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labelWidth() : int
      {
         return this._1657211086labelWidth;
      }
      
      public function set labelWidth(param1:int) : void
      {
         var _loc2_:Object = this._1657211086labelWidth;
         if(_loc2_ !== param1)
         {
            this._1657211086labelWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labelWidth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labelBackgroundColor() : uint
      {
         return this._209262271labelBackgroundColor;
      }
      
      public function set labelBackgroundColor(param1:uint) : void
      {
         var _loc2_:Object = this._209262271labelBackgroundColor;
         if(_loc2_ !== param1)
         {
            this._209262271labelBackgroundColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labelBackgroundColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labelColor() : uint
      {
         return this._1675495217labelColor;
      }
      
      public function set labelColor(param1:uint) : void
      {
         var _loc2_:Object = this._1675495217labelColor;
         if(_loc2_ !== param1)
         {
            this._1675495217labelColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labelColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gapSize() : int
      {
         return this._193361929gapSize;
      }
      
      public function set gapSize(param1:int) : void
      {
         var _loc2_:Object = this._193361929gapSize;
         if(_loc2_ !== param1)
         {
            this._193361929gapSize = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gapSize",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get contentBackgroundColor() : uint
      {
         return this._1296639716contentBackgroundColor;
      }
      
      public function set contentBackgroundColor(param1:uint) : void
      {
         var _loc2_:Object = this._1296639716contentBackgroundColor;
         if(_loc2_ !== param1)
         {
            this._1296639716contentBackgroundColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"contentBackgroundColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get contentFillAlpha() : Number
      {
         return this._975087906contentFillAlpha;
      }
      
      public function set contentFillAlpha(param1:Number) : void
      {
         var _loc2_:Object = this._975087906contentFillAlpha;
         if(_loc2_ !== param1)
         {
            this._975087906contentFillAlpha = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"contentFillAlpha",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get contentBackgroundTexture() : Class
      {
         return this._1397355668contentBackgroundTexture;
      }
      
      public function set contentBackgroundTexture(param1:Class) : void
      {
         var _loc2_:Object = this._1397355668contentBackgroundTexture;
         if(_loc2_ !== param1)
         {
            this._1397355668contentBackgroundTexture = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"contentBackgroundTexture",_loc2_,param1));
            }
         }
      }
   }
}
