using System;
using Godot;

public partial class ScoreManager : Node {
    public static event Action<ScoreData> OnScoreChanged = delegate { };
    public static int Score { get; private set; }
    public static int HighScore { get; private set; }

    public override void _Ready() {
        Score = 0;
    }

    public static void IncreaseScore(int amount) {
        Score += amount;
        EvaluateHighScore();
        OnScoreChanged.Invoke(new(Score, amount));
    }

    public static void EvaluateHighScore() {
        HighScore = Mathf.Max(Score, HighScore);
    }
}
