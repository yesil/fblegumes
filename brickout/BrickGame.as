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
	import fl.motion.AnimatorFactory;

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
		private var standalone:Boolean = true;
		private var animFactory:AnimatorFactory;

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
			removeBrick(brick,0,false);
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
			var tourCount:uint = this.standalone ? 1:100;
			for (var yy:uint = 0; yy <= yyy; yy++)
			{
				brickDefs[yy] = [];
				for (var xx:uint = 0; xx <= xxx; xx++)
				{
					brickDefs[yy][xx] = {};
					brickDefs[yy][xx].backIndex = Math.round(Math.random() * 10) % 2 + 1;
					brickDefs[yy][xx].overlayIndex = Math.round(Math.random() * 10) % 4 + 1;
					brickDefs[yy][xx].tourCount = Math.round(Math.random() * tourCount) + 1;
					brickDefs[yy][xx].sleepTime = Math.round(Math.random() * 2000) + 1;
				}
			}

		}

		public function initBricks():void
		{
			for (var yy:uint = 0; yy <= yyy; yy++)
			{
				bricks[yy] = [];
				for (var xx:uint = 0; xx <= xxx; xx++)
				{
					var brickDef:* = brickDefs[yy][xx];
					var brick:Brick = new Brick(xx,yy,brickDef.backIndex,brickDef.overlayIndex,brickDef.tourCount,brickDef.sleepTime);
					brick.x = xx * Math.round(brick.width) + 50;
					brick.y = yy * Math.round(brick.height) + 50;
					brick.addEventListener(MouseEvent.CLICK,mouseClickHandler);
					brick.scaleX = 1;
					brick.scaleY = 1;
					bricks[yy][xx] = brick;
					bricksZone.addChild(brick);
				}
			}
		}

		private function mouseClickHandler(event:MouseEvent):void
		{
			var brick:Brick = event.currentTarget as Brick;
			var count:uint = removeBrick(brick);
		}

		public function removeBrick(brick:Brick,count:uint=0,send:Boolean=true):uint
		{
			if (brick.free && ! brick.removed)
			{
				count++;
				brick.marked = true;
				var lbrick:Brick = brick.xx > 0 ? bricks[brick.yy][brick.xx - 1]:null;
				if (lbrick && ! lbrick.marked && brick.equals(lbrick))
				{
					count = removeBrick(lbrick,count,send);
				}


				var tbrick:Brick = brick.yy > 0 ? bricks[brick.yy - 1][brick.xx]:null;
				if (tbrick && ! tbrick.marked && brick.equals(tbrick))
				{
					count = removeBrick(tbrick,count,send);
				}

				var rbrick:Brick = brick.xx < xxx ? bricks[brick.yy][brick.xx + 1]:null;
				if (rbrick && ! rbrick.marked && brick.equals(rbrick))
				{
					count = removeBrick(rbrick,count,send);
				}

				var bbrick:Brick = brick.yy < yyy ? bricks[brick.yy + 1][brick.xx]:null;
				if (bbrick && ! bbrick.marked && brick.equals(bbrick))
				{
					count = removeBrick(bbrick,count,send);
				}
				if (count > 1)
				{
					if (send && ! standalone)
					{
						sendStream.send("removeBrick",brick.xx,brick.yy);
					}
					brick.removed = true;
					if (tbrick)
					{
						tbrick.gotoAndStop(1);
						var motionBase:MotionBase = new MotionBase();
						motionBase.duration = 20;
						motionBase.addPropertyArray("x",[0,50,95,134,169,199,225,247,265,280]);
						motionBase.addPropertyArray("y",[0,1,0,4,12,21,32,44,52,38]);
						animFactory = new AnimatorFactory(motionBase);
						animFactory.transformationPoint = new Point(2,2);
						animFactory.addTarget(tbrick, 0);
					}
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