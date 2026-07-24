package
{
   import mx.binding.IWatcherSetupUtil2;
   import mx.binding.PropertyWatcher;
   import mx.core.IFlexModuleFactory;
   import views.GWizChordCalc;
   
   public class _views_GWizChordCalcWatcherSetupUtil implements IWatcherSetupUtil2
   {
       
      
      public function _views_GWizChordCalcWatcherSetupUtil()
      {
         super();
      }
      
      public static function init(param1:IFlexModuleFactory) : void
      {
         GWizChordCalc.watcherSetupUtil = new _views_GWizChordCalcWatcherSetupUtil();
      }
      
      public function setup(param1:Object, param2:Function, param3:Function, param4:Array, param5:Array) : void
      {
         param5[1] = new PropertyWatcher("gridArea",{"propertyChange":true},[param4[1],param4[2],param4[3],param4[4],param4[5],param4[6],param4[7],param4[8],param4[9]],param2);
         param5[6] = new PropertyWatcher("yOrigin",{"propertyChange":true},[param4[3],param4[5],param4[7],param4[9]],null);
         param5[2] = new PropertyWatcher("xOrigin",{"propertyChange":true},[param4[1],param4[2],param4[4],param4[6],param4[8]],null);
         param5[3] = new PropertyWatcher("chordWidth",{"propertyChange":true},[param4[1]],param2);
         param5[4] = new PropertyWatcher("width",{"widthChanged":true},[param4[1]],null);
         param5[5] = new PropertyWatcher("chordRight",{"propertyChange":true},[param4[2]],param2);
         param5[10] = new PropertyWatcher("arcLenGrp",{"propertyChange":true},[param4[8]],param2);
         param5[11] = new PropertyWatcher("width",{"widthChanged":true},[param4[8]],null);
         param5[7] = new PropertyWatcher("chordTop",{"propertyChange":true},[param4[3]],param2);
         param5[8] = new PropertyWatcher("angle",{"propertyChange":true},[param4[4]],param2);
         param5[9] = new PropertyWatcher("width",{"widthChanged":true},[param4[4]],null);
         param5[1].updateParent(param1);
         param5[1].addChild(param5[6]);
         param5[1].addChild(param5[2]);
         param5[3].updateParent(param1);
         param5[3].addChild(param5[4]);
         param5[5].updateParent(param1);
         param5[10].updateParent(param1);
         param5[10].addChild(param5[11]);
         param5[7].updateParent(param1);
         param5[8].updateParent(param1);
         param5[8].addChild(param5[9]);
      }
   }
}
