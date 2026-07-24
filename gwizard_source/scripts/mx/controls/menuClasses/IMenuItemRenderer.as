package mx.controls.menuClasses
{
   import mx.controls.Menu;
   
   public interface IMenuItemRenderer
   {
       
      
      function get menu() : Menu;
      
      function set menu(param1:Menu) : void;
      
      function get measuredIconWidth() : Number;
      
      function get measuredTypeIconWidth() : Number;
      
      function get measuredBranchIconWidth() : Number;
   }
}
