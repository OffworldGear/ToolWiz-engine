package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.binding.StaticPropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import notebook.GWizNotebook;
   import utils.ColorPalette;
   
   public class _notebook_GWizNotebookWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _notebook_GWizNotebookWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizNotebook.watcherSetupUtil = new _notebook_GWizNotebookWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[0] = new PropertyWatcher("notebookContents",{"propertyChange":true},[param4[0]],param2);
         param5[2] = new StaticPropertyWatcher("alternateb5",{"propertyChange":true},[param4[2],param4[3]],null);
         param5[1] = new StaticPropertyWatcher("alternateb4",{"propertyChange":true},[param4[1]],null);
         param5[0].updateParent(param1);
         param5[2].updateParent(ColorPalette);
         param5[1].updateParent(ColorPalette);
      }
   }
}
