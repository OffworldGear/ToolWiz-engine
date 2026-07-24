package comps
{
   import mx.binding.BindingManager;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import skins.GWizStylePalette;
   import spark.components.HGroup;
   import spark.components.Label;
   import utils.ColorPalette;
   import utils.GWizUtils;
   
   public class GWizLabText extends HGroup
   {
      
      private static const log:ILogger = Log.getLogger("GWizLabText");
      
      private static const ALERT_TEXT_COLOR:uint = ColorPalette.secondaryb1;
       
      
      private var _896192468spacer:Spacer;
      
      private var _1078357251theLabel:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var ccDone:Boolean = false;
      
      private var _68996955fatSpacer:Boolean = true;
      
      private var _1110433373labTxt:String = "";
      
      private var _UnitLabel:GWizUnitLabel;
      
      private var unitLabelTarget:Label;
      
      public var decPlaces:Number = 4;
      
      public var usesMetric:Boolean = true;
      
      private var _460780813metUnits:String = "MM";
      
      private var _1287124693backgroundColor:uint = 16777215;
      
      private var val:Number = 0.0;
      
      private var oldUnits:String = "Inches";
      
      public function GWizLabText()
      {
         this._UnitLabel = new GWizUnitLabel();
         super();
         mx_internal::_document = this;
         this.verticalAlign = "middle";
         this.mxmlContent = [this._GWizLabText_Label1_i(),this._GWizLabText_Spacer1_i()];
         this.addEventListener("creationComplete",this.___GWizLabText_HGroup1_creationComplete);
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
            this.color = 0;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function onCC() : void
      {
         this._UnitLabel.useMetric = this.useMetricFcn;
         this.ccDone = true;
         this.UnitLabel = this._UnitLabel.UnitLabel;
         this._UnitLabel.theOwnerID = this.id;
         GWizNumStep.checkUnitsCC.addFunction("GWizLabText",this.checkUnits,false);
         this.checkUnits();
         if(!this.fatSpacer)
         {
            this.removeElement(this.spacer);
         }
      }
      
      public function set UnitLabel(param1:String) : void
      {
         this._UnitLabel.UnitLabel = param1;
         if(param1.length > 0 && this.ccDone)
         {
            this.unitLabelTarget = this._UnitLabel.setupUnitLabel(this);
         }
      }
      
      public function get UnitLabel() : String
      {
         return this._UnitLabel.UnitLabel;
      }
      
      private function useMetricFcn() : Boolean
      {
         return this.oldUnits == GWizUtils.MM_UNITS && this.usesMetric;
      }
      
      public function set labWidth(param1:int) : void
      {
      }
      
      public function set value(param1:Number) : void
      {
         this.setVal(param1);
      }
      
      public function get value() : Number
      {
         return this.getVal();
      }
      
      public function setVal(param1:Number) : void
      {
         this.val = param1;
         this.formatText();
      }
      
      public function getVal() : Number
      {
         return this.val;
      }
      
      public function getValCurrUnits() : Number
      {
         return Number(this.formatText());
      }
      
      public function checkUnits(param1:Object = null) : Boolean
      {
         if(false && GWizUtils.debug && id == "IPR")
         {
            log.debug("gotcha");
         }
         if(this.usesMetric && GWizUtils.Units != this.oldUnits)
         {
            this.formatText();
            this.oldUnits = GWizUtils.Units;
            this._UnitLabel.setupUnitLabelText();
         }
         return true;
      }
      
      public function setLabTxt(param1:String) : void
      {
         this.labTxt = param1;
         this.formatText();
      }
      
      private function formatText() : String
      {
         var _loc1_:String = GWizUtils.formatPlaces(this.val,this.decPlaces,this.usesMetric,this.metUnits);
         this.theLabel.text = this.labTxt + " " + _loc1_;
         var _loc2_:Object = this.theLabel.getStyle("color");
         this._UnitLabel.titleColor = uint(_loc2_);
         return _loc1_;
      }
      
      public function setAlertTextColor(param1:Boolean) : void
      {
         if(param1)
         {
            this.setStyle("color",ALERT_TEXT_COLOR);
         }
         else
         {
            this.setStyle("color",GWizStylePalette.textColor);
         }
      }
      
      private function _GWizLabText_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "theLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theLabel = _loc1_;
         BindingManager.executeBindings(this,"theLabel",this.theLabel);
         return _loc1_;
      }
      
      private function _GWizLabText_Spacer1_i() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         _loc1_.height = 1;
         _loc1_.id = "spacer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.spacer = _loc1_;
         BindingManager.executeBindings(this,"spacer",this.spacer);
         return _loc1_;
      }
      
      public function ___GWizLabText_HGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      [Bindable(event="propertyChange")]
      public function get spacer() : Spacer
      {
         return this._896192468spacer;
      }
      
      public function set spacer(param1:Spacer) : void
      {
         var _loc2_:Object = this._896192468spacer;
         if(_loc2_ !== param1)
         {
            this._896192468spacer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"spacer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get theLabel() : Label
      {
         return this._1078357251theLabel;
      }
      
      public function set theLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1078357251theLabel;
         if(_loc2_ !== param1)
         {
            this._1078357251theLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fatSpacer() : Boolean
      {
         return this._68996955fatSpacer;
      }
      
      public function set fatSpacer(param1:Boolean) : void
      {
         var _loc2_:Object = this._68996955fatSpacer;
         if(_loc2_ !== param1)
         {
            this._68996955fatSpacer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fatSpacer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labTxt() : String
      {
         return this._1110433373labTxt;
      }
      
      public function set labTxt(param1:String) : void
      {
         var _loc2_:Object = this._1110433373labTxt;
         if(_loc2_ !== param1)
         {
            this._1110433373labTxt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labTxt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get metUnits() : String
      {
         return this._460780813metUnits;
      }
      
      public function set metUnits(param1:String) : void
      {
         var _loc2_:Object = this._460780813metUnits;
         if(_loc2_ !== param1)
         {
            this._460780813metUnits = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"metUnits",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get backgroundColor() : uint
      {
         return this._1287124693backgroundColor;
      }
      
      public function set backgroundColor(param1:uint) : void
      {
         var _loc2_:Object = this._1287124693backgroundColor;
         if(_loc2_ !== param1)
         {
            this._1287124693backgroundColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"backgroundColor",_loc2_,param1));
            }
         }
      }
   }
}
