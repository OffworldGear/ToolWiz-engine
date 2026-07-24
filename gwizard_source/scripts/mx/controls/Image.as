package mx.controls
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import mx.controls.listClasses.BaseListData;
   import mx.controls.listClasses.IDropInListItemRenderer;
   import mx.controls.listClasses.IListItemRenderer;
   import mx.core.IDataRenderer;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   
   use namespace mx_internal;
   
   public class Image extends SWFLoader implements IDataRenderer, IDropInListItemRenderer, IListItemRenderer
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var makeContentVisible:Boolean = false;
      
      private var sourceSet:Boolean;
      
      private var settingBrokenImage:Boolean;
      
      private var _data:Object;
      
      private var _listData:BaseListData;
      
      public function Image()
      {
         super();
         tabChildren = false;
         tabEnabled = true;
         tabFocusEnabled = true;
         showInAutomationHierarchy = true;
      }
      
      [Bindable("sourceChanged")]
      override public function set source(param1:Object) : void
      {
         this.settingBrokenImage = param1 == getStyle("brokenImageSkin");
         this.sourceSet = !this.settingBrokenImage;
         super.source = param1;
      }
      
      [Bindable("dataChange")]
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
         if(!this.sourceSet)
         {
            this.source = !!this.listData ? this.listData.label : this.data;
            this.sourceSet = false;
         }
         dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
      }
      
      [Bindable("dataChange")]
      public function get listData() : BaseListData
      {
         return this._listData;
      }
      
      public function set listData(param1:BaseListData) : void
      {
         this._listData = param1;
      }
      
      override public function invalidateSize() : void
      {
         if(this.data && this.settingBrokenImage)
         {
            return;
         }
         super.invalidateSize();
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         if(this.makeContentVisible && mx_internal::contentHolder)
         {
            mx_internal::contentHolder.visible = true;
            this.makeContentVisible = false;
         }
      }
      
      override mx_internal function contentLoaderInfo_completeEventHandler(param1:Event) : void
      {
         var _loc2_:DisplayObject = DisplayObject(param1.target.loader);
         super.contentLoaderInfo_completeEventHandler(param1);
         _loc2_.visible = false;
         this.makeContentVisible = true;
         invalidateDisplayList();
      }
   }
}
