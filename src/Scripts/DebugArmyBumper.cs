using Godot;
using System;
using System.ComponentModel;
using static ArmySyncer;

/// <summary>
/// Used for quickly debugging by allowing you to change the army count without plalying plinko.
/// </summary>
[GlobalClass]
public partial class DebugArmyBumper : Node
{

    private int armyCount = 0;


    public override void _Ready()
    {
        AddInput("countincrement", Key.Bracketright);
        AddInput("countdecrement", Key.Bracketleft);
        AddInput("countincrement10", Key.Backslash);
        AddInput("countreset", Key.Backspace);

        AddInput("savebattle", Key.S);
        AddInput("displayallhistory", Key.D);
    }

    public override void _Process(double delta)
    {
        if (!OS.HasFeature("Server"))
        {
            if (Input.IsActionJustReleased("countincrement"))
            {
                armyCount += 1;
                instance.SetArmyCount(armyCount);
            }
            if (Input.IsActionJustReleased("countdecrement"))
            {
                armyCount -= 1;
                instance.SetArmyCount(armyCount);
            }
            if (Input.IsActionJustReleased("countincrement10"))
            {
                armyCount += 10;
                instance.SetArmyCount(armyCount);
            }
            if (Input.IsActionJustReleased("countreset"))
            {
                armyCount = 0;
                instance.SetArmyCount(armyCount);
            }
        }
        else
        {
            if (Input.IsActionJustReleased("savebattle"))
            {
                instance.SaveCurrentBattle();
            }
            if (Input.IsActionJustReleased("displayallhistory"))
            {
                foreach (string ii in GetSaveFileNames()) GD.Print(DisplayHistory(ii));
            }
        }
    }

    private void AddInput(string label, Key keyCode)
    {
        InputMap.AddAction(label);
        InputEventKey ev = new InputEventKey();
        ev.PhysicalKeycode = keyCode;
        InputMap.ActionAddEvent(label, ev);
    }
}
