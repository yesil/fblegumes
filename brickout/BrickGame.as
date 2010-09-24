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

		public function BrickGame()
		{
			super();
			txtConnected.visible = false;
			stageWidthHalf = stage.width / 2;
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
			this.btnCall.addEventListener(MouseEvent.CLICK, callClickHandler);
			gotoAndPlay(1, "intro");
			connectStratus();
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
					txtConnected.visible = true;
					sendStream = new NetStream(netConnection,NetStream.DIRECT_CONNECTIONS);
					sendStream.addEventListener(NetStatusEvent.NET_STATUS,netConnectionHandler);
					sendStream.publish('game');
					break;

				case "NetConnection.Connect.Closed" :
					trace("netconnection closed");
					break;

				case "NetStream.Connect.Success" :
					if (recvStream == null)
					{
						gotoAndPlay(1,'starting');
						txtPeerId.text = event.info.stream.farID;
						recvStream = new NetStream(netConnection,event.info.stream.farID);
						recvStream.addEventListener(NetStatusEvent.NET_STATUS, netConnectionHandler);
					}
					break;

				case "NetConnection.Connect.Failed" :
					trace("Unable to connect to " + StratusAddress + "/" + DeveloperKey + "\n");
					break;

				case "NetStream.Connect.Closed" :
					trace("netstream closed");
					break;
			}
		}

		private function callClickHandler(event:MouseEvent):void
		{
			var remoteId:String = this.txtRemoteId.text;
			gotoAndPlay(1,'starting');
			txtPeerId.text = remoteId;
			recvStream = new NetStream(netConnection,remoteId);
			recvStream.addEventListener(NetStatusEvent.NET_STATUS, netConnectionHandler);
			recvStream.play('game');
		}

		public function getGameLevel(level:int = 1):MovieClip
		{
			if (levels[level] == null)
			{

				bricks = new MovieClip();

				for (var yy:int = 0; yy<=7; yy++)
				{
					for (var xx:int = 0; xx<=5; xx++)
					{
						var brick:Brick = new Brick();
						brick.x = xx * brick.width + 15;
						brick.y = yy * brick.height + 15;

						bricks.addChild(brick);
					}
				}
				levels[level] = bricks;
			}
			return levels[level];
		}


		public function startGame():void
		{
			gotoAndPlay(1, "game");
		}
	}
}