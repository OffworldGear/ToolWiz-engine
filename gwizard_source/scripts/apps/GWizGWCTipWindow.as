package apps
{
   import bubbletip.GWizAbstractTipWindow;
   
   public class GWizGWCTipWindow extends GWizAbstractTipWindow
   {
       
      
      public function GWizGWCTipWindow()
      {
         super();
      }
      
      override public function doCC() : void
      {
         super.doCC();
         var _loc1_:* = "";
         var _loc2_:int = 0;
         _loc1_ = "<p><b>Have you told G-Wizard about your machine?</b></p>";
         _loc1_ += "<p></p>";
         _loc1_ += "<p>First thing to do when getting started is go to the Setup Basics page and create a Machine Profile for your machine.</p>";
         _loc1_ += "<p>Select the profile closest to your machine with the combo box next to Machine Profiles.</p>";
         _loc1_ += "<p>Edit the fields below until they match your machine\'s capabilities.  You can rename the profile if you like.</p>";
         _loc1_ += "<p>Press \'Save\' at the bottom when done.</p>";
         _loc1_ += "<p></p>";
         _loc1_ += "<p>Don\'t forget to set your preferred units to Imperial or Metric at the top of the page.</p>";
         var _loc3_:* = _loc2_++;
         tipJar[_loc3_] = _loc1_;
         _loc1_ = "<p><b>Need to adjust G-Wizard for a smaller machine?</b></p>";
         _loc1_ += "<p></p>";
         _loc1_ += "<p>The best way is to limit the spindle horsepower available for cutting. This can be set on the machine profile page.</p>";
         _loc1_ += "<p>If necessary, set it to less than your available spindle horsepower to be ultra-conservative.</p>";
         var _loc4_:*;
         tipJar[_loc4_ = _loc2_++] = _loc1_;
         _loc1_ = "<p><b>Did you know you can change how aggressive G-Wizard is in reminding you about new releases?</b></p>";
         _loc1_ += "<p></p>";
         _loc1_ += "<p>Go to the Setup About page. Press \'Update Options\' right below the black splash logo box.</p>";
         _loc1_ += "<p></p>";
         var _loc5_:*;
         tipJar[_loc5_ = _loc2_++] = _loc1_;
         _loc1_ = "<p><b>There\'s no need to logout when you quit G-Wizard</b></p>";
         _loc1_ += "<p></p>";
         _loc1_ += "<p>It will remember your login each time it starts up.</p>";
         var _loc6_:*;
         tipJar[_loc6_ = _loc2_++] = _loc1_;
         BeginnerEnd = _loc2_ - 1;
         _loc1_ = "<p><b>Need to work with angles as degrees:minutes:seconds?</b></p>";
         _loc1_ += "<p></p>";
         _loc1_ += "<p>Use the \'D:M:S\' button on the Scientific Calculator tab.</p>";
         var _loc7_:*;
         tipJar[_loc7_ = _loc2_++] = _loc1_;
         _loc1_ = "<p><b>Use the Materials Database to fine tune feeds and speeds</b></p>";
         _loc1_ += "<p></p>";
         _loc1_ += "<p>Press the More button next to the material list and select your material by family, alloy, and condition.</p>";
         _loc1_ += "<p>This fine tunes for hardness and machinability within the family.  Drop us a note if you don\'t find your material listed.</p>";
         var _loc8_:*;
         tipJar[_loc8_ = _loc2_++] = _loc1_;
         _loc1_ = "<p><b>Typing Math in Fields</b></p>";
         _loc1_ += "<p></p>";
         _loc1_ += "<p>There are a lot of fields scattered around G-Wizard for things like Tool Diameter. You can type math into most of them.</p>";
         _loc1_ += "<p>For example, to enter a 10mm diameter in Imperial mode type \'10/25.4\' and press the Enter.</p>";
         _loc1_ += "<p>Actually, that case is even easier: type \'10m\' and press the Enter. Or if in Metric, type \'0.5i\' to convert inches to mm.</p>";
         _loc1_ += "<p>Visit the online documentation to see all the math that\'s supported.</p>";
         var _loc9_:*;
         tipJar[_loc9_ = _loc2_++] = _loc1_;
         _loc1_ = "<p><b>Want to see how much a lower spindle speed increases tool life?</b></p>";
         _loc1_ += "<p></p>";
         _loc1_ += "<p>There is a Taylor\'s tool life calculator in the Machine Profiles under setup.  Try changing the SFM Adjustment to see.</p>";
         var _loc10_:*;
         tipJar[_loc10_ = _loc2_++] = _loc1_;
         _loc1_ = "<p><b>Have you backed up your G-Wizard settings?</b></p>";
         _loc1_ += "<p></p>";
         _loc1_ += "<p>It\'s easy.  Go to the Setup Files page. Press \'Browse\' to tell it what directory to back up to.  Then press \'Backup\'.</p>";
         _loc1_ += "<p>To restore the settings, press \'Restore\' with the Backup Directory showing the folder containing your files.</p>";
         _loc1_ += "<p></p>";
         var _loc11_:*;
         tipJar[_loc11_ = _loc2_++] = _loc1_;
      }
   }
}
