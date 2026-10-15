using Godot;
using System;
using System.Runtime.CompilerServices;

public partial class PlayerMovement : CharacterBody3D
{
	[Export] private float MoveSpeed = 5, MouseSens = 0.0025f, VRotation = 0;
	private enum MoveState {Normal, Sprinting, Crouching}
	[Export]private MoveState CurrentMoveState;
	public Camera3D cam;

	public override void _Ready()
	{
		cam = GetNode<Camera3D>("Camera3D");
		Input.MouseMode = Input.MouseModeEnum.Captured;
	}

	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event is InputEventMouseMotion mouseMotion)
		{
			RotateY(-mouseMotion.Relative.X * MouseSens);
			VRotation -= (mouseMotion.Relative.Y * MouseSens);
			VRotation = Mathf.Clamp(VRotation, Mathf.DegToRad(-90), Mathf.DegToRad(90));
			cam.Rotation = new Vector3(VRotation, 0, 0);
		}
	}

	public override void _Process(double delta)
	{
		Vector2 inputDir = Input.GetVector("move_left", "move_right", "move_forward", "move_back");
		Vector3 direction = (Transform.Basis * new Vector3(inputDir.X, 0, inputDir.Y));
		Velocity = new Vector3(direction.X * MoveSpeed, Velocity.Y, direction.Z * MoveSpeed);
		MoveAndSlide();
	}
}
