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
module Dgame.Graphics.Image;

private {
	import Dgame.Graphics.Surface;
	import Dgame.Graphics.Color;
	import Dgame.Math.Rect;
}

public import Dgame.Graphics.Texture;

/**
 * Image is the class for loading and manipulating images.
 * It extends Texture of the feature to load images by filename 
 * and save the (current) image into a file.
 *
 * Author: rschuett
 */
class Image : Texture {
public:
final:
	/**
	 * CTor
	 */
	this() {
		super();
	}

	/**
	 * CTor
	 */
	this(string filename, Texture.Format t_fmt = Texture.Format.None) {
		this.loadFromFile(filename, t_fmt);
	}

	/**
	 * CTor
	 */
	this(ref const Texture tex, Texture.Format t_fmt = Texture.Format.None) {
		super(tex, t_fmt);
	}
	
	/**
	 * CTor
	 */
	this(ref Surface srfc, Texture.Format t_fmt = Texture.Format.None) {
		if (t_fmt == Texture.Format.None
	   		&& !srfc.isMask(Surface.Mask.Red, 0x000000ff))
		{
			t_fmt = srfc.bits == 24 ? Texture.Format.BGR : Texture.Format.BGRA;
		}
	
		super.loadFromMemory(srfc.pixels, srfc.width, srfc.height, srfc.bits, t_fmt);
	}
	
	/**
	 * Load the image from filename with a colorkey.
	 */
	void loadFromFile(string filename, ref const Color colorkey, Texture.Format t_fmt = Texture.Format.None) {
		Surface img = Surface(filename);
		img.setColorkey(colorkey);
	
		super.loadFromMemory(img.pixels, img.width, img.height, img.bits, t_fmt);
	}
	
	/**
	 * Rvalue version
	 */
	void loadFromFile(string filename, const Color colorkey, Texture.Format t_fmt = Texture.Format.None) {
		this.loadFromFile(filename, colorkey, t_fmt);
	}
	
	/**
	 * Load the image from filename.
	 */
	void loadFromFile(string filename, Texture.Format t_fmt = Texture.Format.None) {
		Surface img = Surface(filename);
		enforce(img.pixels !is null, "Cannot load image with no memory.");
		super.loadFromMemory(img.pixels, img.width, img.height, img.bits, t_fmt);
	}
	
	/**
	 * Save the (current) image into filename.
	 */
	void saveToFile(string filename) {
		void* mem = super.getMemory();
		enforce(mem !is null, "Cannot save image with no memory.");

		Surface img = Surface.make(mem, super.width, super.height, super.depth);
		img.saveToFile(filename);
	}
	
	/**
	 * Alias for subTexture.
	 */
	alias subImage = subTexture;
}

