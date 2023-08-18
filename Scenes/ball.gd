extends CharacterBody2D

class_name Ball

signal life_lost

const VELOCITY_LIMIT = 40

@export var ball_speed = 15
@export var lifes = 3
@export var death_zone: DeathZone
@export var ui: UI

var speed_up_factor = 1.05
var start_position: Vector2
var last_collider_id

@onready var collision_shape_2d = $CollisionShape2D



func _ready():
	ui.set_lifes(lifes)
	start_position = position
	death_zone.life_lost.connect(on_life_lost)

func _physics_process(delta):
	var collision = move_and_collide(velocity * ball_speed * delta)
	if (!collision):
		return
		
	var collider = collision.get_collider()
	if collider is Brick:
		collider.decrease_level()
		
	if (collider is Brick or collider is Paddle):
		ball_collision(collider)
	else:
		velocity = velocity.bounce(collision.get_normal())
	
	
func start_ball():
	position = start_position
	randomize()
	
	velocity = Vector2(randf_range(-1, 1), randf_range(-.1, -1)).normalized() * ball_speed

func on_life_lost():
	lifes -= 1
	if lifes == 0:
		ui.game_over()
	else:
		life_lost.emit()
		reset_ball()
		ui.set_lifes(lifes)

func reset_ball():
	position = start_position
	velocity = Vector2.ZERO

func ball_collision(collider):
	
	var ball_width = collision_shape_2d.shape.get_rect().size.x
	var ball_center_x = position.x
	var collider_width = collider.get_width()
	var collider_center_x = collider.position.x
	
	var velocity_xy = velocity.length()
	
	var collision_x = (ball_center_x - collider_center_x) / (collider_width / 2)
	
	var new_velocity = Vector2.ZERO
	
	new_velocity.x = velocity_xy * collision_x
	
	if collider.get_rid() == last_collider_id && collider is Brick:
		new_velocity.x = new_velocity.rotated(deg_to_rad(randf_range(-45, 45))).x * 10
	else: 
		last_collider_id == collider.get_rid()
	
	new_velocity.y = sqrt(absf(velocity_xy* velocity_xy - new_velocity.x * new_velocity.x)) * (-1 if velocity.y > 0 else 1)
	var speed_multiplier = speed_up_factor if collider is Paddle else 1
	
	velocity = (new_velocity * speed_multiplier).limit_length(VELOCITY_LIMIT)
	
	
