/// @enum An enumeration of members of a legacy rotation key struct.
/// @extends BBMOD_EAnimationKey
/// @see BBMOD_EAnimationKey
/// @see BBMOD_EPositionKey
enum BBMOD_ERotationKey
{
	/// @member {real} Time when the animation key occurs.
	/// @readonly
	Time,
	/// @member {real[]} A quaternion.
	/// @readonly
	Rotation,
	/// @member The size of the struct.
	SIZE
};

/// @func bbmod_rotation_key_interpolate(_rk1, _rk2, _factor)
/// @desc Interpolates between two rotation keys.
/// @param {BBMOD_ERotationKey} _rk1 The first rotation key.
/// @param {BBMOD_ERotationKey} _rk2 The second rotation key.
/// @param {real} _factor The interpolation factor. Should be a value in range 0..1.
/// @return {BBMOD_ERotationKey} A new rotation key with the interpolated
/// animation time and position.
/// @private
function bbmod_rotation_key_interpolate(_rk1, _rk2, _factor)
{
	var _key = array_create(BBMOD_EPositionKey.SIZE, undefined);
	_key[@ BBMOD_ERotationKey.Time] = lerp(
		_rk1[BBMOD_ERotationKey.Time],
		_rk2[BBMOD_ERotationKey.Time],
		_factor);
	var _rotation = ce_quaternion_clone(_rk1[BBMOD_ERotationKey.Rotation]);
	ce_quaternion_slerp(_rotation, _rk2[BBMOD_ERotationKey.Rotation], _factor);
	_key[@ BBMOD_ERotationKey.Rotation] = _rotation;
	return _key;
}

/// @func bbmod_rotation_key_load(_buffer)
/// @desc Loads a rotation key from a buffer.
/// @param {buffer} _buffer The buffer to load the struct from.
/// @return {BBMOD_ERotationKey} The loaded rotation key.
/// @private
function bbmod_rotation_key_load(_buffer)
{
	var _key = array_create(BBMOD_ERotationKey.SIZE, undefined);
	_key[@ BBMOD_ERotationKey.Time] = buffer_read(_buffer, buffer_f64);
	_key[@ BBMOD_ERotationKey.Rotation] = bbmod_load_quaternion(_buffer);
	return _key;
}

/// @func bbmod_rotation_key_to_matrix(_rotation_key)
/// @desc Creates a rotation matrix from a rotation key.
/// @param {BBMOD_ERotationKey} _rotation_key The rotation key.
/// @return {real[]} The created matrix.
/// @private
function bbmod_rotation_key_to_matrix(_rotation_key)
{
	gml_pragma("forceinline");
	return ce_quaternion_to_matrix(_rotation_key[BBMOD_ERotationKey.Rotation]);
}