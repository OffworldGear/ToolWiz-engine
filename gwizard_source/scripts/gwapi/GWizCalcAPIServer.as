package gwapi
{
   import comps.GWizLogWindow;
   import flash.net.Socket;
   import utils.GWizJustASec;
   
   public class GWizCalcAPIServer extends GWizAbstractAPIServer
   {
      
      public static const SELECT_TAB:String = "selectTab";
      
      public static const SELECT_CADCAM:String = "selectCADCAM";
      
      public static const RECALC_CADCAM:String = "recalcCADCAM";
      
      public static const SET_CCFM_DEPTH:String = "setCCFMDepth";
      
      public static const GET_CC_FIELD:String = "getCADCAMField";
      
      public static const FIELD_TOOLDIA:String = "ToolDiameter";
      
      public static const FIELD_CUTWIDTH:String = "CutWidth";
      
      public static const FIELD_CUTDEPTH:String = "CutDepth";
      
      public static const FIELD_RPM:String = "RPM";
      
      public static const FIELD_FEEDRATE:String = "Feedrate";
      
      public static const FIELD_PLUNGE:String = "Plunge";
      
      public static const DONE:String = "DONE";
      
      public static const ERROR:String = "ERROR";
      
      public static var selectTabFcn:Function;
      
      public static var selectCADCAM:Function;
      
      public static var recalcCADCAM:Function;
      
      public static var setCCFMDepth:Function;
      
      public static var getCCField:Function;
      
      public static const API_PORT:int = 1337;
      
      public static var apiServer:GWizAbstractAPIServer = null;
      
      private static var wait4Socket:Socket;
      
      private static var wait4Id:String;
      
      private static var wait4Arg:String;
       
      
      public function GWizCalcAPIServer()
      {
         super(API_PORT);
      }
      
      override public function dispatchIncoming(param1:Socket, param2:String, param3:String) : void
      {
         GWizLogWindow.write("Request: " + param2 + ", arg = " + param3 + "\n");
         switch(param2)
         {
            case SELECT_TAB:
               if(selectTabFcn != null)
               {
                  selectTabFcn(param3);
                  this.dispatchResponse(param1,param2,DONE);
               }
               else
               {
                  this.wait4API(param1,param2,param3);
               }
               break;
            case SELECT_CADCAM:
               if(selectCADCAM != null)
               {
                  selectCADCAM(param3);
                  this.dispatchResponse(param1,param2,DONE);
               }
               else
               {
                  this.wait4API(param1,param2,param3);
               }
               break;
            case RECALC_CADCAM:
               if(recalcCADCAM != null)
               {
                  recalcCADCAM();
                  this.dispatchResponse(param1,param2,DONE);
               }
               else
               {
                  this.wait4API(param1,param2,param3);
               }
               break;
            case SET_CCFM_DEPTH:
               if(setCCFMDepth != null)
               {
                  setCCFMDepth(param3);
                  this.dispatchResponse(param1,param2,DONE);
               }
               else
               {
                  this.wait4API(param1,param2,param3);
               }
               break;
            case GET_CC_FIELD:
               if(getCCField != null && getCCField("Test") != "")
               {
                  this.dispatchResponse(param1,param2,param3 + "=" + getCCField(param3));
               }
               else
               {
                  this.wait4API(param1,param2,param3);
               }
               break;
            default:
               super.dispatchIncoming(param1,param2,param3);
         }
      }
      
      private function wait4API(param1:Socket, param2:String, param3:String) : void
      {
         wait4Socket = param1;
         wait4Id = param2;
         wait4Arg = param3;
         var _loc4_:GWizJustASec = new GWizJustASec(this.dispatchIncomingAux);
      }
      
      private function dispatchIncomingAux() : void
      {
         this.dispatchIncoming(wait4Socket,wait4Id,wait4Arg);
      }
      
      override public function dispatchResponse(param1:Socket, param2:String, param3:String) : void
      {
         GWizLogWindow.write("Response: " + param2 + ", arg = " + param3 + "\n");
         GWizLogWindow.write("***************************************\n");
         super.dispatchResponse(param1,param2,param3);
      }
   }
}
