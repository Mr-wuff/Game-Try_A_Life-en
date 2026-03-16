extends Node

const BASE_URL = "http://127.0.0.1:8000/api"

func _make_async_request(endpoint: String, method: int, data: Dictionary = {}) -> Dictionary:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var headers = ["Content-Type: application/json"]
	var body = ""
	if not data.is_empty(): body = JSON.stringify(data)
		
	var error = http_request.request(BASE_URL + endpoint, headers, method, body)
	if error != OK: return {"error": "request_failed"}
		
	var result = await http_request.request_completed
	http_request.queue_free()
	
	var res_code = result[1]
	var res_body = result[3].get_string_from_utf8()
	
	if res_code >= 200 and res_code < 300:
		var json = JSON.parse_string(res_body)
		if typeof(json) == TYPE_DICTIONARY: return json
	return {"error": "http_error", "code": res_code}

func start_game(w, c, g, d, s) -> Dictionary: return await _make_async_request("/start_game", HTTPClient.METHOD_POST, {"world_key": w, "character_name": c, "gender": g, "difficulty": d, "stats": s})
func get_state() -> Dictionary: return await _make_async_request("/get_state", HTTPClient.METHOD_GET)
func generate_event() -> Dictionary: return await _make_async_request("/generate_event", HTTPClient.METHOD_GET)
func roll_dice(choice_index: int) -> Dictionary: return await _make_async_request("/roll_dice", HTTPClient.METHOD_POST, {"choice_index": choice_index})
func resolve_narrative() -> Dictionary: return await _make_async_request("/resolve_narrative", HTTPClient.METHOD_POST, {})
func submit_node_choice(inv: Dictionary) -> Dictionary: return await _make_async_request("/submit_node_choice", HTTPClient.METHOD_POST, {"investments": inv})
func resolve_node_narrative() -> Dictionary: return await _make_async_request("/resolve_node_narrative", HTTPClient.METHOD_POST, {})
func get_leaderboard() -> Dictionary: return await _make_async_request("/get_leaderboard", HTTPClient.METHOD_GET)

func get_model_status() -> Dictionary: return await _make_async_request("/models/status", HTTPClient.METHOD_GET)
func get_model_catalog() -> Dictionary: return await _make_async_request("/models/catalog", HTTPClient.METHOD_GET)
func pull_model(m: String) -> Dictionary: return await _make_async_request("/models/pull", HTTPClient.METHOD_POST, {"model_id": m})
func get_pull_progress(m: String) -> Dictionary: return await _make_async_request("/models/pull_progress/" + m, HTTPClient.METHOD_GET)
func switch_model(m: String) -> Dictionary: return await _make_async_request("/models/switch", HTTPClient.METHOD_POST, {"model_id": m})
func set_custom_api(api_url: String, api_key: String, model_name: String) -> Dictionary:
	return await _make_async_request("/models/set_custom_api", HTTPClient.METHOD_POST, {"api_url": api_url, "api_key": api_key, "model_name": model_name})

func submit_leaderboard(biography: String) -> Dictionary:
	return await _make_async_request("/leaderboard/submit", HTTPClient.METHOD_POST, {"biography": biography})
