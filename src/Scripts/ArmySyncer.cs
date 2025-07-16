using Godot;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

public partial class ArmySyncer : Node
{
    public static ArmySyncer instance;

    private Dictionary<string, int> teamArmyCounts = new Dictionary<string, int>();
    private string clientTeamName;
    private bool areAllClientsNamed = false;
    private bool areAllClientsJoined = false;
    private int expectedClientCount;

    [Signal]
    public delegate void AllClientNamesChosenEventHandler();
    [Signal]
    public delegate void ArmyCountChangedEventHandler(string team, int newValue);

    public override void _Ready()
    {
        instance = this;
        if (!ArgumentHandler.instance.IsArgumentIncluded("client-count")) expectedClientCount = 2;
        else expectedClientCount = ArgumentHandler.instance.GetArgumentValue("client-count").ToInt();
        Multiplayer.ConnectedToServer += AskUserForName;
    }

    public void SetArmyCount(int newCount)
    {
        if (OS.HasFeature("Server")) return;
        if (clientTeamName == null || clientTeamName == string.Empty) return;

        teamArmyCounts[clientTeamName] = newCount;
        Rpc(MethodName.AddTeamToServerRpc, clientTeamName, newCount);
    }

    public string GetClientName()
    {
        return clientTeamName;
    }

    public Dictionary<string, int> GetArmyCounts()
    {
        return teamArmyCounts;
    }


    public int GetArmyCount(string teamName)
    {
        return teamArmyCounts[teamName];
    }

    public void AllClientsJoined()
    {
        if (!OS.HasFeature("Server")) return;

        areAllClientsJoined = true;
        foreach (KeyValuePair<string, int> ii in teamArmyCounts)
        {
            Rpc(MethodName.AddTeamToClientRpc, ii.Key, ii.Value);
        }
    }

    private void AskUserForName()
    {
        if (ArgumentHandler.instance.IsArgumentIncluded("team-name"))
        {
            clientTeamName = ArgumentHandler.instance.GetArgumentValue("team-name");
            Rpc(MethodName.AddTeamToServerRpc, clientTeamName, 0);
            return;
        }

        LineEdit lineEdit = new LineEdit();
        AddChild(lineEdit);
        lineEdit.CustomMinimumSize = new Vector2(GetViewport().GetVisibleRect().Size.X, 80);
        lineEdit.PlaceholderText = "Team Name";
        lineEdit.Position = new Vector2(0, 100);
        lineEdit.TextSubmitted += (val) =>
        {
            clientTeamName = val;
            Rpc(MethodName.AddTeamToServerRpc, clientTeamName, 0);
            lineEdit.QueueFree();
        };
    }

    [Rpc(MultiplayerApi.RpcMode.AnyPeer, TransferMode = MultiplayerPeer.TransferModeEnum.Reliable)]
    private void AddTeamToServerRpc(string teamName, int armyCount)
    {
        teamArmyCounts[teamName] = armyCount;

        if (areAllClientsJoined)
        {
            Rpc(MethodName.AddTeamToClientRpc, teamName, armyCount);
        }
    }

    [Rpc(MultiplayerApi.RpcMode.Authority, TransferMode = MultiplayerPeer.TransferModeEnum.Reliable)]
    private void AddTeamToClientRpc(string teamName, int armyCount)
    {
        teamArmyCounts[teamName] = armyCount;
        if (teamName != clientTeamName)
        {
            EmitSignal(SignalName.ArmyCountChanged, teamName, armyCount);
        }

        if (!areAllClientsNamed && teamArmyCounts.Count == expectedClientCount)
        {
            areAllClientsNamed = true;
            EmitSignal(SignalName.AllClientNamesChosen);
        }

        GD.Print(Multiplayer.GetUniqueId() + ": " + teamName + " " + armyCount.ToString());
    }

    public void SaveCurrentBattle()
    {
        SaveBattle(teamArmyCounts);
    }

    public void SaveBattle(Dictionary<string, int> battleData)
    {
        using FileAccess saveFile = FileAccess.Open("user://history" + Time.GetDateStringFromSystem() + ".save", FileAccess.ModeFlags.Write);
        string json = JsonConvert.SerializeObject(battleData, Formatting.Indented);
        GD.Print(json);
        saveFile.StoreLine(json);
    }
}
