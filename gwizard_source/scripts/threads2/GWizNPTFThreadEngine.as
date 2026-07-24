package threads2
{
   import configinfo.GWizAbstractPrefs;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import mx.collections.ArrayCollection;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizNPTFThreadEngine extends GWizAbstractTaperThreadEngine
   {
      
      private static const log:ILogger = Log.getLogger("GWizNPTFThreadEngine");
      
      public static var NPTFStdSizes:ArrayCollection;
      
      private static var _166949130NPTFTapDrillList:ArrayCollection = new ArrayCollection([{
         "Size":"1/16 - 27",
         "TapDrill":0.242
      },{
         "Size":"1/8 - 27",
         "TapDrill":0.332
      },{
         "Size":"1/4 - 18",
         "TapDrill":0.438
      },{
         "Size":"3/8 - 18",
         "TapDrill":0.562
      },{
         "Size":"1/2 - 14",
         "TapDrill":0.703
      },{
         "Size":"3/4 - 14",
         "TapDrill":0.906
      },{
         "Size":"1 - 11.5",
         "TapDrill":1.141
      },{
         "Size":"1-1/4 - 11.5",
         "TapDrill":1.484
      },{
         "Size":"1-1/2 - 11.5",
         "TapDrill":1.719
      },{
         "Size":"2 - 11.5",
         "TapDrill":2.188
      },{
         "Size":"2-1/2 - 8",
         "TapDrill":2.609
      },{
         "Size":"3 - 8",
         "TapDrill":3.234
      }]);
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      public function GWizNPTFThreadEngine()
      {
         this.initPreferredThreads();
         super();
      }
      
      [Bindable(event="propertyChange")]
      public static function get NPTFTapDrillList() : ArrayCollection
      {
         return GWizNPTFThreadEngine._166949130NPTFTapDrillList;
      }
      
      public static function set NPTFTapDrillList(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizNPTFThreadEngine._166949130NPTFTapDrillList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizNPTFThreadEngine,"NPTFTapDrillList",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      public function initPreferredThreads() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         if(GWizAbstractPrefs.ThreadCalcEnabled)
         {
            if(!NPTFStdSizes)
            {
               NPTFStdSizes = new ArrayCollection();
               _loc1_ = 0;
               while(_loc1_ < GWizThreadDB.PipeThreadList.length)
               {
                  _loc2_ = GWizThreadDB.PipeThreadList.getItemAt(_loc1_);
                  _loc2_ = GWizUtils.clone(_loc2_);
                  if(_loc2_.Family == "NPT")
                  {
                     _loc2_.Family = "NPTF";
                  }
                  NPTFStdSizes.addItem(_loc2_);
                  _loc1_++;
               }
            }
            if(!PreferredThreads)
            {
               PreferredThreads = NPTFStdSizes;
            }
            else
            {
               PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,NPTFStdSizes);
            }
         }
      }
      
      override public function selectThread(param1:String, param2:String) : Boolean
      {
         var _loc3_:Boolean = super.selectThread(param1,param2);
         Reference = "ANSI B1.20.3 - 1976";
         SharpVHeight = 0.865881 * Pitch;
         Height = SharpVHeight - this.minTruncation(TPI,true) - this.minTruncation(TPI,false);
         MinHeight = SharpVHeight - this.maxTruncation(TPI,true) - this.maxTruncation(TPI,false);
         MinFlatAtCrest = GWizUtils.roundTenths(this.minFlatWidth(TPI,true));
         MaxFlatAtCrest = GWizUtils.roundTenths(this.maxFlatWidth(TPI,true));
         MinTruncation = GWizUtils.roundTenths(this.minTruncation(TPI,true));
         MaxTruncation = GWizUtils.roundTenths(this.maxTruncation(TPI,true));
         this.setTapDrillInfo(param1,param2);
         return true;
      }
      
      private function setTapDrillInfo(param1:String, param2:String) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(param1 == "NPTF")
         {
            _loc3_ = 0;
            while(_loc3_ < NPTFTapDrillList.length)
            {
               if((_loc4_ = NPTFTapDrillList.getItemAt(_loc3_)).Size == param2)
               {
                  TapDrill = _loc4_.TapDrill;
                  return;
               }
               _loc3_++;
            }
            TapDrill = NaN;
         }
      }
      
      private function minTruncation(param1:int, param2:Boolean) : Number
      {
         if(param2)
         {
            if(param1 > 18)
            {
               return 0.047 * Pitch;
            }
            if(param1 > 14)
            {
               return 0.047 * Pitch;
            }
            if(param1 > 11.5)
            {
               return 0.036 * Pitch;
            }
            if(param1 > 8)
            {
               return 0.04 * Pitch;
            }
            return 0.042 * Pitch;
         }
         if(param1 > 18)
         {
            return 0.094 * Pitch;
         }
         if(param1 > 14)
         {
            return 0.078 * Pitch;
         }
         if(param1 > 11.5)
         {
            return 0.06 * Pitch;
         }
         if(param1 > 8)
         {
            return 0.06 * Pitch;
         }
         return 0.055 * Pitch;
      }
      
      private function maxTruncation(param1:int, param2:Boolean) : Number
      {
         if(param2)
         {
            if(param1 > 18)
            {
               return 0.094 * Pitch;
            }
            if(param1 > 14)
            {
               return 0.078 * Pitch;
            }
            if(param1 > 11.5)
            {
               return 0.06 * Pitch;
            }
            if(param1 > 8)
            {
               return 0.06 * Pitch;
            }
            return 0.055 * Pitch;
         }
         if(param1 > 18)
         {
            return 0.14 * Pitch;
         }
         if(param1 > 14)
         {
            return 0.109 * Pitch;
         }
         if(param1 > 11.5)
         {
            return 0.085 * Pitch;
         }
         if(param1 > 8)
         {
            return 0.09 * Pitch;
         }
         return 0.076 * Pitch;
      }
      
      private function minFlatWidth(param1:int, param2:Boolean) : Number
      {
         if(param2)
         {
            if(param1 > 18)
            {
               return 0.054 * Pitch;
            }
            if(param1 > 14)
            {
               return 0.054 * Pitch;
            }
            if(param1 > 11.5)
            {
               return 0.042 * Pitch;
            }
            if(param1 > 8)
            {
               return 0.046 * Pitch;
            }
            return 0.048 * Pitch;
         }
         if(param1 > 18)
         {
            return 0.108 * Pitch;
         }
         if(param1 > 14)
         {
            return 0.09 * Pitch;
         }
         if(param1 > 11.5)
         {
            return 0.07 * Pitch;
         }
         if(param1 > 8)
         {
            return 0.069 * Pitch;
         }
         return 0.064 * Pitch;
      }
      
      private function maxFlatWidth(param1:int, param2:Boolean) : Number
      {
         if(param2)
         {
            if(param1 > 18)
            {
               return 0.108 * Pitch;
            }
            if(param1 > 14)
            {
               return 0.09 * Pitch;
            }
            if(param1 > 11.5)
            {
               return 0.07 * Pitch;
            }
            if(param1 > 8)
            {
               return 0.069 * Pitch;
            }
            return 0.064 * Pitch;
         }
         if(param1 > 18)
         {
            return 0.162 * Pitch;
         }
         if(param1 > 14)
         {
            return 0.126 * Pitch;
         }
         if(param1 > 11.5)
         {
            return 0.098 * Pitch;
         }
         if(param1 > 8)
         {
            return 0.103 * Pitch;
         }
         return 0.088 * Pitch;
      }
   }
}
