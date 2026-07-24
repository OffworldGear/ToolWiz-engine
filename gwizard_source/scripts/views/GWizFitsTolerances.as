package views
{
   import comps.GWizNumStep;
   import comps.GridComponent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import skins.GridSkin;
   import spark.components.DropDownList;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.components.VGroup;
   import spark.events.IndexChangeEvent;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizFitsTolerances extends Group implements IBindingClient
   {
      
      private static var _521093400fitTypes:ArrayCollection = new ArrayCollection([{
         "type":"Loose fit",
         "hole":"H11",
         "shaft":"c11"
      },{
         "type":"Free running",
         "hole":"H9",
         "shaft":"d9"
      },{
         "type":"Easy running",
         "hole":"H8",
         "shaft":"f8"
      },{
         "type":"Sliding fit",
         "hole":"H7",
         "shaft":"g6"
      },{
         "type":"Close clearance",
         "hole":"H8",
         "shaft":"f7"
      },{
         "type":"Location clearance",
         "hole":"H7",
         "shaft":"h6"
      },{
         "type":"Slight interference",
         "hole":"H7",
         "shaft":"k6"
      },{
         "type":"Transition",
         "hole":"H7",
         "shaft":"n6"
      },{
         "type":"Press fit",
         "hole":"H7",
         "shaft":"p6"
      },{
         "type":"Medium fit",
         "hole":"H7",
         "shaft":"s6"
      },{
         "type":"Force fit",
         "hole":"H7",
         "shaft":"u6"
      }]);
      
      private static var minDiameters:Array = [3,6,10,18,30,40,50,65,80,100,120,140,160,180,200,225,250,280,315,355];
      
      private static var maxDiameters:Array = [6,10,18,30,40,50,65,80,100,120,140,160,180,200,225,250,280,315,355,400];
      
      private static var _2020605114holeClasses:ArrayCollection = new ArrayCollection([{"name":"E7"},{"name":"E11"},{"name":"E12"},{"name":"E13"},{"name":"F6"},{"name":"F7"},{"name":"F8"},{"name":"G6"},{"name":"G7"},{"name":"G8"},{"name":"H6"},{"name":"H7"},{"name":"H8"},{"name":"H9"},{"name":"H10"},{"name":"H11"},{"name":"J6"},{"name":"J7"},{"name":"J8"},{"name":"JS6"},{"name":"JS7"},{"name":"JS8"},{"name":"K6"},{"name":"K7"},{"name":"K8"},{"name":"M6"},{"name":"M7"},{"name":"M8"},{"name":"N6"},{"name":"N7"},{"name":"N8"},{"name":"P6"},{"name":"P7"},{"name":"P8"},{"name":"R6"},{"name":"R7"}]);
      
      private static var _1022370892shaftClasses:ArrayCollection = new ArrayCollection([{"name":"b9"},{"name":"c9"},{"name":"c10"},{"name":"c11"},{"name":"d8"},{"name":"d9"},{"name":"e7"},{"name":"e8"},{"name":"e9"},{"name":"f6"},{"name":"f7"},{"name":"f8"},{"name":"g5"},{"name":"g6"},{"name":"h5"},{"name":"h6"},{"name":"h7"},{"name":"h8"},{"name":"h9"},{"name":"h10"},{"name":"h11"},{"name":"js5"},{"name":"js6"},{"name":"js7"},{"name":"k5"},{"name":"k6"},{"name":"m5"},{"name":"m6"},{"name":"n5"},{"name":"n6"},{"name":"p6"},{"name":"r6"},{"name":"s6"},{"name":"t6"},{"name":"u6"},{"name":"x6"}]);
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _168560467Diameter:GWizNumStep;
      
      private var _450588731HoleFund:Label;
      
      private var _1077977599HoleLower:Label;
      
      private var _1538549660HoleMax:Label;
      
      private var _1538549422HoleMin:Label;
      
      private var _1538542511HoleTol:Label;
      
      private var _1069642846HoleUpper:Label;
      
      private var _1345958606PrefFit:Label;
      
      private var _91830335ShaftFund:Label;
      
      private var _1442855737ShaftLower:Label;
      
      private var _689768278ShaftMax:Label;
      
      private var _689768040ShaftMin:Label;
      
      private var _689761129ShaftTol:Label;
      
      private var _1434520984ShaftUpper:Label;
      
      private var _81880911Units:Label;
      
      private var _1998452996fitTolerance:Label;
      
      private var _848093461fitType:DropDownList;
      
      private var _1740381858fitTypeLab:Label;
      
      private var _317504755gridArea:GridComponent;
      
      private var _1204599960holeClass:DropDownList;
      
      private var _514811878holeType:RadioButton;
      
      private var _1601164312maxClearance:Label;
      
      private var _2075590378minClearance:Label;
      
      private var _850224926shaftClass:DropDownList;
      
      private var _1911716652shaftType:RadioButton;
      
      private var _526703493typegroup:RadioButtonGroup;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var diameter:Number;
      
      private var holeTolerance:Number;
      
      private var shaftTolerance:Number;
      
      private var holeMin:Number;
      
      private var holeMax:Number;
      
      private var holeUpper:Number;
      
      private var holeLower:Number;
      
      private var holeFundDev:Number;
      
      private var shaftMin:Number;
      
      private var shaftMax:Number;
      
      private var shaftUpper:Number;
      
      private var shaftLower:Number;
      
      private var shaftFundDev:Number;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizFitsTolerances()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizFitsTolerances_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_views_GWizFitsTolerancesWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizFitsTolerances[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.mxmlContent = [this._GWizFitsTolerances_GridComponent1_i()];
         this._GWizFitsTolerances_RadioButtonGroup1_i();
         this.addEventListener("creationComplete",this.___GWizFitsTolerances_Group1_creationComplete);
         this.addEventListener("show",this.___GWizFitsTolerances_Group1_show);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizFitsTolerances._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      private static function get fitTypes() : ArrayCollection
      {
         return GWizFitsTolerances._521093400fitTypes;
      }
      
      private static function set fitTypes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizFitsTolerances._521093400fitTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizFitsTolerances,"fitTypes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get holeClasses() : ArrayCollection
      {
         return GWizFitsTolerances._2020605114holeClasses;
      }
      
      private static function set holeClasses(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizFitsTolerances._2020605114holeClasses;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizFitsTolerances,"holeClasses",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      private static function get shaftClasses() : ArrayCollection
      {
         return GWizFitsTolerances._1022370892shaftClasses;
      }
      
      private static function set shaftClasses(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizFitsTolerances._1022370892shaftClasses;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizFitsTolerances,"shaftClasses",_loc2_,param1));
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
            this.chromeColor = 13224393;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function onCC() : void
      {
         this.changeType();
      }
      
      private function checkUnits() : void
      {
         if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
         {
            this.Units.text = "inches (D)";
         }
         else
         {
            this.Units.text = " mm (D)";
         }
         this.recalc();
      }
      
      private function changeBasis() : void
      {
         if(this.holeType.selected)
         {
            this.Diameter.titleTxt = "Hole Diameter:";
         }
         else
         {
            this.Diameter.titleTxt = "Shaft Diameter:";
         }
         this.recalc();
      }
      
      private function changeType() : void
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         if(this.fitType.selectedIndex >= 0)
         {
            _loc1_ = fitTypes.getItemAt(this.fitType.selectedIndex);
            this.PrefFit.text = "Preferred Fit: " + _loc1_.hole + "/" + _loc1_.shaft;
            _loc2_ = 0;
            while(_loc2_ < holeClasses.length)
            {
               _loc3_ = holeClasses.getItemAt(_loc2_);
               if(_loc1_.hole == _loc3_.name)
               {
                  this.holeClass.selectedIndex = _loc2_;
                  break;
               }
               _loc2_++;
            }
            _loc2_ = 0;
            while(_loc2_ < shaftClasses.length)
            {
               _loc4_ = shaftClasses.getItemAt(_loc2_);
               if(_loc1_.shaft == _loc4_.name)
               {
                  this.shaftClass.selectedIndex = _loc2_;
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      private function geometricMeanDimension(param1:Number) : Number
      {
         if(param1 < 0 || param1 > 3150)
         {
            param1 = NaN;
         }
         else if(param1 <= 3)
         {
            param1 = Math.sqrt(0 * 3);
         }
         else if(param1 <= 6)
         {
            param1 = Math.sqrt(3 * 6);
         }
         else if(param1 <= 10)
         {
            param1 = Math.sqrt(6 * 10);
         }
         else if(param1 <= 18)
         {
            param1 = Math.sqrt(10 * 18);
         }
         else if(param1 <= 30)
         {
            param1 = Math.sqrt(18 * 30);
         }
         else if(param1 <= 50)
         {
            param1 = Math.sqrt(30 * 50);
         }
         else if(param1 <= 80)
         {
            param1 = Math.sqrt(50 * 80);
         }
         else if(param1 <= 120)
         {
            param1 = Math.sqrt(80 * 120);
         }
         else if(param1 <= 180)
         {
            param1 = Math.sqrt(120 * 180);
         }
         else if(param1 <= 250)
         {
            param1 = Math.sqrt(180 * 250);
         }
         else if(param1 <= 315)
         {
            param1 = Math.sqrt(250 * 315);
         }
         else if(param1 <= 400)
         {
            param1 = Math.sqrt(315 * 400);
         }
         else if(param1 <= 500)
         {
            param1 = Math.sqrt(400 * 500);
         }
         else if(param1 <= 630)
         {
            param1 = Math.sqrt(500 * 630);
         }
         else if(param1 <= 800)
         {
            param1 = Math.sqrt(630 * 800);
         }
         else if(param1 <= 1000)
         {
            param1 = Math.sqrt(800 * 1000);
         }
         else if(param1 <= 1250)
         {
            param1 = Math.sqrt(1000 * 1250);
         }
         else if(param1 <= 1600)
         {
            param1 = Math.sqrt(1250 * 1600);
         }
         else if(param1 <= 2000)
         {
            param1 = Math.sqrt(1600 * 2000);
         }
         else if(param1 <= 2500)
         {
            param1 = Math.sqrt(2000 * 2500);
         }
         else if(param1 <= 3150)
         {
            param1 = Math.sqrt(2500 * 3150);
         }
         return param1;
      }
      
      private function intlToleranceGrade(param1:int, param2:Number) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         param2 = this.geometricMeanDimension(param2);
         switch(param1)
         {
            case 5:
               _loc4_ = 7;
               break;
            case 6:
               _loc4_ = 10;
               break;
            case 7:
               _loc4_ = 16;
               break;
            case 8:
               _loc4_ = 25;
               break;
            case 9:
               _loc4_ = 40;
               break;
            case 10:
               _loc4_ = 64;
               break;
            case 11:
               _loc4_ = 100;
               break;
            case 12:
               _loc4_ = 160;
               break;
            case 13:
               _loc4_ = 250;
               break;
            case 14:
               _loc4_ = 400;
               break;
            case 15:
               _loc4_ = 640;
               break;
            case 16:
               _loc4_ = 1000;
               break;
            default:
               GWizUtils.assert(false);
               _loc4_ = NaN;
         }
         _loc3_ = 0.45 * Math.pow(param2,1 / 3) + 0.001 * param2;
         _loc3_ = _loc4_ * _loc3_;
         _loc3_ = Math.ceil(_loc3_);
         return Number(_loc3_ / 1000);
      }
      
      private function recalc() : void
      {
         if(!this.fitTypeLab)
         {
            return;
         }
         this.diameter = this.Diameter.getVal() * 25.4;
         var _loc1_:Object = this.holeClass.selectedItem;
         if(!_loc1_)
         {
            return;
         }
         this.holeFundDev = this.fundDevHole(_loc1_.name,this.diameter);
         this.holeTolerance = this.intlToleranceGrade(this.tolClass(_loc1_.name),this.diameter);
         this.shaftFundDev = this.fundDevShaft(this.shaftClass.selectedItem.name,this.diameter);
         this.shaftTolerance = this.intlToleranceGrade(this.tolClass(this.shaftClass.selectedItem.name),this.diameter);
         if(this.holeType.selected)
         {
            this.holeFundDev = 0;
         }
         else
         {
            this.shaftFundDev = 0;
         }
         if(!this.holeType.selected)
         {
            this.holeMin = this.diameter - this.holeTolerance;
            this.holeMax = this.diameter + this.holeTolerance;
            this.holeUpper = this.holeTolerance;
            this.holeLower = this.holeTolerance;
         }
         else
         {
            this.holeMin = this.diameter + this.holeFundDev;
            this.holeMax = this.holeMin + this.holeTolerance;
            this.holeUpper = this.holeTolerance;
            this.holeLower = 0;
         }
         if(this.fundDevLetter(this.shaftClass.selectedItem.name) <= "h")
         {
            this.shaftUpper = this.shaftFundDev;
            this.shaftLower = this.shaftFundDev - this.shaftTolerance;
         }
         else
         {
            this.shaftLower = this.shaftFundDev;
            this.shaftUpper = this.shaftFundDev + this.shaftTolerance;
         }
         if(this.holeType.selected)
         {
            this.shaftMax = this.diameter + this.shaftUpper;
            this.shaftMin = this.diameter + this.shaftLower;
         }
         else
         {
            this.shaftMin = this.diameter;
            this.shaftMax = this.shaftMin + this.shaftTolerance;
            this.shaftUpper = this.shaftTolerance;
            this.shaftLower = 0;
         }
         var _loc2_:String = " inches";
         if(GWizUtils.Units != GWizUtils.INCHES_UNITS)
         {
            _loc2_ = " mm";
         }
         this.Units.text = _loc2_ + " (D)";
         this.HoleMin.text = "Hole Min: " + GWizUtils.roundTenths(this.holeMin / 25.4,true) + _loc2_;
         this.HoleMax.text = "Hole Max: " + GWizUtils.roundTenths(this.holeMax / 25.4,true) + _loc2_;
         this.HoleUpper.text = "Hole Upper: " + GWizUtils.roundTenths(this.holeUpper / 25.4,true) + _loc2_ + " (ES)";
         this.HoleLower.text = "Hole Lower: " + GWizUtils.roundTenths(this.holeLower / 25.4,true) + _loc2_ + " (EI)";
         this.HoleTol.text = "Hole Tolerance: " + GWizUtils.roundTenths(this.holeTolerance / 25.4,true) + _loc2_;
         this.HoleFund.text = "Hole Fund. Dev.: " + GWizUtils.roundTenths(this.holeFundDev / 25.4,true) + _loc2_;
         this.ShaftMin.text = "Shaft Min: " + GWizUtils.roundTenths(this.shaftMin / 25.4,true) + _loc2_;
         this.ShaftMax.text = "Shaft Max: " + GWizUtils.roundTenths(this.shaftMax / 25.4,true) + _loc2_;
         this.ShaftUpper.text = "Shaft Upper: " + GWizUtils.roundTenths(this.shaftUpper / 25.4,true) + _loc2_ + " (es)";
         this.ShaftLower.text = "Shaft Lower: " + GWizUtils.roundTenths(this.shaftLower / 25.4,true) + _loc2_ + " (ei)";
         this.ShaftTol.text = "Shaft Tolerance: " + GWizUtils.roundTenths(this.shaftTolerance / 25.4,true) + _loc2_;
         this.ShaftFund.text = "Shaft Fund. Dev.: " + GWizUtils.roundTenths(this.shaftFundDev / 25.4,true) + _loc2_;
         var _loc3_:Number = (this.holeMax - this.shaftMin) / 25.4;
         var _loc4_:Number = (this.holeMin - this.shaftMax) / 25.4;
         this.maxClearance.text = "Maximum Clearance: " + GWizUtils.roundTenths(_loc3_,true) + _loc2_ + " (cmax)";
         this.minClearance.text = "Minimum Clearance: " + GWizUtils.roundTenths(_loc4_,true) + _loc2_ + " (cmin)";
         this.fitTolerance.text = "Tolerance of Fit: " + GWizUtils.roundTenths(Math.abs(_loc3_ - _loc4_),true) + _loc2_;
         this.fitTypeLab.text = "Fit Type: " + this.typeOfFit((this.holeMax - this.shaftMin) / 25.4,(this.holeMin - this.shaftMax) / 25.4);
      }
      
      private function fundDevLetter(param1:String) : String
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = param1.charAt(_loc2_);
            if("0123456789".indexOf(_loc3_) >= 0)
            {
               return param1.substr(0,_loc2_);
            }
            _loc2_++;
         }
         return "";
      }
      
      private function ansi(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         if(param3 == 1)
         {
            return param1 + param2 * param4 * 1000;
         }
         if(param3 == 0)
         {
            return (param1 + param2) * 1000;
         }
         return (param1 + param2 * Math.pow(param4,param3) / 1000) * 1000;
      }
      
      private function fundDevShaft(param1:String, param2:Number) : Number
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc3_:String = this.fundDevLetter(param1);
         param2 = this.geometricMeanDimension(param2);
         if(param2 <= 500)
         {
            switch(_loc3_)
            {
               case "a":
                  if(param2 <= 120)
                  {
                     _loc4_ = -(265 + 1.32 * param2);
                     _loc4_ = this.ansi(-0.265,-1.3,1,param2);
                  }
                  else
                  {
                     _loc4_ = -3.52 * param2;
                     _loc4_ = this.ansi(0,-3.5,1,param2);
                  }
                  break;
               case "b":
                  if(param2 < 160)
                  {
                     _loc4_ = -(140 + 0.852 * param2);
                     _loc4_ = this.ansi(-0.14,-0.85,1,param2);
                  }
                  else
                  {
                     _loc4_ = -1.82 * param2;
                     _loc4_ = this.ansi(0,-1.8,1,param2);
                  }
                  break;
               case "c":
                  if(param2 <= 40)
                  {
                     _loc4_ = -52 * Math.pow(param2,0.2);
                     _loc4_ = this.ansi(0,-52,0.2,param2);
                  }
                  else
                  {
                     _loc4_ = -(95 + 0.82 * param2);
                     _loc4_ = this.ansi(-0.095,-0.8,1,param2);
                  }
                  break;
               case "d":
                  _loc4_ = -16 * Math.pow(param2,0.44);
                  _loc4_ = this.ansi(0,-16,0.44,param2);
                  break;
               case "e":
                  _loc4_ = -11 * Math.pow(param2,0.41);
                  _loc4_ = this.ansi(0,-11,0.41,param2);
                  break;
               case "f":
                  _loc4_ = -5.5 * Math.pow(param2,0.41);
                  _loc4_ = this.ansi(0,-5.5,0.41,param2);
                  break;
               case "g":
                  _loc4_ = -2.5 * Math.pow(param2,0.34);
                  _loc4_ = this.ansi(0,-2.5,0.34,param2);
                  break;
               case "h":
                  _loc4_ = 0;
                  break;
               case "js":
                  _loc4_ = this.intlToleranceGrade(this.tolClass(param1),this.diameter) / 2;
                  break;
               case "k":
                  if(4 <= this.tolClass(param1) && this.tolClass(param1) <= 7)
                  {
                     _loc4_ = 0.6 * Math.pow(param2,1 / 3);
                     _loc4_ = this.ansi(0,0.6,0.33,param2);
                  }
                  else
                  {
                     _loc4_ = 0;
                  }
                  break;
               case "m":
                  _loc4_ = this.intlToleranceGrade(7,this.diameter) - this.intlToleranceGrade(6,this.diameter);
                  _loc4_ = this.ansi(this.intlToleranceGrade(7,this.diameter),-this.intlToleranceGrade(6,this.diameter),0,param2);
                  break;
               case "n":
                  _loc4_ = 5 * Math.pow(param2,0.34);
                  _loc4_ = this.ansi(0,5,0.34,param2);
                  break;
               case "p":
                  _loc4_ = this.intlToleranceGrade(7,this.diameter);
                  _loc4_ = this.ansi(this.intlToleranceGrade(7,this.diameter),0.003,0,param2);
                  break;
               case "r":
                  if(param2 <= 50)
                  {
                     _loc5_ = this.intlToleranceGrade(8,this.diameter);
                  }
                  else
                  {
                     _loc5_ = this.intlToleranceGrade(7,this.diameter) + 0.4 * param2;
                  }
                  _loc4_ = Math.sqrt(this.intlToleranceGrade(7,this.diameter) * _loc5_);
                  break;
               case "s":
                  if(param2 <= 50)
                  {
                     _loc4_ = this.intlToleranceGrade(8,this.diameter);
                     _loc4_ = this.ansi(this.intlToleranceGrade(8,this.diameter),2,0,param2);
                  }
                  else
                  {
                     _loc4_ = this.intlToleranceGrade(7,this.diameter) + 0.4 * param2;
                     _loc4_ = this.ansi(this.intlToleranceGrade(7,this.diameter),0.4,1,param2);
                  }
                  break;
               case "t":
                  _loc4_ = this.intlToleranceGrade(7,this.diameter) + 0.63 * param2;
                  _loc4_ = this.ansi(this.intlToleranceGrade(7,this.diameter),0.63,1,param2);
                  break;
               case "u":
                  _loc4_ = this.intlToleranceGrade(7,this.diameter) + param2;
                  break;
               case "x":
                  _loc4_ = this.intlToleranceGrade(7,this.diameter) + 1.62 * param2;
                  break;
               default:
                  _loc4_ = NaN;
            }
         }
         else
         {
            switch(_loc3_)
            {
               case "d":
                  _loc4_ = -16 * Math.pow(param2,0.44);
                  break;
               case "e":
                  _loc4_ = -11 * Math.pow(param2,0.41);
                  break;
               case "f":
                  _loc4_ = -5.5 * Math.pow(param2,0.41);
                  break;
               case "g":
                  _loc4_ = -2.5 * Math.pow(param2,0.34);
                  break;
               case "h":
                  _loc4_ = 0;
                  break;
               case "js":
                  _loc4_ = -this.intlToleranceGrade(this.tolClass(param1),this.diameter) / 2;
                  break;
               case "k":
                  _loc4_ = 0;
                  break;
               case "m":
                  _loc4_ = 0.024 * param2 + 12.6;
                  break;
               case "n":
                  _loc4_ = 0.04 * param2 + 21;
                  break;
               case "p":
                  _loc4_ = 0.072 * param2 + 37.8;
                  break;
               case "r":
                  _loc4_ = Math.sqrt((0.072 * param2 + 37.8) * (this.intlToleranceGrade(7,this.diameter) + 0.4 * param2));
                  break;
               case "s":
                  _loc4_ = this.intlToleranceGrade(7,this.diameter) + 0.4 * param2;
                  break;
               case "t":
                  _loc4_ = this.intlToleranceGrade(7,this.diameter) + 0.63 * param2;
                  break;
               case "u":
                  _loc4_ = this.intlToleranceGrade(7,this.diameter) + param2;
                  break;
               default:
                  _loc4_ = NaN;
            }
         }
         return _loc4_ / 1000;
      }
      
      private function fundDevHole(param1:String, param2:Number) : Number
      {
         var _loc3_:String = this.fundDevLetter(param1);
         var _loc4_:Number = -this.fundDevShaft(param1.toLowerCase(),param2);
         if(param2 <= 500)
         {
            switch(_loc3_)
            {
               case "N":
                  _loc4_ = 0;
                  break;
               case "J":
               case "K":
               case "M":
               case "N":
                  if(param2 > 3 && this.tolClass(param1) <= 8)
                  {
                     _loc4_ = NaN;
                  }
                  break;
               case "P":
               case "R":
                  if(param2 > 3 && this.tolClass(param1) <= 7)
                  {
                     _loc4_ = NaN;
                  }
            }
         }
         return _loc4_ / 1000;
      }
      
      private function tolClass(param1:String) : int
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = param1.charAt(_loc2_);
            if("0123456789".indexOf(_loc3_) >= 0)
            {
               return int(param1.substr(_loc2_));
            }
            _loc2_++;
         }
         return -1;
      }
      
      private function typeOfFit(param1:Number, param2:Number) : String
      {
         var _loc3_:String = "Transitional";
         if(param2 < 0 && param1 > 0)
         {
            _loc3_ = "Interference";
         }
         else if(param2 > 0)
         {
            _loc3_ = "Clearance";
         }
         return _loc3_;
      }
      
      private function _GWizFitsTolerances_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.addEventListener("change",this.__typegroup_change);
         _loc1_.initialized(this,"typegroup");
         this.typegroup = _loc1_;
         BindingManager.executeBindings(this,"typegroup",this.typegroup);
         return _loc1_;
      }
      
      public function __typegroup_change(param1:Event) : void
      {
         this.changeBasis();
      }
      
      private function _GWizFitsTolerances_GridComponent1_i() : GridComponent
      {
         var _loc1_:GridComponent = new GridComponent();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.showXAxis = false;
         _loc1_.showYAxis = false;
         _loc1_.top = 10;
         _loc1_.bottom = 10;
         _loc1_.left = 10;
         _loc1_.right = 10;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFitsTolerances_Array2_c);
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
      
      private function _GWizFitsTolerances_Array2_c() : Array
      {
         return [this._GWizFitsTolerances_VGroup1_c()];
      }
      
      private function _GWizFitsTolerances_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingBottom = 10;
         _loc1_.paddingLeft = 10;
         _loc1_.paddingRight = 10;
         _loc1_.paddingTop = 10;
         _loc1_.mxmlContent = [this._GWizFitsTolerances_Label1_c(),this._GWizFitsTolerances_HGroup1_c(),this._GWizFitsTolerances_HGroup2_c(),this._GWizFitsTolerances_HGroup3_c(),this._GWizFitsTolerances_HGroup4_c(),this._GWizFitsTolerances_Label20_i(),this._GWizFitsTolerances_Label21_i(),this._GWizFitsTolerances_Label22_i(),this._GWizFitsTolerances_Label23_i(),this._GWizFitsTolerances_Spacer2_c(),this._GWizFitsTolerances_Label24_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Fits and Tolerances";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",16);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFitsTolerances_Label2_c(),this._GWizFitsTolerances_RadioButton1_i(),this._GWizFitsTolerances_RadioButton2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Type:";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Hole-basis";
         _loc1_.groupName = "typegroup";
         _loc1_.selected = true;
         _loc1_.id = "holeType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.holeType = _loc1_;
         BindingManager.executeBindings(this,"holeType",this.holeType);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Shaft-basis";
         _loc1_.groupName = "typegroup";
         _loc1_.id = "shaftType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.shaftType = _loc1_;
         BindingManager.executeBindings(this,"shaftType",this.shaftType);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFitsTolerances_GWizNumStep1_i(),this._GWizFitsTolerances_Label3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Hole Diameter:";
         _loc1_.min = 0;
         _loc1_.max = 3200;
         _loc1_.steps = 0.0001;
         _loc1_.addEventListener("change",this.__Diameter_change);
         _loc1_.id = "Diameter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Diameter = _loc1_;
         BindingManager.executeBindings(this,"Diameter",this.Diameter);
         return _loc1_;
      }
      
      public function __Diameter_change(param1:Event) : void
      {
         this.recalc();
      }
      
      private function _GWizFitsTolerances_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "inches (D)";
         _loc1_.id = "Units";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Units = _loc1_;
         BindingManager.executeBindings(this,"Units",this.Units);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizFitsTolerances_Label4_c(),this._GWizFitsTolerances_DropDownList1_i(),this._GWizFitsTolerances_Label5_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Fit Type:";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "type";
         _loc1_.selectedIndex = 0;
         _loc1_.addEventListener("change",this.__fitType_change);
         _loc1_.id = "fitType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fitType = _loc1_;
         BindingManager.executeBindings(this,"fitType",this.fitType);
         return _loc1_;
      }
      
      public function __fitType_change(param1:IndexChangeEvent) : void
      {
         this.changeType();
      }
      
      private function _GWizFitsTolerances_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "PrefFit";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.PrefFit = _loc1_;
         BindingManager.executeBindings(this,"PrefFit",this.PrefFit);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.paddingLeft = 2;
         _loc1_.mxmlContent = [this._GWizFitsTolerances_VGroup2_c(),this._GWizFitsTolerances_Spacer1_c(),this._GWizFitsTolerances_VGroup3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.width = 350;
         _loc1_.mxmlContent = [this._GWizFitsTolerances_Label6_c(),this._GWizFitsTolerances_DropDownList2_i(),this._GWizFitsTolerances_Label7_i(),this._GWizFitsTolerances_Label8_i(),this._GWizFitsTolerances_Label9_i(),this._GWizFitsTolerances_Label10_i(),this._GWizFitsTolerances_Label11_i(),this._GWizFitsTolerances_Label12_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hole Specifications:";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_DropDownList2_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "name";
         _loc1_.addEventListener("valueCommit",this.__holeClass_valueCommit);
         _loc1_.id = "holeClass";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.holeClass = _loc1_;
         BindingManager.executeBindings(this,"holeClass",this.holeClass);
         return _loc1_;
      }
      
      public function __holeClass_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizFitsTolerances_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hole tolerance: ";
         _loc1_.id = "HoleTol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HoleTol = _loc1_;
         BindingManager.executeBindings(this,"HoleTol",this.HoleTol);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hole min: ";
         _loc1_.id = "HoleMin";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HoleMin = _loc1_;
         BindingManager.executeBindings(this,"HoleMin",this.HoleMin);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hole max: ";
         _loc1_.id = "HoleMax";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HoleMax = _loc1_;
         BindingManager.executeBindings(this,"HoleMax",this.HoleMax);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label10_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hole upper: ";
         _loc1_.toolTip = "Upper deviation is the difference between the diameter and the permitted max size";
         _loc1_.id = "HoleUpper";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HoleUpper = _loc1_;
         BindingManager.executeBindings(this,"HoleUpper",this.HoleUpper);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hole lower: ";
         _loc1_.toolTip = "Lower deviation is the difference between the diameter and the permitted min size";
         _loc1_.id = "HoleLower";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HoleLower = _loc1_;
         BindingManager.executeBindings(this,"HoleLower",this.HoleLower);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label12_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Hole Fund. Dev.: ";
         _loc1_.id = "HoleFund";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.HoleFund = _loc1_;
         BindingManager.executeBindings(this,"HoleFund",this.HoleFund);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 2;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.width = 350;
         _loc1_.mxmlContent = [this._GWizFitsTolerances_Label13_c(),this._GWizFitsTolerances_DropDownList3_i(),this._GWizFitsTolerances_Label14_i(),this._GWizFitsTolerances_Label15_i(),this._GWizFitsTolerances_Label16_i(),this._GWizFitsTolerances_Label17_i(),this._GWizFitsTolerances_Label18_i(),this._GWizFitsTolerances_Label19_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label13_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Shaft Specifications:";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_DropDownList3_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "name";
         _loc1_.addEventListener("valueCommit",this.__shaftClass_valueCommit);
         _loc1_.id = "shaftClass";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.shaftClass = _loc1_;
         BindingManager.executeBindings(this,"shaftClass",this.shaftClass);
         return _loc1_;
      }
      
      public function __shaftClass_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizFitsTolerances_Label14_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Shaft tolerance: ";
         _loc1_.id = "ShaftTol";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ShaftTol = _loc1_;
         BindingManager.executeBindings(this,"ShaftTol",this.ShaftTol);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label15_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Shaft min: ";
         _loc1_.id = "ShaftMin";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ShaftMin = _loc1_;
         BindingManager.executeBindings(this,"ShaftMin",this.ShaftMin);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label16_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Shaft max: ";
         _loc1_.id = "ShaftMax";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ShaftMax = _loc1_;
         BindingManager.executeBindings(this,"ShaftMax",this.ShaftMax);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label17_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Shaft upper: ";
         _loc1_.toolTip = "Upper deviation is the difference between the diameter and the permitted max size";
         _loc1_.id = "ShaftUpper";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ShaftUpper = _loc1_;
         BindingManager.executeBindings(this,"ShaftUpper",this.ShaftUpper);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label18_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Shaft lower: ";
         _loc1_.toolTip = "Lower deviation is the difference between the diameter and the permitted min size";
         _loc1_.id = "ShaftLower";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ShaftLower = _loc1_;
         BindingManager.executeBindings(this,"ShaftLower",this.ShaftLower);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label19_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Shaft Fund. Dev.: ";
         _loc1_.id = "ShaftFund";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ShaftFund = _loc1_;
         BindingManager.executeBindings(this,"ShaftFund",this.ShaftFund);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label20_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Fit Type: ";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "fitTypeLab";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fitTypeLab = _loc1_;
         BindingManager.executeBindings(this,"fitTypeLab",this.fitTypeLab);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label21_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "maxClearance";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.maxClearance = _loc1_;
         BindingManager.executeBindings(this,"maxClearance",this.maxClearance);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label22_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "minClearance";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.minClearance = _loc1_;
         BindingManager.executeBindings(this,"minClearance",this.minClearance);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label23_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "fitTolerance";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fitTolerance = _loc1_;
         BindingManager.executeBindings(this,"fitTolerance",this.fitTolerance);
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentHeight = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizFitsTolerances_Label24_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Fits and Tolerances based on ISO 286, ANSI B4.2, and DIN 7172";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizFitsTolerances_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      public function ___GWizFitsTolerances_Group1_show(param1:FlexEvent) : void
      {
         this.checkUnits();
      }
      
      private function _GWizFitsTolerances_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return fitTypes;
         },null,"fitType.dataProvider");
         result[1] = new Binding(this,function():IList
         {
            return holeClasses;
         },null,"holeClass.dataProvider");
         result[2] = new Binding(this,function():IList
         {
            return shaftClasses;
         },null,"shaftClass.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Diameter() : GWizNumStep
      {
         return this._168560467Diameter;
      }
      
      public function set Diameter(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._168560467Diameter;
         if(_loc2_ !== param1)
         {
            this._168560467Diameter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Diameter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HoleFund() : Label
      {
         return this._450588731HoleFund;
      }
      
      public function set HoleFund(param1:Label) : void
      {
         var _loc2_:Object = this._450588731HoleFund;
         if(_loc2_ !== param1)
         {
            this._450588731HoleFund = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HoleFund",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HoleLower() : Label
      {
         return this._1077977599HoleLower;
      }
      
      public function set HoleLower(param1:Label) : void
      {
         var _loc2_:Object = this._1077977599HoleLower;
         if(_loc2_ !== param1)
         {
            this._1077977599HoleLower = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HoleLower",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HoleMax() : Label
      {
         return this._1538549660HoleMax;
      }
      
      public function set HoleMax(param1:Label) : void
      {
         var _loc2_:Object = this._1538549660HoleMax;
         if(_loc2_ !== param1)
         {
            this._1538549660HoleMax = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HoleMax",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HoleMin() : Label
      {
         return this._1538549422HoleMin;
      }
      
      public function set HoleMin(param1:Label) : void
      {
         var _loc2_:Object = this._1538549422HoleMin;
         if(_loc2_ !== param1)
         {
            this._1538549422HoleMin = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HoleMin",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HoleTol() : Label
      {
         return this._1538542511HoleTol;
      }
      
      public function set HoleTol(param1:Label) : void
      {
         var _loc2_:Object = this._1538542511HoleTol;
         if(_loc2_ !== param1)
         {
            this._1538542511HoleTol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HoleTol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get HoleUpper() : Label
      {
         return this._1069642846HoleUpper;
      }
      
      public function set HoleUpper(param1:Label) : void
      {
         var _loc2_:Object = this._1069642846HoleUpper;
         if(_loc2_ !== param1)
         {
            this._1069642846HoleUpper = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"HoleUpper",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get PrefFit() : Label
      {
         return this._1345958606PrefFit;
      }
      
      public function set PrefFit(param1:Label) : void
      {
         var _loc2_:Object = this._1345958606PrefFit;
         if(_loc2_ !== param1)
         {
            this._1345958606PrefFit = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"PrefFit",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ShaftFund() : Label
      {
         return this._91830335ShaftFund;
      }
      
      public function set ShaftFund(param1:Label) : void
      {
         var _loc2_:Object = this._91830335ShaftFund;
         if(_loc2_ !== param1)
         {
            this._91830335ShaftFund = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ShaftFund",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ShaftLower() : Label
      {
         return this._1442855737ShaftLower;
      }
      
      public function set ShaftLower(param1:Label) : void
      {
         var _loc2_:Object = this._1442855737ShaftLower;
         if(_loc2_ !== param1)
         {
            this._1442855737ShaftLower = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ShaftLower",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ShaftMax() : Label
      {
         return this._689768278ShaftMax;
      }
      
      public function set ShaftMax(param1:Label) : void
      {
         var _loc2_:Object = this._689768278ShaftMax;
         if(_loc2_ !== param1)
         {
            this._689768278ShaftMax = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ShaftMax",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ShaftMin() : Label
      {
         return this._689768040ShaftMin;
      }
      
      public function set ShaftMin(param1:Label) : void
      {
         var _loc2_:Object = this._689768040ShaftMin;
         if(_loc2_ !== param1)
         {
            this._689768040ShaftMin = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ShaftMin",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ShaftTol() : Label
      {
         return this._689761129ShaftTol;
      }
      
      public function set ShaftTol(param1:Label) : void
      {
         var _loc2_:Object = this._689761129ShaftTol;
         if(_loc2_ !== param1)
         {
            this._689761129ShaftTol = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ShaftTol",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ShaftUpper() : Label
      {
         return this._1434520984ShaftUpper;
      }
      
      public function set ShaftUpper(param1:Label) : void
      {
         var _loc2_:Object = this._1434520984ShaftUpper;
         if(_loc2_ !== param1)
         {
            this._1434520984ShaftUpper = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ShaftUpper",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Units() : Label
      {
         return this._81880911Units;
      }
      
      public function set Units(param1:Label) : void
      {
         var _loc2_:Object = this._81880911Units;
         if(_loc2_ !== param1)
         {
            this._81880911Units = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Units",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fitTolerance() : Label
      {
         return this._1998452996fitTolerance;
      }
      
      public function set fitTolerance(param1:Label) : void
      {
         var _loc2_:Object = this._1998452996fitTolerance;
         if(_loc2_ !== param1)
         {
            this._1998452996fitTolerance = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fitTolerance",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fitType() : DropDownList
      {
         return this._848093461fitType;
      }
      
      public function set fitType(param1:DropDownList) : void
      {
         var _loc2_:Object = this._848093461fitType;
         if(_loc2_ !== param1)
         {
            this._848093461fitType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fitType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fitTypeLab() : Label
      {
         return this._1740381858fitTypeLab;
      }
      
      public function set fitTypeLab(param1:Label) : void
      {
         var _loc2_:Object = this._1740381858fitTypeLab;
         if(_loc2_ !== param1)
         {
            this._1740381858fitTypeLab = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fitTypeLab",_loc2_,param1));
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
      public function get holeClass() : DropDownList
      {
         return this._1204599960holeClass;
      }
      
      public function set holeClass(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1204599960holeClass;
         if(_loc2_ !== param1)
         {
            this._1204599960holeClass = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"holeClass",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get holeType() : RadioButton
      {
         return this._514811878holeType;
      }
      
      public function set holeType(param1:RadioButton) : void
      {
         var _loc2_:Object = this._514811878holeType;
         if(_loc2_ !== param1)
         {
            this._514811878holeType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"holeType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get maxClearance() : Label
      {
         return this._1601164312maxClearance;
      }
      
      public function set maxClearance(param1:Label) : void
      {
         var _loc2_:Object = this._1601164312maxClearance;
         if(_loc2_ !== param1)
         {
            this._1601164312maxClearance = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"maxClearance",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get minClearance() : Label
      {
         return this._2075590378minClearance;
      }
      
      public function set minClearance(param1:Label) : void
      {
         var _loc2_:Object = this._2075590378minClearance;
         if(_loc2_ !== param1)
         {
            this._2075590378minClearance = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"minClearance",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get shaftClass() : DropDownList
      {
         return this._850224926shaftClass;
      }
      
      public function set shaftClass(param1:DropDownList) : void
      {
         var _loc2_:Object = this._850224926shaftClass;
         if(_loc2_ !== param1)
         {
            this._850224926shaftClass = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"shaftClass",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get shaftType() : RadioButton
      {
         return this._1911716652shaftType;
      }
      
      public function set shaftType(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1911716652shaftType;
         if(_loc2_ !== param1)
         {
            this._1911716652shaftType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"shaftType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get typegroup() : RadioButtonGroup
      {
         return this._526703493typegroup;
      }
      
      public function set typegroup(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._526703493typegroup;
         if(_loc2_ !== param1)
         {
            this._526703493typegroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"typegroup",_loc2_,param1));
            }
         }
      }
   }
}
