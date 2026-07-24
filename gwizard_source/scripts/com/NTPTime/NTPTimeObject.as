package com.NTPTime
{
   import flash.utils.ByteArray;
   
   public class NTPTimeObject
   {
       
      
      public var leapIndicator:uint = 0;
      
      public var version:uint = 3;
      
      public var mode:uint = 0;
      
      public var stratum:uint = 0;
      
      public var pollInterval:uint = 0;
      
      public var precision:uint = 0;
      
      public var rootDelay:Number = 0;
      
      public var rootDispersion:Number = 0;
      
      public var referenceIdentifier:String = "";
      
      public var referenceTimestamp:Number = 0;
      
      public var originateTimestamp:Number = 0;
      
      public var receiveTimestamp:Number = 0;
      
      public var transmitTimestamp:Number = 0;
      
      private var hasBeenPopulated:Boolean = false;
      
      public function NTPTimeObject()
      {
         super();
      }
      
      public function createNTPRequest() : ByteArray
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc1_:ByteArray = new ByteArray();
         this.mode = 3;
         var _loc2_:Date = new Date(1900,0,1,0,0,0,0);
         var _loc3_:Date = new Date();
         this.transmitTimestamp = _loc3_.valueOf() / 1000 + _loc2_.valueOf() / 1000 * -1;
         if(this.hasBeenPopulated == false)
         {
            _loc1_.writeByte(this.leapIndicator << 6 | this.version << 3 | this.mode);
            _loc1_.writeByte(this.stratum);
            _loc1_.writeByte(this.pollInterval);
            _loc1_.writeByte(this.precision);
            _loc4_ = int(this.rootDelay * 65536);
            _loc1_.writeByte(_loc4_ >> 24 & 255);
            _loc1_.writeByte(_loc4_ >> 16 & 255);
            _loc1_.writeByte(_loc4_ >> 8 & 255);
            _loc1_.writeByte(_loc4_ & 255);
            _loc5_ = int(this.rootDispersion * 65536);
            _loc1_.writeByte(_loc5_ >> 24 & 255);
            _loc1_.writeByte(_loc5_ >> 16 & 255);
            _loc1_.writeByte(_loc5_ >> 8 & 255);
            _loc1_.writeByte(_loc5_ & 255);
            _loc1_.writeByte(0);
            _loc1_.writeByte(0);
            _loc1_.writeByte(0);
            _loc1_.writeByte(0);
            this.encodeTimestamp(_loc1_,16,this.referenceTimestamp);
            this.encodeTimestamp(_loc1_,24,this.originateTimestamp);
            this.encodeTimestamp(_loc1_,32,this.receiveTimestamp);
            this.encodeTimestamp(_loc1_,40,this.transmitTimestamp);
            return _loc1_;
         }
         throw new Error("You can only create a request before the object is populated");
      }
      
      public function populateObjectFromBA(param1:ByteArray) : void
      {
         var _loc2_:ByteArray = null;
         if(param1.length == 48)
         {
            this.leapIndicator = param1[0] >> 6 & 3;
            this.version = param1[0] >> 3 & 7;
            this.mode = param1[0] & 7;
            this.stratum = param1[1];
            this.pollInterval = param1[2];
            this.precision = param1[3];
            this.rootDelay = param1[4] * 256 + param1[5] + param1[6] / 256 + param1[7] / 65536;
            this.rootDispersion = param1[8] * 256 + param1[9] + param1[10] / 256 + param1[11] / 65536;
            _loc2_ = new ByteArray();
            param1.position = 12;
            _loc2_.writeByte(param1.readByte());
            _loc2_.writeByte(param1.readByte());
            _loc2_.writeByte(param1.readByte());
            _loc2_.writeByte(param1.readByte());
            _loc2_.position = 0;
            this.referenceIdentifier = _loc2_.readUTFBytes(4);
            this.referenceTimestamp = this.decodeTimestamp(param1,16);
            this.originateTimestamp = this.decodeTimestamp(param1,24);
            this.receiveTimestamp = this.decodeTimestamp(param1,32);
            this.transmitTimestamp = this.decodeTimestamp(param1,40);
            this.hasBeenPopulated = true;
         }
      }
      
      public function getLocalizedTimeserverDate() : Date
      {
         var _loc2_:Number = NaN;
         var _loc1_:Date = null;
         if(this.hasBeenPopulated == true)
         {
            _loc2_ = this.referenceTimestamp * 1000 - 2208988800000;
            return new Date(_loc2_);
         }
         throw new Error("You must first populate the data using populateObjectFromBA");
      }
      
      private function decodeTimestamp(param1:ByteArray, param2:int) : Number
      {
         var _loc3_:Number = 0;
         var _loc4_:int = 0;
         while(_loc4_ < 8)
         {
            _loc3_ += param1[param2 + _loc4_] * Math.pow(2,(3 - _loc4_) * 8);
            _loc4_++;
         }
         return _loc3_;
      }
      
      private function encodeTimestamp(param1:ByteArray, param2:int, param3:Number) : void
      {
         var _loc5_:Number = NaN;
         var _loc4_:int = 0;
         while(_loc4_ < 8)
         {
            _loc5_ = Math.pow(2,(3 - _loc4_) * 8);
            param1.writeByte(param3 / _loc5_);
            param3 -= Number(int(param1[param2 + _loc4_]) * _loc5_);
            _loc4_++;
         }
      }
   }
}
