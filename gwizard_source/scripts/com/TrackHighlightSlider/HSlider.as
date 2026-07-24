package com.TrackHighlightSlider
{
   import com.TrackHighlightSlider.skins.HSliderSkin;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import mx.core.InteractionMode;
   import mx.events.PropertyChangeEvent;
   import mx.events.ResizeEvent;
   import spark.components.Button;
   import spark.components.HSlider;
   import spark.effects.animation.Animation;
   
   public class HSlider extends spark.components.HSlider
   {
       
      
      private var animator:Animation = null;
      
      [SkinPart(required="false")]
      public var trackHighLight:Button;
      
      private var _1794353414_accentColor:uint;
      
      private var accentColorChanged:Boolean;
      
      private var _862744229_showTrackHighlight:Boolean = true;
      
      private var showTrackHighlightChanged:Boolean;
      
      public function HSlider()
      {
         super();
         setStyle("skinClass",HSliderSkin);
      }
      
      override protected function updateSkinDisplayList() : void
      {
         super.updateSkinDisplayList();
         if(!thumb || !track || !this.trackHighLight)
         {
            return;
         }
         var _loc1_:Number = track.getLayoutBoundsWidth() - thumb.getLayoutBoundsWidth();
         var _loc2_:Number = maximum - minimum;
         var _loc3_:Number = _loc2_ > 0 ? Number((pendingValue - minimum) / _loc2_ * _loc1_) : Number(0);
         var _loc4_:Point = track.localToGlobal(new Point(_loc3_,0));
         var _loc5_:Number = thumb.parent.globalToLocal(_loc4_).x + thumb.getLayoutBoundsWidth() / 2;
         this.trackHighLight.setLayoutBoundsSize(Math.round(_loc5_),this.trackHighLight.getLayoutBoundsHeight());
      }
      
      override protected function partAdded(param1:String, param2:Object) : void
      {
         super.partAdded(param1,param2);
         if(param2 == this.trackHighLight)
         {
            this.trackHighLight.focusEnabled = false;
            this.trackHighLight.addEventListener(ResizeEvent.RESIZE,this.trackHighLight_resizeHandler);
            if(getStyle("interactionMode") == InteractionMode.MOUSE)
            {
               this.trackHighLight.addEventListener(MouseEvent.MOUSE_DOWN,this.trackHighLight_mouseDownHandler);
            }
         }
      }
      
      override protected function partRemoved(param1:String, param2:Object) : void
      {
         super.partRemoved(param1,param2);
         if(param2 == this.trackHighLight)
         {
            this.trackHighLight.removeEventListener(MouseEvent.MOUSE_DOWN,this.trackHighLight_mouseDownHandler);
            this.trackHighLight.removeEventListener(ResizeEvent.RESIZE,this.trackHighLight_resizeHandler);
         }
      }
      
      protected function trackHighLight_mouseDownHandler(param1:MouseEvent) : void
      {
         this.track_mouseDownHandler(param1);
      }
      
      private function trackHighLight_resizeHandler(param1:Event) : void
      {
         this.updateSkinDisplayList();
      }
      
      override public function styleChanged(param1:String) : void
      {
         var _loc2_:Boolean = param1 == null || param1 == "styleName";
         super.styleChanged(param1);
         if(param1 == "showTrackHighlight" || _loc2_)
         {
            this.showTrackHighlightChanged = true;
            invalidateProperties();
         }
         if(param1 == "accentColor" || _loc2_)
         {
            this.accentColorChanged = true;
            invalidateProperties();
         }
         invalidateDisplayList();
      }
      
      override protected function commitProperties() : void
      {
         super.commitProperties();
         if(this.showTrackHighlightChanged)
         {
            this.trackHighLight.visible = this._showTrackHighlight;
            this.showTrackHighlightChanged = false;
         }
         if(this.accentColorChanged)
         {
            this.trackHighLight.setStyle("themeColor",this.accentColor);
            this.accentColorChanged = false;
         }
      }
      
      public function set accentColor(param1:uint) : void
      {
         this._accentColor = param1;
         this.accentColorChanged = true;
         this.invalidateProperties();
      }
      
      public function get accentColor() : uint
      {
         return this._accentColor;
      }
      
      public function set showTrackHighlight(param1:Boolean) : void
      {
         this._showTrackHighlight = param1;
         this.showTrackHighlightChanged = true;
         this.invalidateProperties();
      }
      
      public function get showTrackHighlight() : Boolean
      {
         return this._showTrackHighlight;
      }
      
      [Bindable(event="propertyChange")]
      private function get _accentColor() : uint
      {
         return this._1794353414_accentColor;
      }
      
      private function set _accentColor(param1:uint) : void
      {
         var _loc2_:Object = this._1794353414_accentColor;
         if(_loc2_ !== param1)
         {
            this._1794353414_accentColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_accentColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get _showTrackHighlight() : Boolean
      {
         return this._862744229_showTrackHighlight;
      }
      
      private function set _showTrackHighlight(param1:Boolean) : void
      {
         var _loc2_:Object = this._862744229_showTrackHighlight;
         if(_loc2_ !== param1)
         {
            this._862744229_showTrackHighlight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"_showTrackHighlight",_loc2_,param1));
            }
         }
      }
   }
}
