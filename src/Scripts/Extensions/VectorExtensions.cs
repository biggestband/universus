using Godot;
namespace Utility;

public static class VectorExtensions {
    public static Vector2 With(this Vector2 vector, float? x = null, float? y = null) {
        return new(
            x ?? vector.X,
            y ?? vector.Y
        );
    }

    public static Vector3 With(this Vector3 vector, float? x = null, float? y = null, float? z = null) {
        return new(
            x ?? vector.X,
            y ?? vector.Y,
            z ?? vector.Z
        );
    }
}
