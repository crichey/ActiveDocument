xquery version "1.0-ml";
declare namespace error = "http://marklogic.com/xdmp/error";
try {
	let $request := xdmp:get-request-field("request")
	let $log := xdmp:log(fn:concat("Dynamic request received:",$request))
	return xdmp:eval($request)
}
catch ($exception) {
	let $error-message := $exception/error:message
	let $error-response := xdmp:set-response-code(500, $error-message)
	return $error-message
}