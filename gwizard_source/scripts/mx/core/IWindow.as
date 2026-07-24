package mx.core
{
   import flash.display.NativeWindow;
   
   public interface IWindow
   {
       
      
      function get maximizable() : Boolean;
      
      function get minimizable() : Boolean;
      
      function get nativeWindow() : NativeWindow;
      
      function get resizable() : Boolean;
      
      function get status() : String;
      
      function set status(param1:String) : void;
      
      function get systemChrome() : String;
      
      function get title() : String;
      
      function set title(param1:String) : void;
      
      function get titleIcon() : Class;
      
      function set titleIcon(param1:Class) : void;
      
      function get transparent() : Boolean;
      
      function get type() : String;
      
      function get visible() : Boolean;
      
      function close() : void;
      
      function maximize() : void;
      
      function minimize() : void;
      
      function restore() : void;
   }
}
