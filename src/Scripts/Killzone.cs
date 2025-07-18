using Godot;

public partial class Killzone : Area3D {
    bool queueReload;
    public override void _Ready() => BodyEntered += OnBodyEntered;
    public override void _ExitTree() => BodyEntered -= OnBodyEntered;
    void OnBodyEntered(Node3D body) {
        if (body is not Ball) return;
        // Godot doesn't like it when you reload the scene while processing the physics step, so we queue it for the next frame
        queueReload = true;
    }

    public override void _Process(double delta) {
        if (queueReload) GetTree().ReloadCurrentScene();
    }
}
