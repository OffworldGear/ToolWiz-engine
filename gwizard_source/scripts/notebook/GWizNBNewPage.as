package notebook
{
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.net.FileFilter;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   import spark.components.TextInput;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizNBNewPage extends GWizPopUp implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1791469120CSVType:RadioButton;
      
      private var _1145615899NotepadType:RadioButton;
      
      public var _GWizNBNewPage_Button1:Button;
      
      public var _GWizNBNewPage_Button2:Button;
      
      private var _1350845015csvurl:TextInput;
      
      private var _859271610pageName:TextInput;
      
      private var _1408964138pagetypegroup:RadioButtonGroup;
      
      private var _859591425txturl:TextInput;
      
      private var _234054827webURLType:RadioButton;
      
      private var _791787109weburl:TextInput;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var newPageCallback:Function = null;
      
      private var textInpForBrowser:TextInput;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizNBNewPage()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizNBNewPage_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_notebook_GWizNBNewPageWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizNBNewPage[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.width = 520;
         this.height = 200;
         this.title = "Add Notebook Page";
         this.okLabel = "Add Page";
         this.mxmlContent = [this._GWizNBNewPage_HGroup1_c(),this._GWizNBNewPage_HGroup2_c(),this._GWizNBNewPage_HGroup3_c(),this._GWizNBNewPage_HGroup4_c()];
         this._GWizNBNewPage_RadioButtonGroup1_i();
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizNBNewPage._watcherSetupUtil = param1;
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
      
      override public function onOk(param1:Event) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(this.newPageCallback != null)
         {
            _loc2_ = GWizNotebook.WEB_PAGE;
            _loc3_ = "";
            _loc4_ = "";
            if(this.CSVType.selected)
            {
               _loc2_ = GWizNotebook.CSV_PAGE;
               _loc3_ = this.csvurl.text;
               if(_loc3_ == "")
               {
                  _loc4_ = "Missing CSV file";
               }
            }
            else if(this.NotepadType.selected)
            {
               _loc2_ = GWizNotebook.TXT_PAGE;
               _loc3_ = this.txturl.text;
               if(_loc3_ == "")
               {
                  _loc4_ = "Missing text file";
               }
            }
            else
            {
               _loc2_ = GWizNotebook.WEB_PAGE;
               _loc3_ = this.weburl.text;
               if(_loc3_ == "")
               {
                  _loc4_ = "Missing page URL";
               }
            }
            if(this.pageName.text == "")
            {
               _loc4_ = "Missing page name";
            }
            if(_loc4_ != "")
            {
               GWizPopUpManager.Show(_loc4_,"Error: Notebook Error",GWizPopUpManager.ERROR);
            }
            else
            {
               this.newPageCallback(this.pageName.text,_loc2_,_loc3_,0);
            }
         }
         super.close();
      }
      
      private function browseFileURL(param1:TextInput) : void
      {
         var _loc3_:FileFilter = null;
         this.textInpForBrowser = param1;
         var _loc2_:File = new File();
         if(param1 == this.csvurl)
         {
            _loc3_ = new FileFilter("CSV Files","*.csv");
         }
         else
         {
            _loc3_ = new FileFilter("Text Files","*.txt");
         }
         _loc2_.browseForOpen("Open",[_loc3_]);
         _loc2_.addEventListener(Event.SELECT,this.fileSelectedForOpen);
      }
      
      private function fileSelectedForOpen(param1:Event) : void
      {
         var _loc2_:File = File(param1.target);
         if(this.textInpForBrowser)
         {
            this.textInpForBrowser.text = _loc2_.url;
         }
         else
         {
            GWizUtils.assert(false);
         }
      }
      
      private function _GWizNBNewPage_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"pagetypegroup");
         this.pagetypegroup = _loc1_;
         BindingManager.executeBindings(this,"pagetypegroup",this.pagetypegroup);
         return _loc1_;
      }
      
      private function _GWizNBNewPage_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizNBNewPage_Label1_c(),this._GWizNBNewPage_TextInput1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizNBNewPage_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Page Name";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizNBNewPage_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.width = 410;
         _loc1_.setStyle("color",0);
         _loc1_.id = "pageName";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.pageName = _loc1_;
         BindingManager.executeBindings(this,"pageName",this.pageName);
         return _loc1_;
      }
      
      private function _GWizNBNewPage_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizNBNewPage_RadioButton1_i(),this._GWizNBNewPage_TextInput2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizNBNewPage_RadioButton1_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Web Page URL:";
         _loc1_.groupName = "pagetypegroup";
         _loc1_.selected = true;
         _loc1_.id = "webURLType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.webURLType = _loc1_;
         BindingManager.executeBindings(this,"webURLType",this.webURLType);
         return _loc1_;
      }
      
      private function _GWizNBNewPage_TextInput2_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.width = 374;
         _loc1_.toolTip = "Web URL to display on the notebook page";
         _loc1_.setStyle("color",0);
         _loc1_.id = "weburl";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.weburl = _loc1_;
         BindingManager.executeBindings(this,"weburl",this.weburl);
         return _loc1_;
      }
      
      private function _GWizNBNewPage_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizNBNewPage_RadioButton2_i(),this._GWizNBNewPage_TextInput3_i(),this._GWizNBNewPage_Button1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizNBNewPage_RadioButton2_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "CSV File";
         _loc1_.groupName = "pagetypegroup";
         _loc1_.id = "CSVType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CSVType = _loc1_;
         BindingManager.executeBindings(this,"CSVType",this.CSVType);
         return _loc1_;
      }
      
      private function _GWizNBNewPage_TextInput3_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.width = 336;
         _loc1_.toolTip = "File URL for the CSV file.";
         _loc1_.setStyle("color",0);
         _loc1_.id = "csvurl";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.csvurl = _loc1_;
         BindingManager.executeBindings(this,"csvurl",this.csvurl);
         return _loc1_;
      }
      
      private function _GWizNBNewPage_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Browse...";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("click",this.___GWizNBNewPage_Button1_click);
         _loc1_.id = "_GWizNBNewPage_Button1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizNBNewPage_Button1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizNBNewPage_Button1",this._GWizNBNewPage_Button1);
         return _loc1_;
      }
      
      public function ___GWizNBNewPage_Button1_click(param1:MouseEvent) : void
      {
         this.browseFileURL(this.csvurl);
      }
      
      private function _GWizNBNewPage_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizNBNewPage_RadioButton3_i(),this._GWizNBNewPage_TextInput4_i(),this._GWizNBNewPage_Button2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizNBNewPage_RadioButton3_i() : RadioButton
      {
         var _loc1_:RadioButton = new RadioButton();
         _loc1_.label = "Text File";
         _loc1_.groupName = "pagetypegroup";
         _loc1_.id = "NotepadType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.NotepadType = _loc1_;
         BindingManager.executeBindings(this,"NotepadType",this.NotepadType);
         return _loc1_;
      }
      
      private function _GWizNBNewPage_TextInput4_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.width = 336;
         _loc1_.toolTip = "File URL for the Text file.";
         _loc1_.setStyle("color",0);
         _loc1_.id = "txturl";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.txturl = _loc1_;
         BindingManager.executeBindings(this,"txturl",this.txturl);
         return _loc1_;
      }
      
      private function _GWizNBNewPage_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Browse...";
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("click",this.___GWizNBNewPage_Button2_click);
         _loc1_.id = "_GWizNBNewPage_Button2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizNBNewPage_Button2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizNBNewPage_Button2",this._GWizNBNewPage_Button2);
         return _loc1_;
      }
      
      public function ___GWizNBNewPage_Button2_click(param1:MouseEvent) : void
      {
         this.browseFileURL(this.txturl);
      }
      
      private function _GWizNBNewPage_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Boolean
         {
            return webURLType.selected;
         },null,"weburl.enabled");
         result[1] = new Binding(this,function():Boolean
         {
            return CSVType.selected;
         },null,"csvurl.enabled");
         result[2] = new Binding(this,function():Boolean
         {
            return CSVType.selected;
         },null,"_GWizNBNewPage_Button1.enabled");
         result[3] = new Binding(this,function():Boolean
         {
            return NotepadType.selected;
         },null,"txturl.enabled");
         result[4] = new Binding(this,function():Boolean
         {
            return NotepadType.selected;
         },null,"_GWizNBNewPage_Button2.enabled");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get CSVType() : RadioButton
      {
         return this._1791469120CSVType;
      }
      
      public function set CSVType(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1791469120CSVType;
         if(_loc2_ !== param1)
         {
            this._1791469120CSVType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CSVType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get NotepadType() : RadioButton
      {
         return this._1145615899NotepadType;
      }
      
      public function set NotepadType(param1:RadioButton) : void
      {
         var _loc2_:Object = this._1145615899NotepadType;
         if(_loc2_ !== param1)
         {
            this._1145615899NotepadType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"NotepadType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get csvurl() : TextInput
      {
         return this._1350845015csvurl;
      }
      
      public function set csvurl(param1:TextInput) : void
      {
         var _loc2_:Object = this._1350845015csvurl;
         if(_loc2_ !== param1)
         {
            this._1350845015csvurl = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"csvurl",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get pageName() : TextInput
      {
         return this._859271610pageName;
      }
      
      public function set pageName(param1:TextInput) : void
      {
         var _loc2_:Object = this._859271610pageName;
         if(_loc2_ !== param1)
         {
            this._859271610pageName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"pageName",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get pagetypegroup() : RadioButtonGroup
      {
         return this._1408964138pagetypegroup;
      }
      
      public function set pagetypegroup(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._1408964138pagetypegroup;
         if(_loc2_ !== param1)
         {
            this._1408964138pagetypegroup = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"pagetypegroup",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get txturl() : TextInput
      {
         return this._859591425txturl;
      }
      
      public function set txturl(param1:TextInput) : void
      {
         var _loc2_:Object = this._859591425txturl;
         if(_loc2_ !== param1)
         {
            this._859591425txturl = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"txturl",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get webURLType() : RadioButton
      {
         return this._234054827webURLType;
      }
      
      public function set webURLType(param1:RadioButton) : void
      {
         var _loc2_:Object = this._234054827webURLType;
         if(_loc2_ !== param1)
         {
            this._234054827webURLType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"webURLType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get weburl() : TextInput
      {
         return this._791787109weburl;
      }
      
      public function set weburl(param1:TextInput) : void
      {
         var _loc2_:Object = this._791787109weburl;
         if(_loc2_ !== param1)
         {
            this._791787109weburl = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"weburl",_loc2_,param1));
            }
         }
      }
   }
}
