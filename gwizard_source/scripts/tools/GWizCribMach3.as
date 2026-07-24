package tools
{
   import comps.GWizFileBrowser;
   import comps.GWizPopUpManager;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizCribMach3 extends GWizCribFileFormat
   {
      
      private static const log:ILogger = Log.getLogger("GWizCribMach3");
       
      
      public function GWizCribMach3()
      {
         super();
         cribFiles = new GWizFileBrowser("Mach3Cribs","Mach3","*.dat");
      }
      
      override public function importTools(param1:File) : void
      {
         var f:File = param1;
         var stream:FileStream = new FileStream();
         try
         {
            stream.open(f,FileMode.READ);
            this.readTools(stream,f.name);
            stream.close();
         }
         catch(e:Error)
         {
            GWizPopUpManager.Show("Error importing file: " + e.message,"Error: Import Failed",GWizPopUpManager.ERROR);
         }
      }
      
      private function readTools(param1:FileStream, param2:String) : void
      {
         var _loc5_:Object = null;
         var _loc3_:ArrayCollection = new ArrayCollection();
         var _loc4_:int = 0;
         while(_loc4_ < 255)
         {
            _loc5_ = this.readTool(param1);
            if(_loc4_ > 0 && _loc5_)
            {
               _loc5_.slot = _loc4_;
               _loc3_.addItem(_loc5_);
            }
            _loc4_++;
         }
         if(importFcn != null)
         {
            this.importFcn(_loc3_,param2);
         }
      }
      
      private function readTool(param1:FileStream) : Object
      {
         var _loc2_:Object = newDefaultTool();
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.endian = Endian.LITTLE_ENDIAN;
         var _loc4_:int = param1.readByte();
         log.debug("Position = " + param1.position + ", len = " + _loc4_);
         var _loc5_:String = param1.readUTFBytes(_loc4_);
         log.debug("description = \'" + _loc5_ + "\'");
         _loc2_.description = _loc5_;
         _loc3_.clear();
         param1.readBytes(_loc3_,0,8);
         _loc3_.clear();
         param1.readBytes(_loc3_,0,8);
         _loc2_.diameter = _loc3_.readDouble();
         _loc3_.clear();
         param1.readBytes(_loc3_,0,26);
         _loc3_.clear();
         param1.readBytes(_loc3_,0,8);
         _loc2_.xcomp = _loc3_.readDouble();
         _loc3_.clear();
         param1.readBytes(_loc3_,0,8);
         _loc2_.zgeom = _loc3_.readDouble();
         _loc3_.clear();
         param1.readBytes(_loc3_,0,8);
         _loc2_.zcomp = _loc3_.readDouble();
         return _loc2_;
      }
      
      public function browseForExport() : void
      {
         browseForExportAux("Tools.dat");
      }
      
      override public function exportTools(param1:File) : void
      {
         var f:File = param1;
         var stream:FileStream = new FileStream();
         try
         {
            stream.open(f,FileMode.WRITE);
            this.writeTools(stream);
            stream.close();
         }
         catch(e:Error)
         {
            GWizPopUpManager.Show("Error exporting file: " + e.message,"Error: Export Failed",GWizPopUpManager.ERROR);
         }
      }
      
      private function writeTools(param1:FileStream) : void
      {
         var _loc3_:Object = null;
         this.fillBytes(param1,2,1);
         this.fillBytes(param1,66,0);
         var _loc2_:int = 0;
         while(_loc2_ < 254)
         {
            _loc3_ = null;
            if(_loc2_ < toolsAC.length)
            {
               _loc3_ = this.toolsAC.getItemAt(_loc2_);
            }
            if(_loc3_)
            {
               this.writeATool(_loc3_,param1);
            }
            else
            {
               this.writeNullTool(param1);
            }
            _loc2_++;
         }
         this.fillBytes(param1,255,1);
      }
      
      private function writeATool(param1:Object, param2:FileStream) : void
      {
         var _loc3_:String = param1.description;
         if(_loc3_.length > 255)
         {
            _loc3_ = _loc3_.substr(0,255);
         }
         param2.writeByte(_loc3_.length);
         param2.writeUTFBytes(_loc3_);
         param2.endian = Endian.LITTLE_ENDIAN;
         this.fillBytes(param2,8,0);
         param2.writeDouble(param1.diameter);
         this.fillBytes(param2,26,0);
         param2.writeDouble(param1.xcomp);
         param2.writeDouble(param1.zgeom);
         param2.writeDouble(param1.zcomp);
      }
      
      private function writeNullTool(param1:FileStream) : void
      {
         param1.writeByte(0);
         this.fillBytes(param1,8,0);
         this.fillBytes(param1,8,0);
         this.fillBytes(param1,26,0);
         this.fillBytes(param1,8,0);
         this.fillBytes(param1,8,0);
         this.fillBytes(param1,8,0);
      }
      
      private function fillBytes(param1:FileStream, param2:int, param3:int) : void
      {
         var _loc4_:int = 0;
         while(_loc4_ < param2)
         {
            param1.writeByte(param3);
            _loc4_++;
         }
      }
      
      private function writeDouble(param1:FileStream, param2:Number) : void
      {
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.endian = Endian.LITTLE_ENDIAN;
         _loc3_.writeDouble(param2);
         param1.writeBytes(_loc3_,0,8);
      }
   }
}
