class_name LLMRequester extends RefCounted
## 申请LLM Calls.


var is_chunked := false # 是否分块
var is_finished := true # 是否完毕


var api_url := ""
var api_port := 443
var api_path := "/v1/chat/completions"
var api_authorization:String = ""


var respond_headers:Dictionary
var _self_ref:LLMRequester = null ## 此变量是为了造成“循环引用”，防止自己被GC回收。


var api_model:String = ""
var use_stream := true # 是否使用流式传输


signal chunk_raw_received(chunk:String) # 收到一个分块。原始文本，未经处理。
signal chunk_dict_received(chunk_dict:Dictionary) # 收到一个分块。原始文本，未经处理。
signal chunk_text_received(chunk_text:String) # 收到一个分块（限chat文本内容，过滤了无关信息）
# signal chat_completions_request_finished(response:String) # 请求完成(聊天)
# signal completion_request_finished(response:String) # 请求完成(补全)


signal request_finished(response:String) # 请求完成


## 初始化为本地Ollama
func init_as_local_ollama():
	api_url = "http://localhost"
	api_port = 11434
	api_path = "/v1/chat/completions"
	api_authorization = ""
	api_model = "gemma3:1b"


## 初始化为硅基流动 API
func init_as_siloconflow(api_key:String, default_model:="Qwen/Qwen2.5-Coder-7B-Instruct"):
	api_url = "https://api.siliconflow.com"
	api_port = 443
	api_model = default_model
	api_path = "/v1/chat/completions" 
	api_authorization = "Bearer " + api_key



## 初始化为OpenAI兼容API
func init_as_openai_compatible(_api_key:String, _api_url:String, _api_port:int=443, _api_model="gpt-3.5-turbo"):
	self.api_key = _api_key
	self.api_url = _api_url
	self.api_port = _api_port
	self.api_model = _api_model


func call_api() -> void:
	_self_ref = self # 确保不被GC

	var payload = JSON.stringify({
		"model": api_model,
		"messages": [
			{"role": "system", "content": "你是一个AI助手。"},
			{"role": "user", "content": "请解释一下什么是人工智能。"}
		],
		"max_tokens": 500,
		"temperature": 0.7,
		"stream": true
	})

	var err := 0
	var http := HTTPClient.new() # 创建用于HTTP连接的Client.
	err = http.connect_to_host(api_url, api_port) # 建立连接。HOST, PORT
	assert(err == OK) # 确保连接OK

	# 等待，直到Resolver已经连接完毕
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		print("正在建立连接......")
		await Engine.get_main_loop().process_frame

	assert(http.get_status() == HTTPClient.STATUS_CONNECTED) # 检查连接是否正确建立。

	var headers :PackedStringArray = [
		"Content-Type: application/json",
		"Authorization: {0}".format([api_authorization])
		]
	err = http.request(HTTPClient.METHOD_POST, api_path , headers, payload) # 从该网站获取数据。（原始网站是Trunked）
	assert(err == OK) # Make sure all is OK.

	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		# 持续Polling，（检查是否有新数据到达）直到请求完成。
		http.poll()
		print("正在请求......")
		await Engine.get_main_loop().process_frame

	assert(http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED) # 确保请求完毕
	print("是否有Response: ", http.has_response()) # 网站有可能没Response.

	if http.has_response(): # 如果获取到了响应，则
		respond_headers = http.get_response_headers_as_dictionary() # Get response headers.
		print("Response code:  ", http.get_response_code()) # Show response code.
		print("Headers:  ", respond_headers) # Show headers.

		# 获取HTTP Body
		if http.is_response_chunked():
			print("Response is Chunked!") # Does it use chunks?
			#is_chunked = true
		else:
			pass
			# TODO 处理非stream情况。
			#body_length = http.get_response_body_length() # Or just plain Content-Length
			#print("Response Length: ", body_length)
			#is_chunked = false
			
		# 使用buffer对两种方法都管用
		var read_buffer := PackedByteArray() # 读取缓冲区，存储保存的chunk.

		while http.get_status() == HTTPClient.STATUS_BODY: # 如果仍然有待读取的body：
			http.poll()
			var chunk = http.read_response_body_chunk() # 获取一个Chunk。 TODO HACK BROKEN警告：部分API获得的Chunk可能不止一个！我应该按换行符进行分割。
			if chunk.size() == 0:
				await Engine.get_main_loop().process_frame
			else:
				# 打印。？
				
				# 原始文本。
				var chunk_raw_str :=chunk.get_string_from_utf8() # data: {"xxxx":"xxx", "xxx":"xxx" ... }
				chunk_raw_received.emit(chunk_raw_str) # 发射信号，传递chunk_raw_str。
				
				# 处理后解析后的字典。
				var chunk_str_clean := chunk_raw_str.lstrip("data: ") # {"xxxx":"xxx", "xxx":"xxx" ... }
				var chunk_dict = JSON.parse_string(chunk_str_clean)  # HACK 没考虑异常情况
				if chunk_dict != null:
					# NOTE 解析成功
					chunk_dict_received.emit(chunk_dict) # 发射信号，传递chunk
					
					
					# 如果解析成功，则返回content字段。
					#print(chunk_dict)
					var content_str := str(chunk_dict["choices"][0]["delta"]["content"])
					# 尝试解析。
					
					print(content_str) ## 打印解析的文本片段
					
					chunk_text_received.emit(content_str) # 发射信号，传递content字段。注意，这里可能会抛出异常，如果content字段不存在。
					
					#print(chunk_dict)
				else:
					# NOTE 解析失败 TODO 暂时没想好怎么处理

					#assert(chunk_dict)
					print("遇到了解析错误：\n", chunk_raw_str, "\n")
					push_error("解析错误！尝试解析", chunk_raw_str, "但发生了错误！")
				
				# 无论最终解析结果如何，都会全部追加到Read Buffer里。
				read_buffer = read_buffer + chunk # 追加到read buffer
		
		# 到此，读取结束！
		# DEBUG 打印已经获取的bytes数量：
		print("已经获取的bytes: ", read_buffer.size())
		var text = read_buffer.get_string_from_ascii()
		# print("Text: ", text)
		request_finished.emit(text) # 发射信号，传递最终的文本内容。
	
	# 析构、丢引用。
	#self.free()
	_self_ref = null

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		print("调用了析构函数！")
