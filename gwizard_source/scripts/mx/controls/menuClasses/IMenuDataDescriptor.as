package mx.controls.menuClasses
{
   import mx.collections.ICollectionView;
   
   public interface IMenuDataDescriptor
   {
       
      
      function getChildren(param1:Object, param2:Object = null) : ICollectionView;
      
      function hasChildren(param1:Object, param2:Object = null) : Boolean;
      
      function getData(param1:Object, param2:Object = null) : Object;
      
      function isBranch(param1:Object, param2:Object = null) : Boolean;
      
      function getType(param1:Object) : String;
      
      function addChildAt(param1:Object, param2:Object, param3:int, param4:Object = null) : Boolean;
      
      function removeChildAt(param1:Object, param2:Object, param3:int, param4:Object = null) : Boolean;
      
      function isEnabled(param1:Object) : Boolean;
      
      function setEnabled(param1:Object, param2:Boolean) : void;
      
      function isToggled(param1:Object) : Boolean;
      
      function setToggled(param1:Object, param2:Boolean) : void;
      
      function getGroupName(param1:Object) : String;
   }
}
