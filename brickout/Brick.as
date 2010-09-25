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
	import flash.filters.GlowFilter;

	public class Brick extends MovieClip
	{
		protected var free:Boolean = false;
		public var wall:Bitmap;
		public var legume:Bitmap;
		public var tourNumber:int;
		public var sleepTime:int;
		public var currentTour:int = 0;
		private static var walls = ["Green","White"];
		public var brickDefs:Array;
		public var brickDef:Object;
		public var xx:Number;
		public var yy:Number;
		public function Brick(brickDef:Object, brickDefs:Array, xx:Number,yy:Number)
		{
			brickDef.parent = this;
			this.brickDef = brickDef;
			this.brickDefs = brickDefs;
			this.xx = xx;
			this.yy = yy;
			super();
			stop();

			this.tourNumber = brickDef.tourNumber;
			this.sleepTime = brickDef.sleepTime;

			this.addEventListener(MouseEvent.MOUSE_OVER, rollOverHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT, rollOutHandler);
			this.addEventListener(MouseEvent.CLICK, mouseClickHandler);

			var wallClassName:String = "Brick" + walls[brickDef.rndWall];
			var WallReference:Class = getDefinitionByName(wallClassName) as Class;
			var wallBitmap:BitmapData = new WallReference(64,32);
			wall = new Bitmap(wallBitmap);
			brick.addChild(wall);

			var legumeClasseName:String = "Legume" + brickDef.rndLegume;
			var legumeClassReference:Class = getDefinitionByName(legumeClasseName) as Class;
			var legumeBitmap:BitmapData = new legumeClassReference(64,32);
			legume = new Bitmap(legumeBitmap);
			brick.addChild(legume);

			var timer:Timer = new Timer(this.sleepTime,1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, startBrickHandler);
			timer.start();
		}

		private var gf = new GlowFilter(0xE8FF11,26,35,35,2,1,false,false);
		private function rollOverHandler(event:MouseEvent):void
		{
			this.filters = [gf];
			//parent.setChildIndex(this, parent.numChildren-1);
			//if(free) gotoAndPlay("rollOverStart");
		}

		private function rollOutHandler(event:MouseEvent):void
		{
			this.filters = [];
		}

		private function mouseClickHandler(event:MouseEvent):void
		{
			removeBrick(this);
		}

		private var marked:Boolean = false;
		public function removeBrick(cmp = null):Boolean
		{
			var ok = false;
			if (! marked && free && cmp.brickDef.rndWall == brickDef.rndWall && cmp.brickDef.rndLegume == brickDef.rndLegume)
			{
				marked = true;
				var lbrickDef:Object = brickDefs[yy][xx - 1];
				if (lbrickDef && lbrickDef.parent != cmp && lbrickDef.parent.removeBrick(this))
				{
					ok = true;
				}
				var tbrickDef:Object = brickDefs[yy - 1][xx];
				if (tbrickDef && tbrickDef.parent != cmp && tbrickDef.parent.removeBrick(this))
				{
					ok = true;
				}
				var rbrickDef:Object = brickDefs[yy][xx + 1];
				if (rbrickDef && rbrickDef.parent != cmp && rbrickDef.parent.removeBrick(this))
				{
					ok = true;
				}
				var bbrickDef:Object = brickDefs[yy + 1][xx];
				if (bbrickDef && bbrickDef.parent != cmp && bbrickDef.parent.removeBrick(this))
				{
					ok = true;
				}
				parent.removeChild(this);
			}
			else
			{
				marked = false;
			}
			return ok;
		}

		private function startBrickHandler(event:TimerEvent):void
		{
			gotoAndPlay("start");
		}
	}
}