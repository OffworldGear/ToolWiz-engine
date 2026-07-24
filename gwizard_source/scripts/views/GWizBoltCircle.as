package views
{
   import comps.GWizFileBrowser;
   import comps.GWizNumStepOvr;
   import comps.GWizPanel;
   import comps.GridComponent;
   import comps.skins.PanelSkin;
   import flash.display.Graphics;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.core.ClassFactory;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.states.SetProperty;
   import mx.states.State;
   import mx.utils.ColorUtil;
   import skins.GridSkin;
   import spark.components.Button;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.List;
   import spark.layouts.HorizontalLayout;
   import spark.layouts.VerticalLayout;
   import utils.GWizCSVUtils;
   import utils.GWizGeomUtils;
   
   use namespace mx_internal;
   
   public class GWizBoltCircle extends Group implements IBindingClient, IStateClient2
   {
      
      private static const log:ILogger = Log.getLogger("GWizBoltCircles");
      
      private static const boltRadius:int = 20;
      
      private static const defaultArray:Array = [{
         "angle":30,
         "x":0.866,
         "y":0.5
      },{
         "angle":102,
         "x":-0.2079,
         "y":0.9781
      },{
         "angle":174,
         "x":-0.9945,
         "y":0.1045
      },{
         "angle":246,
         "x":-0.4067,
         "y":-0.9135
      },{
         "angle":318,
         "x":0.7431,
         "y":-0.6691
      }];
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _65193517Clear:Button;
      
      private var _2569629Save:Button;
      
      private var _1979520456_GWizBoltCircle_GWizPanel1:GWizPanel;
      
      public var _GWizBoltCircle_List1:List;
      
      private var _665239203centerX:GWizNumStepOvr;
      
      private var _665239204centerY:GWizNumStepOvr;
      
      private var _317504755gridArea:GridComponent;
      
      private var _1081394000nBolts:GWizNumStepOvr;
      
      private var _938578798radius:GWizNumStepOvr;
      
      private var _1601031791startAngle:GWizNumStepOvr;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1202947449holeArray:ArrayCollection;
      
      private var holeArrayFieldList:Array;
      
      public var bcFiles:GWizFileBrowser;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizBoltCircle()
      {
         var bindings:Array = null;
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._1202947449holeArray = new ArrayCollection();
         this.holeArrayFieldList = ["angle","x","y"];
         this.bcFiles = new GWizFileBrowser("BoltCircle","CSV","*.csv");
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         bindings = this._GWizBoltCircle_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_views_GWizBoltCircleWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizBoltCircle[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.styleName = "geoView";
         this.percentHeight = 100;
         this.percentWidth = 100;
         this.bottom = 10;
         this.left = 10;
         this.right = 10;
         this.top = 10;
         this.mxmlContent = [this._GWizBoltCircle_GridComponent1_i(),this._GWizBoltCircle_GWizPanel1_i()];
         this.currentState = "portrait";
         this.addEventListener("creationComplete",this.___GWizBoltCircle_Group1_creationComplete);
         this.addEventListener("show",this.___GWizBoltCircle_Group1_show);
         states = [new State({
            "name":"portrait",
            "overrides":[new SetProperty().initializeFromObject({
               "name":"layout",
               "value":this._GWizBoltCircle_VerticalLayout1_c()
            }),new SetProperty().initializeFromObject({
               "target":"_GWizBoltCircle_GWizPanel1",
               "name":"percentHeight",
               "value":25
            }),new SetProperty().initializeFromObject({
               "target":"_GWizBoltCircle_GWizPanel1",
               "name":"percentWidth",
               "value":100
            })]
         }),new State({
            "name":"landscape",
            "overrides":[new SetProperty().initializeFromObject({
               "name":"layout",
               "value":this._GWizBoltCircle_HorizontalLayout1_c()
            }),new SetProperty().initializeFromObject({
               "target":"_GWizBoltCircle_GWizPanel1",
               "name":"percentHeight",
               "value":100
            }),new SetProperty().initializeFromObject({
               "target":"_GWizBoltCircle_GWizPanel1",
               "name":"width",
               "value":300
            })]
         })];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizBoltCircle._watcherSetupUtil = param1;
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
      
      private function restoreViewData() : void
      {
         this.recalc();
      }
      
      private function saveViewData() : void
      {
      }
      
      private function recalc() : void
      {
         this.holeArray = GWizGeomUtils.boltCircleCenters(this.radius.getVal(),this.nBolts.getVal(),this.startAngle.getVal(),this.centerX.getVal(),this.centerY.getVal(),false);
         this.gridArea.redraw();
      }
      
      private function clearAll() : void
      {
         this.startAngle.resetOverride(true);
         this.radius.resetOverride(true);
         this.nBolts.resetOverride(true);
         this.centerX.resetOverride(true);
         this.centerY.resetOverride(true);
         this.holeArray.removeAll();
         this.gridArea.redraw();
      }
      
      private function drawShape(param1:Graphics) : void
      {
         var _loc6_:Object = null;
         var _loc2_:int = Math.min(this.gridArea.xMax,this.gridArea.yMax) - boltRadius;
         param1.lineStyle(1,5592405,1);
         param1.drawCircle(this.gridArea.xOrigin,this.gridArea.yOrigin,_loc2_);
         var _loc3_:Boolean = this.nBolts.getVal() < 1 || this.nBolts.getVal() > 25 || this.radius.getVal() == 0 ? true : false;
         var _loc4_:Array = !!_loc3_ ? defaultArray : this.holeArray.source;
         var _loc5_:Number = !!_loc3_ ? Number(_loc2_) : Number(_loc2_ / this.radius.getVal());
         param1.lineStyle(1,13684800);
         param1.moveTo((_loc4_[0].x - this.centerX.getVal()) * _loc5_ + this.gridArea.xOrigin,this.gridArea.yOrigin - (_loc4_[0].y - this.centerY.getVal()) * _loc5_);
         param1.lineTo(this.gridArea.xOrigin,this.gridArea.yOrigin);
         param1.lineTo(this.gridArea.xOrigin + _loc2_,this.gridArea.yOrigin);
         param1.lineStyle(1,0);
         param1.moveTo((_loc4_[_loc4_.length - 1].x - this.centerX.getVal()) * _loc5_ + this.gridArea.xOrigin,this.gridArea.yOrigin - (_loc4_[_loc4_.length - 1].y - this.centerY.getVal()) * _loc5_);
         param1.lineStyle(1,5592405,1);
         for each(_loc6_ in _loc4_)
         {
            param1.lineTo((_loc6_.x - this.centerX.getVal()) * _loc5_ + this.gridArea.xOrigin,this.gridArea.yOrigin - (_loc6_.y - this.centerY.getVal()) * _loc5_);
            param1.beginFill(0,0.2);
            param1.lineStyle(1,5592405,1);
            param1.drawCircle((_loc6_.x - this.centerX.getVal()) * _loc5_ + this.gridArea.xOrigin,this.gridArea.yOrigin - (_loc6_.y - this.centerY.getVal()) * _loc5_,boltRadius);
            param1.endFill();
            param1.moveTo((_loc6_.x - this.centerX.getVal()) * _loc5_ + this.gridArea.xOrigin,this.gridArea.yOrigin - (_loc6_.y - this.centerY.getVal()) * _loc5_);
         }
      }
      
      private function clear() : void
      {
         this.nBolts.resetOverride(true);
         this.radius.resetOverride(true);
         this.startAngle.resetOverride(true);
         this.centerX.resetOverride(true);
         this.centerY.resetOverride(true);
         this.recalc();
      }
      
      private function save() : void
      {
         var _loc1_:GWizCSVUtils = new GWizCSVUtils();
         _loc1_.exportCSVData(this.holeArray,this.holeArrayFieldList,this.bcFiles);
      }
      
      private function _GWizBoltCircle_GridComponent1_i() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.xOriginPos = 50;
         _loc1_.yOriginPos = 50;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizBoltCircle_Array3_c);
         _loc1_.setStyle("skinClass",GridSkin);
         _loc1_.id = "gridArea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.gridArea = _loc1_;
         BindingManager.executeBindings(this,"gridArea",this.gridArea);
         return _loc1_;
      }
      
      private function _GWizBoltCircle_Array3_c() : Array
      {
         return [this._GWizBoltCircle_GWizNumStepOvr1_i(),this._GWizBoltCircle_GWizNumStepOvr2_i(),this._GWizBoltCircle_GWizNumStepOvr3_i(),this._GWizBoltCircle_GWizNumStepOvr4_i(),this._GWizBoltCircle_GWizNumStepOvr5_i(),this._GWizBoltCircle_Button1_i(),this._GWizBoltCircle_Button2_i()];
      }
      
      private function _GWizBoltCircle_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "# of Bolts";
         _loc1_.labelWidth = 90;
         _loc1_.y = 10;
         _loc1_.min = 0;
         _loc1_.steps = 1;
         _loc1_.max = 1000;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__nBolts_valueCommit);
         _loc1_.id = "nBolts";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.nBolts = _loc1_;
         BindingManager.executeBindings(this,"nBolts",this.nBolts);
         return _loc1_;
      }
      
      public function __nBolts_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizBoltCircle_GWizNumStepOvr2_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Circle Radius";
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.max = 10000;
         _loc1_.labelWidth = 90;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__radius_valueCommit);
         _loc1_.id = "radius";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.radius = _loc1_;
         BindingManager.executeBindings(this,"radius",this.radius);
         return _loc1_;
      }
      
      public function __radius_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizBoltCircle_GWizNumStepOvr3_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Start Angle";
         _loc1_.suffix = "°";
         _loc1_.labelWidth = 90;
         _loc1_.noUnits = true;
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.max = 360;
         _loc1_.addEventListener("valueCommit",this.__startAngle_valueCommit);
         _loc1_.id = "startAngle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.startAngle = _loc1_;
         BindingManager.executeBindings(this,"startAngle",this.startAngle);
         return _loc1_;
      }
      
      public function __startAngle_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizBoltCircle_GWizNumStepOvr4_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Circle X";
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.max = 10000;
         _loc1_.labelWidth = 90;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__centerX_valueCommit);
         _loc1_.id = "centerX";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.centerX = _loc1_;
         BindingManager.executeBindings(this,"centerX",this.centerX);
         return _loc1_;
      }
      
      public function __centerX_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizBoltCircle_GWizNumStepOvr5_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Circle Y";
         _loc1_.min = 0;
         _loc1_.steps = 0.0001;
         _loc1_.max = 10000;
         _loc1_.labelWidth = 90;
         _loc1_.noUnits = true;
         _loc1_.addEventListener("valueCommit",this.__centerY_valueCommit);
         _loc1_.id = "centerY";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.centerY = _loc1_;
         BindingManager.executeBindings(this,"centerY",this.centerY);
         return _loc1_;
      }
      
      public function __centerY_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizBoltCircle_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.top = 10;
         _loc1_.right = 10;
         _loc1_.label = "Clear";
         _loc1_.addEventListener("click",this.__Clear_click);
         _loc1_.id = "Clear";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Clear = _loc1_;
         BindingManager.executeBindings(this,"Clear",this.Clear);
         return _loc1_;
      }
      
      public function __Clear_click(param1:MouseEvent) : void
      {
         this.clear();
      }
      
      private function _GWizBoltCircle_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.right = 10;
         _loc1_.label = "Save";
         _loc1_.addEventListener("click",this.__Save_click);
         _loc1_.id = "Save";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Save = _loc1_;
         BindingManager.executeBindings(this,"Save",this.Save);
         return _loc1_;
      }
      
      public function __Save_click(param1:MouseEvent) : void
      {
         this.save();
      }
      
      private function _GWizBoltCircle_GWizPanel1_i() : GWizPanel
      {
         var _loc1_:GWizPanel = new GWizPanel();
         _loc1_.darkBack = true;
         _loc1_.title = "";
         _loc1_.layout = this._GWizBoltCircle_VerticalLayout2_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizBoltCircle_Array4_c);
         _loc1_.setStyle("skinClass",PanelSkin);
         _loc1_.id = "_GWizBoltCircle_GWizPanel1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizBoltCircle_GWizPanel1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizBoltCircle_GWizPanel1",this._GWizBoltCircle_GWizPanel1);
         return _loc1_;
      }
      
      private function _GWizBoltCircle_VerticalLayout2_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.gap = 1;
         return _loc1_;
      }
      
      private function _GWizBoltCircle_Array4_c() : Array
      {
         return [this._GWizBoltCircle_HGroup1_c(),this._GWizBoltCircle_List1_i()];
      }
      
      private function _GWizBoltCircle_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.gap = 1;
         _loc1_.mxmlContent = [this._GWizBoltCircle_Label1_c(),this._GWizBoltCircle_Label2_c(),this._GWizBoltCircle_Label3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBoltCircle_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 30;
         _loc1_.text = "Angle";
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","center");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBoltCircle_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 35;
         _loc1_.text = "x";
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","center");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBoltCircle_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 35;
         _loc1_.text = "y";
         _loc1_.setStyle("backgroundColor",2236962);
         _loc1_.setStyle("color",16711422);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","center");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBoltCircle_List1_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.itemRenderer = this._GWizBoltCircle_ClassFactory1_c();
         _loc1_.setStyle("alternatingItemColors",[16711422,15790320]);
         _loc1_.id = "_GWizBoltCircle_List1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizBoltCircle_List1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizBoltCircle_List1",this._GWizBoltCircle_List1);
         return _loc1_;
      }
      
      private function _GWizBoltCircle_ClassFactory1_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizBoltCircleInnerClass0;
         _loc1_.properties = {"outerDocument":this};
         return _loc1_;
      }
      
      public function ___GWizBoltCircle_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.restoreViewData();
      }
      
      public function ___GWizBoltCircle_Group1_show(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizBoltCircle_VerticalLayout1_c() : VerticalLayout
      {
         return new VerticalLayout();
      }
      
      private function _GWizBoltCircle_HorizontalLayout1_c() : HorizontalLayout
      {
         return new HorizontalLayout();
      }
      
      private function _GWizBoltCircle_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Function
         {
            return drawShape;
         },null,"gridArea.drawFunc");
         result[1] = new Binding(this,function():Number
         {
            return gridArea.xOrigin - 95;
         },null,"nBolts.x");
         result[2] = new Binding(this,function():Number
         {
            return gridArea.xOrigin - 95;
         },null,"radius.x");
         result[3] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - gridArea.yMax / 2;
         },null,"radius.y");
         result[4] = new Binding(this,function():Number
         {
            return gridArea.xOrigin - 95;
         },null,"startAngle.x");
         result[5] = new Binding(this,function():Number
         {
            return gridArea.yOrigin - 20;
         },null,"startAngle.y");
         result[6] = new Binding(this,function():Number
         {
            return gridArea.xOrigin - 95;
         },null,"centerX.x");
         result[7] = new Binding(this,function():Number
         {
            return gridArea.yOrigin + 10;
         },null,"centerX.y");
         result[8] = new Binding(this,function():Number
         {
            return gridArea.xOrigin - 95;
         },null,"centerY.x");
         result[9] = new Binding(this,function():Number
         {
            return gridArea.yOrigin + 45;
         },null,"centerY.y");
         result[10] = new Binding(this,function():Object
         {
            return Clear.top + 3 + Clear.height;
         },null,"Save.top");
         result[11] = new Binding(this,function():Number
         {
            return Clear.width;
         },null,"Save.width");
         result[12] = new Binding(this,function():IList
         {
            return holeArray;
         },null,"_GWizBoltCircle_List1.dataProvider");
         result[13] = new Binding(this,function():uint
         {
            return ColorUtil.adjustBrightness2(getStyle("backgroundColor"),60);
         },function(param1:uint):void
         {
            _GWizBoltCircle_List1.setStyle("selectionColor",param1);
         },"_GWizBoltCircle_List1.selectionColor");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Clear() : Button
      {
         return this._65193517Clear;
      }
      
      public function set Clear(param1:Button) : void
      {
         var _loc2_:Object = this._65193517Clear;
         if(_loc2_ !== param1)
         {
            this._65193517Clear = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Clear",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Save() : Button
      {
         return this._2569629Save;
      }
      
      public function set Save(param1:Button) : void
      {
         var _loc2_:Object = this._2569629Save;
         if(_loc2_ !== param1)
         {
            this._2569629Save = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Save",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizBoltCircle_GWizPanel1() : GWizPanel
      {
         return this._1979520456_GWizBoltCircle_GWizPanel1;
      }
      
      public function set _GWizBoltCircle_GWizPanel1(param1:GWizPanel) : void
      {
         var _loc2_:Object = this._1979520456_GWizBoltCircle_GWizPanel1;
         if(_loc2_ !== param1)
         {
            this._1979520456_GWizBoltCircle_GWizPanel1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizBoltCircle_GWizPanel1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get centerX() : GWizNumStepOvr
      {
         return this._665239203centerX;
      }
      
      public function set centerX(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._665239203centerX;
         if(_loc2_ !== param1)
         {
            this._665239203centerX = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"centerX",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get centerY() : GWizNumStepOvr
      {
         return this._665239204centerY;
      }
      
      public function set centerY(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._665239204centerY;
         if(_loc2_ !== param1)
         {
            this._665239204centerY = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"centerY",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get gridArea() : GridComponent
      {
         return this._317504755gridArea;
      }
      
      public function set gridArea(param1:GridComponent) : void
      {
         var _loc2_:Object = this._317504755gridArea;
         if(_loc2_ !== param1)
         {
            this._317504755gridArea = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"gridArea",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get nBolts() : GWizNumStepOvr
      {
         return this._1081394000nBolts;
      }
      
      public function set nBolts(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1081394000nBolts;
         if(_loc2_ !== param1)
         {
            this._1081394000nBolts = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"nBolts",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get radius() : GWizNumStepOvr
      {
         return this._938578798radius;
      }
      
      public function set radius(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._938578798radius;
         if(_loc2_ !== param1)
         {
            this._938578798radius = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"radius",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get startAngle() : GWizNumStepOvr
      {
         return this._1601031791startAngle;
      }
      
      public function set startAngle(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._1601031791startAngle;
         if(_loc2_ !== param1)
         {
            this._1601031791startAngle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"startAngle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get holeArray() : ArrayCollection
      {
         return this._1202947449holeArray;
      }
      
      private function set holeArray(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._1202947449holeArray;
         if(_loc2_ !== param1)
         {
            this._1202947449holeArray = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"holeArray",_loc2_,param1));
            }
         }
      }
   }
}
