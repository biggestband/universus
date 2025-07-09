using Godot;
using System;

public partial class Boot : Node
{
    private int port = 3333;
    private int expectedClientCount = 2;

    public override void _Ready()
    {
        if(OS.HasFeature("Server"))
        {
            InitializeServer();
            Multiplayer.PeerConnected += (val) => {GD.Print(val + " connected");};
        }
        else
        {
            LineEdit lineEdit = new LineEdit();
            AddChild(lineEdit);
            lineEdit.CustomMinimumSize = new Vector2(1000, 80);
            lineEdit.PlaceholderText = "Server Ip";
            lineEdit.TextSubmitted += InitializeClient;
        }
    }

    private void InitializeServer()
    {
        var peer = new ENetMultiplayerPeer();
        peer.CreateServer(port, expectedClientCount);
        Multiplayer.MultiplayerPeer = peer;
        GD.Print("Initialized Server");
    }

    private void InitializeClient(string address)
    {
        var peer = new ENetMultiplayerPeer();
        peer.CreateClient(address, port);
        Multiplayer.MultiplayerPeer = peer;
        GD.Print("Initialized Client");
    }
}
