package views
{
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.supportClasses.ItemRenderer;
   
   public class GWizBoltCircleInnerClass0 extends ItemRenderer
   {
       
      
      private var _92960979angle:Label;
      
      private var _88844982outerDocument:GWizBoltCircle;
      
      private var _3659480xTxt:Label;
      
      private var _3689271yTxt:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizBoltCircleInnerClass0()
      {
         super();
         mx_internal::_document = this;
         this.percentWidth = 100;
         this.mxmlContent = [this._GWizBoltCircleInnerClass0_HGroup1_c()];
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
         this.angle.text = (Math.round(param1.angle * 10) / 10).toString();
         this.xTxt.text = param1.x;
         this.yTxt.text = param1.y;
      }
      
      private function _GWizBoltCircleInnerClass0_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizBoltCircleInnerClass0_Label1_i(),this._GWizBoltCircleInnerClass0_Label2_i(),this._GWizBoltCircleInnerClass0_Label3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizBoltCircleInnerClass0_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 30;
         _loc1_.setStyle("paddingRight",5);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "angle";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.angle = _loc1_;
         BindingManager.executeBindings(this,"angle",this.angle);
         return _loc1_;
      }
      
      private function _GWizBoltCircleInnerClass0_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 35;
         _loc1_.setStyle("paddingRight",5);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "xTxt";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xTxt = _loc1_;
         BindingManager.executeBindings(this,"xTxt",this.xTxt);
         return _loc1_;
      }
      
      private function _GWizBoltCircleInnerClass0_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 35;
         _loc1_.setStyle("paddingRight",5);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("textAlign","right");
         _loc1_.id = "yTxt";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.yTxt = _loc1_;
         BindingManager.executeBindings(this,"yTxt",this.yTxt);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get angle() : Label
      {
         return this._92960979angle;
      }
      
      public function set angle(param1:Label) : void
      {
         var _loc2_:Object = this._92960979angle;
         if(_loc2_ !== param1)
         {
            this._92960979angle = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"angle",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizBoltCircle
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizBoltCircle) : void
      {
         var _loc2_:Object = this._88844982outerDocument;
         if(_loc2_ !== param1)
         {
            this._88844982outerDocument = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"outerDocument",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get xTxt() : Label
      {
         return this._3659480xTxt;
      }
      
      public function set xTxt(param1:Label) : void
      {
         var _loc2_:Object = this._3659480xTxt;
         if(_loc2_ !== param1)
         {
            this._3659480xTxt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xTxt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get yTxt() : Label
      {
         return this._3689271yTxt;
      }
      
      public function set yTxt(param1:Label) : void
      {
         var _loc2_:Object = this._3689271yTxt;
         if(_loc2_ !== param1)
         {
            this._3689271yTxt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"yTxt",_loc2_,param1));
            }
         }
      }
   }
}
