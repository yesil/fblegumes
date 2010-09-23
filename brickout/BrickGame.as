package brickout
{
	import flash.display.MovieClip;	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import brickout.*;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	
	public class BrickGame extends MovieClip
	{
		private var stageWidthHalf:int;
		public var bricks:MovieClip;
		public var level:int = 1;
		private var levels:Array = new Array();
		private const StratusAddress:String = "rtmfp://stratus.rtmfp.net";
		private const DeveloperKey:String = "0e8780f03fc122388b0ff850-4e52140316e0";
		private var netConnection:NetConnection;
		
		public function BrickGame()
		{
			super();
			connectStratus();
			stageWidthHalf = stage.width/2;
			stage.addEventListener(KeyboardEvent.KEY_UP, keyPressedEvent);
//			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
			gotoAndPlay(1, "intro");
		}
		
		private function connectStratus():void{
			netConnection = new NetConnection();
			netConnection.addEventListener(NetStatusEvent.NET_STATUS,
			netConnectionHandler);
			netConnection.connect(StratusAddress + "/" + DeveloperKey);
		}
		
		private function netConnectionHandler(event:NetStatusEvent):void
			{
				trace("NetConnection event: " + event.info.code + "\n");
				
            	switch (event.info.code)
            	{
                	case "NetConnection.Connect.Success":
						trace("Connected, my ID: " + netConnection.nearID + "\n");
                    	break;
                    	
                    case "NetConnection.Connect.Closed":
                    	trace("netconnection closed");
                    	break;
                    	
                    case "NetStream.Connect.Success":
                    	trace("Connection from: " + event.info.stream.farID + "\n");
                    	break;
                    	
                    case "NetConnection.Connect.Failed":
                    	trace("Unable to connect to " + StratusAddress + "/" + DeveloperKey + "\n");
                    	break;
                    	
                    case "NetStream.Connect.Closed":
                    	trace("netstream closed");
                    	break;
             	}
         	}
		
		private function keyPressedEvent(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.SPACE)
			{
				if(currentScene.name=="pause") gotoAndPlay(1, "game");
				else if (currentScene.name == "game") 
				{
					gotoAndPlay(1, "pause");
				}
				else if (currentScene.name == "finish") gotoAndPlay(1, "intro");
			}
		}
		
		public function getGameLevel(level:int = 1):MovieClip
		{
			if(levels[level] == null)
			{
				
				bricks = new MovieClip();

				for (var yy:int = 0; yy<=7;yy++)
				{
					for(var xx:int = 0; xx<=5;xx++)
					{
							var brick:Brick = new Brick()
							
							brick.x = xx*brick.width+15;
							brick.y = yy*brick.height+15;
							
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
		