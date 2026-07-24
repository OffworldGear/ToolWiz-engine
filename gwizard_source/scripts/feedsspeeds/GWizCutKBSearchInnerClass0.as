package feedsspeeds
{
   import comps.Rating;
   import configinfo.GWizConfigData;
   import material.GWizMaterialsDB;
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.supportClasses.ItemRenderer;
   import utils.GWizUtils;
   
   public class GWizCutKBSearchInnerClass0 extends ItemRenderer
   {
       
      
      private var _739134921chatter:Label;
      
      private var _602415628comments:Label;
      
      private var _952211966coolant:Label;
      
      private var _3062216crib:Label;
      
      private var _590180769cutDepth:Label;
      
      private var _1127912604cutType:Label;
      
      private var _607835300cutWidth:Label;
      
      private var _1724546052description:Label;
      
      private var _1271453357flutes:Label;
      
      private var _1846020210geometry:Label;
      
      private var _116645314hardness:Label;
      
      private var _1211707988holder:Label;
      
      private var _104486ipm:Label;
      
      private var _1182144805ipmPct:Label;
      
      private var _104493ipt:Label;
      
      private var _1181936268iptPct:Label;
      
      private var _50351358leadang:Label;
      
      private var _825312327machine:Label;
      
      private var _2115803054materialName:Label;
      
      private var _108397mrr:Label;
      
      private var _1065632204mrrPct:Label;
      
      private var _2128288578noseRad:Label;
      
      private var _88844982outerDocument:GWizCutKBSearch;
      
      private var _938102371rating:Rating;
      
      private var _108703929rough:Label;
      
      private var _1385263910rougher:Label;
      
      private var _113135rpm:Label;
      
      private var _924482446rpmPct:Label;
      
      private var _113786sfm:Label;
      
      private var _905088505sfmPct:Label;
      
      private var _1531724990stickout:Label;
      
      private var _114704tea:Label;
      
      private var _3565976tool:Label;
      
      private var _1140122684toolDia:Label;
      
      private var _110818187txtid:Label;
      
      private var _3645311wear:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function GWizCutKBSearchInnerClass0()
      {
         super();
         mx_internal::_document = this;
         this.percentWidth = 100;
         this.doubleClickEnabled = true;
         this.mxmlContent = [this._GWizCutKBSearchInnerClass0_HGroup1_c()];
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
         this.description.text = param1.description;
         this.cutType.text = GWizCutType.CutTypesLabelFcn(param1.cutType);
         this.rough.text = param1 && param1.rough == "true" ? "✓" : "";
         this.rating.value = param1.rating;
         this.mrr.text = GWizUtils.convUnitsCCLabelFcn(param1.mrr);
         this.mrrPct.text = GWizUtils.addPctLabelFcn(param1.mrrPct);
         this.rpm.text = param1.rpm;
         this.rpmPct.text = GWizUtils.addPctLabelFcn(param1.rpmPct);
         this.ipm.text = GWizUtils.convUnitsInMMLabelFcn(param1.ipm);
         this.ipmPct.text = GWizUtils.addPctLabelFcn(param1.ipmPct);
         this.chatter.text = param1.chatter;
         this.wear.text = GWizConfigData.ToolWearLabelFcn(param1.wear);
         this.comments.text = param1.comments;
         this.sfm.text = GWizUtils.convUnitsFtMLabelFcn(param1.sfm);
         this.sfmPct.text = GWizUtils.addPctLabelFcn(param1.sfmPct);
         this.ipt.text = GWizUtils.convUnitsInMMLabelFcn(param1.ipt);
         this.iptPct.text = GWizUtils.addPctLabelFcn(param1.iptPct);
         this.cutDepth.text = GWizUtils.convUnitsInMMLabelFcn(param1.cutDepth);
         this.cutWidth.text = GWizUtils.convUnitsInMMLabelFcn(param1.cutWidth);
         this.tea.text = param1.tea;
         this.materialName.text = GWizMaterialsDB.MaterialsListLabelFcn(param1.material);
         this.hardness.text = param1.hardness;
         this.machine.text = param1.machine;
         this.holder.text = GWizConfigData.HolderTypesLabelFcn(param1.holder);
         this.coolant.text = GWizConfigData.CoolantTypeLabelFcn(param1.coolant);
         this.tool.text = param1.tool;
         this.crib.text = param1.crib;
         this.flutes.text = param1.flutes;
         this.geometry.text = param1.geometry;
         this.leadang.text = param1.leadang;
         this.rougher.text = param1 && param1.rougher == "true" ? "✓" : "";
         this.toolDia.text = GWizUtils.convUnitsInMMLabelFcn(param1.toolDia);
         this.stickout.text = GWizUtils.convUnitsInMMLabelFcn(param1.stickout);
         this.noseRad.text = GWizUtils.convUnitsInMMLabelFcn(param1.noseRad);
         this.txtid.text = param1.id;
      }
      
      private function _GWizCutKBSearchInnerClass0_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.gap = 1;
         _loc1_.mxmlContent = [this._GWizCutKBSearchInnerClass0_Label1_i(),this._GWizCutKBSearchInnerClass0_Label2_i(),this._GWizCutKBSearchInnerClass0_Label3_i(),this._GWizCutKBSearchInnerClass0_Rating1_i(),this._GWizCutKBSearchInnerClass0_Label4_i(),this._GWizCutKBSearchInnerClass0_Label5_i(),this._GWizCutKBSearchInnerClass0_Label6_i(),this._GWizCutKBSearchInnerClass0_Label7_i(),this._GWizCutKBSearchInnerClass0_Label8_i(),this._GWizCutKBSearchInnerClass0_Label9_i(),this._GWizCutKBSearchInnerClass0_Label10_i(),this._GWizCutKBSearchInnerClass0_Label11_i(),this._GWizCutKBSearchInnerClass0_Label12_i(),this._GWizCutKBSearchInnerClass0_Label13_i(),this._GWizCutKBSearchInnerClass0_Label14_i(),this._GWizCutKBSearchInnerClass0_Label15_i(),this._GWizCutKBSearchInnerClass0_Label16_i(),this._GWizCutKBSearchInnerClass0_Label17_i(),this._GWizCutKBSearchInnerClass0_Label18_i(),this._GWizCutKBSearchInnerClass0_Label19_i(),this._GWizCutKBSearchInnerClass0_Label20_i(),this._GWizCutKBSearchInnerClass0_Label21_i(),this._GWizCutKBSearchInnerClass0_Label22_i(),this._GWizCutKBSearchInnerClass0_Label23_i(),this._GWizCutKBSearchInnerClass0_Label24_i(),this._GWizCutKBSearchInnerClass0_Label25_i(),this._GWizCutKBSearchInnerClass0_Label26_i(),this._GWizCutKBSearchInnerClass0_Label27_i(),this._GWizCutKBSearchInnerClass0_Label28_i(),this._GWizCutKBSearchInnerClass0_Label29_i(),this._GWizCutKBSearchInnerClass0_Label30_i(),this._GWizCutKBSearchInnerClass0_Label31_i(),this._GWizCutKBSearchInnerClass0_Label32_i(),this._GWizCutKBSearchInnerClass0_Label33_i(),this._GWizCutKBSearchInnerClass0_Label34_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 200;
         _loc1_.setStyle("textAlign","left");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "description";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.description = _loc1_;
         BindingManager.executeBindings(this,"description",this.description);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 100;
         _loc1_.setStyle("textAlign","left");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "cutType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cutType = _loc1_;
         BindingManager.executeBindings(this,"cutType",this.cutType);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 60;
         _loc1_.setStyle("textAlign","left");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "rough";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.rough = _loc1_;
         BindingManager.executeBindings(this,"rough",this.rough);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Rating1_i() : Rating
      {
         var _loc1_:Rating = new Rating();
         _loc1_.width = 70;
         _loc1_.smallSize = true;
         _loc1_.id = "rating";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.rating = _loc1_;
         BindingManager.executeBindings(this,"rating",this.rating);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 50;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "mrr";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.mrr = _loc1_;
         BindingManager.executeBindings(this,"mrr",this.mrr);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 50;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "mrrPct";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.mrrPct = _loc1_;
         BindingManager.executeBindings(this,"mrrPct",this.mrrPct);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 50;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "rpm";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.rpm = _loc1_;
         BindingManager.executeBindings(this,"rpm",this.rpm);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 50;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "rpmPct";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.rpmPct = _loc1_;
         BindingManager.executeBindings(this,"rpmPct",this.rpmPct);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label8_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 50;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "ipm";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ipm = _loc1_;
         BindingManager.executeBindings(this,"ipm",this.ipm);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label9_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 50;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "ipmPct";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ipmPct = _loc1_;
         BindingManager.executeBindings(this,"ipmPct",this.ipmPct);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label10_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 55;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "chatter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.chatter = _loc1_;
         BindingManager.executeBindings(this,"chatter",this.chatter);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label11_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 50;
         _loc1_.setStyle("textAlign","center");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "wear";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.wear = _loc1_;
         BindingManager.executeBindings(this,"wear",this.wear);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label12_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 300;
         _loc1_.setStyle("textAlign","left");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "comments";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.comments = _loc1_;
         BindingManager.executeBindings(this,"comments",this.comments);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label13_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 50;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "sfm";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sfm = _loc1_;
         BindingManager.executeBindings(this,"sfm",this.sfm);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label14_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 50;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "sfmPct";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.sfmPct = _loc1_;
         BindingManager.executeBindings(this,"sfmPct",this.sfmPct);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label15_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 50;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "ipt";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.ipt = _loc1_;
         BindingManager.executeBindings(this,"ipt",this.ipt);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label16_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 50;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "iptPct";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.iptPct = _loc1_;
         BindingManager.executeBindings(this,"iptPct",this.iptPct);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label17_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 70;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "cutDepth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cutDepth = _loc1_;
         BindingManager.executeBindings(this,"cutDepth",this.cutDepth);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label18_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 70;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "cutWidth";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cutWidth = _loc1_;
         BindingManager.executeBindings(this,"cutWidth",this.cutWidth);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label19_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 50;
         _loc1_.setStyle("textAlign","center");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "tea";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tea = _loc1_;
         BindingManager.executeBindings(this,"tea",this.tea);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label20_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 250;
         _loc1_.setStyle("textAlign","left");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "materialName";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.materialName = _loc1_;
         BindingManager.executeBindings(this,"materialName",this.materialName);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label21_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 50;
         _loc1_.setStyle("textAlign","center");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "hardness";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.hardness = _loc1_;
         BindingManager.executeBindings(this,"hardness",this.hardness);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label22_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 250;
         _loc1_.setStyle("textAlign","left");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "machine";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machine = _loc1_;
         BindingManager.executeBindings(this,"machine",this.machine);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label23_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 100;
         _loc1_.setStyle("textAlign","left");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "holder";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.holder = _loc1_;
         BindingManager.executeBindings(this,"holder",this.holder);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label24_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 80;
         _loc1_.setStyle("textAlign","left");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "coolant";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.coolant = _loc1_;
         BindingManager.executeBindings(this,"coolant",this.coolant);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label25_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 100;
         _loc1_.setStyle("textAlign","left");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "tool";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tool = _loc1_;
         BindingManager.executeBindings(this,"tool",this.tool);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label26_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 150;
         _loc1_.setStyle("textAlign","left");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "crib";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.crib = _loc1_;
         BindingManager.executeBindings(this,"crib",this.crib);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label27_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 60;
         _loc1_.setStyle("textAlign","center");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "flutes";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.flutes = _loc1_;
         BindingManager.executeBindings(this,"flutes",this.flutes);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label28_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 100;
         _loc1_.setStyle("textAlign","center");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "geometry";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.geometry = _loc1_;
         BindingManager.executeBindings(this,"geometry",this.geometry);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label29_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 60;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "leadang";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.leadang = _loc1_;
         BindingManager.executeBindings(this,"leadang",this.leadang);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label30_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 60;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "rougher";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.rougher = _loc1_;
         BindingManager.executeBindings(this,"rougher",this.rougher);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label31_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 80;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "toolDia";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.toolDia = _loc1_;
         BindingManager.executeBindings(this,"toolDia",this.toolDia);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label32_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 80;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "stickout";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.stickout = _loc1_;
         BindingManager.executeBindings(this,"stickout",this.stickout);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label33_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 80;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "noseRad";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.noseRad = _loc1_;
         BindingManager.executeBindings(this,"noseRad",this.noseRad);
         return _loc1_;
      }
      
      private function _GWizCutKBSearchInnerClass0_Label34_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.width = 80;
         _loc1_.setStyle("textAlign","right");
         _loc1_.setStyle("paddingTop",3);
         _loc1_.setStyle("paddingBottom",3);
         _loc1_.setStyle("paddingLeft",3);
         _loc1_.setStyle("paddingRight",3);
         _loc1_.id = "txtid";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.txtid = _loc1_;
         BindingManager.executeBindings(this,"txtid",this.txtid);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get chatter() : Label
      {
         return this._739134921chatter;
      }
      
      public function set chatter(param1:Label) : void
      {
         var _loc2_:Object = this._739134921chatter;
         if(_loc2_ !== param1)
         {
            this._739134921chatter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"chatter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get comments() : Label
      {
         return this._602415628comments;
      }
      
      public function set comments(param1:Label) : void
      {
         var _loc2_:Object = this._602415628comments;
         if(_loc2_ !== param1)
         {
            this._602415628comments = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"comments",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get coolant() : Label
      {
         return this._952211966coolant;
      }
      
      public function set coolant(param1:Label) : void
      {
         var _loc2_:Object = this._952211966coolant;
         if(_loc2_ !== param1)
         {
            this._952211966coolant = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"coolant",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get crib() : Label
      {
         return this._3062216crib;
      }
      
      public function set crib(param1:Label) : void
      {
         var _loc2_:Object = this._3062216crib;
         if(_loc2_ !== param1)
         {
            this._3062216crib = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"crib",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cutDepth() : Label
      {
         return this._590180769cutDepth;
      }
      
      public function set cutDepth(param1:Label) : void
      {
         var _loc2_:Object = this._590180769cutDepth;
         if(_loc2_ !== param1)
         {
            this._590180769cutDepth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cutDepth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cutType() : Label
      {
         return this._1127912604cutType;
      }
      
      public function set cutType(param1:Label) : void
      {
         var _loc2_:Object = this._1127912604cutType;
         if(_loc2_ !== param1)
         {
            this._1127912604cutType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cutType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get cutWidth() : Label
      {
         return this._607835300cutWidth;
      }
      
      public function set cutWidth(param1:Label) : void
      {
         var _loc2_:Object = this._607835300cutWidth;
         if(_loc2_ !== param1)
         {
            this._607835300cutWidth = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cutWidth",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get description() : Label
      {
         return this._1724546052description;
      }
      
      public function set description(param1:Label) : void
      {
         var _loc2_:Object = this._1724546052description;
         if(_loc2_ !== param1)
         {
            this._1724546052description = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"description",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get flutes() : Label
      {
         return this._1271453357flutes;
      }
      
      public function set flutes(param1:Label) : void
      {
         var _loc2_:Object = this._1271453357flutes;
         if(_loc2_ !== param1)
         {
            this._1271453357flutes = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"flutes",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get geometry() : Label
      {
         return this._1846020210geometry;
      }
      
      public function set geometry(param1:Label) : void
      {
         var _loc2_:Object = this._1846020210geometry;
         if(_loc2_ !== param1)
         {
            this._1846020210geometry = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"geometry",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get hardness() : Label
      {
         return this._116645314hardness;
      }
      
      public function set hardness(param1:Label) : void
      {
         var _loc2_:Object = this._116645314hardness;
         if(_loc2_ !== param1)
         {
            this._116645314hardness = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hardness",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get holder() : Label
      {
         return this._1211707988holder;
      }
      
      public function set holder(param1:Label) : void
      {
         var _loc2_:Object = this._1211707988holder;
         if(_loc2_ !== param1)
         {
            this._1211707988holder = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"holder",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ipm() : Label
      {
         return this._104486ipm;
      }
      
      public function set ipm(param1:Label) : void
      {
         var _loc2_:Object = this._104486ipm;
         if(_loc2_ !== param1)
         {
            this._104486ipm = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ipm",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ipmPct() : Label
      {
         return this._1182144805ipmPct;
      }
      
      public function set ipmPct(param1:Label) : void
      {
         var _loc2_:Object = this._1182144805ipmPct;
         if(_loc2_ !== param1)
         {
            this._1182144805ipmPct = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ipmPct",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get ipt() : Label
      {
         return this._104493ipt;
      }
      
      public function set ipt(param1:Label) : void
      {
         var _loc2_:Object = this._104493ipt;
         if(_loc2_ !== param1)
         {
            this._104493ipt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"ipt",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get iptPct() : Label
      {
         return this._1181936268iptPct;
      }
      
      public function set iptPct(param1:Label) : void
      {
         var _loc2_:Object = this._1181936268iptPct;
         if(_loc2_ !== param1)
         {
            this._1181936268iptPct = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"iptPct",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get leadang() : Label
      {
         return this._50351358leadang;
      }
      
      public function set leadang(param1:Label) : void
      {
         var _loc2_:Object = this._50351358leadang;
         if(_loc2_ !== param1)
         {
            this._50351358leadang = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"leadang",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machine() : Label
      {
         return this._825312327machine;
      }
      
      public function set machine(param1:Label) : void
      {
         var _loc2_:Object = this._825312327machine;
         if(_loc2_ !== param1)
         {
            this._825312327machine = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machine",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get materialName() : Label
      {
         return this._2115803054materialName;
      }
      
      public function set materialName(param1:Label) : void
      {
         var _loc2_:Object = this._2115803054materialName;
         if(_loc2_ !== param1)
         {
            this._2115803054materialName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"materialName",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get mrr() : Label
      {
         return this._108397mrr;
      }
      
      public function set mrr(param1:Label) : void
      {
         var _loc2_:Object = this._108397mrr;
         if(_loc2_ !== param1)
         {
            this._108397mrr = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"mrr",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get mrrPct() : Label
      {
         return this._1065632204mrrPct;
      }
      
      public function set mrrPct(param1:Label) : void
      {
         var _loc2_:Object = this._1065632204mrrPct;
         if(_loc2_ !== param1)
         {
            this._1065632204mrrPct = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"mrrPct",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get noseRad() : Label
      {
         return this._2128288578noseRad;
      }
      
      public function set noseRad(param1:Label) : void
      {
         var _loc2_:Object = this._2128288578noseRad;
         if(_loc2_ !== param1)
         {
            this._2128288578noseRad = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"noseRad",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizCutKBSearch
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizCutKBSearch) : void
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
      public function get rating() : Rating
      {
         return this._938102371rating;
      }
      
      public function set rating(param1:Rating) : void
      {
         var _loc2_:Object = this._938102371rating;
         if(_loc2_ !== param1)
         {
            this._938102371rating = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"rating",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get rough() : Label
      {
         return this._108703929rough;
      }
      
      public function set rough(param1:Label) : void
      {
         var _loc2_:Object = this._108703929rough;
         if(_loc2_ !== param1)
         {
            this._108703929rough = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"rough",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get rougher() : Label
      {
         return this._1385263910rougher;
      }
      
      public function set rougher(param1:Label) : void
      {
         var _loc2_:Object = this._1385263910rougher;
         if(_loc2_ !== param1)
         {
            this._1385263910rougher = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"rougher",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get rpm() : Label
      {
         return this._113135rpm;
      }
      
      public function set rpm(param1:Label) : void
      {
         var _loc2_:Object = this._113135rpm;
         if(_loc2_ !== param1)
         {
            this._113135rpm = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"rpm",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get rpmPct() : Label
      {
         return this._924482446rpmPct;
      }
      
      public function set rpmPct(param1:Label) : void
      {
         var _loc2_:Object = this._924482446rpmPct;
         if(_loc2_ !== param1)
         {
            this._924482446rpmPct = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"rpmPct",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sfm() : Label
      {
         return this._113786sfm;
      }
      
      public function set sfm(param1:Label) : void
      {
         var _loc2_:Object = this._113786sfm;
         if(_loc2_ !== param1)
         {
            this._113786sfm = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sfm",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get sfmPct() : Label
      {
         return this._905088505sfmPct;
      }
      
      public function set sfmPct(param1:Label) : void
      {
         var _loc2_:Object = this._905088505sfmPct;
         if(_loc2_ !== param1)
         {
            this._905088505sfmPct = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"sfmPct",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get stickout() : Label
      {
         return this._1531724990stickout;
      }
      
      public function set stickout(param1:Label) : void
      {
         var _loc2_:Object = this._1531724990stickout;
         if(_loc2_ !== param1)
         {
            this._1531724990stickout = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"stickout",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tea() : Label
      {
         return this._114704tea;
      }
      
      public function set tea(param1:Label) : void
      {
         var _loc2_:Object = this._114704tea;
         if(_loc2_ !== param1)
         {
            this._114704tea = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tea",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tool() : Label
      {
         return this._3565976tool;
      }
      
      public function set tool(param1:Label) : void
      {
         var _loc2_:Object = this._3565976tool;
         if(_loc2_ !== param1)
         {
            this._3565976tool = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tool",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get toolDia() : Label
      {
         return this._1140122684toolDia;
      }
      
      public function set toolDia(param1:Label) : void
      {
         var _loc2_:Object = this._1140122684toolDia;
         if(_loc2_ !== param1)
         {
            this._1140122684toolDia = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"toolDia",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get txtid() : Label
      {
         return this._110818187txtid;
      }
      
      public function set txtid(param1:Label) : void
      {
         var _loc2_:Object = this._110818187txtid;
         if(_loc2_ !== param1)
         {
            this._110818187txtid = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"txtid",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get wear() : Label
      {
         return this._3645311wear;
      }
      
      public function set wear(param1:Label) : void
      {
         var _loc2_:Object = this._3645311wear;
         if(_loc2_ !== param1)
         {
            this._3645311wear = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"wear",_loc2_,param1));
            }
         }
      }
   }
}
