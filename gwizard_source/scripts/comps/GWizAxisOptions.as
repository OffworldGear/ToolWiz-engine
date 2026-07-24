package comps
{
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import machines.GWizMachProfile;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.containers.TabNavigator;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponentDescriptor;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NavigatorContent;
   import spark.components.VGroup;
   
   use namespace mx_internal;
   
   public class GWizAxisOptions extends GWizPopUp implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1932142811fourthAxis:DropDownList;
      
      private var _1785909688parallelAxis:DropDownList;
      
      private var _938221833rapids:GWizNumStep;
      
      private var _1141079789xCenter:GWizNumStep;
      
      private var _2028583470yCenter:GWizNumStep;
      
      private var _1378880145zCenter:GWizNumStep;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _1932142687fourthAxes:Array;
      
      private var _1785909812parallelAxes:Array;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizAxisOptions()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._1932142687fourthAxes = ["A","B","C"];
         this._1785909812parallelAxes = ["X","Y","Z"];
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizAxisOptions_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizAxisOptionsWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizAxisOptions[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.okLabel = "Save";
         this.width = 600;
         this.height = 398;
         this.title = "Axis Options...";
         this.mxmlContent = [this._GWizAxisOptions_TabNavigator1_c()];
         this.addEventListener("creationComplete",this.___GWizAxisOptions_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizAxisOptions._watcherSetupUtil = param1;
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
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < this.fourthAxes.length)
         {
            if(this.fourthAxes[_loc1_] == GWizMachProfile.fourthAxis)
            {
               this.fourthAxis.selectedIndex = _loc1_;
               break;
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this.parallelAxes.length)
         {
            if(this.parallelAxes[_loc1_] == GWizMachProfile.parallelAxis)
            {
               this.parallelAxis.selectedIndex = _loc1_;
               break;
            }
            _loc1_++;
         }
         this.rapids.setVal(GWizMachProfile.rapidsRate);
         this.xCenter.setVal(GWizMachProfile.xCenter);
         this.yCenter.setVal(GWizMachProfile.yCenter);
         this.zCenter.setVal(GWizMachProfile.zCenter);
      }
      
      private function doSave(param1:Boolean) : void
      {
         super.close();
         if(param1)
         {
            GWizMachProfile.fourthAxis = this.fourthAxis.selectedItem;
            GWizMachProfile.parallelAxis = this.parallelAxis.selectedItem;
            GWizMachProfile.rapidsRate = this.rapids.getVal();
            GWizMachProfile.xCenter = this.xCenter.getVal();
            GWizMachProfile.yCenter = this.yCenter.getVal();
            GWizMachProfile.zCenter = this.zCenter.getVal();
         }
      }
      
      override public function onOk(param1:Event) : void
      {
         this.doSave(true);
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.doSave(false);
      }
      
      private function _GWizAxisOptions_TabNavigator1_c() : TabNavigator
      {
         var temp:TabNavigator = new TabNavigator();
         temp.percentWidth = 100;
         temp.percentHeight = 100;
         temp.creationPolicy = "all";
         temp.setStyle("backgroundColor",12303291);
         temp.setStyle("borderColor",11187123);
         temp.setStyle("color",0);
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":TabNavigator,
            "stylesFactory":function():void
            {
               this.backgroundColor = 12303291;
               this.borderColor = 11187123;
               this.color = 0;
            },
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"4th Axis",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizAxisOptions_Array2_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         return temp;
      }
      
      private function _GWizAxisOptions_Array2_c() : Array
      {
         return [this._GWizAxisOptions_VGroup1_c()];
      }
      
      private function _GWizAxisOptions_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.paddingTop = 3;
         _loc1_.paddingBottom = 3;
         _loc1_.paddingLeft = 3;
         _loc1_.paddingRight = 3;
         _loc1_.mxmlContent = [this._GWizAxisOptions_HGroup1_c(),this._GWizAxisOptions_HGroup2_c(),this._GWizAxisOptions_HGroup3_c(),this._GWizAxisOptions_Label6_c(),this._GWizAxisOptions_HGroup4_c(),this._GWizAxisOptions_HGroup5_c(),this._GWizAxisOptions_HGroup6_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizAxisOptions_Label1_c(),this._GWizAxisOptions_Spacer1_c(),this._GWizAxisOptions_DropDownList1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Axis Identifier";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 11;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.id = "fourthAxis";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fourthAxis = _loc1_;
         BindingManager.executeBindings(this,"fourthAxis",this.fourthAxis);
         return _loc1_;
      }
      
      private function _GWizAxisOptions_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizAxisOptions_Label2_c(),this._GWizAxisOptions_Spacer2_c(),this._GWizAxisOptions_DropDownList2_i(),this._GWizAxisOptions_Label3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Parallel to";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 36;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_DropDownList2_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.id = "parallelAxis";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.parallelAxis = _loc1_;
         BindingManager.executeBindings(this,"parallelAxis",this.parallelAxis);
         return _loc1_;
      }
      
      private function _GWizAxisOptions_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "axis";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizAxisOptions_Label4_c(),this._GWizAxisOptions_GWizNumStep1_i(),this._GWizAxisOptions_Label5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Rapids rate";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 10000;
         _loc1_.steps = 1;
         _loc1_.usesMetric = false;
         _loc1_.id = "rapids";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.rapids = _loc1_;
         BindingManager.executeBindings(this,"rapids",this.rapids);
         return _loc1_;
      }
      
      private function _GWizAxisOptions_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "deg/min";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Centerline:";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizAxisOptions_Label7_c(),this._GWizAxisOptions_Spacer3_c(),this._GWizAxisOptions_GWizNumStep2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "    X";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 36;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 10000;
         _loc1_.steps = 0.0001;
         _loc1_.usesMetric = false;
         _loc1_.id = "xCenter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.xCenter = _loc1_;
         BindingManager.executeBindings(this,"xCenter",this.xCenter);
         return _loc1_;
      }
      
      private function _GWizAxisOptions_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizAxisOptions_Label8_c(),this._GWizAxisOptions_Spacer4_c(),this._GWizAxisOptions_GWizNumStep3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "    Y";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_Spacer4_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 36;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 10000;
         _loc1_.steps = 0.0001;
         _loc1_.usesMetric = false;
         _loc1_.id = "yCenter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.yCenter = _loc1_;
         BindingManager.executeBindings(this,"yCenter",this.yCenter);
         return _loc1_;
      }
      
      private function _GWizAxisOptions_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizAxisOptions_Label9_c(),this._GWizAxisOptions_Spacer5_c(),this._GWizAxisOptions_GWizNumStep4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_Label9_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "    Z";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_Spacer5_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 36;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizAxisOptions_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 10000;
         _loc1_.steps = 0.0001;
         _loc1_.usesMetric = false;
         _loc1_.id = "zCenter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.zCenter = _loc1_;
         BindingManager.executeBindings(this,"zCenter",this.zCenter);
         return _loc1_;
      }
      
      public function ___GWizAxisOptions_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizAxisOptions_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return new ArrayCollection(fourthAxes);
         },null,"fourthAxis.dataProvider");
         result[1] = new Binding(this,function():IList
         {
            return new ArrayCollection(parallelAxes);
         },null,"parallelAxis.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get fourthAxis() : DropDownList
      {
         return this._1932142811fourthAxis;
      }
      
      public function set fourthAxis(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1932142811fourthAxis;
         if(_loc2_ !== param1)
         {
            this._1932142811fourthAxis = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fourthAxis",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get parallelAxis() : DropDownList
      {
         return this._1785909688parallelAxis;
      }
      
      public function set parallelAxis(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1785909688parallelAxis;
         if(_loc2_ !== param1)
         {
            this._1785909688parallelAxis = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"parallelAxis",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get rapids() : GWizNumStep
      {
         return this._938221833rapids;
      }
      
      public function set rapids(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._938221833rapids;
         if(_loc2_ !== param1)
         {
            this._938221833rapids = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"rapids",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get xCenter() : GWizNumStep
      {
         return this._1141079789xCenter;
      }
      
      public function set xCenter(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1141079789xCenter;
         if(_loc2_ !== param1)
         {
            this._1141079789xCenter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"xCenter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get yCenter() : GWizNumStep
      {
         return this._2028583470yCenter;
      }
      
      public function set yCenter(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._2028583470yCenter;
         if(_loc2_ !== param1)
         {
            this._2028583470yCenter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"yCenter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get zCenter() : GWizNumStep
      {
         return this._1378880145zCenter;
      }
      
      public function set zCenter(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1378880145zCenter;
         if(_loc2_ !== param1)
         {
            this._1378880145zCenter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"zCenter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get fourthAxes() : Array
      {
         return this._1932142687fourthAxes;
      }
      
      private function set fourthAxes(param1:Array) : void
      {
         var _loc2_:Object = this._1932142687fourthAxes;
         if(_loc2_ !== param1)
         {
            this._1932142687fourthAxes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fourthAxes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get parallelAxes() : Array
      {
         return this._1785909812parallelAxes;
      }
      
      private function set parallelAxes(param1:Array) : void
      {
         var _loc2_:Object = this._1785909812parallelAxes;
         if(_loc2_ !== param1)
         {
            this._1785909812parallelAxes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"parallelAxes",_loc2_,param1));
            }
         }
      }
   }
}
