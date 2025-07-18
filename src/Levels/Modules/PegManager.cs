using Godot;

[Tool]
public partial class PegManager : Node3D {
    // [Export]
    // int rows = 5;
    //
    // [Export]
    // int columns = 10;

    [Export]
    float rowSpacing = 50f;

    [Export]
    float columnSpacing = 50f;

    [Export]
    float evenRowOffset = 25f;

    [ExportToolButton("Rearrange Pegs")]
    Callable SpawnPegsCallable => Callable.From(SpawnPegs);

    void SpawnPegs() {
        var rows = GetChildren();
        var yOffset = 0f;
        for (var y = 0; y < rows.Count; y++) {
            var node = rows[y];
            if (node is not Node3D rowNode) continue;
            rowNode.Position = Vector3.Down * yOffset;
            yOffset += rowSpacing;
            var columns = rowNode.GetChildren();
            var xOffset = (y % 2 == 0) ? evenRowOffset : 0f;
            for (var x = 0; x < columns.Count; x++) {
                var columnNode = columns[x];
                if (columnNode is not Node3D pegNode) continue;
                pegNode.Position = Vector3.Right * (x * columnSpacing + xOffset);
            }
        }
    }
    
    public void Setup() {
        foreach (var row in GetChildren()) {
            foreach (var node in row.GetChildren()) {
                if (node is not Peg peg) continue;
                peg.Setup();
            }
        }
    }
}
