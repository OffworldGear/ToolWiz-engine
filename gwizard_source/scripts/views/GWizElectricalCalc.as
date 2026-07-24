package views
{
   import comps.GWizForePanel;
   import comps.GWizNumStep;
   import comps.GWizNumStepOvr;
   import flash.display.GradientType;
   import flash.display.Graphics;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.utils.Proxy;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.containers.ViewStack;
   import mx.controls.Spacer;
   import mx.core.ClassFactory;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponentDescriptor;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.ButtonBar;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.List;
   import spark.components.NavigatorContent;
   import spark.components.RadioButton;
   import spark.components.VGroup;
   import spark.layouts.VerticalLayout;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizElectricalCalc extends VGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _69E:GWizNumStepOvr;
      
      private var _1145796631EnterOhms:GWizNumStep;
      
      private var _1807401085FirstDigit:List;
      
      private var _73I:GWizNumStepOvr;
      
      private var _302765621Label4Band:Label;
      
      private var _303689142Label5Band:Label;
      
      private var _304612663Label6Band:Label;
      
      private var _1036428831Multiplier:List;
      
      private var _80P:GWizNumStepOvr;
      
      private var _82R:GWizNumStepOvr;
      
      private var _1908053241SecondDigit:List;
      
      private var _1258110943TempCoef:List;
      
      private var _1012672550ThirdDigit:List;
      
      private var _1257926675Tolerance:List;
      
      private var _541144369Use4Bands:RadioButton;
      
      public var _GWizElectricalCalc_ButtonBar1:ButtonBar;
      
      public var _GWizElectricalCalc_Image1:Image;
      
      public var _GWizElectricalCalc_Image2:Image;
      
      public var _GWizElectricalCalc_Image3:Image;
      
      private var _2060356430colorEntryRenderer:ClassFactory;
      
      private var _713637562electricalViews:ViewStack;
      
      private var _1343731790msgText:Label;
      
      private var _3496849res1:HGroup;
      
      private var _3496850res2:HGroup;
      
      private var _3496851res3:HGroup;
      
      private var _376413029resImage:Group;
      
      private var _656460527resistorImageGroup:Group;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private const ResistorImage:Class = GWizElectricalCalc_ResistorImage;
      
      private var _1108604178digitBandColors:Array;
      
      private var _370138266digitBandNames:ArrayCollection;
      
      private var _770382507multBandColors:Array;
      
      private var _1816224061multBandNames:ArrayCollection;
      
      private var _672292918tolBandColors:Array;
      
      private var _447071170tolBandNames:ArrayCollection;
      
      private var _887891207tempBandColors:Array;
      
      private var _1643668639tempBandNames:ArrayCollection;
      
      private var resistor1Colors:Array;
      
      private var resistor2Colors:Array;
      
      private var resistor3Colors:Array;
      
      private var calcInProgress:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizElectricalCalc()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._1108604178digitBandColors = ["0x000000","0x97331b","0xec1f24","0xf4661e","0xf6eb13","0x05833c","0x3a53a5","0x7c267d","0x707070","0xfbf9fa"];
         this._370138266digitBandNames = new ArrayCollection([{
            "label":"0",
            "data":0
         },{
            "label":"1",
            "data":1
         },{
            "label":"2",
            "data":2
         },{
            "label":"3",
            "data":3
         },{
            "label":"4",
            "data":4
         },{
            "label":"5",
            "data":5
         },{
            "label":"6",
            "data":6
         },{
            "label":"7",
            "data":7
         },{
            "label":"8",
            "data":8
         },{
            "label":"9",
            "data":9
         }]);
         this._770382507multBandColors = ["0xdedcdd","0xf5da11","0x000000","0x97331b","0xec1f24","0xf4661e","0xf6eb13","0x05833c","0x3a53a5","0x7c267d"];
         this._1816224061multBandNames = new ArrayCollection([{
            "label":"Silver - 0.01",
            "data":0.01
         },{
            "label":"Gold - 0.1",
            "data":0.1
         },{
            "label":"Black - 1",
            "data":1
         },{
            "label":"Brown - 10",
            "data":10
         },{
            "label":"Red - 100",
            "data":100
         },{
            "label":"Orange - 1K",
            "data":1000
         },{
            "label":"Yellow - 10K",
            "data":10000
         },{
            "label":"Green - 100K",
            "data":100000
         },{
            "label":"Blue - 1M",
            "data":1000000
         },{
            "label":"Violet - 10M",
            "data":10000000
         }]);
         this._672292918tolBandColors = ["0xdedcdd","0xf5da11","0x97331b","0xec1f24","0x05833c","0x3a53a5","0x7c267d"];
         this._447071170tolBandNames = new ArrayCollection([{
            "label":"Silver - 10%",
            "data":10
         },{
            "label":"Gold - 5%",
            "data":5
         },{
            "label":"Brown - 1%",
            "data":1
         },{
            "label":"Red - 2%",
            "data":2
         },{
            "label":"Green - 0.5%",
            "data":0.5
         },{
            "label":"Blue - 0.25%",
            "data":0.25
         },{
            "label":"Violet - 0.1%",
            "data":0.1
         }]);
         this._887891207tempBandColors = ["0x97331b","0xec1f24","0xf4661e","0xf6eb13"];
         this._1643668639tempBandNames = new ArrayCollection([{"label":"Brown - 100ppm"},{"label":"Red - 50ppm"},{"label":"Orange - 15ppm"},{"label":"Yellow - 25ppm"}]);
         this.resistor1Colors = ["0x000000","0x000000","0x000000","0x000000"];
         this.resistor2Colors = ["0x000000","0x000000","0x000000","0x000000","0x000000"];
         this.resistor3Colors = ["0x000000","0x000000","0x000000","0x000000","0x000000","0x000000"];
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizElectricalCalc_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_views_GWizElectricalCalcWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizElectricalCalc[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.styleName = "refView";
         this.paddingBottom = 10;
         this.paddingLeft = 10;
         this.paddingRight = 10;
         this.paddingTop = 10;
         this.horizontalAlign = "center";
         this.mxmlContent = [this._GWizElectricalCalc_ButtonBar1_i(),this._GWizElectricalCalc_ViewStack1_i()];
         this._GWizElectricalCalc_ClassFactory1_i();
         this.addEventListener("creationComplete",this.___GWizElectricalCalc_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizElectricalCalc._watcherSetupUtil = param1;
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
      
      private function doEnterOhms() : void
      {
         var _loc1_:Number = this.EnterOhms.getVal();
         if(_loc1_ >= 100000000)
         {
            this.Multiplier.selectedIndex = 9;
            _loc1_ /= 10000000;
         }
         else if(_loc1_ >= 10000000)
         {
            this.Multiplier.selectedIndex = 8;
            _loc1_ /= 1000000;
         }
         else if(_loc1_ >= 1000000)
         {
            this.Multiplier.selectedIndex = 7;
            _loc1_ /= 100000;
         }
         else if(_loc1_ >= 100000)
         {
            this.Multiplier.selectedIndex = 6;
            _loc1_ /= 10000;
         }
         else if(_loc1_ >= 10000)
         {
            this.Multiplier.selectedIndex = 5;
            _loc1_ /= 1000;
         }
         else if(_loc1_ >= 1000)
         {
            this.Multiplier.selectedIndex = 4;
            _loc1_ /= 100;
         }
         else if(_loc1_ >= 100)
         {
            this.Multiplier.selectedIndex = 3;
            _loc1_ /= 10;
         }
         else if(_loc1_ >= 10)
         {
            this.Multiplier.selectedIndex = 2;
            _loc1_ /= 1;
         }
         else if(_loc1_ >= 1)
         {
            this.Multiplier.selectedIndex = 1;
            _loc1_ /= 0.1;
         }
         else
         {
            this.Multiplier.selectedIndex = 0;
            _loc1_ /= 0.01;
         }
         if(this.Use4Bands.selected)
         {
            if(_loc1_ > 10)
            {
               this.FirstDigit.selectedIndex = int(_loc1_ / 10);
               _loc1_ -= this.FirstDigit.selectedIndex * 10;
            }
            this.SecondDigit.selectedIndex = int(_loc1_);
         }
         else
         {
            _loc1_ *= 10;
            this.Multiplier.selectedIndex = Math.max(0,this.Multiplier.selectedIndex - 1);
            if(_loc1_ > 100)
            {
               this.FirstDigit.selectedIndex = int(_loc1_ / 100);
               _loc1_ -= this.FirstDigit.selectedIndex * 100;
            }
            if(_loc1_ > 10)
            {
               this.SecondDigit.selectedIndex = int(_loc1_ / 10);
               _loc1_ -= this.SecondDigit.selectedIndex * 10;
            }
            this.ThirdDigit.selectedIndex = int(_loc1_);
         }
         this.doBands();
      }
      
      private function matchColor(param1:List, param2:Object, param3:Array) : Number
      {
         var _loc4_:Object = param3[param1.selectedIndex];
         var _loc5_:Array;
         (_loc5_ = [])[0] = _loc4_;
         _loc5_[1] = _loc4_;
         return param1.selectedItem.data;
      }
      
      private function doBands() : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(!this.FirstDigit)
         {
            this.callLater(this.doBands);
            return;
         }
         var _loc1_:Number = 0;
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         _loc4_ = this.FirstDigit.selectedItem.data;
         _loc5_ = this.SecondDigit.selectedItem.data;
         _loc6_ = this.ThirdDigit.selectedItem.data;
         _loc1_ = _loc4_ * 10 + _loc5_;
         _loc2_ = _loc4_ * 100 + _loc5_ * 10 + _loc6_;
         _loc4_ = this.Multiplier.selectedItem.data;
         _loc1_ *= _loc4_;
         _loc2_ *= _loc4_;
         this.Label4Band.text = String(_loc1_) + " Ohms";
         this.Label5Band.text = String(_loc2_) + " Ohms";
         _loc4_ = this.Tolerance.selectedItem.data;
         this.Label4Band.text += " +/-" + String(_loc4_) + "%";
         this.Label5Band.text += " +/-" + String(_loc4_) + "%";
         _loc4_ = this.TempCoef.selectedItem.data;
         this.Label6Band.text = this.Label5Band.text;
         this.drawBands();
      }
      
      private function drawBands() : void
      {
         var _loc1_:Graphics = this.resImage.graphics;
         this.drawBand(_loc1_,this.res1,1,this.digitBandColors[this.FirstDigit.selectedIndex]);
         this.drawBand(_loc1_,this.res2,1,this.digitBandColors[this.FirstDigit.selectedIndex]);
         this.drawBand(_loc1_,this.res3,1,this.digitBandColors[this.FirstDigit.selectedIndex]);
         this.drawBand(_loc1_,this.res1,2,this.digitBandColors[this.SecondDigit.selectedIndex]);
         this.drawBand(_loc1_,this.res2,2,this.digitBandColors[this.SecondDigit.selectedIndex]);
         this.drawBand(_loc1_,this.res3,2,this.digitBandColors[this.SecondDigit.selectedIndex]);
         this.drawBand(_loc1_,this.res2,3,this.digitBandColors[this.ThirdDigit.selectedIndex]);
         this.drawBand(_loc1_,this.res3,3,this.digitBandColors[this.ThirdDigit.selectedIndex]);
         this.drawBand(_loc1_,this.res1,3,this.multBandColors[this.Multiplier.selectedIndex]);
         this.drawBand(_loc1_,this.res2,4,this.multBandColors[this.Multiplier.selectedIndex]);
         this.drawBand(_loc1_,this.res3,4,this.multBandColors[this.Multiplier.selectedIndex]);
         this.drawBand(_loc1_,this.res1,6,this.tolBandColors[this.Tolerance.selectedIndex]);
         this.drawBand(_loc1_,this.res2,6,this.tolBandColors[this.Tolerance.selectedIndex]);
         this.drawBand(_loc1_,this.res3,6,this.tolBandColors[this.Tolerance.selectedIndex]);
         this.drawBand(_loc1_,this.res3,7,this.tempBandColors[this.TempCoef.selectedIndex]);
      }
      
      private function drawBand(param1:Graphics, param2:Object, param3:int, param4:uint) : void
      {
         var _loc5_:int = param2.x + 230 + param3 * 15;
         var _loc6_:int = param2.y + 25;
         var _loc7_:Matrix;
         (_loc7_ = new Matrix()).createGradientBox(10,49,GWizUtils.radians(90),_loc5_,_loc6_);
         param1.lineStyle();
         param1.beginGradientFill(GradientType.LINEAR,[param4,0],[1,1],[50,255],_loc7_);
         param1.drawRect(_loc5_,_loc6_,10,49);
         param1.endFill();
      }
      
      private function empty(param1:GWizNumStepOvr) : Boolean
      {
         return param1.getVal() == 0;
      }
      
      private function recalc() : void
      {
         if(this.calcInProgress)
         {
            return;
         }
         this.calcInProgress = true;
         var _loc1_:Boolean = !!this.P.isOverridden() ? true : false;
         var _loc2_:Boolean = !!this.I.isOverridden() ? true : false;
         var _loc3_:Boolean = !!this.R.isOverridden() ? true : false;
         var _loc4_:Boolean = !!this.E.isOverridden() ? true : false;
         var _loc5_:int;
         if((_loc5_ = (!!_loc1_ ? 1 : 0) + (!!_loc2_ ? 1 : 0) + (!!_loc3_ ? 1 : 0) + (!!_loc4_ ? 1 : 0)) > 2)
         {
            this.msgText.text = "Too many values entered.  Please clear values by selecting lock symbol.";
            this.msgText.setStyle("color","0xFF0000");
            this.calcInProgress = false;
            return;
         }
         this.msgText.text = "Enter any two values.";
         this.msgText.setStyle("color","black");
         if(!_loc1_)
         {
            if(_loc2_ && _loc3_)
            {
               this.P.setVal(this.I.getVal() * this.I.getVal() * this.R.getVal());
            }
            else if(_loc2_ && _loc4_)
            {
               this.P.setVal(this.E.getVal() * this.I.getVal());
            }
            else if(_loc4_ && _loc3_)
            {
               this.P.setVal(this.E.getVal() * this.E.getVal() / this.R.getVal());
            }
         }
         if(!_loc4_)
         {
            if(_loc2_ && _loc3_)
            {
               this.E.setVal(this.I.getVal() * this.R.getVal());
            }
            else if(_loc1_ && _loc2_)
            {
               this.E.setVal(this.P.getVal() / this.I.getVal());
            }
            else if(_loc1_ && _loc3_)
            {
               this.E.setVal(Math.sqrt(this.P.getVal() * this.R.getVal()));
            }
         }
         if(!_loc3_)
         {
            if(_loc4_ && _loc2_)
            {
               this.R.setVal(this.E.getVal() / this.I.getVal());
            }
            else if(_loc4_ && _loc1_)
            {
               this.R.setVal(this.E.getVal() * this.E.getVal() / this.P.getVal());
            }
            else if(_loc2_ && _loc1_)
            {
               this.R.setVal(this.P.getVal() / (this.I.getVal() * this.I.getVal()));
            }
         }
         if(!_loc2_)
         {
            if(_loc4_ && _loc3_)
            {
               this.I.setVal(this.E.getVal() / this.R.getVal());
            }
            else if(_loc1_ && _loc4_)
            {
               this.I.setVal(this.P.getVal() / this.E.getVal());
            }
            else if(_loc1_ && _loc3_)
            {
               this.I.setVal(Math.sqrt(this.P.getVal() / this.R.getVal()));
            }
         }
         this.calcInProgress = false;
      }
      
      private function clearAll() : void
      {
         this.E.resetOverride(true);
         this.I.resetOverride(true);
         this.R.resetOverride(true);
         this.P.resetOverride(true);
      }
      
      private function _GWizElectricalCalc_ClassFactory1_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizElectricalCalcInnerClass0;
         _loc1_.properties = {"outerDocument":this};
         this.colorEntryRenderer = _loc1_;
         BindingManager.executeBindings(this,"colorEntryRenderer",this.colorEntryRenderer);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_ButtonBar1_i() : ButtonBar
      {
         var _loc1_:ButtonBar = new ButtonBar();
         _loc1_.requireSelection = true;
         _loc1_.id = "_GWizElectricalCalc_ButtonBar1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizElectricalCalc_ButtonBar1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizElectricalCalc_ButtonBar1",this._GWizElectricalCalc_ButtonBar1);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_ViewStack1_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.id = "electricalViews";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"electricalViews",
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Ohms/Power",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizElectricalCalc_Array2_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Resistors",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizElectricalCalc_Array8_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.electricalViews = temp;
         BindingManager.executeBindings(this,"electricalViews",this.electricalViews);
         return temp;
      }
      
      private function _GWizElectricalCalc_Array2_c() : Array
      {
         return [this._GWizElectricalCalc_GWizForePanel1_c()];
      }
      
      private function _GWizElectricalCalc_GWizForePanel1_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.layout = this._GWizElectricalCalc_VerticalLayout1_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizElectricalCalc_Array3_c);
         _loc1_.setStyle("color",0);
         _loc1_.setStyle("backgroundColor",10461087);
         _loc1_.setStyle("backgroundAlpha",1);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_VerticalLayout1_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 10;
         _loc1_.paddingRight = 10;
         _loc1_.paddingTop = 10;
         _loc1_.gap = 10;
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Array3_c() : Array
      {
         return [this._GWizElectricalCalc_Label1_i(),this._GWizElectricalCalc_HGroup1_c(),this._GWizElectricalCalc_HGroup2_c(),this._GWizElectricalCalc_HGroup3_c(),this._GWizElectricalCalc_HGroup4_c(),this._GWizElectricalCalc_Label2_c()];
      }
      
      private function _GWizElectricalCalc_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Enter any two values.";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "msgText";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.msgText = _loc1_;
         BindingManager.executeBindings(this,"msgText",this.msgText);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizElectricalCalc_GWizNumStepOvr1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_GWizNumStepOvr1_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Voltage (E or V)";
         _loc1_.suffix = " volts";
         _loc1_.labelWidth = 200;
         _loc1_.noUnits = true;
         _loc1_.min = -100000;
         _loc1_.max = 100000;
         _loc1_.steps = 0.1;
         _loc1_.addEventListener("change",this.__E_change);
         _loc1_.id = "E";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.E = _loc1_;
         BindingManager.executeBindings(this,"E",this.E);
         return _loc1_;
      }
      
      public function __E_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizElectricalCalc_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizElectricalCalc_GWizNumStepOvr2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_GWizNumStepOvr2_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Current (I)";
         _loc1_.suffix = " amperes or amps";
         _loc1_.labelWidth = 200;
         _loc1_.noUnits = true;
         _loc1_.min = -100000;
         _loc1_.max = 100000;
         _loc1_.steps = 0.1;
         _loc1_.addEventListener("change",this.__I_change);
         _loc1_.id = "I";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.I = _loc1_;
         BindingManager.executeBindings(this,"I",this.I);
         return _loc1_;
      }
      
      public function __I_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizElectricalCalc_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizElectricalCalc_GWizNumStepOvr3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_GWizNumStepOvr3_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Resistance (R)";
         _loc1_.suffix = " ohms";
         _loc1_.labelWidth = 200;
         _loc1_.noUnits = true;
         _loc1_.min = -10000000;
         _loc1_.max = 10000000;
         _loc1_.steps = 0.1;
         _loc1_.addEventListener("change",this.__R_change);
         _loc1_.id = "R";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.R = _loc1_;
         BindingManager.executeBindings(this,"R",this.R);
         return _loc1_;
      }
      
      public function __R_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizElectricalCalc_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizElectricalCalc_GWizNumStepOvr4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_GWizNumStepOvr4_i() : GWizNumStepOvr
      {
         var _loc1_:GWizNumStepOvr = new GWizNumStepOvr();
         _loc1_.titleTxt = "Power (P)";
         _loc1_.suffix = " watts";
         _loc1_.labelWidth = 200;
         _loc1_.noUnits = true;
         _loc1_.min = -10000000;
         _loc1_.max = 10000000;
         _loc1_.steps = 0.1;
         _loc1_.addEventListener("change",this.__P_change);
         _loc1_.id = "P";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.P = _loc1_;
         BindingManager.executeBindings(this,"P",this.P);
         return _loc1_;
      }
      
      public function __P_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizElectricalCalc_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Array8_c() : Array
      {
         return [this._GWizElectricalCalc_GWizForePanel2_c()];
      }
      
      private function _GWizElectricalCalc_GWizForePanel2_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.layout = this._GWizElectricalCalc_VerticalLayout2_c();
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizElectricalCalc_Array9_c);
         _loc1_.setStyle("color",0);
         _loc1_.setStyle("backgroundColor",10461087);
         _loc1_.setStyle("backgroundAlpha",1);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_VerticalLayout2_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 10;
         _loc1_.paddingRight = 10;
         _loc1_.paddingTop = 10;
         _loc1_.gap = 0;
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Array9_c() : Array
      {
         return [this._GWizElectricalCalc_HGroup5_c(),this._GWizElectricalCalc_HGroup6_c()];
      }
      
      private function _GWizElectricalCalc_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizElectricalCalc_Label3_c(),this._GWizElectricalCalc_GWizNumStep1_i(),this._GWizElectricalCalc_RadioButton1_i(),this._GWizElectricalCalc_RadioButton2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "To see colors";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Enter resistor value in Ohms";
         _loc1_.max = 990000000;
         _loc1_.steps = 0.01;
         _loc1_.usesMetric = false;
         _loc1_.addEventListener("valueCommit",this.__EnterOhms_valueCommit);
         _loc1_.id = "EnterOhms";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.EnterOhms = _loc1_;
         BindingManager.executeBindings(this,"EnterOhms",this.EnterOhms);
         return _loc1_;
      }
      
      public function __EnterOhms_valueCommit(param1:FlexEvent) : void
      {
         this.doEnterOhms();
      }
      
      private function _GWizElectricalCalc_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "4 Band";
         _loc1_.groupName = "BandType";
         _loc1_.selected = true;
         _loc1_.addEventListener("click",this.__Use4Bands_click);
         _loc1_.id = "Use4Bands";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Use4Bands = _loc1_;
         BindingManager.executeBindings(this,"Use4Bands",this.Use4Bands);
         return _loc1_;
      }
      
      public function __Use4Bands_click(param1:MouseEvent) : void
      {
         this.doEnterOhms();
      }
      
      private function _GWizElectricalCalc_RadioButton2_c() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "5 & 6 Band";
         _loc1_.groupName = "BandType";
         _loc1_.addEventListener("click",this.___GWizElectricalCalc_RadioButton2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizElectricalCalc_RadioButton2_click(param1:MouseEvent) : void
      {
         this.doEnterOhms();
      }
      
      private function _GWizElectricalCalc_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizElectricalCalc_Group1_i(),this._GWizElectricalCalc_VGroup6_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Group1_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizElectricalCalc_VGroup2_c(),this._GWizElectricalCalc_Group2_i()];
         _loc1_.id = "resistorImageGroup";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.resistorImageGroup = _loc1_;
         BindingManager.executeBindings(this,"resistorImageGroup",this.resistorImageGroup);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizElectricalCalc_HGroup7_i(),this._GWizElectricalCalc_HGroup8_i(),this._GWizElectricalCalc_HGroup9_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_HGroup7_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizElectricalCalc_VGroup3_c(),this._GWizElectricalCalc_Image1_i()];
         _loc1_.id = "res1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.res1 = _loc1_;
         BindingManager.executeBindings(this,"res1",this.res1);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.width = 120;
         _loc1_.mxmlContent = [this._GWizElectricalCalc_Spacer1_c(),this._GWizElectricalCalc_Label4_c(),this._GWizElectricalCalc_Label5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 2;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "4-Band Color Code";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "10K Ohms +/- 5%";
         _loc1_.id = "Label4Band";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Label4Band = _loc1_;
         BindingManager.executeBindings(this,"Label4Band",this.Label4Band);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.id = "_GWizElectricalCalc_Image1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizElectricalCalc_Image1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizElectricalCalc_Image1",this._GWizElectricalCalc_Image1);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_HGroup8_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizElectricalCalc_VGroup4_c(),this._GWizElectricalCalc_Image2_i()];
         _loc1_.id = "res2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.res2 = _loc1_;
         BindingManager.executeBindings(this,"res2",this.res2);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_VGroup4_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.width = 120;
         _loc1_.mxmlContent = [this._GWizElectricalCalc_Spacer2_c(),this._GWizElectricalCalc_Label6_c(),this._GWizElectricalCalc_Label7_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 2;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "5-Band Color Code";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "10K Ohms +/- 5%";
         _loc1_.id = "Label5Band";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Label5Band = _loc1_;
         BindingManager.executeBindings(this,"Label5Band",this.Label5Band);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Image2_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.id = "_GWizElectricalCalc_Image2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizElectricalCalc_Image2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizElectricalCalc_Image2",this._GWizElectricalCalc_Image2);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_HGroup9_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizElectricalCalc_VGroup5_c(),this._GWizElectricalCalc_Image3_i()];
         _loc1_.id = "res3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.res3 = _loc1_;
         BindingManager.executeBindings(this,"res3",this.res3);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_VGroup5_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.width = 120;
         _loc1_.mxmlContent = [this._GWizElectricalCalc_Spacer3_c(),this._GWizElectricalCalc_Label8_c(),this._GWizElectricalCalc_Label9_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 2;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "6-Band Color Code";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "10K Ohms +/- 5%";
         _loc1_.id = "Label6Band";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Label6Band = _loc1_;
         BindingManager.executeBindings(this,"Label6Band",this.Label6Band);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Image3_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.id = "_GWizElectricalCalc_Image3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizElectricalCalc_Image3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizElectricalCalc_Image3",this._GWizElectricalCalc_Image3);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Group2_i() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "resImage";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.resImage = _loc1_;
         BindingManager.executeBindings(this,"resImage",this.resImage);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_VGroup6_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizElectricalCalc_HGroup10_c(),this._GWizElectricalCalc_HGroup11_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_HGroup10_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizElectricalCalc_VGroup7_c(),this._GWizElectricalCalc_VGroup8_c(),this._GWizElectricalCalc_VGroup9_c(),this._GWizElectricalCalc_VGroup10_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_VGroup7_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 20;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizElectricalCalc_Label10_c(),this._GWizElectricalCalc_List1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Label10_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "1st Digit";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_List1_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.minWidth = 0;
         _loc1_.percentWidth = 100;
         _loc1_.selectedIndex = 0;
         _loc1_.layout = this._GWizElectricalCalc_VerticalLayout3_c();
         _loc1_.setStyle("color",0);
         _loc1_.setStyle("borderAlpha",1);
         _loc1_.setStyle("borderVisible",true);
         _loc1_.setStyle("borderColor",0);
         _loc1_.addEventListener("click",this.__FirstDigit_click);
         _loc1_.id = "FirstDigit";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FirstDigit = _loc1_;
         BindingManager.executeBindings(this,"FirstDigit",this.FirstDigit);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_VerticalLayout3_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.requestedRowCount = 10;
         _loc1_.gap = 1;
         return _loc1_;
      }
      
      public function __FirstDigit_click(param1:MouseEvent) : void
      {
         this.doBands();
      }
      
      private function _GWizElectricalCalc_VGroup8_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 20;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizElectricalCalc_Label11_c(),this._GWizElectricalCalc_List2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Label11_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "2nd Digit";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_List2_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.minWidth = 0;
         _loc1_.percentWidth = 100;
         _loc1_.selectedIndex = 0;
         _loc1_.layout = this._GWizElectricalCalc_VerticalLayout4_c();
         _loc1_.setStyle("color",0);
         _loc1_.setStyle("borderAlpha",1);
         _loc1_.setStyle("borderVisible",true);
         _loc1_.setStyle("borderColor",0);
         _loc1_.addEventListener("click",this.__SecondDigit_click);
         _loc1_.id = "SecondDigit";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.SecondDigit = _loc1_;
         BindingManager.executeBindings(this,"SecondDigit",this.SecondDigit);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_VerticalLayout4_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.requestedRowCount = 10;
         _loc1_.gap = 1;
         return _loc1_;
      }
      
      public function __SecondDigit_click(param1:MouseEvent) : void
      {
         this.doBands();
      }
      
      private function _GWizElectricalCalc_VGroup9_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 20;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizElectricalCalc_Label12_c(),this._GWizElectricalCalc_List3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Label12_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "3rd Digit";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_List3_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.minWidth = 0;
         _loc1_.percentWidth = 100;
         _loc1_.selectedIndex = 0;
         _loc1_.layout = this._GWizElectricalCalc_VerticalLayout5_c();
         _loc1_.setStyle("color",0);
         _loc1_.setStyle("borderAlpha",1);
         _loc1_.setStyle("borderVisible",true);
         _loc1_.setStyle("borderColor",0);
         _loc1_.addEventListener("click",this.__ThirdDigit_click);
         _loc1_.id = "ThirdDigit";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ThirdDigit = _loc1_;
         BindingManager.executeBindings(this,"ThirdDigit",this.ThirdDigit);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_VerticalLayout5_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.requestedRowCount = 10;
         _loc1_.gap = 1;
         return _loc1_;
      }
      
      public function __ThirdDigit_click(param1:MouseEvent) : void
      {
         this.doBands();
      }
      
      private function _GWizElectricalCalc_VGroup10_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 40;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizElectricalCalc_Label13_c(),this._GWizElectricalCalc_List4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Label13_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Multiplier";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_List4_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.minWidth = 0;
         _loc1_.percentWidth = 100;
         _loc1_.selectedIndex = 0;
         _loc1_.layout = this._GWizElectricalCalc_VerticalLayout6_c();
         _loc1_.setStyle("color",0);
         _loc1_.setStyle("borderAlpha",1);
         _loc1_.setStyle("borderVisible",true);
         _loc1_.setStyle("borderColor",0);
         _loc1_.addEventListener("click",this.__Multiplier_click);
         _loc1_.id = "Multiplier";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Multiplier = _loc1_;
         BindingManager.executeBindings(this,"Multiplier",this.Multiplier);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_VerticalLayout6_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.requestedRowCount = 10;
         _loc1_.gap = 1;
         return _loc1_;
      }
      
      public function __Multiplier_click(param1:MouseEvent) : void
      {
         this.doBands();
      }
      
      private function _GWizElectricalCalc_HGroup11_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizElectricalCalc_VGroup11_c(),this._GWizElectricalCalc_VGroup12_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_VGroup11_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 50;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizElectricalCalc_Label14_c(),this._GWizElectricalCalc_List5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Label14_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Tolerance";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_List5_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.minWidth = 0;
         _loc1_.percentWidth = 100;
         _loc1_.selectedIndex = 0;
         _loc1_.layout = this._GWizElectricalCalc_VerticalLayout7_c();
         _loc1_.setStyle("color",0);
         _loc1_.setStyle("borderAlpha",1);
         _loc1_.setStyle("borderVisible",true);
         _loc1_.setStyle("borderColor",0);
         _loc1_.addEventListener("click",this.__Tolerance_click);
         _loc1_.id = "Tolerance";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Tolerance = _loc1_;
         BindingManager.executeBindings(this,"Tolerance",this.Tolerance);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_VerticalLayout7_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.requestedRowCount = 7;
         _loc1_.gap = 1;
         return _loc1_;
      }
      
      public function __Tolerance_click(param1:MouseEvent) : void
      {
         this.doBands();
      }
      
      private function _GWizElectricalCalc_VGroup12_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 50;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizElectricalCalc_Label15_c(),this._GWizElectricalCalc_List6_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_Label15_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Temp Coef.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_List6_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.minWidth = 0;
         _loc1_.percentWidth = 100;
         _loc1_.selectedIndex = 0;
         _loc1_.layout = this._GWizElectricalCalc_VerticalLayout8_c();
         _loc1_.setStyle("color",0);
         _loc1_.setStyle("borderAlpha",1);
         _loc1_.setStyle("borderVisible",true);
         _loc1_.setStyle("borderColor",0);
         _loc1_.addEventListener("click",this.__TempCoef_click);
         _loc1_.id = "TempCoef";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.TempCoef = _loc1_;
         BindingManager.executeBindings(this,"TempCoef",this.TempCoef);
         return _loc1_;
      }
      
      private function _GWizElectricalCalc_VerticalLayout8_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.requestedRowCount = 4;
         _loc1_.gap = 1;
         return _loc1_;
      }
      
      public function __TempCoef_click(param1:MouseEvent) : void
      {
         this.doBands();
      }
      
      public function ___GWizElectricalCalc_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.doBands();
      }
      
      private function _GWizElectricalCalc_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,null,null,"_GWizElectricalCalc_ButtonBar1.dataProvider","electricalViews");
         result[1] = new Binding(this,function():Object
         {
            return ResistorImage;
         },null,"_GWizElectricalCalc_Image1.source");
         result[2] = new Binding(this,function():Object
         {
            return ResistorImage;
         },null,"_GWizElectricalCalc_Image2.source");
         result[3] = new Binding(this,function():Object
         {
            return ResistorImage;
         },null,"_GWizElectricalCalc_Image3.source");
         result[4] = new Binding(this,function():Array
         {
            var _loc1_:* = digitBandColors;
            return _loc1_ == null || _loc1_ is Array || _loc1_ is Proxy ? _loc1_ : [_loc1_];
         },function(param1:Array):void
         {
            FirstDigit.setStyle("alternatingItemColors",param1);
         },"FirstDigit.alternatingItemColors");
         result[5] = new Binding(this,function():IList
         {
            return digitBandNames;
         },null,"FirstDigit.dataProvider");
         result[6] = new Binding(this,null,null,"FirstDigit.itemRenderer","colorEntryRenderer");
         result[7] = new Binding(this,function():Array
         {
            var _loc1_:* = digitBandColors;
            return _loc1_ == null || _loc1_ is Array || _loc1_ is Proxy ? _loc1_ : [_loc1_];
         },function(param1:Array):void
         {
            SecondDigit.setStyle("alternatingItemColors",param1);
         },"SecondDigit.alternatingItemColors");
         result[8] = new Binding(this,function():IList
         {
            return digitBandNames;
         },null,"SecondDigit.dataProvider");
         result[9] = new Binding(this,null,null,"SecondDigit.itemRenderer","colorEntryRenderer");
         result[10] = new Binding(this,function():Array
         {
            var _loc1_:* = digitBandColors;
            return _loc1_ == null || _loc1_ is Array || _loc1_ is Proxy ? _loc1_ : [_loc1_];
         },function(param1:Array):void
         {
            ThirdDigit.setStyle("alternatingItemColors",param1);
         },"ThirdDigit.alternatingItemColors");
         result[11] = new Binding(this,function():IList
         {
            return digitBandNames;
         },null,"ThirdDigit.dataProvider");
         result[12] = new Binding(this,null,null,"ThirdDigit.itemRenderer","colorEntryRenderer");
         result[13] = new Binding(this,function():Array
         {
            var _loc1_:* = multBandColors;
            return _loc1_ == null || _loc1_ is Array || _loc1_ is Proxy ? _loc1_ : [_loc1_];
         },function(param1:Array):void
         {
            Multiplier.setStyle("alternatingItemColors",param1);
         },"Multiplier.alternatingItemColors");
         result[14] = new Binding(this,function():IList
         {
            return multBandNames;
         },null,"Multiplier.dataProvider");
         result[15] = new Binding(this,null,null,"Multiplier.itemRenderer","colorEntryRenderer");
         result[16] = new Binding(this,function():Array
         {
            var _loc1_:* = tolBandColors;
            return _loc1_ == null || _loc1_ is Array || _loc1_ is Proxy ? _loc1_ : [_loc1_];
         },function(param1:Array):void
         {
            Tolerance.setStyle("alternatingItemColors",param1);
         },"Tolerance.alternatingItemColors");
         result[17] = new Binding(this,function():IList
         {
            return tolBandNames;
         },null,"Tolerance.dataProvider");
         result[18] = new Binding(this,null,null,"Tolerance.itemRenderer","colorEntryRenderer");
         result[19] = new Binding(this,function():Array
         {
            var _loc1_:* = tempBandColors;
            return _loc1_ == null || _loc1_ is Array || _loc1_ is Proxy ? _loc1_ : [_loc1_];
         },function(param1:Array):void
         {
            TempCoef.setStyle("alternatingItemColors",param1);
         },"TempCoef.alternatingItemColors");
         result[20] = new Binding(this,function():IList
         {
            return tempBandNames;
         },null,"TempCoef.dataProvider");
         result[21] = new Binding(this,null,null,"TempCoef.itemRenderer","colorEntryRenderer");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get E() : GWizNumStepOvr
      {
         return this._69E;
      }
      
      public function set E(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._69E;
         if(_loc2_ !== param1)
         {
            this._69E = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"E",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get EnterOhms() : GWizNumStep
      {
         return this._1145796631EnterOhms;
      }
      
      public function set EnterOhms(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1145796631EnterOhms;
         if(_loc2_ !== param1)
         {
            this._1145796631EnterOhms = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"EnterOhms",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get FirstDigit() : List
      {
         return this._1807401085FirstDigit;
      }
      
      public function set FirstDigit(param1:List) : void
      {
         var _loc2_:Object = this._1807401085FirstDigit;
         if(_loc2_ !== param1)
         {
            this._1807401085FirstDigit = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FirstDigit",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get I() : GWizNumStepOvr
      {
         return this._73I;
      }
      
      public function set I(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._73I;
         if(_loc2_ !== param1)
         {
            this._73I = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"I",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Label4Band() : Label
      {
         return this._302765621Label4Band;
      }
      
      public function set Label4Band(param1:Label) : void
      {
         var _loc2_:Object = this._302765621Label4Band;
         if(_loc2_ !== param1)
         {
            this._302765621Label4Band = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Label4Band",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Label5Band() : Label
      {
         return this._303689142Label5Band;
      }
      
      public function set Label5Band(param1:Label) : void
      {
         var _loc2_:Object = this._303689142Label5Band;
         if(_loc2_ !== param1)
         {
            this._303689142Label5Band = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Label5Band",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Label6Band() : Label
      {
         return this._304612663Label6Band;
      }
      
      public function set Label6Band(param1:Label) : void
      {
         var _loc2_:Object = this._304612663Label6Band;
         if(_loc2_ !== param1)
         {
            this._304612663Label6Band = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Label6Band",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Multiplier() : List
      {
         return this._1036428831Multiplier;
      }
      
      public function set Multiplier(param1:List) : void
      {
         var _loc2_:Object = this._1036428831Multiplier;
         if(_loc2_ !== param1)
         {
            this._1036428831Multiplier = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Multiplier",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get P() : GWizNumStepOvr
      {
         return this._80P;
      }
      
      public function set P(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._80P;
         if(_loc2_ !== param1)
         {
            this._80P = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"P",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get R() : GWizNumStepOvr
      {
         return this._82R;
      }
      
      public function set R(param1:GWizNumStepOvr) : void
      {
         var _loc2_:Object = this._82R;
         if(_loc2_ !== param1)
         {
            this._82R = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"R",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get SecondDigit() : List
      {
         return this._1908053241SecondDigit;
      }
      
      public function set SecondDigit(param1:List) : void
      {
         var _loc2_:Object = this._1908053241SecondDigit;
         if(_loc2_ !== param1)
         {
            this._1908053241SecondDigit = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"SecondDigit",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get TempCoef() : List
      {
         return this._1258110943TempCoef;
      }
      
      public function set TempCoef(param1:List) : void
      {
         var _loc2_:Object = this._1258110943TempCoef;
         if(_loc2_ !== param1)
         {
            this._1258110943TempCoef = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"TempCoef",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ThirdDigit() : List
      {
         return this._1012672550ThirdDigit;
      }
      
      public function set ThirdDigit(param1:List) : void
      {
         var _loc2_:Object = this._1012672550ThirdDigit;
         if(_loc2_ !== param1)
         {
            this._1012672550ThirdDigit = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ThirdDigit",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Tolerance() : List
      {
         return this._1257926675Tolerance;
      }
      
      public function set Tolerance(param1:List) : void
      {
         var _loc2_:Object = this._1257926675Tolerance;
         if(_loc2_ !== param1)
         {
            this._1257926675Tolerance = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Tolerance",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Use4Bands() : RadioButton
      {
         return this._541144369Use4Bands;
      }
      
      public function set Use4Bands(param1:RadioButton) : void
      {
         var _loc2_:Object = this._541144369Use4Bands;
         if(_loc2_ !== param1)
         {
            this._541144369Use4Bands = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Use4Bands",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get colorEntryRenderer() : ClassFactory
      {
         return this._2060356430colorEntryRenderer;
      }
      
      public function set colorEntryRenderer(param1:ClassFactory) : void
      {
         var _loc2_:Object = this._2060356430colorEntryRenderer;
         if(_loc2_ !== param1)
         {
            this._2060356430colorEntryRenderer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"colorEntryRenderer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get electricalViews() : ViewStack
      {
         return this._713637562electricalViews;
      }
      
      public function set electricalViews(param1:ViewStack) : void
      {
         var _loc2_:Object = this._713637562electricalViews;
         if(_loc2_ !== param1)
         {
            this._713637562electricalViews = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"electricalViews",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get msgText() : Label
      {
         return this._1343731790msgText;
      }
      
      public function set msgText(param1:Label) : void
      {
         var _loc2_:Object = this._1343731790msgText;
         if(_loc2_ !== param1)
         {
            this._1343731790msgText = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"msgText",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get res1() : HGroup
      {
         return this._3496849res1;
      }
      
      public function set res1(param1:HGroup) : void
      {
         var _loc2_:Object = this._3496849res1;
         if(_loc2_ !== param1)
         {
            this._3496849res1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"res1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get res2() : HGroup
      {
         return this._3496850res2;
      }
      
      public function set res2(param1:HGroup) : void
      {
         var _loc2_:Object = this._3496850res2;
         if(_loc2_ !== param1)
         {
            this._3496850res2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"res2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get res3() : HGroup
      {
         return this._3496851res3;
      }
      
      public function set res3(param1:HGroup) : void
      {
         var _loc2_:Object = this._3496851res3;
         if(_loc2_ !== param1)
         {
            this._3496851res3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"res3",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get resImage() : Group
      {
         return this._376413029resImage;
      }
      
      public function set resImage(param1:Group) : void
      {
         var _loc2_:Object = this._376413029resImage;
         if(_loc2_ !== param1)
         {
            this._376413029resImage = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"resImage",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get resistorImageGroup() : Group
      {
         return this._656460527resistorImageGroup;
      }
      
      public function set resistorImageGroup(param1:Group) : void
      {
         var _loc2_:Object = this._656460527resistorImageGroup;
         if(_loc2_ !== param1)
         {
            this._656460527resistorImageGroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"resistorImageGroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get digitBandColors() : Array
      {
         return this._1108604178digitBandColors;
      }
      
      private function set digitBandColors(param1:Array) : void
      {
         var _loc2_:Object = this._1108604178digitBandColors;
         if(_loc2_ !== param1)
         {
            this._1108604178digitBandColors = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"digitBandColors",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get digitBandNames() : ArrayCollection
      {
         return this._370138266digitBandNames;
      }
      
      private function set digitBandNames(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._370138266digitBandNames;
         if(_loc2_ !== param1)
         {
            this._370138266digitBandNames = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"digitBandNames",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get multBandColors() : Array
      {
         return this._770382507multBandColors;
      }
      
      private function set multBandColors(param1:Array) : void
      {
         var _loc2_:Object = this._770382507multBandColors;
         if(_loc2_ !== param1)
         {
            this._770382507multBandColors = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"multBandColors",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get multBandNames() : ArrayCollection
      {
         return this._1816224061multBandNames;
      }
      
      private function set multBandNames(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._1816224061multBandNames;
         if(_loc2_ !== param1)
         {
            this._1816224061multBandNames = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"multBandNames",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get tolBandColors() : Array
      {
         return this._672292918tolBandColors;
      }
      
      private function set tolBandColors(param1:Array) : void
      {
         var _loc2_:Object = this._672292918tolBandColors;
         if(_loc2_ !== param1)
         {
            this._672292918tolBandColors = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tolBandColors",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get tolBandNames() : ArrayCollection
      {
         return this._447071170tolBandNames;
      }
      
      private function set tolBandNames(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._447071170tolBandNames;
         if(_loc2_ !== param1)
         {
            this._447071170tolBandNames = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tolBandNames",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get tempBandColors() : Array
      {
         return this._887891207tempBandColors;
      }
      
      private function set tempBandColors(param1:Array) : void
      {
         var _loc2_:Object = this._887891207tempBandColors;
         if(_loc2_ !== param1)
         {
            this._887891207tempBandColors = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tempBandColors",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get tempBandNames() : ArrayCollection
      {
         return this._1643668639tempBandNames;
      }
      
      private function set tempBandNames(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._1643668639tempBandNames;
         if(_loc2_ !== param1)
         {
            this._1643668639tempBandNames = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tempBandNames",_loc2_,param1));
            }
         }
      }
   }
}
