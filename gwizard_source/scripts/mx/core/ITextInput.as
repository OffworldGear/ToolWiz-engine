package mx.core
{
   import mx.controls.listClasses.IDropInListItemRenderer;
   import mx.controls.listClasses.IListItemRenderer;
   import mx.managers.IFocusManagerComponent;
   import mx.styles.IStyleClient;
   
   public interface ITextInput extends IDataRenderer, IDropInListItemRenderer, IFocusManagerComponent, IFontContextComponent, IIMESupport, IListItemRenderer, IUIComponent, IInvalidating, IStyleClient
   {
       
      
      function get selectionActivePosition() : int;
      
      function get selectionAnchorPosition() : int;
      
      function get editable() : Boolean;
      
      function set editable(param1:Boolean) : void;
      
      function get horizontalScrollPosition() : Number;
      
      function set horizontalScrollPosition(param1:Number) : void;
      
      function get maxChars() : int;
      
      function set maxChars(param1:int) : void;
      
      function get mouseChildren() : Boolean;
      
      function set mouseChildren(param1:Boolean) : void;
      
      function get mouseEnabled() : Boolean;
      
      function set mouseEnabled(param1:Boolean) : void;
      
      function get parentDrawsFocus() : Boolean;
      
      function set parentDrawsFocus(param1:Boolean) : void;
      
      function get restrict() : String;
      
      function set restrict(param1:String) : void;
      
      function get selectable() : Boolean;
      
      function set selectable(param1:Boolean) : void;
      
      function get text() : String;
      
      function set text(param1:String) : void;
      
      function showBorderAndBackground(param1:Boolean) : void;
      
      function selectRange(param1:int, param2:int) : void;
   }
}
