package tools
{
   import comps.GWizNumStep;
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import material.GWizMaterialChooser;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import skins.GWizStylePalette;
   import spark.components.HGroup;
   import spark.components.Image;
   import spark.components.Label;
   import spark.components.VGroup;
   
   use namespace mx_internal;
   
   public class GWizOpPopUp extends GWizPopUp implements IBindingClient
   {
      
      public static var selectedItem:Object = null;
      
      private static var selectedImage:Image = null;
      
      private static var selectFcn:Function;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _946303064CutLength:GWizNumStep;
      
      private var _168560467Diameter:GWizNumStep;
      
      private var _2107381107Flutes:GWizNumStep;
      
      private var _1910664338Geometry:GWizGeometryCombo;
      
      private var _1243041755MatChooser:GWizMaterialChooser;
      
      private var _1596369118Stickout:GWizNumStep;
      
      private var _881395123filterGrp:VGroup;
      
      private var _100317443img00:Image;
      
      private var _100317444img01:Image;
      
      private var _100317445img02:Image;
      
      private var _100317446img03:Image;
      
      private var _100317474img10:Image;
      
      private var _100317475img11:Image;
      
      private var _100317476img12:Image;
      
      private var _100317477img13:Image;
      
      private var _100317505img20:Image;
      
      private var _100317506img21:Image;
      
      private var _100317507img22:Image;
      
      private var _100317508img23:Image;
      
      private var _100317536img30:Image;
      
      private var _100317537img31:Image;
      
      private var _100317538img32:Image;
      
      private var _100317539img33:Image;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizOpPopUp()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizOpPopUp_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_tools_GWizOpPopUpWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizOpPopUp[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.width = 800;
         this.height = 600;
         this.title = "Choose Tool Crib Filters...";
         this.mxmlContent = [this._GWizOpPopUp_HGroup1_c()];
         this.addEventListener("creationComplete",this.___GWizOpPopUp_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function launchOpPopUp(param1:Function, param2:DisplayObject) : void
      {
         selectFcn = param1;
         var _loc3_:GWizOpPopUp = GWizOpPopUp(GWizPopUpManager.createPopUp(null,GWizOpPopUp,true));
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizOpPopUp._watcherSetupUtil = param1;
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
         var _loc2_:int = 0;
         var _loc3_:Image = null;
         var _loc4_:int = 0;
         var _loc1_:int = 0;
         while(_loc1_ <= 3)
         {
            _loc2_ = 0;
            while(_loc2_ <= 3)
            {
               _loc3_ = this.getImage(_loc1_,_loc2_);
               if((_loc4_ = _loc1_ * 4 + _loc2_) < GWizOpSelector.opChoices.length)
               {
                  _loc3_.source = GWizOpSelector.opChoices.getItemAt(_loc4_).icon;
               }
               _loc2_++;
            }
            _loc1_++;
         }
         selectedItem = GWizOpSelector.opChoices.getItemAt(0);
         this.centerPopUp();
      }
      
      private function getImage(param1:int, param2:int) : Image
      {
         var _loc3_:Image = this.img00;
         if(param1 == 0)
         {
            if(param2 == 0)
            {
               _loc3_ = this.img00;
            }
            else if(param2 == 1)
            {
               _loc3_ = this.img01;
            }
            else if(param2 == 2)
            {
               _loc3_ = this.img02;
            }
            else
            {
               _loc3_ = this.img03;
            }
         }
         else if(param1 == 1)
         {
            if(param2 == 0)
            {
               _loc3_ = this.img10;
            }
            else if(param2 == 1)
            {
               _loc3_ = this.img11;
            }
            else if(param2 == 2)
            {
               _loc3_ = this.img12;
            }
            else
            {
               _loc3_ = this.img13;
            }
         }
         else if(param1 == 2)
         {
            if(param2 == 0)
            {
               _loc3_ = this.img20;
            }
            else if(param2 == 1)
            {
               _loc3_ = this.img21;
            }
            else if(param2 == 2)
            {
               _loc3_ = this.img22;
            }
            else
            {
               _loc3_ = this.img23;
            }
         }
         else if(param2 == 0)
         {
            _loc3_ = this.img30;
         }
         else if(param2 == 1)
         {
            _loc3_ = this.img31;
         }
         else if(param2 == 2)
         {
            _loc3_ = this.img32;
         }
         else
         {
            _loc3_ = this.img33;
         }
         return _loc3_;
      }
      
      override public function onOk(param1:Event) : void
      {
         var _loc2_:Boolean = false;
         _loc2_ = _loc2_ || selectedItem.label != "All";
         _loc2_ = _loc2_ || this.Diameter.getVal() > 0;
         _loc2_ = _loc2_ || this.CutLength.getVal() > 0;
         _loc2_ = _loc2_ || this.Stickout.getVal() > 0;
         _loc2_ = _loc2_ || this.Flutes.getVal() > 0;
         _loc2_ = _loc2_ || this.Geometry.selectedIndex >= 0;
         GWizOpSelector.filtered = _loc2_;
         if(selectFcn != null)
         {
            selectFcn(selectedItem,this.MatChooser.Selection,this.Diameter.getVal(),this.CutLength.getVal(),this.Stickout.getVal(),this.Flutes.getVal(),this.Geometry.selectedItem);
         }
         this.close();
      }
      
      private function onClick(param1:int, param2:int) : void
      {
         if(selectedImage)
         {
            this.deselectImage(selectedImage);
         }
         var _loc3_:int = param1 * 4 + param2;
         selectedImage = this.getImage(param1,param2);
         selectedItem = GWizOpSelector.opChoices.getItemAt(_loc3_);
         if(selectedImage)
         {
            this.selectImage(selectedImage);
         }
      }
      
      private function selectImage(param1:Image) : void
      {
         if(param1)
         {
            param1.alpha = 0.8;
         }
      }
      
      private function deselectImage(param1:Image) : void
      {
         if(param1)
         {
            param1.alpha = 1;
         }
      }
      
      private function rollover(param1:MouseEvent) : void
      {
         this.selectImage(Image(param1.target));
      }
      
      private function rollout(param1:MouseEvent) : void
      {
         this.deselectImage(Image(param1.target));
         this.selectImage(selectedImage);
      }
      
      private function _GWizOpPopUp_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizOpPopUp_VGroup1_c(),this._GWizOpPopUp_VGroup2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizOpPopUp_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.mxmlContent = [this._GWizOpPopUp_HGroup2_c(),this._GWizOpPopUp_HGroup3_c(),this._GWizOpPopUp_HGroup4_c(),this._GWizOpPopUp_HGroup5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizOpPopUp_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizOpPopUp_Image1_i(),this._GWizOpPopUp_Image2_i(),this._GWizOpPopUp_Image3_i(),this._GWizOpPopUp_Image4_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizOpPopUp_Image1_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img00_click);
         _loc1_.addEventListener("rollOver",this.__img00_rollOver);
         _loc1_.addEventListener("rollOut",this.__img00_rollOut);
         _loc1_.id = "img00";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img00 = _loc1_;
         BindingManager.executeBindings(this,"img00",this.img00);
         return _loc1_;
      }
      
      public function __img00_click(param1:MouseEvent) : void
      {
         this.onClick(0,0);
      }
      
      public function __img00_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img00_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_Image2_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img01_click);
         _loc1_.addEventListener("rollOver",this.__img01_rollOver);
         _loc1_.addEventListener("rollOut",this.__img01_rollOut);
         _loc1_.id = "img01";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img01 = _loc1_;
         BindingManager.executeBindings(this,"img01",this.img01);
         return _loc1_;
      }
      
      public function __img01_click(param1:MouseEvent) : void
      {
         this.onClick(0,1);
      }
      
      public function __img01_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img01_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_Image3_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img02_click);
         _loc1_.addEventListener("rollOver",this.__img02_rollOver);
         _loc1_.addEventListener("rollOut",this.__img02_rollOut);
         _loc1_.id = "img02";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img02 = _loc1_;
         BindingManager.executeBindings(this,"img02",this.img02);
         return _loc1_;
      }
      
      public function __img02_click(param1:MouseEvent) : void
      {
         this.onClick(0,2);
      }
      
      public function __img02_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img02_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_Image4_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img03_click);
         _loc1_.addEventListener("rollOver",this.__img03_rollOver);
         _loc1_.addEventListener("rollOut",this.__img03_rollOut);
         _loc1_.id = "img03";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img03 = _loc1_;
         BindingManager.executeBindings(this,"img03",this.img03);
         return _loc1_;
      }
      
      public function __img03_click(param1:MouseEvent) : void
      {
         this.onClick(0,3);
      }
      
      public function __img03_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img03_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizOpPopUp_Image5_i(),this._GWizOpPopUp_Image6_i(),this._GWizOpPopUp_Image7_i(),this._GWizOpPopUp_Image8_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizOpPopUp_Image5_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img10_click);
         _loc1_.addEventListener("rollOver",this.__img10_rollOver);
         _loc1_.addEventListener("rollOut",this.__img10_rollOut);
         _loc1_.id = "img10";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img10 = _loc1_;
         BindingManager.executeBindings(this,"img10",this.img10);
         return _loc1_;
      }
      
      public function __img10_click(param1:MouseEvent) : void
      {
         this.onClick(1,0);
      }
      
      public function __img10_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img10_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_Image6_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img11_click);
         _loc1_.addEventListener("rollOver",this.__img11_rollOver);
         _loc1_.addEventListener("rollOut",this.__img11_rollOut);
         _loc1_.id = "img11";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img11 = _loc1_;
         BindingManager.executeBindings(this,"img11",this.img11);
         return _loc1_;
      }
      
      public function __img11_click(param1:MouseEvent) : void
      {
         this.onClick(1,1);
      }
      
      public function __img11_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img11_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_Image7_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img12_click);
         _loc1_.addEventListener("rollOver",this.__img12_rollOver);
         _loc1_.addEventListener("rollOut",this.__img12_rollOut);
         _loc1_.id = "img12";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img12 = _loc1_;
         BindingManager.executeBindings(this,"img12",this.img12);
         return _loc1_;
      }
      
      public function __img12_click(param1:MouseEvent) : void
      {
         this.onClick(1,2);
      }
      
      public function __img12_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img12_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_Image8_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img13_click);
         _loc1_.addEventListener("rollOver",this.__img13_rollOver);
         _loc1_.addEventListener("rollOut",this.__img13_rollOut);
         _loc1_.id = "img13";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img13 = _loc1_;
         BindingManager.executeBindings(this,"img13",this.img13);
         return _loc1_;
      }
      
      public function __img13_click(param1:MouseEvent) : void
      {
         this.onClick(1,3);
      }
      
      public function __img13_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img13_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizOpPopUp_Image9_i(),this._GWizOpPopUp_Image10_i(),this._GWizOpPopUp_Image11_i(),this._GWizOpPopUp_Image12_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizOpPopUp_Image9_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img20_click);
         _loc1_.addEventListener("rollOver",this.__img20_rollOver);
         _loc1_.addEventListener("rollOut",this.__img20_rollOut);
         _loc1_.id = "img20";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img20 = _loc1_;
         BindingManager.executeBindings(this,"img20",this.img20);
         return _loc1_;
      }
      
      public function __img20_click(param1:MouseEvent) : void
      {
         this.onClick(2,0);
      }
      
      public function __img20_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img20_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_Image10_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img21_click);
         _loc1_.addEventListener("rollOver",this.__img21_rollOver);
         _loc1_.addEventListener("rollOut",this.__img21_rollOut);
         _loc1_.id = "img21";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img21 = _loc1_;
         BindingManager.executeBindings(this,"img21",this.img21);
         return _loc1_;
      }
      
      public function __img21_click(param1:MouseEvent) : void
      {
         this.onClick(2,1);
      }
      
      public function __img21_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img21_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_Image11_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img22_click);
         _loc1_.addEventListener("rollOver",this.__img22_rollOver);
         _loc1_.addEventListener("rollOut",this.__img22_rollOut);
         _loc1_.id = "img22";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img22 = _loc1_;
         BindingManager.executeBindings(this,"img22",this.img22);
         return _loc1_;
      }
      
      public function __img22_click(param1:MouseEvent) : void
      {
         this.onClick(2,2);
      }
      
      public function __img22_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img22_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_Image12_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img23_click);
         _loc1_.addEventListener("rollOver",this.__img23_rollOver);
         _loc1_.addEventListener("rollOut",this.__img23_rollOut);
         _loc1_.id = "img23";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img23 = _loc1_;
         BindingManager.executeBindings(this,"img23",this.img23);
         return _loc1_;
      }
      
      public function __img23_click(param1:MouseEvent) : void
      {
         this.onClick(2,3);
      }
      
      public function __img23_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img23_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._GWizOpPopUp_Image13_i(),this._GWizOpPopUp_Image14_i(),this._GWizOpPopUp_Image15_i(),this._GWizOpPopUp_Image16_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizOpPopUp_Image13_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img30_click);
         _loc1_.addEventListener("rollOver",this.__img30_rollOver);
         _loc1_.addEventListener("rollOut",this.__img30_rollOut);
         _loc1_.id = "img30";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img30 = _loc1_;
         BindingManager.executeBindings(this,"img30",this.img30);
         return _loc1_;
      }
      
      public function __img30_click(param1:MouseEvent) : void
      {
         this.onClick(3,0);
      }
      
      public function __img30_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img30_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_Image14_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img31_click);
         _loc1_.addEventListener("rollOver",this.__img31_rollOver);
         _loc1_.addEventListener("rollOut",this.__img31_rollOut);
         _loc1_.id = "img31";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img31 = _loc1_;
         BindingManager.executeBindings(this,"img31",this.img31);
         return _loc1_;
      }
      
      public function __img31_click(param1:MouseEvent) : void
      {
         this.onClick(3,1);
      }
      
      public function __img31_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img31_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_Image15_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img32_click);
         _loc1_.addEventListener("rollOver",this.__img32_rollOver);
         _loc1_.addEventListener("rollOut",this.__img32_rollOut);
         _loc1_.id = "img32";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img32 = _loc1_;
         BindingManager.executeBindings(this,"img32",this.img32);
         return _loc1_;
      }
      
      public function __img32_click(param1:MouseEvent) : void
      {
         this.onClick(3,2);
      }
      
      public function __img32_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img32_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_Image16_i() : Image
      {
         var _loc1_:Image = new Image();
         _loc1_.addEventListener("click",this.__img33_click);
         _loc1_.addEventListener("rollOver",this.__img33_rollOver);
         _loc1_.addEventListener("rollOut",this.__img33_rollOut);
         _loc1_.id = "img33";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.img33 = _loc1_;
         BindingManager.executeBindings(this,"img33",this.img33);
         return _loc1_;
      }
      
      public function __img33_click(param1:MouseEvent) : void
      {
         this.onClick(3,3);
      }
      
      public function __img33_rollOver(param1:MouseEvent) : void
      {
         this.rollover(param1);
      }
      
      public function __img33_rollOut(param1:MouseEvent) : void
      {
         this.rollout(param1);
      }
      
      private function _GWizOpPopUp_VGroup2_i() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.width = 250;
         _loc1_.horizontalAlign = "right";
         _loc1_.mxmlContent = [this._GWizOpPopUp_Label1_c(),this._GWizOpPopUp_GWizMaterialChooser1_i(),this._GWizOpPopUp_Label2_c(),this._GWizOpPopUp_GWizNumStep1_i(),this._GWizOpPopUp_GWizNumStep2_i(),this._GWizOpPopUp_GWizNumStep3_i(),this._GWizOpPopUp_GWizNumStep4_i(),this._GWizOpPopUp_HGroup6_c()];
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "filterGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.filterGrp = _loc1_;
         BindingManager.executeBindings(this,"filterGrp",this.filterGrp);
         return _loc1_;
      }
      
      private function _GWizOpPopUp_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Filters:";
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("fontSize",16);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizOpPopUp_GWizMaterialChooser1_i() : GWizMaterialChooser
      {
         var _loc1_:GWizMaterialChooser = new GWizMaterialChooser();
         _loc1_.percentWidth = 100;
         _loc1_.visible = false;
         _loc1_.id = "MatChooser";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.MatChooser = _loc1_;
         BindingManager.executeBindings(this,"MatChooser",this.MatChooser);
         return _loc1_;
      }
      
      private function _GWizOpPopUp_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0 value means ignore for filtering.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizOpPopUp_GWizNumStep1_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 400;
         _loc1_.steps = 0.0001;
         _loc1_.titleTxt = "Diameter";
         _loc1_.titleColor = 16777215;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.toolTip = "Show diameters within +/- 20% of this.";
         _loc1_.id = "Diameter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Diameter = _loc1_;
         BindingManager.executeBindings(this,"Diameter",this.Diameter);
         return _loc1_;
      }
      
      private function _GWizOpPopUp_GWizNumStep2_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 400;
         _loc1_.steps = 0.0001;
         _loc1_.titleTxt = "Cut Length";
         _loc1_.titleColor = 16777215;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.toolTip = "Show cut lengths within +/- 20% of this.";
         _loc1_.id = "CutLength";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CutLength = _loc1_;
         BindingManager.executeBindings(this,"CutLength",this.CutLength);
         return _loc1_;
      }
      
      private function _GWizOpPopUp_GWizNumStep3_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.min = 0;
         _loc1_.max = 400;
         _loc1_.steps = 0.0001;
         _loc1_.titleTxt = "Stickout";
         _loc1_.titleColor = 16777215;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.toolTip = "Show stickouts within +/- 20% of this.";
         _loc1_.id = "Stickout";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Stickout = _loc1_;
         BindingManager.executeBindings(this,"Stickout",this.Stickout);
         return _loc1_;
      }
      
      private function _GWizOpPopUp_GWizNumStep4_i() : GWizNumStep
      {
         var _loc1_:GWizNumStep = new GWizNumStep();
         _loc1_.titleTxt = "Flutes";
         _loc1_.titleColor = 16777215;
         _loc1_.ignoreForePanelThemes = true;
         _loc1_.toolTip = "Show cutters with this many flutes.";
         _loc1_.min = 0;
         _loc1_.max = 400;
         _loc1_.steps = 1;
         _loc1_.id = "Flutes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Flutes = _loc1_;
         BindingManager.executeBindings(this,"Flutes",this.Flutes);
         return _loc1_;
      }
      
      private function _GWizOpPopUp_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.horizontalAlign = "right";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizOpPopUp_Label3_c(),this._GWizOpPopUp_GWizGeometryCombo1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizOpPopUp_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Tip Type";
         _loc1_.toolTip = "Show cutters with this tip geometry.";
         _loc1_.setStyle("color",16777215);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizOpPopUp_GWizGeometryCombo1_i() : GWizGeometryCombo
      {
         var _loc1_:GWizGeometryCombo = new GWizGeometryCombo();
         _loc1_.id = "Geometry";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Geometry = _loc1_;
         BindingManager.executeBindings(this,"Geometry",this.Geometry);
         return _loc1_;
      }
      
      public function ___GWizOpPopUp_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizOpPopUp_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Boolean
         {
            return GWizSettings.prefs.powerUser || GWizAbstractPrefs.isOEM;
         },null,"filterGrp.visible");
         result[1] = new Binding(this,function():Boolean
         {
            return filterGrp.visible;
         },null,"filterGrp.includeInLayout");
         result[2] = new Binding(this,function():String
         {
            var _loc1_:* = GWizStylePalette.textColor;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"MatChooser.labColor");
         result[3] = new Binding(this,function():Boolean
         {
            return MatChooser.visible;
         },null,"MatChooser.includeInLayout");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get CutLength() : GWizNumStep
      {
         return this._946303064CutLength;
      }
      
      public function set CutLength(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._946303064CutLength;
         if(_loc2_ !== param1)
         {
            this._946303064CutLength = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CutLength",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Diameter() : GWizNumStep
      {
         return this._168560467Diameter;
      }
      
      public function set Diameter(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._168560467Diameter;
         if(_loc2_ !== param1)
         {
            this._168560467Diameter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Diameter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Flutes() : GWizNumStep
      {
         return this._2107381107Flutes;
      }
      
      public function set Flutes(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._2107381107Flutes;
         if(_loc2_ !== param1)
         {
            this._2107381107Flutes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Flutes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Geometry() : GWizGeometryCombo
      {
         return this._1910664338Geometry;
      }
      
      public function set Geometry(param1:GWizGeometryCombo) : void
      {
         var _loc2_:Object = this._1910664338Geometry;
         if(_loc2_ !== param1)
         {
            this._1910664338Geometry = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Geometry",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get MatChooser() : GWizMaterialChooser
      {
         return this._1243041755MatChooser;
      }
      
      public function set MatChooser(param1:GWizMaterialChooser) : void
      {
         var _loc2_:Object = this._1243041755MatChooser;
         if(_loc2_ !== param1)
         {
            this._1243041755MatChooser = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"MatChooser",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Stickout() : GWizNumStep
      {
         return this._1596369118Stickout;
      }
      
      public function set Stickout(param1:GWizNumStep) : void
      {
         var _loc2_:Object = this._1596369118Stickout;
         if(_loc2_ !== param1)
         {
            this._1596369118Stickout = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Stickout",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get filterGrp() : VGroup
      {
         return this._881395123filterGrp;
      }
      
      public function set filterGrp(param1:VGroup) : void
      {
         var _loc2_:Object = this._881395123filterGrp;
         if(_loc2_ !== param1)
         {
            this._881395123filterGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"filterGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img00() : Image
      {
         return this._100317443img00;
      }
      
      public function set img00(param1:Image) : void
      {
         var _loc2_:Object = this._100317443img00;
         if(_loc2_ !== param1)
         {
            this._100317443img00 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img00",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img01() : Image
      {
         return this._100317444img01;
      }
      
      public function set img01(param1:Image) : void
      {
         var _loc2_:Object = this._100317444img01;
         if(_loc2_ !== param1)
         {
            this._100317444img01 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img01",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img02() : Image
      {
         return this._100317445img02;
      }
      
      public function set img02(param1:Image) : void
      {
         var _loc2_:Object = this._100317445img02;
         if(_loc2_ !== param1)
         {
            this._100317445img02 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img02",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img03() : Image
      {
         return this._100317446img03;
      }
      
      public function set img03(param1:Image) : void
      {
         var _loc2_:Object = this._100317446img03;
         if(_loc2_ !== param1)
         {
            this._100317446img03 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img03",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img10() : Image
      {
         return this._100317474img10;
      }
      
      public function set img10(param1:Image) : void
      {
         var _loc2_:Object = this._100317474img10;
         if(_loc2_ !== param1)
         {
            this._100317474img10 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img10",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img11() : Image
      {
         return this._100317475img11;
      }
      
      public function set img11(param1:Image) : void
      {
         var _loc2_:Object = this._100317475img11;
         if(_loc2_ !== param1)
         {
            this._100317475img11 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img11",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img12() : Image
      {
         return this._100317476img12;
      }
      
      public function set img12(param1:Image) : void
      {
         var _loc2_:Object = this._100317476img12;
         if(_loc2_ !== param1)
         {
            this._100317476img12 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img12",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img13() : Image
      {
         return this._100317477img13;
      }
      
      public function set img13(param1:Image) : void
      {
         var _loc2_:Object = this._100317477img13;
         if(_loc2_ !== param1)
         {
            this._100317477img13 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img13",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img20() : Image
      {
         return this._100317505img20;
      }
      
      public function set img20(param1:Image) : void
      {
         var _loc2_:Object = this._100317505img20;
         if(_loc2_ !== param1)
         {
            this._100317505img20 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img20",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img21() : Image
      {
         return this._100317506img21;
      }
      
      public function set img21(param1:Image) : void
      {
         var _loc2_:Object = this._100317506img21;
         if(_loc2_ !== param1)
         {
            this._100317506img21 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img21",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img22() : Image
      {
         return this._100317507img22;
      }
      
      public function set img22(param1:Image) : void
      {
         var _loc2_:Object = this._100317507img22;
         if(_loc2_ !== param1)
         {
            this._100317507img22 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img22",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img23() : Image
      {
         return this._100317508img23;
      }
      
      public function set img23(param1:Image) : void
      {
         var _loc2_:Object = this._100317508img23;
         if(_loc2_ !== param1)
         {
            this._100317508img23 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img23",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img30() : Image
      {
         return this._100317536img30;
      }
      
      public function set img30(param1:Image) : void
      {
         var _loc2_:Object = this._100317536img30;
         if(_loc2_ !== param1)
         {
            this._100317536img30 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img30",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img31() : Image
      {
         return this._100317537img31;
      }
      
      public function set img31(param1:Image) : void
      {
         var _loc2_:Object = this._100317537img31;
         if(_loc2_ !== param1)
         {
            this._100317537img31 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img31",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img32() : Image
      {
         return this._100317538img32;
      }
      
      public function set img32(param1:Image) : void
      {
         var _loc2_:Object = this._100317538img32;
         if(_loc2_ !== param1)
         {
            this._100317538img32 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img32",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get img33() : Image
      {
         return this._100317539img33;
      }
      
      public function set img33(param1:Image) : void
      {
         var _loc2_:Object = this._100317539img33;
         if(_loc2_ !== param1)
         {
            this._100317539img33 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"img33",_loc2_,param1));
            }
         }
      }
   }
}
