/// @func BBMOD_Error([_msg])
/// @desc The base struct for exceptions thrown by the BBMOD library.
/// @param {string} [_msg] An error message. Defaults to an empty string.
function BBMOD_Error(_msg) constructor
{
	/// @var {string} The error message.
	/// @readonly
	Message = !is_undefined(_msg) ? _msg : "";
}