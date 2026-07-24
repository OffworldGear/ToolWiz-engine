package localdb
{
   import machines.GWizMachSettings;
   
   public class GWizCutKB
   {
       
      
      public var id:int = -1;
      
      public var mrr:Number;
      
      public var mrrPct:Number;
      
      public var rpm:Number;
      
      public var rpmPct:Number;
      
      public var ipm:Number;
      
      public var ipmPct:Number;
      
      public var sfm:Number;
      
      public var sfmPct:Number;
      
      public var ipt:Number;
      
      public var iptPct:Number;
      
      public var machine:String = "";
      
      public var tool:String = "";
      
      public var crib:String = "";
      
      public var toolDia:Number;
      
      public var flutes:int;
      
      public var geometry:String;
      
      public var rougher:Boolean;
      
      public var stickout:Number;
      
      public var leadAng:int;
      
      public var noseRad:Number;
      
      public var material:int;
      
      public var hardness:int;
      
      public var cutDepth:Number;
      
      public var cutWidth:Number;
      
      public var tea:int;
      
      public var description:String = "";
      
      public var rating:int;
      
      public var comments:String = "";
      
      public var wear:int;
      
      public var chatter:int;
      
      public var cutType:int;
      
      public var rough:Boolean;
      
      public var holder:int;
      
      public var coolant:int;
      
      public function GWizCutKB()
      {
         super();
      }
      
      public static function encodeCutType(param1:int, param2:String) : int
      {
         var _loc3_:Object = GWizMachSettings.lookupMachine(param2);
         if(_loc3_ && _loc3_.type == "Lathe")
         {
            param1 = -param1;
         }
         return param1;
      }
   }
}
