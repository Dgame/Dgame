module Dgame.System.FrameBufferObject;

private {
	import derelict.opengl3.gl;

	import Dgame.Internal.core;
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
final class FrameBufferObject {
private:
	GLuint _fboId;
	GLuint _depthBuffer;

	Texture _tex;

public:
	/**
	 * CTor with a Texture and the boolean flag if you want a depthBuffer
	 */
	this(Texture tex, bool depthBuffer = false) in {
		assert(tex !is null && tex.isValid());
	} body {
		glCheck(glGenFramebuffers(1, &this._fboId));
		if (!this._fboId)
			throw new Exception("Failed to create the frame buffer object");

		glCheck(glBindFramebuffer(GL_FRAMEBUFFER, this._fboId));

		if (depthBuffer) {
			glCheck(glGenRenderbuffers(1, &this._depthBuffer));
			if (!this._depthBuffer)
				throw new Exception("Failed to create the attached depth buffer");

			glCheck(glBindRenderbuffer(GL_RENDERBUFFER, this._depthBuffer));
			glCheck(glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, tex.width, tex.height));
			glCheck(glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
												 GL_RENDERBUFFER, this._depthBuffer));
		}

		this.setTexture(tex);
	}

	~this() {
		if (this._depthBuffer != 0)
			glCheck(glDeleteRenderbuffers(1, &this._depthBuffer));

		glCheck(glDeleteFramebuffers(1, &this._fboId));
	}

	/**
	 * Set a new Texture to the FBO which is now the new render target.
	 */
	void setTexture(Texture tex) in {
		assert(tex !is null && tex.isValid());
	} body {
		this.bind();
		scope(exit) this.unbind();

		glCheck(glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex.Id, 0));

		if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
			glCheck(glBindFramebuffer(GL_FRAMEBUFFER, 0));

			throw new Exception("Failed to link the target texture to the frame buffer");
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
		glCheck(glBindFramebuffer(GL_FRAMEBUFFER, this._fboId));
	}

	/**
	* Unbind the current FBO. This is mostly done automatically.
	*/
	void unbind() const {
		glCheck(glBindFramebuffer(GL_FRAMEBUFFER, 0));
	}
}