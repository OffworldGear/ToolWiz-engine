package threads2
{
   import configinfo.GWizAbstractPrefs;
   import mx.collections.ArrayCollection;
   import utils.GWizUtils;
   
   public class GWizWhitworthThreadEngine extends GWizAbstractThreadEngine
   {
      
      private static var BSWIntThreadImg:Class = GWizWhitworthThreadEngine_BSWIntThreadImg;
      
      private static var BSWExtThreadImg:Class = GWizWhitworthThreadEngine_BSWExtThreadImg;
      
      public static var BSWStdSizes:ArrayCollection = new ArrayCollection([{
         "Family":"BSW",
         "Size":"1/16-60",
         "NominalSize":"0.0625",
         "TPI":"60",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"3/32-48",
         "NominalSize":"0.09375",
         "TPI":"48",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"1/8-40",
         "NominalSize":"0.125",
         "TPI":"40",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"5/32-32",
         "NominalSize":"0.15625",
         "TPI":"32",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"3/16-24",
         "NominalSize":"0.1875",
         "TPI":"24",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"7/32-24",
         "NominalSize":"0.21875",
         "TPI":"24",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"1/4-20",
         "NominalSize":"0.25",
         "TPI":"20",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"5/16-18",
         "NominalSize":"0.3125",
         "TPI":"18",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"3/8-16",
         "NominalSize":"0.375",
         "TPI":"16",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"7/16-14",
         "NominalSize":"0.4375",
         "TPI":"14",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"1/2-12",
         "NominalSize":"0.5",
         "TPI":"12",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"9/16-12",
         "NominalSize":"0.5625",
         "TPI":"12",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"5/8-11",
         "NominalSize":"0.625",
         "TPI":"11",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"11/16-11",
         "NominalSize":"0.6875",
         "TPI":"11",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"3/4-10",
         "NominalSize":"0.75",
         "TPI":"10",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"13/16-10",
         "NominalSize":"0.8125",
         "TPI":"10",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"7/8-9",
         "NominalSize":"0.875",
         "TPI":"9",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"15/16-9",
         "NominalSize":"0.9375",
         "TPI":"9",
         "ThreadAngle":"55"
      },{
         "Family":"BSW",
         "Size":"1 inch-8",
         "NominalSize":"1",
         "TPI":"8",
         "ThreadAngle":"55"
      }]);
      
      public static var BSFStdSizes:ArrayCollection = new ArrayCollection([{
         "Family":"BSF",
         "Size":"3/16-32",
         "NominalSize":"0.1875",
         "TPI":"32",
         "ThreadAngle":"55"
      },{
         "Family":"BSF",
         "Size":"7/32-28",
         "NominalSize":"0.21875",
         "TPI":"28",
         "ThreadAngle":"55"
      },{
         "Family":"BSF",
         "Size":"1/4-26",
         "NominalSize":"0.25",
         "TPI":"26",
         "ThreadAngle":"55"
      },{
         "Family":"BSF",
         "Size":"5/16-22",
         "NominalSize":"0.3125",
         "TPI":"22",
         "ThreadAngle":"55"
      },{
         "Family":"BSF",
         "Size":"3/8-20",
         "NominalSize":"0.375",
         "TPI":"20",
         "ThreadAngle":"55"
      },{
         "Family":"BSF",
         "Size":"7/16-18",
         "NominalSize":"0.4375",
         "TPI":"18",
         "ThreadAngle":"55"
      },{
         "Family":"BSF",
         "Size":"1/2-16",
         "NominalSize":"0.5",
         "TPI":"16",
         "ThreadAngle":"55"
      },{
         "Family":"BSF",
         "Size":"9/16-16",
         "NominalSize":"0.5625",
         "TPI":"16",
         "ThreadAngle":"55"
      },{
         "Family":"BSF",
         "Size":"5/8-14",
         "NominalSize":"0.625",
         "TPI":"14",
         "ThreadAngle":"55"
      },{
         "Family":"BSF",
         "Size":"11/16-14",
         "NominalSize":"0.6875",
         "TPI":"14",
         "ThreadAngle":"55"
      },{
         "Family":"BSF",
         "Size":"3/4-12",
         "NominalSize":"0.75",
         "TPI":"12",
         "ThreadAngle":"55"
      },{
         "Family":"BSF",
         "Size":"7/8-11",
         "NominalSize":"0.875",
         "TPI":"11",
         "ThreadAngle":"55"
      },{
         "Family":"BSF",
         "Size":"1 inch-10",
         "NominalSize":"1",
         "TPI":"10",
         "ThreadAngle":"55"
      },{
         "Family":"BSF",
         "Size":"1 1/8-9",
         "NominalSize":"1",
         "TPI":"9",
         "ThreadAngle":"55"
      },{
         "Family":"BSF",
         "Size":"1 1/4-9",
         "NominalSize":"1",
         "TPI":"9",
         "ThreadAngle":"55"
      },{
         "Family":"BSF",
         "Size":"1 1/2-8",
         "NominalSize":"1",
         "TPI":"8",
         "ThreadAngle":"55"
      }]);
      
      public static var BSPPStdSizes:ArrayCollection = new ArrayCollection([{
         "Family":"BSPP",
         "Size":"1/16-28",
         "NominalSize":"7.723",
         "TPI":"28",
         "ThreadAngle":"55",
         "PitchDia":"7.142",
         "MinorDia":"6.561",
         "TD2Lower":"0",
         "TD2Upper":"0.107",
         "Td2ClassALower":"-0.107",
         "Td2ClassBLower":"-0.214",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.282",
         "TdLower":"-0.214",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"1/8-28",
         "NominalSize":"9.728",
         "TPI":"28",
         "ThreadAngle":"55",
         "PitchDia":"9.147",
         "MinorDia":"8.566",
         "TD2Lower":"0",
         "TD2Upper":"0.107",
         "Td2ClassALower":"-0.107",
         "Td2ClassBLower":"-0.214",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.282",
         "TdLower":"-0.214",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"1/4-19",
         "NominalSize":"13.157",
         "TPI":"19",
         "ThreadAngle":"55",
         "PitchDia":"12.301",
         "MinorDia":"11.445",
         "TD2Lower":"0",
         "TD2Upper":"0.125",
         "Td2ClassALower":"-0.125",
         "Td2ClassBLower":"-0.25",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.445",
         "TdLower":"-0.25",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"3/8-19",
         "NominalSize":"16.662",
         "TPI":"19",
         "ThreadAngle":"55",
         "PitchDia":"15.806",
         "MinorDia":"14.95",
         "TD2Lower":"0",
         "TD2Upper":"0.125",
         "Td2ClassALower":"-0.125",
         "Td2ClassBLower":"-0.25",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.445",
         "TdLower":"-0.25",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"1/2-14",
         "NominalSize":"20.955",
         "TPI":"14",
         "ThreadAngle":"55",
         "PitchDia":"19.793",
         "MinorDia":"18.631",
         "TD2Lower":"0",
         "TD2Upper":"0.142",
         "Td2ClassALower":"-0.142",
         "Td2ClassBLower":"-0.284",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.541",
         "TdLower":"-0.284",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"5/8-14",
         "NominalSize":"22.911",
         "TPI":"14",
         "ThreadAngle":"55",
         "PitchDia":"21.749",
         "MinorDia":"20.587",
         "TD2Lower":"0",
         "TD2Upper":"0.142",
         "Td2ClassALower":"-0.142",
         "Td2ClassBLower":"-0.284",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.541",
         "TdLower":"-0.284",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"3/4-14",
         "NominalSize":"26.441",
         "TPI":"14",
         "ThreadAngle":"55",
         "PitchDia":"25.279",
         "MinorDia":"24.117",
         "TD2Lower":"0",
         "TD2Upper":"0.142",
         "Td2ClassALower":"-0.142",
         "Td2ClassBLower":"-0.284",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.541",
         "TdLower":"-0.284",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"7/8-14",
         "NominalSize":"30.201",
         "TPI":"14",
         "ThreadAngle":"55",
         "PitchDia":"29.039",
         "MinorDia":"27.877",
         "TD2Lower":"0",
         "TD2Upper":"0.142",
         "Td2ClassALower":"-0.142",
         "Td2ClassBLower":"-0.284",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.541",
         "TdLower":"-0.284",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"1-11",
         "NominalSize":"33.249",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"31.77",
         "MinorDia":"30.291",
         "TD2Lower":"0",
         "TD2Upper":"0.18",
         "Td2ClassALower":"-0.18",
         "Td2ClassBLower":"-0.36",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.36",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"1 1/8-11",
         "NominalSize":"37.897",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"36.418",
         "MinorDia":"34.939",
         "TD2Lower":"0",
         "TD2Upper":"0.18",
         "Td2ClassALower":"-0.18",
         "Td2ClassBLower":"-0.36",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.36",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"1 1/4-11",
         "NominalSize":"41.91",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"40.431",
         "MinorDia":"38.952",
         "TD2Lower":"0",
         "TD2Upper":"0.18",
         "Td2ClassALower":"-0.18",
         "Td2ClassBLower":"-0.36",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.36",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"1 1/2-11",
         "NominalSize":"47.803",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"46.324",
         "MinorDia":"44.845",
         "TD2Lower":"0",
         "TD2Upper":"0.18",
         "Td2ClassALower":"-0.18",
         "Td2ClassBLower":"-0.36",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.36",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"1 3/4-11",
         "NominalSize":"53.746",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"52.267",
         "MinorDia":"50.788",
         "TD2Lower":"0",
         "TD2Upper":"0.18",
         "Td2ClassALower":"-0.18",
         "Td2ClassBLower":"-0.36",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.36",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"2-11",
         "NominalSize":"59.614",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"58.135",
         "MinorDia":"56.656",
         "TD2Lower":"0",
         "TD2Upper":"0.18",
         "Td2ClassALower":"-0.18",
         "Td2ClassBLower":"-0.36",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.36",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"2 1/4-11",
         "NominalSize":"65.71",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"64.231",
         "MinorDia":"62.752",
         "TD2Lower":"0",
         "TD2Upper":"0.217",
         "Td2ClassALower":"-0.217",
         "Td2ClassBLower":"-0.434",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.434",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"2 1/2-11",
         "NominalSize":"75.184",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"73.705",
         "MinorDia":"72.226",
         "TD2Lower":"0",
         "TD2Upper":"0.217",
         "Td2ClassALower":"-0.217",
         "Td2ClassBLower":"-0.434",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.434",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"2 3/4-11",
         "NominalSize":"81.534",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"80.055",
         "MinorDia":"78.576",
         "TD2Lower":"0",
         "TD2Upper":"0.217",
         "Td2ClassALower":"-0.217",
         "Td2ClassBLower":"-0.434",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.434",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"3-11",
         "NominalSize":"87.884",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"86.405",
         "MinorDia":"84.926",
         "TD2Lower":"0",
         "TD2Upper":"0.217",
         "Td2ClassALower":"-0.217",
         "Td2ClassBLower":"-0.434",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.434",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"3 1/2-11",
         "NominalSize":"100.33",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"98.851",
         "MinorDia":"97.372",
         "TD2Lower":"0",
         "TD2Upper":"0.217",
         "Td2ClassALower":"-0.217",
         "Td2ClassBLower":"-0.434",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.434",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"4-11",
         "NominalSize":"113.03",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"111.551",
         "MinorDia":"110.072",
         "TD2Lower":"0",
         "TD2Upper":"0.217",
         "Td2ClassALower":"-0.217",
         "Td2ClassBLower":"-0.434",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.434",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"4 1/2-11",
         "NominalSize":"125.73",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"124.251",
         "MinorDia":"122.772",
         "TD2Lower":"0",
         "TD2Upper":"0.217",
         "Td2ClassALower":"-0.217",
         "Td2ClassBLower":"-0.434",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.434",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"5-11",
         "NominalSize":"138.43",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"139.951",
         "MinorDia":"135.472",
         "TD2Lower":"0",
         "TD2Upper":"0.217",
         "Td2ClassALower":"-0.217",
         "Td2ClassBLower":"-0.434",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.434",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"5 1/2-11",
         "NominalSize":"151.13",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"149.651",
         "MinorDia":"148.172",
         "TD2Lower":"0",
         "TD2Upper":"0.217",
         "Td2ClassALower":"-0.217",
         "Td2ClassBLower":"-0.434",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.434",
         "TdUpper":"0"
      },{
         "Family":"BSPP",
         "Size":"6-11",
         "NominalSize":"163.83",
         "TPI":"11",
         "ThreadAngle":"55",
         "PitchDia":"162.351",
         "MinorDia":"160.872",
         "TD2Lower":"0",
         "TD2Upper":"0.217",
         "Td2ClassALower":"-0.217",
         "Td2ClassBLower":"-0.434",
         "Td2Upper":"0",
         "TD1Lower":"0",
         "TD1Upper":"0.64",
         "TdLower":"-0.434",
         "TdUpper":"0"
      }]);
      
      public static var BAStdSizes:ArrayCollection = new ArrayCollection([{
         "Family":"BA",
         "Size":"#16 BA",
         "NominalSize":"0.0311023622047244",
         "TPI":"133.684210526316"
      },{
         "Family":"BA",
         "Size":"#15 BA",
         "NominalSize":"0.0354330708661417",
         "TPI":"120.952380952381"
      },{
         "Family":"BA",
         "Size":"#14 BA",
         "NominalSize":"0.0393700787401575",
         "TPI":"110.434782608696"
      },{
         "Family":"BA",
         "Size":"#13 BA",
         "NominalSize":"0.047244094488189",
         "TPI":"101.6"
      },{
         "Family":"BA",
         "Size":"#12 BA",
         "NominalSize":"0.0511811023622047",
         "TPI":"90.7142857142857"
      },{
         "Family":"BA",
         "Size":"#11 BA",
         "NominalSize":"0.0590551181102362",
         "TPI":"81.9354838709677"
      },{
         "Family":"BA",
         "Size":"#10 BA",
         "NominalSize":"0.0669291338582677",
         "TPI":"72.5714285714286"
      },{
         "Family":"BA",
         "Size":"#9 BA",
         "NominalSize":"0.0748031496062992",
         "TPI":"65.1282051282051"
      },{
         "Family":"BA",
         "Size":"#8 BA",
         "NominalSize":"0.0866141732283465",
         "TPI":"59.0697674418605"
      },{
         "Family":"BA",
         "Size":"#7 BA",
         "NominalSize":"0.0984251968503937",
         "TPI":"52.9166666666667"
      },{
         "Family":"BA",
         "Size":"#6 BA",
         "NominalSize":"0.110236220472441",
         "TPI":"47.9245283018868"
      },{
         "Family":"BA",
         "Size":"#5 BA",
         "NominalSize":"0.125984251968504",
         "TPI":"43.0508474576271"
      },{
         "Family":"BA",
         "Size":"#4 BA",
         "NominalSize":"0.141732283464567",
         "TPI":"38.4848484848485"
      },{
         "Family":"BA",
         "Size":"#3 BA",
         "NominalSize":"0.161417322834646",
         "TPI":"34.7945205479452"
      },{
         "Family":"BA",
         "Size":"#2 BA",
         "NominalSize":"0.18503937007874",
         "TPI":"31.358024691358"
      },{
         "Family":"BA",
         "Size":"#1 BA",
         "NominalSize":"0.208661417322835",
         "TPI":"28.2222222222222"
      },{
         "Family":"BA",
         "Size":"#0 BA",
         "NominalSize":"0.236220472440945",
         "TPI":"25.4",
         "Type":"Internal"
      }]);
      
      public static var BSAStdSizesData:ArrayCollection = new ArrayCollection([{
         "Family":"BA",
         "Size":"#16 BA",
         "NominalSize":"0.0311023622047244",
         "TPI":"133.684210526316",
         "Type":"Internal",
         "MinPitchDia":"0.0265748031496063",
         "MaxPitchDia":"0.028740157480315",
         "MinMinorDia":"0.0220472440944882",
         "MaxMinorDia":"0.0248031496062992"
      },{
         "Family":"BA",
         "Size":"#15 BA",
         "NominalSize":"0.0354330708661417",
         "TPI":"120.952380952381",
         "Type":"Internal",
         "MinPitchDia":"0.030511811023622",
         "MaxPitchDia":"0.0326771653543307",
         "MinMinorDia":"0.0255905511811024",
         "MaxMinorDia":"0.028740157480315"
      },{
         "Family":"BA",
         "Size":"#14 BA",
         "NominalSize":"0.0393700787401575",
         "TPI":"110.434782608696",
         "Type":"Internal",
         "MinPitchDia":"0.0338582677165354",
         "MaxPitchDia":"0.0362204724409449",
         "MinMinorDia":"0.0283464566929134",
         "MaxMinorDia":"0.0316929133858268"
      },{
         "Family":"BA",
         "Size":"#13 BA",
         "NominalSize":"0.047244094488189",
         "TPI":"101.6",
         "Type":"Internal",
         "MinPitchDia":"0.0413385826771654",
         "MaxPitchDia":"0.0437007874015748",
         "MinMinorDia":"0.0354330708661417",
         "MaxMinorDia":"0.0391732283464567"
      },{
         "Family":"BA",
         "Size":"#12 BA",
         "NominalSize":"0.0511811023622047",
         "TPI":"90.7142857142857",
         "Type":"Internal",
         "MinPitchDia":"0.0444881889763779",
         "MaxPitchDia":"0.0470472440944882",
         "MinMinorDia":"0.0377952755905512",
         "MaxMinorDia":"0.0419291338582677"
      },{
         "Family":"BA",
         "Size":"#11 BA",
         "NominalSize":"0.0590551181102362",
         "TPI":"81.9354838709677",
         "Type":"Internal",
         "MinPitchDia":"0.0517716535433071",
         "MaxPitchDia":"0.0543307086614173",
         "MinMinorDia":"0.0444881889763779",
         "MaxMinorDia":"0.0490157480314961"
      },{
         "Family":"BA",
         "Size":"#10 BA",
         "NominalSize":"0.0669291338582677",
         "TPI":"72.5714285714286",
         "Type":"Internal",
         "MinPitchDia":"0.0586614173228346",
         "MaxPitchDia":"0.0614173228346457",
         "MinMinorDia":"0.0503937007874016",
         "MaxMinorDia":"0.055511811023622"
      },{
         "Family":"BA",
         "Size":"#9 BA",
         "NominalSize":"0.0748031496062992",
         "TPI":"65.1282051282051",
         "Type":"Internal",
         "MinPitchDia":"0.0655511811023622",
         "MaxPitchDia":"0.068503937007874",
         "MinMinorDia":"0.0562992125984252",
         "MaxMinorDia":"0.062007874015748"
      },{
         "Family":"BA",
         "Size":"#8 BA",
         "NominalSize":"0.0866141732283465",
         "TPI":"59.0697674418605",
         "Type":"Internal",
         "MinPitchDia":"0.0763779527559055",
         "MaxPitchDia":"0.0795275590551181",
         "MinMinorDia":"0.0661417322834646",
         "MaxMinorDia":"0.0724409448818898"
      },{
         "Family":"BA",
         "Size":"#7 BA",
         "NominalSize":"0.0984251968503937",
         "TPI":"52.9166666666667",
         "Type":"Internal",
         "MinPitchDia":"0.087007874015748",
         "MaxPitchDia":"0.0905511811023622",
         "MinMinorDia":"0.0755905511811024",
         "MaxMinorDia":"0.0826771653543307"
      },{
         "Family":"BA",
         "Size":"#6 BA",
         "NominalSize":"0.110236220472441",
         "TPI":"47.9245283018868",
         "Type":"Internal",
         "MinPitchDia":"0.0976377952755905",
         "MaxPitchDia":"0.101377952755906",
         "MinMinorDia":"0.0850393700787402",
         "MaxMinorDia":"0.0929133858267717"
      },{
         "Family":"BA",
         "Size":"#5 BA",
         "NominalSize":"0.125984251968504",
         "TPI":"43.0508474576271",
         "Type":"Internal",
         "MinPitchDia":"0.112007874015748",
         "MaxPitchDia":"0.115944881889764",
         "MinMinorDia":"0.0980314960629921",
         "MaxMinorDia":"0.106692913385827"
      },{
         "Family":"BA",
         "Size":"#4 BA",
         "NominalSize":"0.141732283464567",
         "TPI":"38.4848484848485",
         "Type":"Internal",
         "MinPitchDia":"0.126181102362205",
         "MaxPitchDia":"0.130511811023622",
         "MinMinorDia":"0.110629921259843",
         "MaxMinorDia":"0.120472440944882"
      },{
         "Family":"BA",
         "Size":"#3 BA",
         "NominalSize":"0.161417322834646",
         "TPI":"34.7945205479452",
         "Type":"Internal",
         "MinPitchDia":"0.144094488188976",
         "MaxPitchDia":"0.148818897637795",
         "MinMinorDia":"0.126771653543307",
         "MaxMinorDia":"0.13759842519685"
      },{
         "Family":"BA",
         "Size":"#2 BA",
         "NominalSize":"0.18503937007874",
         "TPI":"31.358024691358",
         "Type":"Internal",
         "MinPitchDia":"0.165944881889764",
         "MaxPitchDia":"0.170866141732283",
         "MinMinorDia":"0.146850393700787",
         "MaxMinorDia":"0.158858267716535"
      },{
         "Family":"BA",
         "Size":"#1 BA",
         "NominalSize":"0.208661417322835",
         "TPI":"28.2222222222222",
         "Type":"Internal",
         "MinPitchDia":"0.18740157480315",
         "MaxPitchDia":"0.192913385826772",
         "MinMinorDia":"0.166141732283465",
         "MaxMinorDia":"0.179527559055118"
      },{
         "Family":"BA",
         "Size":"#0 BA",
         "NominalSize":"0.236220472440945",
         "TPI":"25.4",
         "Type":"Internal",
         "MinPitchDia":"0.21259842519685",
         "MaxPitchDia":"0.218503937007874",
         "MinMinorDia":"0.188976377952756",
         "MaxMinorDia":"0.203740157480315"
      },{
         "Family":"BA",
         "Size":"#16 BA",
         "NominalSize":"0.0311023622047244",
         "TPI":"133.684210526316",
         "Type":"External Normal",
         "MinPitchDia":"0.0248031496062992",
         "MaxPitchDia":"0.0265748031496063",
         "MinMinorDia":"0.018503937007874",
         "MaxMinorDia":"0.0220472440944882",
         "MinMajorDia":"0.0291338582677165"
      },{
         "Family":"BA",
         "Size":"#15 BA",
         "NominalSize":"0.0354330708661417",
         "TPI":"120.952380952381",
         "Type":"External Normal",
         "MinPitchDia":"0.028740157480315",
         "MaxPitchDia":"0.030511811023622",
         "MinMinorDia":"0.0220472440944882",
         "MaxMinorDia":"0.0255905511811024",
         "MinMajorDia":"0.0332677165354331"
      },{
         "Family":"BA",
         "Size":"#14 BA",
         "NominalSize":"0.0393700787401575",
         "TPI":"110.434782608696",
         "Type":"External Normal",
         "MinPitchDia":"0.0318897637795276",
         "MaxPitchDia":"0.0338582677165354",
         "MinMinorDia":"0.0246062992125984",
         "MaxMinorDia":"0.0283464566929134",
         "MinMajorDia":"0.037007874015748"
      },{
         "Family":"BA",
         "Size":"#13 BA",
         "NominalSize":"0.047244094488189",
         "TPI":"101.6",
         "Type":"External Normal",
         "MinPitchDia":"0.0393700787401575",
         "MaxPitchDia":"0.0413385826771654",
         "MinMinorDia":"0.031496062992126",
         "MaxMinorDia":"0.0354330708661417",
         "MinMajorDia":"0.0446850393700787"
      },{
         "Family":"BA",
         "Size":"#12 BA",
         "NominalSize":"0.0511811023622047",
         "TPI":"90.7142857142857",
         "Type":"External Normal",
         "MinPitchDia":"0.0423228346456693",
         "MaxPitchDia":"0.0444881889763779",
         "MinMinorDia":"0.0336614173228346",
         "MaxMinorDia":"0.0377952755905512",
         "MinMajorDia":"0.0484251968503937"
      },{
         "Family":"BA",
         "Size":"#11 BA",
         "NominalSize":"0.0590551181102362",
         "TPI":"81.9354838709677",
         "Type":"External Normal",
         "MinPitchDia":"0.0496062992125984",
         "MaxPitchDia":"0.0517716535433071",
         "MinMinorDia":"0.0401574803149606",
         "MaxMinorDia":"0.0444881889763779",
         "MinMajorDia":"0.0559055118110236"
      },{
         "Family":"BA",
         "Size":"#10 BA",
         "NominalSize":"0.0659448818897638",
         "TPI":"72.5714285714286",
         "Type":"External Normal",
         "MinPitchDia":"0.059251968503937",
         "MaxPitchDia":"0.0576771653543307",
         "MinMinorDia":"0.0446850393700787",
         "MaxMinorDia":"0.0494094488188976",
         "MinMajorDia":"0.0631889763779528"
      },{
         "Family":"BA",
         "Size":"#9 BA",
         "NominalSize":"0.0738188976377953",
         "TPI":"65.1282051282051",
         "Type":"External Normal",
         "MinPitchDia":"0.062007874015748",
         "MaxPitchDia":"0.0645669291338583",
         "MinMinorDia":"0.0501968503937008",
         "MaxMinorDia":"0.0553149606299213",
         "MinMajorDia":"0.0706692913385827"
      },{
         "Family":"BA",
         "Size":"#8 BA",
         "NominalSize":"0.0856299212598425",
         "TPI":"59.0697674418605",
         "Type":"External Normal",
         "MinPitchDia":"0.0726377952755906",
         "MaxPitchDia":"0.0753937007874016",
         "MinMinorDia":"0.0598425196850394",
         "MaxMinorDia":"0.0651574803149606",
         "MinMajorDia":"0.0822834645669291"
      },{
         "Family":"BA",
         "Size":"#7 BA",
         "NominalSize":"0.0974409448818898",
         "TPI":"52.9166666666667",
         "Type":"External Normal",
         "MinPitchDia":"0.0830708661417323",
         "MaxPitchDia":"0.0860236220472441",
         "MinMinorDia":"0.0688976377952756",
         "MaxMinorDia":"0.0746062992125984",
         "MinMajorDia":"0.0937007874015748"
      },{
         "Family":"BA",
         "Size":"#6 BA",
         "NominalSize":"0.109251968503937",
         "TPI":"47.9245283018868",
         "Type":"External Normal",
         "MinPitchDia":"0.093503937007874",
         "MaxPitchDia":"0.0966535433070866",
         "MinMinorDia":"0.0779527559055118",
         "MaxMinorDia":"0.0840551181102362",
         "MinMajorDia":"0.10511811023622"
      },{
         "Family":"BA",
         "Size":"#5 BA",
         "NominalSize":"0.125",
         "TPI":"43.0508474576271",
         "Type":"External Normal",
         "MinPitchDia":"0.107677165354331",
         "MaxPitchDia":"0.111023622047244",
         "MinMinorDia":"0.0903543307086614",
         "MaxMinorDia":"0.0970472440944882",
         "MinMajorDia":"0.120275590551181"
      },{
         "Family":"BA",
         "Size":"#4 BA",
         "NominalSize":"0.140748031496063",
         "TPI":"38.4848484848485",
         "Type":"External Normal",
         "MinPitchDia":"0.121653543307087",
         "MaxPitchDia":"0.125196850393701",
         "MinMinorDia":"0.10255905511811",
         "MaxMinorDia":"0.109645669291339",
         "MinMajorDia":"0.135629921259843"
      },{
         "Family":"BA",
         "Size":"#3 BA",
         "NominalSize":"0.160433070866142",
         "TPI":"34.7945205479452",
         "Type":"External Normal",
         "MinPitchDia":"0.140748031496063",
         "MaxPitchDia":"0.143110236220472",
         "MinMinorDia":"0.118110236220472",
         "MaxMinorDia":"0.125787401574803",
         "MinMajorDia":"0.154724409448819"
      },{
         "Family":"BA",
         "Size":"#2 BA",
         "NominalSize":"0.184055118110236",
         "TPI":"31.358024691358",
         "Type":"External Normal",
         "MinPitchDia":"0.160826771653543",
         "MaxPitchDia":"0.16496062992126",
         "MinMinorDia":"0.13759842519685",
         "MaxMinorDia":"0.145866141732283",
         "MinMajorDia":"0.163425196850394"
      },{
         "Family":"BA",
         "Size":"#1 BA",
         "NominalSize":"0.207677165354331",
         "TPI":"28.2222222222222",
         "Type":"External Normal",
         "MinPitchDia":"0.181102362204724",
         "MaxPitchDia":"0.186417322834646",
         "MinMinorDia":"0.156102362204724",
         "MaxMinorDia":"0.165157480314961",
         "MinMajorDia":"0.200590551181102"
      },{
         "Family":"BA",
         "Size":"#0 BA",
         "NominalSize":"0.235236220472441",
         "TPI":"25.4",
         "Type":"External Normal",
         "MinPitchDia":"0.206692913385827",
         "MaxPitchDia":"0.211614173228346",
         "MinMinorDia":"0.178149606299213",
         "MaxMinorDia":"0.187992125984252",
         "MinMajorDia":"0.227362204724409"
      },{
         "Family":"BA",
         "Size":"#10 BA",
         "NominalSize":"0.0669291338582677",
         "TPI":"72.5714285714286",
         "Type":"External Close",
         "MinPitchDia":"0.0566929133858268",
         "MaxPitchDia":"0.0586614173228346",
         "MinMinorDia":"0.0466535433070866",
         "MaxMinorDia":"0.0503937007874016",
         "MinMajorDia":"0.0647637795275591"
      },{
         "Family":"BA",
         "Size":"#9 BA",
         "NominalSize":"0.0748031496062992",
         "TPI":"65.1282051282051",
         "Type":"External Close",
         "MinPitchDia":"0.0635826771653543",
         "MaxPitchDia":"0.0655511811023622",
         "MinMinorDia":"0.0523622047244095",
         "MaxMinorDia":"0.0562992125984252",
         "MinMajorDia":"0.0724409448818898"
      },{
         "Family":"BA",
         "Size":"#8 BA",
         "NominalSize":"0.0866141732283465",
         "TPI":"59.0697674418605",
         "Type":"External Close",
         "MinPitchDia":"0.0742125984251969",
         "MaxPitchDia":"0.0763779527559055",
         "MinMinorDia":"0.0618110236220472",
         "MaxMinorDia":"0.0661417322834646",
         "MinMajorDia":"0.0840551181102362"
      },{
         "Family":"BA",
         "Size":"#7 BA",
         "NominalSize":"0.0984251968503937",
         "TPI":"52.9166666666667",
         "Type":"External Close",
         "MinPitchDia":"0.0846456692913386",
         "MaxPitchDia":"0.087007874015748",
         "MinMinorDia":"0.0710629921259843",
         "MaxMinorDia":"0.0755905511811024",
         "MinMajorDia":"0.0956692913385827"
      },{
         "Family":"BA",
         "Size":"#6 BA",
         "NominalSize":"0.110236220472441",
         "TPI":"47.9245283018868",
         "Type":"External Close",
         "MinPitchDia":"0.0952755905511811",
         "MaxPitchDia":"0.0976377952755905",
         "MinMinorDia":"0.0801181102362205",
         "MaxMinorDia":"0.0850393700787402",
         "MinMajorDia":"0.107086614173228"
      },{
         "Family":"BA",
         "Size":"#5 BA",
         "NominalSize":"0.125984251968504",
         "TPI":"43.0508474576271",
         "Type":"External Close",
         "MinPitchDia":"0.109251968503937",
         "MaxPitchDia":"0.112007874015748",
         "MinMinorDia":"0.0927165354330709",
         "MaxMinorDia":"0.0980314960629921",
         "MinMajorDia":"0.12244094488189"
      },{
         "Family":"BA",
         "Size":"#4 BA",
         "NominalSize":"0.141732283464567",
         "TPI":"38.4848484848485",
         "Type":"External Close",
         "MinPitchDia":"0.123228346456693",
         "MaxPitchDia":"0.126181102362205",
         "MinMinorDia":"0.10492125984252",
         "MaxMinorDia":"0.110629921259843",
         "MinMajorDia":"0.137795275590551"
      },{
         "Family":"BA",
         "Size":"#3 BA",
         "NominalSize":"0.161417322834646",
         "TPI":"34.7945205479452",
         "Type":"External Close",
         "MinPitchDia":"0.140944881889764",
         "MaxPitchDia":"0.144094488188976",
         "MinMinorDia":"0.120669291338583",
         "MaxMinorDia":"0.126771653543307",
         "MinMajorDia":"0.157086614173228"
      },{
         "Family":"BA",
         "Size":"#2 BA",
         "NominalSize":"0.18503937007874",
         "TPI":"31.358024691358",
         "Type":"External Close",
         "MinPitchDia":"0.16259842519685",
         "MaxPitchDia":"0.165944881889764",
         "MinMinorDia":"0.140157480314961",
         "MaxMinorDia":"0.146850393700787",
         "MinMajorDia":"0.180314960629921"
      },{
         "Family":"BA",
         "Size":"#1 BA",
         "NominalSize":"0.208661417322835",
         "TPI":"28.2222222222222",
         "Type":"External Close",
         "MinPitchDia":"0.183858267716535",
         "MaxPitchDia":"0.18740157480315",
         "MinMinorDia":"0.158858267716535",
         "MaxMinorDia":"0.166141732283465",
         "MinMajorDia":"0.203346456692913"
      },{
         "Family":"BA",
         "Size":"#0 BA",
         "NominalSize":"0.236220472440945",
         "TPI":"25.4",
         "Type":"External Close",
         "MinPitchDia":"0.208661417322835",
         "MaxPitchDia":"0.21259842519685",
         "MinMinorDia":"0.181102362204724",
         "MaxMinorDia":"0.188976377952756",
         "MinMajorDia":"0.230314960629921"
      }]);
       
      
      private var extClasses:ArrayCollection;
      
      private var extBAClasses:ArrayCollection;
      
      private var extBSPPClasses:ArrayCollection;
      
      private var intClasses:ArrayCollection;
      
      public function GWizWhitworthThreadEngine()
      {
         this.extClasses = new ArrayCollection([{"Class":"Close"},{"Class":"Medium"},{"Class":"Free"}]);
         this.extBAClasses = new ArrayCollection([{"Class":"Close"},{"Class":"Normal"}]);
         this.extBSPPClasses = new ArrayCollection([{"Class":"Class A"},{"Class":"Class B"}]);
         this.intClasses = new ArrayCollection([{"Class":"Close"},{"Class":"Medium"},{"Class":"Normal"}]);
         this.initPreferredThreads();
         PremiumThreadFamily["BSW"] = true;
         PremiumThreadFamily["BSF"] = true;
         PremiumThreadFamily["BSPP"] = true;
         PremiumThreadFamily["BA"] = true;
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
               PreferredThreads = BSWStdSizes;
            }
            else
            {
               PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,BSWStdSizes);
            }
            PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,BSFStdSizes);
            PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,BAStdSizes);
            PreferredThreads = GWizUtils.mergeArrays(PreferredThreads,BSPPStdSizes);
            if(!GWizUtils.debug)
            {
            }
         }
      }
      
      override public function selectThread(param1:String, param2:String, param3:Number, param4:Number, param5:String, param6:int, param7:Boolean) : Boolean
      {
         var _loc9_:int = 0;
         var _loc10_:Object = null;
         var _loc15_:String = null;
         var _loc8_:Boolean = super.selectThread(param1,param2,param3,param4,param5,param6,param7);
         ExtThreadImg = BSWExtThreadImg;
         IntThreadImg = BSWIntThreadImg;
         Reference = "Whitworth";
         if(Family.indexOf("BSW") >= 0)
         {
            Reference = "British Standard Whitworth (BSW)";
         }
         else if(this.isBA())
         {
            Reference = "British Association BS 93:2008";
         }
         else if(this.isBSPP())
         {
            Reference = "ISO 228-1";
         }
         TPISelect = true;
         allowCustomSizeTPI = !this.isBA() && !this.isBSPP();
         TolClass = param5;
         Designation = this.getDesignation();
         _loc10_ = lookupFamilySize(param1,param2);
         if(this.isBA())
         {
            ThreadAngle = 47.5;
         }
         else
         {
            ThreadAngle = _loc10_.ThreadAngle;
         }
         FltsHeight = 2 * Height / 3;
         if(this.isBA())
         {
            FltsHeight = 0.6 * Pitch;
         }
         else if(this.isBSPP())
         {
            FltsHeight = 0.640327 * Pitch;
         }
         var _loc11_:Number = 0.002 * GWizUtils.cubeRoot(NomSize) + 0.003 * Math.sqrt(EngagementLength) + 0.005 * Math.sqrt(Pitch);
         var _loc12_:Number;
         var _loc13_:Number = (_loc12_ = NomSize) - FltsHeight;
         var _loc14_:Number = _loc12_ - 2 * FltsHeight;
         switch(param5)
         {
            case "Medium":
               break;
            case "Free":
            case "Normal":
               _loc11_ = 1.5 * _loc11_;
               break;
            case "Close":
            default:
               _loc11_ = 2 * _loc11_ / 3;
         }
         _loc11_ = this.tolClassToT(param5,_loc11_);
         PitchDiaTol = _loc11_;
         MajorDiaTol = _loc11_ + 0.01 * Math.sqrt(Pitch);
         if(param5 == "Close")
         {
            MinorDiaTol = _loc11_ + 0.013 * Math.sqrt(Pitch);
         }
         else
         {
            MinorDiaTol = _loc11_ + 0.02 * Math.sqrt(Pitch);
         }
         if(param7)
         {
            MaxPitchDia = _loc13_;
            MinPitchDia = MaxPitchDia - PitchDiaTol;
            MaxMajorDia = _loc12_;
            MinMajorDia = MaxMajorDia - MajorDiaTol;
            MaxMinorDia = _loc14_;
            MinMinorDia = MaxMinorDia - MinorDiaTol;
            if(0.25 <= NomSize && NomSize <= 0.75)
            {
               Allowance = 0.3 * PitchDiaTol;
            }
            else if(NomSize < 0.25)
            {
               _loc11_ = 0.002 * GWizUtils.cubeRoot(0.25) + 0.003 * Math.sqrt(0.25) + 0.005 * Math.sqrt(1 / 20);
               _loc11_ = this.tolClassToT(param5,_loc11_);
               Allowance = 0.3 * PitchDiaTol;
            }
            if(param5 == "Close")
            {
               Allowance = 0;
            }
            if(this.isBA())
            {
               _loc15_ = "External " + TolClass;
               if(false && GWizUtils.debug)
               {
                  GWizUtils.assert(TolClass == "Normal" || TolClass == "Close");
               }
               MinMajorDia = NaN;
               MaxMajorDia = NaN;
               MinPitchDia = NaN;
               MaxPitchDia = NaN;
               MinMinorDia = NaN;
               MaxMinorDia = NaN;
               Allowance = 0;
               MajorDiaTol = NaN;
               PitchDiaTol = NaN;
               MinorDiaTol = NaN;
               _loc9_ = 0;
               while(_loc9_ < BSAStdSizesData.length)
               {
                  if((_loc10_ = BSAStdSizesData.getItemAt(_loc9_)).Size == param2 && _loc10_.Type == _loc15_)
                  {
                     MinMajorDia = _loc10_.MinMajorDia;
                     MaxMajorDia = _loc10_.NominalSize;
                     NomSize = MaxMajorDia;
                     MinPitchDia = _loc10_.MinPitchDia;
                     MaxPitchDia = _loc10_.MaxPitchDia;
                     MinMinorDia = _loc10_.MinMinorDia;
                     MaxMinorDia = _loc10_.MaxMinorDia;
                     MajorDiaTol = Math.abs(MaxMajorDia - MinMajorDia);
                     PitchDiaTol = Math.abs(MaxPitchDia - MinPitchDia);
                     MinorDiaTol = Math.abs(MaxMinorDia - MinMinorDia);
                     break;
                  }
                  _loc9_++;
               }
            }
            if(this.isBSPP())
            {
               MinMajorDia = NaN;
               MaxMajorDia = NaN;
               MinPitchDia = NaN;
               MaxPitchDia = NaN;
               MinMinorDia = NaN;
               MaxMinorDia = NaN;
               Allowance = 0;
               MajorDiaTol = NaN;
               PitchDiaTol = NaN;
               MinorDiaTol = NaN;
               EngagementLength = NaN;
               if(TolClass == "Class A")
               {
                  PitchDiaTol = _loc10_.Td2ClassALower / 25.4;
               }
               else
               {
                  PitchDiaTol = _loc10_.Td2ClassBLower / 25.4;
               }
               MajorDiaTol = _loc10_.TdLower / 25.4;
               NomSize = _loc10_.NominalSize / 25.4;
               _loc12_ = NomSize;
               MaxMajorDia = _loc12_;
               MinMajorDia = MaxMajorDia + MajorDiaTol;
               _loc14_ = _loc12_ - 1.280654 * Pitch;
               MinMinorDia = _loc14_;
               _loc13_ = _loc12_ - 0.640327 * Pitch;
               MaxPitchDia = _loc13_;
               MinPitchDia = MaxPitchDia + PitchDiaTol;
            }
         }
         else
         {
            MinorDiaTol = 0.2 * Pitch;
            if(TPI >= 26)
            {
               MinorDiaTol += 0.004;
            }
            else if(22 <= TPI && TPI < 26)
            {
               MinorDiaTol += 0.005;
            }
            else
            {
               MinorDiaTol += 0.007;
            }
            MinMajorDia = NomSize;
            MaxMajorDia = NaN;
            MinPitchDia = _loc13_;
            MaxPitchDia = MinPitchDia + PitchDiaTol;
            MinMinorDia = _loc14_;
            MaxMinorDia = MinMinorDia + MinorDiaTol;
            Allowance = NaN;
            if(this.isBA())
            {
               _loc15_ = "Internal";
               MinMajorDia = NaN;
               MaxMajorDia = NaN;
               MinPitchDia = NaN;
               MaxPitchDia = NaN;
               MinMinorDia = NaN;
               MaxMinorDia = NaN;
               Allowance = NaN;
               MajorDiaTol = NaN;
               PitchDiaTol = NaN;
               MinorDiaTol = NaN;
               _loc9_ = 0;
               while(_loc9_ < BSAStdSizesData.length)
               {
                  if((_loc10_ = BSAStdSizesData.getItemAt(_loc9_)).Size == param2 && _loc10_.Type == _loc15_)
                  {
                     MinMajorDia = _loc10_.NominalSize;
                     NomSize = MinMajorDia;
                     MinPitchDia = _loc10_.MinPitchDia;
                     MaxPitchDia = _loc10_.MaxPitchDia;
                     MinMinorDia = _loc10_.MinMinorDia;
                     MaxMinorDia = _loc10_.MaxMinorDia;
                     MajorDiaTol = Math.abs(MaxMajorDia - MinMajorDia);
                     PitchDiaTol = Math.abs(MaxPitchDia - MinPitchDia);
                     MinorDiaTol = Math.abs(MaxMinorDia - MinMinorDia);
                     break;
                  }
                  _loc9_++;
               }
            }
            if(this.isBSPP())
            {
               MinMajorDia = NaN;
               MaxMajorDia = NaN;
               MinPitchDia = NaN;
               MaxPitchDia = NaN;
               MinMinorDia = NaN;
               MaxMinorDia = NaN;
               Allowance = 0;
               MajorDiaTol = NaN;
               PitchDiaTol = NaN;
               MinorDiaTol = NaN;
               EngagementLength = NaN;
               MajorDiaTol = NaN;
               PitchDiaTol = _loc10_.TD2Upper / 25.4;
               MinorDiaTol = _loc10_.TD1Upper / 25.4;
               NomSize = _loc10_.NominalSize / 25.4;
               _loc12_ = NomSize;
               MaxMajorDia = _loc12_;
               _loc14_ = _loc12_ - 1.280654 * Pitch;
               MaxMinorDia = _loc14_;
               MinMinorDia = _loc14_ - MinorDiaTol;
               _loc13_ = _loc12_ - 0.640327 * Pitch;
               MaxPitchDia = _loc13_;
               MinPitchDia = MaxPitchDia - PitchDiaTol;
            }
         }
         return _loc8_;
      }
      
      private function tolClassToT(param1:String, param2:Number) : Number
      {
         switch(param1)
         {
            case "Medium":
               break;
            case "Free":
               param2 = 1.5 * param2;
               break;
            case "Close":
            default:
               param2 = 2 * param2 / 3;
         }
         return param2;
      }
      
      override public function initClassList(param1:Boolean = true) : void
      {
         showTolClass = true;
         DefaultClassChoice = 0;
         if(param1)
         {
            ClassList = this.extClasses;
         }
         else
         {
            ClassList = this.intClasses;
         }
         if(this.isBA())
         {
            if(param1)
            {
               ClassList = this.extBAClasses;
               ClassList.refresh();
            }
            else
            {
               showTolClass = false;
            }
         }
         else if(this.isBSPP())
         {
            if(param1)
            {
               ClassList = this.extBSPPClasses;
               ClassList.refresh();
            }
            else
            {
               showTolClass = false;
            }
         }
         ClassList.refresh();
      }
      
      override public function lookupTPI(param1:String, param2:String) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Object = lookupFamilySize(param1,param2);
         _loc3_ = Number(_loc4_.TPI);
         GWizUtils.assert(!isNaN(_loc3_));
         return _loc3_;
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
      
      private function getDesignation() : String
      {
         var _loc1_:* = "";
         if(Size != "")
         {
            _loc1_ += Size;
         }
         else
         {
            _loc1_ += String(NomSize);
         }
         _loc1_ += " " + Family;
         if(!this.isBSPP() || External)
         {
            _loc1_ += "(" + TolClass + ") ";
         }
         if(!this.isBSPP())
         {
            if(External)
            {
               _loc1_ += "bolt";
            }
            else
            {
               _loc1_ += "nut";
            }
         }
         return _loc1_;
      }
      
      override public function addlThreadData() : void
      {
         var _loc1_:Number = 0.137329 * Pitch;
         if(this.isBA())
         {
            _loc1_ = 0.18083 * Pitch;
         }
         newThreadData("Crest Radius",_loc1_,true,true);
         newThreadData("Root Radius",_loc1_,true,true);
      }
      
      private function isBSPP() : Boolean
      {
         return Family == "BSPP";
      }
      
      private function isBA() : Boolean
      {
         return Family == "BA";
      }
   }
}
