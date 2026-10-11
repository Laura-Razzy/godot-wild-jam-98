using Godot;
using System;
using System.Data;
using System.Security.AccessControl;
using System.Security.Cryptography;

public partial class PlayerInteractions : Node
{
	[Export] private float RayDistance = 10;
	GodotObject Target;
	private uint NodeDetection = 1;
	private uint PreviousLayer;
	private Camera3D cam;
	private RayCast3D RayCast;
	private Marker3D Holder;
	private RigidBody3D rb, Holding, Dropped;

	public override void _Ready()
	{
		cam = GetNode<Camera3D>("../Camera3D");
		RayCast = GetNode<RayCast3D>("../Camera3D/InteractionRay");
		Holder = GetNode<Marker3D>("../Camera3D/HoldPoint");
		RayCast.TargetPosition = new Vector3(0, 0, -RayDistance);
		RayCast.CollisionMask = NodeDetection;
		RayCast.Enabled = true;
		Target = RayCast.GetCollider();
	}

	public override void _Process(double delta)
	{
		RayCast.ForceRaycastUpdate();
	}

	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event.IsActionPressed("interact"))
		{
			if (Holding != null)
			{
				Drop();
			}
			else
			{
				PickUp();
			}
		}
		if (@event.IsActionPressed("ui_cancel"))
		{
			if (Input.MouseMode == Input.MouseModeEnum.Captured)
			{
				Input.MouseMode = Input.MouseModeEnum.Visible;
			}
			else
			{
				Input.MouseMode = Input.MouseModeEnum.Captured;
			}
		}
	}

	void PickUp()
	{
		RayCast.ForceRaycastUpdate();
		Target = RayCast.GetCollider();
		if (!RayCast.IsColliding() || Target is not RigidBody3D rb || !rb.IsInGroup("pickupable"))
		{
			return;
		}
		Holding = rb;
		PreviousLayer = Holding.CollisionLayer;
		Holding.CollisionLayer = 0;
		Holding.LinearVelocity = Vector3.Zero;
		Holding.AngularVelocity = Vector3.Zero;
		Holding.Reparent(Holder, false);
		Holding.Position = Vector3.Zero;
		Holding.Rotation = Vector3.Zero;
		Holding.Freeze = true;
	}

	void Drop()
	{
		Dropped = Holding;
		Holding = null;
		Dropped.Reparent(GetTree().CurrentScene, true);
		Dropped.GlobalPosition = cam.GlobalPosition - cam.GlobalBasis.Z * 2;
		Dropped.CollisionLayer = PreviousLayer;
		Dropped.Freeze = false;
		Dropped.Sleeping = false;
	}
}
