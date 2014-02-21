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
module Dgame.System.FrameBufferObject;

private {
	import derelict.opengl3.gl;

	import Dgame.Internal.Log;
	import Dgame.Graphics.Drawable;
	import Dgame.Graphics.Texture;
}

/**
 * A FrameBufferObject is usefull if you want to blit Drawables on a Texture.
 * You create an FBO, set an Image/Texture to it and draw what you want.
 * After drawing it is on your Texture.
 *
 * Author: rschuett
 */
class FrameBufferObject {
private:
	GLuint _fboId;
	GLuint _depthBuffer;

	Texture _tex;

public:
final:
	/**
	 * CTor with a Texture and the boolean flag if you want a depthBuffer
	 */
	this(Texture tex, bool depthBuffer = false) in {
		assert(tex !is null && tex.isValid());
	} body {
		glGenFramebuffers(1, &this._fboId);
		if (!this._fboId)
			Log.error("Failed to create the frame buffer object.");

		glBindFramebuffer(GL_FRAMEBUFFER, this._fboId);

		if (depthBuffer) {
			glGenRenderbuffers(1, &this._depthBuffer);
			if (!this._depthBuffer)
				Log.error("Failed to create the attached depth buffer.");

			glBindRenderbuffer(GL_RENDERBUFFER, this._depthBuffer);
			glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, tex.width, tex.height);
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, this._depthBuffer);
		}

		this.setTexture(tex);
	}

	~this() {
		if (this._depthBuffer != 0)
			glDeleteRenderbuffers(1, &this._depthBuffer);
		glDeleteFramebuffers(1, &this._fboId);
	}

	/**
	 * Set a new Texture to the FBO which is now the new render target.
	 */
	void setTexture(Texture tex) in {
		assert(tex !is null && tex.isValid());
	} body {
		this.bind();
		scope(exit) this.unbind();

		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex.Id, 0);

		if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
			glBindFramebuffer(GL_FRAMEBUFFER, 0);
			Log.error("Failed to link the target texture to the frame buffer.");
		}

		this._tex = tex;
	}

	/**
	 * Clears the content of the FBO.
	 */
	void clear() const {
		this.bind();
		scope(exit) this.unbind();

		glClear(GL_COLOR_BUFFER_BIT);
	}

	/**
	 * Draw a Drawable on the current render target
	 */
	void draw(Drawable draw) in {
		assert(draw !is null);
		assert(this._tex !is null && this._tex.isValid());
	} body {
		this.bind();
		scope(exit) this.unbind();

		glPushAttrib(GL_VIEWPORT_BIT | GL_CURRENT_BIT | GL_ENABLE_BIT);
		glPushMatrix();

		glDisable(GL_TEXTURE_2D);

		scope(exit) {
			glPopAttrib();
			glPopMatrix();
		}

		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();

		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();

		glViewport(0, 0, this._tex.width, this._tex.height);
		glOrtho(0, this._tex.width, this._tex.height, 0, 1, -1);

		draw.render();
	}

	/**
	 * Bind the current FBO. This is mostly done automatically.
	 */
	void bind() const {
		glBindFramebuffer(GL_FRAMEBUFFER, this._fboId);
	}

	/**
	* Unbind the current FBO. This is mostly done automatically.
	*/
	void unbind() const {
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
	}
}