package comps
{
   import flash.events.MouseEvent;
   import mx.binding.BindingManager;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import spark.components.Button;
   import spark.components.TextArea;
   import spark.components.VGroup;
   import spark.components.Window;
   import utils.GWizUtils;
   
   public class GWizLogWindow extends Window
   {
      
      public static var logWindow:GWizLogWindow;
      
      private static const ALLOW_DEBUG_LOG:Boolean = false;
      
      private static var backlog:Array = [];
       
      
      private var _3556653text:TextArea;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizLogWindow()
      {
         super();
         mx_internal::_document = this;
         this.title = "Debug Log Window";
         this.width = 400;
         this.height = 300;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizLogWindow_Array1_c);
      }
      
      public static function newLogWindow() : void
      {
         if(ALLOW_DEBUG_LOG && GWizUtils.debug)
         {
            logWindow = new GWizLogWindow();
            logWindow.open();
         }
      }
      
      public static function write(param1:String) : void
      {
         var _loc2_:int = 0;
         if(logWindow)
         {
            if(backlog.length > 0)
            {
               _loc2_ = 0;
               while(_loc2_ < backlog.length)
               {
                  logWindow.text.text += String(backlog[_loc2_]);
                  _loc2_++;
               }
               backlog = [];
            }
            logWindow.text.text += param1;
         }
         else
         {
            backlog.push(param1);
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
      
      private function _GWizLogWindow_Array1_c() : Array
      {
         return [this._GWizLogWindow_VGroup1_c()];
      }
      
      private function _GWizLogWindow_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizLogWindow_TextArea1_i(),this._GWizLogWindow_Button1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizLogWindow_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "text";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.text = _loc1_;
         BindingManager.executeBindings(this,"text",this.text);
         return _loc1_;
      }
      
      private function _GWizLogWindow_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Clear";
         _loc1_.addEventListener("click",this.___GWizLogWindow_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizLogWindow_Button1_click(param1:MouseEvent) : void
      {
         this.text.text = "";
      }
      
      [Bindable(event="propertyChange")]
      public function get text() : TextArea
      {
         return this._3556653text;
      }
      
      public function set text(param1:TextArea) : void
      {
         var _loc2_:Object = this._3556653text;
         if(_loc2_ !== param1)
         {
            this._3556653text = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"text",_loc2_,param1));
            }
         }
      }
   }
}
