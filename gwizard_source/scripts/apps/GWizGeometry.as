package apps
{
   import comps.GWizTaperCalc;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.containers.ViewStack;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponentDescriptor;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.IndexChangedEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.ButtonBar;
   import spark.components.HGroup;
   import spark.components.NavigatorContent;
   import spark.layouts.TileLayout;
   import utils.GATracker;
   import views.GWizBallGage;
   import views.GWizBoltCircle;
   import views.GWizChamferDrillCalc;
   import views.GWizChordCalc;
   import views.GWizDovetailCalc;
   import views.GWizFitsTolerances;
   import views.GWizGageBlocks;
   import views.GWizPoints;
   import views.GWizPolarCalc;
   import views.GWizTrigCalc;
   import views.GWizTrigCalcOblique;
   import views.GWizTruePosition;
   import views.GWizTurnersCube;
   
   use namespace mx_internal;
   
   public class GWizGeometry extends HGroup implements IBindingClient
   {
      
      public static const CHAMFER_DRILL:String = "Chamfer/Drill";
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1552339620BallGages:NavigatorContent;
      
      private var _2140717358BoltCircles:NavigatorContent;
      
      private var _979855097ChamferDrill:NavigatorContent;
      
      private var _2017618871Chords:NavigatorContent;
      
      private var _2111573Cube:NavigatorContent;
      
      private var _2116481591Dovetails:NavigatorContent;
      
      private var _428923132FitsTols:NavigatorContent;
      
      private var _260085502GageBlocks:NavigatorContent;
      
      private var _862215993ObliqueTriangle:NavigatorContent;
      
      private var _1898886909Points:NavigatorContent;
      
      private var _77295390Polar:NavigatorContent;
      
      private var _1070695460RightTriangle:NavigatorContent;
      
      private var _1797099773Tapers:NavigatorContent;
      
      private var _689920247TruePosition:NavigatorContent;
      
      public var _GWizGeometry_ButtonBar1:ButtonBar;
      
      private var _881406642tabNav:ViewStack;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var appSelectedCallback:Function;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizGeometry()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizGeometry_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_apps_GWizGeometryWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizGeometry[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.left = 10;
         this.right = 0;
         this.top = 0;
         this.bottom = 0;
         this.gap = 0;
         this.styleName = "geoView";
         this.alpha = 1;
         this.mxmlContent = [this._GWizGeometry_ButtonBar1_i(),this._GWizGeometry_ViewStack1_i()];
         this.addEventListener("show",this.___GWizGeometry_HGroup1_show);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizGeometry._watcherSetupUtil = param1;
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
      
      private function checkUnits(param1:Event) : void
      {
         this.tabNav.selectedChild.dispatchEvent(param1);
      }
      
      public function appSelector(param1:String, param2:Function) : void
      {
         var _loc6_:Object = null;
         var _loc3_:Object = this.tabNav.selectedChild;
         var _loc4_:int = 0;
         while(_loc4_ < this.tabNav.numChildren)
         {
            if((_loc6_ = this.tabNav.getChildAt(_loc4_)).hasOwnProperty("label") && _loc6_.label == param1)
            {
               _loc3_ = _loc6_;
               GATracker.logPageView("Geometry/" + param1,"Geometry: " + param1);
               break;
            }
            _loc4_++;
         }
         var _loc5_:NavigatorContent = _loc3_ as NavigatorContent;
         this.tabNav.selectedChild = _loc5_;
         this.appSelectedCallback = param2;
         this.waitForAppSelection();
      }
      
      private function waitForAppSelection() : void
      {
         var _loc1_:Object = this.tabNav.selectedChild;
         var _loc2_:NavigatorContent = _loc1_ as NavigatorContent;
         if(_loc2_.numElements > 0)
         {
            this.appSelectedCallback(_loc2_.getElementAt(0) as Object);
         }
         else
         {
            this.callLater(this.waitForAppSelection);
         }
      }
      
      private function _GWizGeometry_ButtonBar1_i() : ButtonBar
      {
         var _loc1_:ButtonBar = new ButtonBar();
         _loc1_.styleName = "geoTabBar";
         _loc1_.horizontalCenter = 0;
         _loc1_.verticalCenter = 0;
         _loc1_.width = 130;
         _loc1_.percentHeight = 100;
         _loc1_.requireSelection = true;
         _loc1_.layout = this._GWizGeometry_TileLayout1_c();
         _loc1_.id = "_GWizGeometry_ButtonBar1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGeometry_ButtonBar1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGeometry_ButtonBar1",this._GWizGeometry_ButtonBar1);
         return _loc1_;
      }
      
      private function _GWizGeometry_TileLayout1_c() : TileLayout
      {
         var _loc1_:TileLayout = new TileLayout();
         _loc1_.columnWidth = 130;
         _loc1_.orientation = "columns";
         _loc1_.requestedColumnCount = 1;
         _loc1_.verticalGap = -1;
         _loc1_.rowHeight = 30;
         return _loc1_;
      }
      
      private function _GWizGeometry_ViewStack1_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.top = 0;
         temp.left = 0;
         temp.bottom = 0;
         temp.right = 0;
         temp.creationPolicy = "auto";
         temp.styleName = "geoView";
         temp.setStyle("borderColor",8752525);
         temp.addEventListener("change",this.__tabNav_change);
         temp.id = "tabNav";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"tabNav",
            "events":{"change":"__tabNav_change"},
            "stylesFactory":function():void
            {
               this.borderColor = 8752525;
            },
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"RightTriangle",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Right Triangle",
                        "percentWidth":100,
                        "percentHeight":100,
                        "styleName":"geoView",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGeometry_Array2_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"ObliqueTriangle",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Oblique Triangle",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGeometry_Array3_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"BoltCircles",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Bolt Circles",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGeometry_Array4_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Dovetails",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Dovetails",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGeometry_Array5_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Tapers",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Tapers",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGeometry_Array6_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"ChamferDrill",
                  "stylesFactory":function():void
                  {
                     this.backgroundColor = 15398372;
                  },
                  "propertiesFactory":function():Object
                  {
                     return {
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGeometry_Array7_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Chords",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Chords",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGeometry_Array8_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"TruePosition",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"True Positon",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGeometry_Array9_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Points",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Points",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGeometry_Array10_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Polar",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Polar",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGeometry_Array11_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Cube",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Cube",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGeometry_Array12_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"FitsTols",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Fits/Tols",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGeometry_Array13_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"GageBlocks",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Gage Blk/Sine Bar",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGeometry_Array14_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"BallGages",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Ball Gages",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizGeometry_Array15_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.tabNav = temp;
         BindingManager.executeBindings(this,"tabNav",this.tabNav);
         return temp;
      }
      
      public function __tabNav_change(param1:IndexChangedEvent) : void
      {
         GATracker.logPageView("Geometry/" + this.tabNav.selectedChild.label,"Geometry: " + this.tabNav.selectedChild.label);
      }
      
      private function _GWizGeometry_Array2_c() : Array
      {
         return [this._GWizGeometry_GWizTrigCalc1_c()];
      }
      
      private function _GWizGeometry_GWizTrigCalc1_c() : GWizTrigCalc
      {
         var _loc1_:GWizTrigCalc = new GWizTrigCalc();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGeometry_Array3_c() : Array
      {
         return [this._GWizGeometry_GWizTrigCalcOblique1_c()];
      }
      
      private function _GWizGeometry_GWizTrigCalcOblique1_c() : GWizTrigCalcOblique
      {
         var _loc1_:GWizTrigCalcOblique = new GWizTrigCalcOblique();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGeometry_Array4_c() : Array
      {
         return [this._GWizGeometry_GWizBoltCircle1_c()];
      }
      
      private function _GWizGeometry_GWizBoltCircle1_c() : GWizBoltCircle
      {
         var _loc1_:GWizBoltCircle = new GWizBoltCircle();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGeometry_Array5_c() : Array
      {
         return [this._GWizGeometry_GWizDovetailCalc1_c()];
      }
      
      private function _GWizGeometry_GWizDovetailCalc1_c() : GWizDovetailCalc
      {
         var _loc1_:GWizDovetailCalc = new GWizDovetailCalc();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGeometry_Array6_c() : Array
      {
         return [this._GWizGeometry_GWizTaperCalc1_c()];
      }
      
      private function _GWizGeometry_GWizTaperCalc1_c() : GWizTaperCalc
      {
         var _loc1_:GWizTaperCalc = new GWizTaperCalc();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGeometry_Array7_c() : Array
      {
         return [this._GWizGeometry_GWizChamferDrillCalc1_c()];
      }
      
      private function _GWizGeometry_GWizChamferDrillCalc1_c() : GWizChamferDrillCalc
      {
         var _loc1_:GWizChamferDrillCalc = new GWizChamferDrillCalc();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGeometry_Array8_c() : Array
      {
         return [this._GWizGeometry_GWizChordCalc1_c()];
      }
      
      private function _GWizGeometry_GWizChordCalc1_c() : GWizChordCalc
      {
         var _loc1_:GWizChordCalc = new GWizChordCalc();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGeometry_Array9_c() : Array
      {
         return [this._GWizGeometry_GWizTruePosition1_c()];
      }
      
      private function _GWizGeometry_GWizTruePosition1_c() : GWizTruePosition
      {
         var _loc1_:GWizTruePosition = new GWizTruePosition();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGeometry_Array10_c() : Array
      {
         return [this._GWizGeometry_GWizPoints1_c()];
      }
      
      private function _GWizGeometry_GWizPoints1_c() : GWizPoints
      {
         var _loc1_:GWizPoints = new GWizPoints();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGeometry_Array11_c() : Array
      {
         return [this._GWizGeometry_GWizPolarCalc1_c()];
      }
      
      private function _GWizGeometry_GWizPolarCalc1_c() : GWizPolarCalc
      {
         var _loc1_:GWizPolarCalc = new GWizPolarCalc();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGeometry_Array12_c() : Array
      {
         return [this._GWizGeometry_GWizTurnersCube1_c()];
      }
      
      private function _GWizGeometry_GWizTurnersCube1_c() : GWizTurnersCube
      {
         var _loc1_:GWizTurnersCube = new GWizTurnersCube();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGeometry_Array13_c() : Array
      {
         return [this._GWizGeometry_GWizFitsTolerances1_c()];
      }
      
      private function _GWizGeometry_GWizFitsTolerances1_c() : GWizFitsTolerances
      {
         var _loc1_:GWizFitsTolerances = new GWizFitsTolerances();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGeometry_Array14_c() : Array
      {
         return [this._GWizGeometry_GWizGageBlocks1_c()];
      }
      
      private function _GWizGeometry_GWizGageBlocks1_c() : GWizGageBlocks
      {
         var _loc1_:GWizGageBlocks = new GWizGageBlocks();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGeometry_Array15_c() : Array
      {
         return [this._GWizGeometry_GWizBallGage1_c()];
      }
      
      private function _GWizGeometry_GWizBallGage1_c() : GWizBallGage
      {
         var _loc1_:GWizBallGage = new GWizBallGage();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizGeometry_HGroup1_show(param1:FlexEvent) : void
      {
         this.checkUnits(param1);
      }
      
      private function _GWizGeometry_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,null,null,"_GWizGeometry_ButtonBar1.dataProvider","tabNav");
         result[1] = new Binding(this,function():String
         {
            var _loc1_:* = CHAMFER_DRILL;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"ChamferDrill.label");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get BallGages() : NavigatorContent
      {
         return this._1552339620BallGages;
      }
      
      public function set BallGages(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1552339620BallGages;
         if(_loc2_ !== param1)
         {
            this._1552339620BallGages = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"BallGages",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get BoltCircles() : NavigatorContent
      {
         return this._2140717358BoltCircles;
      }
      
      public function set BoltCircles(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._2140717358BoltCircles;
         if(_loc2_ !== param1)
         {
            this._2140717358BoltCircles = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"BoltCircles",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ChamferDrill() : NavigatorContent
      {
         return this._979855097ChamferDrill;
      }
      
      public function set ChamferDrill(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._979855097ChamferDrill;
         if(_loc2_ !== param1)
         {
            this._979855097ChamferDrill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ChamferDrill",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Chords() : NavigatorContent
      {
         return this._2017618871Chords;
      }
      
      public function set Chords(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._2017618871Chords;
         if(_loc2_ !== param1)
         {
            this._2017618871Chords = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Chords",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Cube() : NavigatorContent
      {
         return this._2111573Cube;
      }
      
      public function set Cube(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._2111573Cube;
         if(_loc2_ !== param1)
         {
            this._2111573Cube = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Cube",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Dovetails() : NavigatorContent
      {
         return this._2116481591Dovetails;
      }
      
      public function set Dovetails(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._2116481591Dovetails;
         if(_loc2_ !== param1)
         {
            this._2116481591Dovetails = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Dovetails",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FitsTols() : NavigatorContent
      {
         return this._428923132FitsTols;
      }
      
      public function set FitsTols(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._428923132FitsTols;
         if(_loc2_ !== param1)
         {
            this._428923132FitsTols = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FitsTols",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get GageBlocks() : NavigatorContent
      {
         return this._260085502GageBlocks;
      }
      
      public function set GageBlocks(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._260085502GageBlocks;
         if(_loc2_ !== param1)
         {
            this._260085502GageBlocks = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"GageBlocks",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ObliqueTriangle() : NavigatorContent
      {
         return this._862215993ObliqueTriangle;
      }
      
      public function set ObliqueTriangle(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._862215993ObliqueTriangle;
         if(_loc2_ !== param1)
         {
            this._862215993ObliqueTriangle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ObliqueTriangle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Points() : NavigatorContent
      {
         return this._1898886909Points;
      }
      
      public function set Points(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1898886909Points;
         if(_loc2_ !== param1)
         {
            this._1898886909Points = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Points",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Polar() : NavigatorContent
      {
         return this._77295390Polar;
      }
      
      public function set Polar(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._77295390Polar;
         if(_loc2_ !== param1)
         {
            this._77295390Polar = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Polar",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get RightTriangle() : NavigatorContent
      {
         return this._1070695460RightTriangle;
      }
      
      public function set RightTriangle(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1070695460RightTriangle;
         if(_loc2_ !== param1)
         {
            this._1070695460RightTriangle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"RightTriangle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Tapers() : NavigatorContent
      {
         return this._1797099773Tapers;
      }
      
      public function set Tapers(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1797099773Tapers;
         if(_loc2_ !== param1)
         {
            this._1797099773Tapers = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Tapers",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TruePosition() : NavigatorContent
      {
         return this._689920247TruePosition;
      }
      
      public function set TruePosition(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._689920247TruePosition;
         if(_loc2_ !== param1)
         {
            this._689920247TruePosition = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TruePosition",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tabNav() : ViewStack
      {
         return this._881406642tabNav;
      }
      
      public function set tabNav(param1:ViewStack) : void
      {
         var _loc2_:Object = this._881406642tabNav;
         if(_loc2_ !== param1)
         {
            this._881406642tabNav = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tabNav",_loc2_,param1));
            }
         }
      }
   }
}
