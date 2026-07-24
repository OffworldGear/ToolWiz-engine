package mx.rpc.xml
{
   dynamic class ComplexString
   {
       
      
      public var value:String;
      
      function ComplexString(param1:String)
      {
         super();
         this.value = param1;
      }
      
      public function toString() : String
      {
         return this.value;
      }
      
      public function valueOf() : Object
      {
         return SimpleXMLDecoder.simpleType(this.value);
      }
   }
}
