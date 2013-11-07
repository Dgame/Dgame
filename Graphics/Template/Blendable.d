/*
*******************************************************************************************
* Dgame (a D game framework) - Copyright (c) Randy Schütt
* 
* This software is provided 'as-is', without any express or implied warranty.
* In no event will the authors be held liable for any damages arising from
* the use of this software.
* 
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 
* 1. The origin of this software must not be misrepresented; you must not claim
*    that you wrote the original software. If you use this software in a product,
*    an acknowledgment in the product documentation would be appreciated but is
*    not required.
* 
* 2. Altered source versions must be plainly marked as such, and must not be
*    misrepresented as being the original software.
* 
* 3. This notice may not be removed or altered from any source distribution.
*******************************************************************************************
*/
module Dgame.Graphics.Template.Blendable;

private import Dgame.Graphics.Color;

/**
 * Supported BlendModes
 */
enum BlendMode {
	None,      /** No blending. */
	Alpha,    /** Pixel = Src * a + Dest * (1 - a) */
	Add,      /** Pixel = Src + Dest */
	Multiply /** Pixel = Src * Dest */
}

enum BlendColor {
	Default,
	Color4f
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

		if (!glIsEnabled(GL_BLEND))
			glEnable(GL_BLEND);

		if (this._isBlendColor) {
			const float[4] col = this._blendColor.asGLColor();

			version(all)
				glBlendColor(col[0], col[1], col[2], col[3]);
			else
				glColor4f(col[0], col[1], col[2], col[3]);
		}

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
	* Activate or deactivate the using of the blend color.
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
	
	/**
	 * Set the Blendmode.
	 */
	void setBlendMode(BlendMode mode) {
		this._blendMode = mode;
		this._isBlending = true;
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
}