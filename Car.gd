extends KinematicBody2D

export var SELF_DRIVING=true

var engine_power =800
var wheel_base = 70
var steering_angle = 15
var friction = -0.9
var drag = -0.001
var braking = -450
var max_speed_reverse = 250
var slip_speed = 400
var traction_fast = 0.1
var traction_slow = 0.7

var acceleration = Vector2.ZERO
var velocity = Vector2.ZERO
var steer_direction
var isCollide
var live = true
var sensorDistances=[]
func _ready():
	var CarSprite = load('Motorcycle.tscn').instance()
	if SELF_DRIVING:
		CarSprite = load('DummyCar.tscn').instance()
	CarSprite.set_name("carSprite")
	self.add_child(CarSprite)
	
func _physics_process(delta):
	read_distances()
	acceleration = Vector2.ZERO
	if SELF_DRIVING:
		nn_input_noReverse()
	else:
		get_input()
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	velocity = move_and_slide(velocity)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision:
			on_collided(collision)
		
func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	acceleration += drag_force + friction_force

func get_input():
	var turn = 0
	if Input.is_action_pressed("steer_right"):
		turn += 1
	if Input.is_action_pressed("steer_left"):
		turn -= 1
	steer_direction = turn * deg2rad(steering_angle)
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking
		
func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base/2.0
	var front_wheel = position + transform.x * wheel_base/2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = velocity.linear_interpolate(new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()

var lastTurnTime=0.0
var lastGasTime=0.0
var lastTurn=rand_range(-1,1)

func on_collided(body):
	if live:
#		print(self.get_name(),' 报废一辆')
		if SELF_DRIVING:
			live=false

func read_distances():
	sensorDistances=[$Sensor.globalDistance,$Sensor2.globalDistance,$Sensor3.globalDistance,$Sensor4.globalDistance,$Sensor5.globalDistance]

var NN_turn
var NN_gas
func nn_input_noReverse():
	var turn = randi()  % 3 - 1 
	var gas =rand_range(0,1)+0.5
	if !NN_turn:
		steer_direction = turn * deg2rad(steering_angle)
		acceleration = transform.x * engine_power * gas
	else:
		steer_direction = NN_turn * deg2rad(steering_angle)
		acceleration = transform.x * engine_power * NN_gas
		



