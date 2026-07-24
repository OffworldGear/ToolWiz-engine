package gwapi
{
   import comps.GWizLogWindow;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.ProgressEvent;
   import flash.events.ServerSocketConnectEvent;
   import flash.net.ServerSocket;
   import flash.net.Socket;
   import mx.collections.ArrayCollection;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizAbstractAPIServer implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizAbstractAPIServer");
      
      public static const DEFAULT_PORT:int = 1337;
      
      public static const ADDRESS:String = "127.0.0.1";
      
      public static const STR_DELIM:String = "!";
      
      public static const API_VERSION:Number = 0.1;
      
      public static const GET_API_VERSION:String = "GetAPIVersion";
      
      private static var onlyOne:Boolean = false;
       
      
      private var socket:ServerSocket;
      
      private var _1618433771clientSockets:ArrayCollection;
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizAbstractAPIServer(param1:int = 1337)
      {
         this.socket = new ServerSocket();
         this._1618433771clientSockets = new ArrayCollection();
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
         this.createServer(null,param1);
         if(GWizUtils.debug)
         {
            GWizLogWindow.newLogWindow();
         }
      }
      
      public function shutdown() : void
      {
         GWizUtils.LogError("Top of GWizCalcAPIServer.apiServer.shutdown()\n");
         try
         {
            if(this.socket)
            {
               GWizUtils.LogError("GWizCalcAPIServer.apiServer.shutdown(), about to socket.close()\n");
               this.socket.close();
            }
            else
            {
               GWizUtils.LogError("GWizCalcAPIServer.apiServer.shutdown(): no socket.\n");
            }
         }
         catch(e:Error)
         {
            GWizUtils.LogError("GWizCalcAPIServer.apiServer.shutdown(): Threw an exception.\n");
         }
         GWizUtils.LogError("Return from GWizCalcAPIServer.apiServer.shutdown()\n");
      }
      
      public function dispatchIncoming(param1:Socket, param2:String, param3:String) : void
      {
         switch(param2)
         {
            case GET_API_VERSION:
               this.dispatchResponse(param1,param2,String(API_VERSION));
               break;
            default:
               GWizUtils.assert(false);
         }
      }
      
      public function dispatchResponse(param1:Socket, param2:String, param3:String) : void
      {
         var _loc4_:String = param2 + STR_DELIM + param3;
         this.writeStr(param1,_loc4_);
      }
      
      private function createServer(param1:FlexEvent, param2:int) : void
      {
         if(onlyOne)
         {
            GWizUtils.assert(false);
            return;
         }
         onlyOne = true;
         this.socket.bind(param2,ADDRESS);
         this.socket.addEventListener(ServerSocketConnectEvent.CONNECT,this.clientConnectedHandler);
         this.socket.listen();
      }
      
      private function clientConnectedHandler(param1:ServerSocketConnectEvent) : void
      {
         this.clientSockets.addItem(param1.socket);
         param1.socket.addEventListener(Event.CLOSE,this.clientDisconnectedHandler);
         param1.socket.addEventListener(ProgressEvent.SOCKET_DATA,this.msgIncoming);
         GWizLogWindow.write("**** Client Connected ****\n");
      }
      
      private function clientDisconnectedHandler(param1:Event) : void
      {
         this.clientSockets.removeItemAt(this.clientSockets.getItemIndex(param1.target));
         param1.target.removeEventListener(Event.CLOSE,this.clientDisconnectedHandler);
         GWizLogWindow.write("**** Client Disconnected ****\n");
      }
      
      private function msgIncoming(param1:ProgressEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc2_:Socket = param1.target as Socket;
         if(_loc2_)
         {
            _loc3_ = _loc2_.readUTF();
            _loc4_ = _loc3_.split(STR_DELIM);
            GWizUtils.assert(_loc4_.length > 0);
            _loc5_ = "";
            _loc6_ = "";
            if(_loc4_.length > 0)
            {
               _loc5_ = _loc4_[0];
            }
            if(_loc4_.length > 1)
            {
               _loc6_ = _loc4_[1];
            }
            if(_loc5_ != "")
            {
               this.dispatchIncoming(_loc2_,_loc5_,_loc6_);
            }
         }
      }
      
      private function writeStr(param1:Socket, param2:String) : void
      {
         param1.writeUTF(param2);
         param1.flush();
      }
      
      [Bindable(event="propertyChange")]
      private function get clientSockets() : ArrayCollection
      {
         return this._1618433771clientSockets;
      }
      
      private function set clientSockets(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._1618433771clientSockets;
         if(_loc2_ !== param1)
         {
            this._1618433771clientSockets = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"clientSockets",_loc2_,param1));
            }
         }
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this._bindingEventDispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this._bindingEventDispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this._bindingEventDispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.willTrigger(param1);
      }
   }
}
