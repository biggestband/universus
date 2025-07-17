using System;
using Godot;

public partial class ScoreManager : Node {
    [Export]
    float newHitScore = 0.2f, reHitScore = 0.1f;
    public static event Action<ScoreData> OnScoreChanged = delegate { };
    public static float Score { get; private set; }
    public static float HighScore { get; private set; }

    public static float NewHitScore, ReHitScore;

    public override void _Ready() {
        Score = 0;
        NewHitScore = newHitScore;
        ReHitScore = reHitScore;
    }

    public static void IncreaseScore(HitType type) {
        var amount = type switch {
            HitType.NewHit => NewHitScore,
            HitType.ReHit =>  ReHitScore,
            _ => 0,
        };
        Score += amount;
        EvaluateHighScore();
        OnScoreChanged.Invoke(new(Score, amount, type));
    }

    public static void EvaluateHighScore() {
        HighScore = Mathf.Max(Score, HighScore);
    }
}

public enum HitType : byte {
    NewHit,
    ReHit,
    NoHit,
}
