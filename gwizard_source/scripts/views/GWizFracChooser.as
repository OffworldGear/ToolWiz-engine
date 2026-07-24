package views
{
   import mx.collections.ArrayCollection;
   import mx.controls.DataGrid;
   import mx.controls.PopUpButton;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.ListEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.TextInput;
   import utils.GWizUtils;
   
   public class GWizFracChooser extends PopUpButton
   {
      
      private static const log:ILogger = Log.getLogger("GWizFracChooser");
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var textInpRef:TextInput;
      
      private var _691508768FractionList:ArrayCollection;
      
      public function GWizFracChooser()
      {
         this._691508768FractionList = new ArrayCollection([{
            "fraction":"1/32",
            "value":0.0313
         },{
            "fraction":"1/16",
            "value":0.0625
         },{
            "fraction":"3/32",
            "value":0.0938
         },{
            "fraction":"1/8",
            "value":0.125
         },{
            "fraction":"5/32",
            "value":0.1563
         },{
            "fraction":"3/16",
            "value":0.1875
         },{
            "fraction":"7/32",
            "value":0.2188
         },{
            "fraction":"1/4",
            "value":0.25
         },{
            "fraction":"9/32",
            "value":0.2813
         },{
            "fraction":"5/16",
            "value":0.3125
         },{
            "fraction":"11/32",
            "value":0.3438
         },{
            "fraction":"3/8",
            "value":0.375
         },{
            "fraction":"13/32",
            "value":0.4063
         },{
            "fraction":"7/16",
            "value":0.4375
         },{
            "fraction":"15/32",
            "value":0.4688
         },{
            "fraction":"1/2",
            "value":0.5
         },{
            "fraction":"17/32",
            "value":0.5313
         },{
            "fraction":"9/16",
            "value":0.5625
         },{
            "fraction":"19/32",
            "value":0.5938
         },{
            "fraction":"5/8",
            "value":0.625
         },{
            "fraction":"21/32",
            "value":0.6563
         },{
            "fraction":"11/16",
            "value":0.6875
         },{
            "fraction":"23/32",
            "value":0.7188
         },{
            "fraction":"3/4",
            "value":0.75
         },{
            "fraction":"25/32",
            "value":0.7813
         },{
            "fraction":"13/16",
            "value":0.8125
         },{
            "fraction":"27/32",
            "value":0.8438
         },{
            "fraction":"7/8",
            "value":0.875
         },{
            "fraction":"29/32",
            "value":0.9063
         },{
            "fraction":"15/16",
            "value":0.9375
         },{
            "fraction":"31/32",
            "value":0.9688
         }]);
         super();
         this.label = "Frac";
         this.width = 70;
         this.addEventListener("creationComplete",this.___GWizFracChooser_PopUpButton1_creationComplete);
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function initPopup() : void
      {
         var _loc1_:DataGrid = new DataGrid();
         _loc1_.dataProvider = this.FractionList;
         _loc1_.addEventListener(ListEvent.ITEM_CLICK,this.chooseFraction);
         _loc1_.height = 300;
         this.popUp = _loc1_;
      }
      
      private function chooseFraction(param1:ListEvent) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc2_:Object = this.FractionList.getItemAt(param1.rowIndex);
         this.label = _loc2_.fraction;
         log.debug("chooseFraction");
         log.debug("fracGrid.selectedItem = " + _loc2_);
         log.debug("textInpRef = " + this.textInpRef);
         _loc3_ = _loc2_.value;
         _loc4_ = Math.floor(Number(this.textInpRef.text));
         log.debug("tiValue = " + _loc4_ + ", nValue = " + _loc3_);
         this.textInpRef.text = GWizUtils.sroundTenths(String(_loc4_ + _loc3_));
         this.close();
      }
      
      public function ___GWizFracChooser_PopUpButton1_creationComplete(param1:FlexEvent) : void
      {
         this.initPopup();
      }
      
      [Bindable(event="propertyChange")]
      public function get FractionList() : ArrayCollection
      {
         return this._691508768FractionList;
      }
      
      public function set FractionList(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._691508768FractionList;
         if(_loc2_ !== param1)
         {
            this._691508768FractionList = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"FractionList",_loc2_,param1));
            }
         }
      }
   }
}
