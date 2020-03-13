extends Area2D
var signRelativePos
var start_point
var end_point
export (int) var sensorDistance = 200
var offset=5
var distanceScale
var globalDistance=Global.SUPA_LARGE_VALUE

func init_sensor():
	var sensorEndpoint = Vector2(0,sensorDistance)
	$ObstacleSign/Line2D.set_point_position(1,sensorEndpoint)
	$ObstacleSign/Sign.position = sensorEndpoint
	signRelativePos = sensorEndpoint
	distanceScale=int(self.global_position.distance_to($ObstacleSign/Sign.global_position)/sensorDistance)


func _ready():
	init_sensor()


func _process(_delta):
	probe_obstacles()

var SENSOR_TOLERANCE_OFFSET = 8
func probe_obstacles():
	var space_state = get_world_2d().direct_space_state
	start_point=self.global_position
	if (int($ObstacleSign/Sign.global_position.distance_to(start_point)/distanceScale))>=sensorDistance+offset:
		$ObstacleSign/Sign.position=signRelativePos

	end_point=$ObstacleSign/Sign.global_position
	var result = space_state.intersect_ray(start_point,end_point, [self],1)
	if result:
		var obstacleDistance = int(result.position.distance_to(start_point)/distanceScale)
#		print([$'../'.get_name(),self.get_name(),obstacleDistance])
		globalDistance=obstacleDistance
#		print(globalDistance)
		if globalDistance<=SENSOR_TOLERANCE_OFFSET:
			$ObstacleSign.visible=false
		else:
			$ObstacleSign.visible=true
			$ObstacleSign/Line2D.set_point_position(1,Vector2(0,obstacleDistance))
			$ObstacleSign/Sign.position=Vector2(0,obstacleDistance)
	else:
		globalDistance=Global.SUPA_LARGE_VALUE
		$ObstacleSign/Sign.position=signRelativePos
		$ObstacleSign.visible=false
