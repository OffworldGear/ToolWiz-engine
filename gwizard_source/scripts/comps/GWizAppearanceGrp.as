package comps
{
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import machines.GWizMachProfile;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import skins.GWizStylePalette;
   import spark.components.Button;
   import spark.components.ButtonBar;
   import spark.components.CheckBox;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.components.TextInput;
   import spark.components.ToggleButton;
   import spark.components.VGroup;
   import spark.events.IndexChangeEvent;
   import spark.layouts.HorizontalLayout;
   import utils.ColorPalette;
   import utils.FontSizeManager;
   
   use namespace mx_internal;
   
   public class GWizAppearanceGrp extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizAppearanceGrp");
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _288714233AlwaysOnTop:CheckBox;
      
      private var _1805473709DarkMood:RadioButton;
      
      private var _1604818150LightenUp:RadioButton;
      
      private var _1655955243OriginalFlava:RadioButton;
      
      private var _1601592413PowerUserBar:ButtonBar;
      
      private var _1601587083PowerUserGrp:GWizForePanel;
      
      private var _1173571196ThemeGrp:RadioButtonGroup;
      
      public var _GWizAppearanceGrp_Label1:Label;
      
      private var _680954346fontGrp:HGroup;
      
      private var _1687620514fontManager:ButtonBar;
      
      private var _1193906020impMetric:GWizImperialMetric;
      
      private var _338668849lockBtn:Button;
      
      private var _338673594lockGrp:HGroup;
      
      private var _1097453690lockID:TextInput;
      
      private var _200614670lockIDLabel:Label;
      
      private var _1720564310overallVGroup:VGroup;
      
      private var _1108927068themeGrp:HGroup;
      
      private var _1091963704themeSelector:GWizForePanel;
      
      private var _616918724topLineGrp:HGroup;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _454770372unitsText:String = "";
      
      private var _513770495powerUserState:Boolean = true;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizAppearanceGrp()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizAppearanceGrp_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizAppearanceGrpWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizAppearanceGrp[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.gap = 0;
         this.mxmlContent = [this._GWizAppearanceGrp_Label1_i(),this._GWizAppearanceGrp_VGroup2_i(),this._GWizAppearanceGrp_Spacer1_c()];
         this._GWizAppearanceGrp_RadioButtonGroup1_i();
         this.addEventListener("creationComplete",this.___GWizAppearanceGrp_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function changeFontSize() : void
      {
         switch(GWizMachProfile.currMachProfile.Units.fontManager.selectedIndex)
         {
            case 1:
               GWizSettings.fontManager.fontSize = FontSizeManager.MEDIUM_FONT;
               break;
            case 2:
               GWizSettings.fontManager.fontSize = FontSizeManager.LARGE_FONT;
               break;
            default:
               GWizSettings.fontManager.fontSize = FontSizeManager.SMALL_FONT;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizAppearanceGrp._watcherSetupUtil = param1;
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
         if(GWizSettings.gotPreferences)
         {
            GWizAbstractPrefs.powerUserCC.addFunction("GWizAppearanceGrp",this.powerUserChanged,false);
            this.powerUserChange(GWizSettings.prefs.powerUser);
            if(GWizAbstractPrefs.isOEM)
            {
               this.powerUserChange(false);
               this.PowerUserGrp.visible = false;
               GWizSettings.fontManager.fontSize = FontSizeManager.LARGE_FONT;
            }
            this.fontManager.selectedIndex = GWizSettings.fontManager.fontSize < FontSizeManager.MEDIUM_FONT ? 0 : (GWizSettings.fontManager.fontSize > FontSizeManager.MEDIUM_FONT ? 2 : 1);
            switch(GWizStylePalette.currTheme)
            {
               case GWizStylePalette.DARK_MOOD:
                  this.DarkMood.selected = true;
                  break;
               case GWizStylePalette.LIGHTEN_UP:
                  this.LightenUp.selected = true;
                  break;
               default:
                  this.OriginalFlava.selected = true;
            }
            this.AlwaysOnTop.selected = GWizSettings.prefs.docWinStayOnTop;
            if(GWizSettings.loginBar.appLongNameParm != "G-Wizard Machinist\'s Calculator")
            {
               this.topLineGrp.removeElement(this.PowerUserGrp);
            }
            this.callLater(this.lateCC);
         }
         else
         {
            this.callLater(this.onCC);
         }
      }
      
      private function lateCC() : void
      {
         if(GWizAbstractPrefs.isOEM)
         {
            this.LightenUp.selected = true;
         }
      }
      
      private function initFontButtons() : void
      {
         ToggleButton(this.fontManager.dataGroup.getElementAt(0)).setStyle("fontSize",FontSizeManager.SMALL_FONT);
         ToggleButton(this.fontManager.dataGroup.getElementAt(1)).setStyle("fontSize",FontSizeManager.MEDIUM_FONT);
         ToggleButton(this.fontManager.dataGroup.getElementAt(2)).setStyle("fontSize",FontSizeManager.LARGE_FONT);
      }
      
      private function themeChange(param1:String) : void
      {
         GWizStylePalette.currTheme = param1;
         GWizStylePalette.onThemeChange();
      }
      
      private function alwaysOnTopChange() : void
      {
         GWizSettings.prefs.docWinStayOnTop = this.AlwaysOnTop.selected;
         GWizSettings.docWindow.alwaysInFront = GWizSettings.prefs.docWinStayOnTop;
      }
      
      private function powerUserChange(param1:Boolean) : void
      {
         GWizSettings.prefs.powerUser = param1;
         if(param1)
         {
            this.PowerUserBar.selectedIndex = 1;
         }
         else
         {
            this.PowerUserBar.selectedIndex = 0;
         }
         GWizAbstractPrefs.powerUserCC.callChain(null);
      }
      
      private function powerUserChange2(param1:MouseEvent) : void
      {
         var _loc2_:String = this.PowerUserBar.selectedItem;
         this.powerUserChange(_loc2_ != "Easy");
      }
      
      private function powerUserChanged(param1:Object = null) : Boolean
      {
         if(GWizSettings.prefs.powerUser != this.powerUserState)
         {
            if(GWizSettings.prefs.powerUser)
            {
               this.overallVGroup.addElementAt(this.themeGrp,1);
            }
            else
            {
               this.overallVGroup.removeElement(this.themeGrp);
            }
            this.powerUserState = GWizSettings.prefs.powerUser;
         }
         return true;
      }
      
      private function _GWizAppearanceGrp_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.addEventListener("change",this.__ThemeGrp_change);
         _loc1_.initialized(this,"ThemeGrp");
         this.ThemeGrp = _loc1_;
         BindingManager.executeBindings(this,"ThemeGrp",this.ThemeGrp);
         return _loc1_;
      }
      
      public function __ThemeGrp_change(param1:Event) : void
      {
         this.themeChange(this.ThemeGrp.selection.label);
      }
      
      private function _GWizAppearanceGrp_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Appearance";
         _loc1_.styleName = "fontSizeDelta4";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("paddingBottom",5);
         _loc1_.setStyle("paddingTop",5);
         _loc1_.setStyle("paddingLeft",5);
         _loc1_.id = "_GWizAppearanceGrp_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizAppearanceGrp_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizAppearanceGrp_Label1",this._GWizAppearanceGrp_Label1);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_VGroup2_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.gap = 0;
         _loc1_.mxmlContent = [this._GWizAppearanceGrp_HGroup1_c(),this._GWizAppearanceGrp_HGroup3_i()];
         _loc1_.id = "overallVGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.overallVGroup = _loc1_;
         BindingManager.executeBindings(this,"overallVGroup",this.overallVGroup);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.gap = 1;
         _loc1_.mxmlContent = [this._GWizAppearanceGrp_GWizForePanel1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_GWizForePanel1_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizAppearanceGrp_Array4_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_Array4_c() : Array
      {
         return [this._GWizAppearanceGrp_HGroup2_i()];
      }
      
      private function _GWizAppearanceGrp_HGroup2_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "baseline";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizAppearanceGrp_GWizForePanel2_c(),this._GWizAppearanceGrp_GWizForePanel3_c(),this._GWizAppearanceGrp_GWizForePanel4_i()];
         _loc1_.id = "topLineGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.topLineGrp = _loc1_;
         BindingManager.executeBindings(this,"topLineGrp",this.topLineGrp);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_GWizForePanel2_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizAppearanceGrp_Array6_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_Array6_c() : Array
      {
         return [this._GWizAppearanceGrp_GWizImperialMetric1_i()];
      }
      
      private function _GWizAppearanceGrp_GWizImperialMetric1_i() : GWizImperialMetric
      {
         var _loc1_:GWizImperialMetric = new GWizImperialMetric();
         _loc1_.id = "impMetric";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.impMetric = _loc1_;
         BindingManager.executeBindings(this,"impMetric",this.impMetric);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_GWizForePanel3_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizAppearanceGrp_Array7_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_Array7_c() : Array
      {
         return [this._GWizAppearanceGrp_CheckBox1_i()];
      }
      
      private function _GWizAppearanceGrp_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Always on Top";
         _loc1_.toolTip = "If selected, window will always be on top of other windows.";
         _loc1_.addEventListener("click",this.__AlwaysOnTop_click);
         _loc1_.id = "AlwaysOnTop";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.AlwaysOnTop = _loc1_;
         BindingManager.executeBindings(this,"AlwaysOnTop",this.AlwaysOnTop);
         return _loc1_;
      }
      
      public function __AlwaysOnTop_click(param1:MouseEvent) : void
      {
         this.alwaysOnTopChange();
      }
      
      private function _GWizAppearanceGrp_GWizForePanel4_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizAppearanceGrp_Array8_c);
         _loc1_.id = "PowerUserGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PowerUserGrp = _loc1_;
         BindingManager.executeBindings(this,"PowerUserGrp",this.PowerUserGrp);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_Array8_c() : Array
      {
         return [this._GWizAppearanceGrp_ButtonBar1_i()];
      }
      
      private function _GWizAppearanceGrp_ButtonBar1_i() : ButtonBar
      {
         var _loc1_:ButtonBar = new ButtonBar();
         _loc1_.requireSelection = true;
         _loc1_.toolTip = "Easy = Radically Simplify.  Power = Show All Our Features.";
         _loc1_.dataProvider = this._GWizAppearanceGrp_ArrayCollection1_c();
         _loc1_.addEventListener("click",this.__PowerUserBar_click);
         _loc1_.id = "PowerUserBar";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PowerUserBar = _loc1_;
         BindingManager.executeBindings(this,"PowerUserBar",this.PowerUserBar);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_ArrayCollection1_c() : ArrayCollection
      {
         var _loc1_:ArrayCollection = new ArrayCollection();
         _loc1_.source = ["Easy","Powerful"];
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      public function __PowerUserBar_click(param1:MouseEvent) : void
      {
         this.powerUserChange2(param1);
      }
      
      private function _GWizAppearanceGrp_HGroup3_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.gap = 1;
         _loc1_.mxmlContent = [this._GWizAppearanceGrp_GWizForePanel5_i(),this._GWizAppearanceGrp_GWizForePanel6_c(),this._GWizAppearanceGrp_GWizForePanel7_c()];
         _loc1_.id = "themeGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.themeGrp = _loc1_;
         BindingManager.executeBindings(this,"themeGrp",this.themeGrp);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_GWizForePanel5_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizAppearanceGrp_Array11_c);
         _loc1_.id = "themeSelector";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.themeSelector = _loc1_;
         BindingManager.executeBindings(this,"themeSelector",this.themeSelector);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_Array11_c() : Array
      {
         return [this._GWizAppearanceGrp_HGroup4_c()];
      }
      
      private function _GWizAppearanceGrp_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizAppearanceGrp_Label2_c(),this._GWizAppearanceGrp_RadioButton1_i(),this._GWizAppearanceGrp_RadioButton2_i(),this._GWizAppearanceGrp_RadioButton3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Theme";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Original Flava";
         _loc1_.id = "OriginalFlava";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.OriginalFlava = _loc1_;
         BindingManager.executeBindings(this,"OriginalFlava",this.OriginalFlava);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Lighten Up";
         _loc1_.id = "LightenUp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.LightenUp = _loc1_;
         BindingManager.executeBindings(this,"LightenUp",this.LightenUp);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_RadioButton3_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Dark Mood";
         _loc1_.id = "DarkMood";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.DarkMood = _loc1_;
         BindingManager.executeBindings(this,"DarkMood",this.DarkMood);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_GWizForePanel6_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizAppearanceGrp_Array13_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_Array13_c() : Array
      {
         return [this._GWizAppearanceGrp_HGroup5_i()];
      }
      
      private function _GWizAppearanceGrp_HGroup5_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizAppearanceGrp_Label3_c(),this._GWizAppearanceGrp_ButtonBar2_i()];
         _loc1_.id = "fontGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fontGrp = _loc1_;
         BindingManager.executeBindings(this,"fontGrp",this.fontGrp);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Font Size";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_ButtonBar2_i() : ButtonBar
      {
         var _loc1_:ButtonBar = new ButtonBar();
         _loc1_.layout = this._GWizAppearanceGrp_HorizontalLayout1_c();
         _loc1_.dataProvider = this._GWizAppearanceGrp_ArrayCollection2_c();
         _loc1_.addEventListener("creationComplete",this.__fontManager_creationComplete);
         _loc1_.addEventListener("change",this.__fontManager_change);
         _loc1_.id = "fontManager";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fontManager = _loc1_;
         BindingManager.executeBindings(this,"fontManager",this.fontManager);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_HorizontalLayout1_c() : HorizontalLayout
      {
         var _loc1_:HorizontalLayout = new HorizontalLayout();
         _loc1_.columnWidth = 15;
         _loc1_.gap = -1;
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_ArrayCollection2_c() : ArrayCollection
      {
         var _loc1_:ArrayCollection = new ArrayCollection();
         _loc1_.source = ["A","A","A"];
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      public function __fontManager_creationComplete(param1:FlexEvent) : void
      {
         this.initFontButtons();
      }
      
      public function __fontManager_change(param1:IndexChangeEvent) : void
      {
         changeFontSize();
      }
      
      private function _GWizAppearanceGrp_GWizForePanel7_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizAppearanceGrp_Array16_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_Array16_c() : Array
      {
         return [this._GWizAppearanceGrp_HGroup6_i()];
      }
      
      private function _GWizAppearanceGrp_HGroup6_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizAppearanceGrp_Label4_i(),this._GWizAppearanceGrp_TextInput1_i(),this._GWizAppearanceGrp_Button1_i()];
         _loc1_.id = "lockGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.lockGrp = _loc1_;
         BindingManager.executeBindings(this,"lockGrp",this.lockGrp);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Lock ID";
         _loc1_.id = "lockIDLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.lockIDLabel = _loc1_;
         BindingManager.executeBindings(this,"lockIDLabel",this.lockIDLabel);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.prompt = "Lock ID";
         _loc1_.toolTip = "ID code to lock or unlock Setup";
         _loc1_.percentWidth = 100;
         _loc1_.id = "lockID";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.lockID = _loc1_;
         BindingManager.executeBindings(this,"lockID",this.lockID);
         return _loc1_;
      }
      
      private function _GWizAppearanceGrp_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Lock";
         _loc1_.toolTip = "Enter your lock ID and click Lock to lock the Setup";
         _loc1_.addEventListener("click",this.__lockBtn_click);
         _loc1_.id = "lockBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.lockBtn = _loc1_;
         BindingManager.executeBindings(this,"lockBtn",this.lockBtn);
         return _loc1_;
      }
      
      public function __lockBtn_click(param1:MouseEvent) : void
      {
         GWizMachProfile.doLock();
      }
      
      private function _GWizAppearanceGrp_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizAppearanceGrp_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizAppearanceGrp_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.gray3;
         },function(param1:uint):void
         {
            _GWizAppearanceGrp_Label1.setStyle("backgroundColor",param1);
         },"_GWizAppearanceGrp_Label1.backgroundColor");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.gray5;
         },function(param1:uint):void
         {
            _GWizAppearanceGrp_Label1.setStyle("color",param1);
         },"_GWizAppearanceGrp_Label1.color");
         result[2] = new Binding(this,function():String
         {
            var _loc1_:* = this.unitsText;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"impMetric.unitsText");
         result[3] = new Binding(this,function():Boolean
         {
            return powerUserState;
         },null,"AlwaysOnTop.visible");
         result[4] = new Binding(this,null,null,"OriginalFlava.group","ThemeGrp");
         result[5] = new Binding(this,null,null,"LightenUp.group","ThemeGrp");
         result[6] = new Binding(this,null,null,"DarkMood.group","ThemeGrp");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get AlwaysOnTop() : CheckBox
      {
         return this._288714233AlwaysOnTop;
      }
      
      public function set AlwaysOnTop(param1:CheckBox) : void
      {
         var _loc2_:Object = this._288714233AlwaysOnTop;
         if(_loc2_ !== param1)
         {
            this._288714233AlwaysOnTop = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"AlwaysOnTop",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get DarkMood() : RadioButton
      {
         return this._1805473709DarkMood;
      }
      
      public function set DarkMood(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1805473709DarkMood;
         if(_loc2_ !== param1)
         {
            this._1805473709DarkMood = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"DarkMood",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get LightenUp() : RadioButton
      {
         return this._1604818150LightenUp;
      }
      
      public function set LightenUp(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1604818150LightenUp;
         if(_loc2_ !== param1)
         {
            this._1604818150LightenUp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"LightenUp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get OriginalFlava() : RadioButton
      {
         return this._1655955243OriginalFlava;
      }
      
      public function set OriginalFlava(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1655955243OriginalFlava;
         if(_loc2_ !== param1)
         {
            this._1655955243OriginalFlava = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"OriginalFlava",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PowerUserBar() : ButtonBar
      {
         return this._1601592413PowerUserBar;
      }
      
      public function set PowerUserBar(param1:ButtonBar) : void
      {
         var _loc2_:Object = this._1601592413PowerUserBar;
         if(_loc2_ !== param1)
         {
            this._1601592413PowerUserBar = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PowerUserBar",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PowerUserGrp() : GWizForePanel
      {
         return this._1601587083PowerUserGrp;
      }
      
      public function set PowerUserGrp(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._1601587083PowerUserGrp;
         if(_loc2_ !== param1)
         {
            this._1601587083PowerUserGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PowerUserGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ThemeGrp() : RadioButtonGroup
      {
         return this._1173571196ThemeGrp;
      }
      
      public function set ThemeGrp(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._1173571196ThemeGrp;
         if(_loc2_ !== param1)
         {
            this._1173571196ThemeGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ThemeGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fontGrp() : HGroup
      {
         return this._680954346fontGrp;
      }
      
      public function set fontGrp(param1:HGroup) : void
      {
         var _loc2_:Object = this._680954346fontGrp;
         if(_loc2_ !== param1)
         {
            this._680954346fontGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fontGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fontManager() : ButtonBar
      {
         return this._1687620514fontManager;
      }
      
      public function set fontManager(param1:ButtonBar) : void
      {
         var _loc2_:Object = this._1687620514fontManager;
         if(_loc2_ !== param1)
         {
            this._1687620514fontManager = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fontManager",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get impMetric() : GWizImperialMetric
      {
         return this._1193906020impMetric;
      }
      
      public function set impMetric(param1:GWizImperialMetric) : void
      {
         var _loc2_:Object = this._1193906020impMetric;
         if(_loc2_ !== param1)
         {
            this._1193906020impMetric = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"impMetric",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get lockBtn() : Button
      {
         return this._338668849lockBtn;
      }
      
      public function set lockBtn(param1:Button) : void
      {
         var _loc2_:Object = this._338668849lockBtn;
         if(_loc2_ !== param1)
         {
            this._338668849lockBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"lockBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get lockGrp() : HGroup
      {
         return this._338673594lockGrp;
      }
      
      public function set lockGrp(param1:HGroup) : void
      {
         var _loc2_:Object = this._338673594lockGrp;
         if(_loc2_ !== param1)
         {
            this._338673594lockGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"lockGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get lockID() : TextInput
      {
         return this._1097453690lockID;
      }
      
      public function set lockID(param1:TextInput) : void
      {
         var _loc2_:Object = this._1097453690lockID;
         if(_loc2_ !== param1)
         {
            this._1097453690lockID = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"lockID",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get lockIDLabel() : Label
      {
         return this._200614670lockIDLabel;
      }
      
      public function set lockIDLabel(param1:Label) : void
      {
         var _loc2_:Object = this._200614670lockIDLabel;
         if(_loc2_ !== param1)
         {
            this._200614670lockIDLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"lockIDLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get overallVGroup() : VGroup
      {
         return this._1720564310overallVGroup;
      }
      
      public function set overallVGroup(param1:VGroup) : void
      {
         var _loc2_:Object = this._1720564310overallVGroup;
         if(_loc2_ !== param1)
         {
            this._1720564310overallVGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"overallVGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get themeGrp() : HGroup
      {
         return this._1108927068themeGrp;
      }
      
      public function set themeGrp(param1:HGroup) : void
      {
         var _loc2_:Object = this._1108927068themeGrp;
         if(_loc2_ !== param1)
         {
            this._1108927068themeGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"themeGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get themeSelector() : GWizForePanel
      {
         return this._1091963704themeSelector;
      }
      
      public function set themeSelector(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._1091963704themeSelector;
         if(_loc2_ !== param1)
         {
            this._1091963704themeSelector = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"themeSelector",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get topLineGrp() : HGroup
      {
         return this._616918724topLineGrp;
      }
      
      public function set topLineGrp(param1:HGroup) : void
      {
         var _loc2_:Object = this._616918724topLineGrp;
         if(_loc2_ !== param1)
         {
            this._616918724topLineGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"topLineGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get unitsText() : String
      {
         return this._454770372unitsText;
      }
      
      public function set unitsText(param1:String) : void
      {
         var _loc2_:Object = this._454770372unitsText;
         if(_loc2_ !== param1)
         {
            this._454770372unitsText = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"unitsText",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get powerUserState() : Boolean
      {
         return this._513770495powerUserState;
      }
      
      private function set powerUserState(param1:Boolean) : void
      {
         var _loc2_:Object = this._513770495powerUserState;
         if(_loc2_ !== param1)
         {
            this._513770495powerUserState = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"powerUserState",_loc2_,param1));
            }
         }
      }
   }
}
