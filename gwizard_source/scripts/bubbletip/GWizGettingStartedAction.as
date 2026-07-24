package bubbletip
{
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.controls.HRule;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.Button;
   import spark.components.CheckBox;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.VGroup;
   import utils.ColorPalette;
   import utils.GATracker;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizGettingStartedAction extends VGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      public var _GWizGettingStartedAction_Label1:Label;
      
      public var _GWizGettingStartedAction_Label2:Label;
      
      private var _1649900115numberBtn:Button;
      
      private var _892481550status:CheckBox;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _892367443stepNo:int = 1;
      
      private var _1428336503stepName:String = "Setup Your Machine Profile";
      
      private var _1893581265stepTip:String = "";
      
      private var _1428052078stepDone:Boolean = false;
      
      private var _1428395899stepPage:String = "http://www.cnccookbook.com/Slides/GWFirstLogin/GWFirstLoginSetupHome.html";
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizGettingStartedAction()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizGettingStartedAction_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_bubbletip_GWizGettingStartedActionWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizGettingStartedAction[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.verticalAlign = "middle";
         this.mxmlContent = [this._GWizGettingStartedAction_HGroup1_c(),this._GWizGettingStartedAction_HRule1_c()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizGettingStartedAction._watcherSetupUtil = param1;
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
      
      private function stepDoneChanged() : void
      {
         if(this.status.selected)
         {
            this.numberBtn.setStyle("chromeColor",ColorPalette.gray4);
         }
         else
         {
            this.numberBtn.setStyle("chromeColor",ColorPalette.secondarya4);
         }
      }
      
      private function doStep() : void
      {
         GWizUtils.doWebPage(this.stepPage);
         this.stepDone = true;
         GATracker.logPageView("GettingStarted/" + this.stepName,"GettingStarted/" + this.stepName);
      }
      
      private function _GWizGettingStartedAction_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizGettingStartedAction_Button1_i(),this._GWizGettingStartedAction_Label1_i(),this._GWizGettingStartedAction_Spacer1_c(),this._GWizGettingStartedAction_Label2_i(),this._GWizGettingStartedAction_CheckBox1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStartedAction_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.addEventListener("click",this.__numberBtn_click);
         _loc1_.id = "numberBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.numberBtn = _loc1_;
         BindingManager.executeBindings(this,"numberBtn",this.numberBtn);
         return _loc1_;
      }
      
      public function __numberBtn_click(param1:MouseEvent) : void
      {
         this.doStep();
      }
      
      private function _GWizGettingStartedAction_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "_GWizGettingStartedAction_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGettingStartedAction_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGettingStartedAction_Label1",this._GWizGettingStartedAction_Label1);
         return _loc1_;
      }
      
      private function _GWizGettingStartedAction_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStartedAction_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Done!";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "_GWizGettingStartedAction_Label2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizGettingStartedAction_Label2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizGettingStartedAction_Label2",this._GWizGettingStartedAction_Label2);
         return _loc1_;
      }
      
      private function _GWizGettingStartedAction_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.addEventListener("valueCommit",this.__status_valueCommit);
         _loc1_.id = "status";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.status = _loc1_;
         BindingManager.executeBindings(this,"status",this.status);
         return _loc1_;
      }
      
      public function __status_valueCommit(param1:FlexEvent) : void
      {
         this.stepDone = this.status.selected;
         this.stepDoneChanged();
      }
      
      private function _GWizGettingStartedAction_HRule1_c() : HRule
      {
         var _loc1_:HRule = new HRule();
         _loc1_.alpha = 0.7;
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizGettingStartedAction_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,null,null,"this.toolTip","stepTip");
         result[1] = new Binding(this,function():String
         {
            var _loc1_:* = String(stepNo);
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"numberBtn.label");
         result[2] = new Binding(this,function():Number
         {
            return numberBtn.height / 2;
         },function(param1:Number):void
         {
            numberBtn.setStyle("cornerRadius",param1);
         },"numberBtn.cornerRadius");
         result[3] = new Binding(this,function():uint
         {
            return ColorPalette.secondarya4;
         },function(param1:uint):void
         {
            numberBtn.setStyle("chromeColor",param1);
         },"numberBtn.chromeColor");
         result[4] = new Binding(this,null,null,"_GWizGettingStartedAction_Label1.text","stepName");
         result[5] = new Binding(this,function():Boolean
         {
            return status.selected;
         },null,"_GWizGettingStartedAction_Label2.visible");
         result[6] = new Binding(this,null,null,"status.selected","stepDone");
         result[7] = new Binding(this,null,null,"status.visible","stepDone");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get numberBtn() : Button
      {
         return this._1649900115numberBtn;
      }
      
      public function set numberBtn(param1:Button) : void
      {
         var _loc2_:Object = this._1649900115numberBtn;
         if(_loc2_ !== param1)
         {
            this._1649900115numberBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"numberBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get status() : CheckBox
      {
         return this._892481550status;
      }
      
      public function set status(param1:CheckBox) : void
      {
         var _loc2_:Object = this._892481550status;
         if(_loc2_ !== param1)
         {
            this._892481550status = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"status",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stepNo() : int
      {
         return this._892367443stepNo;
      }
      
      public function set stepNo(param1:int) : void
      {
         var _loc2_:Object = this._892367443stepNo;
         if(_loc2_ !== param1)
         {
            this._892367443stepNo = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stepNo",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stepName() : String
      {
         return this._1428336503stepName;
      }
      
      public function set stepName(param1:String) : void
      {
         var _loc2_:Object = this._1428336503stepName;
         if(_loc2_ !== param1)
         {
            this._1428336503stepName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stepName",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stepTip() : String
      {
         return this._1893581265stepTip;
      }
      
      public function set stepTip(param1:String) : void
      {
         var _loc2_:Object = this._1893581265stepTip;
         if(_loc2_ !== param1)
         {
            this._1893581265stepTip = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stepTip",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stepDone() : Boolean
      {
         return this._1428052078stepDone;
      }
      
      public function set stepDone(param1:Boolean) : void
      {
         var _loc2_:Object = this._1428052078stepDone;
         if(_loc2_ !== param1)
         {
            this._1428052078stepDone = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stepDone",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stepPage() : String
      {
         return this._1428395899stepPage;
      }
      
      public function set stepPage(param1:String) : void
      {
         var _loc2_:Object = this._1428395899stepPage;
         if(_loc2_ !== param1)
         {
            this._1428395899stepPage = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stepPage",_loc2_,param1));
            }
         }
      }
   }
}
