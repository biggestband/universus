using Godot;

[Tool]
public partial class PegSpawner : Node {
    const string PEG_CONTAINER_NAME = "Peg Container";
    [Export]
    int rows = 5;

    [Export]
    int columns = 10;

    [Export]
    float inSpacing = 50f;

    [Export]
    float betweenSpacing = 50f;

    [Export]
    Node PegContainer {
        get => pegContainerRef;
        set  {
            if (value == null) {
                GD.PrintErr("Peg container cannot be null.");
                return;
            }
            if (value.Name != PEG_CONTAINER_NAME) {
                GD.Print($"Peg container's name is not {PEG_CONTAINER_NAME}, renaming...");
                value.Name = PEG_CONTAINER_NAME;
            }
            pegContainerRef = value;
        }
    }

    Node pegContainerRef;

    [Export]
    PackedScene pegPrefab;

    [ExportToolButton("Spawn Pegs")]
    Callable SpawnPegsCallable => Callable.From(SpawnPegs);

    void SpawnPegs() {
        if (PegContainer == null) {
            GD.PrintErr("The peg container is not set, aborting peg spawn.");
            return;
        }
        if (pegPrefab == null) {
            GD.PrintErr("The peg prefab is not set, aborting peg spawn.");
            return;
        }
        GD.Print("Removing children from peg container...");
        foreach (var child in PegContainer.GetChildren()) {
            child.Free();
        }
        GD.Print($"Spawning {rows * columns} pegs...");
        for (int y = 0; y < rows; y++) {
            for (int x = 0; x < columns; x++) {
                var peg = ResourceLoader.Load<PackedScene>(pegPrefab.ResourcePath).Instantiate() as Node2D;
                if (peg == null) {
                    GD.PrintErr($"Failed to instantiate peg from prefab at {pegPrefab.ResourcePath}");
                    continue;
                }
                peg.Name = $"Peg {y}x{x}";
                GetTree().EditedSceneRoot.FindChild("Peg Container") .AddChild(peg); // i wish pegContainer.SceneFilePath worked but it doesn't work in editor. WTF godot ??
                peg.SetOwner(GetTree().EditedSceneRoot);
                var offsetX = ((columns - 1) * inSpacing + (betweenSpacing / 2)) / 2f;
                var offsetY = ((rows - 1) * betweenSpacing) / 2f;
                peg.Position = new(
                    x * inSpacing + (y % 2 == 0 ? 0 : betweenSpacing / 2) - offsetX,
                    y * betweenSpacing - offsetY
                );
            }
        }
    }
}
