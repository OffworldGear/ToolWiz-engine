package comps
{
   public class GWizDataGridConfigColumn
   {
       
      
      private var _configId:String = null;
      
      private var _hasSort:Boolean = false;
      
      private var _sortDescending:Boolean = true;
      
      private var _visible:Boolean = true;
      
      private var _width:Number = NaN;
      
      public function GWizDataGridConfigColumn()
      {
         super();
      }
      
      public static function fromColumnConfigStr(param1:String) : GWizDataGridConfigColumn
      {
         var _loc2_:GWizDataGridConfigColumn = new GWizDataGridConfigColumn();
         _loc2_.parseColConfig(param1);
         return _loc2_;
      }
      
      private function parseColConfig(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc2_:Array = param1.split("=");
         this.configId = _loc2_[0];
         _loc3_ = _loc2_[1];
         var _loc4_:String;
         if((_loc4_ = _loc3_.substr(_loc3_.length - 1,1)) == "a" || _loc4_ == "d")
         {
            this.sortDescending = _loc4_ == "d";
            _loc3_ = _loc3_.substr(0,_loc3_.length - 1);
         }
         this.visible = true;
         if(_loc3_.charAt(0) == "-")
         {
            this.visible = false;
            _loc3_ = _loc3_.substr(1);
         }
         this.width = _loc3_ == "NaN" ? (Number(this.width = NaN)) : (Number(this.width = int(_loc3_)));
      }
      
      public function get configId() : String
      {
         return this._configId;
      }
      
      public function set configId(param1:String) : void
      {
         this._configId = param1;
      }
      
      public function get hasSort() : Boolean
      {
         return this._hasSort;
      }
      
      public function set hasSort(param1:Boolean) : void
      {
         this._hasSort = param1;
      }
      
      public function get sortDescending() : Boolean
      {
         this.hasSort = true;
         return this._sortDescending;
      }
      
      public function set sortDescending(param1:Boolean) : void
      {
         this.hasSort = true;
         this._sortDescending = param1;
      }
      
      public function get visible() : Boolean
      {
         return this._visible;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this._visible = param1;
      }
      
      public function get width() : Number
      {
         return this._width;
      }
      
      public function set width(param1:Number) : void
      {
         this._width = param1;
      }
   }
}
