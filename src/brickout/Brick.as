package brickout
{
	import flash.display.MovieClip;
	import flash.display.Scene;
	import flash.events.MouseEvent;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.utils.getDefinitionByName;
	import flash.utils.describeType;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.filters.GlowFilter;
	import flash.display.DisplayObject;
	import fl.transitions.Tween;
	import fl.motion.Animator;
	import fl.transitions.TweenEvent;
	import fl.motion.easing.Elastic;
	import flash.events.Event;

	public class Brick extends MovieClip
	{
		public var backIndex:uint;
		public var overlayIndex:uint;
		public var tourCount:uint;
		public var sleepTime:uint;
		public var currentTour:uint = 0;
		public var xx:uint;
		public var yy:uint;
		public var free:Boolean = false;
		public var marked:Boolean = false;
		public var removed:Boolean = false;
		public function Brick(xx:uint, yy:uint, backIndex:uint, overlayIndex:uint, tourCount:uint,sleepTime:uint )
		{
			super();
			this.xx = xx;
			this.yy = yy;
			this.backIndex = backIndex;
			this.overlayIndex = overlayIndex;
			this.tourCount = tourCount;
			this.sleepTime = sleepTime;
			stop();

			this.addEventListener(MouseEvent.MOUSE_OVER, rollOverHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT, rollOutHandler);

			var backClassName:String = "b" + backIndex;
			var WallReference:Class = getDefinitionByName(backClassName) as Class;
			var backBitmap:BitmapData = new WallReference(64,32);
			var back = new Bitmap(backBitmap);
			brick.addChild(back);

			var frontClasseName:String = "f" + overlayIndex;
			var frontClassReference:Class = getDefinitionByName(frontClasseName) as Class;
			var frontBitmap:BitmapData = new frontClassReference(64,32);
			var front = new Bitmap(frontBitmap);
			brick.addChild(front);

			var timer:Timer = new Timer(this.sleepTime,1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, startBrickHandler);
			timer.start();
		}

		private var gf = new GlowFilter(0xE8FF11,26,35,35,2,1,false,false);
		private function rollOverHandler(event:MouseEvent):void
		{
			parent.setChildIndex(this,parent.numChildren-1);
			this.filters = [gf];
		}

		private function rollOutHandler(event:MouseEvent):void
		{
			this.filters = [];
		}

		private function startBrickHandler(event:TimerEvent):void
		{
			gotoAndPlay("start");
		}

		public function equals(brick:Brick):Boolean
		{
			return (brick.backIndex == backIndex && brick.overlayIndex == overlayIndex);
		}

		public function remove():void
		{
			gotoAndPlay(16);
		}

		public function moveToXY(toX:Number,toY:Number):void
		{
			var t:Tween = new Tween(this,"y",Elastic.easeOut,y,toY,1,true);
		}
	}
}