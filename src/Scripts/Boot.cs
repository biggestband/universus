using Godot;
using System;

public partial class Boot : Node
{
    private int port = 3333;
    private int expectedClientCount = 2;
    private int trackedClientCount = 0;

    public override void _Ready()
    {
        ArmySyncer.instance.expectedClientCount = expectedClientCount;

        if(OS.HasFeature("Server"))
        {
            InitializeServer(expectedClientCount);
            Multiplayer.PeerConnected += (val) => {BumpPlayerCount();};
        }
        else
        {
            LineEdit lineEdit = new LineEdit();
            AddChild(lineEdit);
            lineEdit.CustomMinimumSize = new Vector2(GetViewport().GetVisibleRect().Size.X, 80);
            lineEdit.PlaceholderText = "Server Ip";
            lineEdit.TextSubmitted += InitializeClient;

            ArmySyncer.instance.AllClientNamesChosen += () => 
            {
                GD.Print(Multiplayer.GetUniqueId() + ": " + "Finished boot, go to new scene");
                //Add scene transition here
            };
        }
    }

    private void InitializeServer(int maxClients)
    {
        var peer = new ENetMultiplayerPeer();
        peer.CreateServer(port, maxClients);
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

    private void BumpPlayerCount()
    {
        trackedClientCount += 1;

        if(trackedClientCount == expectedClientCount)
        {
            ArmySyncer.instance.AllClientsjoined();
            GD.Print("All Clients joined");
        }
    }
}
