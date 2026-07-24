package com.NTPTime
{
   import flash.events.DNSResolverEvent;
   import flash.events.DatagramSocketDataEvent;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.TimerEvent;
   import flash.net.DatagramSocket;
   import flash.net.dns.ARecord;
   import flash.net.dns.DNSResolver;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   
   public class ntpTimeUtility extends EventDispatcher
   {
      
      public static var NTP_TIME_RECIEVED:String = "com.NTPTime.ntpTimeUtility.NTP_TIME_RECIEVED";
      
      public static var NTP_TIMEOUT:String = "com.NTPTime.ntpTimeUtility.NTP_TIMEOUT";
       
      
      public var latestNTPTime:Date = null;
      
      private var port:int = 123;
      
      private var timeServers:Vector.<String>;
      
      private var currentTSIndex:int = 0;
      
      private var networkTimeout:Timer;
      
      private var datagramSocket:DatagramSocket;
      
      private var dnsResolve:DNSResolver;
      
      public function ntpTimeUtility(param1:IEventDispatcher = null)
      {
         this.timeServers = new <String>["nist1-ny.ustiming.org","nist1-nj.ustiming.org","nist1-nj2.ustiming.org","nist2-nj2.ustiming.org","nist1-pa.ustiming.org","time-d.nist.gov","nist1.aol-va.symmetricom.com"];
         super(param1);
         this.createUDPSocket();
      }
      
      public function initiateUDPTimeRequest() : void
      {
         this.currentTSIndex = 0;
         this.tryNextTimeServer();
      }
      
      private function tryNextTimeServer() : void
      {
         if(this.currentTSIndex < this.timeServers.length)
         {
            this.doDNSResolve(this.timeServers[this.currentTSIndex]);
         }
         else
         {
            dispatchEvent(new Event(ntpTimeUtility.NTP_TIMEOUT,false,true));
         }
      }
      
      private function doTimeRequestUsingIP(param1:String) : void
      {
         var ntpReq:ByteArray = null;
         var _IPV4Add:String = param1;
         if(this.datagramSocket != null)
         {
            try
            {
               ntpReq = this.formNTPRequest();
               this.datagramSocket.send(ntpReq,0,0,_IPV4Add,this.port);
               this.createTimeoutTimer();
            }
            catch(e:Error)
            {
               dispatchEvent(new Event(ntpTimeUtility.NTP_TIMEOUT,false,true));
            }
         }
      }
      
      private function createUDPSocket() : void
      {
         if(this.datagramSocket == null)
         {
            this.datagramSocket = new DatagramSocket();
            this.datagramSocket.addEventListener(DatagramSocketDataEvent.DATA,this.handleIncomingUDPMessage,false,0,true);
            this.datagramSocket.bind();
            this.datagramSocket.receive();
         }
         else
         {
            this.destroyUDPSocket(true);
         }
      }
      
      private function destroyUDPSocket(param1:Boolean = false) : void
      {
         var _OptionalCallback:Boolean = param1;
         if(this.datagramSocket != null)
         {
            try
            {
               if(this.datagramSocket.bound)
               {
                  this.datagramSocket.close();
               }
            }
            catch(e:Error)
            {
               trace("ntpTimeUtility - error closing udp socket: " + e.message);
            }
            this.datagramSocket.removeEventListener(DatagramSocketDataEvent.DATA,this.handleIncomingUDPMessage);
            this.datagramSocket = null;
            if(_OptionalCallback == true)
            {
               this.createUDPSocket();
            }
         }
      }
      
      private function handleIncomingUDPMessage(param1:DatagramSocketDataEvent) : void
      {
         var timeObj:NTPTimeObject = null;
         var e:DatagramSocketDataEvent = param1;
         var incomingBA:ByteArray = e.data;
         this.destroyTimeoutTimer();
         if(incomingBA.length == 48)
         {
            try
            {
               timeObj = new NTPTimeObject();
               timeObj.populateObjectFromBA(incomingBA);
               this.latestNTPTime = timeObj.getLocalizedTimeserverDate();
               this.currentTSIndex = 0;
               dispatchEvent(new Event(ntpTimeUtility.NTP_TIME_RECIEVED));
            }
            catch(e:Error)
            {
               currentTSIndex += 1;
               tryNextTimeServer();
            }
         }
      }
      
      private function formNTPRequest() : ByteArray
      {
         var _loc1_:ByteArray = new ByteArray();
         var _loc2_:NTPTimeObject = new NTPTimeObject();
         return _loc2_.createNTPRequest();
      }
      
      private function doDNSResolve(param1:String) : void
      {
         if(this.dnsResolve == null)
         {
            this.dnsResolve = new DNSResolver();
            this.dnsResolve.addEventListener(DNSResolverEvent.LOOKUP,this.handleDNSLookup,false,0,true);
            this.dnsResolve.addEventListener(ErrorEvent.ERROR,this.handleDNSError,false,0,true);
            this.dnsResolve.lookup(param1,ARecord);
         }
         else
         {
            this.destroyDNSResolve(param1,true);
         }
      }
      
      private function destroyDNSResolve(param1:String = "", param2:Boolean = false) : void
      {
         if(this.dnsResolve != null)
         {
            this.dnsResolve.removeEventListener(DNSResolverEvent.LOOKUP,this.handleDNSLookup);
            this.dnsResolve.removeEventListener(ErrorEvent.ERROR,this.handleDNSError);
            this.dnsResolve = null;
            if(param2 == true)
            {
               this.doDNSResolve(param1);
            }
         }
      }
      
      private function handleDNSLookup(param1:DNSResolverEvent) : void
      {
         var _loc3_:* = undefined;
         this.destroyDNSResolve();
         var _loc2_:String = "";
         for each(_loc3_ in param1.resourceRecords)
         {
            if(_loc3_ is ARecord)
            {
               _loc2_ = _loc3_.address;
            }
         }
         if(_loc2_ != "")
         {
            this.doTimeRequestUsingIP(_loc2_);
         }
         else
         {
            this.currentTSIndex += 1;
            this.tryNextTimeServer();
         }
      }
      
      private function handleDNSError(param1:ErrorEvent) : void
      {
         this.destroyDNSResolve();
         this.currentTSIndex += 1;
         this.tryNextTimeServer();
      }
      
      private function createTimeoutTimer() : void
      {
         if(this.networkTimeout == null)
         {
            this.networkTimeout = new Timer(10000);
            this.networkTimeout.addEventListener(TimerEvent.TIMER,this.handleNetworkTimeout,false,0,true);
            this.networkTimeout.start();
         }
         else
         {
            this.destroyTimeoutTimer(true);
         }
      }
      
      private function destroyTimeoutTimer(param1:Boolean = false) : void
      {
         if(this.networkTimeout != null)
         {
            this.networkTimeout.stop();
            this.networkTimeout.removeEventListener(TimerEvent.TIMER,this.handleNetworkTimeout);
            this.networkTimeout = null;
            if(param1 == true)
            {
               this.createTimeoutTimer();
            }
         }
      }
      
      private function handleNetworkTimeout(param1:TimerEvent) : void
      {
         this.destroyTimeoutTimer();
         this.currentTSIndex += 1;
         this.tryNextTimeServer();
      }
      
      public function destroyInternals() : void
      {
         this.destroyTimeoutTimer();
         this.destroyUDPSocket();
         this.destroyDNSResolve();
      }
   }
}
