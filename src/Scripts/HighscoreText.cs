using Godot;

public partial class HighscoreText : Label {
    public override void _Ready() {
        ScoreManager.OnScoreChanged += UpdateText;
        UpdateText();
    }
    public override void _ExitTree() {
        ScoreManager.OnScoreChanged -= UpdateText;
    }
    void UpdateText(ScoreData data = default) {
        Text = $"Highscore:   {ScoreManager.HighScore:F1}";
    }
}
