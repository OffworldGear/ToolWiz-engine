package threads2
{
   import comps.GWizForePanel;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.TextArea;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizManualLatheThread extends GWizForePanel implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _934914674recipe:TextArea;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var steps:int;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizManualLatheThread()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizManualLatheThread_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_threads2_GWizManualLatheThreadWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizManualLatheThread[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizManualLatheThread_Array1_c);
         this.addEventListener("creationComplete",this.___GWizManualLatheThread_GWizForePanel1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizManualLatheThread._watcherSetupUtil = param1;
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
      
      public function recalc() : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         this.steps = 1;
         this.recipe.text = "";
         this.addStep("Recipe to cut thread: " + GWizAbstractThreadEngine.Designation + "\n");
         var _loc1_:Number = GWizAbstractThreadEngine.ThreadAngle / 2 - 1;
         this.addStep("Set compound to " + _loc1_ + " degrees.\n");
         this.addStep("Put a proper tool in the tool holder for your thread type.\n");
         this.addStep("Make sure the tool is at right angles to the part and the tool\'s center height is properly set.\n");
         this.addStep("Coat the area to be threaded with layout dye.\n");
         this.addStep("Move the threading tool up to the part using both the compound and cross feed.  Set the micrometer on both dials to zero.\n");
         this.addStep("Move the cross feed to back the tool off the work.  Move the carriage to the end of the part.  Reset the cross feed to zero.\n");
         this.addStep("Using only the compound, feed in 0.001 to 0.002 inches. We\'re going to make a shallow scratch cut.\n");
         this.addStep("Set your quick change gearbox for the proper feedrate based on TPI or Pitch.  TPI for this thread is " + GWizAbstractThreadEngine.threadInfo("TPI") + " and Pitch is " + GWizAbstractThreadEngine.threadInfo("Pitch") + ".\n");
         this.addStep("Turn on the lathe, and enage the half nut.\n");
         this.addStep("Take a scratch cut on the part, then disengage the half nut at the end of the cut.  Stop the lathe and back out the tool using the cross feed.  " + "Return the carriage to the starting position.\n");
         this.addStep("Use a screw pitch gage or rule to verifty the thread pitch is correct.  The layout dye makes it easy to see the scratch cut.\n");
         var _loc2_:Number = (GWizAbstractThreadEngine.MinMinorDia + GWizAbstractThreadEngine.MaxMinorDia) / 2;
         this.addStep("You\'re ready to start making passes to cut to a final diameter of " + GWizAbstractThreadEngine.newThreadData("Man. Lathe Final Dia",_loc2_,true,true) + ".\n");
         _loc2_ = GWizAbstractThreadEngine.MeanMajorDia - _loc2_;
         var _loc3_:int = 6;
         this.addStep("We\'ll cut the thread in " + _loc3_ + " passes.  Here are recommended total depths on the compound for each pass:\n");
         var _loc4_:int = 1;
         var _loc5_:Number = 0.3;
         _loc4_ = 1;
         while(_loc4_ <= _loc3_)
         {
            _loc7_ = _loc2_ / Math.sqrt(_loc3_ - 1) * Math.sqrt(_loc5_);
            if(_loc5_ == 0.3)
            {
               _loc5_ = 1;
            }
            else
            {
               _loc5_ = _loc4_ - 1;
            }
            if(Math.abs(_loc7_ - _loc6_) > 0.0005)
            {
               this.addStep("    Compound in feed to " + GWizUtils.roundThousandths(_loc7_,true));
            }
            _loc6_ = _loc7_;
            _loc4_++;
         }
         this.addStep("    Make the final pass to a final depth of " + GWizAbstractThreadEngine.newThreadData("Man. Lathe Final Depth",_loc2_,true,true) + ".\n");
         this.addStep("Use a screw thread micrometer, thread gage, or three wire measurement to check the size.\n");
         this.addStep("Chamfer the end of the thread to protect it from damage.\n");
      }
      
      private function addStep(param1:String) : void
      {
         this.recipe.text += this.steps + ". " + param1 + "\n";
         ++this.steps;
      }
      
      private function _GWizManualLatheThread_Array1_c() : Array
      {
         return [this._GWizManualLatheThread_VGroup1_c()];
      }
      
      private function _GWizManualLatheThread_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizManualLatheThread_TextArea1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizManualLatheThread_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "recipe";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.recipe = _loc1_;
         BindingManager.executeBindings(this,"recipe",this.recipe);
         return _loc1_;
      }
      
      public function ___GWizManualLatheThread_GWizForePanel1_creationComplete(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      private function _GWizManualLatheThread_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Boolean
         {
            return this.enabled;
         },null,"this.visible");
         result[1] = new Binding(this,function():Boolean
         {
            return this.enabled;
         },null,"this.includeInLayout");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get recipe() : TextArea
      {
         return this._934914674recipe;
      }
      
      public function set recipe(param1:TextArea) : void
      {
         var _loc2_:Object = this._934914674recipe;
         if(_loc2_ !== param1)
         {
            this._934914674recipe = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"recipe",_loc2_,param1));
            }
         }
      }
   }
}
