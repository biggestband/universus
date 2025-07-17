using Godot;

public partial class HighscoreText : Label {
    public override void _Ready() {
        PachinkoEventManager.Instance.OnHighScore += UpdateText;
        UpdateText();
    }
    public override void _ExitTree() {
        PachinkoEventManager.Instance.OnHighScore -= UpdateText;
    }
    void UpdateText(float score = 0) {
        Text = $"Highscore:   {score:F1}";
    }
}
