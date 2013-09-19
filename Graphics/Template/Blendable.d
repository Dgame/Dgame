module Dgame.Graphics.Template.Blendable;

private {
	debug import std.stdio;
	
	import Dgame.Graphics.Color;
}

/**
 * Supported BlendModes
 */
enum BlendMode {
	Alpha,    /** Pixel = Src * a + Dest * (1 - a) */
	Add,      /** Pixel = Src + Dest */
	Multiply, /** Pixel = Src * Dest */
	None      /** No blending. */
}

interface Blendable {
public:
	/**
	 * Enable or Disable blending
	 */
	void enableBlending(bool);
	/**
	 * Returns if Blending is enabled
	 */
	bool isBlendingEnabled() const pure nothrow;
	/**
	 * Set the Blendmode.
	 */
	void setBlendMode(BlendMode);
	/**
	 * Returns the current Blendmode.
	 */
	BlendMode getBlendMode() const pure nothrow;
	/**
	 * Set the Blend Color.
	 */
	void setBlendColor(ref const Color);
	/**
	 * Rvalue version
	 */
	void setBlendColor(const Color);
	/**
	 * Returns the current Blend Color.
	 */
	ref const(Color) getBlendColor() const pure nothrow;
	/**
	 * Activate or deactivate the using of the Blend color.
	 */
	void enableBlendColor(bool);
	/**
	 * Returns, if using blend color is activated, or not.
	 */
	bool isBlendColorEnabled() const pure nothrow;
}

mixin template TplBlendable() {
private:
	BlendMode _blendMode;
	Color _blendColor;
	
	bool _isBlending;
	bool _isBlendColor;
	
protected:
	void _applyBlending() const {
		if (!this._isBlending)
			return;
		
		final switch (this._blendMode) {
			// Alpha blending
			case BlendMode.Alpha:
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
				break;
				// Additive blending
			case BlendMode.Add:
				glBlendFunc(GL_SRC_ALPHA, GL_ONE);
				break;
				// Multiplicative blending
			case BlendMode.Multiply :
				glBlendFunc(GL_DST_COLOR, GL_ZERO);
				break;
				// No blending
			case BlendMode.None:
				glBlendFunc(GL_ONE, GL_ZERO);
				break;
		}
		
		if (this._isBlendColor && this._blendMode != BlendMode.None) {
			const float[4] col = this._blendColor.asGLColor();
			
			version(all)
				glBlendColor(col[0], col[1], col[2], col[3]);
			else
				glColor4f(col[0], col[1], col[2], col[3]);
		}
	}
	
public:
final:
	/**
	 * Enable or Disable blending
	 */
	void enableBlending(bool enable) {
		this._isBlending = enable;
	}
	
	/**
	 * Returns if Blending is enabled
	 */
	bool isBlendingEnabled() const pure nothrow {
		return this._isBlending;
	}
	
	/**
	 * Set the Blendmode.
	 */
	void setBlendMode(BlendMode mode) {
		this._blendMode = mode;
	}
	
	/**
	 * Returns the current Blendmode.
	 */
	BlendMode getBlendMode() const pure nothrow {
		return this._blendMode;
	}
	
	/**
	 * Set the Blend Color.
	 */
	void setBlendColor(ref const Color col) {
		this._isBlendColor = true;
		this._blendColor = col;
	}
	
	/**
	 * Rvalue version
	 */
	void setBlendColor(const Color col) {
		this.setBlendColor(col);
	}
	
	/**
	 * Returns the current Blend Color.
	 */
	ref const(Color) getBlendColor() const pure nothrow {
		return this._blendColor;
	}
	
	/**
	 * Activate or deactivate the using of the Blend color.
	 */
	void enableBlendColor(bool enable) {
		this._isBlendColor = enable;
	}
	
	/**
	 * Returns, if using blend color is activated, or not.
	 */
	bool isBlendColorEnabled() const pure nothrow {
		return this._isBlendColor;
	}
}