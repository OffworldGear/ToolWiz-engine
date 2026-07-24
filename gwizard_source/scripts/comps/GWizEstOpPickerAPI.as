package comps
{
   import cadcamwiz.GWizCCWEstRecord;
   import cadcamwizp.GWizCadCamD;
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import login.GWizLoginBar;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   import utils.SequencedArrayCollection;
   
   public class GWizEstOpPickerAPI implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizEstOpPickerAPI");
      
      private static var _1612358735OrderSize:Number = 1;
      
      private static var _editOp:GWizCCWEstRecord;
      
      public static var editing:Boolean = false;
      
      public static var CadCamD:GWizCadCamD;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      public var beginOpSessionDone:Boolean = false;
      
      private var opList:SequencedArrayCollection;
      
      private var selectedIndex:int;
      
      public var variableCost:Boolean = true;
      
      private var OpToUIFcn:Function;
      
      private var UIToOpFcn:Function;
      
      private var opType:String = "";
      
      public var saveBtnLabel:String = "Save Op";
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizEstOpPickerAPI(param1:Function, param2:Function)
      {
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
         this.UIToOpFcn = param1;
         this.OpToUIFcn = param2;
      }
      
      public static function estimatorApp() : Boolean
      {
         return GWizSettings.loginBar.appNameParm == GWizLoginBar.GW_ESTIMATOR_NAMEPARM;
      }
      
      public static function get editOp() : GWizCCWEstRecord
      {
         return _editOp;
      }
      
      public static function set editOp(param1:GWizCCWEstRecord) : void
      {
         _editOp = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get OrderSize() : Number
      {
         return GWizEstOpPickerAPI._1612358735OrderSize;
      }
      
      public static function set OrderSize(param1:Number) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizEstOpPickerAPI._1612358735OrderSize;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizEstOpPickerAPI,"OrderSize",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      public function beginOpSession(param1:GWizCCWEstRecord, param2:String, param3:SequencedArrayCollection, param4:int, param5:Boolean, param6:Boolean) : void
      {
         this.opList = param3;
         this.selectedIndex = param4;
         this.variableCost = param5;
         editOp = param1;
         if(!param1)
         {
            editOp = new GWizCCWEstRecord(GWizCCWEstRecord.OTHER_TYPE,"Other");
            editOp.rateper = param2;
         }
         editing = !param6;
         if(editing)
         {
            this.OpToUI(param1);
         }
         this.beginOpSessionDone = true;
      }
      
      public function saveOp(param1:Boolean) : void
      {
         if(param1)
         {
            this.UIToOp(editOp);
            if(!editing && editOp.type != GWizCCWEstRecord.MACHINING_TYPE)
            {
               if(this.selectedIndex >= 0)
               {
                  this.opList.addItemAt(editOp,this.selectedIndex);
               }
               else
               {
                  this.opList.addItem(editOp);
               }
            }
            else if(CadCamD)
            {
               if(!editing)
               {
                  CadCamD.saveOp(null);
               }
               else
               {
                  CadCamD.customMillWiz.UIToOp(editOp);
               }
            }
         }
      }
      
      private function OpToUI(param1:GWizCCWEstRecord) : void
      {
         if(param1)
         {
            this.OpToUIAux();
         }
      }
      
      private function OpToUIAux() : void
      {
         var _loc1_:GWizJustASec = null;
         if(this.OpToUIFcn != null)
         {
            this.OpToUIFcn(editOp);
         }
         else
         {
            _loc1_ = new GWizJustASec(this.OpToUIAux,0);
         }
      }
      
      private function UIToOp(param1:GWizCCWEstRecord) : void
      {
         if(this.UIToOpFcn != null)
         {
            this.UIToOpFcn(param1);
         }
         else
         {
            GWizUtils.assert(false);
         }
      }
      
      public function endOpSession() : void
      {
      }
      
      public function setOpType(param1:String) : void
      {
         this.opType = param1;
         if(editOp)
         {
            editOp.op = this.opType;
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
