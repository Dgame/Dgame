module Dgame.Graphics.Spritesheet;

private {
	import Dgame.Graphics.Texture;
	import Dgame.Graphics.Sprite;
	import Dgame.Math.Rect;
}

/**
 * SpriteSheet extends Sprite and has, besides the texture, 
 * even a viewport and acts as a Texture Atlas.
 * With slideViewport the viewport slides over the current row of the texture atlas.
 * With setRow the current row can be changed (increased, decreased).
 *
 * Author: rschuett
 */
class Spritesheet : Sprite {
public:
	/**
	 * The Grid
	 */
	enum Grid {
		None = 0, /// No Grid is used
		Row = 1,  /// Only Rows are used
		Column = 2, /// Only Columns are used
		Both = Row | Column /// Both, Columns <b>and</b> Rows are used
	}
	
protected:
	ubyte _row;
	
public:
final:
	/**
	 * CTor
	 */
	this(Texture tex) {
		super(tex);
	}
	
	/**
	 * CTor
	 */
	this(Texture tex, ref const ShortRect texView) {
		this(tex);
		
		super.setTextureRect(texView);
	}
	
	/**
	 * CTor
	 * 
	 * Rvalue version
	 */
	this(Texture tex, const ShortRect texView) {
		this(tex, texView);
	}
	
	/**
	 * Returns the current row (starting value is 0)
	 */
	ubyte getRow() const pure nothrow {
		return this._row;
	}
	
	/**
	 * Set a new row.
	 * This only matters, if you slide without Grid.Column.
	 */
	void setRow(ubyte row) {
		this._row = row;
	}
	
	/**
	 * Slide/move the current Viewport of the Texture.
	 * So the next area of the Texture atlas will be drawn.
	 * With grid you can decide if both, x and y, or only one of them are updated.
	 * Default both are updated.
	 * 
	 * See: Grid
	 */
	void slideTextureRect(Grid grid = Grid.Both) in {
		assert(this._tex !is null, "No Texture.");
	} body {
		const short w = super._texView.width;
		const short h = super._texView.height;
		
		ShortRect* rect = &super._texView;

		if (!(grid & Grid.Column)) {
			// to avoid a cast...
			rect.y = this._row; rect.y *= h;
		}
		
		if (grid & Grid.Row) {
			if ((rect.x + w) < super._tex.width)
				rect.x += w;
			else
				rect.x = 0;
		}

		if (grid & Grid.Column && rect.x == 0) {
			if ((rect.y + h) < super._tex.height)
				rect.y += h;
			else
				rect.y = 0;
		}
	}
}