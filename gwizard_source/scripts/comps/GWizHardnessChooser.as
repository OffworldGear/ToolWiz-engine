package comps
{
   import flash.utils.getDefinitionByName;
   import material.GWizMaterialsDB;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.IList;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   
   use namespace mx_internal;
   
   public class GWizHardnessChooser extends HGroup implements IBindingClient
   {
      
      public static var lookupRow:int = -1;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _181289442Hardness:GWizNumStep;
      
      private var _81880911Units:DropDownList;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var changeFcn:Function;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizHardnessChooser()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizHardnessChooser_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizHardnessChooserWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizHardnessChooser[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.verticalAlign = "middle";
         this.mxmlContent = [this._GWizHardnessChooser_GWizNumStep1_i(),this._GWizHardnessChooser_DropDownList1_i()];
         this.addEventListener("creationComplete",this.___GWizHardnessChooser_HGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      private static function fieldName(param1:String) : String
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < GWizMaterialsDB.HardnessUnits.length)
         {
            _loc3_ = GWizMaterialsDB.HardnessUnits.getItemAt(_loc2_);
            if(_loc3_.name == param1)
            {
               return _loc3_.field;
            }
            _loc2_++;
         }
         return "";
      }
      
      public static function convertHardness(param1:Number, param2:String, param3:String) : Number
      {
         var _loc4_:int = 0;
         var _loc9_:Number = NaN;
         var _loc10_:Object = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:String = fieldName(param2);
         var _loc7_:String = fieldName(param3);
         var _loc8_:Boolean = false;
         if(_loc6_ != "" && _loc7_ != "")
         {
            if(_loc6_ == _loc7_)
            {
               _loc5_ = param1;
            }
            else
            {
               _loc4_ = 0;
               while(_loc4_ < GWizMaterialsDB.HardnessConv.length)
               {
                  _loc9_ = (_loc10_ = GWizMaterialsDB.HardnessConv.getItemAt(_loc4_))[_loc6_];
                  if(!isNaN(_loc9_) && _loc9_ != 0 && _loc9_ <= param1)
                  {
                     _loc8_ = true;
                     break;
                  }
                  _loc4_++;
               }
               if(_loc8_)
               {
                  if(_loc9_ == param1)
                  {
                     _loc5_ = _loc10_[_loc7_];
                  }
                  else
                  {
                     _loc11_ = _loc9_;
                     _loc12_ = _loc10_[_loc7_];
                     if(_loc4_ > 0)
                     {
                        _loc13_ = (_loc10_ = GWizMaterialsDB.HardnessConv.getItemAt(_loc4_ - 1))[_loc6_];
                        _loc14_ = _loc10_[_loc7_];
                        if(_loc13_ > 0 && _loc14_ > 0)
                        {
                           _loc15_ = (param1 - _loc11_) / (_loc13_ - _loc11_);
                           _loc5_ = _loc12_ + _loc15_ * (_loc14_ - _loc12_);
                        }
                        else
                        {
                           _loc8_ = false;
                        }
                     }
                     else
                     {
                        _loc8_ = false;
                     }
                  }
                  if(_loc8_)
                  {
                     lookupRow = _loc4_;
                  }
               }
            }
         }
         return _loc5_;
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizHardnessChooser._watcherSetupUtil = param1;
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
         this.Units.selectedIndex = GWizMaterialsDB.BRINELL_TUNG;
      }
      
      private function recalc() : void
      {
         if(this.changeFcn != null)
         {
            this.changeFcn();
         }
      }
      
      private function _GWizHardnessChooser_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 1000;
         _loc1_.steps = 0.1;
         _loc1_.addEventListener("valueCommit",this.__Hardness_valueCommit);
         _loc1_.id = "Hardness";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Hardness = _loc1_;
         BindingManager.executeBindings(this,"Hardness",this.Hardness);
         return _loc1_;
      }
      
      public function __Hardness_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizHardnessChooser_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "name";
         _loc1_.addEventListener("valueCommit",this.__Units_valueCommit);
         _loc1_.id = "Units";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Units = _loc1_;
         BindingManager.executeBindings(this,"Units",this.Units);
         return _loc1_;
      }
      
      public function __Units_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      public function ___GWizHardnessChooser_HGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizHardnessChooser_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return GWizMaterialsDB.HardnessUnits;
         },null,"Units.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Hardness() : GWizNumStep
      {
         return this._181289442Hardness;
      }
      
      public function set Hardness(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._181289442Hardness;
         if(_loc2_ !== param1)
         {
            this._181289442Hardness = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Hardness",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Units() : DropDownList
      {
         return this._81880911Units;
      }
      
      public function set Units(param1:DropDownList) : void
      {
         var _loc2_:Object = this._81880911Units;
         if(_loc2_ !== param1)
         {
            this._81880911Units = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Units",_loc2_,param1));
            }
         }
      }
   }
}
