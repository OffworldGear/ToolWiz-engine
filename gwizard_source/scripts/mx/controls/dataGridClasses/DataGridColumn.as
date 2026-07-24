package mx.controls.dataGridClasses
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import mx.controls.TextInput;
   import mx.controls.listClasses.IListItemRenderer;
   import mx.core.ClassFactory;
   import mx.core.ContextualClassFactory;
   import mx.core.IEmbeddedFontRegistry;
   import mx.core.IFactory;
   import mx.core.IFlexModuleFactory;
   import mx.core.IIMESupport;
   import mx.core.Singleton;
   import mx.core.mx_internal;
   import mx.styles.CSSStyleDeclaration;
   import mx.utils.StringUtil;
   
   use namespace mx_internal;
   
   public class DataGridColumn extends CSSStyleDeclaration implements IIMESupport
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static var noEmbeddedFonts:Boolean;
      
      private static var _embeddedFontRegistry:IEmbeddedFontRegistry;
      
      private static var _defaultItemEditorFactory:IFactory;
       
      
      mx_internal var owner:DataGridBase;
      
      mx_internal var explicitWidth:Number;
      
      mx_internal var cachedHeaderRenderer:IListItemRenderer;
      
      private var oldEmbeddedFontContext:IFlexModuleFactory = null;
      
      private var oldHeaderEmbeddedFontContext:IFlexModuleFactory = null;
      
      protected var hasComplexFieldName:Boolean = false;
      
      protected var complexFieldNameComponents:Array;
      
      public var sortDescending:Boolean = false;
      
      private var _itemRenderer:IFactory;
      
      private var _contextItemRenderer:IFactory;
      
      mx_internal var colNum:Number;
      
      private var _dataField:String;
      
      private var _dataTipField:String;
      
      private var _dataTipFunction:Function;
      
      public var draggable:Boolean = true;
      
      private var _editable:Boolean = true;
      
      public var itemEditor:IFactory;
      
      public var editorDataField:String = "text";
      
      public var editorHeightOffset:Number = 0;
      
      public var editorWidthOffset:Number = 0;
      
      public var editorXOffset:Number = 0;
      
      public var editorYOffset:Number = 0;
      
      public var editorUsesEnterKey:Boolean = false;
      
      private var _headerRenderer:IFactory;
      
      private var _contextHeaderRenderer:IFactory;
      
      private var _headerText:String;
      
      private var _headerWordWrap;
      
      private var _imeMode:String;
      
      public var rendererIsEditor:Boolean = false;
      
      private var _labelFunction:Function;
      
      private var _minWidth:Number = 20;
      
      private var _nullItemRenderer:IFactory;
      
      private var _contextNullItemRenderer:IFactory;
      
      public var resizable:Boolean = true;
      
      private var _showDataTips;
      
      public var sortable:Boolean = true;
      
      private var _sortCompareFunction:Function;
      
      private var _visible:Boolean = true;
      
      mx_internal var newlyVisible:Boolean = false;
      
      private var _width:Number = 100;
      
      mx_internal var preferredWidth:Number = 100;
      
      private var _wordWrap;
      
      mx_internal var measuringObjects:Dictionary;
      
      mx_internal var freeItemRenderersByFactory:Dictionary;
      
      public function DataGridColumn(param1:String = null)
      {
         this.itemEditor = mx_internal::defaultItemEditorFactory;
         super();
         if(param1)
         {
            this.dataField = param1;
            this.headerText = param1;
         }
      }
      
      private static function get embeddedFontRegistry() : IEmbeddedFontRegistry
      {
         if(!_embeddedFontRegistry && !noEmbeddedFonts)
         {
            try
            {
               _embeddedFontRegistry = IEmbeddedFontRegistry(Singleton.getInstance("mx.core::IEmbeddedFontRegistry"));
            }
            catch(e:Error)
            {
               noEmbeddedFonts = true;
            }
         }
         return _embeddedFontRegistry;
      }
      
      mx_internal static function get defaultItemEditorFactory() : IFactory
      {
         if(!_defaultItemEditorFactory)
         {
            _defaultItemEditorFactory = new ClassFactory(TextInput);
         }
         return _defaultItemEditorFactory;
      }
      
      [Bindable("itemRendererChanged")]
      public function get itemRenderer() : IFactory
      {
         return this._itemRenderer;
      }
      
      public function set itemRenderer(param1:IFactory) : void
      {
         this._itemRenderer = param1;
         if(this.owner)
         {
            this.owner.invalidateList();
            this.owner.columnRendererChanged(this);
            this._contextItemRenderer = null;
         }
         dispatchEvent(new Event("itemRendererChanged"));
      }
      
      public function get dataField() : String
      {
         return this._dataField;
      }
      
      public function set dataField(param1:String) : void
      {
         this._dataField = param1;
         if(param1.indexOf(".") != -1)
         {
            this.hasComplexFieldName = true;
            this.complexFieldNameComponents = param1.split(".");
            if(this._sortCompareFunction == null)
            {
               this._sortCompareFunction = this.complexColumnSortCompare;
            }
         }
         else
         {
            this.hasComplexFieldName = false;
         }
         if(this.owner)
         {
            this.owner.invalidateList();
         }
      }
      
      [Bindable("dataTipFieldChanged")]
      public function get dataTipField() : String
      {
         return this._dataTipField;
      }
      
      public function set dataTipField(param1:String) : void
      {
         this._dataTipField = param1;
         if(this.owner)
         {
            this.owner.invalidateList();
         }
         dispatchEvent(new Event("dataTipChanged"));
      }
      
      [Bindable("dataTipFunctionChanged")]
      public function get dataTipFunction() : Function
      {
         return this._dataTipFunction;
      }
      
      public function set dataTipFunction(param1:Function) : void
      {
         this._dataTipFunction = param1;
         if(this.owner)
         {
            this.owner.invalidateList();
         }
         dispatchEvent(new Event("labelFunctionChanged"));
      }
      
      public function get editable() : Boolean
      {
         return this._editable;
      }
      
      public function set editable(param1:Boolean) : void
      {
         this._editable = param1;
      }
      
      public function get enableIME() : Boolean
      {
         return false;
      }
      
      [Bindable("headerRendererChanged")]
      public function get headerRenderer() : IFactory
      {
         return this._headerRenderer;
      }
      
      public function set headerRenderer(param1:IFactory) : void
      {
         this._headerRenderer = param1;
         if(this.owner)
         {
            this.owner.invalidateList();
            this.owner.columnRendererChanged(this);
            this._contextHeaderRenderer = null;
         }
         dispatchEvent(new Event("headerRendererChanged"));
      }
      
      [Bindable("headerTextChanged")]
      public function get headerText() : String
      {
         return this._headerText != null ? this._headerText : this.dataField;
      }
      
      public function set headerText(param1:String) : void
      {
         this._headerText = param1;
         if(this.owner)
         {
            this.owner.invalidateList();
         }
         dispatchEvent(new Event("headerTextChanged"));
      }
      
      public function get headerWordWrap() : *
      {
         return this._headerWordWrap;
      }
      
      public function set headerWordWrap(param1:*) : void
      {
         this._headerWordWrap = param1;
         if(this.owner)
         {
            this.owner.invalidateList();
         }
      }
      
      public function get imeMode() : String
      {
         return this._imeMode;
      }
      
      public function set imeMode(param1:String) : void
      {
         this._imeMode = param1;
      }
      
      [Bindable("labelFunctionChanged")]
      public function get labelFunction() : Function
      {
         return this._labelFunction;
      }
      
      public function set labelFunction(param1:Function) : void
      {
         this._labelFunction = param1;
         if(this.owner)
         {
            this.owner.invalidateList();
         }
         dispatchEvent(new Event("labelFunctionChanged"));
      }
      
      [Bindable("minWidthChanged")]
      public function get minWidth() : Number
      {
         return this._minWidth;
      }
      
      public function set minWidth(param1:Number) : void
      {
         this._minWidth = param1;
         if(this.owner)
         {
            this.owner.invalidateList();
         }
         if(this._width < param1)
         {
            this._width = param1;
         }
         dispatchEvent(new Event("minWidthChanged"));
      }
      
      [Bindable("nullItemRendererChanged")]
      public function get nullItemRenderer() : IFactory
      {
         return this._nullItemRenderer;
      }
      
      public function set nullItemRenderer(param1:IFactory) : void
      {
         this._nullItemRenderer = param1;
         if(this.owner)
         {
            this.owner.invalidateList();
            this.owner.columnRendererChanged(this);
            this._contextNullItemRenderer = null;
         }
         dispatchEvent(new Event("nullItemRendererChanged"));
      }
      
      public function get showDataTips() : *
      {
         return this._showDataTips;
      }
      
      public function set showDataTips(param1:*) : void
      {
         this._showDataTips = param1;
         if(this.owner)
         {
            this.owner.invalidateList();
         }
      }
      
      [Bindable("sortCompareFunctionChanged")]
      public function get sortCompareFunction() : Function
      {
         return this._sortCompareFunction;
      }
      
      public function set sortCompareFunction(param1:Function) : void
      {
         this._sortCompareFunction = param1;
         dispatchEvent(new Event("sortCompareFunctionChanged"));
      }
      
      public function get visible() : Boolean
      {
         return this._visible;
      }
      
      public function set visible(param1:Boolean) : void
      {
         if(this._visible != param1)
         {
            this._visible = param1;
            if(param1)
            {
               this.newlyVisible = true;
            }
            if(this.owner)
            {
               this.owner.columnsInvalid = true;
               this.owner.invalidateSize();
               this.owner.invalidateList();
            }
         }
      }
      
      [Bindable("widthChanged")]
      public function get width() : Number
      {
         return this._width;
      }
      
      public function set width(param1:Number) : void
      {
         var _loc2_:Boolean = false;
         this.explicitWidth = param1;
         this.preferredWidth = param1;
         if(this.owner != null)
         {
            _loc2_ = this.resizable;
            this.resizable = false;
            this.owner.resizeColumn(this.colNum,param1);
            this.resizable = _loc2_;
         }
         else
         {
            this._width = param1;
         }
         dispatchEvent(new Event("widthChanged"));
      }
      
      mx_internal function setWidth(param1:Number) : void
      {
         var _loc2_:Number = this._width;
         this._width = param1;
         if(_loc2_ != param1)
         {
            dispatchEvent(new Event("widthChanged"));
         }
      }
      
      public function get wordWrap() : *
      {
         return this._wordWrap;
      }
      
      public function set wordWrap(param1:*) : void
      {
         this._wordWrap = param1;
         if(this.owner)
         {
            this.owner.invalidateList();
         }
      }
      
      override mx_internal function addStyleToProtoChain(param1:Object, param2:DisplayObject, param3:Object = null) : Object
      {
         var _loc6_:Object = null;
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         var _loc4_:DataGridBase = this.owner;
         var _loc5_:IListItemRenderer = IListItemRenderer(param2);
         if(_loc6_ = _loc6_)
         {
            if(_loc6_ is String)
            {
               param1 = this.addStylesToProtoChain(String(_loc6_),param1,param2);
            }
            else if(_loc6_ is CSSStyleDeclaration)
            {
               param1 = _loc6_.addStyleToProtoChain(param1,param2);
            }
         }
         param1 = super.addStyleToProtoChain(param1,param2);
         if(_loc5_.data && _loc5_.data is DataGridColumn)
         {
            if(_loc8_ = _loc4_.getStyle("headerStyleName"))
            {
               if(_loc8_ is String)
               {
                  param1 = this.addStylesToProtoChain(String(_loc8_),param1,param2);
               }
               else if(_loc8_ is CSSStyleDeclaration)
               {
                  param1 = _loc8_.addStyleToProtoChain(param1,param2);
               }
            }
            if(_loc8_ = getStyle("headerStyleName"))
            {
               if(_loc8_ is String)
               {
                  param1 = this.addStylesToProtoChain(String(_loc8_),param1,param2);
               }
               else if(_loc8_ is CSSStyleDeclaration)
               {
                  param1 = _loc8_.addStyleToProtoChain(param1,param2);
               }
            }
         }
         return param1;
      }
      
      override public function setStyle(param1:String, param2:*) : void
      {
         if(param1 == "fontFamily" || param1 == "fontWeight" || param1 == "fontStyle")
         {
            if(this.owner)
            {
               this.owner.fontContextChanged = true;
               this.owner.invalidateProperties();
            }
         }
         var _loc3_:Object = getStyle(param1);
         var _loc4_:Boolean = false;
         if(factory == null && defaultFactory == null && !overrides && _loc3_ !== param2)
         {
            _loc4_ = true;
         }
         super.setLocalStyle(param1,param2);
         if(param1 == "headerStyleName")
         {
            if(this.owner)
            {
               this.owner.regenerateStyleCache(true);
               this.owner.notifyStyleChangeInChildren("headerStyleName",true);
            }
            return;
         }
         if(this.owner)
         {
            if(_loc4_)
            {
               this.owner.regenerateStyleCache(true);
            }
            this.owner.invalidateList();
         }
      }
      
      public function itemToLabel(param1:Object) : String
      {
         var data:Object = param1;
         if(!data)
         {
            return " ";
         }
         if(this.labelFunction != null)
         {
            return this.labelFunction(data,this);
         }
         if(this.owner.labelFunction != null)
         {
            return this.owner.labelFunction(data,this);
         }
         if(typeof data == "object" || typeof data == "xml")
         {
            try
            {
               if(!this.hasComplexFieldName)
               {
                  data = data[this.dataField];
               }
               else
               {
                  data = this.deriveComplexColumnData(data);
               }
            }
            catch(e:Error)
            {
               data = null;
            }
         }
         if(data is String)
         {
            return String(data);
         }
         try
         {
            return data.toString();
         }
         catch(e:Error)
         {
            return " ";
         }
      }
      
      public function itemToDataTip(param1:Object) : String
      {
         var field:String = null;
         var data:Object = param1;
         if(this.dataTipFunction != null)
         {
            return this.dataTipFunction(data);
         }
         if(this.owner.dataTipFunction != null)
         {
            return this.owner.dataTipFunction(data);
         }
         if(typeof data == "object" || typeof data == "xml")
         {
            field = this.dataTipField;
            if(!field)
            {
               field = this.owner.dataTipField;
            }
            try
            {
               if(data[field] != null)
               {
                  data = data[field];
               }
               else if(data[this.dataField] != null)
               {
                  data = data[this.dataField];
               }
            }
            catch(e:Error)
            {
               data = null;
            }
         }
         if(data is String)
         {
            return String(data);
         }
         try
         {
            return data.toString();
         }
         catch(e:Error)
         {
            return " ";
         }
      }
      
      protected function deriveComplexColumnData(param1:Object) : Object
      {
         var _loc3_:int = 0;
         var _loc2_:Object = param1;
         if(this.complexFieldNameComponents)
         {
            _loc3_ = 0;
            while(_loc3_ < this.complexFieldNameComponents.length)
            {
               _loc2_ = _loc2_[this.complexFieldNameComponents[_loc3_]];
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      protected function complexColumnSortCompare(param1:Object, param2:Object) : int
      {
         if(!param1 && !param2)
         {
            return 0;
         }
         if(!param1)
         {
            return 1;
         }
         if(!param2)
         {
            return -1;
         }
         var _loc3_:String = this.deriveComplexColumnData(param1).toString();
         var _loc4_:String = this.deriveComplexColumnData(param2).toString();
         if(_loc3_ < _loc4_)
         {
            return -1;
         }
         if(_loc3_ > _loc4_)
         {
            return 1;
         }
         return 0;
      }
      
      public function getItemRendererFactory(param1:Boolean, param2:Object) : IFactory
      {
         if(param1)
         {
            if(!this._contextHeaderRenderer)
            {
               this._contextHeaderRenderer = this.replaceItemRendererFactory(this.headerRenderer,true);
            }
            return this._contextHeaderRenderer;
         }
         if(!param2)
         {
            if(!this._contextNullItemRenderer)
            {
               this._contextNullItemRenderer = this.replaceItemRendererFactory(this.nullItemRenderer);
            }
            return this._contextNullItemRenderer;
         }
         if(!this._contextItemRenderer)
         {
            this._contextItemRenderer = this.replaceItemRendererFactory(this.itemRenderer);
         }
         return this._contextItemRenderer;
      }
      
      private function replaceItemRendererFactory(param1:IFactory, param2:Boolean = false) : IFactory
      {
         var _loc3_:ContextualClassFactory = null;
         if(this.oldEmbeddedFontContext == null)
         {
            return param1;
         }
         if(param1 == null && this.owner != null)
         {
            param1 = this.owner.itemRenderer;
         }
         if(param1 is ClassFactory)
         {
            _loc3_ = new ContextualClassFactory(ClassFactory(param1).generator,!!param2 ? this.oldHeaderEmbeddedFontContext : this.oldEmbeddedFontContext);
            _loc3_.properties = ClassFactory(param1).properties;
            return _loc3_;
         }
         return param1;
      }
      
      mx_internal function getMeasuringRenderer(param1:Boolean, param2:Object) : IListItemRenderer
      {
         var _loc3_:IFactory = this.getItemRendererFactory(param1,param2);
         if(!_loc3_)
         {
            _loc3_ = this.owner.itemRenderer;
         }
         if(!this.measuringObjects)
         {
            this.measuringObjects = new Dictionary(false);
         }
         var _loc4_:IListItemRenderer;
         if(!(_loc4_ = this.measuringObjects[_loc3_]))
         {
            (_loc4_ = _loc3_.newInstance()).visible = false;
            _loc4_.styleName = this;
            this.measuringObjects[_loc3_] = _loc4_;
         }
         return _loc4_;
      }
      
      mx_internal function resetFactories() : void
      {
         this._contextHeaderRenderer = null;
         this._contextItemRenderer = null;
         this._contextNullItemRenderer = null;
         this.determineFontContext();
      }
      
      mx_internal function determineFontContext() : void
      {
         var _loc1_:IFlexModuleFactory = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc2_:String = StringUtil.trimArrayElements(getStyle("fontFamily"),",");
         var _loc3_:String = getStyle("fontWeight");
         var _loc4_:String = getStyle("fontStyle");
         if(_loc2_ == null)
         {
            _loc2_ = StringUtil.trimArrayElements(this.owner.getStyle("fontFamily"),",");
         }
         if(_loc3_ == null)
         {
            _loc3_ = this.owner.getStyle("fontWeight");
         }
         if(_loc4_ == null)
         {
            _loc4_ = this.owner.getStyle("fontStyle");
         }
         var _loc5_:* = _loc3_ == "bold";
         var _loc6_:* = _loc4_ == "italic";
         _loc1_ = noEmbeddedFonts || !embeddedFontRegistry ? null : embeddedFontRegistry.getAssociatedModuleFactory(_loc2_,_loc5_,_loc6_,this,this.owner.moduleFactory,this.owner.systemManager);
         if(_loc1_ != this.oldEmbeddedFontContext)
         {
            this.oldEmbeddedFontContext = _loc1_;
            this.owner.invalidateList();
            this.owner.columnRendererChanged(this);
            this._contextItemRenderer = null;
            this._contextNullItemRenderer = null;
         }
         var _loc7_:Object;
         if(_loc7_ = this.owner.getStyle("headerStyleName"))
         {
            if(_loc7_ is String)
            {
               _loc7_ = this.owner.styleManager.getMergedStyleDeclaration(String(_loc7_));
            }
         }
         if(_loc7_)
         {
            if(_loc8_ = StringUtil.trimArrayElements(_loc7_.getStyle("fontFamily"),","))
            {
               _loc2_ = _loc8_;
            }
            if(_loc9_ = _loc7_.getStyle("fontWeight"))
            {
               _loc3_ = _loc9_;
            }
            if(_loc10_ = _loc7_.getStyle("fontStyle"))
            {
               _loc4_ = _loc10_;
            }
            _loc5_ = _loc3_ == "bold";
            _loc6_ = _loc4_ == "italic";
         }
         if(_loc7_ = getStyle("headerStyleName"))
         {
            if(_loc7_ is String)
            {
               _loc7_ = this.owner.styleManager.getMergedStyleDeclaration(String(_loc7_));
            }
         }
         if(_loc7_)
         {
            if(_loc8_ = StringUtil.trimArrayElements(_loc7_.getStyle("fontFamily"),","))
            {
               _loc2_ = _loc8_;
            }
            if(_loc9_ = _loc7_.getStyle("fontWeight"))
            {
               _loc3_ = _loc9_;
            }
            if(_loc10_ = _loc7_.getStyle("fontStyle"))
            {
               _loc4_ = _loc10_;
            }
            _loc5_ = _loc3_ == "bold";
            _loc6_ = _loc4_ == "italic";
         }
         _loc1_ = noEmbeddedFonts || !embeddedFontRegistry ? null : embeddedFontRegistry.getAssociatedModuleFactory(_loc2_,_loc5_,_loc6_,this,this.owner.moduleFactory,this.owner.systemManager);
         if(_loc1_ != this.oldHeaderEmbeddedFontContext)
         {
            this.oldHeaderEmbeddedFontContext = _loc1_;
            this.cachedHeaderRenderer = null;
            this.owner.dataGridHeader.headerItemsChanged = true;
            this._contextHeaderRenderer = null;
         }
      }
      
      private function addStylesToProtoChain(param1:String, param2:Object, param3:DisplayObject) : Object
      {
         var _loc6_:CSSStyleDeclaration = null;
         var _loc4_:Array = param1.split(/\s+/);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            if(_loc4_[_loc5_].length)
            {
               if(_loc6_ = this.owner.styleManager.getMergedStyleDeclaration("." + _loc4_[_loc5_]))
               {
                  param2 = _loc6_.addStyleToProtoChain(param2,param3);
               }
            }
            _loc5_++;
         }
         return param2;
      }
   }
}
