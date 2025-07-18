using System;
using Godot;

public partial class ScoreManager : Node {
    [Export]
    float newHitScore = 0.2f, reHitScore = 0.1f;

    static bool logging;
    
    [Export]
    bool logging_backing = false;
    
    public static float Score { get; private set; }
    public static float HighScore { get; private set; }

    public static float NewHitScore, ReHitScore;

    public override void _Ready() {
        Score = 0;
        NewHitScore = newHitScore;
        ReHitScore = reHitScore;
        
        logging = logging_backing;

        PachinkoEventManager.Instance.OnHit += IncreaseScore;
        PachinkoEventManager.Instance.OnFinalScore += FinalScore;
    }
    
    public override void _ExitTree() {
        PachinkoEventManager.Instance.OnHit -= IncreaseScore;
        PachinkoEventManager.Instance.OnFinalScore += FinalScore;
    }
    void FinalScore(float baseScore, float multiplier) {
        Score = baseScore * multiplier;
        if (logging) GD.Print($"Final Score: {Score} (Base: {baseScore}, Multiplier: {multiplier})");
        EvaluateHighScore();
    }
    
    public static void IncreaseScore(int type) {
        var amount = (HitType)type switch {
            HitType.NewHit => NewHitScore,
            HitType.ReHit =>  ReHitScore,
            _ => 0,
        };
        SetScore(Score, Score + amount);
    }
    
    static void SetScore(float oldScore, float score) {
        Score = score;
        EvaluateHighScore();
        if (logging) GD.Print($"Earned {score - oldScore} points, new score: {Score}");
        PachinkoEventManager.Instance.Score(oldScore, Score);
    }

    public static void EvaluateHighScore() {
        if (Score <= HighScore) return;
        
        HighScore = Score;
        if (logging) GD.Print($"New High Score: {HighScore}");
        PachinkoEventManager.Instance.HighScore(HighScore);
    }

    public static void ResetScore() {
        SetScore(0, 0);
    }
}

public enum HitType : byte {
    NewHit,
    ReHit,
    NoHit,
}
