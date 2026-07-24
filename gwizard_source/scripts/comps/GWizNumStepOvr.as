package comps
{
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.ui.Keyboard;
   import mx.controls.Image;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.IndexChangedEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizNumStepOvr extends GWizNumStep
   {
      
      private static const log:ILogger = Log.getLogger("GWizNumStepOvr");
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1774231116overridden:Boolean = false;
      
      private var _1238050139padlockImg:Class;
      
      private var statusLED:Image = null;
      
      public function GWizNumStepOvr()
      {
         this._1238050139padlockImg = GWizNumStepOvr_padlockImg;
         super();
         mx_internal::_document = this;
         this.addEventListener("creationComplete",this.___GWizNumStepOvr_GWizNumStep1_creationComplete);
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
      
      override public function setVal(param1:Number) : void
      {
         if(!this.overridden)
         {
            super.setVal(param1);
         }
      }
      
      public function setValOverride(param1:Number) : void
      {
         super.setVal(param1);
         this.overridden = true;
         this.updateRadio();
      }
      
      public function resetOverride(param1:Boolean = false) : void
      {
         if(!enabled)
         {
            return;
         }
         this.overridden = false;
         if(param1)
         {
            this.setVal(0);
         }
         this.updateRadio();
      }
      
      public function isOverridden() : Boolean
      {
         return this.overridden;
      }
      
      private function userOverride(param1:Event) : void
      {
         if(!(param1 is KeyboardEvent) || KeyboardEvent(param1).keyCode != Keyboard.TAB)
         {
            this.overridden = true;
            this.updateRadio();
         }
         dispatchEvent(param1);
      }
      
      private function unOverride(param1:Event) : void
      {
         var event:Event = param1;
         this.overridden = false;
         this.updateRadio();
         try
         {
            super.onValueCommit(true);
            super.dispatchEvent(new IndexChangedEvent(Event.CHANGE,true));
         }
         catch(myError:Error)
         {
            log.debug(myError.message);
         }
      }
      
      private function updateRadio() : void
      {
         if(!this.statusLED)
         {
            return;
         }
         this.statusLED.visible = this.overridden;
         if(this.overridden)
         {
            stepper.setStyle("contentBackgroundColor","0xDDDDFF");
         }
         else
         {
            stepper.setStyle("contentBackgroundColor","white");
         }
      }
      
      private function onCreationComplete() : void
      {
         this.statusLED = new Image();
         this.statusLED.visible = false;
         this.statusLED.source = this.padlockImg;
         this.statusLED.addEventListener(MouseEvent.CLICK,this.unOverride);
         this.statusLED.toolTip = "Padlock shows value was overridden and locked to what you\'ve entered. Click padlock to clear the lock.";
         this.stepperGroup.addElement(this.statusLED);
         stepper.addEventListener(Event.CHANGE,this.userOverride);
         stepper.addEventListener(KeyboardEvent.KEY_UP,this.userOverride);
      }
      
      public function ___GWizNumStepOvr_GWizNumStep1_creationComplete(param1:FlexEvent) : void
      {
         this.onCreationComplete();
      }
      
      [Bindable(event="propertyChange")]
      private function get overridden() : Boolean
      {
         return this._1774231116overridden;
      }
      
      private function set overridden(param1:Boolean) : void
      {
         var _loc2_:Object = this._1774231116overridden;
         if(_loc2_ !== param1)
         {
            this._1774231116overridden = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"overridden",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get padlockImg() : Class
      {
         return this._1238050139padlockImg;
      }
      
      public function set padlockImg(param1:Class) : void
      {
         var _loc2_:Object = this._1238050139padlockImg;
         if(_loc2_ !== param1)
         {
            this._1238050139padlockImg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"padlockImg",_loc2_,param1));
            }
         }
      }
   }
}
