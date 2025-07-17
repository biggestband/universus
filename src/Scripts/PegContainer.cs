using Godot;
public partial class PegContainer : Node2D {
    Peg[] pegs;
    public override void _Ready() {
        var children = GetChildren();
        pegs = new Peg[children.Count];
        for (int i = 0; i < children.Count; i++) {
            if (children[i] is not Peg peg) continue;
            pegs[i] = peg;
        }
    }
    public void Setup() {
        foreach (Peg peg in pegs) {
            peg.Setup();
        }
    }
}