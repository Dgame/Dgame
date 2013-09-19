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
			t_fmt = srfc.countBits() == 24 ? Texture.Format.BGR : Texture.Format.BGRA;
		}
		
		super.loadFromMemory(srfc.getPixels(), srfc.width, srfc.height,
		                     srfc.countBits(), t_fmt);
	}
	
	/**
	 * CTor
	 */
	this(string filename, Texture.Format t_fmt = Texture.Format.None) {
		this.loadFromFile(filename, t_fmt);
	}
	
	/**
	 * Load the image from filename with a colorkey.
	 */
	void loadFromFile(string filename, ref const Color colorkey,
	                  Texture.Format t_fmt = Texture.Format.None)
	{
		Surface img = Surface(filename);
		img.setColorkey(colorkey);
		
		super.loadFromMemory(img.getPixels(), img.width, img.height, 32, t_fmt);
	}
	
	/**
	 * Rvalue version
	 */
	void loadFromFile(string filename, const Color colorkey,
	                  Texture.Format t_fmt = Texture.Format.None)
	{
		this.loadFromFile(filename, colorkey, t_fmt);
	}
	
	/**
	 * Load the image from filename.
	 */
	void loadFromFile(string filename,
	                  Texture.Format t_fmt = Texture.Format.None)
	{
		Surface img = Surface(filename);
		
		super.loadFromMemory(img.getPixels(), img.width, img.height, 32, t_fmt);
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
}