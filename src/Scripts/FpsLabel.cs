using Godot;

public partial class FpsLabel : RichTextLabel {
    public override void _Process(double delta) {
        Text = $"{Engine.GetFramesPerSecond():F0}";
    }
}
