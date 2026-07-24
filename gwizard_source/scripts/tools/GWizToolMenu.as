package tools
{
   import compsp.ScrollableMenu;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.core.ScrollPolicy;
   import mx.events.FlexEvent;
   import mx.events.MenuEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.skins.halo.ComboBoxArrowSkin;
   import spark.components.Button;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.TextInput;
   import spark.skins.spark.ComboBoxButtonSkin;
   import utils.GATracker;
   import utils.GWizDebugUtils;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   public class GWizToolMenu extends HGroup
   {
      
      private static const log:ILogger = Log.getLogger("GWizToolMenu");
      
      public static var MillToolMenuXML:XMLList = new XMLList("\n\t\t\t\t\t<menuitem label=\"HSS Endmill\" tool=\"\"/>\n\t\t\t\t\t<menuitem label=\"HP HSS Endmill\" tool=\"\"/>\n\t\t\t\t\t<menuitem label=\"Carbide Endmill\" tool=\"\"/>\n\t\t\t\t\t<menuitem label=\"HP Carbide Endmill\" tool=\"\"/>\n\t\t\t\t\t<menuitem label=\"TiAlN Carbide Endmill\" tool=\"\"/>\n\t\t\t\t\t<menuitem label=\"PCD Endmill\" tool=\"\"/>\n\t\t\t\t\t\t\t\t\n\t\t\t\t\t<menuitem label=\"Indexable End Or Face Mill\" tool=\"\"/>\n\t\t\t\t\t\t\t\t\n\t\t\t\t\t<menuitem label=\"HSS Twist Drill\" tool=\"\"/>\n\t\t\t\t\t<menuitem label=\"HP HSS Twist Drill\" tool=\"\"/>\n\t\t\t\t\t<menuitem label=\"Cobalt Twist Drill\" tool=\"\"/>\n\t\t\t\t\t<menuitem label=\"Carbide Twist Drill\" tool=\"\"/>\n\t\t\t\t\t<menuitem label=\"HP Carbide Twist Drill\" tool=\"\"/>\n\t\t\t\t\t<menuitem label=\"PCD Twist Drill\" tool=\"\"/>\n\t\t\t\t\t\t\t\t\n\t\t\t\t\t<menuitem label=\"Indexable Drill\" tool=\"\"/>\n\t\t\t\t\n\t\t\t\t\t<menuitem label=\"Spot Drill\">\n\t\t\t\t\t\t<menuitem label=\"HSS\" tool=\"\"/>\n\t\t\t\t\t\t<menuitem label=\"Carbide\" tool=\"\"/>\n\t\t\t\t\t</menuitem>\n\t\t\t\t\t\t\t\t\n\t\t\t\t\t<menuitem label=\"Center Drill\">\n\t\t\t\t\t\t<menuitem label=\"HSS\" tool=\"\"/>\n\t\t\t\t\t\t<menuitem label=\"Carbide\" tool=\"\"/>\n\t\t\t\t\t</menuitem>\n\t\t\t\t\t\t\t\n\t\t\t\t\t<menuitem label=\"Spade Drill\">\n\t\t\t\t\t\t<menuitem label=\"HSS\" tool=\"\"/>\n\t\t\t\t\t\t<menuitem label=\"Carbide\" tool=\"\"/>\n\t\t\t\t\t</menuitem>\n\t\t\t\t\n\t\t\t\t\t<menuitem label=\"Gun Drill\" tool=\"\"/>\t\n\t\t\t\t\t\t\t\t\n\t\t\t\t\t<menuitem label=\"Reamer\">\n\t\t\t\t\t\t<menuitem label=\"HSS\" tool=\"\"/>\n\t\t\t\t\t\t<menuitem label=\"Carbide\" tool=\"\"/>\n\t\t\t\t\t</menuitem>\n\t\t\t\t\t\t\t\t\n\t\t\t\t\t<menuitem label=\"Tapping\">\n\t\t\t\t\t\t<menuitem label=\"HSS\" tool=\"\"/>\n\t\t\t\t\t\t<menuitem label=\"Carbide\" tool=\"\"/>\n\t\t\t\t\t</menuitem>\n\t\t\t\t\t\t\t\t\n\t\t\t\t\t<menuitem label=\"Carbide Thread Mill\" tool=\"\"/>\n\n\t\t\t\t\t<menuitem label=\"Boring\">\n\t\t\t\t\t\t<menuitem label=\"HSS\" tool=\"\"/>\n\t\t\t\t\t\t<menuitem label=\"Carbide\" tool=\"\"/>\n\t\t\t\t\t</menuitem>\n\t\t\t\t\t\t\t\t\n\t\t\t\t\t<menuitem label=\"Saws & Woodruff Cutters\">\n\t\t\t\t\t\t<menuitem label=\"HSS\" tool=\"\"/>\n\t\t\t\t\t\t<menuitem label=\"Carbide\" tool=\"\"/>\n\t\t\t\t\t</menuitem>\n\n\t\t\t\t\t<menuitem label=\"Annular Cutter (Rotabroach®)\" tool=\"\"/>\n\n\t\t\t\t\t<menuitem label=\"Turning\" tool=\"\"/>\t\n\t\t\t\t\t\t\t\t\n\t\t\t\t\t<menuitem label=\"Probe\" tool=\"\"/>\t\n\t\t\t\t\t\t\t\t\n\t\t\t\t\t<menuitem label=\"Other\" tool=\"\"/>\t\n\t\t\t\t\t\t\t\t\n\t\t\t\t\t<menuitem label=\"Empty Toolholder\" tool=\"\"/>\t\t\t\t\t\t\t\t\t\n\t\t\t\t\t\t\t\t\n\t\t\t\t\t<menuitem label=\"Empty Slot\" tool=\"\"/>\t\n\t\t\t\t");
      
      public static const USE_HYBRID_LABELS:Boolean = true;
      
      public static var tmPopup:GWizToolMenuPopup;
       
      
      private var _2603341Text:TextInput;
      
      private var _3536189tPop:Button;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1032247510cribTbl:DropDownList;
      
      private var ignoreForePanelThemes:Boolean = true;
      
      private var _selectedIndex:int = 0;
      
      private var _toolDef:GWizToolDef = null;
      
      public var theMenuXML:XMLList;
      
      private var _41233125inFeedsSpeedsApp:Boolean = false;
      
      private var oldXML:XMLList;
      
      private var _currGUID:String = "";
      
      private var lastGUID:String = "";
      
      private var _selectedLabel:String = "HSS Endmill";
      
      private var _dataProvider:Array = null;
      
      private var _292864594selectFromCrib:Boolean = false;
      
      public var labelField:String = "";
      
      private var arrow:ComboBoxArrowSkin;
      
      private var tMenu:ScrollableMenu;
      
      private var tMenuShowing:Boolean = false;
      
      public var vcHandler:Function = null;
      
      public var changeHandler:Function = null;
      
      public function GWizToolMenu()
      {
         this.theMenuXML = MillToolMenuXML;
         super();
         mx_internal::_document = this;
         this.gap = 0;
         this.mxmlContent = [this._GWizToolMenu_TextInput1_i(),this._GWizToolMenu_Button1_i()];
         this.addEventListener("creationComplete",this.___GWizToolMenu_HGroup1_creationComplete);
      }
      
      public static function toPrimitiveLabel(param1:String) : String
      {
         var _loc4_:Object = null;
         var _loc2_:String = param1;
         if(false && GWizUtils.debug && param1.toLowerCase().indexOf("annular") >= 0)
         {
            log.debug("toPrimitiveLabel(\'" + param1 + "\'");
         }
         param1 = param1.toLowerCase().replace("tool menu: ","");
         param1 = GWizStringUtils.lowerToProperCase(param1);
         var _loc3_:int = 0;
         while(_loc3_ < GWizToolData.geometryTypes.length)
         {
            _loc4_ = GWizToolData.geometryTypes.getItemAt(_loc3_);
            if(param1.indexOf(_loc4_.label) >= 0 && _loc4_.family == "Endmill")
            {
               param1 = param1.replace(_loc4_.label,"Endmill");
               break;
            }
            _loc3_++;
         }
         if(!GWizToolData.validToolTypeStr(param1))
         {
            if(param1.search("Indexable End Or Face Mill") >= 0)
            {
               param1 = "Indexable End Or Face Mill";
            }
            else
            {
               param1 = "HSS Endmill";
            }
         }
         param1 = param1.replace("Hss ","HSS ");
         param1 = param1.replace("Hp ","HP ");
         param1 = param1.replace("Tialn ","TiAlN ");
         param1 = param1.replace("Pcd ","PCD ");
         if(false && GWizUtils.debug)
         {
            log.debug("toPrimitiveLabel(\'" + _loc2_ + "\') = \'" + param1 + "\'");
         }
         return param1;
      }
      
      public static function toHybridLabel(param1:String, param2:String) : String
      {
         if(USE_HYBRID_LABELS)
         {
            if(param1.indexOf("Endmill") >= 0 && param2 && param2 != "Normal")
            {
               param1 = param1.replace("Endmill",param2);
            }
            else if(param1.indexOf("Turning") >= 0 && param2 && param2 != "Normal")
            {
               param1 = param1.replace("Turning",param2);
            }
         }
         return param1;
      }
      
      public static function validToolName(param1:String) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Boolean = false;
         _loc3_ = 0;
         while(_loc3_ < GWizToolData.LatheToolsList.length && !_loc2_)
         {
            if(param1.indexOf(GWizToolData.LatheToolsList[_loc3_]) >= 0)
            {
               _loc2_ = true;
            }
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < GWizToolData.MillToolsList.length && !_loc2_)
         {
            if(param1.indexOf(GWizToolData.MillToolsList[_loc3_]) >= 0)
            {
               _loc2_ = true;
            }
            _loc3_++;
         }
         return _loc2_;
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
      
      private function onCC() : void
      {
         GWizUtils.LogErrorContext = "GWizToolMenu.onCC";
         this.changeMenuXML(MillToolMenuXML);
         if(GWizUtils.debug)
         {
            this.doUnitTests();
         }
      }
      
      private function doUnitTests() : void
      {
         GWizUtils.assert(toPrimitiveLabel("HSS Endmill") == "HSS Endmill");
         GWizUtils.assert(toPrimitiveLabel("Carbide Endmill") == "Carbide Endmill");
         GWizUtils.assert(toPrimitiveLabel("PCD Endmill") == "PCD Endmill");
         GWizUtils.assert(toPrimitiveLabel("TiAlN Carbide Endmill") == "TiAlN Carbide Endmill");
         GWizUtils.assert(toPrimitiveLabel("HP Carbide Endmill") == "HP Carbide Endmill");
         GWizUtils.assert(toPrimitiveLabel("HP HSS Endmill") == "HP HSS Endmill");
         GWizUtils.assert(toPrimitiveLabel("Indexable End Or Face Mill") == "Indexable End Or Face Mill");
         GWizUtils.assert(toPrimitiveLabel("HSS Twist Drill") == "HSS Twist Drill");
         GWizUtils.assert(toPrimitiveLabel("HP HSS Twist Drill") == "HP HSS Twist Drill");
         GWizUtils.assert(toPrimitiveLabel("Cobalt Twist Drill") == "Cobalt Twist Drill");
         GWizUtils.assert(toPrimitiveLabel("Carbide Twist Drill") == "Carbide Twist Drill");
         GWizUtils.assert(toPrimitiveLabel("HP Carbide Twist Drill") == "HP Carbide Twist Drill");
         GWizUtils.assert(toPrimitiveLabel("PCD Twist Drill") == "PCD Twist Drill");
         GWizUtils.assert(toPrimitiveLabel("Indexable Drill") == "Indexable Drill");
         GWizUtils.assert(toPrimitiveLabel("HSS Spot Drill") == "HSS Spot Drill");
         GWizUtils.assert(toPrimitiveLabel("Carbide Spot Drill") == "Carbide Spot Drill");
         GWizUtils.assert(toPrimitiveLabel("HSS Center Drill") == "HSS Center Drill");
         GWizUtils.assert(toPrimitiveLabel("Carbide Center Drill") == "Carbide Center Drill");
         GWizUtils.assert(toPrimitiveLabel("HSS Spade Drill") == "HSS Spade Drill");
         GWizUtils.assert(toPrimitiveLabel("Gun Drill") == "Gun Drill");
         GWizUtils.assert(toPrimitiveLabel("HSS Reamer") == "HSS Reamer");
         GWizUtils.assert(toPrimitiveLabel("Carbide Reamer") == "Carbide Reamer");
         GWizUtils.assert(toPrimitiveLabel("HSS Tapping") == "HSS Tapping");
         GWizUtils.assert(toPrimitiveLabel("Carbide Tapping") == "Carbide Tapping");
         GWizUtils.assert(toPrimitiveLabel("Carbide Thread Mill") == "Carbide Thread Mill");
         GWizUtils.assert(toPrimitiveLabel("HSS Boring") == "HSS Boring");
         GWizUtils.assert(toPrimitiveLabel("Carbide Boring") == "Carbide Boring");
         GWizUtils.assert(toPrimitiveLabel("HSS Saws & Woodruff Cutters") == "HSS Saws & Woodruff Cutters");
         GWizUtils.assert(toPrimitiveLabel("Carbide Saws & Woodruff Cutters") == "Carbide Saws & Woodruff Cutters");
         GWizUtils.assert(toPrimitiveLabel("Annular Cutter (Rotabroach®)") == "Annular Cutter (Rotabroach®)");
         GWizUtils.assert(toPrimitiveLabel("Turning: Carbide") == "Turning: Carbide");
         GWizUtils.assert(toPrimitiveLabel("Turning: HSS") == "Turning: Hss");
         GWizUtils.assert(toPrimitiveLabel("Turning: Carbide") == "Turning: Carbide");
         GWizUtils.assert(toPrimitiveLabel("Turning: HSS") == "Turning: Hss");
      }
      
      public function set toolDef(param1:GWizToolDef) : void
      {
         this._toolDef = param1;
      }
      
      public function get toolDef() : GWizToolDef
      {
         return this._toolDef;
      }
      
      private function changeMenuXML(param1:XMLList) : void
      {
         var _loc3_:XML = null;
         var _loc4_:XMLList = null;
         var _loc5_:Boolean = false;
         var _loc6_:XML = null;
         GWizUtils.LogErrorContext = "GWizToolMenu.changeMenuXML";
         this.theMenuXML = param1;
         var _loc2_:int = 0;
         for each(_loc3_ in this.theMenuXML)
         {
            _loc3_.@tool = _loc3_.@label;
            _loc4_ = _loc3_.children();
            _loc5_ = true;
            for each(_loc6_ in _loc4_)
            {
               _loc5_ = false;
               _loc6_.@tool = _loc6_.@label + " " + _loc3_.@label;
               _loc6_.@selectedIndex = _loc2_++;
            }
            if(_loc5_)
            {
               _loc3_.@selectedIndex = _loc2_++;
            }
         }
         if(param1 != this.oldXML)
         {
            this.selectedIndex = 0;
            this.oldXML = param1;
         }
      }
      
      public function get selectedIndex() : int
      {
         GWizUtils.LogErrorContext = "GWizToolMenu.get selectedIndex";
         return this._selectedIndex;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         var _loc3_:XML = null;
         var _loc4_:XMLList = null;
         var _loc5_:XML = null;
         var _loc6_:GWizToolCribArray = null;
         var _loc7_:GWizToolCribEntry = null;
         GWizUtils.LogErrorContext = "GWizToolMenu.set selectedIndex";
         var _loc2_:Boolean = false;
         param1 = Math.max(0,param1);
         this._selectedIndex = param1;
         if(!this.isCribDataProvider())
         {
            for each(_loc3_ in this.theMenuXML)
            {
               if(_loc3_.@selectedIndex == param1)
               {
                  this._selectedLabel = this.cleanLabel(_loc3_.@tool);
                  _loc2_ = true;
                  break;
               }
               _loc4_ = _loc3_.children();
               for each(_loc5_ in _loc4_)
               {
                  if(_loc5_.@selectedIndex == param1)
                  {
                     this._selectedLabel = this.cleanLabel(_loc5_.@tool);
                     _loc2_ = true;
                     break;
                  }
               }
               if(_loc2_)
               {
                  break;
               }
            }
            if(!_loc2_)
            {
               this._selectedIndex = 0;
               if(this.theMenuXML && this.theMenuXML.menuitem[0])
               {
                  this._selectedLabel = this.cleanLabel(this.theMenuXML.menuitem[0].@tool);
               }
               else
               {
                  this._selectedLabel = "HSS Endmill";
               }
            }
         }
         else if(this.cribTbl && this.cribTbl.selectedItem)
         {
            _loc6_ = GWizSettings.cribData.currCrib(this.cribTbl.selectedItem.tabname);
            if(param1 < _loc6_.length)
            {
               _loc7_ = _loc6_.getCribEntryAt(param1);
               this._selectedLabel = _loc7_.description;
            }
         }
         this.Text.text = this.selectedLabel;
         this.onChange();
         this.sendUpTheEvent(FlexEvent.VALUE_COMMIT);
      }
      
      public function get currGUID() : String
      {
         return this._currGUID;
      }
      
      public function resetGUID() : void
      {
         this._currGUID = "";
      }
      
      public function setGuid(param1:String) : void
      {
         var _loc2_:* = false;
         var _loc3_:GWizToolCribEntry = null;
         var _loc4_:GWizToolCribArray = null;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         if(this.cribTbl && this.cribTbl.selectedItem)
         {
            _loc2_ = !GWizSettings.cacheToolGUIDS;
            _loc2_ = Boolean(_loc2_ || param1 != this.lastGUID);
            if(_loc2_)
            {
               _loc3_ = GWizToolCribData.ToolCrib.getCribEntryByGUID(param1);
               if(_loc3_)
               {
                  _loc3_ = (_loc4_ = GWizSettings.cribData.currCrib(_loc3_.tabname)).getCribEntryByGUID(param1);
                  this._selectedIndex = _loc4_.lastGUIDIdx;
                  this._selectedLabel = _loc3_.description;
                  this.Text.text = this.selectedLabel;
                  _loc5_ = 0;
                  while(_loc5_ < GWizCribList.cribListPlus.length)
                  {
                     if((_loc6_ = GWizCribList.cribListPlus.getItemAt(_loc5_)).tabname == _loc3_.tabname)
                     {
                        this.cribTbl.selectedIndex = _loc5_;
                        this.cribTbl.validateNow();
                        break;
                     }
                     _loc5_++;
                  }
                  this.onChange();
                  this._currGUID = param1;
                  this.lastGUID = param1;
               }
            }
            return;
         }
         this.resetGUID();
      }
      
      public function get selectedLabel() : String
      {
         GWizUtils.LogErrorContext = "GWizToolMenu.get selectedLabel";
         if(!this._selectedLabel)
         {
            this._selectedLabel = "HSS Endmill";
         }
         var _loc1_:String = this._selectedLabel;
         if(USE_HYBRID_LABELS && !this.isCribDataProvider())
         {
            if(_loc1_ == "Turning")
            {
               _loc1_ = this.toolDef.toolParms.toolmaterial + " " + _loc1_;
            }
            _loc1_ = toHybridLabel(_loc1_,this.toolDef.toolParms.geometry);
         }
         return _loc1_;
      }
      
      public function set selectedLabel(param1:String) : void
      {
         var _loc7_:XML = null;
         var _loc8_:String = null;
         var _loc9_:XMLList = null;
         var _loc10_:XML = null;
         GWizUtils.LogErrorContext = "GWizToolMenu.set selectedLabel";
         var _loc2_:Boolean = false;
         var _loc3_:String = param1;
         if(false && GWizUtils.debug && param1.toLowerCase().indexOf("boring") >= 0)
         {
            log.debug("gotcha");
         }
         param1 = toPrimitiveLabel(param1.toLowerCase()).toLowerCase();
         GWizGraphicToolMenu.emGeometry = param1.toLowerCase().search("endmill") >= 0;
         if(this._selectedLabel.toLowerCase() == param1)
         {
            return;
         }
         if(param1.indexOf("threading") >= 0)
         {
            param1 = "turning";
         }
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 1;
         while(_loc4_ <= _loc6_)
         {
            for each(_loc7_ in this.theMenuXML)
            {
               _loc9_ = _loc7_.children();
               for each(_loc10_ in _loc9_)
               {
                  _loc8_ = (_loc8_ = String(_loc10_.@tool).toLowerCase()).replace(" milling","");
                  if(_loc4_ == _loc5_)
                  {
                     if(param1 == _loc8_)
                     {
                        this._selectedLabel = this.cleanLabel(_loc10_.@tool);
                        this._selectedIndex = _loc10_.@selectedIndex;
                        _loc2_ = true;
                        break;
                     }
                  }
                  else if(_loc4_ == _loc6_)
                  {
                     if(param1.indexOf(_loc8_) >= 0)
                     {
                        this._selectedLabel = this.cleanLabel(_loc10_.@tool);
                        this._selectedIndex = _loc10_.@selectedIndex;
                        _loc2_ = true;
                        break;
                     }
                  }
               }
               if(_loc2_)
               {
                  break;
               }
               _loc8_ = String(_loc7_.@tool).toLowerCase();
               if(_loc4_ == _loc5_)
               {
                  if(param1 == _loc8_)
                  {
                     this._selectedLabel = this.cleanLabel(_loc7_.@tool);
                     this._selectedIndex = _loc7_.@selectedIndex;
                     _loc2_ = true;
                     break;
                  }
               }
               else if(_loc4_ == _loc6_)
               {
                  if(param1.indexOf(_loc8_) >= 0)
                  {
                     this._selectedLabel = this.cleanLabel(_loc7_.@tool);
                     this._selectedIndex = _loc7_.@selectedIndex;
                     _loc2_ = true;
                     break;
                  }
               }
               if(_loc2_)
               {
                  break;
               }
            }
            if(_loc2_)
            {
               break;
            }
            _loc4_++;
         }
         if(!_loc2_)
         {
            this.selectedIndex = 0;
         }
         if(this._selectedLabel == "Turning")
         {
            if(param1.indexOf("hss") >= 0)
            {
               this._selectedLabel = "HSS Turning";
            }
            else
            {
               this._selectedLabel = "Carbide Turning";
            }
         }
         this.Text.text = this._selectedLabel;
         this.onChange();
      }
      
      public function get dataProvider() : Array
      {
         GWizUtils.LogErrorContext = "GWizToolMenu.get dataProvider";
         return this._dataProvider;
      }
      
      public function set dataProvider(param1:Array) : void
      {
         var _loc2_:Array = null;
         var _loc3_:XMLList = null;
         var _loc4_:int = 0;
         var _loc5_:XML = null;
         GWizUtils.LogErrorContext = "GWizToolMenu.set dataProvider";
         this._dataProvider = param1;
         this.selectFromCrib = false;
         if(param1 == GWizToolData.MillToolsList)
         {
            this.changeMenuXML(MillToolMenuXML);
         }
         else if(param1)
         {
            this.selectFromCrib = true;
            _loc2_ = param1 as Array;
            _loc3_ = new XMLList();
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               _loc5_ = new XML();
               _loc5_ = <menuitem label="{_loc2_[_loc4_]}"/>;
               _loc3_ += _loc5_;
               _loc4_++;
            }
            this.changeMenuXML(_loc3_);
         }
      }
      
      public function isCribDataProvider() : Boolean
      {
         GWizUtils.LogErrorContext = "GWizToolMenu.isCribDataProvider";
         var _loc1_:* = false;
         if(this.cribTbl)
         {
            _loc1_ = this.cribTbl.selectedIndex > 0;
         }
         else
         {
            _loc1_ = Boolean(this._dataProvider != GWizToolData.LatheToolsList && this._dataProvider != GWizToolData.MillToolsList);
         }
         return _loc1_;
      }
      
      private function onChange() : void
      {
         if(this.changeHandler != null)
         {
            this.changeHandler();
         }
         GWizSettings.toolSelection = this.selectedIndex;
         this.sendUpTheEvent(FlexEvent.VALUE_COMMIT);
      }
      
      public function syncPopUp() : void
      {
         if(GWizToolMenuPopup.isActive)
         {
            this.resetGUID();
            tmPopup.setToolParms(this.toolDef,this.theMenuXML,this.cribTbl.selectedIndex,this.selectedIndex);
         }
      }
      
      public function setDataProviderByCurrMachType() : void
      {
         this.changeMenuXML(MillToolMenuXML);
      }
      
      private function stdToolPopup() : ScrollableMenu
      {
         var _loc1_:ScrollableMenu = null;
         if(this.theMenuXML != MillToolMenuXML)
         {
            this.changeMenuXML(MillToolMenuXML);
         }
         _loc1_ = ScrollableMenu.createMenu(this,this.theMenuXML,false);
         _loc1_.labelField = "@label";
         _loc1_.verticalScrollPolicy = ScrollPolicy.AUTO;
         _loc1_.maxHeight = 500;
         _loc1_.addEventListener(MenuEvent.ITEM_CLICK,this.menuHandler);
         return _loc1_;
      }
      
      private function menuHandler(param1:MenuEvent) : void
      {
         GWizUtils.LogErrorContext = "GWizToolMenu.menuHandler";
         this.setMenuPick(this.cleanLabel(param1.item.@tool),param1.item.@selectedIndex);
      }
      
      public function setMenuPick(param1:String, param2:int, param3:String = "") : void
      {
         if(param2 < 0)
         {
            this.tMenuShowing = false;
            return;
         }
         if(param3 != "")
         {
            this.setGuid(param3);
         }
         else
         {
            this._selectedLabel = param1;
            this.selectedIndex = param2;
            this.resetGUID();
         }
         this.Text.text = this.selectedLabel;
         this.tMenuShowing = false;
         if(this.tMenu)
         {
            this.tMenu.removeEventListener(MenuEvent.ITEM_CLICK,this.menuHandler);
         }
         this.sendUpTheEvent(FlexEvent.VALUE_COMMIT);
      }
      
      private function sendUpTheEvent(param1:String) : void
      {
         GWizUtils.LogErrorContext = "GWizToolMenu.sendUpTheEvent";
         var _loc2_:FlexEvent = new FlexEvent(param1);
         this.dispatchEvent(_loc2_);
      }
      
      private function cleanLabel(param1:String) : String
      {
         if(param1.indexOf("Milling") >= 0)
         {
            param1 = param1.replace(" Milling","");
         }
         return param1;
      }
      
      private function debugToolMenuVC() : void
      {
      }
      
      public function showToolMenu2() : void
      {
         var _loc1_:Boolean = true;
         var _loc2_:int = 0;
         if(!GWizCribToolEditor.ignoreLockForToolCrib && this.cribTbl)
         {
            _loc2_ = Math.max(0,this.cribTbl.selectedIndex);
         }
         if(_loc2_ <= 0 && !GWizAbstractPrefs.isOEM)
         {
            tmPopup = GWizToolMenuPopup.toolMenuPopUp(DisplayObject(this.parentApplication),this.setMenuPick,this.changeMenuXML,this.vcHandler);
            tmPopup.setToolParms(this.toolDef,this.theMenuXML,_loc2_,this.selectedIndex);
         }
         else
         {
            this.showToolMenu(true);
         }
      }
      
      private function showToolMenu(param1:Boolean) : void
      {
         GWizUtils.LogErrorContext = "GWizToolMenu.showToolMenu";
         GATracker.logPageView("Feeds/Speeds/ToolDropdown","Feeds/Speeds/ToolDropdown");
         if(this.changeHandler != null)
         {
            this.changeHandler();
         }
         var _loc2_:Point = new Point();
         _loc2_.x = this.Text.x;
         _loc2_.y = this.Text.y + this.Text.height;
         _loc2_ = this.Text.localToGlobal(_loc2_);
         if(!this.tMenuShowing)
         {
            if(param1)
            {
               GATracker.logPageView("Feeds/Speeds/CribTool","Feeds/Speeds/CribTool");
               GWizDebugUtils.timeIt("Tool pick button pressed:");
               GWizToolMenuCrib2.cribMenuPopUp(DisplayObject(this.parentApplication),this.cribTbl.selectedItem.tabname,this.setMenuPick);
            }
            else
            {
               GATracker.logPageView("Feeds/Speeds/GenericTool","Feeds/Speeds/GenericTool");
               this.tMenu = this.stdToolPopup();
               this.tMenu.show(_loc2_.x,_loc2_.y);
            }
            this.tMenuShowing = true;
         }
         else
         {
            if(!param1)
            {
               this.tMenu.removeEventListener(MenuEvent.ITEM_CLICK,this.menuHandler);
               this.tMenu = null;
            }
            this.tMenuShowing = false;
         }
      }
      
      private function _GWizToolMenu_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.editable = false;
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("click",this.__Text_click);
         _loc1_.addEventListener("valueCommit",this.__Text_valueCommit);
         _loc1_.id = "Text";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Text = _loc1_;
         BindingManager.executeBindings(this,"Text",this.Text);
         return _loc1_;
      }
      
      public function __Text_click(param1:MouseEvent) : void
      {
         this.showToolMenu2();
      }
      
      public function __Text_valueCommit(param1:FlexEvent) : void
      {
         this.debugToolMenuVC();
      }
      
      private function _GWizToolMenu_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentHeight = 100;
         _loc1_.setStyle("skinClass",ComboBoxButtonSkin);
         _loc1_.addEventListener("click",this.__tPop_click);
         _loc1_.id = "tPop";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tPop = _loc1_;
         BindingManager.executeBindings(this,"tPop",this.tPop);
         return _loc1_;
      }
      
      public function __tPop_click(param1:MouseEvent) : void
      {
         this.showToolMenu2();
      }
      
      public function ___GWizToolMenu_HGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      [Bindable(event="propertyChange")]
      public function get Text() : TextInput
      {
         return this._2603341Text;
      }
      
      public function set Text(param1:TextInput) : void
      {
         var _loc2_:Object = this._2603341Text;
         if(_loc2_ !== param1)
         {
            this._2603341Text = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Text",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tPop() : Button
      {
         return this._3536189tPop;
      }
      
      public function set tPop(param1:Button) : void
      {
         var _loc2_:Object = this._3536189tPop;
         if(_loc2_ !== param1)
         {
            this._3536189tPop = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tPop",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cribTbl() : DropDownList
      {
         return this._1032247510cribTbl;
      }
      
      public function set cribTbl(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1032247510cribTbl;
         if(_loc2_ !== param1)
         {
            this._1032247510cribTbl = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cribTbl",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get inFeedsSpeedsApp() : Boolean
      {
         return this._41233125inFeedsSpeedsApp;
      }
      
      public function set inFeedsSpeedsApp(param1:Boolean) : void
      {
         var _loc2_:Object = this._41233125inFeedsSpeedsApp;
         if(_loc2_ !== param1)
         {
            this._41233125inFeedsSpeedsApp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"inFeedsSpeedsApp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get selectFromCrib() : Boolean
      {
         return this._292864594selectFromCrib;
      }
      
      private function set selectFromCrib(param1:Boolean) : void
      {
         var _loc2_:Object = this._292864594selectFromCrib;
         if(_loc2_ !== param1)
         {
            this._292864594selectFromCrib = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"selectFromCrib",_loc2_,param1));
            }
         }
      }
   }
}
