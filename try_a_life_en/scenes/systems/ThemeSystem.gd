extends Node2D
class_name ThemeSystem
var ambient_particles: CPUParticles2D
func _ready(): EventBus.game_start_requested.connect(_on_start)
func _on_start(wk: String, _c: String, _g: String, _d: String, _s: Dictionary):
	if ambient_particles: ambient_particles.queue_free(); 
	ambient_particles = null
	match wk:
		"xianxia": _particles(Vector2(0,-1), Vector2(0,-5), 30, Color(0.5,1.0,0.8,0.4))
		"medieval_war": _fall_particles()
func _particles(dir: Vector2, grav: Vector2, amt: int, col: Color):
	ambient_particles = CPUParticles2D.new(); 
	ambient_particles.amount = amt
	ambient_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	var ss = get_viewport_rect().size
	ambient_particles.emission_rect_extents = ss / 2.0; 
	ambient_particles.position = ss / 2.0
	ambient_particles.direction = dir; 
	ambient_particles.gravity = grav
	ambient_particles.initial_velocity_min = 10.0; 
	ambient_particles.initial_velocity_max = 30.0
	ambient_particles.scale_amount_min = 1.0; 
	ambient_particles.scale_amount_max = 3.0
	ambient_particles.color = col; 
	add_child(ambient_particles)
func _fall_particles():
	ambient_particles = CPUParticles2D.new(); 
	ambient_particles.amount = 50
	ambient_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	var ss = get_viewport_rect().size
	ambient_particles.emission_rect_extents = Vector2(ss.x/2.0, 10); 
	ambient_particles.position = Vector2(ss.x/2.0, -20)
	ambient_particles.direction = Vector2(0,1); 
	ambient_particles.gravity = Vector2(0,30)
	ambient_particles.initial_velocity_max = 20.0
	ambient_particles.scale_amount_min = 2.0; 
	ambient_particles.scale_amount_max = 4.0
	ambient_particles.color = Color(0.3,0.3,0.3,0.6); 
	add_child(ambient_particles)
