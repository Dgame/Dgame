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
	this(ref const Texture tex) {
		super(tex);
	}
	
	/**
	 * CTor
	 */
	this(ref Surface srfc) {
		super.loadFromMemory(srfc.getPixels(), srfc.width, srfc.height);
	}
	
	/**
	 * CTor
	 */
	this(string filename) {
		this.loadFromFile(filename);
	}
	
	/**
	 * Load the image from filename with a colorkey.
	 */
	void loadFromFile(string filename, ref const Color colorkey) {
		Surface img = Surface(filename);
		img.setColorkey(colorkey);
		
		super.loadFromMemory(img.getPixels(), img.width, img.height);
	}
	
	/**
	 * Rvalue version
	 */
	void loadFromFile(string filename, const Color colorkey) {
		this.loadFromFile(filename, colorkey);
	}
	
	/**
	 * Load the image from filename.
	 */
	void loadFromFile(string filename) {
		Surface img = Surface(filename);
		
		super.loadFromMemory(img.getPixels(), img.width, img.height);
	}
	
	/**
	 * Save the (current) image into filename.
	 */
	void saveToFile(string filename) {
		Surface.make(super.getMemory(), super.width, super.height, super.depth).saveToFile(filename);
	}
	
	/**
	 * Alias for subTexture.
	 */
	alias subImage = subTexture;
	
	/**
	 * Copy the pixel data of a Surface to this Image.
	 * The second parameter is a pointer to the destination rect.
	 * Is it is null this means the whole img is copied.
	 */
	void copy(ref const Surface img, ShortRect* rect = null) in {
		assert(super.width != 0 && super.height != 0, "width or height is 0.");
	} body {
		super.updateMemory(img.getPixels(), rect);
	}
}