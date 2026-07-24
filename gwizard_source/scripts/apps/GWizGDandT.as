package apps
{
   import comps.GWizForePanel;
   import comps.GWizLinkImage;
   import comps.GWizLinkLabelURL;
   import configinfo.GWizAbstractPrefs;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.BorderContainer;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.Scroller;
   import spark.components.TextArea;
   import spark.components.VGroup;
   import spark.layouts.VerticalLayout;
   import utils.ColorPalette;
   
   use namespace mx_internal;
   
   public class GWizGDandT extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizGDandT");
      
      private static var urlTable:Object = new Object();
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1924613036Angularity:GWizLinkLabelURL;
      
      private var _1373162396AngularitySymbol:GWizLinkImage;
      
      private var _1573916542CircularRunout:GWizLinkLabelURL;
      
      private var _1273260218CircularRunoutSymbol:GWizLinkImage;
      
      private var _379749369CircularitySymbol:GWizLinkImage;
      
      private var _339876328CircularityVGroup:VGroup;
      
      private var _79200794Col2Widest:GWizLinkLabelURL;
      
      private var _395286188Concentricity:GWizLinkLabelURL;
      
      private var _164280476ConcentricitySymbol:GWizLinkImage;
      
      private var _124407435ConcentricityVGroup:VGroup;
      
      private var _1473455851Cylindricity:GWizLinkLabelURL;
      
      private var _1043688547CylindricitySymbol:GWizLinkImage;
      
      private var _1691322736Flatness:GWizLinkLabelURL;
      
      private var _1014830888FlatnessSymbol:GWizLinkImage;
      
      private var _1054703929FlatnessVGroup:VGroup;
      
      private var _495679616FormPanel:GWizForePanel;
      
      private var _1991933700Parallelism:GWizLinkLabelURL;
      
      private var _2042219084ParallelismSymbol:GWizLinkImage;
      
      private var _914279524Perpendicularity:GWizLinkLabelURL;
      
      private var _1784458468PerpendicularitySymbol:GWizLinkImage;
      
      private var _1744585427PerpendicularityVGroup:VGroup;
      
      private var _812449097Position:GWizLinkLabelURL;
      
      private var _1646298177PositionSymbol:GWizLinkImage;
      
      private var _1686171218PositionVGroup:VGroup;
      
      private var _1845319965ProfileLine:GWizLinkLabelURL;
      
      private var _647384811ProfileLineSymbol:GWizLinkImage;
      
      private var _610617060ProfileSurface:GWizLinkLabelURL;
      
      private var _711191964ProfileSurfaceSymbol:GWizLinkImage;
      
      private var _842887540RunoutVGroup:VGroup;
      
      private var _1998095247Straightness:GWizLinkLabelURL;
      
      private var _1920533865StraightnessSymbol:GWizLinkImage;
      
      private var _1862498012Symmetry:GWizLinkLabelURL;
      
      private var _174867348SymmetrySymbol:GWizLinkImage;
      
      private var _904515879TotalRunout:GWizLinkLabelURL;
      
      private var _48596577TotalRunoutSymbol:GWizLinkImage;
      
      public var _GWizGDandT_GWizForePanel2:GWizForePanel;
      
      public var _GWizGDandT_GWizForePanel3:GWizForePanel;
      
      public var _GWizGDandT_GWizForePanel4:GWizForePanel;
      
      public var _GWizGDandT_GWizForePanel5:GWizForePanel;
      
      public var _GWizGDandT_Label1:Label;
      
      public var _GWizGDandT_Label3:Label;
      
      public var _GWizGDandT_TextArea1:TextArea;
      
      public var _GWizGDandT_TextArea2:TextArea;
      
      public var _GWizGDandT_TextArea3:TextArea;
      
      public var _GWizGDandT_TextArea4:TextArea;
      
      public var _GWizGDandT_TextArea5:TextArea;
      
      public var _GWizGDandT_TextArea6:TextArea;
      
      private var _809612678contentGroup:VGroup;
      
      private var _542676939theScroller:Scroller;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private const SCALE_SYMBOLS:Number = 0.5;
      
      private var _embed_mxml_assets_Position_JPG_1774735060:Class;
      
      private var _embed_mxml_assets_Perpendicularity_JPG_353984926:Class;
      
      private var _embed_mxml_assets_Flatness_JPG_1585728750:Class;
      
      private var _embed_mxml_assets_Concentricity_JPG_194249396:Class;
      
      private var _embed_mxml_assets_Straightness_JPG_1558507148:Class;
      
      private var _embed_mxml_assets_LineProfile_JPG_1795581758:Class;
      
      private var _embed_mxml_assets_Circularity_JPG_1811284046:Class;
      
      private var _embed_mxml_assets_CircularRunout_JPG_1745841250:Class;
      
      private var _embed_mxml_assets_Angularity_JPG_1419058350:Class;
      
      private var _embed_mxml_assets_Parallelism_JPG_217840052:Class;
      
      private var _embed_mxml_assets_Symmetry_JPG_1044922642:Class;
      
      private var _embed_mxml_assets_SurfaceProfile_JPG_606563794:Class;
      
      private var _embed_mxml_assets_Cylindricity_JPG_1164239760:Class;
      
      private var _embed_mxml_assets_TotalRunout_JPG_187627618:Class;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizGDandT()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._embed_mxml_assets_Position_JPG_1774735060 = GWizGDandT__embed_mxml_assets_Position_JPG_1774735060;
         this._embed_mxml_assets_Perpendicularity_JPG_353984926 = GWizGDandT__embed_mxml_assets_Perpendicularity_JPG_353984926;
         this._embed_mxml_assets_Flatness_JPG_1585728750 = GWizGDandT__embed_mxml_assets_Flatness_JPG_1585728750;
         this._embed_mxml_assets_Concentricity_JPG_194249396 = GWizGDandT__embed_mxml_assets_Concentricity_JPG_194249396;
         this._embed_mxml_assets_Straightness_JPG_1558507148 = GWizGDandT__embed_mxml_assets_Straightness_JPG_1558507148;
         this._embed_mxml_assets_LineProfile_JPG_1795581758 = GWizGDandT__embed_mxml_assets_LineProfile_JPG_1795581758;
         this._embed_mxml_assets_Circularity_JPG_1811284046 = GWizGDandT__embed_mxml_assets_Circularity_JPG_1811284046;
         this._embed_mxml_assets_CircularRunout_JPG_1745841250 = GWizGDandT__embed_mxml_assets_CircularRunout_JPG_1745841250;
         this._embed_mxml_assets_Angularity_JPG_1419058350 = GWizGDandT__embed_mxml_assets_Angularity_JPG_1419058350;
         this._embed_mxml_assets_Parallelism_JPG_217840052 = GWizGDandT__embed_mxml_assets_Parallelism_JPG_217840052;
         this._embed_mxml_assets_Symmetry_JPG_1044922642 = GWizGDandT__embed_mxml_assets_Symmetry_JPG_1044922642;
         this._embed_mxml_assets_SurfaceProfile_JPG_606563794 = GWizGDandT__embed_mxml_assets_SurfaceProfile_JPG_606563794;
         this._embed_mxml_assets_Cylindricity_JPG_1164239760 = GWizGDandT__embed_mxml_assets_Cylindricity_JPG_1164239760;
         this._embed_mxml_assets_TotalRunout_JPG_187627618 = GWizGDandT__embed_mxml_assets_TotalRunout_JPG_187627618;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizGDandT_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_apps_GWizGDandTWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizGDandT[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.styleName = "fontSizeDelta-2";
         this.gap = 0;
         this.paddingLeft = 10;
         this.paddingRight = 10;
         this.paddingTop = 15;
         this.paddingBottom = 10;
         this.percentHeight = 100;
         this.percentWidth = 100;
         this.mxmlContent = [this._GWizGDandT_Label1_i(),this._GWizGDandT_Scroller1_i()];
         this.addEventListener("creationComplete",this.___GWizGDandT_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizGDandT._watcherSetupUtil = param1;
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
         if(GWizAbstractPrefs.GDTBasics)
         {
            urlTable["Flatness"] = "http://www.gdandtbasics.com/flatness/";
            urlTable["Straightness"] = "http://www.gdandtbasics.com/straightness/";
            urlTable["Circularity"] = "http://www.gdandtbasics.com/circularity/";
            urlTable["Cylindricity"] = "http://www.gdandtbasics.com/cylindricity/";
            urlTable["Perpendicularity"] = "http://www.gdandtbasics.com/perpendicularity/";
            urlTable["Parallelism"] = "http://www.gdandtbasics.com/parallelism/";
            urlTable["Angularity"] = "http://www.gdandtbasics.com/angularity/";
            urlTable["Position"] = "http://www.gdandtbasics.com/true-position/";
            urlTable["ProfileSurface"] = "http://www.gdandtbasics.com/profile-of-a-surface/";
            urlTable["ProfileLine"] = "http://www.gdandtbasics.com/profile-of-a-line/";
            urlTable["TotalRunout"] = "http://www.gdandtbasics.com/total-runout/";
            urlTable["CircularRunout"] = "http://www.gdandtbasics.com/runout/";
            urlTable["Concentricity"] = "http://www.gdandtbasics.com/concentricity/";
            urlTable["Symmetry"] = "http://www.gdandtbasics.com/symmetry/";
         }
         else
         {
            urlTable["Flatness"] = "https://www.cnccookbook.com/gdt-flatness-symbol-tolerance-measurement/";
            urlTable["Straightness"] = "https://www.cnccookbook.com/gdt-straightness-symbol-tolerance-measurement/";
            urlTable["Circularity"] = "https://www.cnccookbook.com/gdt-circularity-roundness-symbol-tolerance-measurement/";
            urlTable["Cylindricity"] = "https://www.cnccookbook.com/gdt-cylindricity-symbol-tolerance-measurement/";
            urlTable["Perpendicularity"] = "https://www.cnccookbook.com/gdt-perpendicularity-symbol-tolerance-measurement/";
            urlTable["Parallelism"] = "https://www.cnccookbook.com/gdt-parallelism-symbol-tolerance-measurement/";
            urlTable["Angularity"] = "https://www.cnccookbook.com/gdt-angularity-symbol-tolerance-measurement/";
            urlTable["Position"] = "https://www.cnccookbook.com/gdt-true-position/";
            urlTable["ProfileSurface"] = "https://www.cnccookbook.com/gdt-profile-surface-symbol-tolerance-measurement/";
            urlTable["ProfileLine"] = "https://www.cnccookbook.com/gdt-profile-line-symbol-tolerance-measurement/";
            urlTable["TotalRunout"] = "https://www.cnccookbook.com/gdt-total-runout-symbol-tolerance-measurement/";
            urlTable["CircularRunout"] = "https://www.cnccookbook.com/gdt-circular-runout-symbol-tolerance-measurement/";
            urlTable["Concentricity"] = "https://www.cnccookbook.com/gdt-concentricity-symbol-tolerance-measurement/";
            urlTable["Symmetry"] = "https://www.cnccookbook.com/gdt-symmetry-symbol-tolerance-measurement/";
         }
         this.Flatness.url = urlTable["Flatness"];
         this.FlatnessSymbol.url = urlTable["Flatness"];
         this.Straightness.url = urlTable["Straightness"];
         this.StraightnessSymbol.url = urlTable["Straightness"];
         this.Col2Widest.url = urlTable["Circularity"];
         this.CircularitySymbol.url = urlTable["Circularity"];
         this.Cylindricity.url = urlTable["Cylindricity"];
         this.CylindricitySymbol.url = urlTable["Cylindricity"];
         this.Perpendicularity.url = urlTable["Perpendicularity"];
         this.PerpendicularitySymbol.url = urlTable["Perpendicularity"];
         this.Parallelism.url = urlTable["Parallelism"];
         this.ParallelismSymbol.url = urlTable["Parallelism"];
         this.Angularity.url = urlTable["Angularity"];
         this.AngularitySymbol.url = urlTable["Angularity"];
         this.Position.url = urlTable["Position"];
         this.PositionSymbol.url = urlTable["Position"];
         this.ProfileSurface.url = urlTable["ProfileSurface"];
         this.ProfileSurfaceSymbol.url = urlTable["ProfileSurface"];
         this.ProfileLine.url = urlTable["ProfileLine"];
         this.ProfileLineSymbol.url = urlTable["ProfileLine"];
         this.TotalRunout.url = urlTable["TotalRunout"];
         this.TotalRunoutSymbol.url = urlTable["TotalRunout"];
         this.CircularRunout.url = urlTable["CircularRunout"];
         this.CircularRunoutSymbol.url = urlTable["CircularRunout"];
         this.Concentricity.url = urlTable["Concentricity"];
         this.ConcentricitySymbol.url = urlTable["Concentricity"];
         this.Symmetry.url = urlTable["Symmetry"];
         this.SymmetrySymbol.url = urlTable["Symmetry"];
      }
      
      private function _GWizGDandT_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Geometric Dimensioning and Tolerancing Reference";
         _loc1_.styleName = "fontSizeDelta4";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("paddingBottom",5);
         _loc1_.setStyle("paddingTop",5);
         _loc1_.setStyle("paddingLeft",5);
         _loc1_.id = "_GWizGDandT_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGDandT_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGDandT_Label1",this._GWizGDandT_Label1);
         return _loc1_;
      }
      
      private function _GWizGDandT_Scroller1_i() : Scroller
      {
         var _loc1_:Scroller = new Scroller();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.viewport = this._GWizGDandT_VGroup2_i();
         _loc1_.id = "theScroller";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theScroller = _loc1_;
         BindingManager.executeBindings(this,"theScroller",this.theScroller);
         return _loc1_;
      }
      
      private function _GWizGDandT_VGroup2_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.clipAndEnableScrolling = true;
         _loc1_.minHeight = 400;
         _loc1_.mxmlContent = [this._GWizGDandT_BorderContainer1_c()];
         _loc1_.id = "contentGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.contentGroup = _loc1_;
         BindingManager.executeBindings(this,"contentGroup",this.contentGroup);
         return _loc1_;
      }
      
      private function _GWizGDandT_BorderContainer1_c() : BorderContainer
      {
         var _loc1_:BorderContainer = new BorderContainer();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizGDandT_Array3_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_Array3_c() : Array
      {
         return [this._GWizGDandT_VGroup3_c()];
      }
      
      private function _GWizGDandT_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizGDandT_HGroup1_c(),this._GWizGDandT_GWizForePanel1_i(),this._GWizGDandT_GWizForePanel2_i(),this._GWizGDandT_GWizForePanel3_i(),this._GWizGDandT_GWizForePanel4_i(),this._GWizGDandT_GWizForePanel5_i()];
         _loc1_.setStyle("fontSize",12);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingTop = 8;
         _loc1_.mxmlContent = [this._GWizGDandT_Label2_c(),this._GWizGDandT_Label3_i(),this._GWizGDandT_Label4_c(),this._GWizGDandT_Label5_c()];
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "    Control Type";
         _loc1_.width = 140;
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "    Characteristic";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizGDandT_Label3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGDandT_Label3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGDandT_Label3",this._GWizGDandT_Label3);
         return _loc1_;
      }
      
      private function _GWizGDandT_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "    Symbol";
         _loc1_.width = 100;
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "    Notes";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizForePanel1_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Form";
         _loc1_.labelWidth = 140;
         _loc1_.layout = this._GWizGDandT_VerticalLayout1_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizGDandT_Array6_c);
         _loc1_.id = "FormPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FormPanel = _loc1_;
         BindingManager.executeBindings(this,"FormPanel",this.FormPanel);
         return _loc1_;
      }
      
      private function _GWizGDandT_VerticalLayout1_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizGDandT_Array6_c() : Array
      {
         return [this._GWizGDandT_HGroup2_c(),this._GWizGDandT_HGroup5_c()];
      }
      
      private function _GWizGDandT_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_VGroup4_i(),this._GWizGDandT_TextArea1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_VGroup4_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.mxmlContent = [this._GWizGDandT_HGroup3_c(),this._GWizGDandT_HGroup4_c()];
         _loc1_.id = "FlatnessVGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FlatnessVGroup = _loc1_;
         BindingManager.executeBindings(this,"FlatnessVGroup",this.FlatnessVGroup);
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_GWizLinkLabelURL1_i(),this._GWizGDandT_GWizLinkImage1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkLabelURL1_i() : GWizLinkLabelURL
      {
         var _loc1_:GWizLinkLabelURL = new GWizLinkLabelURL();
         _loc1_.text = "Flatness";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Flatness";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Flatness = _loc1_;
         BindingManager.executeBindings(this,"Flatness",this.Flatness);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkImage1_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml_assets_Flatness_JPG_1585728750;
         _loc1_.id = "FlatnessSymbol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FlatnessSymbol = _loc1_;
         BindingManager.executeBindings(this,"FlatnessSymbol",this.FlatnessSymbol);
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_GWizLinkLabelURL2_i(),this._GWizGDandT_GWizLinkImage2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkLabelURL2_i() : GWizLinkLabelURL
      {
         var _loc1_:GWizLinkLabelURL = new GWizLinkLabelURL();
         _loc1_.text = "Straightness";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Straightness";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Straightness = _loc1_;
         BindingManager.executeBindings(this,"Straightness",this.Straightness);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkImage2_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml_assets_Straightness_JPG_1558507148;
         _loc1_.id = "StraightnessSymbol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.StraightnessSymbol = _loc1_;
         BindingManager.executeBindings(this,"StraightnessSymbol",this.StraightnessSymbol);
         return _loc1_;
      }
      
      private function _GWizGDandT_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.editable = false;
         _loc1_.text = "Controls form (shape) of size and non-size features.  Datum reference is not allowed.";
         _loc1_.percentWidth = 100;
         _loc1_.id = "_GWizGDandT_TextArea1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGDandT_TextArea1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGDandT_TextArea1",this._GWizGDandT_TextArea1);
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_VGroup5_i(),this._GWizGDandT_TextArea2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_VGroup5_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.mxmlContent = [this._GWizGDandT_HGroup6_c(),this._GWizGDandT_HGroup7_c()];
         _loc1_.id = "CircularityVGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CircularityVGroup = _loc1_;
         BindingManager.executeBindings(this,"CircularityVGroup",this.CircularityVGroup);
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_GWizLinkLabelURL3_i(),this._GWizGDandT_GWizLinkImage3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkLabelURL3_i() : GWizLinkLabelURL
      {
         var _loc1_:GWizLinkLabelURL = new GWizLinkLabelURL();
         _loc1_.text = "Circularity (Roundness)";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Col2Widest";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Col2Widest = _loc1_;
         BindingManager.executeBindings(this,"Col2Widest",this.Col2Widest);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkImage3_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml_assets_Circularity_JPG_1811284046;
         _loc1_.id = "CircularitySymbol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CircularitySymbol = _loc1_;
         BindingManager.executeBindings(this,"CircularitySymbol",this.CircularitySymbol);
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup7_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_GWizLinkLabelURL4_i(),this._GWizGDandT_GWizLinkImage4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkLabelURL4_i() : GWizLinkLabelURL
      {
         var _loc1_:GWizLinkLabelURL = new GWizLinkLabelURL();
         _loc1_.text = "Cylindricity";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Cylindricity";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Cylindricity = _loc1_;
         BindingManager.executeBindings(this,"Cylindricity",this.Cylindricity);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkImage4_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml_assets_Cylindricity_JPG_1164239760;
         _loc1_.id = "CylindricitySymbol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CylindricitySymbol = _loc1_;
         BindingManager.executeBindings(this,"CylindricitySymbol",this.CylindricitySymbol);
         return _loc1_;
      }
      
      private function _GWizGDandT_TextArea2_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.editable = false;
         _loc1_.text = "Controls form (shape) of size features only.  Datum reference is not allowed.";
         _loc1_.percentWidth = 100;
         _loc1_.id = "_GWizGDandT_TextArea2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGDandT_TextArea2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGDandT_TextArea2",this._GWizGDandT_TextArea2);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizForePanel2_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Orientation (No relation between features)";
         _loc1_.labelWidth = 140;
         _loc1_.layout = this._GWizGDandT_VerticalLayout2_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizGDandT_Array15_c);
         _loc1_.id = "_GWizGDandT_GWizForePanel2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGDandT_GWizForePanel2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGDandT_GWizForePanel2",this._GWizGDandT_GWizForePanel2);
         return _loc1_;
      }
      
      private function _GWizGDandT_VerticalLayout2_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizGDandT_Array15_c() : Array
      {
         return [this._GWizGDandT_HGroup8_c()];
      }
      
      private function _GWizGDandT_HGroup8_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_VGroup6_i(),this._GWizGDandT_TextArea3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_VGroup6_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.mxmlContent = [this._GWizGDandT_HGroup9_c(),this._GWizGDandT_HGroup10_c(),this._GWizGDandT_HGroup11_c()];
         _loc1_.id = "PerpendicularityVGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PerpendicularityVGroup = _loc1_;
         BindingManager.executeBindings(this,"PerpendicularityVGroup",this.PerpendicularityVGroup);
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup9_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_GWizLinkLabelURL5_i(),this._GWizGDandT_GWizLinkImage5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkLabelURL5_i() : GWizLinkLabelURL
      {
         var _loc1_:GWizLinkLabelURL = new GWizLinkLabelURL();
         _loc1_.text = "Perpendicularity";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Perpendicularity";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Perpendicularity = _loc1_;
         BindingManager.executeBindings(this,"Perpendicularity",this.Perpendicularity);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkImage5_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml_assets_Perpendicularity_JPG_353984926;
         _loc1_.id = "PerpendicularitySymbol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PerpendicularitySymbol = _loc1_;
         BindingManager.executeBindings(this,"PerpendicularitySymbol",this.PerpendicularitySymbol);
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup10_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_GWizLinkLabelURL6_i(),this._GWizGDandT_GWizLinkImage6_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkLabelURL6_i() : GWizLinkLabelURL
      {
         var _loc1_:GWizLinkLabelURL = new GWizLinkLabelURL();
         _loc1_.text = "Parallelism";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Parallelism";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Parallelism = _loc1_;
         BindingManager.executeBindings(this,"Parallelism",this.Parallelism);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkImage6_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml_assets_Parallelism_JPG_217840052;
         _loc1_.id = "ParallelismSymbol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ParallelismSymbol = _loc1_;
         BindingManager.executeBindings(this,"ParallelismSymbol",this.ParallelismSymbol);
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup11_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_GWizLinkLabelURL7_i(),this._GWizGDandT_GWizLinkImage7_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkLabelURL7_i() : GWizLinkLabelURL
      {
         var _loc1_:GWizLinkLabelURL = new GWizLinkLabelURL();
         _loc1_.text = "Angularity";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Angularity";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Angularity = _loc1_;
         BindingManager.executeBindings(this,"Angularity",this.Angularity);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkImage7_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml_assets_Angularity_JPG_1419058350;
         _loc1_.id = "AngularitySymbol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.AngularitySymbol = _loc1_;
         BindingManager.executeBindings(this,"AngularitySymbol",this.AngularitySymbol);
         return _loc1_;
      }
      
      private function _GWizGDandT_TextArea3_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.editable = false;
         _loc1_.percentWidth = 100;
         _loc1_.id = "_GWizGDandT_TextArea3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGDandT_TextArea3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGDandT_TextArea3",this._GWizGDandT_TextArea3);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizForePanel3_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Location";
         _loc1_.labelWidth = 140;
         _loc1_.layout = this._GWizGDandT_VerticalLayout3_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizGDandT_Array21_c);
         _loc1_.id = "_GWizGDandT_GWizForePanel3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGDandT_GWizForePanel3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGDandT_GWizForePanel3",this._GWizGDandT_GWizForePanel3);
         return _loc1_;
      }
      
      private function _GWizGDandT_VerticalLayout3_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizGDandT_Array21_c() : Array
      {
         return [this._GWizGDandT_HGroup12_c()];
      }
      
      private function _GWizGDandT_HGroup12_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_VGroup7_i(),this._GWizGDandT_TextArea4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_VGroup7_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.mxmlContent = [this._GWizGDandT_HGroup13_c(),this._GWizGDandT_HGroup14_c(),this._GWizGDandT_HGroup15_c()];
         _loc1_.id = "PositionVGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PositionVGroup = _loc1_;
         BindingManager.executeBindings(this,"PositionVGroup",this.PositionVGroup);
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup13_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_GWizLinkLabelURL8_i(),this._GWizGDandT_GWizLinkImage8_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkLabelURL8_i() : GWizLinkLabelURL
      {
         var _loc1_:GWizLinkLabelURL = new GWizLinkLabelURL();
         _loc1_.text = "Position";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Position";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Position = _loc1_;
         BindingManager.executeBindings(this,"Position",this.Position);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkImage8_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml_assets_Position_JPG_1774735060;
         _loc1_.id = "PositionSymbol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PositionSymbol = _loc1_;
         BindingManager.executeBindings(this,"PositionSymbol",this.PositionSymbol);
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup14_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_GWizLinkLabelURL9_i(),this._GWizGDandT_GWizLinkImage9_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkLabelURL9_i() : GWizLinkLabelURL
      {
         var _loc1_:GWizLinkLabelURL = new GWizLinkLabelURL();
         _loc1_.text = "Profile of a Surface";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "ProfileSurface";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ProfileSurface = _loc1_;
         BindingManager.executeBindings(this,"ProfileSurface",this.ProfileSurface);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkImage9_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml_assets_SurfaceProfile_JPG_606563794;
         _loc1_.id = "ProfileSurfaceSymbol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ProfileSurfaceSymbol = _loc1_;
         BindingManager.executeBindings(this,"ProfileSurfaceSymbol",this.ProfileSurfaceSymbol);
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup15_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_GWizLinkLabelURL10_i(),this._GWizGDandT_GWizLinkImage10_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkLabelURL10_i() : GWizLinkLabelURL
      {
         var _loc1_:GWizLinkLabelURL = new GWizLinkLabelURL();
         _loc1_.text = "Profile of a Line";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "ProfileLine";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ProfileLine = _loc1_;
         BindingManager.executeBindings(this,"ProfileLine",this.ProfileLine);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkImage10_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml_assets_LineProfile_JPG_1795581758;
         _loc1_.id = "ProfileLineSymbol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ProfileLineSymbol = _loc1_;
         BindingManager.executeBindings(this,"ProfileLineSymbol",this.ProfileLineSymbol);
         return _loc1_;
      }
      
      private function _GWizGDandT_TextArea4_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.editable = false;
         _loc1_.percentWidth = 100;
         _loc1_.id = "_GWizGDandT_TextArea4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGDandT_TextArea4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGDandT_TextArea4",this._GWizGDandT_TextArea4);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizForePanel4_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Runout";
         _loc1_.labelWidth = 140;
         _loc1_.layout = this._GWizGDandT_VerticalLayout4_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizGDandT_Array27_c);
         _loc1_.id = "_GWizGDandT_GWizForePanel4";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGDandT_GWizForePanel4 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGDandT_GWizForePanel4",this._GWizGDandT_GWizForePanel4);
         return _loc1_;
      }
      
      private function _GWizGDandT_VerticalLayout4_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizGDandT_Array27_c() : Array
      {
         return [this._GWizGDandT_HGroup16_c()];
      }
      
      private function _GWizGDandT_HGroup16_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_VGroup8_i(),this._GWizGDandT_TextArea5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_VGroup8_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.mxmlContent = [this._GWizGDandT_HGroup17_c(),this._GWizGDandT_HGroup18_c()];
         _loc1_.id = "RunoutVGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.RunoutVGroup = _loc1_;
         BindingManager.executeBindings(this,"RunoutVGroup",this.RunoutVGroup);
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup17_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_GWizLinkLabelURL11_i(),this._GWizGDandT_GWizLinkImage11_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkLabelURL11_i() : GWizLinkLabelURL
      {
         var _loc1_:GWizLinkLabelURL = new GWizLinkLabelURL();
         _loc1_.text = "Total Runout";
         _loc1_.url = "http://www.cnccookbook.com/GD&T/GD&TTotalRunout.html";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "TotalRunout";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TotalRunout = _loc1_;
         BindingManager.executeBindings(this,"TotalRunout",this.TotalRunout);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkImage11_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml_assets_TotalRunout_JPG_187627618;
         _loc1_.id = "TotalRunoutSymbol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TotalRunoutSymbol = _loc1_;
         BindingManager.executeBindings(this,"TotalRunoutSymbol",this.TotalRunoutSymbol);
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup18_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_GWizLinkLabelURL12_i(),this._GWizGDandT_GWizLinkImage12_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkLabelURL12_i() : GWizLinkLabelURL
      {
         var _loc1_:GWizLinkLabelURL = new GWizLinkLabelURL();
         _loc1_.text = "Circular Runout";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "CircularRunout";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CircularRunout = _loc1_;
         BindingManager.executeBindings(this,"CircularRunout",this.CircularRunout);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkImage12_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml_assets_CircularRunout_JPG_1745841250;
         _loc1_.id = "CircularRunoutSymbol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CircularRunoutSymbol = _loc1_;
         BindingManager.executeBindings(this,"CircularRunoutSymbol",this.CircularRunoutSymbol);
         return _loc1_;
      }
      
      private function _GWizGDandT_TextArea5_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.editable = false;
         _loc1_.text = "Controls surface coaxiality.  Can also control form and orientation of surfaces.";
         _loc1_.percentWidth = 100;
         _loc1_.id = "_GWizGDandT_TextArea5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGDandT_TextArea5 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGDandT_TextArea5",this._GWizGDandT_TextArea5);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizForePanel5_i() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.title = "Location of derived median points";
         _loc1_.labelWidth = 140;
         _loc1_.layout = this._GWizGDandT_VerticalLayout5_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizGDandT_Array32_c);
         _loc1_.id = "_GWizGDandT_GWizForePanel5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGDandT_GWizForePanel5 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGDandT_GWizForePanel5",this._GWizGDandT_GWizForePanel5);
         return _loc1_;
      }
      
      private function _GWizGDandT_VerticalLayout5_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizGDandT_Array32_c() : Array
      {
         return [this._GWizGDandT_HGroup19_c()];
      }
      
      private function _GWizGDandT_HGroup19_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_VGroup9_i(),this._GWizGDandT_TextArea6_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_VGroup9_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.mxmlContent = [this._GWizGDandT_HGroup20_c(),this._GWizGDandT_HGroup21_c()];
         _loc1_.id = "ConcentricityVGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ConcentricityVGroup = _loc1_;
         BindingManager.executeBindings(this,"ConcentricityVGroup",this.ConcentricityVGroup);
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup20_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_GWizLinkLabelURL13_i(),this._GWizGDandT_GWizLinkImage13_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkLabelURL13_i() : GWizLinkLabelURL
      {
         var _loc1_:GWizLinkLabelURL = new GWizLinkLabelURL();
         _loc1_.text = "Concentricity";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Concentricity";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Concentricity = _loc1_;
         BindingManager.executeBindings(this,"Concentricity",this.Concentricity);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkImage13_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml_assets_Concentricity_JPG_194249396;
         _loc1_.id = "ConcentricitySymbol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ConcentricitySymbol = _loc1_;
         BindingManager.executeBindings(this,"ConcentricitySymbol",this.ConcentricitySymbol);
         return _loc1_;
      }
      
      private function _GWizGDandT_HGroup21_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGDandT_GWizLinkLabelURL14_i(),this._GWizGDandT_GWizLinkImage14_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkLabelURL14_i() : GWizLinkLabelURL
      {
         var _loc1_:GWizLinkLabelURL = new GWizLinkLabelURL();
         _loc1_.text = "Symmetry";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Symmetry";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Symmetry = _loc1_;
         BindingManager.executeBindings(this,"Symmetry",this.Symmetry);
         return _loc1_;
      }
      
      private function _GWizGDandT_GWizLinkImage14_i() : GWizLinkImage
      {
         var _loc1_:GWizLinkImage = new GWizLinkImage();
         _loc1_.source = this._embed_mxml_assets_Symmetry_JPG_1044922642;
         _loc1_.id = "SymmetrySymbol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SymmetrySymbol = _loc1_;
         BindingManager.executeBindings(this,"SymmetrySymbol",this.SymmetrySymbol);
         return _loc1_;
      }
      
      private function _GWizGDandT_TextArea6_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.editable = false;
         _loc1_.text = "Locates derived median points of a feature. Not common, consider using position, runout, or profile instead.";
         _loc1_.percentWidth = 100;
         _loc1_.id = "_GWizGDandT_TextArea6";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGDandT_TextArea6 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGDandT_TextArea6",this._GWizGDandT_TextArea6);
         return _loc1_;
      }
      
      public function ___GWizGDandT_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizGDandT_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.gray5;
         },function(param1:uint):void
         {
            _GWizGDandT_Label1.setStyle("color",param1);
         },"_GWizGDandT_Label1.color");
         result[1] = new Binding(this,function():uint
         {
            return ColorPalette.gray3;
         },function(param1:uint):void
         {
            _GWizGDandT_Label1.setStyle("backgroundColor",param1);
         },"_GWizGDandT_Label1.backgroundColor");
         result[2] = new Binding(this,function():Number
         {
            return this.height;
         },null,"theScroller.maxHeight");
         result[3] = new Binding(this,function():Number
         {
            return Col2Widest.width + 3;
         },null,"_GWizGDandT_Label3.width");
         result[4] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"FormPanel.labelBackgroundColor");
         result[5] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"FormPanel.labelColor");
         result[6] = new Binding(this,function():Number
         {
            return Col2Widest.width;
         },null,"Flatness.width");
         result[7] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"FlatnessSymbol.scaleX");
         result[8] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"FlatnessSymbol.scaleY");
         result[9] = new Binding(this,function():Number
         {
            return Col2Widest.width;
         },null,"Straightness.width");
         result[10] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"StraightnessSymbol.scaleX");
         result[11] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"StraightnessSymbol.scaleY");
         result[12] = new Binding(this,function():Number
         {
            return FlatnessVGroup.height;
         },null,"_GWizGDandT_TextArea1.height");
         result[13] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"CircularitySymbol.scaleX");
         result[14] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"CircularitySymbol.scaleY");
         result[15] = new Binding(this,function():Number
         {
            return Col2Widest.width;
         },null,"Cylindricity.width");
         result[16] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"CylindricitySymbol.scaleX");
         result[17] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"CylindricitySymbol.scaleY");
         result[18] = new Binding(this,function():Number
         {
            return CircularityVGroup.height;
         },null,"_GWizGDandT_TextArea2.height");
         result[19] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"_GWizGDandT_GWizForePanel2.labelBackgroundColor");
         result[20] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"_GWizGDandT_GWizForePanel2.labelColor");
         result[21] = new Binding(this,function():Number
         {
            return Col2Widest.width;
         },null,"Perpendicularity.width");
         result[22] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"PerpendicularitySymbol.scaleX");
         result[23] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"PerpendicularitySymbol.scaleY");
         result[24] = new Binding(this,function():Number
         {
            return Col2Widest.width;
         },null,"Parallelism.width");
         result[25] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"ParallelismSymbol.scaleX");
         result[26] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"ParallelismSymbol.scaleY");
         result[27] = new Binding(this,function():Number
         {
            return Col2Widest.width;
         },null,"Angularity.width");
         result[28] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"AngularitySymbol.scaleX");
         result[29] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"AngularitySymbol.scaleY");
         result[30] = new Binding(this,function():String
         {
            var _loc1_:* = "Controls orientation (tilt) of surfaces, axes, or median planes for size and non-size features.\n\n" + "Datum reference required.\n\n" + "Optional: Angularity symbol may be used for all orientation controls.";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizGDandT_TextArea3.text");
         result[31] = new Binding(this,function():Number
         {
            return PerpendicularityVGroup.height;
         },null,"_GWizGDandT_TextArea3.height");
         result[32] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"_GWizGDandT_GWizForePanel3.labelBackgroundColor");
         result[33] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"_GWizGDandT_GWizForePanel3.labelColor");
         result[34] = new Binding(this,function():Number
         {
            return Col2Widest.width;
         },null,"Position.width");
         result[35] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"PositionSymbol.scaleX");
         result[36] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"PositionSymbol.scaleY");
         result[37] = new Binding(this,function():Number
         {
            return Col2Widest.width;
         },null,"ProfileSurface.width");
         result[38] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"ProfileSurfaceSymbol.scaleX");
         result[39] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"ProfileSurfaceSymbol.scaleY");
         result[40] = new Binding(this,function():Number
         {
            return Col2Widest.width;
         },null,"ProfileLine.width");
         result[41] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"ProfileLineSymbol.scaleX");
         result[42] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"ProfileLineSymbol.scaleY");
         result[43] = new Binding(this,function():String
         {
            var _loc1_:* = "Position locates center points, axes, and median planes for size features.  Can also control orientation.\n\n" + "\n" + "Profiles locate surfaces.  Can also be used to control size, form, and orientation based on datum reference.";
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizGDandT_TextArea4.text");
         result[44] = new Binding(this,function():Number
         {
            return PositionVGroup.height;
         },null,"_GWizGDandT_TextArea4.height");
         result[45] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"_GWizGDandT_GWizForePanel4.labelBackgroundColor");
         result[46] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"_GWizGDandT_GWizForePanel4.labelColor");
         result[47] = new Binding(this,function():Number
         {
            return Col2Widest.width;
         },null,"TotalRunout.width");
         result[48] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"TotalRunoutSymbol.scaleX");
         result[49] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"TotalRunoutSymbol.scaleY");
         result[50] = new Binding(this,function():Number
         {
            return Col2Widest.width;
         },null,"CircularRunout.width");
         result[51] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"CircularRunoutSymbol.scaleX");
         result[52] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"CircularRunoutSymbol.scaleY");
         result[53] = new Binding(this,function():Number
         {
            return RunoutVGroup.height;
         },null,"_GWizGDandT_TextArea5.height");
         result[54] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb3;
         },null,"_GWizGDandT_GWizForePanel5.labelBackgroundColor");
         result[55] = new Binding(this,function():uint
         {
            return ColorPalette.alternateb5;
         },null,"_GWizGDandT_GWizForePanel5.labelColor");
         result[56] = new Binding(this,function():Number
         {
            return Col2Widest.width;
         },null,"Concentricity.width");
         result[57] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"ConcentricitySymbol.scaleX");
         result[58] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"ConcentricitySymbol.scaleY");
         result[59] = new Binding(this,function():Number
         {
            return Col2Widest.width;
         },null,"Symmetry.width");
         result[60] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"SymmetrySymbol.scaleX");
         result[61] = new Binding(this,function():Number
         {
            return SCALE_SYMBOLS;
         },null,"SymmetrySymbol.scaleY");
         result[62] = new Binding(this,function():Number
         {
            return ConcentricityVGroup.height;
         },null,"_GWizGDandT_TextArea6.height");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Angularity() : GWizLinkLabelURL
      {
         return this._1924613036Angularity;
      }
      
      public function set Angularity(param1:GWizLinkLabelURL) : void
      {
         var _loc2_:Object = this._1924613036Angularity;
         if(_loc2_ !== param1)
         {
            this._1924613036Angularity = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Angularity",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get AngularitySymbol() : GWizLinkImage
      {
         return this._1373162396AngularitySymbol;
      }
      
      public function set AngularitySymbol(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._1373162396AngularitySymbol;
         if(_loc2_ !== param1)
         {
            this._1373162396AngularitySymbol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"AngularitySymbol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CircularRunout() : GWizLinkLabelURL
      {
         return this._1573916542CircularRunout;
      }
      
      public function set CircularRunout(param1:GWizLinkLabelURL) : void
      {
         var _loc2_:Object = this._1573916542CircularRunout;
         if(_loc2_ !== param1)
         {
            this._1573916542CircularRunout = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CircularRunout",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CircularRunoutSymbol() : GWizLinkImage
      {
         return this._1273260218CircularRunoutSymbol;
      }
      
      public function set CircularRunoutSymbol(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._1273260218CircularRunoutSymbol;
         if(_loc2_ !== param1)
         {
            this._1273260218CircularRunoutSymbol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CircularRunoutSymbol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CircularitySymbol() : GWizLinkImage
      {
         return this._379749369CircularitySymbol;
      }
      
      public function set CircularitySymbol(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._379749369CircularitySymbol;
         if(_loc2_ !== param1)
         {
            this._379749369CircularitySymbol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CircularitySymbol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CircularityVGroup() : VGroup
      {
         return this._339876328CircularityVGroup;
      }
      
      public function set CircularityVGroup(param1:VGroup) : void
      {
         var _loc2_:Object = this._339876328CircularityVGroup;
         if(_loc2_ !== param1)
         {
            this._339876328CircularityVGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CircularityVGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Col2Widest() : GWizLinkLabelURL
      {
         return this._79200794Col2Widest;
      }
      
      public function set Col2Widest(param1:GWizLinkLabelURL) : void
      {
         var _loc2_:Object = this._79200794Col2Widest;
         if(_loc2_ !== param1)
         {
            this._79200794Col2Widest = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Col2Widest",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Concentricity() : GWizLinkLabelURL
      {
         return this._395286188Concentricity;
      }
      
      public function set Concentricity(param1:GWizLinkLabelURL) : void
      {
         var _loc2_:Object = this._395286188Concentricity;
         if(_loc2_ !== param1)
         {
            this._395286188Concentricity = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Concentricity",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ConcentricitySymbol() : GWizLinkImage
      {
         return this._164280476ConcentricitySymbol;
      }
      
      public function set ConcentricitySymbol(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._164280476ConcentricitySymbol;
         if(_loc2_ !== param1)
         {
            this._164280476ConcentricitySymbol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ConcentricitySymbol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ConcentricityVGroup() : VGroup
      {
         return this._124407435ConcentricityVGroup;
      }
      
      public function set ConcentricityVGroup(param1:VGroup) : void
      {
         var _loc2_:Object = this._124407435ConcentricityVGroup;
         if(_loc2_ !== param1)
         {
            this._124407435ConcentricityVGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ConcentricityVGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Cylindricity() : GWizLinkLabelURL
      {
         return this._1473455851Cylindricity;
      }
      
      public function set Cylindricity(param1:GWizLinkLabelURL) : void
      {
         var _loc2_:Object = this._1473455851Cylindricity;
         if(_loc2_ !== param1)
         {
            this._1473455851Cylindricity = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Cylindricity",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CylindricitySymbol() : GWizLinkImage
      {
         return this._1043688547CylindricitySymbol;
      }
      
      public function set CylindricitySymbol(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._1043688547CylindricitySymbol;
         if(_loc2_ !== param1)
         {
            this._1043688547CylindricitySymbol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CylindricitySymbol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Flatness() : GWizLinkLabelURL
      {
         return this._1691322736Flatness;
      }
      
      public function set Flatness(param1:GWizLinkLabelURL) : void
      {
         var _loc2_:Object = this._1691322736Flatness;
         if(_loc2_ !== param1)
         {
            this._1691322736Flatness = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Flatness",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FlatnessSymbol() : GWizLinkImage
      {
         return this._1014830888FlatnessSymbol;
      }
      
      public function set FlatnessSymbol(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._1014830888FlatnessSymbol;
         if(_loc2_ !== param1)
         {
            this._1014830888FlatnessSymbol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FlatnessSymbol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FlatnessVGroup() : VGroup
      {
         return this._1054703929FlatnessVGroup;
      }
      
      public function set FlatnessVGroup(param1:VGroup) : void
      {
         var _loc2_:Object = this._1054703929FlatnessVGroup;
         if(_loc2_ !== param1)
         {
            this._1054703929FlatnessVGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FlatnessVGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FormPanel() : GWizForePanel
      {
         return this._495679616FormPanel;
      }
      
      public function set FormPanel(param1:GWizForePanel) : void
      {
         var _loc2_:Object = this._495679616FormPanel;
         if(_loc2_ !== param1)
         {
            this._495679616FormPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FormPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Parallelism() : GWizLinkLabelURL
      {
         return this._1991933700Parallelism;
      }
      
      public function set Parallelism(param1:GWizLinkLabelURL) : void
      {
         var _loc2_:Object = this._1991933700Parallelism;
         if(_loc2_ !== param1)
         {
            this._1991933700Parallelism = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Parallelism",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ParallelismSymbol() : GWizLinkImage
      {
         return this._2042219084ParallelismSymbol;
      }
      
      public function set ParallelismSymbol(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._2042219084ParallelismSymbol;
         if(_loc2_ !== param1)
         {
            this._2042219084ParallelismSymbol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ParallelismSymbol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Perpendicularity() : GWizLinkLabelURL
      {
         return this._914279524Perpendicularity;
      }
      
      public function set Perpendicularity(param1:GWizLinkLabelURL) : void
      {
         var _loc2_:Object = this._914279524Perpendicularity;
         if(_loc2_ !== param1)
         {
            this._914279524Perpendicularity = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Perpendicularity",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PerpendicularitySymbol() : GWizLinkImage
      {
         return this._1784458468PerpendicularitySymbol;
      }
      
      public function set PerpendicularitySymbol(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._1784458468PerpendicularitySymbol;
         if(_loc2_ !== param1)
         {
            this._1784458468PerpendicularitySymbol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PerpendicularitySymbol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PerpendicularityVGroup() : VGroup
      {
         return this._1744585427PerpendicularityVGroup;
      }
      
      public function set PerpendicularityVGroup(param1:VGroup) : void
      {
         var _loc2_:Object = this._1744585427PerpendicularityVGroup;
         if(_loc2_ !== param1)
         {
            this._1744585427PerpendicularityVGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PerpendicularityVGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Position() : GWizLinkLabelURL
      {
         return this._812449097Position;
      }
      
      public function set Position(param1:GWizLinkLabelURL) : void
      {
         var _loc2_:Object = this._812449097Position;
         if(_loc2_ !== param1)
         {
            this._812449097Position = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Position",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PositionSymbol() : GWizLinkImage
      {
         return this._1646298177PositionSymbol;
      }
      
      public function set PositionSymbol(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._1646298177PositionSymbol;
         if(_loc2_ !== param1)
         {
            this._1646298177PositionSymbol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PositionSymbol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PositionVGroup() : VGroup
      {
         return this._1686171218PositionVGroup;
      }
      
      public function set PositionVGroup(param1:VGroup) : void
      {
         var _loc2_:Object = this._1686171218PositionVGroup;
         if(_loc2_ !== param1)
         {
            this._1686171218PositionVGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PositionVGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ProfileLine() : GWizLinkLabelURL
      {
         return this._1845319965ProfileLine;
      }
      
      public function set ProfileLine(param1:GWizLinkLabelURL) : void
      {
         var _loc2_:Object = this._1845319965ProfileLine;
         if(_loc2_ !== param1)
         {
            this._1845319965ProfileLine = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ProfileLine",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ProfileLineSymbol() : GWizLinkImage
      {
         return this._647384811ProfileLineSymbol;
      }
      
      public function set ProfileLineSymbol(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._647384811ProfileLineSymbol;
         if(_loc2_ !== param1)
         {
            this._647384811ProfileLineSymbol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ProfileLineSymbol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ProfileSurface() : GWizLinkLabelURL
      {
         return this._610617060ProfileSurface;
      }
      
      public function set ProfileSurface(param1:GWizLinkLabelURL) : void
      {
         var _loc2_:Object = this._610617060ProfileSurface;
         if(_loc2_ !== param1)
         {
            this._610617060ProfileSurface = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ProfileSurface",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ProfileSurfaceSymbol() : GWizLinkImage
      {
         return this._711191964ProfileSurfaceSymbol;
      }
      
      public function set ProfileSurfaceSymbol(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._711191964ProfileSurfaceSymbol;
         if(_loc2_ !== param1)
         {
            this._711191964ProfileSurfaceSymbol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ProfileSurfaceSymbol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RunoutVGroup() : VGroup
      {
         return this._842887540RunoutVGroup;
      }
      
      public function set RunoutVGroup(param1:VGroup) : void
      {
         var _loc2_:Object = this._842887540RunoutVGroup;
         if(_loc2_ !== param1)
         {
            this._842887540RunoutVGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RunoutVGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Straightness() : GWizLinkLabelURL
      {
         return this._1998095247Straightness;
      }
      
      public function set Straightness(param1:GWizLinkLabelURL) : void
      {
         var _loc2_:Object = this._1998095247Straightness;
         if(_loc2_ !== param1)
         {
            this._1998095247Straightness = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Straightness",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get StraightnessSymbol() : GWizLinkImage
      {
         return this._1920533865StraightnessSymbol;
      }
      
      public function set StraightnessSymbol(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._1920533865StraightnessSymbol;
         if(_loc2_ !== param1)
         {
            this._1920533865StraightnessSymbol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"StraightnessSymbol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Symmetry() : GWizLinkLabelURL
      {
         return this._1862498012Symmetry;
      }
      
      public function set Symmetry(param1:GWizLinkLabelURL) : void
      {
         var _loc2_:Object = this._1862498012Symmetry;
         if(_loc2_ !== param1)
         {
            this._1862498012Symmetry = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Symmetry",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SymmetrySymbol() : GWizLinkImage
      {
         return this._174867348SymmetrySymbol;
      }
      
      public function set SymmetrySymbol(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._174867348SymmetrySymbol;
         if(_loc2_ !== param1)
         {
            this._174867348SymmetrySymbol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SymmetrySymbol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TotalRunout() : GWizLinkLabelURL
      {
         return this._904515879TotalRunout;
      }
      
      public function set TotalRunout(param1:GWizLinkLabelURL) : void
      {
         var _loc2_:Object = this._904515879TotalRunout;
         if(_loc2_ !== param1)
         {
            this._904515879TotalRunout = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TotalRunout",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TotalRunoutSymbol() : GWizLinkImage
      {
         return this._48596577TotalRunoutSymbol;
      }
      
      public function set TotalRunoutSymbol(param1:GWizLinkImage) : void
      {
         var _loc2_:Object = this._48596577TotalRunoutSymbol;
         if(_loc2_ !== param1)
         {
            this._48596577TotalRunoutSymbol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TotalRunoutSymbol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get contentGroup() : VGroup
      {
         return this._809612678contentGroup;
      }
      
      public function set contentGroup(param1:VGroup) : void
      {
         var _loc2_:Object = this._809612678contentGroup;
         if(_loc2_ !== param1)
         {
            this._809612678contentGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"contentGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get theScroller() : Scroller
      {
         return this._542676939theScroller;
      }
      
      public function set theScroller(param1:Scroller) : void
      {
         var _loc2_:Object = this._542676939theScroller;
         if(_loc2_ !== param1)
         {
            this._542676939theScroller = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theScroller",_loc2_,param1));
            }
         }
      }
   }
}
