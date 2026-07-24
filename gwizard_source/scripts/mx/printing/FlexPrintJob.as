package mx.printing
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.geom.Rectangle;
   import flash.printing.PrintJob;
   import flash.printing.PrintJobOptions;
   import mx.core.FlexVersion;
   import mx.core.IFlexDisplayObject;
   import mx.core.IUIComponent;
   import mx.core.UIComponent;
   import mx.core.UIComponentGlobals;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class FlexPrintJob
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var printJob:PrintJob;
      
      private var _pageHeight:Number = 0;
      
      private var _pageWidth:Number = 0;
      
      private var _printAsBitmap:Boolean = true;
      
      public function FlexPrintJob()
      {
         this.printJob = new PrintJob();
         super();
      }
      
      public function get pageHeight() : Number
      {
         return this._pageHeight;
      }
      
      public function get pageWidth() : Number
      {
         return this._pageWidth;
      }
      
      public function get printAsBitmap() : Boolean
      {
         return this._printAsBitmap;
      }
      
      public function set printAsBitmap(param1:Boolean) : void
      {
         this._printAsBitmap = param1;
      }
      
      public function start() : Boolean
      {
         var _loc1_:Boolean = this.printJob.start();
         if(_loc1_)
         {
            this._pageWidth = this.printJob.pageWidth;
            this._pageHeight = this.printJob.pageHeight;
         }
         return _loc1_;
      }
      
      public function addObject(param1:IUIComponent, param2:String = "matchWidth") : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:IFlexDisplayObject = null;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc26_:Rectangle = null;
         var _loc27_:PrintJobOptions = null;
         var _loc28_:Object = null;
         var _loc11_:Object = {};
         var _loc14_:Class = Class(param1.systemManager.getDefinitionByName("mx.core::Application"));
         var _loc15_:Class = Class(param1.systemManager.getDefinitionByName("spark.components::Application"));
         if(_loc14_ && param1 is _loc14_ || _loc15_ && param1 is _loc15_)
         {
            _loc7_ = param1["numElements"];
            _loc8_ = 0;
            while(_loc8_ < _loc7_)
            {
               if((_loc10_ = IFlexDisplayObject(param1["getElementAt"](_loc8_))) is UIComponent && (!isNaN(UIComponent(_loc10_).percentWidth) || !isNaN(UIComponent(_loc10_).percentHeight)))
               {
                  _loc11_[_loc10_.name] = {};
                  if(!isNaN(UIComponent(_loc10_).percentWidth) && isNaN(UIComponent(_loc10_).explicitWidth))
                  {
                     _loc11_[_loc10_.name].percentWidth = UIComponent(_loc10_).percentWidth;
                     UIComponent(_loc10_).percentWidth = NaN;
                     UIComponent(_loc10_).explicitWidth = UIComponent(_loc10_).width;
                  }
                  if(!isNaN(UIComponent(_loc10_).percentHeight) && isNaN(UIComponent(_loc10_).explicitHeight))
                  {
                     _loc11_[_loc10_.name].percentHeight = UIComponent(_loc10_).percentHeight;
                     UIComponent(_loc10_).percentHeight = NaN;
                     UIComponent(_loc10_).explicitHeight = UIComponent(_loc10_).height;
                  }
               }
               _loc8_++;
            }
            if(!isNaN(UIComponent(param1).explicitWidth) && !isNaN(UIComponent(param1).explicitHeight))
            {
               _loc12_ = UIComponent(param1).explicitWidth;
               _loc13_ = UIComponent(param1).explicitHeight;
               UIComponent(param1).explicitWidth = NaN;
               UIComponent(param1).explicitHeight = NaN;
               UIComponent(param1).measuredWidth = _loc12_;
               UIComponent(param1).measuredHeight = _loc13_;
            }
            if(isNaN(param1.percentWidth) && isNaN(param1.percentHeight))
            {
               UIComponent(param1).invalidateSizeFlag = false;
            }
            UIComponent(param1).validateSize();
            _loc3_ = param1.measuredWidth;
            _loc4_ = param1.measuredHeight;
            if(FlexVersion.compatibilityVersion >= FlexVersion.VERSION_4_0)
            {
               _loc3_ *= param1.scaleX;
               _loc4_ *= param1.scaleY;
            }
         }
         else
         {
            if(!isNaN(param1.percentWidth) && isNaN(param1.explicitWidth))
            {
               _loc5_ = param1.percentWidth;
               param1.percentWidth = NaN;
               param1.explicitWidth = param1.width;
            }
            if(!isNaN(param1.percentHeight) && isNaN(param1.explicitHeight))
            {
               _loc6_ = param1.percentHeight;
               param1.percentHeight = NaN;
               param1.explicitHeight = param1.height;
            }
            _loc3_ = param1.getExplicitOrMeasuredWidth();
            _loc4_ = param1.getExplicitOrMeasuredHeight();
            if(FlexVersion.compatibilityVersion >= FlexVersion.VERSION_4_0)
            {
               _loc3_ *= param1.scaleX;
               _loc4_ *= param1.scaleY;
            }
         }
         var _loc16_:Number = this._pageWidth / _loc3_;
         var _loc17_:Number = this._pageHeight / _loc4_;
         var _loc18_:Number = 1;
         if(param2 == FlexPrintJobScaleType.SHOW_ALL)
         {
            _loc18_ = _loc16_ < _loc17_ ? Number(_loc16_) : Number(_loc17_);
         }
         else if(param2 == FlexPrintJobScaleType.FILL_PAGE)
         {
            _loc18_ = _loc16_ > _loc17_ ? Number(_loc16_) : Number(_loc17_);
         }
         else if(param2 != FlexPrintJobScaleType.NONE)
         {
            if(param2 == FlexPrintJobScaleType.MATCH_HEIGHT)
            {
               _loc18_ = _loc17_;
            }
            else
            {
               _loc18_ = _loc16_;
            }
         }
         param1.scaleX *= _loc18_;
         param1.scaleY *= _loc18_;
         UIComponentGlobals.layoutManager.usePhasedInstantiation = false;
         UIComponentGlobals.layoutManager.validateNow();
         var _loc19_:Array = this.prepareToPrintObject(param1);
         if(_loc14_ && param1 is _loc14_ || _loc15_ && param1 is _loc15_)
         {
            _loc3_ *= _loc18_;
            _loc4_ *= _loc18_;
         }
         else
         {
            _loc3_ = param1.getExplicitOrMeasuredWidth();
            _loc4_ = param1.getExplicitOrMeasuredHeight();
            if(FlexVersion.compatibilityVersion >= FlexVersion.VERSION_4_0)
            {
               _loc3_ *= param1.scaleX;
               _loc4_ *= param1.scaleY;
            }
         }
         var _loc20_:int = Math.ceil(_loc3_ / this._pageWidth);
         var _loc21_:int = Math.ceil(_loc4_ / this._pageHeight);
         var _loc22_:Number = this._pageWidth / _loc18_;
         var _loc23_:Number = this._pageHeight / _loc18_;
         var _loc24_:Number = _loc3_ % this._pageWidth / _loc18_;
         var _loc25_:Number = _loc4_ % this._pageHeight / _loc18_;
         _loc9_ = 0;
         while(_loc9_ < _loc21_)
         {
            _loc8_ = 0;
            while(_loc8_ < _loc20_)
            {
               _loc26_ = new Rectangle(_loc8_ * _loc22_,_loc9_ * _loc23_,_loc22_,_loc23_);
               if(_loc8_ == _loc20_ - 1 && _loc24_ != 0)
               {
                  _loc26_.width = _loc24_;
               }
               if(_loc9_ == _loc21_ - 1 && _loc25_ != 0)
               {
                  _loc26_.height = _loc25_;
               }
               _loc26_.width = Math.ceil(_loc26_.width);
               _loc26_.height = Math.ceil(_loc26_.height);
               (_loc27_ = new PrintJobOptions()).printAsBitmap = this._printAsBitmap;
               this.printJob.addPage(Sprite(param1),_loc26_,_loc27_);
               _loc8_++;
            }
            _loc9_++;
         }
         this.finishPrintObject(param1,_loc19_);
         param1.scaleX /= _loc18_;
         param1.scaleY /= _loc18_;
         if(_loc14_ && param1 is _loc14_ || _loc15_ && param1 is _loc15_)
         {
            if(!isNaN(_loc12_))
            {
               UIComponent(param1).setActualSize(_loc12_,_loc13_);
               if(!param1.systemManager.isTopLevelRoot())
               {
                  UIComponent(param1).explicitWidth = _loc12_;
                  UIComponent(param1).explicitHeight = _loc13_;
               }
               _loc12_ = NaN;
               _loc13_ = NaN;
               UIComponent(param1).measuredWidth = 0;
               UIComponent(param1).measuredHeight = 0;
            }
            _loc7_ = param1["numElements"];
            _loc8_ = 0;
            while(_loc8_ < _loc7_)
            {
               if((_loc10_ = IFlexDisplayObject(param1["getElementAt"](_loc8_))) is UIComponent && _loc11_[_loc10_.name])
               {
                  if((_loc28_ = _loc11_[_loc10_.name]) && !isNaN(_loc28_.percentWidth))
                  {
                     UIComponent(_loc10_).percentWidth = _loc28_.percentWidth;
                     UIComponent(_loc10_).explicitWidth = NaN;
                  }
                  if(_loc28_ && !isNaN(_loc28_.percentHeight))
                  {
                     UIComponent(_loc10_).percentHeight = _loc28_.percentHeight;
                     UIComponent(_loc10_).explicitHeight = NaN;
                  }
               }
               _loc8_++;
            }
            UIComponent(param1).invalidateSizeFlag = false;
            UIComponent(param1).validateSize();
         }
         else
         {
            if(!isNaN(_loc5_))
            {
               param1.percentWidth = _loc5_;
               param1.explicitWidth = NaN;
            }
            if(!isNaN(_loc6_))
            {
               param1.percentHeight = _loc6_;
               param1.explicitHeight = NaN;
            }
         }
         UIComponentGlobals.layoutManager.usePhasedInstantiation = false;
         UIComponentGlobals.layoutManager.validateNow();
      }
      
      public function send() : void
      {
         this.printJob.send();
      }
      
      private function prepareToPrintObject(param1:IUIComponent) : Array
      {
         var _loc2_:Array = [];
         var _loc3_:DisplayObject = param1 is DisplayObject ? DisplayObject(param1) : null;
         var _loc4_:Number = 0;
         while(_loc3_)
         {
            if(_loc3_ is UIComponent)
            {
               var _loc5_:*;
               _loc2_[_loc5_ = _loc4_++] = UIComponent(_loc3_).prepareToPrint(UIComponent(param1));
            }
            else if(_loc3_ is DisplayObject && !(_loc3_ is Stage))
            {
               _loc2_[_loc5_ = _loc4_++] = DisplayObject(_loc3_).mask;
               DisplayObject(_loc3_).mask = null;
            }
            _loc3_ = _loc3_.parent is DisplayObject ? DisplayObject(_loc3_.parent) : null;
         }
         return _loc2_;
      }
      
      private function finishPrintObject(param1:IUIComponent, param2:Array) : void
      {
         var _loc3_:DisplayObject = param1 is DisplayObject ? DisplayObject(param1) : null;
         var _loc4_:Number = 0;
         while(_loc3_)
         {
            if(_loc3_ is UIComponent)
            {
               UIComponent(_loc3_).finishPrint(param2[_loc4_++],UIComponent(param1));
            }
            else if(_loc3_ is DisplayObject && !(_loc3_ is Stage))
            {
               DisplayObject(_loc3_).mask = param2[_loc4_++];
            }
            _loc3_ = _loc3_.parent is DisplayObject ? DisplayObject(_loc3_.parent) : null;
         }
      }
   }
}
