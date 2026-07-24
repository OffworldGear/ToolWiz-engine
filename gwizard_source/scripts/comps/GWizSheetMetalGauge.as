package comps
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.DropDownList;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.VGroup;
   
   use namespace mx_internal;
   
   public class GWizSheetMetalGauge extends GWizPopUp implements IBindingClient
   {
      
      public static var _619867710SheetMetalGauges:ArrayCollection = new ArrayCollection([{
         "System":"Standard Steel",
         "Gauge":"3",
         "Inch":0.2391,
         "MM":6.073
      },{
         "System":"Standard Steel",
         "Gauge":"4",
         "Inch":0.2242,
         "MM":5.695
      },{
         "System":"Standard Steel",
         "Gauge":"5",
         "Inch":0.2092,
         "MM":5.314
      },{
         "System":"Standard Steel",
         "Gauge":"6",
         "Inch":0.1943,
         "MM":4.935
      },{
         "System":"Standard Steel",
         "Gauge":"7",
         "Inch":0.1793,
         "MM":4.554
      },{
         "System":"Standard Steel",
         "Gauge":"8",
         "Inch":0.1644,
         "MM":4.176
      },{
         "System":"Standard Steel",
         "Gauge":"9",
         "Inch":0.1495,
         "MM":3.797
      },{
         "System":"Standard Steel",
         "Gauge":"10",
         "Inch":0.1345,
         "MM":3.416
      },{
         "System":"Standard Steel",
         "Gauge":"11",
         "Inch":0.1196,
         "MM":3.038
      },{
         "System":"Standard Steel",
         "Gauge":"12",
         "Inch":0.1046,
         "MM":2.657
      },{
         "System":"Standard Steel",
         "Gauge":"13",
         "Inch":0.0897,
         "MM":2.278
      },{
         "System":"Standard Steel",
         "Gauge":"14",
         "Inch":0.0747,
         "MM":1.897
      },{
         "System":"Standard Steel",
         "Gauge":"15",
         "Inch":0.0673,
         "MM":1.709
      },{
         "System":"Standard Steel",
         "Gauge":"16",
         "Inch":0.0598,
         "MM":1.519
      },{
         "System":"Standard Steel",
         "Gauge":"17",
         "Inch":0.0538,
         "MM":1.367
      },{
         "System":"Standard Steel",
         "Gauge":"18",
         "Inch":0.0478,
         "MM":1.214
      },{
         "System":"Standard Steel",
         "Gauge":"19",
         "Inch":0.0418,
         "MM":1.062
      },{
         "System":"Standard Steel",
         "Gauge":"20",
         "Inch":0.0359,
         "MM":0.912
      },{
         "System":"Standard Steel",
         "Gauge":"21",
         "Inch":0.0329,
         "MM":0.836
      },{
         "System":"Standard Steel",
         "Gauge":"22",
         "Inch":0.0299,
         "MM":0.759
      },{
         "System":"Standard Steel",
         "Gauge":"23",
         "Inch":0.0269,
         "MM":0.683
      },{
         "System":"Standard Steel",
         "Gauge":"24",
         "Inch":0.0239,
         "MM":0.607
      },{
         "System":"Standard Steel",
         "Gauge":"25",
         "Inch":0.0209,
         "MM":0.531
      },{
         "System":"Standard Steel",
         "Gauge":"26",
         "Inch":0.0179,
         "MM":0.455
      },{
         "System":"Standard Steel",
         "Gauge":"27",
         "Inch":0.0164,
         "MM":0.417
      },{
         "System":"Standard Steel",
         "Gauge":"28",
         "Inch":0.0149,
         "MM":0.378
      },{
         "System":"Standard Steel",
         "Gauge":"29",
         "Inch":0.0135,
         "MM":0.343
      },{
         "System":"Standard Steel",
         "Gauge":"30",
         "Inch":0.012,
         "MM":0.305
      },{
         "System":"Standard Steel",
         "Gauge":"31",
         "Inch":0.0105,
         "MM":0.267
      },{
         "System":"Standard Steel",
         "Gauge":"32",
         "Inch":0.0097,
         "MM":0.246
      },{
         "System":"Standard Steel",
         "Gauge":"33",
         "Inch":0.009,
         "MM":0.229
      },{
         "System":"Standard Steel",
         "Gauge":"34",
         "Inch":0.0082,
         "MM":0.208
      },{
         "System":"Standard Steel",
         "Gauge":"35",
         "Inch":0.0075,
         "MM":0.191
      },{
         "System":"Standard Steel",
         "Gauge":"36",
         "Inch":0.0067,
         "MM":0.17
      },{
         "System":"Standard Steel",
         "Gauge":"37",
         "Inch":0.0064,
         "MM":0.163
      },{
         "System":"Standard Steel",
         "Gauge":"38",
         "Inch":0.006,
         "MM":0.152
      },{
         "System":"Galvanized Steel",
         "Gauge":"8",
         "Inch":0.1681,
         "MM":4.27
      },{
         "System":"Galvanized Steel",
         "Gauge":"9",
         "Inch":0.1532,
         "MM":3.891
      },{
         "System":"Galvanized Steel",
         "Gauge":"10",
         "Inch":0.1382,
         "MM":3.51
      },{
         "System":"Galvanized Steel",
         "Gauge":"11",
         "Inch":0.1233,
         "MM":3.132
      },{
         "System":"Galvanized Steel",
         "Gauge":"12",
         "Inch":0.1084,
         "MM":2.753
      },{
         "System":"Galvanized Steel",
         "Gauge":"13",
         "Inch":0.0934,
         "MM":2.372
      },{
         "System":"Galvanized Steel",
         "Gauge":"14",
         "Inch":0.0785,
         "MM":1.994
      },{
         "System":"Galvanized Steel",
         "Gauge":"15",
         "Inch":0.071,
         "MM":1.803
      },{
         "System":"Galvanized Steel",
         "Gauge":"16",
         "Inch":0.0635,
         "MM":1.613
      },{
         "System":"Galvanized Steel",
         "Gauge":"17",
         "Inch":0.0575,
         "MM":1.461
      },{
         "System":"Galvanized Steel",
         "Gauge":"18",
         "Inch":0.0516,
         "MM":1.311
      },{
         "System":"Galvanized Steel",
         "Gauge":"19",
         "Inch":0.0456,
         "MM":1.158
      },{
         "System":"Galvanized Steel",
         "Gauge":"20",
         "Inch":0.0396,
         "MM":1.006
      },{
         "System":"Galvanized Steel",
         "Gauge":"21",
         "Inch":0.0366,
         "MM":0.93
      },{
         "System":"Galvanized Steel",
         "Gauge":"22",
         "Inch":0.0336,
         "MM":0.853
      },{
         "System":"Galvanized Steel",
         "Gauge":"23",
         "Inch":0.0306,
         "MM":0.777
      },{
         "System":"Galvanized Steel",
         "Gauge":"24",
         "Inch":0.0276,
         "MM":0.701
      },{
         "System":"Galvanized Steel",
         "Gauge":"25",
         "Inch":0.0247,
         "MM":0.627
      },{
         "System":"Galvanized Steel",
         "Gauge":"26",
         "Inch":0.0217,
         "MM":0.551
      },{
         "System":"Galvanized Steel",
         "Gauge":"27",
         "Inch":0.0202,
         "MM":0.513
      },{
         "System":"Galvanized Steel",
         "Gauge":"28",
         "Inch":0.0187,
         "MM":0.475
      },{
         "System":"Galvanized Steel",
         "Gauge":"29",
         "Inch":0.0172,
         "MM":0.437
      },{
         "System":"Galvanized Steel",
         "Gauge":"30",
         "Inch":0.0157,
         "MM":0.399
      },{
         "System":"Galvanized Steel",
         "Gauge":"31",
         "Inch":0.0142,
         "MM":0.361
      },{
         "System":"Galvanized Steel",
         "Gauge":"32",
         "Inch":0.0134,
         "MM":0.34
      },{
         "System":"Stainless Steel",
         "Gauge":"0000000",
         "Inch":0.5,
         "MM":12.7
      },{
         "System":"Stainless Steel",
         "Gauge":"000000",
         "Inch":0.4686,
         "MM":11.902
      },{
         "System":"Stainless Steel",
         "Gauge":"00000",
         "Inch":0.4375,
         "MM":11.113
      },{
         "System":"Stainless Steel",
         "Gauge":"0000",
         "Inch":0.4063,
         "MM":10.32
      },{
         "System":"Stainless Steel",
         "Gauge":"000",
         "Inch":0.375,
         "MM":9.525
      },{
         "System":"Stainless Steel",
         "Gauge":"00",
         "Inch":0.3438,
         "MM":8.733
      },{
         "System":"Stainless Steel",
         "Gauge":"0",
         "Inch":0.3125,
         "MM":7.938
      },{
         "System":"Stainless Steel",
         "Gauge":"1",
         "Inch":0.2813,
         "MM":7.145
      },{
         "System":"Stainless Steel",
         "Gauge":"2",
         "Inch":0.2656,
         "MM":6.746
      },{
         "System":"Stainless Steel",
         "Gauge":"3",
         "Inch":0.25,
         "MM":6.35
      },{
         "System":"Stainless Steel",
         "Gauge":"4",
         "Inch":0.2344,
         "MM":5.954
      },{
         "System":"Stainless Steel",
         "Gauge":"5",
         "Inch":0.2187,
         "MM":5.555
      },{
         "System":"Stainless Steel",
         "Gauge":"6",
         "Inch":0.2031,
         "MM":5.159
      },{
         "System":"Stainless Steel",
         "Gauge":"7",
         "Inch":0.1875,
         "MM":4.763
      },{
         "System":"Stainless Steel",
         "Gauge":"8",
         "Inch":0.1719,
         "MM":4.366
      },{
         "System":"Stainless Steel",
         "Gauge":"9",
         "Inch":0.1562,
         "MM":3.967
      },{
         "System":"Stainless Steel",
         "Gauge":"10",
         "Inch":0.1406,
         "MM":3.571
      },{
         "System":"Stainless Steel",
         "Gauge":"11",
         "Inch":0.125,
         "MM":3.175
      },{
         "System":"Stainless Steel",
         "Gauge":"12",
         "Inch":0.1094,
         "MM":2.779
      },{
         "System":"Stainless Steel",
         "Gauge":"13",
         "Inch":0.0937,
         "MM":2.38
      },{
         "System":"Stainless Steel",
         "Gauge":"14",
         "Inch":0.0781,
         "MM":1.984
      },{
         "System":"Stainless Steel",
         "Gauge":"15",
         "Inch":0.0703,
         "MM":1.786
      },{
         "System":"Stainless Steel",
         "Gauge":"16",
         "Inch":0.0625,
         "MM":1.588
      },{
         "System":"Stainless Steel",
         "Gauge":"17",
         "Inch":0.0562,
         "MM":1.427
      },{
         "System":"Stainless Steel",
         "Gauge":"18",
         "Inch":0.05,
         "MM":1.27
      },{
         "System":"Stainless Steel",
         "Gauge":"19",
         "Inch":0.0437,
         "MM":1.11
      },{
         "System":"Stainless Steel",
         "Gauge":"20",
         "Inch":0.0375,
         "MM":0.953
      },{
         "System":"Stainless Steel",
         "Gauge":"21",
         "Inch":0.0344,
         "MM":0.874
      },{
         "System":"Stainless Steel",
         "Gauge":"22",
         "Inch":0.0312,
         "MM":0.792
      },{
         "System":"Stainless Steel",
         "Gauge":"23",
         "Inch":0.0281,
         "MM":0.714
      },{
         "System":"Stainless Steel",
         "Gauge":"24",
         "Inch":0.025,
         "MM":0.635
      },{
         "System":"Stainless Steel",
         "Gauge":"25",
         "Inch":0.0219,
         "MM":0.556
      },{
         "System":"Stainless Steel",
         "Gauge":"26",
         "Inch":0.0187,
         "MM":0.475
      },{
         "System":"Stainless Steel",
         "Gauge":"27",
         "Inch":0.0172,
         "MM":0.437
      },{
         "System":"Stainless Steel",
         "Gauge":"28",
         "Inch":0.0156,
         "MM":0.396
      },{
         "System":"Stainless Steel",
         "Gauge":"29",
         "Inch":0.0141,
         "MM":0.358
      },{
         "System":"Stainless Steel",
         "Gauge":"30",
         "Inch":0.0125,
         "MM":0.318
      },{
         "System":"Stainless Steel",
         "Gauge":"31",
         "Inch":0.0109,
         "MM":0.277
      },{
         "System":"Stainless Steel",
         "Gauge":"32",
         "Inch":0.0102,
         "MM":0.259
      },{
         "System":"Stainless Steel",
         "Gauge":"33",
         "Inch":0.0094,
         "MM":0.239
      },{
         "System":"Stainless Steel",
         "Gauge":"34",
         "Inch":0.0086,
         "MM":0.218
      },{
         "System":"Stainless Steel",
         "Gauge":"35",
         "Inch":0.0078,
         "MM":0.198
      },{
         "System":"Stainless Steel",
         "Gauge":"36",
         "Inch":0.007,
         "MM":0.178
      },{
         "System":"Stainless Steel",
         "Gauge":"37",
         "Inch":0.0066,
         "MM":0.168
      },{
         "System":"Stainless Steel",
         "Gauge":"38",
         "Inch":0.0062,
         "MM":0.157
      },{
         "System":"Aluminum",
         "Gauge":"000000",
         "Inch":0.58,
         "MM":14.732
      },{
         "System":"Aluminum",
         "Gauge":"00000",
         "Inch":0.5165,
         "MM":13.119
      },{
         "System":"Aluminum",
         "Gauge":"0000",
         "Inch":0.46,
         "MM":11.684
      },{
         "System":"Aluminum",
         "Gauge":"000",
         "Inch":0.4096,
         "MM":10.404
      },{
         "System":"Aluminum",
         "Gauge":"00",
         "Inch":0.3648,
         "MM":9.266
      },{
         "System":"Aluminum",
         "Gauge":"0",
         "Inch":0.3249,
         "MM":8.252
      },{
         "System":"Aluminum",
         "Gauge":"1",
         "Inch":0.2893,
         "MM":7.348
      },{
         "System":"Aluminum",
         "Gauge":"2",
         "Inch":0.2576,
         "MM":6.543
      },{
         "System":"Aluminum",
         "Gauge":"3",
         "Inch":0.2294,
         "MM":5.827
      },{
         "System":"Aluminum",
         "Gauge":"4",
         "Inch":0.2043,
         "MM":5.189
      },{
         "System":"Aluminum",
         "Gauge":"5",
         "Inch":0.1819,
         "MM":4.62
      },{
         "System":"Aluminum",
         "Gauge":"6",
         "Inch":0.162,
         "MM":4.115
      },{
         "System":"Aluminum",
         "Gauge":"7",
         "Inch":0.1443,
         "MM":3.665
      },{
         "System":"Aluminum",
         "Gauge":"8",
         "Inch":0.1285,
         "MM":3.264
      },{
         "System":"Aluminum",
         "Gauge":"9",
         "Inch":0.1144,
         "MM":2.906
      },{
         "System":"Aluminum",
         "Gauge":"10",
         "Inch":0.1019,
         "MM":2.588
      },{
         "System":"Aluminum",
         "Gauge":"11",
         "Inch":0.0907,
         "MM":2.304
      },{
         "System":"Aluminum",
         "Gauge":"12",
         "Inch":0.0808,
         "MM":2.052
      },{
         "System":"Aluminum",
         "Gauge":"13",
         "Inch":0.072,
         "MM":1.829
      },{
         "System":"Aluminum",
         "Gauge":"14",
         "Inch":0.0641,
         "MM":1.628
      },{
         "System":"Aluminum",
         "Gauge":"15",
         "Inch":0.0571,
         "MM":1.45
      },{
         "System":"Aluminum",
         "Gauge":"16",
         "Inch":0.0508,
         "MM":1.29
      },{
         "System":"Aluminum",
         "Gauge":"17",
         "Inch":0.0453,
         "MM":1.151
      },{
         "System":"Aluminum",
         "Gauge":"18",
         "Inch":0.0403,
         "MM":1.024
      },{
         "System":"Aluminum",
         "Gauge":"19",
         "Inch":0.0359,
         "MM":0.912
      },{
         "System":"Aluminum",
         "Gauge":"20",
         "Inch":0.032,
         "MM":0.813
      },{
         "System":"Aluminum",
         "Gauge":"21",
         "Inch":0.0285,
         "MM":0.724
      },{
         "System":"Aluminum",
         "Gauge":"22",
         "Inch":0.0253,
         "MM":0.643
      },{
         "System":"Aluminum",
         "Gauge":"23",
         "Inch":0.0226,
         "MM":0.574
      },{
         "System":"Aluminum",
         "Gauge":"24",
         "Inch":0.0201,
         "MM":0.511
      },{
         "System":"Aluminum",
         "Gauge":"25",
         "Inch":0.0179,
         "MM":0.455
      },{
         "System":"Aluminum",
         "Gauge":"26",
         "Inch":0.0159,
         "MM":0.404
      },{
         "System":"Aluminum",
         "Gauge":"27",
         "Inch":0.0142,
         "MM":0.361
      },{
         "System":"Aluminum",
         "Gauge":"28",
         "Inch":0.0126,
         "MM":0.32
      },{
         "System":"Aluminum",
         "Gauge":"29",
         "Inch":0.0113,
         "MM":0.287
      },{
         "System":"Aluminum",
         "Gauge":"30",
         "Inch":0.01,
         "MM":0.254
      },{
         "System":"Aluminum",
         "Gauge":"31",
         "Inch":0.0089,
         "MM":0.226
      },{
         "System":"Aluminum",
         "Gauge":"32",
         "Inch":0.008,
         "MM":0.203
      },{
         "System":"Aluminum",
         "Gauge":"33",
         "Inch":0.0071,
         "MM":0.18
      },{
         "System":"Aluminum",
         "Gauge":"34",
         "Inch":0.0063,
         "MM":0.16
      },{
         "System":"Aluminum",
         "Gauge":"35",
         "Inch":0.0056,
         "MM":0.142
      },{
         "System":"Aluminum",
         "Gauge":"36",
         "Inch":0.005,
         "MM":0.127
      },{
         "System":"Aluminum",
         "Gauge":"37",
         "Inch":0.0045,
         "MM":0.114
      },{
         "System":"Aluminum",
         "Gauge":"38",
         "Inch":0.004,
         "MM":0.102
      },{
         "System":"Aluminum",
         "Gauge":"39",
         "Inch":0.0035,
         "MM":0.089
      },{
         "System":"Aluminum",
         "Gauge":"40",
         "Inch":0.0031,
         "MM":0.079
      },{
         "System":"Zinc",
         "Gauge":"28",
         "Inch":1,
         "MM":25.4
      },{
         "System":"Zinc",
         "Gauge":"27",
         "Inch":0.5,
         "MM":12.7
      },{
         "System":"Zinc",
         "Gauge":"26",
         "Inch":0.375,
         "MM":9.525
      },{
         "System":"Zinc",
         "Gauge":"25",
         "Inch":0.25,
         "MM":6.35
      },{
         "System":"Zinc",
         "Gauge":"24",
         "Inch":0.125,
         "MM":3.175
      },{
         "System":"Zinc",
         "Gauge":"23",
         "Inch":0.1,
         "MM":2.54
      },{
         "System":"Zinc",
         "Gauge":"22",
         "Inch":0.09,
         "MM":2.286
      },{
         "System":"Zinc",
         "Gauge":"21",
         "Inch":0.08,
         "MM":2.032
      },{
         "System":"Zinc",
         "Gauge":"20",
         "Inch":0.07,
         "MM":1.778
      },{
         "System":"Zinc",
         "Gauge":"19",
         "Inch":0.06,
         "MM":1.524
      },{
         "System":"Zinc",
         "Gauge":"18",
         "Inch":0.055,
         "MM":1.397
      },{
         "System":"Zinc",
         "Gauge":"17",
         "Inch":0.05,
         "MM":1.27
      },{
         "System":"Zinc",
         "Gauge":"16",
         "Inch":0.045,
         "MM":1.143
      },{
         "System":"Zinc",
         "Gauge":"15",
         "Inch":0.04,
         "MM":1.016
      },{
         "System":"Zinc",
         "Gauge":"14",
         "Inch":0.036,
         "MM":0.914
      },{
         "System":"Zinc",
         "Gauge":"13",
         "Inch":0.032,
         "MM":0.813
      },{
         "System":"Zinc",
         "Gauge":"12",
         "Inch":0.028,
         "MM":0.711
      },{
         "System":"Zinc",
         "Gauge":"11",
         "Inch":0.024,
         "MM":0.61
      },{
         "System":"Zinc",
         "Gauge":"10",
         "Inch":0.02,
         "MM":0.508
      },{
         "System":"Zinc",
         "Gauge":"9",
         "Inch":0.018,
         "MM":0.457
      },{
         "System":"Zinc",
         "Gauge":"8",
         "Inch":0.016,
         "MM":0.406
      },{
         "System":"Zinc",
         "Gauge":"7",
         "Inch":0.014,
         "MM":0.356
      },{
         "System":"Zinc",
         "Gauge":"6",
         "Inch":0.012,
         "MM":0.305
      },{
         "System":"Zinc",
         "Gauge":"5",
         "Inch":0.01,
         "MM":0.254
      },{
         "System":"Zinc",
         "Gauge":"4",
         "Inch":0.008,
         "MM":0.203
      },{
         "System":"Zinc",
         "Gauge":"3",
         "Inch":0.006,
         "MM":0.152
      },{
         "System":"Zinc",
         "Gauge":"2",
         "Inch":0.004,
         "MM":0.102
      },{
         "System":"Zinc",
         "Gauge":"1",
         "Inch":0.002,
         "MM":0.051
      },{
         "System":"Birmingham Gage",
         "Gauge":"0000000",
         "Inch":0.6666,
         "MM":16.932
      },{
         "System":"Birmingham Gage",
         "Gauge":"000000",
         "Inch":0.625,
         "MM":15.875
      },{
         "System":"Birmingham Gage",
         "Gauge":"00000",
         "Inch":0.5883,
         "MM":14.943
      },{
         "System":"Birmingham Gage",
         "Gauge":"0000",
         "Inch":0.5416,
         "MM":13.757
      },{
         "System":"Birmingham Gage",
         "Gauge":"000",
         "Inch":0.5,
         "MM":12.7
      },{
         "System":"Birmingham Gage",
         "Gauge":"00",
         "Inch":0.4452,
         "MM":11.308
      },{
         "System":"Birmingham Gage",
         "Gauge":"0",
         "Inch":0.3964,
         "MM":10.069
      },{
         "System":"Birmingham Gage",
         "Gauge":"1",
         "Inch":0.3532,
         "MM":8.971
      },{
         "System":"Birmingham Gage",
         "Gauge":"2",
         "Inch":0.3147,
         "MM":7.993
      },{
         "System":"Birmingham Gage",
         "Gauge":"3",
         "Inch":0.2804,
         "MM":7.122
      },{
         "System":"Birmingham Gage",
         "Gauge":"4",
         "Inch":0.25,
         "MM":6.35
      },{
         "System":"Birmingham Gage",
         "Gauge":"5",
         "Inch":0.2225,
         "MM":5.652
      },{
         "System":"Birmingham Gage",
         "Gauge":"6",
         "Inch":0.1981,
         "MM":5.032
      },{
         "System":"Birmingham Gage",
         "Gauge":"7",
         "Inch":0.1764,
         "MM":4.481
      },{
         "System":"Birmingham Gage",
         "Gauge":"8",
         "Inch":0.157,
         "MM":3.988
      },{
         "System":"Birmingham Gage",
         "Gauge":"9",
         "Inch":0.1398,
         "MM":3.551
      },{
         "System":"Birmingham Gage",
         "Gauge":"10",
         "Inch":0.125,
         "MM":3.175
      },{
         "System":"Birmingham Gage",
         "Gauge":"11",
         "Inch":0.1113,
         "MM":2.827
      },{
         "System":"Birmingham Gage",
         "Gauge":"12",
         "Inch":0.0991,
         "MM":2.517
      },{
         "System":"Birmingham Gage",
         "Gauge":"13",
         "Inch":0.0882,
         "MM":2.24
      },{
         "System":"Birmingham Gage",
         "Gauge":"14",
         "Inch":0.0785,
         "MM":1.994
      },{
         "System":"Birmingham Gage",
         "Gauge":"15",
         "Inch":0.0699,
         "MM":1.775
      },{
         "System":"Birmingham Gage",
         "Gauge":"16",
         "Inch":0.0625,
         "MM":1.588
      },{
         "System":"Birmingham Gage",
         "Gauge":"17",
         "Inch":0.0556,
         "MM":1.412
      },{
         "System":"Birmingham Gage",
         "Gauge":"18",
         "Inch":0.0495,
         "MM":1.257
      },{
         "System":"Birmingham Gage",
         "Gauge":"19",
         "Inch":0.044,
         "MM":1.118
      },{
         "System":"Birmingham Gage",
         "Gauge":"20",
         "Inch":0.0392,
         "MM":0.996
      },{
         "System":"Birmingham Gage",
         "Gauge":"21",
         "Inch":0.0349,
         "MM":0.886
      },{
         "System":"Birmingham Gage",
         "Gauge":"22",
         "Inch":0.0312,
         "MM":0.792
      },{
         "System":"Birmingham Gage",
         "Gauge":"23",
         "Inch":0.0278,
         "MM":0.706
      },{
         "System":"Birmingham Gage",
         "Gauge":"24",
         "Inch":0.0247,
         "MM":0.627
      },{
         "System":"Birmingham Gage",
         "Gauge":"25",
         "Inch":0.022,
         "MM":0.559
      },{
         "System":"Birmingham Gage",
         "Gauge":"26",
         "Inch":0.0196,
         "MM":0.498
      },{
         "System":"Birmingham Gage",
         "Gauge":"27",
         "Inch":0.0174,
         "MM":0.442
      },{
         "System":"Birmingham Gage",
         "Gauge":"28",
         "Inch":0.0156,
         "MM":0.396
      },{
         "System":"Birmingham Gage",
         "Gauge":"29",
         "Inch":0.0139,
         "MM":0.353
      },{
         "System":"Birmingham Gage",
         "Gauge":"30",
         "Inch":0.0123,
         "MM":0.312
      },{
         "System":"Birmingham Gage",
         "Gauge":"31",
         "Inch":0.011,
         "MM":0.279
      },{
         "System":"Birmingham Gage",
         "Gauge":"32",
         "Inch":0.0098,
         "MM":0.249
      },{
         "System":"Birmingham Gage",
         "Gauge":"33",
         "Inch":0.0087,
         "MM":0.221
      },{
         "System":"Birmingham Gage",
         "Gauge":"34",
         "Inch":0.0077,
         "MM":0.196
      },{
         "System":"Birmingham Gage",
         "Gauge":"35",
         "Inch":0.0069,
         "MM":0.175
      },{
         "System":"Birmingham Gage",
         "Gauge":"36",
         "Inch":0.0061,
         "MM":0.155
      },{
         "System":"Birmingham Gage",
         "Gauge":"37",
         "Inch":0.0054,
         "MM":0.137
      },{
         "System":"Birmingham Gage",
         "Gauge":"38",
         "Inch":0.0048,
         "MM":0.122
      },{
         "System":"Birmingham Gage",
         "Gauge":"39",
         "Inch":0.0043,
         "MM":0.109
      },{
         "System":"Birmingham Gage",
         "Gauge":"40",
         "Inch":0.0038,
         "MM":0.097
      },{
         "System":"Birmingham Gage",
         "Gauge":"41",
         "Inch":0.0034,
         "MM":0.086
      },{
         "System":"Birmingham Gage",
         "Gauge":"42",
         "Inch":0.003,
         "MM":0.076
      },{
         "System":"Birmingham Gage",
         "Gauge":"43",
         "Inch":0.0027,
         "MM":0.069
      },{
         "System":"Birmingham Gage",
         "Gauge":"44",
         "Inch":0.0024,
         "MM":0.061
      },{
         "System":"Birmingham Gage",
         "Gauge":"45",
         "Inch":0.0021,
         "MM":0.053
      },{
         "System":"Birmingham Gage",
         "Gauge":"46",
         "Inch":0.0019,
         "MM":0.048
      },{
         "System":"Birmingham Gage",
         "Gauge":"47",
         "Inch":0.0017,
         "MM":0.043
      },{
         "System":"Birmingham Gage",
         "Gauge":"48",
         "Inch":0.0016,
         "MM":0.041
      },{
         "System":"Birmingham Gage",
         "Gauge":"49",
         "Inch":0.0013,
         "MM":0.033
      },{
         "System":"Birmingham Gage",
         "Gauge":"50",
         "Inch":0.0012,
         "MM":0.03
      },{
         "System":"Birmingham Gage",
         "Gauge":"51",
         "Inch":0.0011,
         "MM":0.028
      },{
         "System":"Birmingham Gage",
         "Gauge":"52",
         "Inch":0.001,
         "MM":0.025
      }]);
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _2125839034Gauges:GWizDataGrid;
      
      private var _1803461041System:DropDownList;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var okFunction:Function = null;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizSheetMetalGauge()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizSheetMetalGauge_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizSheetMetalGaugeWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizSheetMetalGauge[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.width = 500;
         this.title = "Sheet Metal Gauge";
         this.mxmlContent = [this._GWizSheetMetalGauge_VGroup1_c()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizSheetMetalGauge._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      public static function get SheetMetalGauges() : ArrayCollection
      {
         return GWizSheetMetalGauge._619867710SheetMetalGauges;
      }
      
      public static function set SheetMetalGauges(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizSheetMetalGauge._619867710SheetMetalGauges;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizSheetMetalGauge,"SheetMetalGauges",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         var factory:IFlexModuleFactory = param1;
         super.moduleFactory = factory;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
         if(!this.styleDeclaration)
         {
            this.styleDeclaration = new CSSStyleDeclaration(null,styleManager);
         }
         this.styleDeclaration.defaultFactory = function():void
         {
            this.color = 16777215;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function filterGauges(param1:Object) : Boolean
      {
         return param1.System == this.System.selectedItem;
      }
      
      private function doSystem() : void
      {
         SheetMetalGauges.filterFunction = this.filterGauges;
         SheetMetalGauges.refresh();
      }
      
      private function onOK(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         if(param1 && this.okFunction != null)
         {
            _loc2_ = this.Gauges.selectedItem;
            if(_loc2_)
            {
               this.okFunction(_loc2_.Inch);
            }
         }
         super.close();
      }
      
      override public function onOk(param1:Event) : void
      {
         this.onOK(true);
      }
      
      override public function onCancel(param1:Event) : void
      {
         this.onOK(false);
      }
      
      private function _GWizSheetMetalGauge_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizSheetMetalGauge_HGroup1_c(),this._GWizSheetMetalGauge_Spacer1_c(),this._GWizSheetMetalGauge_GWizDataGrid1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSheetMetalGauge_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizSheetMetalGauge_Label1_c(),this._GWizSheetMetalGauge_DropDownList1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSheetMetalGauge_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Material:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSheetMetalGauge_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.selectedIndex = 0;
         _loc1_.typicalItem = "Galvanized Steel";
         _loc1_.dataProvider = this._GWizSheetMetalGauge_ArrayCollection1_c();
         _loc1_.setStyle("color",0);
         _loc1_.addEventListener("valueCommit",this.__System_valueCommit);
         _loc1_.id = "System";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.System = _loc1_;
         BindingManager.executeBindings(this,"System",this.System);
         return _loc1_;
      }
      
      private function _GWizSheetMetalGauge_ArrayCollection1_c() : ArrayCollection
      {
         var _loc1_:ArrayCollection = new ArrayCollection();
         _loc1_.source = ["Standard Steel","Galvanized Steel","Stainless Steel","Aluminum","Zinc","Birmingham Gage"];
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      public function __System_valueCommit(param1:FlexEvent) : void
      {
         this.doSystem();
      }
      
      private function _GWizSheetMetalGauge_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizSheetMetalGauge_GWizDataGrid1_i() : GWizDataGrid
      {
         var _loc1_:GWizDataGrid = new GWizDataGrid();
         _loc1_.configId = "sheetMetalGauges";
         _loc1_.percentWidth = 85;
         _loc1_.percentHeight = 100;
         _loc1_.columns = this._GWizSheetMetalGauge_ArrayList1_c();
         _loc1_.setStyle("color",0);
         _loc1_.id = "Gauges";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Gauges = _loc1_;
         BindingManager.executeBindings(this,"Gauges",this.Gauges);
         return _loc1_;
      }
      
      private function _GWizSheetMetalGauge_ArrayList1_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizSheetMetalGauge_GWizGridColumn1_c(),this._GWizSheetMetalGauge_GWizGridColumn2_c(),this._GWizSheetMetalGauge_GWizGridColumn3_c()];
         return _loc1_;
      }
      
      private function _GWizSheetMetalGauge_GWizGridColumn1_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colGauge";
         _loc1_.dataField = "Gauge";
         return _loc1_;
      }
      
      private function _GWizSheetMetalGauge_GWizGridColumn2_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colInch";
         _loc1_.dataField = "Inch";
         return _loc1_;
      }
      
      private function _GWizSheetMetalGauge_GWizGridColumn3_c() : GWizGridColumn
      {
         var _loc1_:GWizGridColumn = new GWizGridColumn();
         _loc1_.configId = "colMM";
         _loc1_.dataField = "MM";
         return _loc1_;
      }
      
      private function _GWizSheetMetalGauge_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return SheetMetalGauges;
         },null,"Gauges.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Gauges() : GWizDataGrid
      {
         return this._2125839034Gauges;
      }
      
      public function set Gauges(param1:GWizDataGrid) : void
      {
         var _loc2_:Object = this._2125839034Gauges;
         if(_loc2_ !== param1)
         {
            this._2125839034Gauges = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Gauges",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get System() : DropDownList
      {
         return this._1803461041System;
      }
      
      public function set System(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1803461041System;
         if(_loc2_ !== param1)
         {
            this._1803461041System = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"System",_loc2_,param1));
            }
         }
      }
   }
}
