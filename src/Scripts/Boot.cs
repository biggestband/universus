using Godot;
using System;

public partial class Boot : Node
{
    private int port = 3333;
    private int expectedClientCount = 2;
    private int trackedClientCount = 0;

    public override void _Ready()
    {
        if (OS.HasFeature("Server"))
        {
            expectedClientCount = ArgumentHandler.instance.GetArgumentValue("client-count").ToInt();
            InitializeServer(expectedClientCount);
            Multiplayer.PeerConnected += (val) => { BumpPlayerCount(); };
        }
        else
        {
            if (ArgumentHandler.instance.IsArgumentIncluded("server-ip"))
            {
                InitializeClient(ArgumentHandler.instance.GetArgumentValue("server-ip"));
            }
            else
            {
                LineEdit lineEdit = new LineEdit();
                AddChild(lineEdit);
                lineEdit.CustomMinimumSize = new Vector2(GetViewport().GetVisibleRect().Size.X, 80);
                lineEdit.PlaceholderText = "Server Ip";
                lineEdit.TextSubmitted += InitializeClient;
            }

            ArmySyncer.instance.AllClientNamesChosen += () =>
            {
                GD.Print(Multiplayer.GetUniqueId() + ": " + "Finished boot, go to new scene");
                //Add scene transition here
            };
        }

        if (ArgumentHandler.instance.IsArgumentIncluded("copy-ip"))
        {
            GetIps();
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

        if (trackedClientCount == expectedClientCount)
        {
            ArmySyncer.instance.AllClientsJoined();
            GD.Print("All Clients joined");
        }
    }

    private void GetIps()
    {
        if (ArgumentHandler.instance.GetArgumentValue("copy-ip") == "local")
        {
            FindLocalIp();
        }
        if (ArgumentHandler.instance.GetArgumentValue("copy-ip") == "public")
        {
            var httpRequest = new HttpRequest();
            AddChild(httpRequest);
            httpRequest.RequestCompleted += ReceivePublicIp;

            Error error = httpRequest.Request("https://api.ipify.org/");
            if (error != Error.Ok)
            {
                GD.PushError("An error occurred in the HTTP request.");
            }
        }
    }
    
    private void FindLocalIp()
    {
        string output = "";
        string environment = "";

        if (OS.HasFeature("windows")) environment = "COMPUTERNAME";
        else if (OS.HasFeature("linux")) environment = "HOSTNAME";

        if (OS.HasEnvironment(environment)) output = IP.ResolveHostname(OS.GetEnvironment(environment), IP.Type.Ipv4);

        GD.Print("local ip: " + output);
        DisplayServer.ClipboardSet(output);
    }

    private void ReceivePublicIp(long result, long responseCode, string[] headers, byte[] body)
    {
        string output = body.GetStringFromUtf8();
        GD.Print("public ip: " + output);
        DisplayServer.ClipboardSet(output);
    }
}
