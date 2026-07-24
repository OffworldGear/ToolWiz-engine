package comps
{
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import machines.GWizMachSettings;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.collections.Sort;
   import mx.collections.SortField;
   import mx.controls.Spacer;
   import mx.core.ClassFactory;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import post.GWizGCParseData;
   import spark.components.Button;
   import spark.components.ButtonBar;
   import spark.components.DataGrid;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.components.TextArea;
   import spark.components.VGroup;
   import spark.components.gridClasses.GridColumn;
   import spark.events.GridItemEditorEvent;
   import spark.events.GridSelectionEvent;
   import spark.events.IndexChangeEvent;
   import utils.ColorPalette;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizGMCodePanel extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizGMCodePanel");
      
      private static var _85315304YesNo:ArrayCollection = new ArrayCollection([{
         "label":"Yes",
         "enabled":"Yes"
      },{
         "label":"No",
         "enabled":""
      },{
         "label":"Ignore",
         "enabled":"Ignore"
      }]);
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _515570190AddCode:Button;
      
      private var _1080868744DelCode:Button;
      
      private var _1372287197EnableCol:GridColumn;
      
      private var _121092109MachType:GridColumn;
      
      private var _871474644ParmCol:GridColumn;
      
      private var _291035191ResetCodes:Button;
      
      public var _GWizGMCodePanel_ButtonBar1:ButtonBar;
      
      public var _GWizGMCodePanel_HGroup1:HGroup;
      
      public var _GWizGMCodePanel_Label2:Label;
      
      private var _867962169codeType:RadioButtonGroup;
      
      private var _1280882689gCodes:RadioButton;
      
      private var _3322014list:DataGrid;
      
      private var _1109107783mCodes:RadioButton;
      
      private var _1797933806notesArea:TextArea;
      
      private var _1168407226selLabel:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1063571914textColor:uint;
      
      private var _1274952974rollOverColor:uint;
      
      private var _189450183selectColor:uint;
      
      public var callerInsert:Function = null;
      
      public var callerCancel:Function = null;
      
      public var pruneEnabledNo:Boolean = false;
      
      private const GCODE_ALL:String = "All";
      
      private const GCODE_MOTION:String = "Motion";
      
      private const GCODE_COORDINATE:String = "CoorDinate";
      
      private const GCODE_CANNED:String = "Canned";
      
      private const GCODE_COMPENSATION:String = "ComPensation";
      
      private const GCODE_OTHER:String = "Other";
      
      private const gcodeTypes:ArrayCollection = new ArrayCollection([this.GCODE_ALL,this.GCODE_MOTION,this.GCODE_COORDINATE,this.GCODE_CANNED,this.GCODE_COMPENSATION,this.GCODE_OTHER]);
      
      public var codeGroup:String = "M";
      
      private var dSource:ArrayCollection = null;
      
      private var _848253512prunedList:ArrayCollection;
      
      private var minLabLen:int = 0;
      
      private var selLabelTxt:String = "";
      
      private var selectedType:String = "";
      
      private var customNewCode:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizGMCodePanel()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._1063571914textColor = ColorPalette.alternateb5;
         this._1274952974rollOverColor = ColorPalette.alternateb5;
         this._189450183selectColor = ColorPalette.alternateb4;
         this._848253512prunedList = new ArrayCollection();
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizGMCodePanel_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizGMCodePanelWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizGMCodePanel[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.mxmlContent = [this._GWizGMCodePanel_HGroup1_i(),this._GWizGMCodePanel_ButtonBar1_i(),this._GWizGMCodePanel_HGroup2_c(),this._GWizGMCodePanel_DataGrid1_i(),this._GWizGMCodePanel_Label2_i(),this._GWizGMCodePanel_TextArea1_i(),this._GWizGMCodePanel_Spacer2_c()];
         this._GWizGMCodePanel_RadioButtonGroup1_i();
         this.addEventListener("creationComplete",this.___GWizGMCodePanel_VGroup1_creationComplete);
         this.addEventListener("initialize",this.___GWizGMCodePanel_VGroup1_initialize);
         this.addEventListener("show",this.___GWizGMCodePanel_VGroup1_show);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizGMCodePanel._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get YesNo() : ArrayCollection
      {
         return GWizGMCodePanel._85315304YesNo;
      }
      
      public static function set YesNo(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizGMCodePanel._85315304YesNo;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizGMCodePanel,"YesNo",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
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
      
      public function doInsert() : void
      {
         var _loc1_:Object = this.list.selectedItem;
         if(this.callerInsert != null)
         {
            this.callerInsert(this.list.selectedItem);
         }
      }
      
      public function changeGroup(param1:String = "M") : void
      {
         var _loc5_:Object = null;
         if(!GWizGCParseData.GCodes || !GWizGCParseData.MCodes)
         {
            return;
         }
         if(this.codeGroup == "G")
         {
            this.selectedType = "";
         }
         this.codeGroup = param1;
         switch(this.codeGroup)
         {
            case "G":
               this.dSource = GWizGCParseData.GCodes;
               this.gCodes.selected = true;
               break;
            case "M":
               this.dSource = GWizGCParseData.MCodes;
               this.mCodes.selected = true;
               break;
            default:
               GWizUtils.assert(false);
         }
         this.dSource.filterFunction = this.filterMCodes;
         this.dSource.refresh();
         this.prunedList.removeAll();
         var _loc2_:int = 0;
         while(_loc2_ < this.dSource.length)
         {
            _loc5_ = this.dSource.getItemAt(_loc2_);
            this.prunedList.addItemAt(_loc5_,_loc2_);
            _loc2_++;
         }
         var _loc3_:Sort = new Sort();
         var _loc4_:SortField;
         (_loc4_ = new SortField("code",true)).numeric = true;
         _loc3_.fields = [_loc4_];
         this.prunedList.sort = _loc3_;
         this.prunedList.refresh();
         this.dSource.filterFunction = null;
         this.dSource.refresh();
      }
      
      public function showColumns(param1:Boolean, param2:Boolean) : void
      {
         this.ParmCol.visible = param1;
         this.EnableCol.visible = param2;
         this.AddCode.visible = param2;
         this.DelCode.visible = param2;
         this.ResetCodes.visible = param2;
         this.list.editable = param2;
      }
      
      private function filterMCodes(param1:Object) : Boolean
      {
         var _loc2_:String = GWizMachSettings.currMachType;
         if(GWizMachSettings.isMill(GWizMachSettings.currMachType))
         {
            _loc2_ = "M";
         }
         else if(_loc2_ == "Lathe")
         {
            _loc2_ = "L";
         }
         var _loc3_:String = param1.machine;
         if(!_loc3_)
         {
            _loc3_ = "ML";
         }
         log.debug("item.code = " + param1.code + ", item.enabled = " + param1.enabled + ", EnableCol.visible = " + this.EnableCol.visible + ", pruneEnabledNo = " + this.pruneEnabledNo + ", itemType = " + _loc3_ + ", machType = " + _loc2_);
         return (param1.enabled == "yes" || this.EnableCol.visible || !this.pruneEnabledNo) && _loc3_.indexOf(_loc2_) != -1;
      }
      
      protected function onInit() : void
      {
         this.changeGroup(this.codeGroup);
         GWizMachSettings.selectMachineCC.addFunction("GWizGMCodePanel",this.selectMachine);
         this.selectMachine(GWizMachSettings.currMachine);
      }
      
      private function selectMachine(param1:String) : Boolean
      {
         return true;
      }
      
      protected function onCC() : void
      {
         this.list.setFocus();
         this.list.selectedIndex = 0;
         this.minLabLen = this.selLabel.text.length;
         this.selLabelTxt = this.selLabel.text;
      }
      
      protected function onShow() : void
      {
         this.changeGroup(this.codeGroup);
      }
      
      protected function onKeydown(param1:KeyboardEvent) : void
      {
         var _loc2_:int = 13;
         var _loc3_:int = 27;
         var _loc4_:int = 48;
         var _loc5_:int = 57;
         var _loc6_:int = 8;
         var _loc7_:int = 65;
         var _loc8_:int = 77;
         var _loc9_:int = 68;
         var _loc10_:int = 67;
         var _loc11_:int = 80;
         var _loc12_:int = 79;
         var _loc13_:String = (_loc13_ = String.fromCharCode(param1.charCode)).toUpperCase();
         param1.charCode = _loc13_.charCodeAt(0);
         if(_loc4_ <= param1.charCode && param1.charCode <= _loc5_)
         {
            this.selLabel.text += _loc13_;
            param1.preventDefault();
            param1.stopPropagation();
            this.refreshIncremental();
         }
         else
         {
            switch(param1.charCode)
            {
               case _loc6_:
                  if(this.selLabel.text.length > this.minLabLen)
                  {
                     this.selLabel.text = this.selLabel.text.substr(0,this.selLabel.text.length - 1);
                     this.refreshIncremental();
                  }
                  break;
               case _loc2_:
                  param1.preventDefault();
                  this.doInsert();
                  break;
               case _loc3_:
                  param1.preventDefault();
                  if(this.callerCancel != null)
                  {
                     this.callerCancel();
                  }
                  break;
               case _loc7_:
                  if(this.gCodes.selected)
                  {
                     this.showAll();
                  }
                  break;
               case _loc8_:
                  if(this.gCodes.selected)
                  {
                     this.showMotion();
                  }
                  break;
               case _loc9_:
                  if(this.gCodes.selected)
                  {
                     this.showCoordinate();
                  }
                  break;
               case _loc10_:
                  if(this.gCodes.selected)
                  {
                     this.showCanned();
                  }
                  break;
               case _loc11_:
                  if(this.gCodes.selected)
                  {
                     this.showCompensation();
                  }
                  break;
               case _loc12_:
                  if(this.gCodes.selected)
                  {
                     this.showOther();
                  }
            }
         }
      }
      
      private function refreshIncremental() : void
      {
         var _loc3_:Object = null;
         var _loc1_:String = this.selLabel.text.substr(this.minLabLen,this.selLabel.text.length - this.minLabLen);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length - 1 && _loc1_.charAt(_loc2_) == "0")
         {
            _loc2_++;
         }
         _loc1_ = _loc1_.substr(_loc2_,_loc1_.length - _loc2_);
         _loc2_ = 0;
         while(_loc2_ < this.prunedList.length)
         {
            _loc3_ = this.prunedList.getItemAt(_loc2_);
            if(_loc1_ == _loc3_.code)
            {
               break;
            }
            _loc2_++;
         }
         if(this.prunedList && _loc2_ < this.prunedList.length)
         {
            this.list.selectedIndex = _loc2_;
            this.newCodeChoice();
         }
      }
      
      private function filterByType(param1:Object) : Boolean
      {
         return param1.type == this.selectedType || this.selectedType.length == 0;
      }
      
      private function showAux(param1:String) : void
      {
         this.prunedList.filterFunction = this.filterByType;
         this.selectedType = param1;
         this.prunedList.refresh();
         this.selLabel.text = this.selLabelTxt;
      }
      
      private function showAll() : void
      {
         this.showAux("");
      }
      
      private function showMotion() : void
      {
         this.showAux("Motion");
      }
      
      private function showCoordinate() : void
      {
         this.showAux("Coordinate");
      }
      
      private function showCanned() : void
      {
         this.showAux("Canned");
      }
      
      private function showCompensation() : void
      {
         this.showAux("Compensation");
      }
      
      private function showOther() : void
      {
         this.showAux("Other");
      }
      
      private function newCodeChoice() : void
      {
         var _loc1_:Object = this.list.selectedItem;
         if(_loc1_)
         {
            this.notesArea.text = _loc1_.uses;
            if(this.notesArea.text == "")
            {
               if(this.codeGroup == "G")
               {
                  if(_loc1_.code == "51")
                  {
                     switch(GWizSettings.post.g51Style)
                     {
                        case GWizSettings.post.G51_FANUC:
                           this.notesArea.text = "P scales all axes same amount or use to scale IJK individual axes.  XYZ scaling center.";
                           break;
                        case GWizSettings.post.G51_HAAS:
                           this.notesArea.text = "P scale factor. IJK is the scaling center.";
                           break;
                        case GWizSettings.post.G51_MACH3:
                           this.notesArea.text = "XYZ are scale factors for each individual axes.";
                     }
                  }
               }
            }
         }
      }
      
      private function doDoubleClick() : void
      {
         if(!this.EnableCol.visible)
         {
            this.newCodeChoice();
            this.doInsert();
         }
         else
         {
            this.customizeCode(false);
         }
      }
      
      private function customizeCode(param1:Boolean) : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         this.customNewCode = param1;
         var _loc2_:GWizGMCodeCustom = GWizGMCodeCustom(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizGMCodeCustom,true));
         if(_loc2_)
         {
            _loc3_ = this.list.selectedItem;
            _loc4_ = "M-Code";
            if(this.gCodes.selected && _loc3_)
            {
               _loc4_ = _loc3_.type;
            }
            if(_loc3_ != null)
            {
               _loc2_.setCustom(_loc3_.code,_loc4_,_loc3_.enabled,_loc3_.hint,_loc3_.parameters,this.customizeResponse,param1);
            }
            else
            {
               _loc2_.setCustom(0,_loc4_,null,null,null,this.customizeResponse,param1);
            }
         }
      }
      
      private function customizeResponse(param1:String, param2:String, param3:String, param4:Number, param5:String, param6:Boolean) : void
      {
         var _loc8_:String = null;
         var _loc7_:Object;
         if((_loc7_ = this.list.selectedItem) && _loc7_.code == param4)
         {
            _loc8_ = _loc7_.code;
         }
         else
         {
            _loc8_ = String(Math.floor(param4));
         }
         var _loc9_:ArrayCollection = GWizGCParseData.MCodes;
         if(this.gCodes.selected)
         {
            _loc9_ = GWizGCParseData.GCodes;
         }
         var _loc10_:String = GWizMachSettings.currMachType;
         if(GWizMachSettings.isMill(GWizMachSettings.currMachType))
         {
            _loc10_ = "M";
         }
         else if(_loc10_ == "Lathe")
         {
            _loc10_ = "L";
         }
         var _loc11_:int = 0;
         while(_loc11_ < _loc9_.length)
         {
            if((_loc7_ = _loc9_.getItemAt(_loc11_)).code == _loc8_)
            {
               _loc7_.enabled = param1;
               _loc7_.hint = param2;
               _loc7_.parameters = param3;
               _loc7_.newCode = param6;
               if(_loc7_.machine != _loc10_)
               {
                  _loc10_ += _loc7_.machine;
                  _loc7_.machine = _loc10_;
               }
               break;
            }
            _loc11_++;
         }
         if(this.customNewCode && _loc7_.code != _loc8_)
         {
            (_loc7_ = new Object()).code = String(Math.floor(param4));
            _loc7_.hint = param2;
            _loc7_.parameters = param3;
            _loc7_.enabled = param1;
            _loc7_.newCode = true;
            _loc7_.machine = _loc10_;
            _loc7_.type = param5;
            if(param5 != "M-Code")
            {
               _loc7_.uses = "";
               GWizGCParseData.GCodes.addItem(_loc7_);
            }
            else
            {
               GWizGCParseData.MCodes.addItem(_loc7_);
            }
         }
         this.changeGroup(this.codeGroup);
         this.prunedList.refresh();
         this.list.selectedIndex = 0;
         this.list.validateNow();
      }
      
      public function formatData(param1:Event) : void
      {
         if(param1 is GridItemEditorEvent && param1.type == GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_CANCEL)
         {
            return;
         }
         var _loc2_:String = DropDownList(param1.currentTarget.itemEditorInstance).selectedItem;
         if(_loc2_ == "no")
         {
            DropDownList(param1.currentTarget.itemEditorInstance).selectedIndex = -1;
         }
      }
      
      private function doReset() : void
      {
         GWizGCParseData.resetCodes();
         GWizSettings.post.forceSavePost();
         this.changeGroup("M");
         this.changeGroup("G");
      }
      
      private function codeSortFcn(param1:Object, param2:Object) : int
      {
         var _loc3_:Number = param1.code == "" || param1.code == null ? Number(null) : Number(new Number(param1.code));
         var _loc4_:Number = param2.code == "" || param2.code == null ? Number(null) : Number(new Number(param2.code));
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
      
      private function doDelCode() : void
      {
         var _loc2_:ArrayCollection = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         var _loc1_:Object = this.list.selectedItem;
         if(_loc1_.hasOwnProperty("newCode") && _loc1_.newCode == true)
         {
            _loc2_ = GWizGCParseData.MCodes;
            if(this.gCodes.selected)
            {
               _loc2_ = GWizGCParseData.GCodes;
            }
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               _loc5_ = _loc2_.getItemAt(_loc3_);
               if(_loc1_.code == _loc5_.code)
               {
                  _loc2_.removeItemAt(_loc3_);
               }
               _loc3_++;
            }
            _loc4_ = 0;
            while(_loc4_ < this.prunedList.length)
            {
               _loc6_ = this.prunedList.getItemAt(_loc4_);
               if(_loc1_.code == _loc6_.code)
               {
                  this.prunedList.removeItemAt(_loc4_);
               }
               _loc4_++;
            }
         }
         else
         {
            GWizPopUpManager.Show("Sorry, can\'t delete builtin codes.  You can only make them unavailable.","Error: Cannot Delete",GWizPopUpManager.ERROR);
         }
      }
      
      private function onTypeChange(param1:IndexChangeEvent) : void
      {
         switch(ButtonBar(param1.target).selectedItem)
         {
            case this.GCODE_ALL:
               this.showAll();
               break;
            case this.GCODE_MOTION:
               this.showMotion();
               break;
            case this.GCODE_COORDINATE:
               this.showCoordinate();
               break;
            case this.GCODE_CANNED:
               this.showCanned();
               break;
            case this.GCODE_COMPENSATION:
               this.showCompensation();
               break;
            case this.GCODE_OTHER:
               this.showOther();
               break;
            default:
               this.showAll();
         }
      }
      
      private function _GWizGMCodePanel_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"codeType");
         this.codeType = _loc1_;
         BindingManager.executeBindings(this,"codeType",this.codeType);
         return _loc1_;
      }
      
      private function _GWizGMCodePanel_HGroup1_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGMCodePanel_Label1_i(),this._GWizGMCodePanel_RadioButton1_i(),this._GWizGMCodePanel_RadioButton2_i()];
         _loc1_.id = "_GWizGMCodePanel_HGroup1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGMCodePanel_HGroup1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGMCodePanel_HGroup1",this._GWizGMCodePanel_HGroup1);
         return _loc1_;
      }
      
      private function _GWizGMCodePanel_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Select Code: ";
         _loc1_.id = "selLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.selLabel = _loc1_;
         BindingManager.executeBindings(this,"selLabel",this.selLabel);
         return _loc1_;
      }
      
      private function _GWizGMCodePanel_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "G";
         _loc1_.groupName = "codeType";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("click",this.__gCodes_click);
         _loc1_.id = "gCodes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gCodes = _loc1_;
         BindingManager.executeBindings(this,"gCodes",this.gCodes);
         return _loc1_;
      }
      
      public function __gCodes_click(param1:MouseEvent) : void
      {
         this.changeGroup("G");
      }
      
      private function _GWizGMCodePanel_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "M";
         _loc1_.groupName = "codeType";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("click",this.__mCodes_click);
         _loc1_.id = "mCodes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.mCodes = _loc1_;
         BindingManager.executeBindings(this,"mCodes",this.mCodes);
         return _loc1_;
      }
      
      public function __mCodes_click(param1:MouseEvent) : void
      {
         this.changeGroup("M");
      }
      
      private function _GWizGMCodePanel_ButtonBar1_i() : ButtonBar
      {
         var _loc1_:ButtonBar = new ButtonBar();
         _loc1_.requireSelection = true;
         _loc1_.addEventListener("change",this.___GWizGMCodePanel_ButtonBar1_change);
         _loc1_.id = "_GWizGMCodePanel_ButtonBar1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGMCodePanel_ButtonBar1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGMCodePanel_ButtonBar1",this._GWizGMCodePanel_ButtonBar1);
         return _loc1_;
      }
      
      public function ___GWizGMCodePanel_ButtonBar1_change(param1:IndexChangeEvent) : void
      {
         this.onTypeChange(param1);
      }
      
      private function _GWizGMCodePanel_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGMCodePanel_Button1_i(),this._GWizGMCodePanel_Spacer1_c(),this._GWizGMCodePanel_Button2_i(),this._GWizGMCodePanel_Button3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGMCodePanel_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Add Code";
         _loc1_.toolTip = "Add a new G- or M-Code";
         _loc1_.visible = false;
         _loc1_.addEventListener("click",this.__AddCode_click);
         _loc1_.id = "AddCode";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.AddCode = _loc1_;
         BindingManager.executeBindings(this,"AddCode",this.AddCode);
         return _loc1_;
      }
      
      public function __AddCode_click(param1:MouseEvent) : void
      {
         this.customizeCode(true);
      }
      
      private function _GWizGMCodePanel_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 30;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGMCodePanel_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Delete";
         _loc1_.visible = false;
         _loc1_.addEventListener("click",this.__DelCode_click);
         _loc1_.id = "DelCode";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DelCode = _loc1_;
         BindingManager.executeBindings(this,"DelCode",this.DelCode);
         return _loc1_;
      }
      
      public function __DelCode_click(param1:MouseEvent) : void
      {
         this.doDelCode();
      }
      
      private function _GWizGMCodePanel_Button3_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Reset to Defaults";
         _loc1_.toolTip = "Reset G-and-M-Codes to G-Wizard defaults";
         _loc1_.visible = false;
         _loc1_.addEventListener("click",this.__ResetCodes_click);
         _loc1_.id = "ResetCodes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ResetCodes = _loc1_;
         BindingManager.executeBindings(this,"ResetCodes",this.ResetCodes);
         return _loc1_;
      }
      
      public function __ResetCodes_click(param1:MouseEvent) : void
      {
         this.doReset();
      }
      
      private function _GWizGMCodePanel_DataGrid1_i() : DataGrid
      {
         var _loc1_:DataGrid = new DataGrid();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.editable = false;
         _loc1_.doubleClickEnabled = true;
         _loc1_.columns = this._GWizGMCodePanel_ArrayList1_c();
         _loc1_.setStyle("horizontalScrollPolicy","on");
         _loc1_.addEventListener("keyDown",this.__list_keyDown);
         _loc1_.addEventListener("selectionChange",this.__list_selectionChange);
         _loc1_.addEventListener("doubleClick",this.__list_doubleClick);
         _loc1_.id = "list";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.list = _loc1_;
         BindingManager.executeBindings(this,"list",this.list);
         return _loc1_;
      }
      
      private function _GWizGMCodePanel_ArrayList1_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizGMCodePanel_GridColumn1_c(),this._GWizGMCodePanel_GridColumn2_c(),this._GWizGMCodePanel_GridColumn3_c(),this._GWizGMCodePanel_GridColumn4_i(),this._GWizGMCodePanel_GridColumn5_i(),this._GWizGMCodePanel_GridColumn6_i()];
         return _loc1_;
      }
      
      private function _GWizGMCodePanel_GridColumn1_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Code";
         _loc1_.dataField = "code";
         _loc1_.width = 50;
         _loc1_.editable = false;
         _loc1_.sortCompareFunction = this.codeSortFcn;
         return _loc1_;
      }
      
      private function _GWizGMCodePanel_GridColumn2_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Function";
         _loc1_.dataField = "hint";
         _loc1_.editable = false;
         return _loc1_;
      }
      
      private function _GWizGMCodePanel_GridColumn3_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Type";
         _loc1_.dataField = "type";
         _loc1_.editable = false;
         _loc1_.width = 110;
         return _loc1_;
      }
      
      private function _GWizGMCodePanel_GridColumn4_i() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Parameters";
         _loc1_.dataField = "parameters";
         _loc1_.width = 0;
         _loc1_.visible = false;
         _loc1_.editable = false;
         this.ParmCol = _loc1_;
         BindingManager.executeBindings(this,"ParmCol",this.ParmCol);
         return _loc1_;
      }
      
      private function _GWizGMCodePanel_GridColumn5_i() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Enabled";
         _loc1_.dataField = "enabled";
         _loc1_.width = 0;
         _loc1_.visible = false;
         _loc1_.editable = false;
         _loc1_.itemRenderer = this._GWizGMCodePanel_ClassFactory1_c();
         this.EnableCol = _loc1_;
         BindingManager.executeBindings(this,"EnableCol",this.EnableCol);
         return _loc1_;
      }
      
      private function _GWizGMCodePanel_ClassFactory1_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizGMCodePanelInnerClass0;
         _loc1_.properties = {"outerDocument":this};
         return _loc1_;
      }
      
      private function _GWizGMCodePanel_GridColumn6_i() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Machine";
         _loc1_.dataField = "machine";
         _loc1_.width = 80;
         _loc1_.visible = false;
         _loc1_.editable = false;
         this.MachType = _loc1_;
         BindingManager.executeBindings(this,"MachType",this.MachType);
         return _loc1_;
      }
      
      public function __list_keyDown(param1:KeyboardEvent) : void
      {
         this.onKeydown(param1);
      }
      
      public function __list_selectionChange(param1:GridSelectionEvent) : void
      {
         this.newCodeChoice();
      }
      
      public function __list_doubleClick(param1:MouseEvent) : void
      {
         this.doDoubleClick();
      }
      
      private function _GWizGMCodePanel_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Notes:";
         _loc1_.setStyle("fontSize",12);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizGMCodePanel_Label2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGMCodePanel_Label2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGMCodePanel_Label2",this._GWizGMCodePanel_Label2);
         return _loc1_;
      }
      
      private function _GWizGMCodePanel_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.id = "notesArea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.notesArea = _loc1_;
         BindingManager.executeBindings(this,"notesArea",this.notesArea);
         return _loc1_;
      }
      
      private function _GWizGMCodePanel_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizGMCodePanel_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      public function ___GWizGMCodePanel_VGroup1_initialize(param1:FlexEvent) : void
      {
         this.onInit();
      }
      
      public function ___GWizGMCodePanel_VGroup1_show(param1:FlexEvent) : void
      {
         this.callLater(this.onShow);
      }
      
      private function _GWizGMCodePanel_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,null,function(param1:uint):void
         {
            _GWizGMCodePanel_HGroup1.setStyle("color",param1);
         },"_GWizGMCodePanel_HGroup1.color","textColor");
         result[1] = new Binding(this,function():Boolean
         {
            return gCodes.selected;
         },null,"_GWizGMCodePanel_ButtonBar1.visible");
         result[2] = new Binding(this,function():IList
         {
            return gcodeTypes;
         },null,"_GWizGMCodePanel_ButtonBar1.dataProvider");
         result[3] = new Binding(this,function():IList
         {
            return prunedList;
         },null,"list.dataProvider");
         result[4] = new Binding(this,null,function(param1:uint):void
         {
            list.setStyle("selectionColor",param1);
         },"list.selectionColor","selectColor");
         result[5] = new Binding(this,null,function(param1:uint):void
         {
            list.setStyle("rollOverColor",param1);
         },"list.rollOverColor","rollOverColor");
         result[6] = new Binding(this,null,function(param1:uint):void
         {
            _GWizGMCodePanel_Label2.setStyle("color",param1);
         },"_GWizGMCodePanel_Label2.color","textColor");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get AddCode() : Button
      {
         return this._515570190AddCode;
      }
      
      public function set AddCode(param1:Button) : void
      {
         var _loc2_:Object = this._515570190AddCode;
         if(_loc2_ !== param1)
         {
            this._515570190AddCode = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"AddCode",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get DelCode() : Button
      {
         return this._1080868744DelCode;
      }
      
      public function set DelCode(param1:Button) : void
      {
         var _loc2_:Object = this._1080868744DelCode;
         if(_loc2_ !== param1)
         {
            this._1080868744DelCode = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DelCode",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EnableCol() : GridColumn
      {
         return this._1372287197EnableCol;
      }
      
      public function set EnableCol(param1:GridColumn) : void
      {
         var _loc2_:Object = this._1372287197EnableCol;
         if(_loc2_ !== param1)
         {
            this._1372287197EnableCol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EnableCol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MachType() : GridColumn
      {
         return this._121092109MachType;
      }
      
      public function set MachType(param1:GridColumn) : void
      {
         var _loc2_:Object = this._121092109MachType;
         if(_loc2_ !== param1)
         {
            this._121092109MachType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MachType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ParmCol() : GridColumn
      {
         return this._871474644ParmCol;
      }
      
      public function set ParmCol(param1:GridColumn) : void
      {
         var _loc2_:Object = this._871474644ParmCol;
         if(_loc2_ !== param1)
         {
            this._871474644ParmCol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ParmCol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ResetCodes() : Button
      {
         return this._291035191ResetCodes;
      }
      
      public function set ResetCodes(param1:Button) : void
      {
         var _loc2_:Object = this._291035191ResetCodes;
         if(_loc2_ !== param1)
         {
            this._291035191ResetCodes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ResetCodes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get codeType() : RadioButtonGroup
      {
         return this._867962169codeType;
      }
      
      public function set codeType(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._867962169codeType;
         if(_loc2_ !== param1)
         {
            this._867962169codeType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"codeType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gCodes() : RadioButton
      {
         return this._1280882689gCodes;
      }
      
      public function set gCodes(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1280882689gCodes;
         if(_loc2_ !== param1)
         {
            this._1280882689gCodes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gCodes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get list() : DataGrid
      {
         return this._3322014list;
      }
      
      public function set list(param1:DataGrid) : void
      {
         var _loc2_:Object = this._3322014list;
         if(_loc2_ !== param1)
         {
            this._3322014list = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"list",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get mCodes() : RadioButton
      {
         return this._1109107783mCodes;
      }
      
      public function set mCodes(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1109107783mCodes;
         if(_loc2_ !== param1)
         {
            this._1109107783mCodes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"mCodes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get notesArea() : TextArea
      {
         return this._1797933806notesArea;
      }
      
      public function set notesArea(param1:TextArea) : void
      {
         var _loc2_:Object = this._1797933806notesArea;
         if(_loc2_ !== param1)
         {
            this._1797933806notesArea = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"notesArea",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get selLabel() : Label
      {
         return this._1168407226selLabel;
      }
      
      public function set selLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1168407226selLabel;
         if(_loc2_ !== param1)
         {
            this._1168407226selLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"selLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get textColor() : uint
      {
         return this._1063571914textColor;
      }
      
      public function set textColor(param1:uint) : void
      {
         var _loc2_:Object = this._1063571914textColor;
         if(_loc2_ !== param1)
         {
            this._1063571914textColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"textColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get rollOverColor() : uint
      {
         return this._1274952974rollOverColor;
      }
      
      public function set rollOverColor(param1:uint) : void
      {
         var _loc2_:Object = this._1274952974rollOverColor;
         if(_loc2_ !== param1)
         {
            this._1274952974rollOverColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"rollOverColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get selectColor() : uint
      {
         return this._189450183selectColor;
      }
      
      public function set selectColor(param1:uint) : void
      {
         var _loc2_:Object = this._189450183selectColor;
         if(_loc2_ !== param1)
         {
            this._189450183selectColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"selectColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get prunedList() : ArrayCollection
      {
         return this._848253512prunedList;
      }
      
      private function set prunedList(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._848253512prunedList;
         if(_loc2_ !== param1)
         {
            this._848253512prunedList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"prunedList",_loc2_,param1));
            }
         }
      }
   }
}
