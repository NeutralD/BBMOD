/// @func BBMOD_StaticBatch(_vformat)
///
/// @desc A static batch is a structure that allows you to compose static models
/// into a single one. Compared to {@link BBMOD_Model.render}, this drastically
/// reduces draw calls and increases performance, but requires more memory.
/// Current limitation is that the added models must use the same single material.
///
/// @param {BBMOD_VertexFormat} _vformat The vertex format of the static batch.
/// All models added to the same static batch must have the same vertex format.
/// This vertex format must not contain bone data!
///
/// @example
/// ```gml
/// mod_tree = new BBMOD_Model("Tree.bbmod");
/// var _vformat = mod_tree.get_vertex_format();
/// batch = new BBMOD_StaticBatch(_vformat);
/// batch.start();
/// with (OTree)
/// {
///     var _transform = matrix_build(x, y, z, 0, 0, direction, 1, 1, 1);
///     other.batch.add(other.mod_tree, _transform);
/// }
/// batch.finish();
/// batch.freeze();
/// ```
///
/// @see BBMOD_Model.get_vertex_format
/// @see BBMOD_DynamicBatch
function BBMOD_StaticBatch(_vformat) constructor
{
	/// @var {vertex_buffer} A vertex buffer.
	/// @private
	VertexBuffer = vertex_create_buffer();

	/// @var {BBMOD_VertexFormat} The format of the vertex buffer.
	/// @private
	VertexFormat = _vformat;

	/// @func start()
	/// @desc Begins adding models into the static batch.
	/// @see BBMOD_StaticBatch.add
	/// @see BBMOD_StaticBatch.finish
	/// @return {BBMOD_StaticBatch} Returns `self` to allow method chaining.
	static start = function () {
		gml_pragma("forceinline");
		vertex_begin(VertexBuffer, VertexFormat.Raw);
		return self;
	};

	/// @func add(_model, _transform)
	/// @desc Adds a model to the static batch.
	/// @param {BBMOD_Model} _model The model.
	/// @param {real[]} _transform A transformation matrix of the model.
	/// @return {BBMOD_StaticBatch} Returns `self` to allow method chaining.
	/// @example
	/// ```gml
	/// mod_tree = new BBMOD_Model("Tree.bbmod");
	/// var _vformat = mod_tree.get_vertex_format();
	/// batch = new BBMOD_StaticBatch(_vformat);
	/// batch.start();
	/// with (OTree)
	/// {
	///     var _transform = matrix_build(x, y, z, 0, 0, direction, 1, 1, 1);
	///     other.batch.add(other.mod_tree, _transform);
	/// }
	/// batch.finish();
	/// batch.freeze();
	/// ```
	/// @note You must first call {@link BBMOD_StaticBatch.begin} before using this
	/// function!
	/// @see BBMOD_StaticBatch.finish
	static add = function (_model, _transform) {
		gml_pragma("forceinline");
		_model.to_static_batch(self, _transform);
		return self;
	};

	/// @func finish()
	/// @desc Ends adding models into the static batch.
	/// @return {BBMOD_StaticBatch} Returns `self` to allow method chaining.
	/// @see BBMOD_StaticBatch.start
	static finish = function () {
		gml_pragma("forceinline");
		vertex_end(VertexBuffer);
		return self;
	};

	/// @func freeze()
	/// @desc Freezes the static batch. This makes it render faster, but disables
	/// adding more models.
	/// @return {BBMOD_StaticBatch} Returns `self` to allow method chaining.
	static freeze = function () {
		gml_pragma("forceinline");
		vertex_freeze(VertexBuffer);
		return self;
	};

	/// @func render(_material)
	/// @desc Submits the static batch for rendering.
	/// @param {BBMOD_Material} _material A material.
	/// @return {BBMOD_StaticBatch} Returns `self` to allow method chaining.
	static render = function (_material) {
		if ((_material.RenderPath & global.bbmod_render_pass) == 0)
		{
			// Do not render the mesh if it doesn't use a material that can be used
			// in the current render path.
			return;
		}
		_material.apply();
		vertex_submit(VertexBuffer, pr_trianglelist, _material.BaseOpacity);
		return self;
	};

	/// @func destroy()
	/// @desc Frees memory used by the static batch. Use this in combination with
	/// `delete` to destroy a static batch struct.
	/// @example
	/// ```gml
	/// static_batch.destroy();
	/// delete static_batch;
	/// ```
	static destroy = function () {
		gml_pragma("forceinline");
		vertex_delete_buffer(VertexBuffer);
	};
}