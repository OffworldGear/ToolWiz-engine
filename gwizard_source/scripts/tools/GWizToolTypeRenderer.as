package tools
{
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.gridClasses.GridItemRenderer;
   import spark.layouts.VerticalLayout;
   
   public class GWizToolTypeRenderer extends GridItemRenderer
   {
      
      private static const log:ILogger = Log.getLogger("GWizToolTypeRenderer");
      
      private static var _1590897163BallnoseIcon:Class = GWizToolTypeRenderer_BallnoseIcon;
      
      private static var _86847946BoringIcon:Class = GWizToolTypeRenderer_BoringIcon;
      
      private static var _904511103CenterDrillIcon:Class = GWizToolTypeRenderer_CenterDrillIcon;
      
      private static var _1694310939ChamferIcon:Class = GWizToolTypeRenderer_ChamferIcon;
      
      private static var _162258894CornerRoundIcon:Class = GWizToolTypeRenderer_CornerRoundIcon;
      
      private static var _1984324733DovetailIcon:Class = GWizToolTypeRenderer_DovetailIcon;
      
      private static var _1348694928EndmillIcon:Class = GWizToolTypeRenderer_EndmillIcon;
      
      private static var _676324402FacemillIcon:Class = GWizToolTypeRenderer_FacemillIcon;
      
      private static var _1082750008IndexableDrillIcon:Class = GWizToolTypeRenderer_IndexableDrillIcon;
      
      private static var _141729468LollipopIcon:Class = GWizToolTypeRenderer_LollipopIcon;
      
      private static var _1403117893ReamerIcon:Class = GWizToolTypeRenderer_ReamerIcon;
      
      private static var _1547946143RougherIcon:Class = GWizToolTypeRenderer_RougherIcon;
      
      private static var _505157615SpadeDrillIcon:Class = GWizToolTypeRenderer_SpadeDrillIcon;
      
      private static var _132512882SpotDrillIcon:Class = GWizToolTypeRenderer_SpotDrillIcon;
      
      private static var _793001358TappingIcon:Class = GWizToolTypeRenderer_TappingIcon;
      
      private static var _1466891007ThreadMillIcon:Class = GWizToolTypeRenderer_ThreadMillIcon;
      
      private static var _858762195TwistDrillIcon:Class = GWizToolTypeRenderer_TwistDrillIcon;
      
      private static var _644451113WoodruffIcon:Class = GWizToolTypeRenderer_WoodruffIcon;
      
      private static var _1118996976VBitIcon:Class = GWizToolTypeRenderer_VBitIcon;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _109401869tIcon:Image;
      
      private var _109548831tName:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizToolTypeRenderer()
      {
         super();
         mx_internal::_document = this;
         this.clipAndEnableScrolling = true;
         this.layout = this._GWizToolTypeRenderer_VerticalLayout1_c();
         this.mxmlContent = [this._GWizToolTypeRenderer_Image1_i(),this._GWizToolTypeRenderer_Label1_i()];
      }
      
      public static function toolTypeIcon(param1:String, param2:String) : Object
      {
         var _loc3_:Object = EndmillIcon;
         if(param1.toLowerCase().indexOf("ballnose") >= 0)
         {
            _loc3_ = BallnoseIcon;
         }
         else if(param1.toLowerCase().indexOf("center drill") >= 0)
         {
            _loc3_ = CenterDrillIcon;
         }
         else if(param1.toLowerCase().indexOf("indexable end") >= 0)
         {
            _loc3_ = FacemillIcon;
         }
         else if(param1.toLowerCase().indexOf("indexable drill") >= 0)
         {
            _loc3_ = IndexableDrillIcon;
         }
         else if(param1.toLowerCase().indexOf("reamer") >= 0)
         {
            _loc3_ = ReamerIcon;
         }
         else if(param1.toLowerCase().indexOf("spade drill") >= 0 || param1.toLowerCase().indexOf("gun drill") >= 0)
         {
            _loc3_ = SpadeDrillIcon;
         }
         else if(param1.toLowerCase().indexOf("spot drill") >= 0)
         {
            _loc3_ = SpotDrillIcon;
         }
         else if(param1.toLowerCase().indexOf("tapping") >= 0)
         {
            _loc3_ = TappingIcon;
         }
         else if(param1.toLowerCase().indexOf("thread mill") >= 0)
         {
            _loc3_ = TappingIcon;
         }
         else if(param1.toLowerCase().indexOf("twist drill") >= 0)
         {
            _loc3_ = TwistDrillIcon;
         }
         else if(param1.toLowerCase().indexOf("boring") >= 0)
         {
            _loc3_ = BoringIcon;
         }
         else if(param1.toLowerCase().indexOf("woodruff") >= 0)
         {
            _loc3_ = WoodruffIcon;
         }
         else if(GWizToolData.isNonCuttingTool(param1) || GWizToolData.isTurningTool(param1) || !param2)
         {
            _loc3_ = null;
         }
         else
         {
            _loc3_ = EndmillIcon;
            if(param2.toLowerCase().indexOf("ballnose") >= 0)
            {
               _loc3_ = BallnoseIcon;
            }
            else if(param2.toLowerCase().indexOf("chamfer") >= 0)
            {
               _loc3_ = ChamferIcon;
            }
            else if(param2.toLowerCase().indexOf("corner round") >= 0)
            {
               _loc3_ = CornerRoundIcon;
            }
            else if(param2.toLowerCase().indexOf("dovetail") >= 0)
            {
               _loc3_ = DovetailIcon;
            }
            else if(param2.toLowerCase().indexOf("lollipop") >= 0)
            {
               _loc3_ = LollipopIcon;
            }
            else if(param2.toLowerCase().indexOf("rougher") >= 0)
            {
               _loc3_ = RougherIcon;
            }
            else if(param2.toLowerCase().indexOf("v-bit") >= 0)
            {
               _loc3_ = VBitIcon;
            }
         }
         return _loc3_;
      }
      
      [Bindable(event="propertyChange")]
      public static function get BallnoseIcon() : Class
      {
         return GWizToolTypeRenderer._1590897163BallnoseIcon;
      }
      
      public static function set BallnoseIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._1590897163BallnoseIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"BallnoseIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get BoringIcon() : Class
      {
         return GWizToolTypeRenderer._86847946BoringIcon;
      }
      
      public static function set BoringIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._86847946BoringIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"BoringIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get CenterDrillIcon() : Class
      {
         return GWizToolTypeRenderer._904511103CenterDrillIcon;
      }
      
      public static function set CenterDrillIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._904511103CenterDrillIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"CenterDrillIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get ChamferIcon() : Class
      {
         return GWizToolTypeRenderer._1694310939ChamferIcon;
      }
      
      public static function set ChamferIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._1694310939ChamferIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"ChamferIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get CornerRoundIcon() : Class
      {
         return GWizToolTypeRenderer._162258894CornerRoundIcon;
      }
      
      public static function set CornerRoundIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._162258894CornerRoundIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"CornerRoundIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get DovetailIcon() : Class
      {
         return GWizToolTypeRenderer._1984324733DovetailIcon;
      }
      
      public static function set DovetailIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._1984324733DovetailIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"DovetailIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get EndmillIcon() : Class
      {
         return GWizToolTypeRenderer._1348694928EndmillIcon;
      }
      
      public static function set EndmillIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._1348694928EndmillIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"EndmillIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get FacemillIcon() : Class
      {
         return GWizToolTypeRenderer._676324402FacemillIcon;
      }
      
      public static function set FacemillIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._676324402FacemillIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"FacemillIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get IndexableDrillIcon() : Class
      {
         return GWizToolTypeRenderer._1082750008IndexableDrillIcon;
      }
      
      public static function set IndexableDrillIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._1082750008IndexableDrillIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"IndexableDrillIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get LollipopIcon() : Class
      {
         return GWizToolTypeRenderer._141729468LollipopIcon;
      }
      
      public static function set LollipopIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._141729468LollipopIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"LollipopIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get ReamerIcon() : Class
      {
         return GWizToolTypeRenderer._1403117893ReamerIcon;
      }
      
      public static function set ReamerIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._1403117893ReamerIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"ReamerIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get RougherIcon() : Class
      {
         return GWizToolTypeRenderer._1547946143RougherIcon;
      }
      
      public static function set RougherIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._1547946143RougherIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"RougherIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get SpadeDrillIcon() : Class
      {
         return GWizToolTypeRenderer._505157615SpadeDrillIcon;
      }
      
      public static function set SpadeDrillIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._505157615SpadeDrillIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"SpadeDrillIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get SpotDrillIcon() : Class
      {
         return GWizToolTypeRenderer._132512882SpotDrillIcon;
      }
      
      public static function set SpotDrillIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._132512882SpotDrillIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"SpotDrillIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get TappingIcon() : Class
      {
         return GWizToolTypeRenderer._793001358TappingIcon;
      }
      
      public static function set TappingIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._793001358TappingIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"TappingIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get ThreadMillIcon() : Class
      {
         return GWizToolTypeRenderer._1466891007ThreadMillIcon;
      }
      
      public static function set ThreadMillIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._1466891007ThreadMillIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"ThreadMillIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get TwistDrillIcon() : Class
      {
         return GWizToolTypeRenderer._858762195TwistDrillIcon;
      }
      
      public static function set TwistDrillIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._858762195TwistDrillIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"TwistDrillIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get WoodruffIcon() : Class
      {
         return GWizToolTypeRenderer._644451113WoodruffIcon;
      }
      
      public static function set WoodruffIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._644451113WoodruffIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"WoodruffIcon",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get VBitIcon() : Class
      {
         return GWizToolTypeRenderer._1118996976VBitIcon;
      }
      
      public static function set VBitIcon(param1:Class) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizToolTypeRenderer._1118996976VBitIcon;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizToolTypeRenderer,"VBitIcon",_loc2_,param1));
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
      
      override public function set data(param1:Object) : void
      {
         var _loc2_:String = null;
         if(param1)
         {
            _loc2_ = String(param1.tool);
            this.tName.text = GWizToolMenu.toHybridLabel(_loc2_,param1.geometry);
            this.tIcon.source = toolTypeIcon(_loc2_,param1.geometry);
         }
      }
      
      private function _GWizToolTypeRenderer_VerticalLayout1_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "center";
         _loc1_.paddingLeft = 3;
         _loc1_.paddingRight = 3;
         _loc1_.paddingTop = 5;
         _loc1_.paddingBottom = 5;
         return _loc1_;
      }
      
      private function _GWizToolTypeRenderer_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.id = "tIcon";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tIcon = _loc1_;
         BindingManager.executeBindings(this,"tIcon",this.tIcon);
         return _loc1_;
      }
      
      private function _GWizToolTypeRenderer_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("paddingTop",2);
         _loc1_.setStyle("paddingBottom",1);
         _loc1_.id = "tName";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tName = _loc1_;
         BindingManager.executeBindings(this,"tName",this.tName);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get tIcon() : Image
      {
         return this._109401869tIcon;
      }
      
      public function set tIcon(param1:Image) : void
      {
         var _loc2_:Object = this._109401869tIcon;
         if(_loc2_ !== param1)
         {
            this._109401869tIcon = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tIcon",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tName() : Label
      {
         return this._109548831tName;
      }
      
      public function set tName(param1:Label) : void
      {
         var _loc2_:Object = this._109548831tName;
         if(_loc2_ !== param1)
         {
            this._109548831tName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tName",_loc2_,param1));
            }
         }
      }
   }
}
