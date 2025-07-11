using Godot;
using System;
using System.Collections.Generic;

public partial class ArgumentHandler : Node
{
    public static ArgumentHandler instance;
    private Dictionary<string, string> arguments = new Dictionary<string, string>();

    public override void _Ready()
    {
        instance = this;
        ParseArguments();
    }

    private void ParseArguments()
    {
        foreach (var argument in OS.GetCmdlineArgs())
        {
            if (argument.Contains('='))
            {
                string[] keyValue = argument.Split("=");
                arguments[keyValue[0].TrimPrefix("--")] = keyValue[1];
            }
            else
            {
                arguments[argument.TrimPrefix("--")] = "";
            }
        }
    }

    public bool IsArgumentIncluded(string argumentName)
    {
        return arguments.ContainsKey(argumentName);
    }

    public string GetArgumentValue(string argumentName)
    {
        if (!arguments.ContainsKey(argumentName)) return "";

        return arguments[argumentName];
    }

}
