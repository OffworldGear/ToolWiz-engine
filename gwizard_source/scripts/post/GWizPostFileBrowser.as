package post
{
   import bubbletip.GWizBubbleTip;
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.core.ClassFactory;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.Button;
   import spark.components.DataGrid;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.VGroup;
   import spark.components.gridClasses.GridColumn;
   import utils.GWizURLLoader;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizPostFileBrowser extends GWizPopUp implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizPostFileBrowser");
      
      private static var _106855379posts:ArrayCollection = new ArrayCollection();
      
      public static var postsAvailable:Boolean;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _1675388953Message:Label;
      
      public var _GWizPostFileBrowser_ClassFactory1:ClassFactory;
      
      public var _GWizPostFileBrowser_GWizBubbleTip1:GWizBubbleTip;
      
      private var _3322014list:DataGrid;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var handler:Function;
      
      private var missingPost:GWizMissingPost;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizPostFileBrowser()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizPostFileBrowser_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_post_GWizPostFileBrowserWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizPostFileBrowser[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.okLabel = "Select Post";
         this.title = "Select CNC Controller Post...";
         this.width = 400;
         this.height = 500;
         this.mxmlContent = [this._GWizPostFileBrowser_VGroup1_c()];
         this._GWizPostFileBrowser_ClassFactory1_i();
         this.addEventListener("creationComplete",this.___GWizPostFileBrowser_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function initPostsList(param1:Label) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:File = null;
         var _loc7_:String = null;
         var _loc8_:Boolean = false;
         var _loc9_:int = 0;
         var _loc2_:File = postsDirectory();
         if(!_loc2_.exists)
         {
            GWizUtils.LogError("Posts path does not exist!");
            if(param1)
            {
               param1.text = "No posts downloaded yet.";
            }
            return false;
         }
         var _loc3_:Array = _loc2_.getDirectoryListing();
         if(_loc3_.length <= 0)
         {
            return false;
         }
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc6_ = _loc3_[_loc4_];
            if((_loc7_ = GWizURLLoader.URLToFilename(_loc6_.url)).indexOf(".pst") >= 0)
            {
               (_loc5_ = new Object()).f = _loc6_;
               _loc5_.fname = _loc7_;
               posts.addItem(_loc5_);
               log.debug("Adding post " + _loc5_.fname + " to list.");
            }
            _loc4_++;
         }
         _loc2_ = GWizSettings.getPrefsFile();
         _loc3_ = _loc2_.getDirectoryListing();
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc6_ = _loc3_[_loc4_];
            if((_loc7_ = GWizURLLoader.URLToFilename(_loc6_.url)).indexOf(".pst") >= 0)
            {
               _loc8_ = false;
               _loc9_ = 0;
               while(_loc9_ < posts.length)
               {
                  _loc5_ = posts.getItemAt(_loc9_);
                  if(_loc7_ == _loc5_.fname)
                  {
                     _loc8_ = true;
                     break;
                  }
                  _loc9_++;
               }
               if(!_loc8_)
               {
                  (_loc5_ = new Object()).f = _loc6_;
                  _loc5_.fname = _loc7_;
                  posts.addItem(_loc5_);
                  log.debug("Adding user defined post " + _loc5_.fname + " to list.");
               }
            }
            _loc4_++;
         }
         return true;
      }
      
      public static function postsDirectory(param1:Boolean = true) : File
      {
         var _loc2_:String = "Posts/";
         var _loc3_:File = GWizSettings.getPrefsFile(_loc2_);
         if(GWizSettings.prefs.sharePrefs)
         {
            _loc3_ = new File(GWizSettings.prefs.sharingDir);
            _loc3_ = _loc3_.resolvePath(_loc2_);
         }
         if(param1 && !_loc3_.exists)
         {
            _loc3_ = null;
         }
         return _loc3_;
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizPostFileBrowser._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get posts() : ArrayCollection
      {
         return GWizPostFileBrowser._106855379posts;
      }
      
      public static function set posts(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizPostFileBrowser._106855379posts;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizPostFileBrowser,"posts",_loc2_,param1));
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
      
      private function onCC() : void
      {
         postsAvailable = initPostsList(this.Message);
      }
      
      private function onOKGuts(param1:Boolean) : void
      {
         if(param1 && this.handler != null && this.list.selectedItem)
         {
            this.handler(this.list.selectedItem.f);
         }
         super.close();
      }
      
      override public function onOk(param1:Event) : void
      {
         this.onOKGuts(true);
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.onOKGuts(false);
      }
      
      private function doMissingPost() : void
      {
         this.missingPost = GWizMissingPost(GWizPopUpManager.createPopUp(DisplayObject(this.parentApplication),GWizMissingPost,true));
         if(!this.missingPost)
         {
         }
      }
      
      private function _GWizPostFileBrowser_ClassFactory1_i() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizMissingPost;
         _loc1_.properties = {"outerDocument":this};
         this._GWizPostFileBrowser_ClassFactory1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizPostFileBrowser_ClassFactory1",this._GWizPostFileBrowser_ClassFactory1);
         return _loc1_;
      }
      
      private function _GWizPostFileBrowser_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizPostFileBrowser_Label1_i(),this._GWizPostFileBrowser_GWizBubbleTip1_i(),this._GWizPostFileBrowser_HGroup1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPostFileBrowser_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "Message";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Message = _loc1_;
         BindingManager.executeBindings(this,"Message",this.Message);
         return _loc1_;
      }
      
      private function _GWizPostFileBrowser_GWizBubbleTip1_i() : GWizBubbleTip
      {
         var _loc1_:GWizBubbleTip = new GWizBubbleTip();
         _loc1_.bubbleID = "PostList";
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizPostFileBrowser_DataGrid1_i()];
         _loc1_.id = "_GWizPostFileBrowser_GWizBubbleTip1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizPostFileBrowser_GWizBubbleTip1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizPostFileBrowser_GWizBubbleTip1",this._GWizPostFileBrowser_GWizBubbleTip1);
         return _loc1_;
      }
      
      private function _GWizPostFileBrowser_DataGrid1_i() : DataGrid
      {
         var _loc1_:DataGrid = new DataGrid();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.columns = this._GWizPostFileBrowser_ArrayCollection1_c();
         _loc1_.setStyle("color",0);
         _loc1_.id = "list";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.list = _loc1_;
         BindingManager.executeBindings(this,"list",this.list);
         return _loc1_;
      }
      
      private function _GWizPostFileBrowser_ArrayCollection1_c() : ArrayCollection
      {
         var _loc1_:ArrayCollection = new ArrayCollection();
         _loc1_.source = [this._GWizPostFileBrowser_GridColumn1_c()];
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizPostFileBrowser_GridColumn1_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Post Name";
         _loc1_.dataField = "fname";
         return _loc1_;
      }
      
      private function _GWizPostFileBrowser_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.horizontalAlign = "center";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizPostFileBrowser_Button1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizPostFileBrowser_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "My post isn\'t here!";
         _loc1_.toolTip = "Click here to request a post.";
         _loc1_.addEventListener("click",this.___GWizPostFileBrowser_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizPostFileBrowser_Button1_click(param1:MouseEvent) : void
      {
         this.doMissingPost();
      }
      
      public function ___GWizPostFileBrowser_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizPostFileBrowser_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():DisplayObject
         {
            return this;
         },null,"_GWizPostFileBrowser_GWizBubbleTip1.myWindow");
         result[1] = new Binding(this,function():IList
         {
            return posts;
         },null,"list.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Message() : Label
      {
         return this._1675388953Message;
      }
      
      public function set Message(param1:Label) : void
      {
         var _loc2_:Object = this._1675388953Message;
         if(_loc2_ !== param1)
         {
            this._1675388953Message = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Message",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get list() : DataGrid
      {
         return this._3322014list;
      }
      
      public function set list(param1:DataGrid) : void
      {
         var _loc2_:Object = this._3322014list;
         if(_loc2_ !== param1)
         {
            this._3322014list = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"list",_loc2_,param1));
            }
         }
      }
   }
}
