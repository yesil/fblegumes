package brickout
{
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import brickout.*;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.display.DisplayObject;
	import fl.motion.Animator;
	import fl.motion.MotionEvent;
	import fl.motion.MotionBase;
	import fl.motion.AnimatorFactory3D;
	import fl.motion.Animator3D;
	import fl.transitions.Tween;
	import fl.motion.easing.Elastic;
	import flash.events.Event;

	public class BrickGame extends MovieClip
	{
		private var stageWidthHalf:uint;
		public var level:uint = 1;
		private var levels:Array = new Array  ;
		private const StratusAddress:String = "rtmfp://stratus.rtmfp.net";
		private const DeveloperKey:String = "0e8780f03fc122388b0ff850-4e52140316e0";
		private var netConnection:NetConnection;
		private var sendStream:NetStream;
		private var recvStream:NetStream;
		private var brickDefs:Array = [];
		private var bricks:Array = [];
		private var client:Object = null;
		public var xxx = 8;
		public var yyy = 10;
		private var mode:String;
		private var standalone:Boolean = false;

		public function BrickGame()
		{
			super();
			if (! standalone)
			{
				gotoAndPlay(1,"intro");
			}
			if (! standalone)
			{
				btnCall.enabled = false;
			}
			stageWidthHalf = stage.width / 2;
			if (! standalone)
			{
				connectStratus();
			}
			client = new Object  ;
			client.debug = function(msg:String):void
			{
			trace(msg);
			};
			client.removeBrick = function(xx:uint,yy:uint):void{
			var brick:Brick = bricks[yy][xx];
			if(brick) removeBrick(brick,0);
			};

			client.setBrickDefs = function(defs:*):void
			{
			trace("reception des bricks");
			 brickDefs = defs as Array;
			};
			client.startGame = startGame;
			if (standalone)
			{
				initBrickDefs();
			}
			if (standalone)
			{
				startGame();
			}
		}

		private function startGame():void
		{
			gotoAndPlay(1,"game");
		}

		private function connectStratus():void
		{
			netConnection = new NetConnection  ;
			netConnection.addEventListener(NetStatusEvent.NET_STATUS,netConnectionHandler);
			netConnection.connect(StratusAddress + "/" + DeveloperKey);
		}

		private function netConnectionHandler(event:NetStatusEvent):void
		{
			trace("NetConnection event: " + event.info.code + "\n");

			switch (event.info.code)
			{
				case "NetConnection.Connect.Success" :
					trace("Connected, my ID: " + netConnection.nearID + "\n");
					txtMyId.text = netConnection.nearID;
					btnCall.enabled = true;
					this.btnCall.addEventListener(MouseEvent.CLICK,callClickHandler);
					sendStream = new NetStream(netConnection,NetStream.DIRECT_CONNECTIONS);
					sendStream.addEventListener(NetStatusEvent.NET_STATUS,netConnectionHandler);
					sendStream.publish("game");
					break;

				case "NetStream.Connect.Success" :
					if (recvStream == null)
					{
						this.mode = "server";
						recvStream = new NetStream(netConnection,event.info.stream.farID);
						recvStream.addEventListener(NetStatusEvent.NET_STATUS,netConnectionHandler);
						recvStream.client = this.client;
						recvStream.play("game");
						initBrickDefs();
						sendStream.send("setBrickDefs",brickDefs);
						sendStream.send("startGame");
						startGame();
					}
					break;
			}
		}

		private function callClickHandler(event:MouseEvent):void
		{
			this.mode = "client";
			var remoteId:String = this.txtRemoteId.text;
			gotoAndPlay(1,"starting");
			txtPeerId.text = remoteId;
			recvStream = new NetStream(netConnection,remoteId);
			recvStream.addEventListener(NetStatusEvent.NET_STATUS,netConnectionHandler);
			recvStream.client = this.client;
			recvStream.play("game");
		}

		private function initBrickDefs():void
		{
			var tourCount:uint = this.standalone ? 1:10;
			var overlayCount:uint = this.standalone ? 1:4;
			var sleepTimeX:uint = this.standalone ? 10:2000;
			for (var yy:uint = 0; yy <= yyy; yy++)
			{
				brickDefs[yy] = [];
				for (var xx:uint = 0; xx <= xxx; xx++)
				{
					brickDefs[yy][xx] = {};
					brickDefs[yy][xx].backIndex = Math.round(Math.random() * 10) % 2 + 1;
					brickDefs[yy][xx].overlayIndex = Math.round(Math.random() * 10) % overlayCount + 1;
					brickDefs[yy][xx].tourCount = Math.round(Math.random() * tourCount) + 1;
					brickDefs[yy][xx].sleepTime = Math.round(Math.random() * sleepTimeX) + 1;
				}
			}
		}

		public function initBricks():void
		{
			for (var yy:uint = 0; yy < yyy; yy++)
			{
				bricks[yy] = [];
				for (var xx:uint = 0; xx < xxx; xx++)
				{
					var brickDef:* = brickDefs[yy][xx];
					var brick:Brick = new Brick(xx,yy,brickDef.backIndex,brickDef.overlayIndex,brickDef.tourCount,brickDef.sleepTime);
					brick.x = xx * brick.width + 50;
					brick.y = yy * brick.height + 50;
					brick.addEventListener(MouseEvent.CLICK,mouseClickHandler);
					brick.scaleX = 1;
					brick.scaleY = 1;
					bricks[yy][xx] = brick;
					brick.addEventListener(Event.REMOVED_FROM_STAGE, brickRemoved);
					bricksZone.addChild(brick);
				}
			}
		}

		private function mouseClickHandler(event:MouseEvent):void
		{
			var brick:Brick = event.currentTarget as Brick;
			sendStream.send("removeBrick",brick.xx,brick.yy);
			removing = removeBrick(brick);
			if (removing > 1)
			{
				trace("Nombre de brique à supprimer: "+(removing-1));
			}
		}

		private function arrange():void
		{
			trace("ré-arrangement des briques");
			var c:uint;
			for (var xx = 0; xx <= xxx; xx++)
			{
				c = 0;
				var found:Boolean = false;
				for (var yy = (yyy-1); yy >= 0; yy--)
				{
					if (! bricks[yy][xx])
					{
						c++;
						found = true;
					}
					if (bricks[yy][xx] && found)
					{
						var b:Brick = bricks[yy][xx];
						b.yy = yy + c;
						bricks[yy][xx] = null;
						bricks[yy + c][xx] = b;
						b.moveToXY(xx, (yy+c)*b.height+50);
					}
				}
			}
		}

		private var removing:int = 0;
		private function brickRemoved(event:Event):void
		{
			removing--;
			var brick:Brick = event.currentTarget as Brick;
			trace("brique xx:" + brick.xx + " yy:"+brick.yy+" supprimé removing:"+removing);
			bricks[brick.yy][brick.xx] = null;
			arrange();
		}

		public function removeBrick(brick:Brick,count:uint=0):uint
		{
			if (brick.free && ! brick.removed)
			{
				count++;
				brick.marked = true;
				var lbrick:Brick = brick.xx > 0 ? bricks[brick.yy][brick.xx - 1]:null;
				if (lbrick && ! lbrick.marked && brick.equals(lbrick))
				{
					count = removeBrick(lbrick,count);
				}


				var tbrick:Brick = brick.yy > 0 ? bricks[brick.yy - 1][brick.xx]:null;
				if (tbrick && ! tbrick.marked && brick.equals(tbrick))
				{
					count = removeBrick(tbrick,count);
				}

				var rbrick:Brick = brick.xx < xxx - 1 ? bricks[brick.yy][brick.xx + 1]:null;
				if (rbrick && ! rbrick.marked && brick.equals(rbrick))
				{
					count = removeBrick(rbrick,count);
				}

				var bbrick:Brick = brick.yy < yyy - 1 ? bricks[brick.yy + 1][brick.xx]:null;
				if (bbrick && ! bbrick.marked && brick.equals(bbrick))
				{
					count = removeBrick(bbrick,count);
				}
				if (count > 1)
				{
					brick.removed = true;
					brick.remove();
				}
				else
				{
					brick.marked = false;
				}
			}
			return count;
		}
	}
}