package notebook
{
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.StageWebView;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.ResizeEvent;
   import spark.components.VGroup;
   
   public class GWizNBWebPage extends VGroup
   {
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var webView:StageWebView;
      
      private var initialURL:String = "";
      
      public function GWizNBWebPage()
      {
         super();
         mx_internal::_document = this;
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.addEventListener("resize",this.___GWizNBWebPage_VGroup1_resize);
         this.addEventListener("removedFromStage",this.___GWizNBWebPage_VGroup1_removedFromStage);
         this.addEventListener("creationComplete",this.___GWizNBWebPage_VGroup1_creationComplete);
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
         this.webView = new StageWebView();
         this.webView.stage = this.stage;
         var _loc1_:Point = localToGlobal(new Point(0,0));
         this.webView.viewPort = new Rectangle(_loc1_.x,_loc1_.y,width,height);
         if(this.initialURL != "")
         {
            this.webView.loadURL(this.initialURL);
         }
      }
      
      public function setURL(param1:String) : void
      {
         var _loc2_:Point = null;
         if(param1.indexOf("http://") == -1)
         {
            param1 = "http://" + param1;
         }
         if(this.webView)
         {
            this.webView.stage = this.stage;
            _loc2_ = localToGlobal(new Point(0,0));
            this.webView.viewPort = new Rectangle(_loc2_.x,_loc2_.y,width,height);
            if(this.webView.location != param1)
            {
               this.webView.loadURL(param1);
            }
         }
         else
         {
            this.initialURL = param1;
         }
      }
      
      private function onResize() : void
      {
         var _loc1_:Point = null;
         if(this.webView)
         {
            _loc1_ = localToGlobal(new Point(0,0));
            this.webView.viewPort = new Rectangle(_loc1_.x,_loc1_.y,width,height);
         }
      }
      
      public function hideMe() : void
      {
         this.webView.stage = null;
      }
      
      public function ___GWizNBWebPage_VGroup1_resize(param1:ResizeEvent) : void
      {
         this.onResize();
      }
      
      public function ___GWizNBWebPage_VGroup1_removedFromStage(param1:Event) : void
      {
         this.hideMe();
      }
      
      public function ___GWizNBWebPage_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
   }
}
