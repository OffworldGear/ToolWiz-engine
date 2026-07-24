package utils
{
   import flash.desktop.Clipboard;
   import flash.desktop.ClipboardFormats;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizClipUtils
   {
      
      private static const log:ILogger = Log.getLogger("GWizClipUtils");
      
      public static const XML_FORMAT:String = "air:xml";
      
      public static const JSON_FORMAT:String = "air:json";
      
      public static const CSV_FORMAT:String = "air:csv";
      
      public static const TSV_FORMAT:String = "air:tsv";
       
      
      public function GWizClipUtils()
      {
         super();
      }
      
      public static function loadClipboard(param1:String, param2:String) : void
      {
         Clipboard.generalClipboard.clear();
         Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT,param2);
      }
   }
}
