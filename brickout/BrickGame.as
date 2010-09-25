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

	public class BrickGame extends MovieClip
	{
		private var stageWidthHalf:int;
		public var bricks:MovieClip;
		public var level:int = 1;
		private var levels:Array = new Array();
		private const StratusAddress:String = "rtmfp://stratus.rtmfp.net";
		private const DeveloperKey:String = "0e8780f03fc122388b0ff850-4e52140316e0";
		private var netConnection:NetConnection;
		private var sendStream:NetStream;
		private var recvStream:NetStream;
		private var brickDefs = [];
		private var mode:String;

		public function BrickGame()
		{
			super();
			//gotoAndPlay(1,"intro");
			//btnCall.enabled = false;
			stageWidthHalf = stage.width / 2;
			//connectStratus();
			client = new Object();
			client.debug = function(msg:String):void
			{
			trace(msg);
			};

			client.setBrickDefs =  function(defs:*):void
			{
			trace("reception des bricks");
			 brickDefs = defs as Array;
			};
			client.startGame = startGame;
			initBrickDefs();
			startGame();
		}

		private function startGame():void
		{
			gotoAndPlay(1,"game");
		}

		private function connectStratus():void
		{
			netConnection = new NetConnection();
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
					this.btnCall.addEventListener(MouseEvent.CLICK, callClickHandler);
					sendStream = new NetStream(netConnection,NetStream.DIRECT_CONNECTIONS);
					sendStream.addEventListener(NetStatusEvent.NET_STATUS,netConnectionHandler);
					sendStream.publish("game");
					break;

				case "NetStream.Connect.Success" :
					if (recvStream == null)
					{
						this.mode = "server";
						recvStream = new NetStream(netConnection,event.info.stream.farID);
						recvStream.addEventListener(NetStatusEvent.NET_STATUS, netConnectionHandler);
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
			recvStream.addEventListener(NetStatusEvent.NET_STATUS, netConnectionHandler);
			recvStream.client = this.client;
			recvStream.play("game");
		}

		private var client:Object = null;
		
		private var xxx = 8;
		private var yyy = 12;

		private function initBrickDefs():void
		{
			for (var yy:int = 0; yy<=yyy; yy++)
			{
				brickDefs[yy] = {};
				for (var xx:int = 0; xx<=xxx; xx++)
				{
					brickDefs[yy][xx] = {};
					brickDefs[yy][xx].rndWall = Math.round(Math.random() * 10) % 2;
					brickDefs[yy][xx].rndLegume = (Math.round(Math.random()*10)%5)+1;
					brickDefs[yy][xx].tourNumber = Math.round(Math.random() * 10) + 1;
					brickDefs[yy][xx].sleepTime = Math.round(Math.random() * 1000) + 1;
				}
			}

		}

		public function initBricks():void
		{
			for (var yy:Number = 0; yy<=yyy; yy++)
			{
				for (var xx:Number = 0; xx<=xxx; xx++)
				{
					var brick:Brick = new Brick(brickDefs[yy][xx], brickDefs,xx,yy);
					brick.x = xx * Math.round(brick.width) + 50;
					brick.y = yy * Math.round(brick.height) + 75;
					bricksZone.addChild(brick);
				}
			}
		}
	}
}