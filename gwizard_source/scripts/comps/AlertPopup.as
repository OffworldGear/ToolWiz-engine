package comps
{
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import spark.components.TextArea;
   
   use namespace mx_internal;
   
   public class AlertPopup extends GWizPopUp implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1603095256alertMessageText:TextArea;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _954925063message:String = "";
      
      public var closeHandler:Function = null;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function AlertPopup()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._AlertPopup_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_AlertPopupWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return AlertPopup[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Alert";
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.paddingBottom = 0;
         this.paddingLeft = 0;
         this.paddingRight = 0;
         this.paddingTop = 0;
         this.mxmlContent = [this._AlertPopup_TextArea1_i()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         AlertPopup._watcherSetupUtil = param1;
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
         super.close();
         if(this.closeHandler != null)
         {
            this.closeHandler(param1);
         }
      }
      
      private function _AlertPopup_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.selectable = false;
         _loc1_.alpha = 0.8;
         _loc1_.setStyle("verticalScrollPolicy","auto");
         _loc1_.setStyle("color",0);
         _loc1_.id = "alertMessageText";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.alertMessageText = _loc1_;
         BindingManager.executeBindings(this,"alertMessageText",this.alertMessageText);
         return _loc1_;
      }
      
      private function _AlertPopup_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():String
         {
            var _loc1_:* = this.message;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"alertMessageText.text");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get alertMessageText() : TextArea
      {
         return this._1603095256alertMessageText;
      }
      
      public function set alertMessageText(param1:TextArea) : void
      {
         var _loc2_:Object = this._1603095256alertMessageText;
         if(_loc2_ !== param1)
         {
            this._1603095256alertMessageText = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"alertMessageText",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get message() : String
      {
         return this._954925063message;
      }
      
      public function set message(param1:String) : void
      {
         var _loc2_:Object = this._954925063message;
         if(_loc2_ !== param1)
         {
            this._954925063message = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"message",_loc2_,param1));
            }
         }
      }
   }
}
