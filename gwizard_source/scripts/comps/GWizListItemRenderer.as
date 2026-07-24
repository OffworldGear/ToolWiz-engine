package comps
{
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.IStateClient2;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.states.SetStyle;
   import mx.states.State;
   import spark.components.Label;
   import spark.components.supportClasses.ItemRenderer;
   
   use namespace mx_internal;
   
   public class GWizListItemRenderer extends ItemRenderer implements IBindingClient, IStateClient2
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1810058455_GWizListItemRenderer_SetStyle1:SetStyle;
      
      private var _1085922839sparkLabel:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizListItemRenderer()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizListItemRenderer_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizListItemRendererWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizListItemRenderer[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.height = 30;
         this.mxmlContent = [this._GWizListItemRenderer_Label1_i()];
         this.currentState = "normal";
         states = [new State({
            "name":"normal",
            "overrides":[new SetStyle().initializeFromObject({
               "target":"sparkLabel",
               "name":"color",
               "value":0
            })]
         }),new State({
            "name":"hovered",
            "overrides":[new SetStyle().initializeFromObject({
               "target":"sparkLabel",
               "name":"color",
               "value":16777215
            })]
         }),new State({
            "name":"selected",
            "overrides":[new SetStyle().initializeFromObject({
               "target":"sparkLabel",
               "name":"color",
               "value":16777215
            }),this._GWizListItemRenderer_SetStyle1 = SetStyle(new SetStyle().initializeFromObject({
               "target":"sparkLabel",
               "name":"backgroundColor",
               "value":undefined
            }))]
         })];
         BindingManager.executeBindings(this,"_GWizListItemRenderer_SetStyle1",this._GWizListItemRenderer_SetStyle1);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizListItemRenderer._watcherSetupUtil = param1;
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
      
      private function _GWizListItemRenderer_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("paddingRight",8);
         _loc1_.setStyle("paddingLeft",8);
         _loc1_.setStyle("verticalAlign","middle");
         _loc1_.id = "sparkLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sparkLabel = _loc1_;
         BindingManager.executeBindings(this,"sparkLabel",this.sparkLabel);
         return _loc1_;
      }
      
      private function _GWizListItemRenderer_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Object
         {
            return getStyle("selectionColor");
         },null,"_GWizListItemRenderer_SetStyle1.value");
         result[1] = new Binding(this,null,null,"sparkLabel.text","label");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get _GWizListItemRenderer_SetStyle1() : SetStyle
      {
         return this._1810058455_GWizListItemRenderer_SetStyle1;
      }
      
      public function set _GWizListItemRenderer_SetStyle1(param1:SetStyle) : void
      {
         var _loc2_:Object = this._1810058455_GWizListItemRenderer_SetStyle1;
         if(_loc2_ !== param1)
         {
            this._1810058455_GWizListItemRenderer_SetStyle1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_GWizListItemRenderer_SetStyle1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sparkLabel() : Label
      {
         return this._1085922839sparkLabel;
      }
      
      public function set sparkLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1085922839sparkLabel;
         if(_loc2_ !== param1)
         {
            this._1085922839sparkLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sparkLabel",_loc2_,param1));
            }
         }
      }
   }
}
