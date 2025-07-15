using Godot;
using System;
using System.ComponentModel;

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
    }

    public override void _Process(double delta)
    {
        if(Input.IsActionJustReleased("countincrement"))
        {
            armyCount += 1;
            ArmySyncer.instance.SetArmyCount(armyCount);
        }
        if(Input.IsActionJustReleased("countdecrement"))
        {
            armyCount -= 1;
            ArmySyncer.instance.SetArmyCount(armyCount);
        }
        if(Input.IsActionJustReleased("countincrement10"))
        {
            armyCount += 10;
            ArmySyncer.instance.SetArmyCount(armyCount);
        }
        if(Input.IsActionJustReleased("countreset"))
        {
            armyCount = 0;
            ArmySyncer.instance.SetArmyCount(armyCount);
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
