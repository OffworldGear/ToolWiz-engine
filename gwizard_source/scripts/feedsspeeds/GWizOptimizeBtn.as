package feedsspeeds
{
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.events.MouseEvent;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import spark.components.Image;
   import tools.GWizToolData;
   import utils.GATracker;
   
   public class GWizOptimizeBtn extends Image
   {
      
      private static var _showOptimizeButtons:Boolean = true;
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var mode:String = "";
      
      public var logContext:String = "";
      
      private var _embed_mxml____assets_OptBtn_jpg_109696314:Class;
      
      public function GWizOptimizeBtn()
      {
         this._embed_mxml____assets_OptBtn_jpg_109696314 = GWizOptimizeBtn__embed_mxml____assets_OptBtn_jpg_109696314;
         super();
         this.source = this._embed_mxml____assets_OptBtn_jpg_109696314;
         this.width = 22;
         this.height = 22;
         this.addEventListener("click",this.___GWizOptimizeBtn_Image1_click);
         this.addEventListener("creationComplete",this.___GWizOptimizeBtn_Image1_creationComplete);
      }
      
      public static function get showOptimizeButtons() : Boolean
      {
         return _showOptimizeButtons;
      }
      
      public static function set showOptimizeButtons(param1:Boolean) : void
      {
         param1 = true;
         _showOptimizeButtons = param1;
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
         showOptimizeButtons = showOptimizeButtons;
         this.visible = !GWizAbstractPrefs.isOEM;
      }
      
      public function optimize() : void
      {
         var _loc1_:GWizToolData = null;
         var _loc2_:GWizDeflectMath = null;
         if(this.mode != "" && GWizSettings.FeedsSpeedsApp && this.logContext != "")
         {
            GATracker.logPageView(this.logContext,this.logContext);
            _loc1_ = GWizSettings.FeedsSpeedsApp.td.toolParms;
            _loc2_ = new GWizDeflectMath();
            _loc2_.optimizeMode(this.mode,_loc1_.stickout,_loc1_.toolDiam);
         }
      }
      
      public function ___GWizOptimizeBtn_Image1_click(param1:MouseEvent) : void
      {
         this.optimize();
      }
      
      public function ___GWizOptimizeBtn_Image1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
   }
}
