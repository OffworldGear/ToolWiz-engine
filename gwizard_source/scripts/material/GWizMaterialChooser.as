package material
{
   import comps.GWizPopUpManager;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import login.GWizLoginBar;
   import mx.binding.BindingManager;
   import mx.binding.utils.ChangeWatcher;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.Label;
   import spark.components.VGroup;
   
   public class GWizMaterialChooser extends VGroup
   {
      
      private static const log:ILogger = Log.getLogger("GWizMaterialChooser");
       
      
      private var _181289442Hardness:Label;
      
      private var _363710791Material:Button;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var AdjHardness:Number = -1;
      
      private var _Selection:String = "";
      
      public var Alloy:String = "";
      
      public var MaterialSelectedIndex:int = -1;
      
      public var onChangeFcn:Function = null;
      
      public var labColor:String = "black";
      
      public var selectionColor:String = "";
      
      public var rolloverColor:String = "";
      
      private var widthWatch:ChangeWatcher;
      
      private var heightWatch:ChangeWatcher;
      
      private var resizeExecuting:Boolean = false;
      
      public const METALISH_HARDNESS:Number = 50.0;
      
      public function GWizMaterialChooser()
      {
         super();
         mx_internal::_document = this;
         this.horizontalAlign = "left";
         this.mxmlContent = [this._GWizMaterialChooser_Button1_i(),this._GWizMaterialChooser_Label1_i()];
         this.addEventListener("creationComplete",this.___GWizMaterialChooser_VGroup1_creationComplete);
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
      
      public function get Selection() : String
      {
         return this._Selection;
      }
      
      public function set Selection(param1:String) : void
      {
         this._Selection = param1;
      }
      
      public function doCC() : void
      {
         GWizAbstractPrefs.powerUserCC.addFunction("GWizmaterialChooser",this.powerUserChanged,false);
         this.powerUserChanged();
         if(GWizLoginBar.isGWEstimator())
         {
            this.Hardness.visible = false;
         }
         this.Hardness.setStyle("color",this.labColor);
         if(this.selectionColor != "")
         {
            this.Material.setStyle("selectionColor",this.selectionColor);
         }
         if(this.rolloverColor != "")
         {
            this.Material.setStyle("rollOverColor",this.rolloverColor);
         }
         this.setupMatChooserSync();
         this.widthWatch = ChangeWatcher.watch(this,"width",this.onResize);
         this.heightWatch = ChangeWatcher.watch(this,"height",this.onResize);
         this.handleResize();
      }
      
      public function onResize(param1:Event) : void
      {
         if(!this.resizeExecuting)
         {
            this.callLater(this.handleResize);
         }
         this.resizeExecuting = true;
      }
      
      private function handleResize() : void
      {
         invalidateDisplayList();
         this.resizeExecuting = false;
      }
      
      private function setupMatChooserSync() : void
      {
         GWizSettings.matchMaterialCC.addFunction("GWizMaterialChooser",this.matchMaterial,false);
         GWizSettings.matchMaterialHardnessCC.addFunction("GWizMaterialChooser",this.matchMaterialHardness,false);
         GWizSettings.matchMaterialSelectionCC.addFunction("GWizMaterialChooser",this.matchMaterialSelection,false);
         this.matchMaterial();
         this.matchMaterialHardness();
         this.matchMaterialSelection();
      }
      
      override public function validateProperties() : void
      {
         this.labelUpdate();
         super.validateProperties();
      }
      
      private function onChange() : void
      {
         GWizSettings.materialChoice = this.MaterialSelectedIndex;
         GWizSettings.materialHardness = this.AdjHardness;
         GWizSettings.materialSelection = this.Selection;
         if(this.onChangeFcn != null)
         {
            this.onChangeFcn();
         }
         this.callLater(invalidateProperties);
      }
      
      private function onChangeAux() : void
      {
      }
      
      private function matchMaterial(param1:Object = null) : Boolean
      {
         this.MaterialSelectedIndex = GWizSettings.materialChoice;
         this.callLater(invalidateProperties);
         return true;
      }
      
      private function matchMaterialHardness(param1:Object = null) : Boolean
      {
         this.AdjHardness = GWizSettings.materialHardness;
         this.callLater(invalidateProperties);
         return true;
      }
      
      private function matchMaterialSelection(param1:Object = null) : Boolean
      {
         this.Selection = GWizSettings.materialSelection;
         this.callLater(invalidateProperties);
         return true;
      }
      
      private function doMatBrowse() : void
      {
         var _loc1_:GWizMatBrowser2 = GWizMatBrowser2(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizMatBrowser2,true));
         if(_loc1_)
         {
            _loc1_.setMaterial = this.setMaterial;
            _loc1_.Family.selectedIndex = this.MaterialSelectedIndex;
         }
      }
      
      public function setMaterialToLabel(param1:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(param1 != this.Selection)
         {
            _loc2_ = 0;
            while(_loc2_ < GWizMaterialsDB.MaterialsList.length)
            {
               _loc3_ = GWizMaterialsDB.MaterialsList[_loc2_];
               if(String(_loc3_) == param1)
               {
                  this.MaterialSelectedIndex = _loc2_;
                  this.AdjHardness = -1;
                  GWizSettings.jankaHardness = -1;
                  this.Selection = "";
                  this.callLater(invalidateProperties);
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public function getMaterialLabel() : String
      {
         return this.Selection;
      }
      
      private function setMaterial(param1:int, param2:Number, param3:String) : void
      {
         if(isNaN(param2))
         {
            param2 = 0;
         }
         this.MaterialSelectedIndex = param1;
         this.AdjHardness = param2;
         this.Selection = param3;
         this.callLater(invalidateProperties);
         this.onChange();
      }
      
      private function onDropdown() : void
      {
         GWizSettings.materialHardness = -1;
         GWizSettings.jankaHardness = -1;
         GWizSettings.materialSelection = "";
         this.callLater(invalidateProperties);
         GWizMatBrowser2.addHistory(this.MaterialSelectedIndex,this.currSelHardness(),this.Selection);
         this.onChange();
      }
      
      public function currSelHardness() : Number
      {
         var _loc1_:Number = 300;
         if(GWizSettings.FeedsSpeedsApp && GWizSettings.FeedsSpeedsApp.fsm && GWizSettings.FeedsSpeedsApp.fsm.minBHN > 0)
         {
            _loc1_ = (GWizSettings.FeedsSpeedsApp.fsm.minBHN + GWizSettings.FeedsSpeedsApp.fsm.maxBHN) / 2;
         }
         return _loc1_;
      }
      
      private function powerUserChanged(param1:Object = null) : Boolean
      {
         this.Hardness.visible = GWizSettings.prefs.powerUser || GWizAbstractPrefs.isOEM;
         return true;
      }
      
      public function materialSelected() : Boolean
      {
         return this.Selection || this.Selection.length > 0;
      }
      
      private function labelUpdate() : void
      {
         if(!GWizMaterialsDB.MaterialsListAC || this.MaterialSelectedIndex < 0)
         {
            return;
         }
         if(this.MaterialSelectedIndex >= GWizMaterialsDB.MaterialsListAC.length)
         {
            this.MaterialSelectedIndex = 0;
         }
         var _loc1_:Object = GWizMaterialsDB.MaterialsListAC.getItemAt(this.MaterialSelectedIndex);
         if(_loc1_)
         {
            this.Alloy = this.Selection;
            this.Selection = String(_loc1_);
            this.Material.label = this.Selection;
            if(this.Alloy == this.Selection)
            {
               this.Alloy = "";
            }
         }
         var _loc2_:String = this.Selection;
         if(this.Alloy != "")
         {
            _loc2_ = this.Alloy;
         }
         this.Hardness.text = _loc2_.substr(0,35) + " ";
         if(this.Selection.indexOf("Wood") < 0)
         {
            if(this.AdjHardness > 0.001 && _loc2_ != "")
            {
               this.Hardness.text += ", Hardness: " + String(this.AdjHardness) + " BHN";
            }
            else if(GWizSettings.FeedsSpeedsApp && GWizSettings.FeedsSpeedsApp.fsm && GWizSettings.FeedsSpeedsApp.fsm.minBHN > 0)
            {
               this.Hardness.text += "Hardness: " + String(GWizSettings.FeedsSpeedsApp.fsm.minBHN) + "-" + String(GWizSettings.FeedsSpeedsApp.fsm.maxBHN) + " BHN";
            }
         }
      }
      
      private function _GWizMaterialChooser_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Material";
         _loc1_.percentWidth = 90;
         _loc1_.addEventListener("click",this.__Material_click);
         _loc1_.id = "Material";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Material = _loc1_;
         BindingManager.executeBindings(this,"Material",this.Material);
         return _loc1_;
      }
      
      public function __Material_click(param1:MouseEvent) : void
      {
         this.doMatBrowse();
      }
      
      private function _GWizMaterialChooser_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Material";
         _loc1_.id = "Hardness";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Hardness = _loc1_;
         BindingManager.executeBindings(this,"Hardness",this.Hardness);
         return _loc1_;
      }
      
      public function ___GWizMaterialChooser_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.doCC();
      }
      
      [Bindable(event="propertyChange")]
      public function get Hardness() : Label
      {
         return this._181289442Hardness;
      }
      
      public function set Hardness(param1:Label) : void
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
      public function get Material() : Button
      {
         return this._363710791Material;
      }
      
      public function set Material(param1:Button) : void
      {
         var _loc2_:Object = this._363710791Material;
         if(_loc2_ !== param1)
         {
            this._363710791Material = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Material",_loc2_,param1));
            }
         }
      }
   }
}
