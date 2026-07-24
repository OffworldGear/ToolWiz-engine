package threads2
{
   import configinfo.GWizAbstractPrefs;
   import mx.collections.ArrayCollection;
   import utils.GWizUtils;
   
   public class GWizACMEThreadEngine extends GWizAbstractThreadEngine
   {
      
      public static var isoMetricTrapExtClasses:ArrayCollection = new ArrayCollection([{
         "Class":"c",
         "label":"c"
      },{
         "Class":"e",
         "label":"e"
      }]);
      
      public static var isoMetricTrapIntClasses:ArrayCollection = new ArrayCollection([{
         "Class":"H",
         "label":"H"
      }]);
      
      public static var ACMEStdSizes:ArrayCollection = new ArrayCollection([{
         "Family":"ACME 29°",
         "Size":"​1⁄4",
         "NominalSize":"0.25",
         "TPI":"16"
      },{
         "Family":"ACME 29°",
         "Size":"​5⁄16",
         "NominalSize":"0.3125",
         "TPI":"14"
      },{
         "Family":"ACME 29°",
         "Size":"​3⁄8",
         "NominalSize":"0.375",
         "TPI":"12"
      },{
         "Family":"ACME 29°",
         "Size":"​1⁄2",
         "NominalSize":"0.5",
         "TPI":"10"
      },{
         "Family":"ACME 29°",
         "Size":"​5⁄8",
         "NominalSize":"0.625",
         "TPI":"8"
      },{
         "Family":"ACME 29°",
         "Size":"​3⁄4",
         "NominalSize":"0.75",
         "TPI":"6"
      },{
         "Family":"ACME 29°",
         "Size":"​7⁄8",
         "NominalSize":"0.875",
         "TPI":"6"
      },{
         "Family":"ACME 29°",
         "Size":"1",
         "NominalSize":"1",
         "TPI":"5"
      },{
         "Family":"ACME 29°",
         "Size":"1 ​1⁄4",
         "NominalSize":"1.25",
         "TPI":"5"
      },{
         "Family":"ACME 29°",
         "Size":"1 ​1⁄2",
         "NominalSize":"1.5",
         "TPI":"4"
      },{
         "Family":"ACME 29°",
         "Size":"1 ​3⁄4",
         "NominalSize":"1.75",
         "TPI":"4"
      },{
         "Family":"ACME 29°",
         "Size":"2",
         "NominalSize":"2",
         "TPI":"4"
      },{
         "Family":"ACME 29°",
         "Size":"2 ​1⁄2",
         "NominalSize":"2.5",
         "TPI":"3"
      },{
         "Family":"ACME 29°",
         "Size":"3",
         "NominalSize":"3",
         "TPI":"2"
      }]);
      
      public static const ISO_METRIC_TRAPEZOIDAL:String = "ISO Trapezoidal 30°";
      
      public static var ISOMetricTrapezoidalStdSizes:ArrayCollection = new ArrayCollection([{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR8x1.5",
         "NominalSize":"8",
         "TPI":"16.9333",
         "ExtPitchDiaTol":"0.17",
         "IntPitchDiaTol":"0.224"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR9x1.5",
         "NominalSize":"9",
         "TPI":"16.9333",
         "ExtPitchDiaTol":"0.17",
         "IntPitchDiaTol":"0.224"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR9x2",
         "NominalSize":"9",
         "TPI":"12.7",
         "ExtPitchDiaTol":"0.19",
         "IntPitchDiaTol":"0.25"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR10x1.5",
         "NominalSize":"10",
         "TPI":"16.9333",
         "ExtPitchDiaTol":"0.17",
         "IntPitchDiaTol":"0.224"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR10x2",
         "NominalSize":"10",
         "TPI":"12.7",
         "ExtPitchDiaTol":"0.19",
         "IntPitchDiaTol":"0.25"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR11x2",
         "NominalSize":"11",
         "TPI":"12.7",
         "ExtPitchDiaTol":"0.19",
         "IntPitchDiaTol":"0.25"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR11x3",
         "NominalSize":"11",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.212",
         "IntPitchDiaTol":"0.28"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR12x2",
         "NominalSize":"12",
         "TPI":"12.7",
         "ExtPitchDiaTol":"0.2",
         "IntPitchDiaTol":"0.265"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR12x3",
         "NominalSize":"12",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.224",
         "IntPitchDiaTol":"0.3"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR14x2",
         "NominalSize":"14",
         "TPI":"12.7",
         "ExtPitchDiaTol":"0.2",
         "IntPitchDiaTol":"0.265"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR14x3",
         "NominalSize":"14",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.224",
         "IntPitchDiaTol":"0.3"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR16x2",
         "NominalSize":"16",
         "TPI":"12.7",
         "ExtPitchDiaTol":"0.2",
         "IntPitchDiaTol":"0.265"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR16x3",
         "NominalSize":"16",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.224",
         "IntPitchDiaTol":"0.3"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR16x4",
         "NominalSize":"16",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.265",
         "IntPitchDiaTol":"0.355"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR18x2",
         "NominalSize":"18",
         "TPI":"12.7",
         "ExtPitchDiaTol":"0.2",
         "IntPitchDiaTol":"0.265"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR18x3",
         "NominalSize":"18",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.224",
         "IntPitchDiaTol":"0.3"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR18x4",
         "NominalSize":"18",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.265",
         "IntPitchDiaTol":"0.355"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR20x2",
         "NominalSize":"20",
         "TPI":"12.7",
         "ExtPitchDiaTol":"0.2",
         "IntPitchDiaTol":"0.265"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR20x3",
         "NominalSize":"20",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.224",
         "IntPitchDiaTol":"0.3"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR20x4",
         "NominalSize":"20",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.265",
         "IntPitchDiaTol":"0.355"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR22x3",
         "NominalSize":"22",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.224",
         "IntPitchDiaTol":"0.3"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR22x5",
         "NominalSize":"22",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.28",
         "IntPitchDiaTol":"0.375"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR22x8",
         "NominalSize":"22",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.475"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR24x3",
         "NominalSize":"24",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.25",
         "IntPitchDiaTol":"0.335"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR24x5",
         "NominalSize":"24",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.3",
         "IntPitchDiaTol":"0.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR24x8",
         "NominalSize":"24",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR26x3",
         "NominalSize":"26",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.25",
         "IntPitchDiaTol":"0.335"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR26x5",
         "NominalSize":"26",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.3",
         "IntPitchDiaTol":"0.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR26x8",
         "NominalSize":"26",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR28x3",
         "NominalSize":"28",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.25",
         "IntPitchDiaTol":"0.335"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR28x5",
         "NominalSize":"28",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.3",
         "IntPitchDiaTol":"0.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR28x8",
         "NominalSize":"28",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR30x3",
         "NominalSize":"30",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.25",
         "IntPitchDiaTol":"0.335"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR30x6",
         "NominalSize":"30",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.335",
         "IntPitchDiaTol":"0.45"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR30x10",
         "NominalSize":"30",
         "TPI":"2.54",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.53"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR32x3",
         "NominalSize":"32",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.25",
         "IntPitchDiaTol":"0.335"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR32x6",
         "NominalSize":"32",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.335",
         "IntPitchDiaTol":"0.45"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR32x10",
         "NominalSize":"32",
         "TPI":"2.54",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.53"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR34x3",
         "NominalSize":"34",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.25",
         "IntPitchDiaTol":"0.335"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR34x6",
         "NominalSize":"34",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.335",
         "IntPitchDiaTol":"0.45"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR34x10",
         "NominalSize":"34",
         "TPI":"2.54",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.53"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR36x3",
         "NominalSize":"36",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.25",
         "IntPitchDiaTol":"0.335"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR36x6",
         "NominalSize":"36",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.335",
         "IntPitchDiaTol":"0.45"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR36x10",
         "NominalSize":"36",
         "TPI":"2.54",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.53"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR38x3",
         "NominalSize":"38",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.25",
         "IntPitchDiaTol":"0.335"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR38x7",
         "NominalSize":"38",
         "TPI":"3.6286",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.475"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR38x10",
         "NominalSize":"38",
         "TPI":"2.54",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.53"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR40x3",
         "NominalSize":"40",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.25",
         "IntPitchDiaTol":"0.335"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR40x7",
         "NominalSize":"40",
         "TPI":"3.6286",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.475"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR40x10",
         "NominalSize":"40",
         "TPI":"2.54",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.53"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR42x3",
         "NominalSize":"42",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.25",
         "IntPitchDiaTol":"0.335"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR42x7",
         "NominalSize":"42",
         "TPI":"3.6286",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.475"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR42x10",
         "NominalSize":"42",
         "TPI":"2.54",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.53"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR44x3",
         "NominalSize":"44",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.25",
         "IntPitchDiaTol":"0.335"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR44x7",
         "NominalSize":"44",
         "TPI":"3.6286",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.475"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR44x12",
         "NominalSize":"44",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.425",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR46x3",
         "NominalSize":"46",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.265",
         "IntPitchDiaTol":"0.355"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR46x8",
         "NominalSize":"46",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.53"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR46x12",
         "NominalSize":"46",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.475",
         "IntPitchDiaTol":"0.63"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR48x3",
         "NominalSize":"48",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.265",
         "IntPitchDiaTol":"0.355"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR48x8",
         "NominalSize":"48",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.53"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR48x12",
         "NominalSize":"48",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.475",
         "IntPitchDiaTol":"0.63"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR50x3",
         "NominalSize":"50",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.265",
         "IntPitchDiaTol":"0.355"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR50x8",
         "NominalSize":"50",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.53"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR50x12",
         "NominalSize":"50",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.475",
         "IntPitchDiaTol":"0.63"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR52x3",
         "NominalSize":"52",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.265",
         "IntPitchDiaTol":"0.355"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR52x8",
         "NominalSize":"52",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.53"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR52x12",
         "NominalSize":"52",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.475",
         "IntPitchDiaTol":"0.63"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR55x3",
         "NominalSize":"55",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.265",
         "IntPitchDiaTol":"0.355"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR55x9",
         "NominalSize":"55",
         "TPI":"2.8222",
         "ExtPitchDiaTol":"0.425",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR55x14",
         "NominalSize":"55",
         "TPI":"1.8143",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR60x3",
         "NominalSize":"60",
         "TPI":"8.4667",
         "ExtPitchDiaTol":"0.265",
         "IntPitchDiaTol":"0.355"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR60x9",
         "NominalSize":"60",
         "TPI":"2.8222",
         "ExtPitchDiaTol":"0.425",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR60x14",
         "NominalSize":"60",
         "TPI":"1.8143",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR65x4",
         "NominalSize":"65",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.3",
         "IntPitchDiaTol":"0.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR65x10",
         "NominalSize":"65",
         "TPI":"2.54",
         "ExtPitchDiaTol":"0.425",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR65x16",
         "NominalSize":"65",
         "TPI":"1.5875",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR70x4",
         "NominalSize":"70",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.3",
         "IntPitchDiaTol":"0.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR70x10",
         "NominalSize":"70",
         "TPI":"2.54",
         "ExtPitchDiaTol":"0.425",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR70x16",
         "NominalSize":"70",
         "TPI":"1.5875",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR75x4",
         "NominalSize":"75",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.3",
         "IntPitchDiaTol":"0.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR75x10",
         "NominalSize":"75",
         "TPI":"2.54",
         "ExtPitchDiaTol":"0.425",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR75x16",
         "NominalSize":"75",
         "TPI":"1.5875",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR80x4",
         "NominalSize":"80",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.3",
         "IntPitchDiaTol":"0.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR80x10",
         "NominalSize":"80",
         "TPI":"2.54",
         "ExtPitchDiaTol":"0.425",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR80x16",
         "NominalSize":"80",
         "TPI":"1.5875",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR85x4",
         "NominalSize":"85",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.3",
         "IntPitchDiaTol":"0.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR85x12",
         "NominalSize":"85",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.475",
         "IntPitchDiaTol":"0.63"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR85x18",
         "NominalSize":"85",
         "TPI":"1.4111",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.75"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR90x4",
         "NominalSize":"90",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.3",
         "IntPitchDiaTol":"0.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR90x12",
         "NominalSize":"90",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.475",
         "IntPitchDiaTol":"0.63"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR90x18",
         "NominalSize":"90",
         "TPI":"1.4111",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.75"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR95x4",
         "NominalSize":"95",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.315",
         "IntPitchDiaTol":"0.425"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR95x12",
         "NominalSize":"95",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR95x18",
         "NominalSize":"95",
         "TPI":"1.4111",
         "ExtPitchDiaTol":"0.6",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR100x4",
         "NominalSize":"100",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.315",
         "IntPitchDiaTol":"0.425"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR100x12",
         "NominalSize":"100",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR100x20",
         "NominalSize":"100",
         "TPI":"1.27",
         "ExtPitchDiaTol":"0.6",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR105x4",
         "NominalSize":"105",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.315",
         "IntPitchDiaTol":"0.425"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR105x12",
         "NominalSize":"105",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR105x20",
         "NominalSize":"105",
         "TPI":"1.27",
         "ExtPitchDiaTol":"0.6",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR110x4",
         "NominalSize":"110",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.315",
         "IntPitchDiaTol":"0.425"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR110x12",
         "NominalSize":"110",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR110x20",
         "NominalSize":"110",
         "TPI":"1.27",
         "ExtPitchDiaTol":"0.6",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR115x6",
         "NominalSize":"115",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR115x12",
         "NominalSize":"115",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR115x14",
         "NominalSize":"115",
         "TPI":"1.8143",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR115x22",
         "NominalSize":"115",
         "TPI":"1.1545",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"0.85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR120x6",
         "NominalSize":"120",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR120x12",
         "NominalSize":"120",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR120x14",
         "NominalSize":"120",
         "TPI":"1.8143",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR120x22",
         "NominalSize":"120",
         "TPI":"1.1545",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"0.85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR125x6",
         "NominalSize":"125",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR125x12",
         "NominalSize":"125",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR125x14",
         "NominalSize":"125",
         "TPI":"1.8143",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR125x22",
         "NominalSize":"125",
         "TPI":"1.1545",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"0.85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR130x6",
         "NominalSize":"130",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR130x12",
         "NominalSize":"130",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR130x14",
         "NominalSize":"130",
         "TPI":"1.8143",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR130x22",
         "NominalSize":"130",
         "TPI":"1.1545",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"0.85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR135x6",
         "NominalSize":"135",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR135x12",
         "NominalSize":"135",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR135x14",
         "NominalSize":"135",
         "TPI":"1.8143",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR135x24",
         "NominalSize":"135",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.67",
         "IntPitchDiaTol":"0.9"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR140x6",
         "NominalSize":"140",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR140x12",
         "NominalSize":"140",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR140x14",
         "NominalSize":"140",
         "TPI":"1.8143",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR140x24",
         "NominalSize":"140",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.67",
         "IntPitchDiaTol":"0.9"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR145x6",
         "NominalSize":"145",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR145x12",
         "NominalSize":"145",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR145x14",
         "NominalSize":"145",
         "TPI":"1.8143",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR145x24",
         "NominalSize":"145",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.67",
         "IntPitchDiaTol":"0.9"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR150x6",
         "NominalSize":"150",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR150x12",
         "NominalSize":"150",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR150x16",
         "NominalSize":"150",
         "TPI":"1.5875",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.75"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR150x24",
         "NominalSize":"150",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.67",
         "IntPitchDiaTol":"0.9"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR155x6",
         "NominalSize":"155",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR155x12",
         "NominalSize":"155",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR155x16",
         "NominalSize":"155",
         "TPI":"1.5875",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.75"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR155x24",
         "NominalSize":"155",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.67",
         "IntPitchDiaTol":"0.9"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR160x6",
         "NominalSize":"160",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR160x12",
         "NominalSize":"160",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR160x16",
         "NominalSize":"160",
         "TPI":"1.5875",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.75"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR160x28",
         "NominalSize":"160",
         "TPI":"0.9071",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR165x6",
         "NominalSize":"165",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR165x12",
         "NominalSize":"165",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR165x16",
         "NominalSize":"165",
         "TPI":"1.5875",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.75"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR165x28",
         "NominalSize":"165",
         "TPI":"0.9071",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR170x6",
         "NominalSize":"170",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR170x12",
         "NominalSize":"170",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR170x16",
         "NominalSize":"170",
         "TPI":"1.5875",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.75"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR170x28",
         "NominalSize":"170",
         "TPI":"0.9071",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR175x8",
         "NominalSize":"175",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.425",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR175x12",
         "NominalSize":"175",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR175x16",
         "NominalSize":"175",
         "TPI":"1.5875",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.75"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR175x28",
         "NominalSize":"175",
         "TPI":"0.9071",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR180x8",
         "NominalSize":"180",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.425",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR180x12",
         "NominalSize":"180",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR180x18",
         "NominalSize":"180",
         "TPI":"1.4111",
         "ExtPitchDiaTol":"0.6",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR180x28",
         "NominalSize":"180",
         "TPI":"0.9071",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR185x8",
         "NominalSize":"185",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.45",
         "IntPitchDiaTol":"0.6"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR185x12",
         "NominalSize":"185",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR185x18",
         "NominalSize":"185",
         "TPI":"1.4111",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"0.85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR185x24",
         "NominalSize":"185",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR185x32",
         "NominalSize":"185",
         "TPI":"0.7938",
         "ExtPitchDiaTol":"0.8",
         "IntPitchDiaTol":"1.06"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR190x8",
         "NominalSize":"190",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.45",
         "IntPitchDiaTol":"0.6"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR190x12",
         "NominalSize":"190",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR190x18",
         "NominalSize":"190",
         "TPI":"1.4111",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"0.85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR190x24",
         "NominalSize":"190",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR190x32",
         "NominalSize":"190",
         "TPI":"0.7938",
         "ExtPitchDiaTol":"0.8",
         "IntPitchDiaTol":"1.06"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR195x8",
         "NominalSize":"195",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.45",
         "IntPitchDiaTol":"0.6"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR195x12",
         "NominalSize":"195",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR195x18",
         "NominalSize":"195",
         "TPI":"1.4111",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"0.85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR195x24",
         "NominalSize":"195",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR195x32",
         "NominalSize":"195",
         "TPI":"0.7938",
         "ExtPitchDiaTol":"0.8",
         "IntPitchDiaTol":"1.06"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR200x8",
         "NominalSize":"200",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.45",
         "IntPitchDiaTol":"0.6"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR200x12",
         "NominalSize":"200",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR200x18",
         "NominalSize":"200",
         "TPI":"1.4111",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"0.85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR200x24",
         "NominalSize":"200",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR200x32",
         "NominalSize":"200",
         "TPI":"0.7938",
         "ExtPitchDiaTol":"0.8",
         "IntPitchDiaTol":"1.06"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR205x4",
         "NominalSize":"205",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR210x4",
         "NominalSize":"210",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR210x8",
         "NominalSize":"210",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.45",
         "IntPitchDiaTol":"0.6"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR210x12",
         "NominalSize":"210",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR210x20",
         "NominalSize":"210",
         "TPI":"1.27",
         "ExtPitchDiaTol":"0.67",
         "IntPitchDiaTol":"0.9"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR210x24",
         "NominalSize":"210",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR210x36",
         "NominalSize":"210",
         "TPI":"0.7056",
         "ExtPitchDiaTol":"0.85",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR215x4",
         "NominalSize":"215",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR220x4",
         "NominalSize":"220",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR220x8",
         "NominalSize":"220",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.45",
         "IntPitchDiaTol":"0.6"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR220x12",
         "NominalSize":"220",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR220x20",
         "NominalSize":"220",
         "TPI":"1.27",
         "ExtPitchDiaTol":"0.67",
         "IntPitchDiaTol":"0.9"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR220x24",
         "NominalSize":"220",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR220x36",
         "NominalSize":"220",
         "TPI":"0.7056",
         "ExtPitchDiaTol":"0.85",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR230x4",
         "NominalSize":"230",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR230x8",
         "NominalSize":"230",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.45",
         "IntPitchDiaTol":"0.6"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR230x12",
         "NominalSize":"230",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR230x20",
         "NominalSize":"230",
         "TPI":"1.27",
         "ExtPitchDiaTol":"0.67",
         "IntPitchDiaTol":"0.9"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR230x24",
         "NominalSize":"230",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR230x36",
         "NominalSize":"230",
         "TPI":"0.7056",
         "ExtPitchDiaTol":"0.85",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR235x4",
         "NominalSize":"235",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR240x4",
         "NominalSize":"240",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR240x8",
         "NominalSize":"240",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.45",
         "IntPitchDiaTol":"0.6"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR240x12",
         "NominalSize":"240",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR240x20",
         "NominalSize":"240",
         "TPI":"1.27",
         "ExtPitchDiaTol":"0.67",
         "IntPitchDiaTol":"0.9"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR240x22",
         "NominalSize":"240",
         "TPI":"1.1545",
         "ExtPitchDiaTol":"0.67",
         "IntPitchDiaTol":"0.9"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR240x24",
         "NominalSize":"240",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR240x36",
         "NominalSize":"240",
         "TPI":"0.7056",
         "ExtPitchDiaTol":"0.85",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR250x4",
         "NominalSize":"250",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR250x12",
         "NominalSize":"250",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR250x22",
         "NominalSize":"250",
         "TPI":"1.1545",
         "ExtPitchDiaTol":"0.67",
         "IntPitchDiaTol":"0.9"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR250x24",
         "NominalSize":"250",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR250x40",
         "NominalSize":"250",
         "TPI":"0.635",
         "ExtPitchDiaTol":"0.85",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR260x4",
         "NominalSize":"260",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR260x12",
         "NominalSize":"260",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR260x20",
         "NominalSize":"260",
         "TPI":"1.27",
         "ExtPitchDiaTol":"0.67",
         "IntPitchDiaTol":"0.9"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR260x22",
         "NominalSize":"260",
         "TPI":"1.1545",
         "ExtPitchDiaTol":"0.67",
         "IntPitchDiaTol":"0.9"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR260x24",
         "NominalSize":"260",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR260x40",
         "NominalSize":"260",
         "TPI":"0.635",
         "ExtPitchDiaTol":"0.85",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR270x12",
         "NominalSize":"270",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR270x24",
         "NominalSize":"270",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR270x40",
         "NominalSize":"270",
         "TPI":"0.635",
         "ExtPitchDiaTol":"0.85",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR275x4",
         "NominalSize":"275",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR280x4",
         "NominalSize":"280",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR280x12",
         "NominalSize":"280",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR280x24",
         "NominalSize":"280",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR280x40",
         "NominalSize":"280",
         "TPI":"0.635",
         "ExtPitchDiaTol":"0.85",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR290x4",
         "NominalSize":"290",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR290x12",
         "NominalSize":"290",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR290x24",
         "NominalSize":"290",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR290x44",
         "NominalSize":"290",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.9",
         "IntPitchDiaTol":"1.25"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR295x4",
         "NominalSize":"295",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR300x4",
         "NominalSize":"300",
         "TPI":"6.35",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR300x12",
         "NominalSize":"300",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR300x24",
         "NominalSize":"300",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR300x44",
         "NominalSize":"300",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.9",
         "IntPitchDiaTol":"1.25"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR310x5",
         "NominalSize":"310",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR315x5",
         "NominalSize":"315",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR320x5",
         "NominalSize":"320",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.53"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR320x12",
         "NominalSize":"320",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR320x24",
         "NominalSize":"320",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR320x44",
         "NominalSize":"320",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.9",
         "IntPitchDiaTol":"1.25"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR330x5",
         "NominalSize":"330",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR335x5",
         "NominalSize":"335",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR340x5",
         "NominalSize":"340",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.375",
         "IntPitchDiaTol":"0.53"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR340x12",
         "NominalSize":"340",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.53",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR340x24",
         "NominalSize":"340",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.71",
         "IntPitchDiaTol":"0.95"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR340x28",
         "NominalSize":"340",
         "TPI":"0.9071",
         "ExtPitchDiaTol":"0.75",
         "IntPitchDiaTol":"1"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR340x44",
         "NominalSize":"340",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.9",
         "IntPitchDiaTol":"1.25"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR345x5",
         "NominalSize":"345",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR350x5",
         "NominalSize":"350",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR355x5",
         "NominalSize":"355",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.355",
         "IntPitchDiaTol":"0.5"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR360x5",
         "NominalSize":"360",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR360x12",
         "NominalSize":"360",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR360x24",
         "NominalSize":"360",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.75",
         "IntPitchDiaTol":"1"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR360x28",
         "NominalSize":"360",
         "TPI":"0.9071",
         "ExtPitchDiaTol":"0.8",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR360x44",
         "NominalSize":"360",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR365x5",
         "NominalSize":"365",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR370x5",
         "NominalSize":"370",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR375x5",
         "NominalSize":"375",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR380x5",
         "NominalSize":"380",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR380x12",
         "NominalSize":"380",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR380x24",
         "NominalSize":"380",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.75",
         "IntPitchDiaTol":"1"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR380x28",
         "NominalSize":"380",
         "TPI":"0.9071",
         "ExtPitchDiaTol":"0.8",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR380x32",
         "NominalSize":"380",
         "TPI":"0.7938",
         "ExtPitchDiaTol":"0.85",
         "IntPitchDiaTol":"1.2"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR380x44",
         "NominalSize":"380",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR385x5",
         "NominalSize":"385",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR395x5",
         "NominalSize":"395",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR400x5",
         "NominalSize":"400",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR400x12",
         "NominalSize":"400",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR400x24",
         "NominalSize":"400",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.75",
         "IntPitchDiaTol":"1"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR400x28",
         "NominalSize":"400",
         "TPI":"0.9071",
         "ExtPitchDiaTol":"0.8",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR400x32",
         "NominalSize":"400",
         "TPI":"0.7938",
         "ExtPitchDiaTol":"0.85",
         "IntPitchDiaTol":"1.2"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR400x44",
         "NominalSize":"400",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR410x5",
         "NominalSize":"410",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR415x5",
         "NominalSize":"415",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR420x5",
         "NominalSize":"420",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR420x12",
         "NominalSize":"420",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR420x24",
         "NominalSize":"420",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.75",
         "IntPitchDiaTol":"1"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR420x32",
         "NominalSize":"420",
         "TPI":"0.7938",
         "ExtPitchDiaTol":"0.85",
         "IntPitchDiaTol":"1.2"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR420x44",
         "NominalSize":"420",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR430x5",
         "NominalSize":"430",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR435x5",
         "NominalSize":"435",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR440x5",
         "NominalSize":"440",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR440x12",
         "NominalSize":"440",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR440x24",
         "NominalSize":"440",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.75",
         "IntPitchDiaTol":"1"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR440x32",
         "NominalSize":"440",
         "TPI":"0.7938",
         "ExtPitchDiaTol":"0.85",
         "IntPitchDiaTol":"1.2"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR440x36",
         "NominalSize":"440",
         "TPI":"0.7056",
         "ExtPitchDiaTol":"0.9",
         "IntPitchDiaTol":"1.25"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR440x44",
         "NominalSize":"440",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR450x5",
         "NominalSize":"450",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR460x5",
         "NominalSize":"460",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR460x12",
         "NominalSize":"460",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR460x24",
         "NominalSize":"460",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.75",
         "IntPitchDiaTol":"1"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR460x32",
         "NominalSize":"460",
         "TPI":"0.7938",
         "ExtPitchDiaTol":"0.85",
         "IntPitchDiaTol":"1.2"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR460x36",
         "NominalSize":"460",
         "TPI":"0.7056",
         "ExtPitchDiaTol":"0.9",
         "IntPitchDiaTol":"1.25"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR460x44",
         "NominalSize":"460",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR470x5",
         "NominalSize":"470",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR480x5",
         "NominalSize":"480",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR480x12",
         "NominalSize":"480",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR480x24",
         "NominalSize":"480",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.75",
         "IntPitchDiaTol":"1"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR480x36",
         "NominalSize":"480",
         "TPI":"0.7056",
         "ExtPitchDiaTol":"0.9",
         "IntPitchDiaTol":"1.25"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR480x44",
         "NominalSize":"480",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR490x5",
         "NominalSize":"490",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR500x5",
         "NominalSize":"500",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR500x12",
         "NominalSize":"500",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR500x24",
         "NominalSize":"500",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.75",
         "IntPitchDiaTol":"1"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR500x36",
         "NominalSize":"500",
         "TPI":"0.7056",
         "ExtPitchDiaTol":"0.9",
         "IntPitchDiaTol":"1.25"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR500x40",
         "NominalSize":"500",
         "TPI":"0.635",
         "ExtPitchDiaTol":"0.9",
         "IntPitchDiaTol":"1.25"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR500x44",
         "NominalSize":"500",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR510x6",
         "NominalSize":"510",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR520x6",
         "NominalSize":"520",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR530x5",
         "NominalSize":"530",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR530x6",
         "NominalSize":"530",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR530x12",
         "NominalSize":"530",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR530x24",
         "NominalSize":"530",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.75",
         "IntPitchDiaTol":"1"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR530x40",
         "NominalSize":"530",
         "TPI":"0.635",
         "ExtPitchDiaTol":"0.9",
         "IntPitchDiaTol":"1.25"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR530x44",
         "NominalSize":"530",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR540x6",
         "NominalSize":"540",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR550x6",
         "NominalSize":"550",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR560x5",
         "NominalSize":"560",
         "TPI":"5.08",
         "ExtPitchDiaTol":"0.4",
         "IntPitchDiaTol":"0.56"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR560x12",
         "NominalSize":"560",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR560x24",
         "NominalSize":"560",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.75",
         "IntPitchDiaTol":"1"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR560x40",
         "NominalSize":"560",
         "TPI":"0.635",
         "ExtPitchDiaTol":"0.9",
         "IntPitchDiaTol":"1.25"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR560x44",
         "NominalSize":"560",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR560x45",
         "NominalSize":"560",
         "TPI":"0.5644",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR600x6",
         "NominalSize":"600",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.425",
         "IntPitchDiaTol":"0.6"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR600x12",
         "NominalSize":"600",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR600x24",
         "NominalSize":"600",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.75",
         "IntPitchDiaTol":"1"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR600x40",
         "NominalSize":"600",
         "TPI":"0.635",
         "ExtPitchDiaTol":"0.9",
         "IntPitchDiaTol":"1.25"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR600x44",
         "NominalSize":"600",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR600x45",
         "NominalSize":"600",
         "TPI":"0.5644",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR630x6",
         "NominalSize":"630",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.425",
         "IntPitchDiaTol":"0.6"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR630x12",
         "NominalSize":"630",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR630x24",
         "NominalSize":"630",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.75",
         "IntPitchDiaTol":"1"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR630x44",
         "NominalSize":"630",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR630x45",
         "NominalSize":"630",
         "TPI":"0.5644",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR670x6",
         "NominalSize":"670",
         "TPI":"4.2333",
         "ExtPitchDiaTol":"0.425",
         "IntPitchDiaTol":"0.6"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR670x12",
         "NominalSize":"670",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR670x24",
         "NominalSize":"670",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.75",
         "IntPitchDiaTol":"1"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR670x44",
         "NominalSize":"670",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR670x45",
         "NominalSize":"670",
         "TPI":"0.5644",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR710x7",
         "NominalSize":"710",
         "TPI":"3.6286",
         "ExtPitchDiaTol":"0.45",
         "IntPitchDiaTol":"0.63"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR710x12",
         "NominalSize":"710",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.56",
         "IntPitchDiaTol":"0.8"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR710x24",
         "NominalSize":"710",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.75",
         "IntPitchDiaTol":"1"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR710x44",
         "NominalSize":"710",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"0.95",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR710x50",
         "NominalSize":"710",
         "TPI":"0.508",
         "ExtPitchDiaTol":"1",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR750x7",
         "NominalSize":"750",
         "TPI":"3.6286",
         "ExtPitchDiaTol":"0.475",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR750x12",
         "NominalSize":"750",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR750x24",
         "NominalSize":"750",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.8",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR750x44",
         "NominalSize":"750",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"1.06",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR800x7",
         "NominalSize":"800",
         "TPI":"3.6286",
         "ExtPitchDiaTol":"0.475",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR800x12",
         "NominalSize":"800",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR800x24",
         "NominalSize":"800",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.8",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR800x44",
         "NominalSize":"800",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"1.06",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR850x7",
         "NominalSize":"850",
         "TPI":"3.6286",
         "ExtPitchDiaTol":"0.475",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR850x12",
         "NominalSize":"850",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR850x24",
         "NominalSize":"850",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.8",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR850x44",
         "NominalSize":"850",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"1.06",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR900x7",
         "NominalSize":"900",
         "TPI":"3.6286",
         "ExtPitchDiaTol":"0.475",
         "IntPitchDiaTol":"0.67"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR900x12",
         "NominalSize":"900",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR900x24",
         "NominalSize":"900",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.8",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR900x44",
         "NominalSize":"900",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"1.06",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR950x8",
         "NominalSize":"950",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR950x12",
         "NominalSize":"950",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR950x24",
         "NominalSize":"950",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.8",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR950x44",
         "NominalSize":"950",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"1.06",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR1000x8",
         "NominalSize":"1000",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR1000x12",
         "NominalSize":"1000",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR1000x24",
         "NominalSize":"1000",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.8",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR1000x44",
         "NominalSize":"1000",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"1.06",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR1060x8",
         "NominalSize":"1060",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR1060x12",
         "NominalSize":"1060",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR1060x24",
         "NominalSize":"1060",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.8",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR1060x44",
         "NominalSize":"1060",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"1.06",
         "IntPitchDiaTol":"1.4"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR1120x8",
         "NominalSize":"1120",
         "TPI":"3.175",
         "ExtPitchDiaTol":"0.5",
         "IntPitchDiaTol":"0.71"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR1120x12",
         "NominalSize":"1120",
         "TPI":"2.1167",
         "ExtPitchDiaTol":"0.63",
         "IntPitchDiaTol":"85"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR1120x24",
         "NominalSize":"1120",
         "TPI":"1.0583",
         "ExtPitchDiaTol":"0.8",
         "IntPitchDiaTol":"1.12"
      },{
         "Family":"ISO Trapezoidal 30°",
         "Size":"TR1120x44",
         "NominalSize":"1120",
         "TPI":"0.5773",
         "ExtPitchDiaTol":"1.06",
         "IntPitchDiaTol":"1.4"
      }]);
       
      
      private var acmeClasses:ArrayCollection;
      
      public function GWizACMEThreadEngine()
      {
         var _loc2_:Object = null;
         this.acmeClasses = new ArrayCollection([{"Class":"2G"},{"Class":"3G"},{"Class":"4G"}]);
         var _loc1_:int = 0;
         while(_loc1_ < ISOMetricTrapezoidalStdSizes.length)
         {
            _loc2_ = ISOMetricTrapezoidalStdSizes.getItemAt(_loc1_);
            _loc2_.NominalSize /= 25.4;
            _loc1_++;
         }
         this.initPreferredThreads();
         PremiumThreadFamily["ACME 29°"] = true;
         PremiumThreadFamily["ISO Trapezoidal 30°"] = true;
         super();
      }
      
      private static function basicMOW(param1:Number, param2:Number, param3:Number) : Number
      {
         return param1 - 0.866025 * param2 + 3 * param3;
      }
      
      public function initPreferredThreads() : void
      {
         if(GWizAbstractPrefs.ThreadCalcEnabled)
         {
            if(!PreferredThreads)
            {
               PreferredThreads = ACMEStdSizes;
            }
            else
            {
               PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,ACMEStdSizes);
               PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,ISOMetricTrapezoidalStdSizes);
            }
            if(!GWizUtils.debug)
            {
            }
         }
      }
      
      override public function addlThreadData() : void
      {
         if(Family && Family.indexOf("ISO Trapezoid") >= 0)
         {
            newThreadData("Root Radius",this.isoTrapAc() / 25.4,true,true);
         }
      }
      
      private function isoTrapAc() : Number
      {
         var _loc1_:Number = NaN;
         if(pitchMM < 2)
         {
            _loc1_ = 0.15;
         }
         else if(pitchMM < 6)
         {
            _loc1_ = 0.25;
         }
         else if(pitchMM < 14)
         {
            _loc1_ = 0.5;
         }
         else
         {
            _loc1_ = 1;
         }
         return _loc1_;
      }
      
      override public function selectThread(param1:String, param2:String, param3:Number, param4:Number, param5:String, param6:int, param7:Boolean) : Boolean
      {
         var _loc9_:int = 0;
         var _loc10_:Object = null;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc8_:Boolean = super.selectThread(param1,param2,param3,param4,param5,param6,param7);
         Reference = "ASME B1.5-1997";
         if(Family == ISO_METRIC_TRAPEZOIDAL)
         {
            Reference = "ISO 2904-1977";
         }
         TPISelect = true;
         allowCustomSizeTPI = true;
         TolClass = param5;
         Designation = this.getDesignation();
         _loc10_ = lookupFamilySize(param1,param2);
         ThreadAngle = 29;
         if(Family == ISO_METRIC_TRAPEZOIDAL)
         {
            ThreadAngle = 30;
         }
         EngagementLength = 2 * NomSize;
         if(Family == ISO_METRIC_TRAPEZOIDAL)
         {
            EngagementLength = 8 * Pitch;
         }
         var _loc11_:Number = 0.5 * Pitch;
         var _loc12_:Number = NomSize;
         var _loc13_:Number = NomSize - _loc11_;
         var _loc14_:Number = NomSize - 2 * _loc11_;
         switch(TolClass)
         {
            case "2G":
               PitchDiaTol = 0.03 * Math.sqrt(Pitch) + 0.006 * Math.sqrt(NomSize);
               _loc15_ = 0.008 * Math.sqrt(NomSize);
               break;
            case "3G":
               PitchDiaTol = 0.014 * Math.sqrt(Pitch) + 0.028 * Math.sqrt(NomSize);
               _loc15_ = 0.006 * Math.sqrt(NomSize);
               break;
            case "4G":
            default:
               PitchDiaTol = 0.01 * Math.sqrt(Pitch) + 0.002 * Math.sqrt(NomSize);
               _loc15_ = 0.004 * Math.sqrt(NomSize);
         }
         if(TPI <= 10)
         {
            Allowance = 0.02;
         }
         else
         {
            Allowance = 0.01;
         }
         FltsHeight = _loc11_ + Allowance / 2;
         MinorDiaTol = 1.5 * PitchDiaTol;
         _loc16_ = this.isoTrapAc();
         if(pitchMM <= 3)
         {
            _loc17_ = -(50 + 11 * pitchMM);
         }
         else
         {
            _loc17_ = -47.49 * Math.sqrt(pitchMM);
         }
         if(pitchMM <= 2)
         {
            _loc18_ = -(125 + 11 * pitchMM);
         }
         else
         {
            _loc18_ = -(5 + 94.12 * Math.sqrt(pitchMM));
         }
         if(TolClass.toLowerCase().indexOf("c") >= 0)
         {
            _loc19_ = _loc18_;
         }
         else
         {
            _loc19_ = _loc17_;
         }
         if(Family == ISO_METRIC_TRAPEZOIDAL)
         {
            Allowance = Math.abs(_loc17_ / 1000 / 25.4);
         }
         if(External)
         {
            MajorDiaTol = 0.05 * Pitch;
            MajorDiaTol = Math.max(MajorDiaTol,0.005);
            MaxMajorDia = _loc12_;
            MinMajorDia = MaxMajorDia - MajorDiaTol;
            Flat = 0.3707 * Pitch - 0.259 * (Allowance - _loc15_);
            MinorDiaTol = 0.05 * Pitch;
            _loc21_ = _loc12_ - Pitch / 2;
            MaxPitchDia = _loc21_ - _loc15_;
            MinPitchDia = MaxPitchDia - PitchDiaTol;
            MaxMinorDia = MaxMajorDia - Pitch - Allowance;
            MinMinorDia = MaxMinorDia - MinorDiaTol;
            if(Family == ISO_METRIC_TRAPEZOIDAL)
            {
               MaxMajorDia = NomSize;
               MajorDiaTol = 0.63 * (180 * Math.pow(pitchMM,2 / 3) - 3.15 / Math.sqrt(pitchMM));
               MajorDiaTol = MajorDiaTol / 1000 / 25.4;
               MinMajorDia = MaxMajorDia - MajorDiaTol;
               _loc20_ = this.getLittleD();
               PitchDiaTol = 90 * Math.pow(pitchMM,0.4) * Math.pow(_loc20_,0.1);
               switch(this.pitchDiaTolClass())
               {
                  case 8:
                     PitchDiaTol = 1.6 * PitchDiaTol;
                     break;
                  case 9:
                     PitchDiaTol = 2 * PitchDiaTol;
                     break;
                  default:
                     PitchDiaTol = 1.25 * PitchDiaTol;
               }
               PitchDiaTol = GWizReynardR40.roundR40(PitchDiaTol);
               PitchDiaTol /= 1000;
               if(_loc10_ = lookupFamilySize(Family,Size))
               {
                  PitchDiaTol = _loc10_.ExtPitchDiaTol;
               }
               PitchDiaTol /= 25.4;
               MaxPitchDia = NomSize * 25.4 - 0.5 * pitchMM;
               MaxPitchDia = MinPitchDia = MaxPitchDia / 25.4 - Allowance;
               MinPitchDia -= PitchDiaTol;
               MinorDiaTol = 1.25 * (PitchDiaTol * 25.4 * 1000) + Math.abs(_loc19_);
               MinorDiaTol /= 1000;
               MinorDiaTol /= 25.4;
               _loc14_ = (_loc14_ = NomSize * 25.4 - 2 * (0.5 * pitchMM + _loc16_)) / 25.4;
               MaxMinorDia = _loc14_;
               MinMinorDia = MaxMinorDia - MinorDiaTol;
               FltsHeight = (MaxMajorDia - MaxMinorDia) / 2;
               Flat = (FltsHeight * 25.4 + _loc16_) / Math.cos(GWizUtils.radians(ThreadAngle / 2));
               Flat *= Math.sin(GWizUtils.radians(ThreadAngle / 2));
               Flat = (pitchMM - 2 * Flat) / 2;
               Flat /= 25.4;
            }
            else
            {
               Allowance = _loc15_;
            }
         }
         else
         {
            if(TPI <= 10)
            {
               MajorDiaTol = 0.02;
            }
            else
            {
               MajorDiaTol = 0.01;
            }
            MinorDiaTol = 0.05 * Pitch;
            MinPitchDia = _loc12_ - Pitch / 2;
            MaxPitchDia = MinPitchDia + PitchDiaTol;
            MinMinorDia = _loc12_ - Pitch;
            MaxMinorDia = MinMinorDia + PitchDiaTol;
            MinMajorDia = _loc12_ + Allowance;
            MaxMajorDia = MinMajorDia + MajorDiaTol;
            Flat = 0.3707 * Pitch - 0.259 * Allowance;
            if(Family == ISO_METRIC_TRAPEZOIDAL)
            {
               MaxMajorDia = NomSize + 2 * _loc16_ / 25.4;
               MajorDiaTol = NaN;
               MinMajorDia = NaN;
               _loc20_ = this.getLittleD();
               PitchDiaTol = 90 * Math.pow(pitchMM,0.4) * Math.pow(_loc20_,0.1);
               switch(this.pitchDiaTolClass())
               {
                  case 8:
                     PitchDiaTol = 2.69 * PitchDiaTol;
                     break;
                  case 9:
                     PitchDiaTol = 2.12 * PitchDiaTol;
                     break;
                  default:
                     PitchDiaTol = 1.7 * PitchDiaTol;
               }
               PitchDiaTol = GWizReynardR40.roundR40(PitchDiaTol);
               PitchDiaTol /= 1000;
               if(_loc10_ = lookupFamilySize(Family,Size))
               {
                  PitchDiaTol = _loc10_.IntPitchDiaTol;
               }
               PitchDiaTol /= 25.4;
               MinPitchDia = NomSize - 0.5 * Pitch;
               MaxPitchDia = MinPitchDia + PitchDiaTol;
               MinorDiaTol = 0.63 * 230 * Math.pow(pitchMM,0.7);
               MinorDiaTol /= 1000;
               MinorDiaTol /= 25.4;
               _loc14_ = (_loc14_ = NomSize * 25.4 - pitchMM) / 25.4;
               MinMinorDia = _loc14_;
               MaxMinorDia = MinMinorDia + MinorDiaTol;
               _loc22_ = (_loc22_ = NomSize * 25.4 - 2 * (0.5 * pitchMM + _loc16_)) / 25.4;
               FltsHeight = (NomSize - _loc22_) / 2;
               Flat = (FltsHeight * 25.4 + _loc16_) / Math.cos(GWizUtils.radians(ThreadAngle / 2));
               Flat *= Math.sin(GWizUtils.radians(ThreadAngle / 2));
               Flat = (pitchMM - 2 * Flat) / 2;
               Flat /= 25.4;
            }
         }
         return _loc8_;
      }
      
      private function getLittleD() : Number
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NomSize * 25.4;
         if(_loc3_ < 11.2)
         {
            _loc1_ = Math.min(_loc3_,5.6);
            _loc2_ = 11.2;
         }
         else if(_loc3_ < 22.4)
         {
            _loc1_ = 11.2;
            _loc2_ = 22.4;
         }
         else if(_loc3_ < 45)
         {
            _loc1_ = 22.4;
            _loc2_ = 45;
         }
         else if(_loc3_ < 90)
         {
            _loc1_ = 45;
            _loc2_ = 90;
         }
         else if(_loc3_ < 180)
         {
            _loc1_ = 90;
            _loc2_ = 180;
         }
         else
         {
            _loc1_ = 180;
            _loc2_ = NomSize;
         }
         return Number(Math.sqrt(_loc1_ * _loc2_));
      }
      
      override public function initClassList(param1:Boolean = true) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         showTolClass = true;
         DefaultClassChoice = 2;
         ClassList = this.acmeClasses;
         if(Family == ISO_METRIC_TRAPEZOIDAL)
         {
            DefaultClassChoice = 1;
            if(param1)
            {
               ClassList = GWizUNISOThreadEngine.extClasses;
            }
            else
            {
               ClassList = GWizUNISOThreadEngine.intClasses;
            }
            _loc2_ = 0;
            while(_loc2_ < ClassList.length)
            {
               _loc3_ = ClassList.getItemAt(_loc2_);
               _loc3_.Class = _loc3_.ISO;
               _loc2_++;
            }
         }
         ClassList.refresh();
      }
      
      private function pitchDiaTolClass() : int
      {
         return int(int(TolClass.substr(0,1)));
      }
      
      override public function lookupTPI(param1:String, param2:String) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Object = lookupFamilySize(param1,param2);
         _loc3_ = Number(_loc4_.TPI);
         GWizUtils.assert(!isNaN(_loc3_));
         return _loc3_;
      }
      
      private function getDesignation() : String
      {
         var _loc1_:String = "";
         if(Size != "")
         {
            _loc1_ += Size;
         }
         else
         {
            _loc1_ += String(NomSize);
         }
         if(Family != GWizACMEThreadEngine.ISO_METRIC_TRAPEZOIDAL)
         {
            _loc1_ += "-" + TPI;
            _loc1_ += "-" + "ACME";
            _loc1_ += "-" + TolClass;
         }
         else
         {
            _loc1_ += "-" + TolClass.substr(0,1) + TolClass.substr(2,1);
         }
         return _loc1_;
      }
      
      override public function RecalcMOWLimits(param1:Number) : void
      {
         MinMeasureMOW = basicMOW(MinPitchDia,Pitch,param1);
         MaxMeasureMOW = basicMOW(MaxPitchDia,Pitch,param1);
      }
      
      override public function RecalcMOWPitchDia(param1:Number, param2:Number) : Number
      {
         return param2 + 0.866025 * Pitch - 3 * param1;
      }
   }
}
