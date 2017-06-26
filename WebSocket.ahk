﻿class WebSocket
{
	__New(WS_URL)
	{
		static wb
		
		; Create an IE instance
		Gui, +hWndhOld
		Gui, New, +hWndhWnd
		this.hWnd := hWnd
		Gui, Add, ActiveX, vWB, Shell.Explorer
		Gui, %hOld%: Default
		
		; Write an appropriate document
		WB.Navigate("about:<!DOCTYPE html><meta http-equiv='X-UA-Compatible'"
		. "content='IE=edge'><body></body>")
		while (WB.ReadyState < 4)
			sleep, 50
		Doc := WB.document
		
		; Add our handlers to the JavaScript namespace
		Doc.parentWindow.ahk_savews := this._SaveWS.Bind(this)
		Doc.parentWindow.ahk_event := this._Event.Bind(this)
		Doc.parentWindow.ahk_ws_url := WS_URL
		
		; Add some JavaScript to the page to open a socket
		Script := doc.createElement("script")
		Script.text := "ws = new WebSocket(ahk_ws_url); ahk_savews(ws);`n"
		. "ws.onopen = function(event){ ahk_event('Open', event); };`n"
		. "ws.onclose = function(event){ ahk_event('Close', event); };`n"
		. "ws.onerror = function(event){ ahk_event('Error', event); };`n"
		. "ws.onmessage = function(event){ ahk_event('Message', event); };"
		Doc.body.appendChild(Script)
	}
	
	; Called by the JS to save the WS object to the host
	_SaveWS(WebSock)
	{
		this.WebSock := WebSock
	}
	
	; Called by the JS in response to WS events
	_Event(EventName, Event)
	{
		this["On" + EventName](Event)
	}
	
	; Sends data through the WebSocket
	Send(Data)
	{
		this.WebSock.send(Data)
	}
	
	; Closes the WebSocket connection
	Close(Code:=1000, Reason:="")
	{
		this.WebSock.close(Code, Reason)
	}
	
	; Closes and deletes the WebSocket, removing
	; references so the class can be garbage collected
	Disconnect()
	{
		if this.hWnd
		{
			this.Close()
			Gui, % this.hWnd ": Destroy"
			this.hWnd := False
		}
	}
}
