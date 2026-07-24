package utils
{
   import mx.collections.ArrayCollection;
   import mx.collections.SortField;
   import spark.collections.Sort;
   
   public class SequencedArrayCollection extends ArrayCollection
   {
       
      
      private var numericDataSort:Sort;
      
      private var markedItems:Array;
      
      public function SequencedArrayCollection(param1:ArrayCollection = null, param2:String = "Seq")
      {
         this.markedItems = [];
         super(null);
         this.addAC(param1);
         var _loc3_:SortField = new SortField();
         _loc3_.name = param2;
         _loc3_.numeric = param2 == "Seq";
         this.numericDataSort = new Sort();
         this.numericDataSort.fields = [_loc3_];
         this.sort = this.numericDataSort;
         this.refresh();
      }
      
      public function addAC(param1:ArrayCollection) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(param1)
         {
            _loc2_ = 0;
            while(_loc2_ < param1.length)
            {
               _loc3_ = param1.getItemAt(_loc2_);
               this.addItem(_loc3_);
               _loc2_++;
            }
         }
      }
      
      override public function addItem(param1:Object) : void
      {
         param1.Seq = this.length + 1;
         super.addItem(param1);
      }
      
      override public function addItemAt(param1:Object, param2:int) : void
      {
         var _loc4_:Object = null;
         if(param2 < 0)
         {
            param2 = this.length - 1;
         }
         param2 = Math.min(param2,this.length);
         param1.Seq = param2 + 1;
         var _loc3_:int = param2;
         while(_loc3_ < this.length)
         {
            (_loc4_ = this.getItemAt(_loc3_)).Seq = param1.Seq + 1;
            _loc3_++;
         }
         super.addItemAt(param1,param2);
      }
      
      override public function removeAll() : void
      {
         super.removeAll();
      }
      
      public function MoveUp(param1:int) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         if(param1 > 0 && param1 < this.length)
         {
            _loc2_ = this.getItemAt(param1);
            _loc3_ = this.getItemAt(param1 - 1);
            _loc4_ = _loc3_.Seq;
            _loc3_.Seq = _loc2_.Seq;
            _loc2_.Seq = _loc4_;
            this.refresh();
         }
      }
      
      public function MoveDown(param1:int) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         if(param1 >= 0 && param1 < this.length - 1)
         {
            _loc2_ = this.getItemAt(param1);
            _loc3_ = this.getItemAt(param1 + 1);
            _loc4_ = _loc3_.Seq;
            _loc3_.Seq = _loc2_.Seq;
            _loc2_.Seq = _loc4_;
            this.refresh();
         }
      }
      
      public function Delete(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(param1 > 0)
         {
            this.removeItemAt(param1);
            _loc2_ = 0;
            while(_loc2_ < this.length)
            {
               _loc3_ = this.getItemAt(_loc2_);
               _loc3_.Seq = _loc2_ + 1;
               _loc2_++;
            }
            this.refresh();
         }
      }
      
      public function MarkItem(param1:int) : void
      {
         this.markedItems.push(this.getItemAt(param1));
      }
      
      public function DelMarkedItems() : void
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         while(this.markedItems.length > 0)
         {
            _loc1_ = this.markedItems.pop();
            _loc2_ = 0;
            while(_loc2_ < this.length)
            {
               if(this.getItemAt(_loc2_) == _loc1_)
               {
                  this.removeItemAt(_loc2_);
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public function UnMarkAll() : void
      {
         this.markedItems = [];
      }
   }
}
