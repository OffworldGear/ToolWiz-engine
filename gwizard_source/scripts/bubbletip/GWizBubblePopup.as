package bubbletip
{
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import spark.components.TextArea;
   
   public class GWizBubblePopup extends GWizPopUp
   {
       
      
      private var _874853040theMsg:TextArea;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var bubbleID:String;
      
      public function GWizBubblePopup()
      {
         super();
         mx_internal::_document = this;
         this.width = 400;
         this.height = 300;
         this.title = "Bubble Tip";
         this.okLabel = "Got It!";
         this.cancelLabel = "";
         this.mxmlContent = [this._GWizBubblePopup_TextArea1_i()];
         this.addEventListener("click",this.___GWizBubblePopup_GWizPopUp1_click);
      }
      
      public static function bubblePopUp(param1:String, param2:DisplayObject) : void
      {
         var _loc3_:String = null;
         var _loc4_:GWizBubblePopup = null;
         if(!param2)
         {
            param2 = GWizSettings.docWindow;
         }
         if(GWizSettings.bubbleMsgs.popupOKFor(param1))
         {
            _loc3_ = GWizSettings.bubbleMsgs.bubbleMsg(param1);
            if(_loc3_)
            {
               (_loc4_ = GWizBubblePopup(GWizPopUpManager.createPopUp(DisplayObject(param2),GWizBubblePopup,true))).bubbleID = param1;
               _loc4_.loadTip(_loc3_);
            }
         }
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
      
      override public function onOk(param1:Event) : void
      {
         GWizSettings.bubbleMsgs.finishedBubble(this.bubbleID);
         super.onOk(param1);
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.onOk(param1);
      }
      
      private function loadTip(param1:String) : void
      {
         this.theMsg.text = param1;
      }
      
      private function _GWizBubblePopup_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "theMsg";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theMsg = _loc1_;
         BindingManager.executeBindings(this,"theMsg",this.theMsg);
         return _loc1_;
      }
      
      public function ___GWizBubblePopup_GWizPopUp1_click(param1:MouseEvent) : void
      {
         this.onOk(param1);
      }
      
      [Bindable(event="propertyChange")]
      public function get theMsg() : TextArea
      {
         return this._874853040theMsg;
      }
      
      public function set theMsg(param1:TextArea) : void
      {
         var _loc2_:Object = this._874853040theMsg;
         if(_loc2_ !== param1)
         {
            this._874853040theMsg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theMsg",_loc2_,param1));
            }
         }
      }
   }
}
