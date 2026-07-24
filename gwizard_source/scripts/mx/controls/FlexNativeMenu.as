package mx.controls
{
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.NativeMenu;
   import flash.display.NativeMenuItem;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.ui.Keyboard;
   import flash.utils.Timer;
   import flash.xml.XMLNode;
   import mx.automation.IAutomationObject;
   import mx.collections.ArrayCollection;
   import mx.collections.ICollectionView;
   import mx.collections.XMLListCollection;
   import mx.collections.errors.ItemPendingError;
   import mx.controls.menuClasses.IMenuDataDescriptor;
   import mx.controls.treeClasses.DefaultDataDescriptor;
   import mx.core.Application;
   import mx.core.EventPriority;
   import mx.core.UIComponentGlobals;
   import mx.core.mx_internal;
   import mx.events.CollectionEvent;
   import mx.events.CollectionEventKind;
   import mx.events.FlexNativeMenuEvent;
   import mx.managers.ILayoutManagerClient;
   import mx.managers.ISystemManager;
   
   use namespace mx_internal;
   
   public class FlexNativeMenu extends EventDispatcher implements ILayoutManagerClient, IFlexContextMenu, IAutomationObject
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static var MNEMONIC_INDEX_CHARACTER:String = "_";
       
      
      private var _automationDelegate:IAutomationObject;
      
      private var _automationName:String = null;
      
      private var _automationOwner:DisplayObjectContainer;
      
      private var _automationParent:DisplayObjectContainer;
      
      private var _showInAutomationHierarchy:Boolean = true;
      
      private var _initialized:Boolean = false;
      
      private var _nestLevel:int = 1;
      
      private var _processedDescriptors:Boolean = false;
      
      private var _updateCompletePendingFlag:Boolean = false;
      
      private var invalidatePropertiesFlag:Boolean = false;
      
      private var _nativeMenu:NativeMenu;
      
      private var dataDescriptorChanged:Boolean = false;
      
      private var _dataDescriptor:IMenuDataDescriptor;
      
      private var dataProviderChanged:Boolean = false;
      
      mx_internal var _rootModel:ICollectionView;
      
      private var _hasRoot:Boolean = false;
      
      private var keyEquivalentFieldChanged:Boolean = false;
      
      private var _keyEquivalentField:String = "keyEquivalent";
      
      private var _keyEquivalentFunction:Function;
      
      private var keyEquivalentModifiersFunctionChanged:Boolean = false;
      
      private var _keyEquivalentModifiersFunction:Function;
      
      private var labelFieldChanged:Boolean = false;
      
      private var _labelField:String = "label";
      
      private var _labelFunction:Function;
      
      private var mnemonicIndexFieldChanged:Boolean = false;
      
      private var _mnemonicIndexField:String = "mnemonicIndex";
      
      private var _mnemonicIndexFunction:Function;
      
      private var _showRoot:Boolean = true;
      
      private var showRootChanged:Boolean = false;
      
      public function FlexNativeMenu()
      {
         this._nativeMenu = new NativeMenu();
         this._dataDescriptor = new DefaultDataDescriptor();
         this._keyEquivalentModifiersFunction = this.keyEquivalentModifiersDefaultFunction;
         super();
         this._nativeMenu.addEventListener(Event.DISPLAYING,this.menuDisplayHandler,false,0,true);
      }
      
      public function get automationDelegate() : Object
      {
         return this._automationDelegate;
      }
      
      public function set automationDelegate(param1:Object) : void
      {
         this._automationDelegate = param1 as IAutomationObject;
      }
      
      public function get automationName() : String
      {
         if(this._automationName)
         {
            return this._automationName;
         }
         if(this.automationDelegate)
         {
            return this.automationDelegate.automationName;
         }
         return "";
      }
      
      public function set automationName(param1:String) : void
      {
         this._automationName = param1;
      }
      
      public function get automationValue() : Array
      {
         if(this.automationDelegate)
         {
            return this.automationDelegate.automationValue;
         }
         return [];
      }
      
      public function get numAutomationChildren() : int
      {
         if(this.automationDelegate)
         {
            return this.automationDelegate.numAutomationChildren;
         }
         return 0;
      }
      
      public function get automationTabularData() : Object
      {
         if(this.automationDelegate)
         {
            return this.automationDelegate.automationTabularData;
         }
         return null;
      }
      
      public function get automationOwner() : DisplayObjectContainer
      {
         return !!this._automationOwner ? this._automationOwner : this.automationParent;
      }
      
      public function set automationOwner(param1:DisplayObjectContainer) : void
      {
         this._automationOwner = param1;
      }
      
      public function get automationParent() : DisplayObjectContainer
      {
         return this._automationParent;
      }
      
      public function set automationParent(param1:DisplayObjectContainer) : void
      {
         this._automationParent = param1;
      }
      
      public function get automationEnabled() : Boolean
      {
         return true;
      }
      
      public function get automationVisible() : Boolean
      {
         return true;
      }
      
      public function get showInAutomationHierarchy() : Boolean
      {
         return this._showInAutomationHierarchy;
      }
      
      public function set showInAutomationHierarchy(param1:Boolean) : void
      {
         this._showInAutomationHierarchy = param1;
      }
      
      public function get initialized() : Boolean
      {
         return this._initialized;
      }
      
      public function set initialized(param1:Boolean) : void
      {
         this._initialized = param1;
      }
      
      public function get nestLevel() : int
      {
         return this._nestLevel;
      }
      
      public function set nestLevel(param1:int) : void
      {
         this._nestLevel = param1;
         this.invalidateProperties();
      }
      
      public function get processedDescriptors() : Boolean
      {
         return this._processedDescriptors;
      }
      
      public function set processedDescriptors(param1:Boolean) : void
      {
         this._processedDescriptors = param1;
      }
      
      public function get updateCompletePendingFlag() : Boolean
      {
         return this._updateCompletePendingFlag;
      }
      
      public function set updateCompletePendingFlag(param1:Boolean) : void
      {
         this._updateCompletePendingFlag = param1;
      }
      
      [Bindable("nativeMenuUpdate")]
      public function get nativeMenu() : NativeMenu
      {
         return this._nativeMenu;
      }
      
      public function get dataDescriptor() : IMenuDataDescriptor
      {
         return IMenuDataDescriptor(this._dataDescriptor);
      }
      
      public function set dataDescriptor(param1:IMenuDataDescriptor) : void
      {
         this._dataDescriptor = param1;
         this.dataDescriptorChanged = true;
      }
      
      [Bindable("collectionChange")]
      public function get dataProvider() : Object
      {
         if(this._rootModel)
         {
            return this._rootModel;
         }
         return null;
      }
      
      public function set dataProvider(param1:Object) : void
      {
         var _loc3_:XMLList = null;
         var _loc4_:Array = null;
         if(this._rootModel)
         {
            this._rootModel.removeEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler);
         }
         if(typeof param1 == "string")
         {
            param1 = new XML(param1);
         }
         else if(param1 is XMLNode)
         {
            param1 = new XML(XMLNode(param1).toString());
         }
         else if(param1 is XMLList)
         {
            param1 = new XMLListCollection(param1 as XMLList);
         }
         if(param1 is XML)
         {
            this._hasRoot = true;
            _loc3_ = new XMLList();
            _loc3_ += param1;
            this._rootModel = new XMLListCollection(_loc3_);
         }
         else if(param1 is ICollectionView)
         {
            this._rootModel = ICollectionView(param1);
            if(this._rootModel.length == 1)
            {
               this._hasRoot = true;
            }
         }
         else if(param1 is Array)
         {
            this._rootModel = new ArrayCollection(param1 as Array);
         }
         else if(param1 is Object)
         {
            this._hasRoot = true;
            (_loc4_ = []).push(param1);
            this._rootModel = new ArrayCollection(_loc4_);
         }
         else
         {
            this._rootModel = new ArrayCollection();
         }
         this._rootModel.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler,false,0,true);
         this.dataProviderChanged = true;
         this.invalidateProperties();
         var _loc2_:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
         _loc2_.kind = CollectionEventKind.RESET;
         this.collectionChangeHandler(_loc2_);
         dispatchEvent(_loc2_);
      }
      
      public function get hasRoot() : Boolean
      {
         return this._hasRoot;
      }
      
      [Bindable("keyEquivalentChanged")]
      public function get keyEquivalentField() : String
      {
         return this._keyEquivalentField;
      }
      
      public function set keyEquivalentField(param1:String) : void
      {
         if(this._keyEquivalentField != param1)
         {
            this._keyEquivalentField = param1;
            this.keyEquivalentFieldChanged = true;
            this.invalidateProperties();
            dispatchEvent(new Event("keyEquivalentFieldChanged"));
         }
      }
      
      [Bindable("keyEquivalentFunctionChanged")]
      public function get keyEquivalentFunction() : Function
      {
         return this._keyEquivalentFunction;
      }
      
      public function set keyEquivalentFunction(param1:Function) : void
      {
         if(this._keyEquivalentFunction != param1)
         {
            this._keyEquivalentFunction = param1;
            this.keyEquivalentFieldChanged = true;
            this.invalidateProperties();
            dispatchEvent(new Event("keyEquivalentFunctionChanged"));
         }
      }
      
      private function keyEquivalentModifiersDefaultFunction(param1:Object) : Array
      {
         var _loc6_:int = 0;
         var _loc7_:* = undefined;
         var _loc2_:Array = [];
         var _loc3_:Array = ["@altKey","@cmdKey","@ctrlKey","@shiftKey","@commandKey","@controlKey"];
         var _loc4_:Array = ["altKey","cmdKey","ctrlKey","shiftKey","commandKey","controlKey"];
         var _loc5_:Array = [Keyboard.ALTERNATE,Keyboard.COMMAND,Keyboard.CONTROL,Keyboard.SHIFT,Keyboard.COMMAND,Keyboard.CONTROL];
         if(param1 is XML)
         {
            _loc6_ = 0;
            for(; _loc6_ < _loc3_.length; _loc6_++)
            {
               try
               {
                  if((_loc7_ = param1[_loc3_[_loc6_]])[0] == true)
                  {
                     _loc2_.push(_loc5_[_loc6_]);
                  }
               }
               catch(e:Error)
               {
                  continue;
               }
            }
         }
         else if(param1 is Object)
         {
            _loc6_ = 0;
            for(; _loc6_ < _loc4_.length; _loc6_++)
            {
               try
               {
                  _loc7_ = param1[_loc4_[_loc6_]];
                  if(String(_loc7_).toLowerCase() == "true")
                  {
                     _loc2_.push(_loc5_[_loc6_]);
                  }
               }
               catch(e:Error)
               {
                  continue;
               }
            }
         }
         return _loc2_;
      }
      
      [Bindable("keyEquivalentModifiersFunctionChanged")]
      public function get keyEquivalentModifiersFunction() : Function
      {
         return this._keyEquivalentModifiersFunction;
      }
      
      public function set keyEquivalentModifiersFunction(param1:Function) : void
      {
         if(this._keyEquivalentModifiersFunction != param1)
         {
            this._keyEquivalentModifiersFunction = param1;
            this.keyEquivalentModifiersFunctionChanged = true;
            this.invalidateProperties();
            dispatchEvent(new Event("keyEquivalentModifiersFunctionChanged"));
         }
      }
      
      [Bindable("labelFieldChanged")]
      public function get labelField() : String
      {
         return this._labelField;
      }
      
      public function set labelField(param1:String) : void
      {
         if(this._labelField != param1)
         {
            this._labelField = param1;
            this.labelFieldChanged = true;
            this.invalidateProperties();
            dispatchEvent(new Event("labelFieldChanged"));
         }
      }
      
      [Bindable("labelFunctionChanged")]
      public function get labelFunction() : Function
      {
         return this._labelFunction;
      }
      
      public function set labelFunction(param1:Function) : void
      {
         if(this._labelFunction != param1)
         {
            this._labelFunction = param1;
            this.labelFieldChanged = true;
            this.invalidateProperties();
            dispatchEvent(new Event("labelFunctionChanged"));
         }
      }
      
      [Bindable("mnemonicIndexChanged")]
      public function get mnemonicIndexField() : String
      {
         return this._mnemonicIndexField;
      }
      
      public function set mnemonicIndexField(param1:String) : void
      {
         if(this._mnemonicIndexField != param1)
         {
            this._mnemonicIndexField = param1;
            this.mnemonicIndexFieldChanged = true;
            this.invalidateProperties();
            dispatchEvent(new Event("mnemonicIndexFieldChanged"));
         }
      }
      
      [Bindable("mnemonicIndexFunctionChanged")]
      public function get mnemonicIndexFunction() : Function
      {
         return this._mnemonicIndexFunction;
      }
      
      public function set mnemonicIndexFunction(param1:Function) : void
      {
         if(this._mnemonicIndexFunction != param1)
         {
            this._mnemonicIndexFunction = param1;
            this.mnemonicIndexFieldChanged = true;
            this.invalidateProperties();
            dispatchEvent(new Event("mnemonicIndexFunctionChanged"));
         }
      }
      
      public function get showRoot() : Boolean
      {
         return this._showRoot;
      }
      
      public function set showRoot(param1:Boolean) : void
      {
         if(this._showRoot != param1)
         {
            this.showRootChanged = true;
            this._showRoot = param1;
            this.invalidateProperties();
         }
      }
      
      public function invalidateProperties() : void
      {
         var _loc1_:Timer = null;
         if(!this.invalidatePropertiesFlag && this.nestLevel > 0)
         {
            this.invalidatePropertiesFlag = true;
            if(UIComponentGlobals.layoutManager)
            {
               UIComponentGlobals.layoutManager.invalidateProperties(this);
            }
            else
            {
               _loc1_ = new Timer(100,1);
               _loc1_.addEventListener(TimerEvent.TIMER,this.validatePropertiesTimerHandler);
               _loc1_.start();
            }
         }
      }
      
      public function validatePropertiesTimerHandler(param1:TimerEvent) : void
      {
         this.validateProperties();
      }
      
      public function validateProperties() : void
      {
         if(this.invalidatePropertiesFlag)
         {
            this.commitProperties();
            this.invalidatePropertiesFlag = false;
         }
      }
      
      public function validateSize(param1:Boolean = false) : void
      {
      }
      
      public function validateDisplayList() : void
      {
      }
      
      public function validateNow() : void
      {
         if(this.invalidatePropertiesFlag)
         {
            this.validateProperties();
         }
      }
      
      public function setContextMenu(param1:InteractiveObject) : void
      {
         var _loc2_:ISystemManager = null;
         param1.contextMenu = this.nativeMenu;
         if(param1 is Application)
         {
            _loc2_ = Application(param1).systemManager;
            if(_loc2_ is InteractiveObject)
            {
               InteractiveObject(_loc2_).contextMenu = this.nativeMenu;
            }
         }
         this.automationParent = param1 as DisplayObjectContainer;
         this.automationOwner = param1 as DisplayObjectContainer;
         param1.dispatchEvent(new Event("flexContextMenuChanged"));
      }
      
      public function unsetContextMenu(param1:InteractiveObject) : void
      {
         param1.contextMenu = null;
         this.automationParent = null;
         this.automationOwner = null;
         param1.dispatchEvent(new Event("flexContextMenuChanged"));
      }
      
      protected function commitProperties() : void
      {
         var _loc1_:ICollectionView = null;
         var _loc2_:* = undefined;
         if(this.showRootChanged)
         {
            if(!this._hasRoot)
            {
               this.showRootChanged = false;
            }
         }
         if(this.dataProviderChanged || this.showRootChanged || this.labelFieldChanged || this.dataDescriptorChanged)
         {
            this.dataProviderChanged = false;
            this.showRootChanged = false;
            this.labelFieldChanged = false;
            this.dataDescriptorChanged = false;
            if(this._rootModel && !this._showRoot && this._hasRoot)
            {
               _loc2_ = this._rootModel.createCursor().current;
               if(_loc2_ != null && this._dataDescriptor.isBranch(_loc2_,this._rootModel) && this._dataDescriptor.hasChildren(_loc2_,this._rootModel))
               {
                  _loc1_ = this._dataDescriptor.getChildren(_loc2_,this._rootModel);
               }
            }
            this.clearMenu(this._nativeMenu);
            if(this._rootModel)
            {
               if(!_loc1_)
               {
                  _loc1_ = this._rootModel;
               }
               _loc1_.addEventListener(CollectionEvent.COLLECTION_CHANGE,this.collectionChangeHandler,false,EventPriority.DEFAULT_HANDLER,true);
               this.populateMenu(this._nativeMenu,_loc1_);
            }
            dispatchEvent(new Event("nativeMenuChange"));
         }
      }
      
      private function createMenu() : NativeMenu
      {
         var _loc1_:NativeMenu = new NativeMenu();
         _loc1_.addEventListener(Event.DISPLAYING,this.menuDisplayHandler,false,0,true);
         return _loc1_;
      }
      
      private function clearMenu(param1:NativeMenu) : void
      {
         var _loc2_:int = param1.numItems;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            param1.removeItemAt(0);
            _loc3_++;
         }
      }
      
      private function populateMenu(param1:NativeMenu, param2:ICollectionView) : NativeMenu
      {
         var _loc3_:int = param2.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            try
            {
               this.insertMenuItem(param1,_loc4_,param2[_loc4_]);
            }
            catch(e:ItemPendingError)
            {
            }
            _loc4_++;
         }
         return param1;
      }
      
      private function insertMenuItem(param1:NativeMenu, param2:int, param3:Object) : void
      {
         var _loc7_:String = null;
         var _loc8_:int = 0;
         if(this.dataProviderChanged)
         {
            this.commitProperties();
            return;
         }
         var _loc4_:String;
         var _loc5_:* = (_loc4_ = this.dataDescriptor.getType(param3).toLowerCase()) == "separator";
         var _loc6_:NativeMenuItem = new NativeMenuItem("",_loc5_);
         if(!_loc5_)
         {
            _loc6_.enabled = this.dataDescriptor.isEnabled(param3);
            _loc6_.checked = _loc4_ == "check" && this.dataDescriptor.isToggled(param3);
            _loc6_.data = this.dataDescriptor.getData(param3,this._rootModel);
            _loc6_.keyEquivalent = this.itemToKeyEquivalent(param3);
            _loc6_.keyEquivalentModifiers = this.itemToKeyEquivalentModifiers(param3);
            _loc7_ = this.itemToLabel(param3);
            if((_loc8_ = this.itemToMnemonicIndex(param3)) >= 0)
            {
               _loc6_.label = this.parseLabelToString(_loc7_);
               _loc6_.mnemonicIndex = _loc8_;
            }
            else
            {
               _loc6_.label = this.parseLabelToString(_loc7_);
               _loc6_.mnemonicIndex = this.parseLabelToMnemonicIndex(_loc7_);
            }
            _loc6_.addEventListener(Event.SELECT,this.itemSelectHandler,false,0,true);
            if(this.dataDescriptor.isBranch(param3,this._rootModel) && this.dataDescriptor.hasChildren(param3,this._rootModel))
            {
               _loc6_.submenu = this.createMenu();
               this.populateMenu(_loc6_.submenu,this.dataDescriptor.getChildren(param3,this._rootModel));
            }
         }
         param1.addItem(_loc6_);
      }
      
      public function display(param1:Stage, param2:int, param3:int) : void
      {
         this.nativeMenu.display(param1,param2,param3);
      }
      
      protected function itemToKeyEquivalent(param1:Object) : String
      {
         if(param1 == null)
         {
            return "";
         }
         if(this.keyEquivalentFunction != null)
         {
            return this.keyEquivalentFunction(param1);
         }
         if(param1 is XML)
         {
            try
            {
               if(param1[this.keyEquivalentField].length() != 0)
               {
                  param1 = param1[this.keyEquivalentField];
                  return param1.toString();
               }
            }
            catch(e:Error)
            {
            }
         }
         else if(param1 is Object)
         {
            try
            {
               if(param1[this.keyEquivalentField] != null)
               {
                  param1 = param1[this.keyEquivalentField];
                  return param1.toString();
               }
            }
            catch(e:Error)
            {
            }
         }
         return "";
      }
      
      protected function itemToKeyEquivalentModifiers(param1:Object) : Array
      {
         if(param1 == null)
         {
            return [];
         }
         if(this.keyEquivalentModifiersFunction != null)
         {
            return this.keyEquivalentModifiersFunction(param1);
         }
         return [];
      }
      
      protected function itemToLabel(param1:Object) : String
      {
         if(param1 == null)
         {
            return " ";
         }
         if(this.labelFunction != null)
         {
            return this.labelFunction(param1);
         }
         if(param1 is XML)
         {
            try
            {
               if(param1[this.labelField].length() != 0)
               {
                  param1 = param1[this.labelField];
               }
            }
            catch(e:Error)
            {
            }
         }
         else if(param1 is Object)
         {
            try
            {
               if(param1[this.labelField] != null)
               {
                  param1 = param1[this.labelField];
               }
            }
            catch(e:Error)
            {
            }
         }
         else if(param1 is String)
         {
            return String(param1);
         }
         try
         {
            return param1.toString();
         }
         catch(e:Error)
         {
            return " ";
         }
      }
      
      protected function itemToMnemonicIndex(param1:Object) : int
      {
         var _loc2_:int = 0;
         if(param1 == null)
         {
            return -1;
         }
         if(this.mnemonicIndexFunction != null)
         {
            return this.mnemonicIndexFunction(param1);
         }
         if(param1 is XML)
         {
            try
            {
               if(param1[this.mnemonicIndexField].length() != 0)
               {
                  return int(param1[this.mnemonicIndexField]);
               }
            }
            catch(e:Error)
            {
            }
         }
         else if(param1 is Object)
         {
            try
            {
               if(param1[this.mnemonicIndexField] != null)
               {
                  return int(param1[this.mnemonicIndexField]);
               }
            }
            catch(e:Error)
            {
            }
         }
         return -1;
      }
      
      protected function parseLabelToString(param1:String) : String
      {
         var _loc7_:String = null;
         var _loc2_:RegExp = new RegExp(MNEMONIC_INDEX_CHARACTER,"g");
         var _loc3_:RegExp = new RegExp(MNEMONIC_INDEX_CHARACTER + MNEMONIC_INDEX_CHARACTER,"g");
         var _loc4_:Array;
         var _loc5_:int = (_loc4_ = param1.split(_loc3_)).length;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc7_ = String(_loc4_[_loc6_]);
            _loc4_[_loc6_] = _loc7_.replace(_loc2_,"");
            _loc6_++;
         }
         return _loc4_.join(MNEMONIC_INDEX_CHARACTER);
      }
      
      protected function parseLabelToMnemonicIndex(param1:String) : int
      {
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc2_:RegExp = new RegExp(MNEMONIC_INDEX_CHARACTER + MNEMONIC_INDEX_CHARACTER,"g");
         var _loc3_:Array = param1.split(_loc2_);
         var _loc4_:int = _loc3_.length;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_)
         {
            if((_loc8_ = (_loc7_ = String(_loc3_[_loc6_])).indexOf(MNEMONIC_INDEX_CHARACTER)) >= 0)
            {
               return _loc8_ + _loc5_;
            }
            _loc5_ += _loc7_.length + MNEMONIC_INDEX_CHARACTER.length;
            _loc6_++;
         }
         return -1;
      }
      
      public function createAutomationIDPart(param1:IAutomationObject) : Object
      {
         if(this.automationDelegate)
         {
            return this.automationDelegate.createAutomationIDPart(param1);
         }
         return null;
      }
      
      public function createAutomationIDPartWithRequiredProperties(param1:IAutomationObject, param2:Array) : Object
      {
         if(this.automationDelegate)
         {
            return this.automationDelegate.createAutomationIDPartWithRequiredProperties(param1,param2);
         }
         return null;
      }
      
      public function resolveAutomationIDPart(param1:Object) : Array
      {
         if(this.automationDelegate)
         {
            return this.automationDelegate.resolveAutomationIDPart(param1);
         }
         return [];
      }
      
      public function getAutomationChildAt(param1:int) : IAutomationObject
      {
         if(this.automationDelegate)
         {
            return this.automationDelegate.getAutomationChildAt(param1);
         }
         return null;
      }
      
      public function getAutomationChildren() : Array
      {
         if(this.automationDelegate)
         {
            return this.automationDelegate.getAutomationChildren();
         }
         return null;
      }
      
      public function replayAutomatableEvent(param1:Event) : Boolean
      {
         if(this.automationDelegate)
         {
            return this.automationDelegate.replayAutomatableEvent(param1);
         }
         return false;
      }
      
      private function itemSelectHandler(param1:Event) : void
      {
         var _loc5_:* = false;
         var _loc2_:NativeMenuItem = param1.target as NativeMenuItem;
         var _loc3_:String = this.dataDescriptor.getType(_loc2_.data).toLowerCase();
         if(_loc3_ == "check")
         {
            _loc5_ = !this.dataDescriptor.isToggled(_loc2_.data);
            _loc2_.checked = _loc5_;
            this.dataDescriptor.setToggled(_loc2_.data,_loc5_);
         }
         var _loc4_:FlexNativeMenuEvent;
         (_loc4_ = new FlexNativeMenuEvent(FlexNativeMenuEvent.ITEM_CLICK)).nativeMenu = _loc2_.menu;
         _loc4_.index = _loc2_.menu.getItemIndex(_loc2_);
         _loc4_.nativeMenuItem = _loc2_;
         _loc4_.label = _loc2_.label;
         _loc4_.item = _loc2_.data;
         dispatchEvent(_loc4_);
      }
      
      private function menuDisplayHandler(param1:Event) : void
      {
         var _loc2_:NativeMenu = param1.target as NativeMenu;
         var _loc3_:FlexNativeMenuEvent = new FlexNativeMenuEvent(FlexNativeMenuEvent.MENU_SHOW);
         _loc3_.nativeMenu = _loc2_;
         dispatchEvent(_loc3_);
      }
      
      private function collectionChangeHandler(param1:CollectionEvent) : void
      {
         if(param1.kind == CollectionEventKind.ADD)
         {
            this.dataProviderChanged = true;
            this.invalidateProperties();
         }
         else if(param1.kind == CollectionEventKind.REMOVE)
         {
            this.dataProviderChanged = true;
            this.invalidateProperties();
         }
         else if(param1.kind == CollectionEventKind.REFRESH)
         {
            this.dataProviderChanged = true;
            this.dataProvider = this.dataProvider;
            this.invalidateProperties();
         }
         else if(param1.kind == CollectionEventKind.RESET)
         {
            this.dataProviderChanged = true;
            this.invalidateProperties();
         }
         else if(param1.kind == CollectionEventKind.UPDATE)
         {
            this.dataProviderChanged = true;
            this.invalidateProperties();
         }
      }
   }
}
