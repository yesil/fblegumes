package brickout
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.utils.getDefinitionByName;
	import flash.utils.describeType;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Brick extends MovieClip
	{
		protected var free:Boolean = true;
		public var wall:Bitmap;
		public var legume:Bitmap;
		public var tourNumber:int;
		public var sleepTime:int;
		public var currentTour:int = 0;
		private static var walls =  ["Green","White"];
		public function Brick()
		{
			super();
			stop();
			this.addEventListener(MouseEvent.MOUSE_OVER, rollOverHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT, rollOutHandler);
			
			var wallClassName:String = "Brick"+walls[((Math.round(Math.random()*10)%2))];
			var WallReference:Class = getDefinitionByName(wallClassName) as Class;
            var wallBitmap:BitmapData = new WallReference(64,32);
			wall = new Bitmap(wallBitmap);
			brick.addChild(wall);
			
			var legumeClasseName:String = "Legume"+((Math.round(Math.random()*10)%5)+1);
			var legumeClassReference:Class = getDefinitionByName(legumeClasseName) as Class;
            var legumeBitmap:BitmapData = new legumeClassReference(64,32);
			legume = new Bitmap(legumeBitmap);
			brick.addChild(legume);

			tourNumber = (Math.round(Math.random()*100))+1;
			sleepTime = (Math.round(Math.random()*1000))+1;
			var timer:Timer = new Timer(sleepTime,1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, startBrickHandler);
			timer.start();
		}
		
		private function rollOverHandler(event:MouseEvent):void
		{
//			parent.setChildIndex(this, parent.numChildren-1);
//			if(free) gotoAndPlay("rollOverStart");
		}
		
		private function rollOutHandler(event:MouseEvent):void
		{
			
		}
		
		private function startBrickHandler(event:TimerEvent):void
		{
			gotoAndPlay("start");			
		}
	}
}
		