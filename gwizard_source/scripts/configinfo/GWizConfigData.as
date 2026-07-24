package configinfo
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import material.GWizMaterialsDB;
   import mx.collections.ArrayCollection;
   import mx.events.PropertyChangeEvent;
   
   public class GWizConfigData implements IEventDispatcher
   {
      
      public static var _1605282041ToolsList:ArrayCollection = new ArrayCollection([{
         "label":"Carbide Parting/Grooving",
         "lathe":"yes",
         "mill":"no",
         "carbide":"yes",
         "chipThin":"no",
         "coating":"yes"
      },{
         "label":"HSS Parting/Grooving",
         "lathe":"yes",
         "mill":"no",
         "carbide":"no",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"Carbide Threading",
         "lathe":"yes",
         "mill":"no",
         "carbide":"yes",
         "chipThin":"no",
         "coating":"yes"
      },{
         "label":"HSS Threading",
         "lathe":"yes",
         "mill":"no",
         "carbide":"no",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"Carbide Boring",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"no",
         "coating":"yes"
      },{
         "label":"HSS Boring",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"no",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"Carbide Endmill",
         "lathe":"no",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"yes",
         "coating":"yes"
      },{
         "label":"Carbide Reamer",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"Carbide Spot Drill",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"Carbide Twist Drill",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"no",
         "coating":"yes"
      },{
         "label":"Cobalt Twist Drill",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"no",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"Gun Drill",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"no",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"HP Carbide Endmill",
         "lathe":"no",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"yes",
         "coating":"yes"
      },{
         "label":"HP Carbide Twist Drill",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"no",
         "coating":"yes"
      },{
         "label":"HP HSS Endmill",
         "lathe":"no",
         "mill":"yes",
         "carbide":"no",
         "chipThin":"yes",
         "coating":"no"
      },{
         "label":"HP HSS Twist Drill",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"no",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"HSS Endmill",
         "lathe":"no",
         "mill":"yes",
         "carbide":"no",
         "chipThin":"yes",
         "coating":"no"
      },{
         "label":"HSS Reamer",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"no",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"Carbide Center Drill",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"HSS Center Drill",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"no",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"Carbide Spade Drill",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"HSS Spade Drill",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"no",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"HSS Spot Drill",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"no",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"HSS Twist Drill",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"no",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"Indexable Drill",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"no",
         "coating":"yes"
      },{
         "label":"Indexable End Or Face Mill",
         "lathe":"no",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"yes",
         "coating":"yes"
      },{
         "label":"Carbide Saws & Woodruff Cutters",
         "lathe":"no",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"HSS Saws & Woodruff Cutters",
         "lathe":"no",
         "mill":"yes",
         "carbide":"no",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"Carbide Tapping",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"HSS Tapping",
         "lathe":"yes",
         "mill":"yes",
         "carbide":"no",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"TiAlN Carbide Endmill",
         "lathe":"no",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"yes",
         "coating":"no"
      },{
         "label":"PCD Endmill",
         "lathe":"no",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"yes",
         "coating":"no"
      },{
         "label":"Carbide Thread Mill",
         "lathe":"no",
         "mill":"yes",
         "carbide":"yes",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"Annular Cutter (Rotabroach®)",
         "lathe":"no",
         "mill":"yes",
         "carbide":"no",
         "chipThin":"no",
         "coating":"no"
      },{
         "label":"Turning: Carbide",
         "lathe":"yes",
         "mill":"no",
         "carbide":"yes",
         "chipThin":"no",
         "coating":"yes"
      },{
         "label":"Turning: HSS",
         "lathe":"yes",
         "mill":"no",
         "carbide":"no",
         "chipThin":"no",
         "coating":"no"
      }]);
      
      public static const CALCULATED_MARKER:String = "@";
      
      public static var ToolAlias:ArrayCollection = new ArrayCollection([{
         "lathe":"Carbide Spot Drill",
         "mill":"Carbide Spot Drill",
         "table":"",
         "calculate":"Carbide Spot Drill"
      },{
         "lathe":"Carbide Spade Drill",
         "mill":"Carbide Spade Drill",
         "table":"",
         "calculate":"Carbide Spade Drill"
      },{
         "lathe":"HSS Reamer",
         "mill":"HSS Reamer",
         "table":"",
         "calculate":"HSS Reamer"
      },{
         "lathe":"Carbide Reamer",
         "mill":"Carbide Reamer",
         "table":"",
         "calculate":"Carbide Reamer"
      },{
         "lathe":"Turning: HSS",
         "mill":"HSS Boring",
         "table":"Turning: HSS"
      },{
         "lathe":"Turning: Carbide",
         "mill":"Carbide Boring",
         "table":"Turning: Carbide"
      }]);
      
      public static var _684363436ToolMaterials:ArrayCollection = new ArrayCollection([{"label":"Carbide"},{"label":"Carbide TiN"},{"label":"Carbide TiCN"},{"label":"Carbide TiAlN"},{"label":"HSS"},{"label":"HSS TiN"},{"label":"HSS TiCN"},{"label":"HSS TiAlN"}]);
      
      private static var lastMaterialIndex:int = -1;
      
      public static var _66936840MachinabilityFactors:ArrayCollection = new ArrayCollection([{
         "material":"Aluminum - Cast",
         "mf":0.32,
         "density":0.0975,
         "minBHN":25,
         "maxBHN":155,
         "dry":0.73,
         "sfmrange":500,
         "sfmrangehss":200,
         "cexp":13,
         "coating":"ZrN, TiN, TiB2, TiAlN",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":1.07,
         "pcdEM":0.98
      },{
         "material":"Aluminum - Wrought (6061)",
         "mf":0.32,
         "density":0.0975,
         "minBHN":20,
         "maxBHN":150,
         "dry":0.73,
         "sfmrange":500,
         "sfmrangehss":200,
         "cexp":13,
         "coating":"ZrN, TiN, TiB2, TiAlN",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":1.08,
         "pcdEM":0.98
      },{
         "material":"Brass",
         "mf":1,
         "density":0.3048,
         "minBHN":100,
         "maxBHN":190,
         "dry":0.83,
         "sfmrange":150,
         "sfmrangehss":75,
         "cexp":10.8,
         "coating":"TiN, TiCN",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":1.38,
         "pcdEM":1.84
      },{
         "material":"Cast Iron - Ductile",
         "mf":1.1,
         "density":0.2604,
         "minBHN":160,
         "maxBHN":330,
         "dry":0.83,
         "sfmrange":100,
         "sfmrangehss":30,
         "cexp":7.5,
         "coating":"TiAlN",
         "drillStyle":"",
         "pointStyle":"conventional or split ",
         "pointAngle":"118 or 135",
         "threadMill":1.5
      },{
         "material":"Cast Iron - Gray",
         "mf":0.6,
         "density":0.2604,
         "minBHN":150,
         "maxBHN":300,
         "dry":0.7,
         "sfmrange":150,
         "sfmrangehss":30,
         "cexp":5.8,
         "coating":"TiAlN",
         "drillStyle":"",
         "pointStyle":"conventional or split ",
         "pointAngle":"118 or 135",
         "threadMill":1.1
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "mf":1.5,
         "density":0.3,
         "minBHN":320,
         "maxBHN":475,
         "dry":0.75,
         "sfmrange":100,
         "sfmrangehss":35,
         "cexp":7.6,
         "coating":"TiAlN,TiN",
         "drillStyle":"",
         "pointStyle":"Split or Notched",
         "pointAngle":"135",
         "threadMill":0.8
      },{
         "material":"Composite: Fiberglass/PC Board",
         "mf":0.1,
         "density":0.04,
         "minBHN":0,
         "maxBHN":0,
         "dry":0.8,
         "sfmrange":0,
         "sfmrangehss":0,
         "cexp":30,
         "coating":"TiAlN",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"90 or 118",
         "threadMill":0.74,
         "pcdEM":0.34
      },{
         "material":"Copper Alloy - Wrought",
         "mf":0.64,
         "density":0.321,
         "minBHN":50,
         "maxBHN":200,
         "dry":0.6,
         "sfmrange":250,
         "sfmrangehss":100,
         "cexp":10.8,
         "coating":"TiN, TiCN",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":0.54,
         "pcdEM":2.32
      },{
         "material":"Graphite",
         "mf":0.21,
         "density":0.0975,
         "minBHN":0,
         "maxBHN":0,
         "dry":0.73,
         "sfmrange":500,
         "sfmrangehss":200,
         "cexp":3.4,
         "coating":"TiAlN",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":0.8,
         "pcdEM":0.84
      },{
         "material":"High Temp Nickel Alloy",
         "mf":2,
         "density":0.315,
         "minBHN":100,
         "maxBHN":400,
         "dry":0.74,
         "sfmrange":20,
         "sfmrangehss":7,
         "cexp":7.9,
         "coating":"TiCN, TiAlN",
         "drillStyle":"HP HSS (Cobalt)",
         "pointStyle":"Split or Notched",
         "pointAngle":"135",
         "threadMill":0.76
      },{
         "material":"Magnesium Alloy",
         "mf":0.16,
         "density":0.0628,
         "minBHN":50,
         "maxBHN":150,
         "dry":0.7,
         "sfmrange":400,
         "sfmrangehss":200,
         "cexp":14,
         "coating":"TiN, TiAlN",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":0.65,
         "pcdEm":1.1
      },{
         "material":"Nickel Alloy",
         "mf":1.9,
         "density":0.31,
         "minBHN":90,
         "maxBHN":190,
         "dry":0.74,
         "sfmrange":100,
         "sfmrangehss":7,
         "cexp":8.1,
         "coating":"TiCN, TiAlN",
         "drillStyle":"HP HSS (Cobalt)",
         "pointStyle":"Split or Notched",
         "pointAngle":"135",
         "threadMill":0.76
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "mf":0.15,
         "density":0.04,
         "minBHN":0,
         "maxBHN":0,
         "dry":0.9,
         "sfmrange":0,
         "sfmrangehss":0,
         "cexp":30,
         "coating":"TiAlN",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"90 or 118",
         "threadMill":0.91,
         "pcdEM":0.77
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "mf":0.08,
         "density":0.04,
         "minBHN":0,
         "maxBHN":0,
         "dry":0.9,
         "sfmrange":0,
         "sfmrangehss":0,
         "cexp":47,
         "coating":"TiAlN",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"90 or 118",
         "threadMill":0.4,
         "pcdEM":0.77
      },{
         "material":"Stainless - 300 Series (316)",
         "mf":1.5,
         "density":0.285,
         "minBHN":135,
         "maxBHN":210,
         "dry":0.77,
         "sfmrange":100,
         "sfmrangehss":40,
         "cexp":9,
         "coating":"TiCN",
         "drillStyle":"",
         "pointStyle":"Split or Notched",
         "pointAngle":"135",
         "threadMill":0.98
      },{
         "material":"Stainless - 400 Series (420)",
         "mf":1.5,
         "density":0.285,
         "minBHN":150,
         "maxBHN":600,
         "dry":0.87,
         "sfmrange":100,
         "sfmrangehss":35,
         "cexp":5.9,
         "coating":"TiAlN",
         "drillStyle":"",
         "pointStyle":"Split or Notched",
         "pointAngle":"135",
         "threadMill":0.98
      },{
         "material":"Stainless - PH Series (17-4)",
         "mf":1.5,
         "density":0.285,
         "minBHN":160,
         "maxBHN":430,
         "dry":0.75,
         "sfmrange":100,
         "sfmrangehss":35,
         "cexp":6.2,
         "coating":"TiAlN",
         "drillStyle":"",
         "pointStyle":"Split or Notched",
         "pointAngle":"135",
         "threadMill":0.98
      },{
         "material":"Steel - Low Carbon (1020)",
         "mf":1.1,
         "density":0.2836,
         "minBHN":90,
         "maxBHN":260,
         "dry":0.75,
         "sfmrange":100,
         "sfmrangehss":90,
         "cexp":7,
         "coating":"TiCN",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":1.11
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "mf":1.1,
         "density":0.2836,
         "minBHN":140,
         "maxBHN":370,
         "dry":0.75,
         "sfmrange":110,
         "sfmrangehss":60,
         "cexp":7,
         "coating":"TiCN",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":1.11
      },{
         "material":"Steel - Medium Carbon (1045)",
         "mf":1.5,
         "density":0.2836,
         "minBHN":180,
         "maxBHN":290,
         "dry":0.75,
         "sfmrange":100,
         "sfmrangehss":33,
         "cexp":7,
         "coating":"TiCN",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":0.92
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "mf":1.8,
         "density":0.2836,
         "minBHN":160,
         "maxBHN":400,
         "dry":0.75,
         "sfmrange":80,
         "sfmrangehss":35,
         "cexp":7,
         "coating":"TiCN, TiAlN",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":0.92
      },{
         "material":"Steel - High Carbon (1090)",
         "mf":1.5,
         "density":0.2836,
         "minBHN":190,
         "maxBHN":300,
         "dry":0.73,
         "sfmrange":100,
         "sfmrangehss":33,
         "cexp":7,
         "coating":"TiAlN",
         "drillStyle":"",
         "pointStyle":"Split or Notched",
         "pointAngle":"135",
         "threadMill":0.85
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "mf":1.8,
         "density":0.2836,
         "minBHN":170,
         "maxBHN":220,
         "dry":0.76,
         "sfmrange":75,
         "sfmrangehss":40,
         "cexp":7,
         "coating":"TiAlN",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":0.78
      },{
         "material":"Steel - Tool (H13)",
         "mf":2.1,
         "density":0.2836,
         "minBHN":200,
         "maxBHN":750,
         "dry":0.7,
         "sfmrange":75,
         "sfmrangehss":25,
         "cexp":7,
         "coating":"TiAlN",
         "drillStyle":"HP HSS (Cobalt)",
         "pointStyle":"Split or Notched",
         "pointAngle":"135",
         "threadMill":0.77
      },{
         "material":"Titanium Alloy",
         "mf":1.1,
         "density":0.1621,
         "minBHN":120,
         "maxBHN":410,
         "dry":0.75,
         "sfmrange":70,
         "sfmrangehss":55,
         "cexp":5.3,
         "coating":"TiAlN",
         "drillStyle":"HP HSS (Cobalt)",
         "pointStyle":"Split or Notched",
         "pointAngle":"135",
         "threadMill":1.5
      },{
         "material":"Tungsten",
         "mf":2.9,
         "density":0.697,
         "minBHN":271,
         "maxBHN":442,
         "dry":0.75,
         "sfmrange":150,
         "sfmrangehss":30,
         "cexp":2.5,
         "coating":"TiAlN",
         "drillStyle":"",
         "pointStyle":"conventional or split ",
         "pointAngle":"118 or 135",
         "threadMill":1.1
      },{
         "material":"Wax",
         "mf":0.15,
         "density":0.03472,
         "minBHN":0,
         "maxBHN":0,
         "dry":1,
         "sfmrange":0,
         "sfmrangehss":0,
         "cexp":3,
         "coating":"Uncoated",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":0.8
      },{
         "material":"Wood: Hardwood",
         "mf":0.15,
         "density":0.0195,
         "minBHN":0,
         "maxBHN":0,
         "dry":1,
         "sfmrange":0,
         "sfmrangehss":0,
         "cexp":3,
         "coating":"Uncoated",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":0.8
      },{
         "material":"Wood: Softwood",
         "mf":0.05,
         "density":0.018,
         "minBHN":0,
         "maxBHN":0,
         "dry":1,
         "sfmrange":0,
         "sfmrangehss":0,
         "cexp":3,
         "coating":"Uncoated",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":0.8
      },{
         "material":"Wood: MDF",
         "mf":0.08,
         "density":0.021,
         "minBHN":0,
         "maxBHN":0,
         "dry":1,
         "sfmrange":0,
         "sfmrangehss":0,
         "cexp":3,
         "coating":"Uncoated",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":0.8
      },{
         "material":"Wood: Plywood",
         "mf":0.08,
         "density":0.021,
         "minBHN":0,
         "maxBHN":0,
         "dry":1,
         "sfmrange":0,
         "sfmrangehss":0,
         "cexp":3,
         "coating":"Uncoated",
         "drillStyle":"",
         "pointStyle":"",
         "pointAngle":"118",
         "threadMill":0.8
      }]);
      
      private static var recurseCt:int = 0;
      
      private static var SFMData:ArrayCollection = new ArrayCollection([{
         "material":"Aluminum - Cast",
         "tool":"HSS Spot Drill",
         "sfm":200,
         "tsc":2
      },{
         "material":"Aluminum - Cast",
         "tool":"HSS Twist Drill",
         "sfm":200,
         "tsc":2
      },{
         "material":"Aluminum - Cast",
         "tool":"Carbide Twist Drill",
         "sfm":450,
         "tsc":2
      },{
         "material":"Aluminum - Cast",
         "tool":"PCD Twist Drill",
         "sfm":1100,
         "tsc":2
      },{
         "material":"Aluminum - Cast",
         "tool":"HSS Spade Drill",
         "sfm":300
      },{
         "material":"Aluminum - Cast",
         "tool":"Gun Drill",
         "sfm":464
      },{
         "material":"Aluminum - Cast",
         "tool":"HSS Endmill",
         "sfm":600,
         "tsc":1.33
      },{
         "material":"Aluminum - Cast",
         "tool":"Carbide Endmill",
         "sfm":900,
         "tsc":1.33
      },{
         "material":"Aluminum - Cast",
         "tool":"HSS Reamer",
         "sfm":150
      },{
         "material":"Aluminum - Cast",
         "tool":"Indexable Drill",
         "sfm":850,
         "tsc":2
      },{
         "material":"Aluminum - Cast",
         "tool":"Cobalt Twist Drill",
         "sfm":220,
         "tsc":2
      },{
         "material":"Aluminum - Cast",
         "tool":"HP HSS Endmill",
         "sfm":660,
         "tsc":1.33
      },{
         "material":"Aluminum - Cast",
         "tool":"HP HSS Twist Drill",
         "sfm":240,
         "tsc":2
      },{
         "material":"Aluminum - Cast",
         "tool":"HP Carbide Endmill",
         "sfm":1170,
         "tsc":1.33
      },{
         "material":"Aluminum - Cast",
         "tool":"TiAlN Carbide Endmill",
         "sfm":1395,
         "tsc":1.33
      },{
         "material":"Aluminum - Cast",
         "tool":"PCD Endmill",
         "sfm":2200,
         "tsc":1
      },{
         "material":"Aluminum - Cast",
         "tool":"HP Carbide Twist Drill",
         "sfm":495,
         "tsc":2
      },{
         "material":"Aluminum - Cast",
         "tool":"Indexable End Or Face Mill",
         "sfm":1080,
         "tsc":1.33
      },{
         "material":"Aluminum - Cast",
         "tool":"Tapping",
         "sfm":50,
         "CarbideCut":3,
         "HSSForm":0.95,
         "CarbideForm":2.5
      },{
         "material":"Aluminum - Cast",
         "tool":"Carbide Thread Mill",
         "sfm":700,
         "tsc":1
      },{
         "material":"Aluminum - Cast",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":725,
         "tsc":1
      },{
         "material":"Aluminum - Cast",
         "tool":"Turning: HSS",
         "sfm":600,
         "tsc":1.33
      },{
         "material":"Aluminum - Cast",
         "tool":"Turning: Carbide",
         "sfm":1800,
         "tsc":1.33
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"HSS Spot Drill",
         "sfm":200,
         "tsc":1.61
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"HSS Twist Drill",
         "sfm":200,
         "tsc":1.61
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"Carbide Twist Drill",
         "sfm":675,
         "tsc":1.61
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"PCD Twist Drill",
         "sfm":1230,
         "tsc":1.61
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"HSS Spade Drill",
         "sfm":300
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"Gun Drill",
         "sfm":464
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"HSS Endmill",
         "sfm":600,
         "tsc":1.13
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"Carbide Endmill",
         "sfm":1200,
         "tsc":1.13
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"HSS Reamer",
         "sfm":150
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"Indexable Drill",
         "sfm":850,
         "tsc":1.61
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"Cobalt Twist Drill",
         "sfm":220,
         "tsc":1.61
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"HP HSS Endmill",
         "sfm":660,
         "tsc":1.13
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"HP HSS Twist Drill",
         "sfm":240,
         "tsc":1.61
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"HP Carbide Endmill",
         "sfm":1560,
         "tsc":1.13
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"TiAlN Carbide Endmill",
         "sfm":1865,
         "tsc":1.13
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"PCD Endmill",
         "sfm":2200,
         "tsc":1
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"HP Carbide Twist Drill",
         "sfm":743,
         "tsc":1.61
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"Indexable End Or Face Mill",
         "sfm":1600,
         "tsc":1.13
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"Tapping",
         "sfm":50,
         "CarbideCut":3.5,
         "HSSForm":0.95,
         "CarbideForm":2.5
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"Carbide Thread Mill",
         "sfm":880,
         "tsc":1
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":725,
         "tsc":1
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"Turning: HSS",
         "sfm":500,
         "tsc":1.13
      },{
         "material":"Aluminum - Wrought (6061)",
         "tool":"Turning: Carbide",
         "sfm":1800,
         "tsc":1.13
      },{
         "material":"Brass",
         "tool":"HSS Spot Drill",
         "sfm":200,
         "tsc":2
      },{
         "material":"Brass",
         "tool":"HSS Twist Drill",
         "sfm":200,
         "tsc":2
      },{
         "material":"Brass",
         "tool":"Carbide Twist Drill",
         "sfm":375,
         "tsc":2
      },{
         "material":"Brass",
         "tool":"PCD Twist Drill",
         "sfm":1030,
         "tsc":2
      },{
         "material":"Brass",
         "tool":"HSS Spade Drill",
         "sfm":125
      },{
         "material":"Brass",
         "tool":"Gun Drill",
         "sfm":406
      },{
         "material":"Brass",
         "tool":"HSS Endmill",
         "sfm":350,
         "tsc":1.75
      },{
         "material":"Brass",
         "tool":"Carbide Endmill",
         "sfm":800,
         "tsc":1.75
      },{
         "material":"Brass",
         "tool":"HSS Reamer",
         "sfm":150
      },{
         "material":"Brass",
         "tool":"Indexable Drill",
         "sfm":680,
         "tsc":2
      },{
         "material":"Brass",
         "tool":"Cobalt Twist Drill",
         "sfm":220,
         "tsc":2
      },{
         "material":"Brass",
         "tool":"HP HSS Endmill",
         "sfm":385,
         "tsc":1.75
      },{
         "material":"Brass",
         "tool":"HP HSS Twist Drill",
         "sfm":240,
         "tsc":2
      },{
         "material":"Brass",
         "tool":"HP Carbide Endmill",
         "sfm":960,
         "tsc":1.75
      },{
         "material":"Brass",
         "tool":"TiAlN Carbide Endmill",
         "sfm":900,
         "tsc":1.75
      },{
         "material":"Brass",
         "tool":"PCD Endmill",
         "sfm":2200,
         "tsc":1
      },{
         "material":"Brass",
         "tool":"HP Carbide Twist Drill",
         "sfm":413,
         "tsc":2
      },{
         "material":"Brass",
         "tool":"Indexable End Or Face Mill",
         "sfm":960,
         "tsc":1.75
      },{
         "material":"Brass",
         "tool":"Tapping",
         "sfm":60,
         "CarbideCut":3,
         "HSSForm":1.21,
         "CarbideForm":1.21
      },{
         "material":"Brass",
         "tool":"Carbide Thread Mill",
         "sfm":660,
         "tsc":1
      },{
         "material":"Brass",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":450,
         "tsc":1
      },{
         "material":"Brass",
         "tool":"Turning: HSS",
         "sfm":250,
         "tsc":1.75
      },{
         "material":"Brass",
         "tool":"Turning: Carbide",
         "sfm":1200,
         "tsc":1.75
      },{
         "material":"Cast Iron - Ductile",
         "tool":"HSS Spot Drill",
         "sfm":75,
         "tsc":2
      },{
         "material":"Cast Iron - Ductile",
         "tool":"HSS Twist Drill",
         "sfm":75,
         "tsc":2
      },{
         "material":"Cast Iron - Ductile",
         "tool":"Carbide Twist Drill",
         "sfm":275,
         "tsc":2
      },{
         "material":"Cast Iron - Ductile",
         "tool":"HSS Spade Drill",
         "sfm":90
      },{
         "material":"Cast Iron - Ductile",
         "tool":"Gun Drill",
         "sfm":200
      },{
         "material":"Cast Iron - Ductile",
         "tool":"HSS Endmill",
         "sfm":90,
         "tsc":2
      },{
         "material":"Cast Iron - Ductile",
         "tool":"Carbide Endmill",
         "sfm":250,
         "tsc":2
      },{
         "material":"Cast Iron - Ductile",
         "tool":"HSS Reamer",
         "sfm":50
      },{
         "material":"Cast Iron - Ductile",
         "tool":"Indexable Drill",
         "sfm":520,
         "tsc":2
      },{
         "material":"Cast Iron - Ductile",
         "tool":"Cobalt Twist Drill",
         "sfm":83,
         "tsc":2
      },{
         "material":"Cast Iron - Ductile",
         "tool":"HP HSS Endmill",
         "sfm":99,
         "tsc":2
      },{
         "material":"Cast Iron - Ductile",
         "tool":"HP HSS Twist Drill",
         "sfm":90,
         "tsc":2
      },{
         "material":"Cast Iron - Ductile",
         "tool":"HP Carbide Endmill",
         "sfm":300,
         "tsc":2
      },{
         "material":"Cast Iron - Ductile",
         "tool":"TiAlN Carbide Endmill",
         "sfm":418,
         "tsc":2
      },{
         "material":"Cast Iron - Ductile",
         "tool":"HP Carbide Twist Drill",
         "sfm":303,
         "tsc":2
      },{
         "material":"Cast Iron - Ductile",
         "tool":"Indexable End Or Face Mill",
         "sfm":300,
         "tsc":2
      },{
         "material":"Cast Iron - Ductile",
         "tool":"Tapping",
         "sfm":40,
         "CarbideCut":3,
         "HSSForm":1.35,
         "CarbideForm":1.35
      },{
         "material":"Cast Iron - Ductile",
         "tool":"Carbide Thread Mill",
         "sfm":310,
         "tsc":1
      },{
         "material":"Cast Iron - Ductile",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":80,
         "tsc":1
      },{
         "material":"Cast Iron - Ductile",
         "tool":"Turning: HSS",
         "sfm":70,
         "tsc":2
      },{
         "material":"Cast Iron - Ductile",
         "tool":"Turning: Carbide",
         "sfm":645,
         "tsc":2
      },{
         "material":"Cast Iron - Gray",
         "tool":"HSS Spot Drill",
         "sfm":100,
         "tsc":2
      },{
         "material":"Cast Iron - Gray",
         "tool":"HSS Twist Drill",
         "sfm":100,
         "tsc":2
      },{
         "material":"Cast Iron - Gray",
         "tool":"Carbide Twist Drill",
         "sfm":350,
         "tsc":2
      },{
         "material":"Cast Iron - Gray",
         "tool":"HSS Spade Drill",
         "sfm":90,
         "tsc":2
      },{
         "material":"Cast Iron - Gray",
         "tool":"Gun Drill",
         "sfm":264
      },{
         "material":"Cast Iron - Gray",
         "tool":"HSS Endmill",
         "sfm":100
      },{
         "material":"Cast Iron - Gray",
         "tool":"Carbide Endmill",
         "sfm":350,
         "tsc":2
      },{
         "material":"Cast Iron - Gray",
         "tool":"HSS Reamer",
         "sfm":65
      },{
         "material":"Cast Iron - Gray",
         "tool":"Indexable Drill",
         "sfm":520,
         "tsc":2
      },{
         "material":"Cast Iron - Gray",
         "tool":"Cobalt Twist Drill",
         "sfm":110,
         "tsc":2
      },{
         "material":"Cast Iron - Gray",
         "tool":"HP HSS Endmill",
         "sfm":110,
         "tsc":2
      },{
         "material":"Cast Iron - Gray",
         "tool":"HP HSS Twist Drill",
         "sfm":120,
         "tsc":2
      },{
         "material":"Cast Iron - Gray",
         "tool":"HP Carbide Endmill",
         "sfm":420,
         "tsc":2
      },{
         "material":"Cast Iron - Gray",
         "tool":"TiAlN Carbide Endmill",
         "sfm":518,
         "tsc":2
      },{
         "material":"Cast Iron - Gray",
         "tool":"HP Carbide Twist Drill",
         "sfm":385,
         "tsc":2
      },{
         "material":"Cast Iron - Gray",
         "tool":"Indexable End Or Face Mill",
         "sfm":420,
         "tsc":2
      },{
         "material":"Cast Iron - Gray",
         "tool":"Tapping",
         "sfm":45,
         "CarbideCut":3,
         "HSSForm":1.35,
         "CarbideForm":1.35
      },{
         "material":"Cast Iron - Gray",
         "tool":"Carbide Thread Mill",
         "sfm":330,
         "tsc":1
      },{
         "material":"Cast Iron - Gray",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":78,
         "tsc":1
      },{
         "material":"Cast Iron - Gray",
         "tool":"Turning: HSS",
         "sfm":80,
         "tsc":2
      },{
         "material":"Cast Iron - Gray",
         "tool":"Turning: Carbide",
         "sfm":650,
         "tsc":2
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"HSS Spot Drill",
         "sfm":30
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"HSS Twist Drill",
         "sfm":30
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"Carbide Twist Drill",
         "sfm":190
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"HSS Spade Drill",
         "sfm":33
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"Gun Drill",
         "sfm":95
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"HSS Endmill",
         "sfm":45
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"Carbide Endmill",
         "sfm":150
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"HSS Reamer",
         "sfm":25
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"Indexable Drill",
         "sfm":230
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"Cobalt Twist Drill",
         "sfm":34
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"HP HSS Endmill",
         "sfm":50
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"HP HSS Twist Drill",
         "sfm":35
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"HP Carbide Endmill",
         "sfm":180
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"TiAlN Carbide Endmill",
         "sfm":200
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"HP Carbide Twist Drill",
         "sfm":212
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"Indexable End Or Face Mill",
         "sfm":198
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"Tapping",
         "sfm":5,
         "CarbideCut":2.5,
         "HSSForm":0,
         "CarbideForm":0
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"Carbide Thread Mill",
         "sfm":100,
         "tsc":1
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":23,
         "tsc":1
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"Turning: HSS",
         "sfm":25
      },{
         "material":"Cobalt Chrome (CoCr ASTM F75)",
         "tool":"Turning: Carbide",
         "sfm":165
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"HSS Spot Drill",
         "sfm":161
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"HSS Twist Drill",
         "sfm":161
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"Carbide Twist Drill",
         "sfm":359
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"PCD Twist Drill",
         "sfm":490
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"HSS Spade Drill",
         "sfm":241
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"Gun Drill",
         "sfm":184
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"HSS Endmill",
         "sfm":483
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"Carbide Endmill",
         "sfm":696
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"HSS Reamer",
         "sfm":117
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"Indexable Drill",
         "sfm":659
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"Cobalt Twist Drill",
         "sfm":175
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"HP HSS Endmill",
         "sfm":512
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"HP HSS Twist Drill",
         "sfm":190
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"HP Carbide Endmill",
         "sfm":879
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"TiAlN Carbide Endmill",
         "sfm":824
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"PCD Endmill",
         "sfm":951
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"HP Carbide Twist Drill",
         "sfm":381
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"Indexable End Or Face Mill",
         "sfm":879
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"Tapping",
         "sfm":30,
         "CarbideCut":3,
         "HSSForm":0,
         "CarbideForm":0
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"Carbide Thread Mill",
         "sfm":319,
         "tsc":1
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":242,
         "tsc":1
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"Turning: HSS",
         "sfm":483
      },{
         "material":"Composite: Fiberglass/PC Board",
         "tool":"Turning: Carbide",
         "sfm":1392
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"HSS Spot Drill",
         "sfm":100,
         "tsc":2
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"HSS Twist Drill",
         "sfm":100,
         "tsc":2
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"Carbide Twist Drill",
         "sfm":375,
         "tsc":2
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"PCD Twist Drill",
         "sfm":1300,
         "tsc":2
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"HSS Spade Drill",
         "sfm":120
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"Gun Drill",
         "sfm":170
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"HSS Endmill",
         "sfm":350,
         "tsc":1.75
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"Carbide Endmill",
         "sfm":600,
         "tsc":1.75
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"HSS Reamer",
         "sfm":55
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"Indexable Drill",
         "sfm":465,
         "tsc":2
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"Cobalt Twist Drill",
         "sfm":110,
         "tsc":2
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"HP HSS Endmill",
         "sfm":385,
         "tsc":1.75
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"HP HSS Twist Drill",
         "sfm":120,
         "tsc":2
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"HP Carbide Endmill",
         "sfm":720
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"TiAlN Carbide Endmill",
         "sfm":900,
         "tsc":1.75
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"PCD Endmill",
         "sfm":2100,
         "tsc":1
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"HP Carbide Twist Drill",
         "sfm":413,
         "tsc":2
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"Indexable End Or Face Mill",
         "sfm":720,
         "tsc":1.75
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"Tapping",
         "sfm":40,
         "CarbideCut":3,
         "HSSForm":1.21,
         "CarbideForm":1.21
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"Carbide Thread Mill",
         "sfm":370,
         "tsc":1
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":175,
         "tsc":1
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"Turning: HSS",
         "sfm":250,
         "tsc":1.75
      },{
         "material":"Copper Alloy - Wrought",
         "tool":"Turning: Carbide",
         "sfm":1200,
         "tsc":1.75
      },{
         "material":"Graphite",
         "tool":"HSS Spot Drill",
         "sfm":166
      },{
         "material":"Graphite",
         "tool":"HSS Twist Drill",
         "sfm":166
      },{
         "material":"Graphite",
         "tool":"Carbide Twist Drill",
         "sfm":560
      },{
         "material":"Graphite",
         "tool":"PCD Twist Drill",
         "sfm":1800
      },{
         "material":"Graphite",
         "tool":"HSS Spade Drill",
         "sfm":249
      },{
         "material":"Graphite",
         "tool":"Gun Drill",
         "sfm":150
      },{
         "material":"Graphite",
         "tool":"HSS Endmill",
         "sfm":498
      },{
         "material":"Graphite",
         "tool":"Carbide Endmill",
         "sfm":996
      },{
         "material":"Graphite",
         "tool":"HSS Reamer",
         "sfm":125
      },{
         "material":"Graphite",
         "tool":"Indexable Drill",
         "sfm":706
      },{
         "material":"Graphite",
         "tool":"Cobalt Twist Drill",
         "sfm":183
      },{
         "material":"Graphite",
         "tool":"HP HSS Endmill",
         "sfm":548
      },{
         "material":"Graphite",
         "tool":"HP HSS Twist Drill",
         "sfm":200
      },{
         "material":"Graphite",
         "tool":"HP Carbide Endmill",
         "sfm":1195
      },{
         "material":"Graphite",
         "tool":"TiAlN Carbide Endmill",
         "sfm":1432
      },{
         "material":"Graphite",
         "tool":"PCD Endmill",
         "sfm":1670
      },{
         "material":"Graphite",
         "tool":"HP Carbide Twist Drill",
         "sfm":617
      },{
         "material":"Graphite",
         "tool":"Indexable End Or Face Mill",
         "sfm":1195
      },{
         "material":"Graphite",
         "tool":"Tapping",
         "sfm":42,
         "CarbideCut":3.5,
         "HSSForm":0.95,
         "CarbideForm":2.5
      },{
         "material":"Graphite",
         "tool":"Carbide Thread Mill",
         "sfm":690,
         "tsc":1
      },{
         "material":"Graphite",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":249,
         "tsc":1
      },{
         "material":"Graphite",
         "tool":"Turning: HSS",
         "sfm":415
      },{
         "material":"Graphite",
         "tool":"Turning: Carbide",
         "sfm":1494
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"HSS Spot Drill",
         "sfm":15,
         "tsc":1.5
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"HSS Twist Drill",
         "sfm":15,
         "tsc":1.5
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"Carbide Twist Drill",
         "sfm":60,
         "tsc":1.5
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"HSS Spade Drill",
         "sfm":15
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"Gun Drill",
         "sfm":90
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"HSS Endmill",
         "sfm":15,
         "tsc":2
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"Carbide Endmill",
         "sfm":60,
         "tsc":2
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"HSS Reamer",
         "sfm":15
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"Indexable Drill",
         "sfm":105,
         "tsc":1.5
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"Cobalt Twist Drill",
         "sfm":17,
         "tsc":1.5
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"HP HSS Endmill",
         "sfm":17,
         "tsc":2
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"HP HSS Twist Drill",
         "sfm":18,
         "tsc":1.5
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"HP Carbide Endmill",
         "sfm":72,
         "tsc":2
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"HP Carbide Endmill",
         "sfm":90,
         "tsc":2
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"TiAlN Carbide Endmill",
         "sfm":96,
         "tsc":2
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"HP Carbide Twist Drill",
         "sfm":66,
         "tsc":1.5
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"Indexable End Or Face Mill",
         "sfm":72,
         "tsc":2
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"Tapping",
         "sfm":10,
         "CarbideCut":2.5,
         "HSSForm":1.5,
         "CarbideForm":1.5
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"Carbide Thread Mill",
         "sfm":70,
         "tsc":1
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":50,
         "tsc":1
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"Turning: HSS",
         "sfm":35,
         "tsc":2
      },{
         "material":"High Temp Nickel Alloy",
         "tool":"Turning: Carbide",
         "sfm":175,
         "tsc":2
      },{
         "material":"Magnesium Alloy",
         "tool":"HSS Spot Drill",
         "sfm":200
      },{
         "material":"Magnesium Alloy",
         "tool":"HSS Twist Drill",
         "sfm":200
      },{
         "material":"Magnesium Alloy",
         "tool":"Carbide Twist Drill",
         "sfm":675
      },{
         "material":"Magnesium Alloy",
         "tool":"PCD Twist Drill",
         "sfm":1230
      },{
         "material":"Magnesium Alloy",
         "tool":"HSS Spade Drill",
         "sfm":350
      },{
         "material":"Magnesium Alloy",
         "tool":"Gun Drill",
         "sfm":450
      },{
         "material":"Magnesium Alloy",
         "tool":"HSS Endmill",
         "sfm":600
      },{
         "material":"Magnesium Alloy",
         "tool":"Carbide Endmill",
         "sfm":1200
      },{
         "material":"Magnesium Alloy",
         "tool":"HSS Reamer",
         "sfm":200
      },{
         "material":"Magnesium Alloy",
         "tool":"Indexable Drill",
         "sfm":1100
      },{
         "material":"Magnesium Alloy",
         "tool":"Cobalt Twist Drill",
         "sfm":220
      },{
         "material":"Magnesium Alloy",
         "tool":"HP HSS Endmill",
         "sfm":660
      },{
         "material":"Magnesium Alloy",
         "tool":"HP HSS Twist Drill",
         "sfm":240
      },{
         "material":"Magnesium Alloy",
         "tool":"HP Carbide Endmill",
         "sfm":1440
      },{
         "material":"Magnesium Alloy",
         "tool":"TiAlN Carbide Endmill",
         "sfm":1200
      },{
         "material":"Magnesium Alloy",
         "tool":"PCD Endmill",
         "sfm":2200
      },{
         "material":"Magnesium Alloy",
         "tool":"HP Carbide Twist Drill",
         "sfm":743
      },{
         "material":"Magnesium Alloy",
         "tool":"Indexable End Or Face Mill",
         "sfm":1440
      },{
         "material":"Magnesium Alloy",
         "tool":"Tapping",
         "sfm":50,
         "CarbideCut":3.5,
         "HSSForm":0,
         "CarbideForm":0
      },{
         "material":"Magnesium Alloy",
         "tool":"Carbide Thread Mill",
         "sfm":1010,
         "tsc":1
      },{
         "material":"Magnesium Alloy",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":600,
         "tsc":1
      },{
         "material":"Magnesium Alloy",
         "tool":"Turning: HSS",
         "sfm":800
      },{
         "material":"Magnesium Alloy",
         "tool":"Turning: Carbide",
         "sfm":1650
      },{
         "material":"Nickel Alloy",
         "tool":"HSS Spot Drill",
         "sfm":55,
         "tsc":1.5
      },{
         "material":"Nickel Alloy",
         "tool":"HSS Twist Drill",
         "sfm":55,
         "tsc":1.5
      },{
         "material":"Nickel Alloy",
         "tool":"Carbide Twist Drill",
         "sfm":175,
         "tsc":1.5
      },{
         "material":"Nickel Alloy",
         "tool":"HSS Spade Drill",
         "sfm":55
      },{
         "material":"Nickel Alloy",
         "tool":"Gun Drill",
         "sfm":150
      },{
         "material":"Nickel Alloy",
         "tool":"HSS Endmill",
         "sfm":45,
         "tsc":2
      },{
         "material":"Nickel Alloy",
         "tool":"Carbide Endmill",
         "sfm":225,
         "tsc":2
      },{
         "material":"Nickel Alloy",
         "tool":"HSS Reamer",
         "sfm":35
      },{
         "material":"Nickel Alloy",
         "tool":"Indexable Drill",
         "sfm":225,
         "tsc":1.5
      },{
         "material":"Nickel Alloy",
         "tool":"Cobalt Twist Drill",
         "sfm":61,
         "tsc":1.5
      },{
         "material":"Nickel Alloy",
         "tool":"HP HSS Endmill",
         "sfm":50,
         "tsc":2
      },{
         "material":"Nickel Alloy",
         "tool":"HP HSS Twist Drill",
         "sfm":66,
         "tsc":1.5,
         "tsc":2
      },{
         "material":"Nickel Alloy",
         "tool":"HP Carbide Endmill",
         "sfm":270,
         "tsc":2
      },{
         "material":"Nickel Alloy",
         "tool":"TiAlN Carbide Endmill",
         "sfm":270,
         "tsc":2
      },{
         "material":"Nickel Alloy",
         "tool":"HP Carbide Twist Drill",
         "sfm":193,
         "tsc":1.5
      },{
         "material":"Nickel Alloy",
         "tool":"Indexable End Or Face Mill",
         "sfm":270,
         "tsc":2
      },{
         "material":"Nickel Alloy",
         "tool":"Tapping",
         "sfm":10,
         "CarbideCut":2.5,
         "HSSForm":2,
         "CarbideForm":2
      },{
         "material":"Nickel Alloy",
         "tool":"Carbide Thread Mill",
         "sfm":120,
         "tsc":1
      },{
         "material":"Nickel Alloy",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":23,
         "tsc":1
      },{
         "material":"Nickel Alloy",
         "tool":"Turning: HSS",
         "sfm":40,
         "tsc":2
      },{
         "material":"Nickel Alloy",
         "tool":"Turning: Carbide",
         "sfm":250,
         "tsc":2
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"HSS Spot Drill",
         "sfm":189
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"HSS Twist Drill",
         "sfm":189
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"Carbide Twist Drill",
         "sfm":422
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"PCD Twist Drill",
         "sfm":720
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"HSS Spade Drill",
         "sfm":284
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"Gun Drill",
         "sfm":288
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"HSS Endmill",
         "sfm":569
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"Carbide Endmill",
         "sfm":820
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"HSS Reamer",
         "sfm":138
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"Indexable Drill",
         "sfm":776
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"Cobalt Twist Drill",
         "sfm":207
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"HP HSS Endmill",
         "sfm":604
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"HP HSS Twist Drill",
         "sfm":224
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"HP Carbide Endmill",
         "sfm":1035
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"TiAlN Carbide Endmill",
         "sfm":971
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"PCD Endmill",
         "sfm":1400
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"HP Carbide Twist Drill",
         "sfm":448
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"Indexable End Or Face Mill",
         "sfm":1035
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"Tapping",
         "sfm":50,
         "CarbideCut":3.5,
         "HSSForm":0,
         "CarbideForm":0
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"Carbide Thread Mill",
         "sfm":500,
         "tsc":1
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":438,
         "tsc":1
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"Turning: HSS",
         "sfm":569
      },{
         "material":GWizMaterialsDB.PLASTICS_HARD,
         "tool":"Turning: Carbide",
         "sfm":1640
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"HSS Spot Drill",
         "sfm":347
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"HSS Twist Drill",
         "sfm":347
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"Carbide Twist Drill",
         "sfm":773
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"PCD Twist Drill",
         "sfm":720
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"HSS Spade Drill",
         "sfm":521
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"Gun Drill",
         "sfm":288
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"HSS Endmill",
         "sfm":1042
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"Carbide Endmill",
         "sfm":1500
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"HSS Reamer",
         "sfm":252
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"Indexable Drill",
         "sfm":1421
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"Cobalt Twist Drill",
         "sfm":378
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"HP HSS Endmill",
         "sfm":1105
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"HP HSS Twist Drill",
         "sfm":410
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"HP Carbide Endmill",
         "sfm":1894
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"TiAlN Carbide Endmill",
         "sfm":1776
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"PCD Endmill",
         "sfm":1400
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"HP Carbide Twist Drill",
         "sfm":821
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"Indexable End Or Face Mill",
         "sfm":1894
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"Tapping",
         "sfm":50,
         "CarbideCut":3.5,
         "HSSForm":0,
         "CarbideForm":0
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"Carbide Thread Mill",
         "sfm":500,
         "tsc":1
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":802,
         "tsc":1
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"Turning: HSS",
         "sfm":750
      },{
         "material":GWizMaterialsDB.PLASTICS_SOFT,
         "tool":"Turning: Carbide",
         "sfm":1640
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"HSS Spot Drill",
         "sfm":45,
         "tsc":2
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"HSS Twist Drill",
         "sfm":45,
         "tsc":2
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"Carbide Twist Drill",
         "sfm":65,
         "tsc":2
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"HSS Spade Drill",
         "sfm":45
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"Gun Drill",
         "sfm":140
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"HSS Endmill",
         "sfm":75,
         "tsc":2
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"Carbide Endmill",
         "sfm":250,
         "tsc":2
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"HSS Reamer",
         "sfm":30
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"Indexable Drill",
         "sfm":345,
         "tsc":2
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"Cobalt Twist Drill",
         "sfm":50,
         "tsc":2
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"HP HSS Endmill",
         "sfm":83,
         "tsc":2
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"HP HSS Twist Drill",
         "sfm":54,
         "tsc":2
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"HP Carbide Endmill",
         "sfm":300,
         "tsc":2
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"TiAlN Carbide Endmill",
         "sfm":300,
         "tsc":2
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"HP Carbide Twist Drill",
         "sfm":379,
         "tsc":2
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"Indexable End Or Face Mill",
         "sfm":300,
         "tsc":2
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"Tapping",
         "sfm":18,
         "CarbideCut":2.5,
         "HSSForm":2,
         "CarbideForm":2.5
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"Carbide Thread Mill",
         "sfm":250,
         "tsc":1
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":55,
         "tsc":1
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"Turning: HSS",
         "sfm":70,
         "tsc":2
      },{
         "material":"Stainless - 300 Series (316)",
         "tool":"Turning: Carbide",
         "sfm":400,
         "tsc":2
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"HSS Spot Drill",
         "sfm":55,
         "tsc":1.07
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"HSS Twist Drill",
         "sfm":55,
         "tsc":1.07
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"Carbide Twist Drill",
         "sfm":70,
         "tsc":1.07
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"HSS Spade Drill",
         "sfm":60
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"Gun Drill",
         "sfm":180
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"HSS Endmill",
         "sfm":85,
         "tsc":1.07
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"Carbide Endmill",
         "sfm":300,
         "tsc":1.07
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"HSS Reamer",
         "sfm":45
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"Indexable Drill",
         "sfm":430,
         "tsc":1.07
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"Cobalt Twist Drill",
         "sfm":61,
         "tsc":1.07
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"HP HSS Endmill",
         "sfm":94,
         "tsc":1.07
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"HP HSS Twist Drill",
         "sfm":66,
         "tsc":1.07
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"HP Carbide Endmill",
         "sfm":360,
         "tsc":1.07
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"TiAlN Carbide Endmill",
         "sfm":390,
         "tsc":1.07
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"HP Carbide Twist Drill",
         "sfm":385,
         "tsc":1.07
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"Indexable End Or Face Mill",
         "sfm":360,
         "tsc":1.07
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"Tapping",
         "sfm":15,
         "CarbideCut":2.5,
         "HSSForm":1.33,
         "CarbideForm":1.33
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"Carbide Thread Mill",
         "sfm":250,
         "tsc":1
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":108,
         "tsc":1
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"Turning: HSS",
         "sfm":60,
         "tsc":1.07
      },{
         "material":"Stainless - 400 Series (420)",
         "tool":"Turning: Carbide",
         "sfm":500,
         "tsc":1.07
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"HSS Spot Drill",
         "sfm":55,
         "tsc":1.07
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"HSS Twist Drill",
         "sfm":55,
         "tsc":1.07
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"Carbide Twist Drill",
         "sfm":70,
         "tsc":1.07
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"HSS Spade Drill",
         "sfm":60
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"Gun Drill",
         "sfm":172
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"HSS Endmill",
         "sfm":85,
         "tsc":1.07
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"Carbide Endmill",
         "sfm":300,
         "tsc":1.07
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"HSS Reamer",
         "sfm":45
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"Indexable Drill",
         "sfm":430,
         "tsc":1.07
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"Cobalt Twist Drill",
         "sfm":61,
         "tsc":1.07
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"HP HSS Endmill",
         "sfm":94,
         "tsc":1.07
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"HP HSS Twist Drill",
         "sfm":66,
         "tsc":1.07
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"HP Carbide Endmill",
         "sfm":360,
         "tsc":1.07
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"TiAlN Carbide Endmill",
         "sfm":360,
         "tsc":1.07
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"HP Carbide Twist Drill",
         "sfm":385,
         "tsc":1.07
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"Indexable End Or Face Mill",
         "sfm":360,
         "tsc":1.07
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"Tapping",
         "sfm":10,
         "CarbideCut":2.5,
         "HSSForm":0,
         "CarbideForm":0
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"Carbide Thread Mill",
         "sfm":290,
         "tsc":1
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":45,
         "tsc":1
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"Turning: HSS",
         "sfm":50,
         "tsc":1.07
      },{
         "material":"Stainless - PH Series (17-4)",
         "tool":"Turning: Carbide",
         "sfm":300,
         "tsc":1.07
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"HSS Spot Drill",
         "sfm":90,
         "tsc":2
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"HSS Twist Drill",
         "sfm":90,
         "tsc":2
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"Carbide Twist Drill",
         "sfm":250,
         "tsc":2
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"HSS Spade Drill",
         "sfm":80
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"Gun Drill",
         "sfm":239
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"HSS Endmill",
         "sfm":160,
         "tsc":2
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"Carbide Endmill",
         "sfm":350,
         "tsc":2
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"HSS Reamer",
         "sfm":50
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"Indexable Drill",
         "sfm":650,
         "tsc":2
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"Cobalt Twist Drill",
         "sfm":99,
         "tsc":2
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"HP HSS Endmill",
         "sfm":176,
         "tsc":2
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"HP HSS Twist Drill",
         "sfm":108,
         "tsc":2
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"HP Carbide Endmill",
         "sfm":420,
         "tsc":2
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"TiAlN Carbide Endmill",
         "sfm":498,
         "tsc":2
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"HP Carbide Twist Drill",
         "sfm":275,
         "tsc":2
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"Indexable End Or Face Mill",
         "sfm":420,
         "tsc":2
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"Tapping",
         "sfm":38,
         "CarbideCut":3,
         "HSSForm":2.11,
         "CarbideForm":2.11
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"Carbide Thread Mill",
         "sfm":390,
         "tsc":1
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":100,
         "tsc":1
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"Turning: HSS",
         "sfm":120,
         "tsc":2
      },{
         "material":"Steel - Low Carbon (1020)",
         "tool":"Turning: Carbide",
         "sfm":800,
         "tsc":2
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"HSS Spot Drill",
         "sfm":60,
         "tsc":2
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"HSS Twist Drill",
         "sfm":60,
         "tsc":2
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"Carbide Twist Drill",
         "sfm":250,
         "tsc":2
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"HSS Spade Drill",
         "sfm":70
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"Gun Drill",
         "sfm":239
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"HSS Endmill",
         "sfm":100,
         "tsc":2
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"Carbide Endmill",
         "sfm":275,
         "tsc":2
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"HSS Reamer",
         "sfm":40
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"Indexable Drill",
         "sfm":480,
         "tsc":2
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"Cobalt Twist Drill",
         "sfm":66,
         "tsc":2
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"HP HSS Endmill",
         "sfm":110,
         "tsc":2
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"HP HSS Twist Drill",
         "sfm":72,
         "tsc":2
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"HP Carbide Endmill",
         "sfm":330,
         "tsc":2
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"TiAlN Carbide Endmill",
         "sfm":529,
         "tsc":2
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"HP Carbide Twist Drill",
         "sfm":275,
         "tsc":2
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"Indexable End Or Face Mill",
         "sfm":330,
         "tsc":2
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"Tapping",
         "sfm":32,
         "CarbideCut":3,
         "HSSForm":1.1875,
         "CarbideForm":2.06
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"Carbide Thread Mill",
         "sfm":250,
         "tsc":1
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":80,
         "tsc":1
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"Turning: HSS",
         "sfm":90,
         "tsc":2
      },{
         "material":"Steel - Low Carbon Alloy (8620)",
         "tool":"Turning: Carbide",
         "sfm":600,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"HSS Spot Drill",
         "sfm":75,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"HSS Twist Drill",
         "sfm":75,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"Carbide Twist Drill",
         "sfm":225,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"HSS Spade Drill",
         "sfm":65
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"Gun Drill",
         "sfm":215
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"HSS Endmill",
         "sfm":85,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"Carbide Endmill",
         "sfm":250,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"HSS Reamer",
         "sfm":40
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"Indexable Drill",
         "sfm":335,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"Cobalt Twist Drill",
         "sfm":83,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"HP HSS Endmill",
         "sfm":94,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"HP HSS Twist Drill",
         "sfm":90,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"HP Carbide Endmill",
         "sfm":300,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"TiAlN Carbide Endmill",
         "sfm":359,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"HP Carbide Twist Drill",
         "sfm":248,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"Indexable End Or Face Mill",
         "sfm":300,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"Tapping",
         "sfm":28,
         "CarbideCut":3,
         "HSSForm":2,
         "CarbideForm":2.5
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"Carbide Thread Mill",
         "sfm":230,
         "tsc":1
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":78,
         "tsc":1
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"Turning: HSS",
         "sfm":70,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon (1045)",
         "tool":"Turning: Carbide",
         "sfm":600,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"HSS Spot Drill",
         "sfm":70,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"HSS Twist Drill",
         "sfm":70,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"Carbide Twist Drill",
         "sfm":225,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"HSS Spade Drill",
         "sfm":65
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"Gun Drill",
         "sfm":200
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"HSS Endmill",
         "sfm":75,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"Carbide Endmill",
         "sfm":200,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"HSS Reamer",
         "sfm":35
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"Indexable Drill",
         "sfm":470,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"Cobalt Twist Drill",
         "sfm":77,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"HP HSS Endmill",
         "sfm":83,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"HP HSS Twist Drill",
         "sfm":84,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"HP Carbide Endmill",
         "sfm":240,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"TiAlN Carbide Endmill",
         "sfm":314,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"HP Carbide Twist Drill",
         "sfm":248,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"Indexable End Or Face Mill",
         "sfm":240,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"Tapping",
         "sfm":26,
         "CarbideCut":3,
         "HSSForm":2,
         "CarbideForm":2.5
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"Carbide Thread Mill",
         "sfm":230,
         "tsc":1
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":65,
         "tsc":1
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"Turning: HSS",
         "sfm":70,
         "tsc":2
      },{
         "material":"Steel - Medium Carbon Alloy (4130)",
         "tool":"Turning: Carbide",
         "sfm":600,
         "tsc":2
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"HSS Spot Drill",
         "sfm":55,
         "tsc":2
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"HSS Twist Drill",
         "sfm":55,
         "tsc":2
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"Carbide Twist Drill",
         "sfm":175,
         "tsc":2
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"HSS Spade Drill",
         "sfm":50
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"Gun Drill",
         "sfm":198
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"HSS Endmill",
         "sfm":80,
         "tsc":2
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"Carbide Endmill",
         "sfm":200,
         "tsc":2
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"HSS Reamer",
         "sfm":35
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"Indexable Drill",
         "sfm":490,
         "tsc":2
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"Cobalt Twist Drill",
         "sfm":61,
         "tsc":2
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"HP HSS Endmill",
         "sfm":88,
         "tsc":2
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"HP HSS Twist Drill",
         "sfm":66,
         "tsc":2
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"HP Carbide Endmill",
         "sfm":240,
         "tsc":2
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"TiAlN Carbide Endmill",
         "sfm":262,
         "tsc":2
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"HP Carbide Twist Drill",
         "sfm":193,
         "tsc":2
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"Indexable End Or Face Mill",
         "sfm":240,
         "tsc":2
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"Tapping",
         "sfm":20,
         "CarbideCut":3,
         "HSSForm":0,
         "CarbideForm":0
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"Carbide Thread Mill",
         "sfm":180,
         "tsc":1
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":40,
         "tsc":1
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"Turning: HSS",
         "sfm":65,
         "tsc":2
      },{
         "material":"Steel - High Carbon (1090)",
         "tool":"Turning: Carbide",
         "sfm":500,
         "tsc":2
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"HSS Spot Drill",
         "sfm":55,
         "tsc":2
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"HSS Twist Drill",
         "sfm":55,
         "tsc":2
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"Carbide Twist Drill",
         "sfm":175,
         "tsc":2
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"HSS Spade Drill",
         "sfm":50
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"Gun Drill",
         "sfm":198
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"HSS Endmill",
         "sfm":75,
         "tsc":2
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"Carbide Endmill",
         "sfm":175,
         "tsc":2
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"HSS Reamer",
         "sfm":35
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"Indexable Drill",
         "sfm":440,
         "tsc":2
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"Cobalt Twist Drill",
         "sfm":61,
         "tsc":2
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"HP HSS Endmill",
         "sfm":83,
         "tsc":2
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"HP HSS Twist Drill",
         "sfm":66,
         "tsc":2
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"HP Carbide Endmill",
         "sfm":210,
         "tsc":2
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"TiAlN Carbide Endmill",
         "sfm":280,
         "tsc":2
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"HP Carbide Twist Drill",
         "sfm":193,
         "tsc":2
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"Indexable End Or Face Mill",
         "sfm":210,
         "tsc":2
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"Tapping",
         "sfm":20,
         "CarbideCut":2.5,
         "HSSForm":0,
         "CarbideForm":0
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"Carbide Thread Mill",
         "sfm":160,
         "tsc":1
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":40,
         "tsc":1
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"Turning: HSS",
         "sfm":60,
         "tsc":2
      },{
         "material":"Steel - High Carbon Alloy (52100)",
         "tool":"Turning: Carbide",
         "sfm":400,
         "tsc":2
      },{
         "material":"Steel - Tool (H13)",
         "tool":"HSS Spot Drill",
         "sfm":45,
         "tsc":2
      },{
         "material":"Steel - Tool (H13)",
         "tool":"HSS Twist Drill",
         "sfm":45,
         "tsc":2
      },{
         "material":"Steel - Tool (H13)",
         "tool":"Carbide Twist Drill",
         "sfm":150,
         "tsc":2
      },{
         "material":"Steel - Tool (H13)",
         "tool":"HSS Spade Drill",
         "sfm":40
      },{
         "material":"Steel - Tool (H13)",
         "tool":"Gun Drill",
         "sfm":175
      },{
         "material":"Steel - Tool (H13)",
         "tool":"HSS Endmill",
         "sfm":80,
         "tsc":2
      },{
         "material":"Steel - Tool (H13)",
         "tool":"Carbide Endmill",
         "sfm":200,
         "tsc":2
      },{
         "material":"Steel - Tool (H13)",
         "tool":"HSS Reamer",
         "sfm":35
      },{
         "material":"Steel - Tool (H13)",
         "tool":"Indexable Drill",
         "sfm":400,
         "tsc":2
      },{
         "material":"Steel - Tool (H13)",
         "tool":"Cobalt Twist Drill",
         "sfm":50,
         "tsc":2
      },{
         "material":"Steel - Tool (H13)",
         "tool":"HP HSS Endmill",
         "sfm":88,
         "tsc":2
      },{
         "material":"Steel - Tool (H13)",
         "tool":"HP HSS Twist Drill",
         "sfm":64,
         "tsc":2
      },{
         "material":"Steel - Tool (H13)",
         "tool":"HP Carbide Endmill",
         "sfm":240,
         "tsc":2
      },{
         "material":"Steel - Tool (H13)",
         "tool":"TiAlN Carbide Endmill",
         "sfm":240,
         "tsc":2
      },{
         "material":"Steel - Tool (H13)",
         "tool":"HP Carbide Twist Drill",
         "sfm":165,
         "tsc":2
      },{
         "material":"Steel - Tool (H13)",
         "tool":"Indexable End Or Face Mill",
         "sfm":240,
         "tsc":2
      },{
         "material":"Steel - Tool (H13)",
         "tool":"Tapping",
         "sfm":20,
         "CarbideCut":2.5,
         "HSSForm":0,
         "CarbideForm":0
      },{
         "material":"Steel - Tool (H13)",
         "tool":"Carbide Thread Mill",
         "sfm":160,
         "tsc":1
      },{
         "material":"Steel - Tool (H13)",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":48,
         "tsc":1
      },{
         "material":"Steel - Tool (H13)",
         "tool":"Turning: HSS",
         "sfm":70,
         "tsc":2
      },{
         "material":"Steel - Tool (H13)",
         "tool":"Turning: Carbide",
         "sfm":400,
         "tsc":2
      },{
         "material":"Titanium Alloy",
         "tool":"HSS Spot Drill",
         "sfm":40,
         "tsc":1.14
      },{
         "material":"Titanium Alloy",
         "tool":"HSS Twist Drill",
         "sfm":40,
         "tsc":1.14
      },{
         "material":"Titanium Alloy",
         "tool":"Carbide Twist Drill",
         "sfm":125,
         "tsc":1.14
      },{
         "material":"Titanium Alloy",
         "tool":"HSS Spade Drill",
         "sfm":45
      },{
         "material":"Titanium Alloy",
         "tool":"Gun Drill",
         "sfm":98
      },{
         "material":"Titanium Alloy",
         "tool":"HSS Endmill",
         "sfm":70,
         "tsc":1.64
      },{
         "material":"Titanium Alloy",
         "tool":"Carbide Endmill",
         "sfm":175,
         "tsc":1.64
      },{
         "material":"Titanium Alloy",
         "tool":"HSS Reamer",
         "sfm":15
      },{
         "material":"Titanium Alloy",
         "tool":"Indexable Drill",
         "sfm":325,
         "tsc":1.14
      },{
         "material":"Titanium Alloy",
         "tool":"Cobalt Twist Drill",
         "sfm":44,
         "tsc":1.14
      },{
         "material":"Titanium Alloy",
         "tool":"HP HSS Endmill",
         "sfm":77,
         "tsc":1.64
      },{
         "material":"Titanium Alloy",
         "tool":"HP HSS Twist Drill",
         "sfm":48,
         "tsc":1.14
      },{
         "material":"Titanium Alloy",
         "tool":"HP Carbide Endmill",
         "sfm":210,
         "tsc":1.64
      },{
         "material":"Titanium Alloy",
         "tool":"TiAlN Carbide Endmill",
         "sfm":230,
         "tsc":1.64
      },{
         "material":"Titanium Alloy",
         "tool":"HP Carbide Twist Drill",
         "sfm":138,
         "tsc":1.14
      },{
         "material":"Titanium Alloy",
         "tool":"Indexable End Or Face Mill",
         "sfm":210,
         "tsc":1.64
      },{
         "material":"Titanium Alloy",
         "tool":"Tapping",
         "sfm":10,
         "CarbideCut":2.5,
         "HSSForm":2,
         "CarbideForm":2
      },{
         "material":"Titanium Alloy",
         "tool":"Carbide Thread Mill",
         "sfm":150,
         "tsc":1
      },{
         "material":"Titanium Alloy",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":35,
         "tsc":1
      },{
         "material":"Titanium Alloy",
         "tool":"Turning: HSS",
         "sfm":60,
         "tsc":1.64
      },{
         "material":"Titanium Alloy",
         "tool":"Turning: Carbide",
         "sfm":200,
         "tsc":1.64
      },{
         "material":"Tungsten",
         "tool":"HSS Spot Drill",
         "sfm":80,
         "tsc":2
      },{
         "material":"Tungsten",
         "tool":"HSS Twist Drill",
         "sfm":80,
         "tsc":2
      },{
         "material":"Tungsten",
         "tool":"Carbide Twist Drill",
         "sfm":270,
         "tsc":2
      },{
         "material":"Tungsten",
         "tool":"HSS Spade Drill",
         "sfm":75,
         "tsc":2
      },{
         "material":"Tungsten",
         "tool":"Gun Drill",
         "sfm":210
      },{
         "material":"Tungsten",
         "tool":"HSS Endmill",
         "sfm":90
      },{
         "material":"Tungsten",
         "tool":"Carbide Endmill",
         "sfm":300,
         "tsc":2
      },{
         "material":"Tungsten",
         "tool":"HSS Reamer",
         "sfm":45
      },{
         "material":"Tungsten",
         "tool":"Indexable Drill",
         "sfm":420,
         "tsc":2
      },{
         "material":"Tungsten",
         "tool":"Cobalt Twist Drill",
         "sfm":80,
         "tsc":2
      },{
         "material":"Tungsten",
         "tool":"HP HSS Endmill",
         "sfm":95,
         "tsc":2
      },{
         "material":"Tungsten",
         "tool":"HP HSS Twist Drill",
         "sfm":90,
         "tsc":2
      },{
         "material":"Tungsten",
         "tool":"HP Carbide Endmill",
         "sfm":360,
         "tsc":2
      },{
         "material":"Tungsten",
         "tool":"TiAlN Carbide Endmill",
         "sfm":409,
         "tsc":2
      },{
         "material":"Tungsten",
         "tool":"HP Carbide Twist Drill",
         "sfm":345,
         "tsc":2
      },{
         "material":"Tungsten",
         "tool":"Indexable End Or Face Mill",
         "sfm":360,
         "tsc":2
      },{
         "material":"Tungsten",
         "tool":"Tapping",
         "sfm":30,
         "CarbideCut":3,
         "HSSForm":1.35,
         "CarbideForm":1.35
      },{
         "material":"Tungsten",
         "tool":"Carbide Thread Mill",
         "sfm":290,
         "tsc":1
      },{
         "material":"Tungsten",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":40,
         "tsc":1
      },{
         "material":"Tungsten",
         "tool":"Turning: HSS",
         "sfm":75,
         "tsc":2
      },{
         "material":"Tungsten",
         "tool":"Turning: Carbide",
         "sfm":525,
         "tsc":2
      },{
         "material":"Wax",
         "tool":"HSS Spot Drill",
         "sfm":729
      },{
         "material":"Wax",
         "tool":"HSS Twist Drill",
         "sfm":729
      },{
         "material":"Wax",
         "tool":"Carbide Twist Drill",
         "sfm":1623
      },{
         "material":"Wax",
         "tool":"HSS Spade Drill",
         "sfm":1094
      },{
         "material":"Wax",
         "tool":"Gun Drill",
         "sfm":288
      },{
         "material":"Wax",
         "tool":"HSS Endmill",
         "sfm":2188
      },{
         "material":"Wax",
         "tool":"Carbide Endmill",
         "sfm":3150
      },{
         "material":"Wax",
         "tool":"HSS Reamer",
         "sfm":252
      },{
         "material":"Wax",
         "tool":"Indexable Drill",
         "sfm":1421
      },{
         "material":"Wax",
         "tool":"Cobalt Twist Drill",
         "sfm":378
      },{
         "material":"Wax",
         "tool":"HP HSS Endmill",
         "sfm":1105
      },{
         "material":"Wax",
         "tool":"HP HSS Twist Drill",
         "sfm":410
      },{
         "material":"Wax",
         "tool":"HP Carbide Endmill",
         "sfm":1894
      },{
         "material":"Wax",
         "tool":"TiAlN Carbide Endmill",
         "sfm":1776
      },{
         "material":"Wax",
         "tool":"HP Carbide Twist Drill",
         "sfm":821
      },{
         "material":"Wax",
         "tool":"Indexable End Or Face Mill",
         "sfm":1894
      },{
         "material":"Wax",
         "tool":"Tapping",
         "sfm":78,
         "CarbideCut":3,
         "HSSForm":0,
         "CarbideForm":0
      },{
         "material":"Wax",
         "tool":"Carbide Thread Mill",
         "sfm":2000,
         "tsc":1
      },{
         "material":"Wax",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":1685,
         "tsc":1
      },{
         "material":"Wax",
         "tool":"Turning: HSS",
         "sfm":1042
      },{
         "material":"Wax",
         "tool":"Turning: Carbide",
         "sfm":3000
      },{
         "material":"Wood: Hardwood",
         "tool":"HSS Spot Drill",
         "sfm":347
      },{
         "material":"Wood: Hardwood",
         "tool":"HSS Twist Drill",
         "sfm":347
      },{
         "material":"Wood: Hardwood",
         "tool":"Carbide Twist Drill",
         "sfm":773
      },{
         "material":"Wood: Hardwood",
         "tool":"HSS Spade Drill",
         "sfm":521
      },{
         "material":"Wood: Hardwood",
         "tool":"Gun Drill",
         "sfm":288
      },{
         "material":"Wood: Hardwood",
         "tool":"HSS Endmill",
         "sfm":1042
      },{
         "material":"Wood: Hardwood",
         "tool":"Carbide Endmill",
         "sfm":1500
      },{
         "material":"Wood: Hardwood",
         "tool":"HSS Reamer",
         "sfm":252
      },{
         "material":"Wood: Hardwood",
         "tool":"Indexable Drill",
         "sfm":1421
      },{
         "material":"Wood: Hardwood",
         "tool":"Cobalt Twist Drill",
         "sfm":378
      },{
         "material":"Wood: Hardwood",
         "tool":"HP HSS Endmill",
         "sfm":1105
      },{
         "material":"Wood: Hardwood",
         "tool":"HP HSS Twist Drill",
         "sfm":410
      },{
         "material":"Wood: Hardwood",
         "tool":"HP Carbide Endmill",
         "sfm":1894
      },{
         "material":"Wood: Hardwood",
         "tool":"TiAlN Carbide Endmill",
         "sfm":1776
      },{
         "material":"Wood: Hardwood",
         "tool":"HP Carbide Twist Drill",
         "sfm":821
      },{
         "material":"Wood: Hardwood",
         "tool":"Indexable End Or Face Mill",
         "sfm":8000
      },{
         "material":"Wood: Hardwood",
         "tool":"Tapping",
         "sfm":78,
         "CarbideCut":3,
         "HSSForm":0,
         "CarbideForm":0
      },{
         "material":"Wood: Hardwood",
         "tool":"Carbide Thread Mill",
         "sfm":1050,
         "tsc":1
      },{
         "material":"Wood: Hardwood",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":802,
         "tsc":1
      },{
         "material":"Wood: Hardwood",
         "tool":"Turning: HSS",
         "sfm":1042
      },{
         "material":"Wood: Hardwood",
         "tool":"Turning: Carbide",
         "sfm":3000
      },{
         "material":"Wood: MDF",
         "tool":"HSS Spot Drill",
         "sfm":347
      },{
         "material":"Wood: MDF",
         "tool":"HSS Twist Drill",
         "sfm":347
      },{
         "material":"Wood: MDF",
         "tool":"Carbide Twist Drill",
         "sfm":773
      },{
         "material":"Wood: MDF",
         "tool":"HSS Spade Drill",
         "sfm":521
      },{
         "material":"Wood: MDF",
         "tool":"Gun Drill",
         "sfm":288
      },{
         "material":"Wood: MDF",
         "tool":"HSS Endmill",
         "sfm":1042
      },{
         "material":"Wood: MDF",
         "tool":"Carbide Endmill",
         "sfm":1500
      },{
         "material":"Wood: MDF",
         "tool":"HSS Reamer",
         "sfm":252
      },{
         "material":"Wood: MDF",
         "tool":"Indexable Drill",
         "sfm":1421
      },{
         "material":"Wood: MDF",
         "tool":"Cobalt Twist Drill",
         "sfm":378
      },{
         "material":"Wood: MDF",
         "tool":"HP HSS Endmill",
         "sfm":1105
      },{
         "material":"Wood: MDF",
         "tool":"HP HSS Twist Drill",
         "sfm":410
      },{
         "material":"Wood: MDF",
         "tool":"HP Carbide Endmill",
         "sfm":1894
      },{
         "material":"Wood: MDF",
         "tool":"TiAlN Carbide Endmill",
         "sfm":1776
      },{
         "material":"Wood: MDF",
         "tool":"HP Carbide Twist Drill",
         "sfm":821
      },{
         "material":"Wood: MDF",
         "tool":"Indexable End Or Face Mill",
         "sfm":8000
      },{
         "material":"Wood: MDF",
         "tool":"Tapping",
         "sfm":78,
         "CarbideCut":3,
         "HSSForm":0,
         "CarbideForm":0
      },{
         "material":"Wood: MDF",
         "tool":"Carbide Thread Mill",
         "sfm":1050,
         "tsc":1
      },{
         "material":"Wood: MDF",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":802,
         "tsc":1
      },{
         "material":"Wood: MDF",
         "tool":"Turning: HSS",
         "sfm":1042
      },{
         "material":"Wood: MDF",
         "tool":"Turning: Carbide",
         "sfm":3000
      },{
         "material":"Wood: Plywood",
         "tool":"HSS Spot Drill",
         "sfm":347
      },{
         "material":"Wood: Plywood",
         "tool":"HSS Twist Drill",
         "sfm":347
      },{
         "material":"Wood: Plywood",
         "tool":"Carbide Twist Drill",
         "sfm":773
      },{
         "material":"Wood: Plywood",
         "tool":"HSS Spade Drill",
         "sfm":521
      },{
         "material":"Wood: Plywood",
         "tool":"Gun Drill",
         "sfm":288
      },{
         "material":"Wood: Plywood",
         "tool":"HSS Endmill",
         "sfm":1042
      },{
         "material":"Wood: Plywood",
         "tool":"Carbide Endmill",
         "sfm":1500
      },{
         "material":"Wood: Plywood",
         "tool":"HSS Reamer",
         "sfm":252
      },{
         "material":"Wood: Plywood",
         "tool":"Indexable Drill",
         "sfm":1421
      },{
         "material":"Wood: Plywood",
         "tool":"Cobalt Twist Drill",
         "sfm":378
      },{
         "material":"Wood: Plywood",
         "tool":"HP HSS Endmill",
         "sfm":1105
      },{
         "material":"Wood: Plywood",
         "tool":"HP HSS Twist Drill",
         "sfm":410
      },{
         "material":"Wood: Plywood",
         "tool":"HP Carbide Endmill",
         "sfm":1894
      },{
         "material":"Wood: Plywood",
         "tool":"TiAlN Carbide Endmill",
         "sfm":1776
      },{
         "material":"Wood: Plywood",
         "tool":"HP Carbide Twist Drill",
         "sfm":821
      },{
         "material":"Wood: Plywood",
         "tool":"Indexable End Or Face Mill",
         "sfm":8000
      },{
         "material":"Wood: Plywood",
         "tool":"Tapping",
         "sfm":78,
         "CarbideCut":3,
         "HSSForm":0,
         "CarbideForm":0
      },{
         "material":"Wood: Plywood",
         "tool":"Carbide Thread Mill",
         "sfm":1050,
         "tsc":1
      },{
         "material":"Wood: Plywood",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":802,
         "tsc":1
      },{
         "material":"Wood: Plywood",
         "tool":"Turning: HSS",
         "sfm":1042
      },{
         "material":"Wood: Plywood",
         "tool":"Turning: Carbide",
         "sfm":3000
      },{
         "material":"Wood: Softwood",
         "tool":"HSS Spot Drill",
         "sfm":347
      },{
         "material":"Wood: Softwood",
         "tool":"HSS Twist Drill",
         "sfm":347
      },{
         "material":"Wood: Softwood",
         "tool":"Carbide Twist Drill",
         "sfm":773
      },{
         "material":"Wood: Softwood",
         "tool":"HSS Spade Drill",
         "sfm":521
      },{
         "material":"Wood: Softwood",
         "tool":"Gun Drill",
         "sfm":288
      },{
         "material":"Wood: Softwood",
         "tool":"HSS Endmill",
         "sfm":1042
      },{
         "material":"Wood: Softwood",
         "tool":"Carbide Endmill",
         "sfm":1500
      },{
         "material":"Wood: Softwood",
         "tool":"HSS Reamer",
         "sfm":252
      },{
         "material":"Wood: Softwood",
         "tool":"Indexable Drill",
         "sfm":1421
      },{
         "material":"Wood: Softwood",
         "tool":"Cobalt Twist Drill",
         "sfm":378
      },{
         "material":"Wood: Softwood",
         "tool":"HP HSS Endmill",
         "sfm":1105
      },{
         "material":"Wood: Softwood",
         "tool":"HP HSS Twist Drill",
         "sfm":410
      },{
         "material":"Wood: Softwood",
         "tool":"HP Carbide Endmill",
         "sfm":1894
      },{
         "material":"Wood: Softwood",
         "tool":"TiAlN Carbide Endmill",
         "sfm":1776
      },{
         "material":"Wood: Softwood",
         "tool":"HP Carbide Twist Drill",
         "sfm":821
      },{
         "material":"Wood: Softwood",
         "tool":"Indexable End Or Face Mill",
         "sfm":8000
      },{
         "material":"Wood: Softwood",
         "tool":"Tapping",
         "sfm":78,
         "CarbideCut":3,
         "HSSForm":0,
         "CarbideForm":0
      },{
         "material":"Wood: Softwood",
         "tool":"Carbide Thread Mill",
         "sfm":1050,
         "tsc":1
      },{
         "material":"Wood: Softwood",
         "tool":"Annular Cutter (Rotabroach®)",
         "sfm":802,
         "tsc":1
      },{
         "material":"Wood: Softwood",
         "tool":"Turning: HSS",
         "sfm":1042
      },{
         "material":"Wood: Softwood",
         "tool":"Turning: Carbide",
         "sfm":3000
      }]);
      
      public static var drillDataFields:Array = ["metric","inch","designation","note","pct","td","eminch","emmm"];
      
      public static var _356480645DrillData:ArrayCollection = new ArrayCollection([{
         "metric":"0.0483 mm",
         "inch":0.0019,
         "designation":"#107",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.05 mm",
         "inch":0.002,
         "designation":"0.05 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.0584 mm",
         "inch":0.0023,
         "designation":"#106",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.0686 mm",
         "inch":0.0027,
         "designation":"#105",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.0787 mm",
         "inch":0.0031,
         "designation":"#104",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.0889 mm",
         "inch":0.0035,
         "designation":"#103",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.0991 mm",
         "inch":0.0039,
         "designation":"#102",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.1 mm",
         "inch":0.0039,
         "designation":"0.1 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.1092 mm",
         "inch":0.0043,
         "designation":"#101",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.1194 mm",
         "inch":0.0047,
         "designation":"#100",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.1295 mm",
         "inch":0.0051,
         "designation":"#99",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.1397 mm",
         "inch":0.0055,
         "designation":"#98",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.1499 mm",
         "inch":0.0059,
         "designation":"#97",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.16 mm",
         "inch":0.0063,
         "designation":"#96",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.1702 mm",
         "inch":0.0067,
         "designation":"#95",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.1803 mm",
         "inch":0.0071,
         "designation":"#94",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.1905 mm",
         "inch":0.0075,
         "designation":"#93",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.2 mm",
         "inch":0.0079,
         "designation":"0.2 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.2007 mm",
         "inch":0.0079,
         "designation":"#92",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.2108 mm",
         "inch":0.0083,
         "designation":"#91",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.221 mm",
         "inch":0.0087,
         "designation":"#90",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.2311 mm",
         "inch":0.0091,
         "designation":"#89",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.2413 mm",
         "inch":0.0095,
         "designation":"#88",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.25 mm",
         "inch":0.0098,
         "designation":"0.25 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.254 mm",
         "inch":0.01,
         "designation":"#87",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.2667 mm",
         "inch":0.0105,
         "designation":"#86",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.2794 mm",
         "inch":0.011,
         "designation":"#85",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.2921 mm",
         "inch":0.0115,
         "designation":"#84",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.3 mm",
         "inch":0.0118,
         "designation":"0.3 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.3048 mm",
         "inch":0.012,
         "designation":"#83",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.3175 mm",
         "inch":0.0125,
         "designation":"#82",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.32 mm",
         "inch":0.0126,
         "designation":"0.32 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"0.3302 mm",
         "inch":0.013,
         "designation":"#81",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".3429 mm",
         "inch":0.0135,
         "designation":"#80",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".3683 mm",
         "inch":0.0145,
         "designation":"#79",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".3969 mm",
         "inch":0.015625,
         "designation":"1/64\"",
         "note":"#0 Pilot, Soft-Wood",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":".4064 mm",
         "inch":0.016,
         "designation":"#78",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".4572 mm",
         "inch":0.018,
         "designation":"#77",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".5 mm",
         "inch":0.0197,
         "designation":".5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":".508 mm",
         "inch":0.02,
         "designation":"#76",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".5334 mm",
         "inch":0.021,
         "designation":"#75",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".5715 mm",
         "inch":0.0225,
         "designation":"#74",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".6096 mm",
         "inch":0.024,
         "designation":"#73",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".635 mm",
         "inch":0.025,
         "designation":"#72",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".6604 mm",
         "inch":0.026,
         "designation":"#71",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".7112 mm",
         "inch":0.028,
         "designation":"#70",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".74168 mm",
         "inch":0.0292,
         "designation":"#69",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".75 mm",
         "inch":0.0295,
         "designation":".75 mm",
         "note":"M1x.25 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".7874 mm",
         "inch":0.031,
         "designation":"#68",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".7938 mm",
         "inch":0.03125,
         "designation":"1/32\"",
         "note":"#0 Pilot, Hard-Wood #1 Pilot, Hard & Soft-Wood #2 Pilot, Soft-Wood",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":".8128 mm",
         "inch":0.032,
         "designation":"#67",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".8382 mm",
         "inch":0.033,
         "designation":"#66",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".85 mm",
         "inch":0.0335,
         "designation":".85 mm",
         "note":"M1.1x.25 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".889 mm",
         "inch":0.035,
         "designation":"#65",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".9144 mm",
         "inch":0.036,
         "designation":"#64",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".9398 mm",
         "inch":0.037,
         "designation":"#63",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".95 mm",
         "inch":0.0374,
         "designation":".95 mm",
         "note":"M1.2x.25 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".9652 mm",
         "inch":0.038,
         "designation":"#62",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":".9906 mm",
         "inch":0.039,
         "designation":"#61",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1 mm",
         "inch":0.0394,
         "designation":"1 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"1.016 mm",
         "inch":0.04,
         "designation":"#60",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.0414 mm",
         "inch":0.041,
         "designation":"#59",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.0668 mm",
         "inch":0.042,
         "designation":"#58",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.0922 mm",
         "inch":0.043,
         "designation":"#57",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.1 mm",
         "inch":0.0433,
         "designation":"1.1 mm",
         "note":"M1.4x.3 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.1811 mm",
         "inch":0.0465,
         "designation":"#56",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.1906 mm",
         "inch":0.046875,
         "designation":"3/64\"",
         "note":"#0-80 UNF#2 Pilot, Hard-wood, #3 Pilot, Soft-Wood #4 Pilot, Soft-Wood",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"1.25 mm",
         "inch":0.0492,
         "designation":"1.25 mm",
         "note":"M1.6x.35 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.3 mm",
         "inch":0.0512,
         "designation":"1.3 mm",
         "note":"M1.7x.35 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.3208 mm",
         "inch":0.052,
         "designation":"#55",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.397 mm",
         "inch":0.055,
         "designation":"#54",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.45 mm",
         "inch":0.0571,
         "designation":"1.45 mm",
         "note":"M1.8x.35 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.5 mm",
         "inch":0.0591,
         "designation":"1.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"1.5113 mm",
         "inch":0.0595,
         "designation":"#53",
         "note":"#1-64 UNC, #1-72 UNF",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.5875 mm",
         "inch":0.0625,
         "designation":"1/16\"",
         "note":"#0 Wood Shank Hole, #3 Pilot, Hard-Wood, #4 Pilot, Hard-wood #5 Pilot, Soft-wood, #6 Pilot, Soft-wood, #7 Pilot, Soft-wood",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"1.6 mm",
         "inch":0.063,
         "designation":"1.6 mm",
         "note":"M2x.4 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.6129 mm",
         "inch":0.0635,
         "designation":"#52",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.7018 mm",
         "inch":0.067,
         "designation":"#51",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.75 mm",
         "inch":0.0689,
         "designation":"1.75 mm",
         "note":"M2.2x.45 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.778 mm",
         "inch":0.07,
         "designation":"#50",
         "note":"#2-64 UNF, #2-56 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.8542 mm",
         "inch":0.073,
         "designation":"#49",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.9304 mm",
         "inch":0.076,
         "designation":"#48",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"1.9844 mm",
         "inch":0.078125,
         "designation":"5/64\"",
         "note":"#1 Wood Shank Hole#5 Pilot, Hard-wood, #6 Pilot, Hard-wood #8 Pilot, Soft-wood, #9 Pilot, Soft-wood",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"1.9939 mm",
         "inch":0.0785,
         "designation":"#47",
         "note":"#3-48 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2 mm",
         "inch":0.0787,
         "designation":"2 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"2.05 mm",
         "inch":0.0807,
         "designation":"2.05 mm",
         "note":"M2.5x.45 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.0574 mm",
         "inch":0.081,
         "designation":"#46",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.0828 mm",
         "inch":0.082,
         "designation":"#45",
         "note":"#3-56 UNF",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.1844 mm",
         "inch":0.086,
         "designation":"#44",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.2606 mm",
         "inch":0.089,
         "designation":"#43",
         "note":"#4-40 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.3749 mm",
         "inch":0.0935,
         "designation":"#42",
         "note":"#4-48 UNF",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.3813 mm",
         "inch":0.09375,
         "designation":"3/32\"",
         "note":"#2 Wood Shank Hole, #7 Pilot, Hard-wood, #8 Pilot, Hard-wood, #10 Pilot, Soft-wood, #11 Pilot, Soft-wood",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"2.4384 mm",
         "inch":0.096,
         "designation":"#41",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.4892 mm",
         "inch":0.098,
         "designation":"#40",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.5 mm",
         "inch":0.0984,
         "designation":"",
         "note":"M3x.5 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"2.5273 mm",
         "inch":0.0995,
         "designation":"#39",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.5781 mm",
         "inch":0.1015,
         "designation":"#38",
         "note":"#5-40 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.6416 mm",
         "inch":0.104,
         "designation":"#37",
         "note":"#5-44 UNF",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.7051 mm",
         "inch":0.1065,
         "designation":"#36",
         "note":"#6-32 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.7781 mm",
         "inch":0.109375,
         "designation":"7/64\"",
         "note":"#3 Wood Shank Hole, #4 Wood Shank Hole, #9 Pilot, Hard-wood #10 Pilot, Hard-wood, #12 Pilot, Soft-wood, #14 Pilot, Soft-wood",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"2.794 mm",
         "inch":0.11,
         "designation":"#35",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.8194 mm",
         "inch":0.111,
         "designation":"#34",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.8702 mm",
         "inch":0.113,
         "designation":"#33",
         "note":"#6-40 UNF",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.9 mm",
         "inch":0.1142,
         "designation":"",
         "note":"M3.5x.6 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"2.9464 mm",
         "inch":0.116,
         "designation":"#32",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"3 mm",
         "inch":0.1181,
         "designation":"3 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"3.048 mm",
         "inch":0.12,
         "designation":"#31",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"3.175 mm",
         "inch":0.125,
         "designation":"1/8\"",
         "note":"#5 Wood Shank Hole, #11 Pilot, Hard-wood, #12 Pilot, Hard-wood",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"3.2639 mm",
         "inch":0.1285,
         "designation":"#30",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"3.3 mm",
         "inch":0.1299,
         "designation":"3.3 mm",
         "note":"M4x.7 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"3.4544 mm",
         "inch":0.136,
         "designation":"#29",
         "note":"#8-32 UNC, #8-36 UNF",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"3.5 mm",
         "inch":0.1378,
         "designation":"3.5 mm",
         "note":"M4x.5 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"3.5687 mm",
         "inch":0.1405,
         "designation":"#28",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"3.5719 mm",
         "inch":0.140625,
         "designation":"9/64\"",
         "note":"#6 Wood Shank Hole, #14 Pilot, Hard-wood, #16 Pilot, Soft-wood #18 Pilot, Soft-wood",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"3.6 mm",
         "inch":0.1417,
         "designation":"3.6 mm",
         "note":"M4x.35 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"3.6576 mm",
         "inch":0.144,
         "designation":"#27",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"3.7 mm",
         "inch":0.1457,
         "designation":"3.7 mm",
         "note":"M4.5x.75 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"3.7338 mm",
         "inch":0.147,
         "designation":"#26",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"3.7973 mm",
         "inch":0.1495,
         "designation":"#25",
         "note":"#10-24 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"3.8608 mm",
         "inch":0.152,
         "designation":"#24",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"3.9116 mm",
         "inch":0.154,
         "designation":"#23",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"3.9688 mm",
         "inch":0.15625,
         "designation":"5/32\"",
         "note":"#7 Wood Shank Hole, #16 Pilot, Hard-wood",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"3.9878 mm",
         "inch":0.157,
         "designation":"#22",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"4 mm",
         "inch":0.1575,
         "designation":"4 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"4.0386 mm",
         "inch":0.159,
         "designation":"#21",
         "note":"#10-32 UNF",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"4.0894 mm",
         "inch":0.161,
         "designation":"#20",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"4.2 mm",
         "inch":0.1654,
         "designation":"4.2 mm",
         "note":"M5x.8 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"4.2164 mm",
         "inch":0.166,
         "designation":"#19",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"4.3053 mm",
         "inch":0.1695,
         "designation":"#18",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"4.3656 mm",
         "inch":0.171875,
         "designation":"11/64\"",
         "note":"#8 Wood Shank Hole, #20 Pilot, Soft-wood",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"4.3942 mm",
         "inch":0.173,
         "designation":"#17",
         "note":"#12-24 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"4.4958 mm",
         "inch":0.177,
         "designation":"#16",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"4.5 mm",
         "inch":0.1772,
         "designation":"4.5 mm",
         "note":"M5x.5 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"4.572 mm",
         "inch":0.18,
         "designation":"#15",
         "note":"#12-28 UNF",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"4.6228 mm",
         "inch":0.182,
         "designation":"#14",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"4.699 mm",
         "inch":0.185,
         "designation":"#13",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"4.7625 mm",
         "inch":0.1875,
         "designation":"3/16\"",
         "note":"#9 Wood Shank Hole, #10 Wood Shank Hole, #18 Pilot, Hardwood",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"4.8006 mm",
         "inch":0.189,
         "designation":"#12",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"4.8514 mm",
         "inch":0.191,
         "designation":"#11",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"4.9149 mm",
         "inch":0.1935,
         "designation":"#10",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"4.9784 mm",
         "inch":0.196,
         "designation":"# 9",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"5 mm",
         "inch":0.1969,
         "designation":"5 mm",
         "note":"M6x1 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"5.0546 mm",
         "inch":0.199,
         "designation":"# 8",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"5.1054 mm",
         "inch":0.201,
         "designation":"# 7",
         "note":"1/4\"-20 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"5.1594 mm",
         "inch":0.203125,
         "designation":"13/64\"",
         "note":"#11 Wood Shank Hole, #20 Pilot, Hard-wood",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"5.1816 mm",
         "inch":0.204,
         "designation":"# 6",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"5.2197 mm",
         "inch":0.2055,
         "designation":"# 5",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"5.25 mm",
         "inch":0.2067,
         "designation":"5.25 mm",
         "note":"M6x.75 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"5.3086 mm",
         "inch":0.209,
         "designation":"# 4",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"5.4102 mm",
         "inch":0.213,
         "designation":"# 3",
         "note":"1/4\"-28 UNF",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"5.5 mm",
         "inch":0.2165,
         "designation":"5.5 mm",
         "note":"M6x.5 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"5.5563 mm",
         "inch":0.21875,
         "designation":"7/32\"",
         "note":"#12 Wood Shank Hole",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"5.6134 mm",
         "inch":0.221,
         "designation":"# 2",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"5.7912 mm",
         "inch":0.228,
         "designation":"# 1",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"5.9436 mm",
         "inch":0.234,
         "designation":"A",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"5.9531 mm",
         "inch":0.234375,
         "designation":"15/64\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"6 mm",
         "inch":0.2362,
         "designation":"6 mm",
         "note":"M7x1 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"6.0452 mm",
         "inch":0.238,
         "designation":"B",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"6.1468 mm",
         "inch":0.242,
         "designation":"C",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"6.2484 mm",
         "inch":0.246,
         "designation":"D",
         "note":"1/16\"-27 NPT",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"6.25 mm",
         "inch":0.2461,
         "designation":"6.25 mm",
         "note":"M7x.75 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"6.35 mm",
         "inch":0.25,
         "designation":"1/4\"",
         "note":"#14 Wood Shank Hole",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"6.35 mm",
         "inch":0.25,
         "designation":"E",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"6.5 mm",
         "inch":0.2559,
         "designation":"6.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"6.5278 mm",
         "inch":0.257,
         "designation":"F",
         "note":"5/16\"-18 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"6.6294 mm",
         "inch":0.261,
         "designation":"G",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"6.7469 mm",
         "inch":0.265625,
         "designation":"17/64\"",
         "note":"#16 Wood Shank Hole",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"6.7564 mm",
         "inch":0.266,
         "designation":"H",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"6.8 mm",
         "inch":0.2677,
         "designation":"6.8 mm",
         "note":"M8x1.25 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"6.9088 mm",
         "inch":0.272,
         "designation":"I",
         "note":"5/16\"-24 UNF",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"7 mm",
         "inch":0.2756,
         "designation":"7 mm",
         "note":"M8x.5 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"7.0358 mm",
         "inch":0.277,
         "designation":"J",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"7.1374 mm",
         "inch":0.281,
         "designation":"K",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"7.1438 mm",
         "inch":0.28125,
         "designation":"9/32\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"7.25 mm",
         "inch":0.2854,
         "designation":"7.25 mm",
         "note":"M8x.75 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"7.366 mm",
         "inch":0.29,
         "designation":"L",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"7.493 mm",
         "inch":0.295,
         "designation":"M",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"7.5 mm",
         "inch":0.2953,
         "designation":"7.5 mm",
         "note":"M8x1 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"7.5406 mm",
         "inch":0.296875,
         "designation":"19/64\"",
         "note":"#18 Wood Shank Hole",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"7.6708 mm",
         "inch":0.302,
         "designation":"N",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"7.8 mm",
         "inch":0.3071,
         "designation":"7.8 mm",
         "note":"M9x1.25 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"7.9375 mm",
         "inch":0.3125,
         "designation":"5/16\"",
         "note":"3/8\"-16 UNC",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"8 mm",
         "inch":0.315,
         "designation":"8 mm",
         "note":"M9x1 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"8.0264 mm",
         "inch":0.316,
         "designation":"O",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"8.2042 mm",
         "inch":0.323,
         "designation":"P",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"8.3344 mm",
         "inch":0.328125,
         "designation":"21/64\"",
         "note":"#20 Wood Shank Hole",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"8.4328 mm",
         "inch":0.332,
         "designation":"Q",
         "note":"3/8\"-24 UNF",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"8.5 mm",
         "inch":0.3346,
         "designation":"8.5 mm",
         "note":"M10x1.5 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"8.6106 mm",
         "inch":0.339,
         "designation":"R",
         "note":"1/8\"-27 NPT",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"8.7313 mm",
         "inch":0.34375,
         "designation":"11/32\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"8.8 mm",
         "inch":0.3465,
         "designation":"8.8 mm",
         "note":"M10x1.25 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"8.8392 mm",
         "inch":0.348,
         "designation":"S",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"9 mm",
         "inch":0.3543,
         "designation":"9 mm",
         "note":"M10x1 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"9.0932 mm",
         "inch":0.358,
         "designation":"T",
         "note":"7/16\"-14 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"9.1281 mm",
         "inch":0.359375,
         "designation":"23/64\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"9.25 mm",
         "inch":0.3642,
         "designation":"9.25 mm",
         "note":"M10x.75 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"9.3472 mm",
         "inch":0.368,
         "designation":"U",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"9.5 mm",
         "inch":0.374,
         "designation":"9.5 mm",
         "note":"M11x1.5 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"9.525 mm",
         "inch":0.375,
         "designation":"3/8\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"9.5758 mm",
         "inch":0.377,
         "designation":"V",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"9.8044 mm",
         "inch":0.386,
         "designation":"W",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"9.9219 mm",
         "inch":0.390625,
         "designation":"25/64\"",
         "note":"7/16\"-20 UNF",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"10 mm",
         "inch":0.3937,
         "designation":"10 mm",
         "note":"M11x1 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"10.0838 mm",
         "inch":0.397,
         "designation":"X",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"10.2 mm",
         "inch":0.4016,
         "designation":"10.2 mm",
         "note":"M12x1.75 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"10.2616 mm",
         "inch":0.404,
         "designation":"Y",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"10.3188 mm",
         "inch":0.40625,
         "designation":"13/32\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"10.4902 mm",
         "inch":0.413,
         "designation":"Z",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"10.5 mm",
         "inch":0.4134,
         "designation":"10.5 mm",
         "note":"M12x1.5 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"10.7156 mm",
         "inch":0.421875,
         "designation":"27/64\"",
         "note":"1/2\"-13 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"11 mm",
         "inch":0.4331,
         "designation":"11 mm",
         "note":"M12x1 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"11.1125 mm",
         "inch":0.4375,
         "designation":"7/16\"",
         "note":"1/4\"-18 NPT",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"11.25 mm",
         "inch":0.4429,
         "designation":"11.25 mm",
         "note":"M12x.75 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"11.5 mm",
         "inch":0.4528,
         "designation":"11.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"11.5094 mm",
         "inch":0.453125,
         "designation":"29/64\"",
         "note":"1/2\"-20 UNF",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"11.9063 mm",
         "inch":0.46875,
         "designation":"15/32\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"12 mm",
         "inch":0.4724,
         "designation":"12 mm",
         "note":"M14x2 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"12.3031 mm",
         "inch":0.484375,
         "designation":"31/64\"",
         "note":"9/16\"-12 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"12.5 mm",
         "inch":0.4921,
         "designation":"12.5 mm",
         "note":"M14x1.5 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"12.7 mm",
         "inch":0.5,
         "designation":"1/2\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"12.8 mm",
         "inch":0.5039,
         "designation":"12.8 mm",
         "note":"M14x1.25 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"13 mm",
         "inch":0.5118,
         "designation":"13 mm",
         "note":"M14x1 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"13.0969 mm",
         "inch":0.515625,
         "designation":"33/64\"",
         "note":"9/16\"-18 UNF",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"13.4938 mm",
         "inch":0.53125,
         "designation":"17/32\"",
         "note":"5/8\"-11 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"13.5 mm",
         "inch":0.5315,
         "designation":"13.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"13.8906 mm",
         "inch":0.546875,
         "designation":"35/64\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"14 mm",
         "inch":0.5512,
         "designation":"14 mm",
         "note":"M16x2 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"14.2875 mm",
         "inch":0.5625,
         "designation":"9/16\"",
         "note":"5/8\"-18 UNF",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"14.5 mm",
         "inch":0.5709,
         "designation":"14.5 mm",
         "note":"M16x1.5 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"14.6844 mm",
         "inch":0.578125,
         "designation":"37/64\"",
         "note":"3/8\"-18 NPT",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"15 mm",
         "inch":0.5906,
         "designation":"15 mm",
         "note":"M16x1 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"15.0813 mm",
         "inch":0.59375,
         "designation":"19/32\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"15.4781 mm",
         "inch":0.609375,
         "designation":"39/64\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"15.5 mm",
         "inch":0.6102,
         "designation":"15.5 mm",
         "note":"M18x2.5 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"15.875 mm",
         "inch":0.625,
         "designation":"5/8\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"16 mm",
         "inch":0.6299,
         "designation":"16 mm",
         "note":"M18x2 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"16.2719 mm",
         "inch":0.640625,
         "designation":"41/64\"",
         "note":"3/4\"-10 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"16.5 mm",
         "inch":0.6496,
         "designation":"16.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"16.6688 mm",
         "inch":0.65625,
         "designation":"21/32\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"17 mm",
         "inch":0.6693,
         "designation":"17 mm",
         "note":"M18x1 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"17.0656 mm",
         "inch":0.671875,
         "designation":"43/64\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"17.4625 mm",
         "inch":0.6875,
         "designation":"11/16\"",
         "note":"3/4\"-16 UNF",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"17.5 mm",
         "inch":0.689,
         "designation":"17.5 mm",
         "note":"M20x2.5 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"17.8594 mm",
         "inch":0.703125,
         "designation":"45/64\"",
         "note":"1/2\"-14 NPT",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"18 mm",
         "inch":0.7087,
         "designation":"18 mm",
         "note":"M20x2 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"18.2563 mm",
         "inch":0.71875,
         "designation":"23/32\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"18.5 mm",
         "inch":0.7283,
         "designation":"18.5 mm",
         "note":"M20x1.5 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"18.6531 mm",
         "inch":0.734375,
         "designation":"47/64\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"19 mm",
         "inch":0.748,
         "designation":"19 mm",
         "note":"M20x1 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"19.05 mm",
         "inch":0.75,
         "designation":"3/4\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"19.4469 mm",
         "inch":0.765625,
         "designation":"49/64\"",
         "note":"7/8\"-9 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"19.5 mm",
         "inch":0.7677,
         "designation":"19.5 mm",
         "note":"M22x2.5 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"19.8438 mm",
         "inch":0.78125,
         "designation":"25/32\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"20 mm",
         "inch":0.7874,
         "designation":"20 mm",
         "note":"M22x2 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"20.2406 mm",
         "inch":0.796875,
         "designation":"51/64\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"20.5 mm",
         "inch":0.8071,
         "designation":"20.5 mm",
         "note":"M22x1.5 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"20.6375 mm",
         "inch":0.8125,
         "designation":"13/16\"",
         "note":"7/8\"-14 UNF",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"21 mm",
         "inch":0.8268,
         "designation":"21 mm",
         "note":"M24x3 coarseM22x1 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"21.0344 mm",
         "inch":0.828125,
         "designation":"53/64\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"21.4313 mm",
         "inch":0.84375,
         "designation":"27/32\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"21.5 mm",
         "inch":0.8465,
         "designation":"21.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"21.8281 mm",
         "inch":0.859375,
         "designation":"55/64\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"22 mm",
         "inch":0.8661,
         "designation":"22 mm",
         "note":"M24x2 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"22.225 mm",
         "inch":0.875,
         "designation":"7/8\"",
         "note":"1\"-8 UNC",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"22.5 mm",
         "inch":0.8858,
         "designation":"22.5 mm",
         "note":"M24x1.5 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"22.6219 mm",
         "inch":0.890625,
         "designation":"57/64\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"23 mm",
         "inch":0.9055,
         "designation":"23 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"23.0188 mm",
         "inch":0.90625,
         "designation":"29/32\"",
         "note":"1\"-12 UNF",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"23.4156 mm",
         "inch":0.921875,
         "designation":"59/64\"",
         "note":"3/4\"-14 NPT",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"23.5 mm",
         "inch":0.9252,
         "designation":"23.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"23.8125 mm",
         "inch":0.9375,
         "designation":"15/16\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"24 mm",
         "inch":0.9449,
         "designation":"24 mm",
         "note":"M27x3 coarse",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"24.2094 mm",
         "inch":0.953125,
         "designation":"61/64\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"24.5 mm",
         "inch":0.9646,
         "designation":"24.5 mm",
         "note":"M26x1.5 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"24.6063 mm",
         "inch":0.96875,
         "designation":"31/32\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"25 mm",
         "inch":0.9843,
         "designation":"25 mm",
         "note":"M27x2 Fine",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"25.0031 mm",
         "inch":0.984375,
         "designation":"63/64\"",
         "note":"1-1/8\"-7 UNC",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"25.4 mm",
         "inch":1,
         "designation":"1\"",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"25.5 mm",
         "inch":1.0039,
         "designation":"25.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"25.7969 mm",
         "inch":1.0156,
         "designation":"1 1/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"26 mm",
         "inch":1.0236,
         "designation":"26 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"26.1938 mm",
         "inch":1.0313,
         "designation":"1 1/32 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"26.5 mm",
         "inch":1.0433,
         "designation":"26.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"26.5906 mm",
         "inch":1.0469,
         "designation":"1 3/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"26.9875 mm",
         "inch":1.0625,
         "designation":"1 1/16 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"27 mm",
         "inch":1.063,
         "designation":"27 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"27.3844 mm",
         "inch":1.0781,
         "designation":"1 5/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"27.5 mm",
         "inch":1.0827,
         "designation":"27.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"27.7813 mm",
         "inch":1.0938,
         "designation":"1 3/32 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"28 mm",
         "inch":1.1024,
         "designation":"28 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"28.1781 mm",
         "inch":1.1094,
         "designation":"1 7/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"28.5 mm",
         "inch":1.1221,
         "designation":"28.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"28.575 mm",
         "inch":1.125,
         "designation":"1 1/8 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"28.9719 mm",
         "inch":1.1406,
         "designation":"1 9/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"29 mm",
         "inch":1.1417,
         "designation":"29 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"29.3688 mm",
         "inch":1.1563,
         "designation":"1 5/32 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"29.5 mm",
         "inch":1.1614,
         "designation":"29.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"29.7656 mm",
         "inch":1.1719,
         "designation":"1 11/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"30 mm",
         "inch":1.1811,
         "designation":"30 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"30.1625 mm",
         "inch":1.1875,
         "designation":"1 3/16 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"30.5 mm",
         "inch":1.2008,
         "designation":"30.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"30.5594 mm",
         "inch":1.2031,
         "designation":"1 13/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"30.9563 mm",
         "inch":1.2188,
         "designation":"1 7/32 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"31 mm",
         "inch":1.2205,
         "designation":"31 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"31.3531 mm",
         "inch":1.2344,
         "designation":"1 15/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"31.5 mm",
         "inch":1.2402,
         "designation":"31.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"31.75 mm",
         "inch":1.25,
         "designation":"1 1/4 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"32 mm",
         "inch":1.2598,
         "designation":"32 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"32.1469 mm",
         "inch":1.2656,
         "designation":"1 17/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"32.5 mm",
         "inch":1.2795,
         "designation":"32.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"32.5438 mm",
         "inch":1.2813,
         "designation":"1 9/32 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"32.9406 mm",
         "inch":1.2969,
         "designation":"1 19/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"33 mm",
         "inch":1.2992,
         "designation":"33 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"33.3375 mm",
         "inch":1.3125,
         "designation":"1 5/16 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"33.5 mm",
         "inch":1.3189,
         "designation":"33.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"33.7344 mm",
         "inch":1.3281,
         "designation":"1 21/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"34 mm",
         "inch":1.3386,
         "designation":"34 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"34.1313 mm",
         "inch":1.3438,
         "designation":"1 11/32 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"34.5 mm",
         "inch":1.3583,
         "designation":"34.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"34.5281 mm",
         "inch":1.3594,
         "designation":"1 23/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"34.925 mm",
         "inch":1.375,
         "designation":"1 3/8 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"35 mm",
         "inch":1.378,
         "designation":"35 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"35.3219 mm",
         "inch":1.3906,
         "designation":"1 25/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"35.5 mm",
         "inch":1.3976,
         "designation":"35.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"35.7188 mm",
         "inch":1.4063,
         "designation":"1 13/32 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"36 mm",
         "inch":1.4173,
         "designation":"36 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"36.1156 mm",
         "inch":1.4219,
         "designation":"1 27/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"36.5 mm",
         "inch":1.437,
         "designation":"36.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"36.5125 mm",
         "inch":1.4375,
         "designation":"1 7/16 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      },{
         "metric":"36.9094 mm",
         "inch":1.4531,
         "designation":"1 29/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"37 mm",
         "inch":1.4567,
         "designation":"37 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"37.3063 mm",
         "inch":1.4688,
         "designation":"1 15/32 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"37.5 mm",
         "inch":1.4764,
         "designation":"37.5 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"37.7031 mm",
         "inch":1.4844,
         "designation":"1 31/64 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":0
      },{
         "metric":"38 mm",
         "inch":1.4961,
         "designation":"38 mm",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":0,
         "emmm":1
      },{
         "metric":"38.1 mm",
         "inch":1.5,
         "designation":"1 1/2 in",
         "note":"",
         "pct":100,
         "td":1,
         "eminch":1,
         "emmm":0
      }]);
      
      public static var _991341380UnitTypeList:Array = ["Length","Temperature","Area","Volume","Weight and Mass","Energy and Work","Power","Pressure"];
      
      public static var BaseUnitList:ArrayCollection = new ArrayCollection([{
         "type":"Area",
         "from":"sq. inches",
         "to":"sq. inches",
         "factor":1,
         "constant":0
      },{
         "type":"Area",
         "from":"sq. feet",
         "to":"sq. inches",
         "factor":144,
         "constant":0
      },{
         "type":"Area",
         "from":"sq. yards",
         "to":"sq. inches",
         "factor":1296,
         "constant":0
      },{
         "type":"Area",
         "from":"sq. meters",
         "to":"sq. inches",
         "factor":1550.0031000062,
         "constant":0
      },{
         "type":"Area",
         "from":"acres",
         "to":"sq. inches",
         "factor":6272640,
         "constant":0
      },{
         "type":"Area",
         "from":"hectares",
         "to":"sq. inches",
         "factor":15500031.000062,
         "constant":0
      },{
         "type":"Area",
         "from":"sq. kilometers",
         "to":"sq. inches",
         "factor":1550003100.0062,
         "constant":0
      },{
         "type":"Area",
         "from":"sq. miles",
         "to":"sq. inches",
         "factor":4014489600,
         "constant":0
      },{
         "type":"Length",
         "from":"Angstroms",
         "to":"inches",
         "factor":3.93700787401575e-10,
         "constant":0
      },{
         "type":"Length",
         "from":"millionths (in)",
         "to":"inches",
         "factor":0.000001,
         "constant":0
      },{
         "type":"Length",
         "from":"micrometers",
         "to":"inches",
         "factor":0.0000393700787401575,
         "constant":0
      },{
         "type":"Length",
         "from":"microns",
         "to":"inches",
         "factor":0.0000393700787401575,
         "constant":0
      },{
         "type":"Length",
         "from":"microinches",
         "to":"inches",
         "factor":0.000001,
         "constant":0
      },{
         "type":"Length",
         "from":"tenths (in)",
         "to":"inches",
         "factor":0.0001,
         "constant":0
      },{
         "type":"Length",
         "from":"thousandths (in)",
         "to":"inches",
         "factor":0.001,
         "constant":0
      },{
         "type":"Length",
         "from":"millimeters",
         "to":"inches",
         "factor":0.0393700787401575,
         "constant":0
      },{
         "type":"Length",
         "from":"centimeters",
         "to":"inches",
         "factor":0.393700787401575,
         "constant":0
      },{
         "type":"Length",
         "from":"inches",
         "to":"inches",
         "factor":1,
         "constant":0
      },{
         "type":"Length",
         "from":"hands",
         "to":"inches",
         "factor":4,
         "constant":0
      },{
         "type":"Length",
         "from":"spans",
         "to":"inches",
         "factor":9,
         "constant":0
      },{
         "type":"Length",
         "from":"feet",
         "to":"inches",
         "factor":12,
         "constant":0
      },{
         "type":"Length",
         "from":"yards",
         "to":"inches",
         "factor":36,
         "constant":0
      },{
         "type":"Length",
         "from":"meters",
         "to":"inches",
         "factor":39.3700787401575,
         "constant":0
      },{
         "type":"Length",
         "from":"fathoms",
         "to":"inches",
         "factor":72,
         "constant":0
      },{
         "type":"Length",
         "from":"rods",
         "to":"inches",
         "factor":198,
         "constant":0
      },{
         "type":"Length",
         "from":"chains",
         "to":"inches",
         "factor":792,
         "constant":0
      },{
         "type":"Length",
         "from":"furlongs",
         "to":"inches",
         "factor":7920,
         "constant":0
      },{
         "type":"Length",
         "from":"kilometers",
         "to":"inches",
         "factor":39370.0787401575,
         "constant":0
      },{
         "type":"Length",
         "from":"miles",
         "to":"inches",
         "factor":63360,
         "constant":0
      },{
         "type":"Length",
         "from":"nautical miles",
         "to":"inches",
         "factor":72913.3858267717,
         "constant":0
      },{
         "type":"Length",
         "from":"leagues",
         "to":"inches",
         "factor":190080,
         "constant":0
      },{
         "type":"Volume",
         "from":"cc",
         "to":"cu. inches",
         "factor":0.0610237441,
         "constant":0
      },{
         "type":"Volume",
         "from":"milliliters (ml)",
         "to":"cu. inches",
         "factor":0.0610237441,
         "constant":0
      },{
         "type":"Volume",
         "from":"teaspoons (US)",
         "to":"cu. inches",
         "factor":0.30078125,
         "constant":0
      },{
         "type":"Volume",
         "from":"pint (Imp)",
         "to":"cu. inches",
         "factor":34.6774434,
         "constant":0
      },{
         "type":"Volume",
         "from":"tablespoons (US)",
         "to":"cu. inches",
         "factor":0.90234375,
         "constant":0
      },{
         "type":"Volume",
         "from":"cu. inches",
         "to":"cu. inches",
         "factor":1,
         "constant":0
      },{
         "type":"Volume",
         "from":"liters",
         "to":"cu. inches",
         "factor":61.0237441,
         "constant":0
      },{
         "type":"Volume",
         "from":"quart (Imp)",
         "to":"cu. inches",
         "factor":69.3548869,
         "constant":0
      },{
         "type":"Volume",
         "from":"fl ozs (US)",
         "to":"cu. inches",
         "factor":1.8046875,
         "constant":0
      },{
         "type":"Volume",
         "from":"gallons (Imp)",
         "to":"cu. inches",
         "factor":277.419547,
         "constant":0
      },{
         "type":"Volume",
         "from":"cups",
         "to":"cu. inches",
         "factor":14.4375,
         "constant":0
      },{
         "type":"Volume",
         "from":"bushels (Imp)",
         "to":"cu. inches",
         "factor":2219.35638,
         "constant":0
      },{
         "type":"Volume",
         "from":"pint (US)",
         "to":"cu. inches",
         "factor":28.875,
         "constant":0
      },{
         "type":"Volume",
         "from":"quart (US)",
         "to":"cu. inches",
         "factor":57.75,
         "constant":0
      },{
         "type":"Volume",
         "from":"board-feet",
         "to":"cu. inches",
         "factor":144,
         "constant":0
      },{
         "type":"Volume",
         "from":"gallons (US)",
         "to":"cu. inches",
         "factor":231,
         "constant":0
      },{
         "type":"Volume",
         "from":"barrels (Imp.)",
         "to":"cu. inches",
         "factor":253.672329344659,
         "constant":0
      },{
         "type":"Volume",
         "from":"cu. Meter",
         "to":"cu. inches",
         "factor":61023.7441,
         "constant":0
      },{
         "type":"Volume",
         "from":"cu. Feet",
         "to":"cu. inches",
         "factor":1728,
         "constant":0
      },{
         "type":"Volume",
         "from":"barrels (US dry)",
         "to":"cu. inches",
         "factor":6063.75,
         "constant":0
      },{
         "type":"Volume",
         "from":"barrels (US fluid)",
         "to":"cu. inches",
         "factor":7276.5,
         "constant":0
      },{
         "type":"Volume",
         "from":"barrels (petroleum)",
         "to":"cu. inches",
         "factor":9702,
         "constant":0
      },{
         "type":"Volume",
         "from":"cu. yards",
         "to":"cu. inches",
         "factor":46656,
         "constant":0
      },{
         "type":"Weight and Mass",
         "from":"grain",
         "to":"gram",
         "factor":0.06479891,
         "constant":0
      },{
         "type":"Weight and Mass",
         "from":"carat",
         "to":"gram",
         "factor":0.198446661875,
         "constant":0
      },{
         "type":"Weight and Mass",
         "from":"pennyweight",
         "to":"gram",
         "factor":1.55517384,
         "constant":0
      },{
         "type":"Weight and Mass",
         "from":"ounce (avoir.)",
         "to":"gram",
         "factor":28.3495,
         "constant":0
      },{
         "type":"Weight and Mass",
         "from":"ounce (troy)",
         "to":"gram",
         "factor":31.1034768,
         "constant":0
      },{
         "type":"Weight and Mass",
         "from":"pound (troy)",
         "to":"gram",
         "factor":373.2417216,
         "constant":0
      },{
         "type":"Weight and Mass",
         "from":"pound (lb)",
         "to":"gram",
         "factor":453.592,
         "constant":0
      },{
         "type":"Weight and Mass",
         "from":"pound (metric)",
         "to":"gram",
         "factor":500,
         "constant":0
      },{
         "type":"Weight and Mass",
         "from":"kilogram",
         "to":"gram",
         "factor":1000,
         "constant":0
      },{
         "type":"Weight and Mass",
         "from":"stone",
         "to":"gram",
         "factor":6350.288,
         "constant":0
      },{
         "type":"Weight and Mass",
         "from":"ton, short",
         "to":"gram",
         "factor":907184,
         "constant":0
      },{
         "type":"Weight and Mass",
         "from":"ton, long (ton)",
         "to":"gram",
         "factor":1016046.08,
         "constant":0
      },{
         "type":"Energy and Work",
         "from":"joule",
         "to":"joules",
         "factor":1,
         "constant":0
      },{
         "type":"Energy and Work",
         "from":"erg",
         "to":"joules",
         "factor":1e-7,
         "constant":0
      },{
         "type":"Energy and Work",
         "from":"inch-pound",
         "to":"joules",
         "factor":0.112984829,
         "constant":0
      },{
         "type":"Energy and Work",
         "from":"foot-pound",
         "to":"joules",
         "factor":1.355817948,
         "constant":0
      },{
         "type":"Energy and Work",
         "from":"calorie (mean)",
         "to":"joules",
         "factor":4.19002,
         "constant":0
      },{
         "type":"Energy and Work",
         "from":"calorie (IT)",
         "to":"joules",
         "factor":4.1868,
         "constant":0
      },{
         "type":"Energy and Work",
         "from":"kilocalarie",
         "to":"joules",
         "factor":4186.8,
         "constant":0
      },{
         "type":"Energy and Work",
         "from":"BTU",
         "to":"joules",
         "factor":1055.055852,
         "constant":0
      },{
         "type":"Energy and Work",
         "from":"kilowatt-hour",
         "to":"joules",
         "factor":3600000,
         "constant":0
      },{
         "type":"Energy and Work",
         "from":"ton of TNT",
         "to":"joules",
         "factor":4184000000,
         "constant":0
      },{
         "type":"Energy and Work",
         "from":"barrel of oil",
         "to":"joules",
         "factor":6120000000,
         "constant":0
      },{
         "type":"Power",
         "from":"watt",
         "to":"watt",
         "factor":1,
         "constant":0
      },{
         "type":"Power",
         "from":"BTU/hour",
         "to":"watt",
         "factor":0.293071,
         "constant":0
      },{
         "type":"Power",
         "from":"BTU/minute",
         "to":"watt",
         "factor":17.58426,
         "constant":0
      },{
         "type":"Power",
         "from":"horsepower (metric)",
         "to":"watt",
         "factor":735.49875,
         "constant":0
      },{
         "type":"Power",
         "from":"horsepower (Imp mech.)",
         "to":"watt",
         "factor":745.699871582,
         "constant":0
      },{
         "type":"Power",
         "from":"horsepower (Imp elec.)",
         "to":"watt",
         "factor":746,
         "constant":0
      },{
         "type":"Power",
         "from":"ton of air conditioning",
         "to":"watt",
         "factor":3504,
         "constant":0
      },{
         "type":"Power",
         "from":"BTU/second",
         "to":"watt",
         "factor":1055.0556,
         "constant":0
      },{
         "type":"Power",
         "from":"ton of refrig (Imp)",
         "to":"watt",
         "factor":3938.875,
         "constant":0
      },{
         "type":"Power",
         "from":"ton of refrig (IT)",
         "to":"watt",
         "factor":3516.853,
         "constant":0
      },{
         "type":"Power",
         "from":"boiler horsepower (bhp)",
         "to":"watt",
         "factor":9810.657,
         "constant":0
      },{
         "type":"Pressure",
         "from":"atmosphere (std)",
         "to":"pascal",
         "factor":101325,
         "constant":0
      },{
         "type":"Pressure",
         "from":"atmosphere (technical)",
         "to":"pascal",
         "factor":98066.5,
         "constant":0
      },{
         "type":"Pressure",
         "from":"bar",
         "to":"pascal",
         "factor":100000,
         "constant":0
      },{
         "type":"Pressure",
         "from":"cm of mercury",
         "to":"pascal",
         "factor":1333.22,
         "constant":0
      },{
         "type":"Pressure",
         "from":"cm of water",
         "to":"pascal",
         "factor":98.0638,
         "constant":0
      },{
         "type":"Pressure",
         "from":"ft of mercury",
         "to":"pascal",
         "factor":40636.66,
         "constant":0
      },{
         "type":"Pressure",
         "from":"inch of water",
         "to":"pascal",
         "factor":249.082,
         "constant":0
      },{
         "type":"Pressure",
         "from":"mm of mercury",
         "to":"pascal",
         "factor":133.3224,
         "constant":0
      },{
         "type":"Pressure",
         "from":"mm of water",
         "to":"pascal",
         "factor":9.80638,
         "constant":0
      },{
         "type":"Pressure",
         "from":"pascal",
         "to":"pascal",
         "factor":1,
         "constant":0
      },{
         "type":"Pressure",
         "from":"pound per sq ft",
         "to":"pascal",
         "factor":47.88025,
         "constant":0
      },{
         "type":"Pressure",
         "from":"pound per sq in",
         "to":"pascal",
         "factor":6894.757,
         "constant":0
      },{
         "type":"Pressure",
         "from":"torr",
         "to":"pascal",
         "factor":133.3224,
         "constant":0
      },{
         "type":"Temperature",
         "from":"Celsius",
         "to":"Kelvin",
         "factor":1,
         "constant":273.15
      },{
         "type":"Temperature",
         "from":"Kelvin",
         "to":"Kelvin",
         "factor":1,
         "constant":0
      },{
         "type":"Temperature",
         "from":"Rankine",
         "to":"Kelvin",
         "factor":0.555555555555556,
         "constant":0
      },{
         "type":"Temperature",
         "from":"Fahrenheit",
         "to":"Kelvin",
         "factor":0.555555555555556,
         "constant":459.67
      },{
         "type":"Torque",
         "from":"oz in",
         "to":"Nm",
         "factor":0.00706155,
         "constant":0
      },{
         "type":"Torque",
         "from":"N-m",
         "to":"Nm",
         "factor":1,
         "constant":0
      },{
         "type":"Torque",
         "from":"in lb",
         "to":"Nm",
         "factor":0.112984829,
         "constant":0
      },{
         "type":"Torque",
         "from":"ft lb",
         "to":"Nm",
         "factor":1.35581795,
         "constant":0
      }]);
      
      public static var _904606372CenterDrillList:ArrayCollection = new ArrayCollection([{
         "drill":"000",
         "bodydia":0.125,
         "pilotdia":0.02,
         "pilotlen":0.03,
         "belldia":0
      },{
         "drill":"00",
         "bodydia":0.125,
         "pilotdia":0.025,
         "pilotlen":0.038,
         "belldia":0
      },{
         "drill":"0",
         "bodydia":0.125,
         "pilotdia":0.03125,
         "pilotlen":0.03125,
         "belldia":0
      },{
         "drill":"1",
         "bodydia":0.125,
         "pilotdia":0.046875,
         "pilotlen":0.046875,
         "belldia":0
      },{
         "drill":"2",
         "bodydia":0.1875,
         "pilotdia":0.078125,
         "pilotlen":0.078125,
         "belldia":0
      },{
         "drill":"3",
         "bodydia":0.25,
         "pilotdia":0.109375,
         "pilotlen":0.109375,
         "belldia":0
      },{
         "drill":"4",
         "bodydia":0.3125,
         "pilotdia":0.125,
         "pilotlen":0.125,
         "belldia":0
      },{
         "drill":"4.5",
         "bodydia":0.375,
         "pilotdia":0.1406,
         "pilotlen":0.1406,
         "belldia":0
      },{
         "drill":"5",
         "bodydia":0.4375,
         "pilotdia":0.1875,
         "pilotlen":0.1875,
         "belldia":0
      },{
         "drill":"6",
         "bodydia":0.5,
         "pilotdia":0.21875,
         "pilotlen":0.21875,
         "belldia":0
      },{
         "drill":"7",
         "bodydia":0.625,
         "pilotdia":0.25,
         "pilotlen":0.25,
         "belldia":0
      },{
         "drill":"8",
         "bodydia":0.75,
         "pilotdia":0.3125,
         "pilotlen":0.3125,
         "belldia":0
      },{
         "drill":"1mm",
         "bodydia":0.124,
         "pilotdia":0.039,
         "pilotlen":0.075,
         "belldia":0
      },{
         "drill":"1.25mm",
         "bodydia":0.124,
         "pilotdia":0.49,
         "pilotlen":0.11,
         "belldia":0
      },{
         "drill":"1.6mm",
         "bodydia":0.157,
         "pilotdia":0.063,
         "pilotlen":0.11,
         "belldia":0
      },{
         "drill":"2mm",
         "bodydia":0.197,
         "pilotdia":0.079,
         "pilotlen":0.13,
         "belldia":0
      },{
         "drill":"2.5mm",
         "bodydia":0.248,
         "pilotdia":0.098,
         "pilotlen":0.161,
         "belldia":0
      },{
         "drill":"3.15mm",
         "bodydia":0.315,
         "pilotdia":0.124,
         "pilotlen":0.193,
         "belldia":0
      },{
         "drill":"4mm",
         "bodydia":0.394,
         "pilotdia":0.157,
         "pilotlen":0.244,
         "belldia":0
      },{
         "drill":"5mm",
         "bodydia":0.492,
         "pilotdia":0.197,
         "pilotlen":0.295,
         "belldia":0
      },{
         "drill":"6.3mm",
         "bodydia":0.63,
         "pilotdia":0.248,
         "pilotlen":0.362,
         "belldia":0
      },{
         "drill":"8mm",
         "bodydia":0.787,
         "pilotdia":0.315,
         "pilotlen":0.453,
         "belldia":0
      },{
         "drill":"10mm",
         "bodydia":0.984,
         "pilotdia":0.394,
         "pilotlen":0.559,
         "belldia":0
      }]);
      
      public static var _551932401StandardTaperList:ArrayCollection = new ArrayCollection([{
         "name":"MT 0",
         "largeEnd":0.3561,
         "smallEnd":0.252,
         "length":2,
         "angle":1.4908
      },{
         "name":"MT 1",
         "largeEnd":0.475,
         "smallEnd":0.369,
         "length":2.13,
         "angle":1.4287
      },{
         "name":"MT 2",
         "largeEnd":0.7,
         "smallEnd":0.572,
         "length":2.56,
         "angle":1.4307
      },{
         "name":"MT 3",
         "largeEnd":0.938,
         "smallEnd":0.778,
         "length":3.19,
         "angle":1.4377
      },{
         "name":"MT 4",
         "largeEnd":1.231,
         "smallEnd":1.02,
         "length":4.06,
         "angle":1.4876
      },{
         "name":"MT 4-1/2",
         "largeEnd":1.5,
         "smallEnd":1.266,
         "length":4.5,
         "angle":1.4894
      },{
         "name":"MT 5",
         "largeEnd":1.748,
         "smallEnd":1.485,
         "length":5.19,
         "angle":1.5073
      },{
         "name":"MT 6",
         "largeEnd":2.494,
         "smallEnd":2.116,
         "length":7.25,
         "angle":1.4933
      },{
         "name":"MT 7",
         "largeEnd":3.27,
         "smallEnd":2.75,
         "length":10,
         "angle":1.4894
      },{
         "name":"JT 0",
         "largeEnd":0.25,
         "smallEnd":0.2284,
         "length":0.4375,
         "angle":1.4117
      },{
         "name":"JT 1",
         "largeEnd":0.384,
         "smallEnd":0.3334,
         "length":0.6563,
         "angle":2.2074
      },{
         "name":"JT 2",
         "largeEnd":0.559,
         "smallEnd":0.4876,
         "length":0.875,
         "angle":2.335
      },{
         "name":"JT 2 Short",
         "largeEnd":0.5488,
         "smallEnd":0.4876,
         "length":0.75,
         "angle":2.335
      },{
         "name":"JT 3",
         "largeEnd":0.811,
         "smallEnd":0.7461,
         "length":1.2188,
         "angle":1.5251
      },{
         "name":"JT 4",
         "largeEnd":1.124,
         "smallEnd":1.0372,
         "length":1.6563,
         "angle":1.5009
      },{
         "name":"JT 5",
         "largeEnd":1.413,
         "smallEnd":1.3161,
         "length":1.875,
         "angle":1.4801
      },{
         "name":"JT 6",
         "largeEnd":0.676,
         "smallEnd":0.6241,
         "length":1,
         "angle":1.4868
      },{
         "name":"JT 33",
         "largeEnd":0.624,
         "smallEnd":0.5604,
         "length":1,
         "angle":1.8184
      },{
         "name":"#1 Brown & Sharpe       ",
         "largeEnd":0.2392,
         "smallEnd":0.2,
         "length":0.94,
         "angle":1.1983
      },{
         "name":"#2 Brown & Sharpe       ",
         "largeEnd":0.2997,
         "smallEnd":0.25,
         "length":1.19,
         "angle":1.1983
      },{
         "name":"#3 Brown & Sharpe       ",
         "largeEnd":0.3753,
         "smallEnd":0.3125,
         "length":1.5,
         "angle":1.1983
      },{
         "name":"#4 Brown & Sharpe       ",
         "largeEnd":0.4207,
         "smallEnd":0.35,
         "length":1.69,
         "angle":1.1992
      },{
         "name":"#5 Brown & Sharpe       ",
         "largeEnd":0.5388,
         "smallEnd":0.45,
         "length":2.13,
         "angle":1.1973
      },{
         "name":"#6 Brown & Sharpe       ",
         "largeEnd":0.5996,
         "smallEnd":0.5,
         "length":2.38,
         "angle":1.2013
      },{
         "name":"#7 Brown & Sharpe       ",
         "largeEnd":0.7201,
         "smallEnd":0.6,
         "length":2.88,
         "angle":1.197
      },{
         "name":"#8 Brown & Sharpe       ",
         "largeEnd":0.8987,
         "smallEnd":0.75,
         "length":3.56,
         "angle":1.1959
      },{
         "name":"#9 Brown & Sharpe       ",
         "largeEnd":1.0775,
         "smallEnd":0.9001,
         "length":4.25,
         "angle":1.1955
      },{
         "name":"#10 Brown & Sharpe      ",
         "largeEnd":1.2597,
         "smallEnd":1.0447,
         "length":5,
         "angle":1.232
      },{
         "name":"#11 Brown & Sharpe      ",
         "largeEnd":1.4978,
         "smallEnd":1.25,
         "length":5.94,
         "angle":1.1959
      },{
         "name":"#12 Brown & Sharpe      ",
         "largeEnd":1.7968,
         "smallEnd":1.5001,
         "length":7.13,
         "angle":1.1928
      },{
         "name":"#13 Brown & Sharpe      ",
         "largeEnd":2.0731,
         "smallEnd":1.7501,
         "length":7.75,
         "angle":1.194
      },{
         "name":"#14 Brown & Sharpe      ",
         "largeEnd":2.3438,
         "smallEnd":2,
         "length":8.25,
         "angle":1.1935
      },{
         "name":"#15 Brown & Sharpe      ",
         "largeEnd":2.6146,
         "smallEnd":2.25,
         "length":8.75,
         "angle":1.1935
      },{
         "name":"#16 Brown & Sharpe      ",
         "largeEnd":2.8854,
         "smallEnd":2.5,
         "length":9.25,
         "angle":1.1935
      },{
         "name":"#17 Brown & Sharpe      ",
         "largeEnd":3.1563,
         "smallEnd":2.75,
         "length":9.75,
         "angle":1.1935
      },{
         "name":"#18 Brown & Sharpe      ",
         "largeEnd":3.4271,
         "smallEnd":3,
         "length":10.25,
         "angle":1.1935
      },{
         "name":"#2 Jarno                ",
         "largeEnd":0.25,
         "smallEnd":0.2,
         "length":1,
         "angle":1.4321
      },{
         "name":"#3 Jarno                ",
         "largeEnd":0.375,
         "smallEnd":0.3,
         "length":1.5,
         "angle":1.4321
      },{
         "name":"#4 Jarno                ",
         "largeEnd":0.5,
         "smallEnd":0.4,
         "length":2,
         "angle":1.4321
      },{
         "name":"#5 Jarno                ",
         "largeEnd":0.625,
         "smallEnd":0.5,
         "length":2.5,
         "angle":1.4321
      },{
         "name":"#6 Jarno                ",
         "largeEnd":0.75,
         "smallEnd":0.6,
         "length":3,
         "angle":1.4321
      },{
         "name":"#7 Jarno                ",
         "largeEnd":0.875,
         "smallEnd":0.7,
         "length":3.5,
         "angle":1.4321
      },{
         "name":"#8 Jarno                ",
         "largeEnd":1,
         "smallEnd":0.8,
         "length":4,
         "angle":1.4321
      },{
         "name":"#9 Jarno                ",
         "largeEnd":1.125,
         "smallEnd":0.9,
         "length":4.5,
         "angle":1.4321
      },{
         "name":"#10 Jarno               ",
         "largeEnd":1.25,
         "smallEnd":1,
         "length":5,
         "angle":1.4321
      },{
         "name":"#11 Jarno               ",
         "largeEnd":1.375,
         "smallEnd":1.1,
         "length":5.5,
         "angle":1.4321
      },{
         "name":"#12 Jarno               ",
         "largeEnd":1.5,
         "smallEnd":1.2,
         "length":6,
         "angle":1.4321
      },{
         "name":"#13 Jarno               ",
         "largeEnd":1.625,
         "smallEnd":1.3,
         "length":6.5,
         "angle":1.4321
      },{
         "name":"#14 Jarno               ",
         "largeEnd":1.75,
         "smallEnd":1.4,
         "length":7,
         "angle":1.4321
      },{
         "name":"#15 Jarno               ",
         "largeEnd":1.875,
         "smallEnd":1.5,
         "length":7.5,
         "angle":1.4321
      },{
         "name":"#16 Jarno               ",
         "largeEnd":2,
         "smallEnd":1.6,
         "length":8,
         "angle":1.4321
      },{
         "name":"#17 Jarno               ",
         "largeEnd":2.125,
         "smallEnd":1.7,
         "length":8.5,
         "angle":1.4321
      },{
         "name":"#18 Jarno               ",
         "largeEnd":2.25,
         "smallEnd":1.8,
         "length":9,
         "angle":1.4321
      },{
         "name":"#19 Jarno               ",
         "largeEnd":2.375,
         "smallEnd":1.9,
         "length":9.5,
         "angle":1.4321
      },{
         "name":"#20 Jarno               ",
         "largeEnd":2.5,
         "smallEnd":2,
         "length":10,
         "angle":1.4321
      },{
         "name":"5C Collet               ",
         "largeEnd":1.453,
         "smallEnd":1.281,
         "length":0.505,
         "angle":10
      },{
         "name":"BT 30                   ",
         "largeEnd":1.25,
         "smallEnd":0.6941,
         "length":1.906,
         "angle":8.29714497
      },{
         "name":"BT 35                   ",
         "largeEnd":1.5,
         "smallEnd":0.8513,
         "length":2.224,
         "angle":8.29714497
      },{
         "name":"BT 40                   ",
         "largeEnd":1.75,
         "smallEnd":0.999,
         "length":2.575,
         "angle":8.29714497
      },{
         "name":"BT 45                   ",
         "largeEnd":2.25,
         "smallEnd":1.2992,
         "length":3.26,
         "angle":8.29714497
      },{
         "name":"BT 50                   ",
         "largeEnd":2.75,
         "smallEnd":1.581,
         "length":4.008,
         "angle":8.29714497
      },{
         "name":"CAT 30                  ",
         "largeEnd":1.25,
         "smallEnd":0.7031,
         "length":1.875,
         "angle":8.29714497
      },{
         "name":"CAT 40                  ",
         "largeEnd":1.75,
         "smallEnd":0.9663,
         "length":2.687,
         "angle":8.29714497
      },{
         "name":"CAT 45                  ",
         "largeEnd":2.25,
         "smallEnd":1.3021,
         "length":3.25,
         "angle":8.29714497
      },{
         "name":"CAT 50                  ",
         "largeEnd":2.75,
         "smallEnd":1.5834,
         "length":4,
         "angle":8.29714497
      },{
         "name":"CAT 60                  ",
         "largeEnd":4.25,
         "smallEnd":2.3907,
         "length":6.375,
         "angle":8.29714497
      },{
         "name":"NMTB 30                 ",
         "largeEnd":1.25,
         "smallEnd":0.673,
         "length":1.88,
         "angle":8.29714497
      },{
         "name":"NMTB 40                 ",
         "largeEnd":1.75,
         "smallEnd":0.984,
         "length":2.51,
         "angle":8.29714497
      },{
         "name":"NMTB 50                 ",
         "largeEnd":2.75,
         "smallEnd":1.545,
         "length":4,
         "angle":8.29714497
      },{
         "name":"ER11                    ",
         "largeEnd":0.4331,
         "smallEnd":0.2953,
         "length":0.4902,
         "angle":8
      },{
         "name":"ER16                    ",
         "largeEnd":0.6299,
         "smallEnd":0.4134,
         "length":0.7705,
         "angle":8
      },{
         "name":"ER20                    ",
         "largeEnd":0.7874,
         "smallEnd":0.5315,
         "length":0.9106,
         "angle":8
      },{
         "name":"ER25                    ",
         "largeEnd":0.9843,
         "smallEnd":0.7087,
         "length":0.9803,
         "angle":8
      },{
         "name":"ER32                    ",
         "largeEnd":1.2598,
         "smallEnd":0.9252,
         "length":1.1906,
         "angle":8
      },{
         "name":"ER40                    ",
         "largeEnd":1.5748,
         "smallEnd":1.2008,
         "length":1.3307,
         "angle":8
      },{
         "name":"ER50                    ",
         "largeEnd":1.9685,
         "smallEnd":1.4961,
         "length":1.6807,
         "angle":8
      },{
         "name":"R8                      ",
         "largeEnd":1.25,
         "smallEnd":0.9495,
         "length":0.9375,
         "angle":8.425
      }]);
      
      public static var ThreadTypeList:Array = ["UNC - Unified National Coarse","UNF - Unified National Fine","UNEF - Unified National Extra Fine","UNJ - UN J-Series","UNJC - UN J-Series Coarse","UNJF - UN J-Series Fine","UN - Unified Constant Pitch","UNS - Unified Special Series","UNM - Unified Miniature Series","UNC-STI, Unified Coarse Screw Thread Insert","UNF-STI, Unified Fine Screw Thread Insert","ACME","Stub ACME","BUTTRESS","NPSM","NPSL","ISO Coarse","ISO Fine","BSW - British Standard Whitworth","BSF - British Standard Fine","BA - British Association"];
      
      public static var PipeThreadTypeList:Array = ["NPT - National Pipe Thread","NPTF - National Pipe Thread Fine"];
      
      public static var _1465048132InsertNoseRadiusList:ArrayCollection = new ArrayCollection([{
         "insert":"",
         "radius":"0.003",
         "fractional":"",
         "label":"              0.0030                    "
      },{
         "insert":"01",
         "radius":"0.004",
         "fractional":"",
         "label":"  01        0.1mm/0.0040in                    "
      },{
         "insert":"",
         "radius":"0.005",
         "fractional":"",
         "label":"              0.0050                    "
      },{
         "insert":"",
         "radius":"0.007",
         "fractional":"",
         "label":"              0.0070                    "
      },{
         "insert":"02",
         "radius":"0.008",
         "fractional":"",
         "label":"  02        0.2mm/0.0080in                    "
      },{
         "insert":"",
         "radius":"0.01",
         "fractional":"",
         "label":"              0.0100                    "
      },{
         "insert":"04",
         "radius":"0.0156",
         "fractional":"1/64",
         "label":"  04        0.4mm/0.0156in            1/64"
      },{
         "insert":"08",
         "radius":"0.0313",
         "fractional":"1/32",
         "label":"  08        0.8mm/0.0313in            1/32"
      },{
         "insert":"12",
         "radius":"0.0469",
         "fractional":"3/64",
         "label":"  12        1.2mm/0.0469in            3/64"
      },{
         "insert":"16",
         "radius":"0.0625",
         "fractional":"1/16",
         "label":"  16        1.6mm/0.0625in            1/16"
      },{
         "insert":"20",
         "radius":"0.0781",
         "fractional":"5/64",
         "label":"  20        2.0mm/0.0781in            5/64"
      },{
         "insert":"24",
         "radius":"0.0938",
         "fractional":"3/32",
         "label":"  24        2.4mm/0.0938in            3/32"
      },{
         "insert":"28",
         "radius":"0.1094",
         "fractional":"7/64",
         "label":"  28        2.8mm/0.1094in            7/64"
      },{
         "insert":"32",
         "radius":"0.125",
         "fractional":"1/8",
         "label":"  32        3.2mm/0.1250in              1/8"
      },{
         "insert":"40",
         "radius":"0.15625",
         "fractional":"5/32",
         "label":"  40        4.0mm/0.1563in            5/32"
      },{
         "insert":"48",
         "radius":"0.1875",
         "fractional":"3/16",
         "label":"  48        4.8mm/0.1875in            3/16"
      },{
         "insert":"56",
         "radius":"0.21875",
         "fractional":"7/32",
         "label":"  56        5.6mm/0.2188in            7/32"
      },{
         "insert":"64",
         "radius":"0.25",
         "fractional":"1/4",
         "label":"  64        6.4mm/0.2500in              1/4"
      },{
         "insert":"80",
         "radius":"0.3125",
         "fractional":"5/16",
         "label":"  80        8.0mm/0.3125in            5/16"
      },{
         "insert":"96",
         "radius":"0.375",
         "fractional":"3/8",
         "label":"  96        9.6mm/0.3750in              3/8"
      },{
         "insert":"112",
         "radius":"0.4375",
         "fractional":"7/16",
         "label":"112        11.2mm/0.4375in            7/16"
      },{
         "insert":"128",
         "radius":"0.5",
         "fractional":"1/2",
         "label":"128        12.8mm/0.5000in              1/2"
      }]);
      
      public static var _1940320737millTapers:Array = ["BT","CAT","DIN","HSK","MT","NMTB","R8","Other"];
      
      public static var _2101708830millTaperSizes:Array = ["25","30","32","35","40","45","50","60","63","80","100","125","160"];
      
      public static var _2105954130latheSpindleNose:Array = ["A1 ","A2 ","B1 ","B2 ","D1 ","L ","Threaded ","Other"];
      
      public static const IPTData_Material:int = 0;
      
      public static const IPTData_Tool:int = 1;
      
      public static const IPTData_FirstDiameter:int = 2;
      
      public static const IPTData_LasttoolDiameter:int = 14;
      
      private static var _1825247731HolderTypes:Array = ["ER Collet Chuck","TG Collet Chuck","Setscrew Holder","Hydraulic","Milling Chuck","Tribos","Shrink Fit","Drill Chuck","Floating Tap"];
      
      private static var _311905989CoolantTypes:Array = ["Flood PCN","Flood","TSC","Mist","Air","None"];
      
      private static var _918858409ToolWear:Array = ["Normal","Poor","Chipped","Broken"];
      
      public static var annularCutterAreaFactors:ArrayCollection = new ArrayCollection([{
         "dia":0.25,
         "af":0.353
      },{
         "dia":0.3125,
         "af":0.353
      },{
         "dia":0.375,
         "af":0.353
      },{
         "dia":0.4375,
         "af":0.353
      },{
         "dia":0.5,
         "af":0.353
      },{
         "dia":0.5625,
         "af":0.353
      },{
         "dia":0.625,
         "af":0.353
      },{
         "dia":0.6875,
         "af":0.353
      },{
         "dia":0.75,
         "af":0.353
      },{
         "dia":0.8125,
         "af":0.43
      },{
         "dia":0.875,
         "af":0.418
      },{
         "dia":0.9375,
         "af":0.457
      },{
         "dia":1,
         "af":0.495
      },{
         "dia":1.0625,
         "af":0.714
      },{
         "dia":1.125,
         "af":0.766
      },{
         "dia":1.25,
         "af":0.818
      },{
         "dia":1.3125,
         "af":0.87
      },{
         "dia":1.375,
         "af":0.921
      },{
         "dia":1.4375,
         "af":0.973
      },{
         "dia":1.5,
         "af":1.025
      },{
         "dia":1.5625,
         "af":1.077
      },{
         "dia":1.625,
         "af":1.129
      },{
         "dia":1.6875,
         "af":1.181
      },{
         "dia":1.75,
         "af":1.232
      },{
         "dia":1.8125,
         "af":1.284
      },{
         "dia":1.875,
         "af":1.336
      },{
         "dia":1.9375,
         "af":1.388
      },{
         "dia":2,
         "af":1.44
      },{
         "dia":2.0625,
         "af":1.492
      },{
         "dia":2.125,
         "af":1.543
      },{
         "dia":2.25,
         "af":1.647
      },{
         "dia":2.3125,
         "af":1.699
      },{
         "dia":2.375,
         "af":1.751
      },{
         "dia":2.4375,
         "af":1.803
      },{
         "dia":2.5,
         "af":1.854
      },{
         "dia":2.5625,
         "af":1.906
      },{
         "dia":2.625,
         "af":1.958
      },{
         "dia":2.6875,
         "af":2.01
      },{
         "dia":2.75,
         "af":2.062
      },{
         "dia":2.8125,
         "af":2.114
      },{
         "dia":2.875,
         "af":2.166
      },{
         "dia":2.9375,
         "af":2.217
      },{
         "dia":3,
         "af":2.269
      }]);
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizConfigData()
      {
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
      }
      
      public static function findMaterialMF(param1:String) : Object
      {
         var _loc2_:Object = null;
         if(lastMaterialIndex >= 0 && lastMaterialIndex < GWizConfigData.MachinabilityFactors.length && param1.indexOf(GWizConfigData.MachinabilityFactors.getItemAt(lastMaterialIndex).material) >= 0)
         {
            return GWizConfigData.MachinabilityFactors.getItemAt(lastMaterialIndex);
         }
         var _loc3_:int = 0;
         while(_loc3_ < GWizConfigData.MachinabilityFactors.length)
         {
            if(param1.indexOf(GWizConfigData.MachinabilityFactors.getItemAt(_loc3_).material) >= 0)
            {
               _loc2_ = GWizConfigData.MachinabilityFactors.getItemAt(_loc3_);
               lastMaterialIndex = _loc3_;
               break;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function lookupSFMData(param1:String, param2:String) : Object
      {
         var _loc4_:Object = null;
         var _loc6_:String = null;
         ++recurseCt;
         if(recurseCt > 2)
         {
            return null;
         }
         var _loc3_:int = GWizConfigData.SFMData.length;
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            if((_loc4_ = GWizConfigData.SFMData.getItemAt(_loc5_)).material == param1 && _loc4_.tool == param2)
            {
               break;
            }
            _loc4_ = null;
            _loc5_++;
         }
         if(!_loc4_)
         {
            _loc6_ = GWizMaterialsDB.alloyToFamily(param1);
            if(param1 != "" && _loc6_ != param1)
            {
               _loc4_ = lookupSFMData(param1,param2);
            }
         }
         recurseCt = 0;
         return _loc4_;
      }
      
      public static function lookupDrillCeiling(param1:Number) : Object
      {
         var _loc2_:Object = DrillData[0];
         var _loc3_:int = 0;
         while(_loc3_ < DrillData.length)
         {
            _loc2_ = DrillData.getItemAt(_loc3_);
            if(_loc2_.inch > param1)
            {
               break;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function lookupDrillCeilingDesig(param1:Number) : String
      {
         var _loc2_:Object = lookupDrillCeiling(param1);
         var _loc3_:String = "";
         if(_loc2_ && _loc2_.hasOwnProperty("designation"))
         {
            if(_loc2_.inch > param1)
            {
               _loc3_ = _loc2_.designation;
            }
            else
            {
               _loc3_ = "";
            }
         }
         return _loc3_;
      }
      
      public static function HolderTypesLabelFcn(param1:Object) : String
      {
         var _loc2_:Number = Number(param1.toString());
         if(0 <= _loc2_ && _loc2_ <= HolderTypes.length)
         {
            return HolderTypes[_loc2_];
         }
         return "Unknown Holder";
      }
      
      public static function CoolantTypeLabelFcn(param1:Object) : String
      {
         var _loc2_:Number = Number(param1.toString());
         if(0 <= _loc2_ && _loc2_ <= CoolantTypes.length)
         {
            return CoolantTypes[_loc2_];
         }
         return "Unknown Coolant";
      }
      
      public static function ToolWearLabelFcn(param1:Object) : String
      {
         var _loc2_:Number = Number(param1.toString());
         if(0 <= _loc2_ && _loc2_ <= ToolWear.length)
         {
            return ToolWear[_loc2_];
         }
         return "Unknown Wear";
      }
      
      public static function threadPasses(param1:Number) : Number
      {
         var _loc2_:Number = 64;
         if(param1 < 0.04)
         {
            _loc2_ = 128;
         }
         else if(param1 < 0.06)
         {
            _loc2_ = 120;
         }
         else if(param1 < 0.08)
         {
            _loc2_ = 112;
         }
         else if(param1 < 0.09)
         {
            _loc2_ = 104;
         }
         else if(param1 < 0.12)
         {
            _loc2_ = 99;
         }
         else if(param1 < 0.14)
         {
            _loc2_ = 98;
         }
         else if(param1 < 0.18)
         {
            _loc2_ = 84;
         }
         else if(param1 < 0.19)
         {
            _loc2_ = 78;
         }
         else if(param1 < 0.23)
         {
            _loc2_ = 70;
         }
         else if(param1 < 0.24)
         {
            _loc2_ = 68;
         }
         else
         {
            _loc2_ = 64;
         }
         return Number(_loc2_ * param1);
      }
      
      public static function firstThreadPass(param1:Number, param2:Number) : Number
      {
         return param1 / Math.sqrt(param2);
      }
      
      [Bindable(event="propertyChange")]
      public static function get ToolsList() : ArrayCollection
      {
         return GWizConfigData._1605282041ToolsList;
      }
      
      public static function set ToolsList(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizConfigData._1605282041ToolsList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizConfigData,"ToolsList",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get ToolMaterials() : ArrayCollection
      {
         return GWizConfigData._684363436ToolMaterials;
      }
      
      public static function set ToolMaterials(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizConfigData._684363436ToolMaterials;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizConfigData,"ToolMaterials",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get MachinabilityFactors() : ArrayCollection
      {
         return GWizConfigData._66936840MachinabilityFactors;
      }
      
      public static function set MachinabilityFactors(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizConfigData._66936840MachinabilityFactors;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizConfigData,"MachinabilityFactors",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get DrillData() : ArrayCollection
      {
         return GWizConfigData._356480645DrillData;
      }
      
      public static function set DrillData(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizConfigData._356480645DrillData;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizConfigData,"DrillData",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get UnitTypeList() : Array
      {
         return GWizConfigData._991341380UnitTypeList;
      }
      
      public static function set UnitTypeList(param1:Array) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizConfigData._991341380UnitTypeList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizConfigData,"UnitTypeList",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get CenterDrillList() : ArrayCollection
      {
         return GWizConfigData._904606372CenterDrillList;
      }
      
      public static function set CenterDrillList(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizConfigData._904606372CenterDrillList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizConfigData,"CenterDrillList",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get StandardTaperList() : ArrayCollection
      {
         return GWizConfigData._551932401StandardTaperList;
      }
      
      public static function set StandardTaperList(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizConfigData._551932401StandardTaperList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizConfigData,"StandardTaperList",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get InsertNoseRadiusList() : ArrayCollection
      {
         return GWizConfigData._1465048132InsertNoseRadiusList;
      }
      
      public static function set InsertNoseRadiusList(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizConfigData._1465048132InsertNoseRadiusList;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizConfigData,"InsertNoseRadiusList",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get millTapers() : Array
      {
         return GWizConfigData._1940320737millTapers;
      }
      
      public static function set millTapers(param1:Array) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizConfigData._1940320737millTapers;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizConfigData,"millTapers",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get millTaperSizes() : Array
      {
         return GWizConfigData._2101708830millTaperSizes;
      }
      
      public static function set millTaperSizes(param1:Array) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizConfigData._2101708830millTaperSizes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizConfigData,"millTaperSizes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get latheSpindleNose() : Array
      {
         return GWizConfigData._2105954130latheSpindleNose;
      }
      
      public static function set latheSpindleNose(param1:Array) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizConfigData._2105954130latheSpindleNose;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizConfigData,"latheSpindleNose",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get HolderTypes() : Array
      {
         return GWizConfigData._1825247731HolderTypes;
      }
      
      public static function set HolderTypes(param1:Array) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizConfigData._1825247731HolderTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizConfigData,"HolderTypes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get CoolantTypes() : Array
      {
         return GWizConfigData._311905989CoolantTypes;
      }
      
      public static function set CoolantTypes(param1:Array) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizConfigData._311905989CoolantTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizConfigData,"CoolantTypes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get ToolWear() : Array
      {
         return GWizConfigData._918858409ToolWear;
      }
      
      public static function set ToolWear(param1:Array) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizConfigData._918858409ToolWear;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizConfigData,"ToolWear",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this._bindingEventDispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this._bindingEventDispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this._bindingEventDispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.willTrigger(param1);
      }
   }
}
