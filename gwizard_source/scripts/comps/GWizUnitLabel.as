package comps
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import machines.GWizMachProfile;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import skins.GWizStylePalette;
   import spark.components.HGroup;
   import spark.components.Label;
   import utils.GWizUtils;
   
   public class GWizUnitLabel implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizUnitLabel");
       
      
      private var _theOwnerID:String = "";
      
      public var useMetric:Function;
      
      private var _UnitLabel:String = "";
      
      private var _711054966_titleColor:uint;
      
      private var unitLabelTarget:Label;
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizUnitLabel()
      {
         this._711054966_titleColor = GWizStylePalette.textColor;
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
      }
      
      public function set theOwnerID(param1:String) : void
      {
         this._theOwnerID = param1;
      }
      
      public function get theOwnerID() : String
      {
         return this._theOwnerID;
      }
      
      public function set UnitLabel(param1:String) : void
      {
         this._UnitLabel = param1;
      }
      
      public function get UnitLabel() : String
      {
         return this._UnitLabel;
      }
      
      public function set titleColor(param1:uint) : void
      {
         this._titleColor = param1;
         if(this.unitLabelTarget)
         {
            this.unitLabelTarget.setStyle("color",this.titleColor);
         }
      }
      
      public function get titleColor() : uint
      {
         return this._titleColor;
      }
      
      public function setupUnitLabel(param1:HGroup) : Label
      {
         if(this._UnitLabel != "")
         {
            if(!this.unitLabelTarget)
            {
               this.unitLabelTarget = new Label();
               this.unitLabelTarget.setStyle("fontFamily","_typewriter");
               this.unitLabelTarget.setStyle("fontGridFitType","subpixel");
               this.unitLabelTarget.setStyle("fontAntiAliasType","advanced");
               this.unitLabelTarget.setStyle("color",this.titleColor);
               param1.addElementAt(this.unitLabelTarget,1);
               this.unitLabelTarget.doubleClickEnabled = true;
               this.unitLabelTarget.addEventListener(MouseEvent.DOUBLE_CLICK,this.onUnitLabelDoubleClick);
               this.unitLabelTarget.toolTip = "Double click to toggle Imperial/Metric units.";
            }
            this.setupUnitLabelText();
         }
         return this.unitLabelTarget;
      }
      
      private function onUnitLabelDoubleClick(param1:Event) : void
      {
         GWizMachProfile.toggleUnits();
      }
      
      public function setupUnitLabelText() : void
      {
         if(this.theOwnerID == "IPR")
         {
            log.debug("gotcha");
         }
         if(this._UnitLabel == "" || !this.unitLabelTarget)
         {
            return;
         }
         var _loc1_:* = this._UnitLabel;
         switch(this._UnitLabel)
         {
            case "in":
               if(this.useMetric())
               {
                  _loc1_ = "mm";
               }
               break;
            case "sfm":
               if(this.useMetric())
               {
                  _loc1_ = "m/min";
               }
               break;
            case "ipt":
               if(this.useMetric())
               {
                  _loc1_ = "mm/tooth";
               }
               break;
            case "hp":
               if(this.useMetric())
               {
                  _loc1_ = "kw";
               }
               break;
            case "ipm":
               if(this.useMetric())
               {
                  _loc1_ = "mm/min";
               }
               break;
            case "ips":
               if(this.useMetric())
               {
                  _loc1_ = "mm/sec";
               }
               break;
            case "oz-in":
               if(this.useMetric())
               {
                  _loc1_ = "N-m";
               }
               break;
            case "in-Hg":
               if(this.useMetric())
               {
                  _loc1_ = "mbar";
               }
               break;
            case "sq in":
               if(this.useMetric())
               {
                  _loc1_ = "sq cm";
               }
               break;
            case "lb":
               if(this.useMetric())
               {
                  _loc1_ = "kg";
               }
               break;
            case "align":
               _loc1_ = "    ";
               break;
            default:
               GWizUtils.assert(false);
         }
         while(_loc1_.length < 3)
         {
            _loc1_ += " ";
         }
         this.unitLabelTarget.text = _loc1_ + " ";
         this.unitLabelTarget.setStyle("color",this.titleColor);
      }
      
      [Bindable(event="propertyChange")]
      private function get _titleColor() : uint
      {
         return this._711054966_titleColor;
      }
      
      private function set _titleColor(param1:uint) : void
      {
         var _loc2_:Object = this._711054966_titleColor;
         if(_loc2_ !== param1)
         {
            this._711054966_titleColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_titleColor",_loc2_,param1));
            }
         }
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this._bindingEventDispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this._bindingEventDispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this._bindingEventDispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.willTrigger(param1);
      }
   }
}
