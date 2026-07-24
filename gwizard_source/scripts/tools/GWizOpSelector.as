package tools
{
   import flash.display.DisplayObject;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.VGroup;
   
   use namespace mx_internal;
   
   public class GWizOpSelector extends VGroup implements IBindingClient
   {
      
      private static var _721167849filtered:Boolean = false;
      
      private static var _341480088opAllDnArrowIcon:Class = GWizOpSelector_opAllDnArrowIcon;
      
      private static var _385561447opAllIcon:Class = GWizOpSelector_opAllIcon;
      
      private static var _1360116134opHoleIcon:Class = GWizOpSelector_opHoleIcon;
      
      private static var _367153136opPocketIcon:Class = GWizOpSelector_opPocketIcon;
      
      private static var _283481442opSurfacingIcon:Class = GWizOpSelector_opSurfacingIcon;
      
      private static var _705798193op2DProfileIcon:Class = GWizOpSelector_op2DProfileIcon;
      
      private static var _999201200op3DProfileIcon:Class = GWizOpSelector_op3DProfileIcon;
      
      private static var _251326928opThreadingIcon:Class = GWizOpSelector_opThreadingIcon;
      
      private static var _2034406657opEngraveCarveIcon:Class = GWizOpSelector_opEngraveCarveIcon;
      
      private static var _763710874opChamferIcon:Class = GWizOpSelector_opChamferIcon;
      
      private static var _1548468376opProbeIcon:Class = GWizOpSelector_opProbeIcon;
      
      private static var _1716503485opTurningIcon:Class = GWizOpSelector_opTurningIcon;
      
      private static var _1961342679opBoringIcon:Class = GWizOpSelector_opBoringIcon;
      
      private static var _2008379353opPartGrooveIcon:Class = GWizOpSelector_opPartGrooveIcon;
      
      private static var _1053360400opSinglePtThreadIcon:Class = GWizOpSelector_opSinglePtThreadIcon;
      
      public static var opChoices:ArrayCollection;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _1122576211FilterLED:Label;
      
      private var _104387img:Image;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var currChoice:int = 0;
      
      private var _152343201centerParent:DisplayObject;
      
      public var opSelectedFcn:Function;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizOpSelector()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizOpSelector_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_tools_GWizOpSelectorWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizOpSelector[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.horizontalAlign = "center";
         this.width = 130;
         this.height = 130;
         this.mxmlContent = [this._GWizOpSelector_Image1_i(),this._GWizOpSelector_Label1_i()];
         this.addEventListener("creationComplete",this.___GWizOpSelector_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizOpSelector._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get filtered() : Boolean
      {
         return GWizOpSelector._721167849filtered;
      }
      
      public static function set filtered(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._721167849filtered;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"filtered",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get opAllDnArrowIcon() : Class
      {
         return GWizOpSelector._341480088opAllDnArrowIcon;
      }
      
      public static function set opAllDnArrowIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._341480088opAllDnArrowIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"opAllDnArrowIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get opAllIcon() : Class
      {
         return GWizOpSelector._385561447opAllIcon;
      }
      
      public static function set opAllIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._385561447opAllIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"opAllIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get opHoleIcon() : Class
      {
         return GWizOpSelector._1360116134opHoleIcon;
      }
      
      public static function set opHoleIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._1360116134opHoleIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"opHoleIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get opPocketIcon() : Class
      {
         return GWizOpSelector._367153136opPocketIcon;
      }
      
      public static function set opPocketIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._367153136opPocketIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"opPocketIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get opSurfacingIcon() : Class
      {
         return GWizOpSelector._283481442opSurfacingIcon;
      }
      
      public static function set opSurfacingIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._283481442opSurfacingIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"opSurfacingIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get op2DProfileIcon() : Class
      {
         return GWizOpSelector._705798193op2DProfileIcon;
      }
      
      public static function set op2DProfileIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._705798193op2DProfileIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"op2DProfileIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get op3DProfileIcon() : Class
      {
         return GWizOpSelector._999201200op3DProfileIcon;
      }
      
      public static function set op3DProfileIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._999201200op3DProfileIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"op3DProfileIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get opThreadingIcon() : Class
      {
         return GWizOpSelector._251326928opThreadingIcon;
      }
      
      public static function set opThreadingIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._251326928opThreadingIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"opThreadingIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get opEngraveCarveIcon() : Class
      {
         return GWizOpSelector._2034406657opEngraveCarveIcon;
      }
      
      public static function set opEngraveCarveIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._2034406657opEngraveCarveIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"opEngraveCarveIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get opChamferIcon() : Class
      {
         return GWizOpSelector._763710874opChamferIcon;
      }
      
      public static function set opChamferIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._763710874opChamferIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"opChamferIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get opProbeIcon() : Class
      {
         return GWizOpSelector._1548468376opProbeIcon;
      }
      
      public static function set opProbeIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._1548468376opProbeIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"opProbeIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get opTurningIcon() : Class
      {
         return GWizOpSelector._1716503485opTurningIcon;
      }
      
      public static function set opTurningIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._1716503485opTurningIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"opTurningIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get opBoringIcon() : Class
      {
         return GWizOpSelector._1961342679opBoringIcon;
      }
      
      public static function set opBoringIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._1961342679opBoringIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"opBoringIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get opPartGrooveIcon() : Class
      {
         return GWizOpSelector._2008379353opPartGrooveIcon;
      }
      
      public static function set opPartGrooveIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._2008379353opPartGrooveIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"opPartGrooveIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get opSinglePtThreadIcon() : Class
      {
         return GWizOpSelector._1053360400opSinglePtThreadIcon;
      }
      
      public static function set opSinglePtThreadIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizOpSelector._1053360400opSinglePtThreadIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizOpSelector,"opSinglePtThreadIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
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
         if(!opChoices)
         {
            opChoices = new ArrayCollection([{
               "label":"All",
               "icon":opAllIcon
            },{
               "label":"Hole",
               "icon":opHoleIcon
            },{
               "label":"Pocket",
               "icon":opPocketIcon
            },{
               "label":"Surfacing",
               "icon":opSurfacingIcon
            },{
               "label":"2D Profiling",
               "icon":op2DProfileIcon
            },{
               "label":"Chamfer",
               "icon":opChamferIcon
            },{
               "label":"3D Profiling",
               "icon":op3DProfileIcon
            },{
               "label":"Threading",
               "icon":opThreadingIcon
            },{
               "label":"Engrave/Carve",
               "icon":opEngraveCarveIcon
            },{
               "label":"Probe",
               "icon":opProbeIcon
            },{
               "label":"Turning",
               "icon":opTurningIcon
            },{
               "label":"Boring",
               "icon":opBoringIcon
            },{
               "label":"Part/Groove",
               "icon":opPartGrooveIcon
            },{
               "label":"Threading",
               "icon":opSinglePtThreadIcon
            }]);
         }
         this.img.source = opAllDnArrowIcon;
      }
      
      private function onClick() : void
      {
         GWizOpPopUp.launchOpPopUp(this.opSelected,this.centerParent);
      }
      
      private function opSelected(param1:Object, param2:String = "", param3:Number = NaN, param4:Number = NaN, param5:Number = NaN, param6:int = 0, param7:String = "") : void
      {
         if(param1)
         {
            if(param1.label == "" || param1.label == "All")
            {
               this.img.source = opAllDnArrowIcon;
            }
            else
            {
               this.img.source = param1.icon;
            }
            if(this.opSelectedFcn != null)
            {
               this.opSelectedFcn(param1.label,param2,param3,param4,param5,param6,param7);
            }
         }
      }
      
      public function resetOpSelector() : void
      {
         this.img.source = opAllDnArrowIcon;
         if(this.opSelectedFcn != null)
         {
            this.opSelectedFcn("All");
         }
      }
      
      private function _GWizOpSelector_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.buttonMode = true;
         _loc1_.addEventListener("click",this.__img_click);
         _loc1_.id = "img";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img = _loc1_;
         BindingManager.executeBindings(this,"img",this.img);
         return _loc1_;
      }
      
      public function __img_click(param1:MouseEvent) : void
      {
         this.onClick();
      }
      
      private function _GWizOpSelector_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Filtered";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "FilterLED";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.FilterLED = _loc1_;
         BindingManager.executeBindings(this,"FilterLED",this.FilterLED);
         return _loc1_;
      }
      
      public function ___GWizOpSelector_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizOpSelector_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return 16711680;
         },function(param1:uint):void
         {
            FilterLED.setStyle("color",param1);
         },"FilterLED.color");
         result[1] = new Binding(this,function():Boolean
         {
            return filtered;
         },null,"FilterLED.visible");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get FilterLED() : Label
      {
         return this._1122576211FilterLED;
      }
      
      public function set FilterLED(param1:Label) : void
      {
         var _loc2_:Object = this._1122576211FilterLED;
         if(_loc2_ !== param1)
         {
            this._1122576211FilterLED = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FilterLED",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img() : Image
      {
         return this._104387img;
      }
      
      public function set img(param1:Image) : void
      {
         var _loc2_:Object = this._104387img;
         if(_loc2_ !== param1)
         {
            this._104387img = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get centerParent() : DisplayObject
      {
         return this._152343201centerParent;
      }
      
      public function set centerParent(param1:DisplayObject) : void
      {
         var _loc2_:Object = this._152343201centerParent;
         if(_loc2_ !== param1)
         {
            this._152343201centerParent = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"centerParent",_loc2_,param1));
            }
         }
      }
   }
}
