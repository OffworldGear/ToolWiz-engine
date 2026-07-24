package feedsspeeds
{
   import mx.core.IFlexModuleFactory;
   import spark.components.Group;
   import utils.GWizUtils;
   
   public class GWizTEADiagram extends Group
   {
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private const Y_OFFSET:Number = 5.0;
      
      private var bgColor:uint = 6986440;
      
      private var borderColor:uint = 6710886;
      
      private var borderSize:uint = 0;
      
      private var cornerRadius:uint = 9;
      
      public function GWizTEADiagram()
      {
         super();
         mx_internal::_document = this;
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
      
      public function drawDiagram(param1:Number, param2:Number, param3:Number) : void
      {
         graphics.clear();
         graphics.lineStyle(3,10027008,1);
         graphics.moveTo(this.width / 2 - this.height / 2,this.height / 2 + this.Y_OFFSET);
         graphics.lineTo(this.width / 2,this.height / 2 + this.Y_OFFSET);
         var _loc4_:Number = -(_loc4_ = this.height / 2 * Math.cos(GWizUtils.radians(param1)));
         var _loc5_:Number = -(_loc5_ = this.height / 2 * Math.sin(GWizUtils.radians(param1)));
         graphics.lineTo(_loc4_ + this.width / 2,_loc5_ + this.height / 2 + this.Y_OFFSET);
         this.drawCircle(param3 / param2,param1);
      }
      
      private function drawCircle(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = Math.round(this.height / 4 / 2);
         param1 = Math.min(1,param1) - 0.5;
         param1 = param1 * _loc3_ * 2;
         graphics.beginFill(this.bgColor,0.6);
         graphics.lineStyle(this.borderSize,this.borderColor);
         var _loc4_:Number = param1 * Math.cos(GWizUtils.radians(param2 / 2));
         var _loc5_:Number = param1 * Math.sin(GWizUtils.radians(param2 / 2));
         graphics.drawCircle(this.width / 2 + _loc4_,this.height / 2 + _loc5_ + this.Y_OFFSET,_loc3_);
         graphics.endFill();
      }
   }
}
