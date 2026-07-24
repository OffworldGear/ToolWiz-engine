package integratep
{
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   import flash.accessibility.*;
   import flash.data.*;
   import flash.debugger.*;
   import flash.desktop.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filesystem.*;
   import flash.geom.*;
   import flash.html.*;
   import flash.html.script.*;
   import flash.media.*;
   import flash.net.*;
   import flash.printing.*;
   import flash.profiler.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   import mx.binding.*;
   import mx.containers.TitleWindow;
   import mx.controls.Spacer;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponentDescriptor;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.filters.*;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.styles.*;
   import mx.utils.UIDUtil;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   public class GWizMecSoftSetup extends TitleWindow
   {
      
      private static const log:ILogger = Log.getLogger("GWizMecSoftSetup");
      
      public static var didMecSoftIntegration:Boolean = false;
       
      
      private var _900413121installBtn:Button;
      
      private var _3360976msg1:Label;
      
      private var _3360977msg2:Label;
      
      private var _3360978msg3:Label;
      
      private var _documentDescriptor_:UIComponentDescriptor;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private const REG_IMPORT_FILE:String = "MECSOFT.REG";
      
      private var exepath:String = "";
      
      public var process:NativeProcess;
      
      public function GWizMecSoftSetup()
      {
         this._documentDescriptor_ = new UIComponentDescriptor({
            "type":TitleWindow,
            "events":{"creationComplete":"___GWizMecSoftSetup_TitleWindow1_creationComplete"},
            "stylesFactory":function():void
            {
               this.horizontalAlign = "center";
            },
            "propertiesFactory":function():Object
            {
               return {
                  "width":450,
                  "height":236,
                  "childDescriptors":[new UIComponentDescriptor({
                     "type":VGroup,
                     "propertiesFactory":function():Object
                     {
                        return {
                           "percentWidth":100,
                           "percentHeight":100,
                           "verticalAlign":"middle",
                           "mxmlContent":[_GWizMecSoftSetup_Label1_c(),_GWizMecSoftSetup_Label2_i(),_GWizMecSoftSetup_Label3_i(),_GWizMecSoftSetup_Label4_i(),_GWizMecSoftSetup_Spacer1_c(),_GWizMecSoftSetup_HGroup1_c()]
                        };
                     }
                  })]
               };
            }
         });
         super();
         mx_internal::_document = this;
         this.layout = "vertical";
         this.width = 450;
         this.height = 236;
         this.title = "MecSoft Integration Setup";
         this.addEventListener("creationComplete",this.___GWizMecSoftSetup_TitleWindow1_creationComplete);
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
            this.horizontalAlign = "center";
         };
      }
      
      override public function initialize() : void
      {
         mx_internal::setDocumentDescriptor(this._documentDescriptor_);
         super.initialize();
      }
      
      private function install() : void
      {
         var stream:FileStream = null;
         var regcmds:String = "";
         regcmds += "REGEDIT4\n";
         regcmds += "\n";
         regcmds += "[HKEY_LOCAL_MACHINE\\SOFTWARE\\MecSoft Corporation\\VisualMILL 2012 Plug-ins\\";
         regcmds += UIDUtil.createUID();
         regcmds += "]\n";
         regcmds += "\"Name\"=\"G-Wizard\"\n";
         regcmds += "\"Executable\"=\"";
         this.exepath = GWizSettings.exeDir;
         this.exepath = this.exepath.replace(".SWF",".EXE");
         this.exepath = this.exepath.replace(".swf",".exe");
         var s:String = this.exepath;
         this.exepath = "";
         var i:int = 0;
         while(i < s.length)
         {
            this.exepath += s.charAt(i);
            if(s.charAt(i) == "\\")
            {
               this.exepath += "\\";
            }
            i++;
         }
         regcmds += this.exepath + "\"\n";
         regcmds += "\"Type\"=\"Executable\"\n";
         try
         {
            stream = new FileStream();
            stream.open(GWizSettings.getPrefsFile(this.REG_IMPORT_FILE),FileMode.WRITE);
            stream.writeUTFBytes(regcmds);
            stream.close();
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error writing temporary registry file for MecSoft integration.");
            GWizPopUpManager.Show("Error writing file for MecSoft integration.","Error: Write Failure",GWizPopUpManager.ERROR);
         }
         if(NativeProcess.isSupported)
         {
            this.launchRegEdit();
         }
         else
         {
            GWizPopUpManager.Show("NativeProcess not supported. You need the Windows native install for G-Wizard.","Error: NativeProcess Not Supported",GWizPopUpManager.ERROR);
         }
         this.quit();
      }
      
      private function quit() : void
      {
         GWizPopUpManager.removePopUp(this);
      }
      
      private function launchRegEdit() : void
      {
         var _loc2_:* = this.exepath;
         if(GWizUtils.debug)
         {
            _loc2_ = "C:\\windows";
         }
         else
         {
            _loc2_ = _loc2_.substr(0,"C:\\".length) + "windows";
         }
         var _loc3_:File = new File(_loc2_);
         _loc3_ = _loc3_.resolvePath("regedit.exe");
         var _loc4_:NativeProcessStartupInfo;
         (_loc4_ = new NativeProcessStartupInfo()).executable = _loc3_;
         var _loc5_:File = GWizSettings.getPrefsFile(this.REG_IMPORT_FILE);
         var _loc6_:Vector.<String>;
         (_loc6_ = new Vector.<String>())[0] = _loc5_.nativePath;
         _loc4_.arguments = _loc6_;
         this.process = new NativeProcess();
         this.process.start(_loc4_);
         didMecSoftIntegration = true;
      }
      
      private function onCC() : void
      {
         if(didMecSoftIntegration)
         {
            this.msg1.text = "Integration was done some time in the past.";
            this.msg2.text = "Pressing \'Install\' will reinstall. Don\'t reinstall";
            this.msg3.text = "if G-Wizard is already on the MecSoft plug-in menu!";
         }
         else if(!NativeProcess.isSupported)
         {
            this.installBtn.enabled = false;
            this.msg1.text = "Installing the MecSoft integration requires a";
            this.msg2.text = "native Windows install of G-Wizard. It\'s free:";
            this.msg3.text = "send email to sales@cnccookbook.com to get one.";
         }
      }
      
      public function ___GWizMecSoftSetup_TitleWindow1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizMecSoftSetup_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Install MecSoft Integration";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMecSoftSetup_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "You must be on Windows and logged in as Administrator.";
         _loc1_.id = "msg1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.msg1 = _loc1_;
         BindingManager.executeBindings(this,"msg1",this.msg1);
         return _loc1_;
      }
      
      private function _GWizMecSoftSetup_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "This install will add entries to the Registry.";
         _loc1_.id = "msg2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.msg2 = _loc1_;
         BindingManager.executeBindings(this,"msg2",this.msg2);
         return _loc1_;
      }
      
      private function _GWizMecSoftSetup_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "You may be asked to confirm them--please select \'Yes\'.";
         _loc1_.id = "msg3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.msg3 = _loc1_;
         BindingManager.executeBindings(this,"msg3",this.msg3);
         return _loc1_;
      }
      
      private function _GWizMecSoftSetup_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.width = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMecSoftSetup_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizMecSoftSetup_Button1_i(),this._GWizMecSoftSetup_Button2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMecSoftSetup_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Install";
         _loc1_.addEventListener("click",this.__installBtn_click);
         _loc1_.id = "installBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.installBtn = _loc1_;
         BindingManager.executeBindings(this,"installBtn",this.installBtn);
         return _loc1_;
      }
      
      public function __installBtn_click(param1:MouseEvent) : void
      {
         this.install();
      }
      
      private function _GWizMecSoftSetup_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Cancel";
         _loc1_.addEventListener("click",this.___GWizMecSoftSetup_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizMecSoftSetup_Button2_click(param1:MouseEvent) : void
      {
         this.quit();
      }
      
      [Bindable(event="propertyChange")]
      public function get installBtn() : Button
      {
         return this._900413121installBtn;
      }
      
      public function set installBtn(param1:Button) : void
      {
         var _loc2_:Object = this._900413121installBtn;
         if(_loc2_ !== param1)
         {
            this._900413121installBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"installBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get msg1() : Label
      {
         return this._3360976msg1;
      }
      
      public function set msg1(param1:Label) : void
      {
         var _loc2_:Object = this._3360976msg1;
         if(_loc2_ !== param1)
         {
            this._3360976msg1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"msg1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get msg2() : Label
      {
         return this._3360977msg2;
      }
      
      public function set msg2(param1:Label) : void
      {
         var _loc2_:Object = this._3360977msg2;
         if(_loc2_ !== param1)
         {
            this._3360977msg2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"msg2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get msg3() : Label
      {
         return this._3360978msg3;
      }
      
      public function set msg3(param1:Label) : void
      {
         var _loc2_:Object = this._3360978msg3;
         if(_loc2_ !== param1)
         {
            this._3360978msg3 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"msg3",_loc2_,param1));
            }
         }
      }
   }
}
