package cadcamwiz
{
   import configinfo.GWizSettings;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import gwapi.GWizCalcAPIServer;
   import machines.GWizMachSelector2;
   import material.GWizMaterialChooser;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.VGroup;
   import utils.GATracker;
   
   public class GWizCadCam extends VGroup
   {
      
      protected static const log:ILogger = Log.getLogger("GWizCadCam");
      
      public static var recalcEngine:GWizCCWRecalc = new GWizCCWRecalc();
      
      public static var autoRecalc:Boolean = false;
      
      public static var CADCAMWiz:GWizCadCam;
      
      public static var currWizard:String = "";
      
      private static var _287459107_needRecalc:Boolean = true;
      
      public static var oldMMSChangeFcn:Function;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _showing:Boolean = false;
      
      public var ccwOptions:GWizCCWMillOptions;
      
      public var ccwLatheOptions:GWizCCWLatheOptions;
      
      public var MatChooser:GWizMaterialChooser;
      
      public var Machine:GWizMachSelector2;
      
      private const MIN_AFTER_USER_RECALC_TIME:int = 1000.0;
      
      private var debugStopCt:int = 0;
      
      private var userActivityTime:Date;
      
      public function GWizCadCam()
      {
         this.userActivityTime = new Date();
         super();
         GWizCalcAPIServer.recalcCADCAM = this.manualRecalc;
      }
      
      public static function set needRecalc(param1:Boolean) : void
      {
         _needRecalc = param1;
      }
      
      public static function get needRecalc() : Boolean
      {
         return _needRecalc;
      }
      
      [Bindable(event="propertyChange")]
      public static function get _needRecalc() : Boolean
      {
         return GWizCadCam._287459107_needRecalc;
      }
      
      public static function set _needRecalc(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCadCam._287459107_needRecalc;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCadCam,"_needRecalc",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      public function get showing() : Boolean
      {
         return this._showing && GWizSettings.docWindow.visible;
      }
      
      public function set showing(param1:Boolean) : void
      {
         this._showing = param1;
      }
      
      override protected function commitProperties() : void
      {
         super.commitProperties();
         if(needRecalc && this.showing)
         {
            this.recalcAux();
         }
      }
      
      public function requestRecalc(param1:FlexEvent = null) : void
      {
         if(oldMMSChangeFcn != null)
         {
            oldMMSChangeFcn();
         }
         needRecalc = true;
         invalidateProperties();
      }
      
      private function recalcAux() : void
      {
         if(!autoRecalc)
         {
            return;
         }
         var _loc1_:Date = new Date();
         if(_loc1_.valueOf() - this.userActivityTime.valueOf() > this.MIN_AFTER_USER_RECALC_TIME)
         {
            this.manualRecalc();
         }
         else
         {
            this.callLater(this.invalidateProperties);
         }
      }
      
      public function manualRecalc() : void
      {
         this.recalc();
         needRecalc = false;
         GATracker.logPageView("CADCAMRecalcs" + String(GWizCCWMillOptions.cadcamRecalcs),"CADCAMRecalcs: " + String(GWizCCWMillOptions.cadcamRecalcs));
         ++GWizCCWMillOptions.cadcamRecalcs;
      }
      
      protected function userActivity() : void
      {
         this.userActivityTime = new Date();
      }
      
      public function hideMe() : void
      {
         this.showing = false;
         this.userActivity();
         this.enableOutputs();
      }
      
      protected function recalc() : void
      {
      }
      
      public function enableOutputs() : void
      {
      }
      
      public function getHourly() : Number
      {
         var _loc1_:Number = 0;
         if(GWizSettings.FeedsSpeedsApp && GWizSettings.FeedsSpeedsApp.estInput && GWizSettings.FeedsSpeedsApp.estInput.HourlyRate)
         {
            _loc1_ = GWizSettings.FeedsSpeedsApp.estInput.HourlyRate.value;
         }
         return _loc1_;
      }
   }
}
