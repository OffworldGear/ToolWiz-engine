package bubbletip
{
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import mx.binding.BindingManager;
   import mx.core.ClassFactory;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Group;
   import utils.ColorPalette;
   import utils.GWizJustASec;
   
   public class GWizBubbleTip extends Group
   {
      
      private static const log:ILogger = Log.getLogger("GWizBubbleTip");
      
      private static const OVERLAY_ALPHA:Number = 0.5;
      
      private static const OVERLAY_SIZE:Number = 30;
      
      private static const PULSE_RANGE:int = 20;
      
      private static const MIN_PULSE_SZ:int = 15;
       
      
      private var _186116767theOverlay:ClassFactory;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _702356292myWindow:DisplayObject = null;
      
      public var bubbleID:String;
      
      private var ovr:controlOverlay;
      
      private var maxLaterCalls:int = 120;
      
      private const PULSE_IN_PLACE:Boolean = true;
      
      private var pulseTimer:Timer;
      
      private var pulseSz:int = 1;
      
      private var pulseIncr:int = 1;
      
      public function GWizBubbleTip()
      {
         this.ovr = new controlOverlay();
         this.pulseTimer = new Timer(100);
         super();
         mx_internal::_document = this;
         this.includeInLayout = true;
         this.visible = true;
         this._GWizBubbleTip_ClassFactory1_i();
         this.addEventListener("add",this.___GWizBubbleTip_Group1_add);
         this.addEventListener("creationComplete",this.___GWizBubbleTip_Group1_creationComplete);
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
         if(GWizSettings.bubbleMsgs && GWizSettings.bubbleMsgs.bubbleEnabledCC)
         {
            GWizSettings.bubbleMsgs.bubbleEnabledCC.addFunction("GWizBubbleTip",this.bubbleEnabled,false);
         }
         else
         {
            this.callLater(this.onCC);
         }
      }
      
      private function onAdd() : void
      {
         var _loc1_:Object = null;
         var _loc2_:GWizJustASec = null;
         var _loc3_:GWizJustASec = null;
         if(GWizSettings.bubbleMsgs)
         {
            if(GWizSettings.bubbleMsgs.allowBubbleTips())
            {
               if(GWizSettings.bubbleMsgs.popupOKFor(this.bubbleID))
               {
                  _loc1_ = this.getElementAt(0);
                  if(_loc1_.hasOwnProperty("visible") && _loc1_.visible)
                  {
                     this.ovr.width = OVERLAY_SIZE;
                     this.ovr.height = OVERLAY_SIZE;
                     this.ovr.solidColor.color = ColorPalette.primary4;
                     this.ovr.solidColor.alpha = OVERLAY_ALPHA;
                     this.ovr.x = 0;
                     this.ovr.includeInLayout = false;
                     this.resizeOverlay();
                     this.addElement(this.ovr);
                     this.pulseTimer.addEventListener("timer",this.pulseHandler);
                     this.pulseTimer.start();
                     this.addEventListener(MouseEvent.CLICK,this.doPopUp,true);
                  }
                  else
                  {
                     _loc2_ = new GWizJustASec(this.onAdd);
                  }
               }
            }
         }
         else if(this.maxLaterCalls > 0)
         {
            _loc3_ = new GWizJustASec(this.onAdd);
            --this.maxLaterCalls;
         }
      }
      
      private function bubbleEnabled(param1:String) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc2_:Boolean = false;
         if(param1 == "")
         {
            param1 = this.bubbleID;
            _loc2_ = true;
         }
         if(param1 == this.bubbleID)
         {
            _loc3_ = 0;
            while(_loc3_ < this.numElements)
            {
               if((_loc4_ = this.getElementAt(_loc3_)) == this.ovr)
               {
                  if(GWizSettings.bubbleMsgs.bubbleFinished(this.bubbleID))
                  {
                     this.removeElement(this.ovr);
                     this.removeEventListener(MouseEvent.CLICK,this.doPopUp,true);
                     return _loc2_;
                  }
               }
               _loc3_++;
            }
            this.maxLaterCalls = 100;
            this.onAdd();
         }
         return true;
      }
      
      private function doPopUp(param1:MouseEvent) : void
      {
         GWizBubblePopup.bubblePopUp(this.bubbleID,this.myWindow);
         if(GWizSettings.bubbleMsgs)
         {
            if(GWizSettings.bubbleMsgs.popupOKFor(this.bubbleID))
            {
               param1.stopPropagation();
            }
         }
      }
      
      private function resizeOverlay() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc1_:Object = this.getElementAt(0);
         if(this.PULSE_IN_PLACE)
         {
            _loc2_ = _loc1_.y + (_loc1_.height - this.ovr.height) / 2;
            _loc3_ = _loc1_.x + (OVERLAY_SIZE - this.ovr.width) / 2;
            if(_loc2_ != this.ovr.y)
            {
               this.ovr.y = _loc2_;
            }
            if(_loc3_ != this.ovr.x)
            {
               this.ovr.x = _loc3_;
            }
         }
         else if((_loc4_ = (_loc1_.height - OVERLAY_SIZE) / 2) != this.ovr.y)
         {
            this.ovr.y = _loc4_;
         }
      }
      
      private function pulseHandler(param1:TimerEvent) : void
      {
         this.pulseSz += this.pulseIncr;
         if(this.pulseSz > PULSE_RANGE)
         {
            this.pulseSz = PULSE_RANGE;
            this.pulseIncr *= -1;
         }
         else if(this.pulseSz < MIN_PULSE_SZ)
         {
            this.pulseSz = MIN_PULSE_SZ;
            this.pulseIncr *= -1;
         }
         this.ovr.width = this.ovr.height = Number(this.pulseSz) / Number(PULSE_RANGE) * OVERLAY_SIZE;
         this.resizeOverlay();
      }
      
      private function _GWizBubbleTip_ClassFactory1_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = controlOverlay;
         _loc1_.properties = {"outerDocument":this};
         this.theOverlay = _loc1_;
         BindingManager.executeBindings(this,"theOverlay",this.theOverlay);
         return _loc1_;
      }
      
      public function ___GWizBubbleTip_Group1_add(param1:FlexEvent) : void
      {
         this.onAdd();
      }
      
      public function ___GWizBubbleTip_Group1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      [Bindable(event="propertyChange")]
      public function get theOverlay() : ClassFactory
      {
         return this._186116767theOverlay;
      }
      
      public function set theOverlay(param1:ClassFactory) : void
      {
         var _loc2_:Object = this._186116767theOverlay;
         if(_loc2_ !== param1)
         {
            this._186116767theOverlay = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theOverlay",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get myWindow() : DisplayObject
      {
         return this._702356292myWindow;
      }
      
      public function set myWindow(param1:DisplayObject) : void
      {
         var _loc2_:Object = this._702356292myWindow;
         if(_loc2_ !== param1)
         {
            this._702356292myWindow = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"myWindow",_loc2_,param1));
            }
         }
      }
   }
}
