using Godot;
using System;
using System.Collections.Generic;

public partial class ArmySyncer : Node
{
    private Dictionary<string, int> teamArmyCounts = new Dictionary<string, int>();

    [Signal]
    public delegate void ArmyCountChangedEventHandler();

    public override void _Ready()
    {
        Multiplayer.ConnectedToServer += AskUserForName;
    }

    public void SetArmyCount(int newCount)
    {
        
    }

    public int GetArmyCount(string teamName)
    {
        return teamArmyCounts[teamName];
    }

    private void AskUserForName()
    {
        LineEdit lineEdit = new LineEdit();
        AddChild(lineEdit);
        lineEdit.CustomMinimumSize = new Vector2(1000, 80);
        lineEdit.PlaceholderText = "Team Name";
        lineEdit.Position = new Vector2(0, 100);
        lineEdit.TextSubmitted += (val) => {Rpc(MethodName.AddTeamToServerRpc, val);};
    }

    [Rpc(MultiplayerApi.RpcMode.AnyPeer, TransferMode = MultiplayerPeer.TransferModeEnum.Reliable)]
    private void AddTeamToServerRpc(string teamName)
    {
        teamArmyCounts.Add(teamName, 0);
        GD.Print(teamName + " added");
    }
}
