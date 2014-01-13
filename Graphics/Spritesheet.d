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
	enum Grid : ubyte {
		None = 0, /// No Grid is used
		Row = 1,  /// Only Rows are used
		Column = 2, /// Only Columns are used
		Both = Row | Column /// Both, Columns <b>and</b> Rows are used
	}
	
	/**
	 * Set or get the current row.
	 * This only matters, if you slide without Grid.Column.
	 */
	ubyte row;

private:
	short _loopCount;
	ushort _passedLoops;

public:
final:
	/**
	 * CTor
	 */
	this(Texture tex, short lc = -1) {
		super(tex);

		this.setLoopCount(lc);
	}

	/**
	 * CTor
	 */
	this(Texture tex, ref const ShortRect texView, short lc = -1) {
		this(tex, lc);

		super.setTextureRect(texView);
	}
	
	/**
	 * CTor
	 * 
	 * Rvalue version
	 */
	this(Texture tex, const ShortRect texView, short lc = -1) {
		this(tex, texView, lc);
	}

	/**
	 * Set the current loop count.
	 * This specif how often the whole Animation is played.
	 * A value of < 0 means: infinite playing.
	 */
	void setLoopCount(short loopCount) pure nothrow {
		this._loopCount = loopCount;
		this._passedLoops = 0;
	}

	/**
	 * Get the current loop count.
	 * This specif how often the whole Animation is played.
	 * A value of < 0 means: infinite playing.
	 */
	short getLoopCount() const pure nothrow {
		return this._loopCount;
	}

	/**
	 * Execute the animation N times where N is the number of the current loop count.
	 * If N is < 0, the animation runs infinite.
	 */
	void execute(Grid grid = Grid.Both) {
		if (this._loopCount < 0 || this._loopCount > this._passedLoops)
			this.slideTextureRect(grid);
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
		
		if ((grid & Grid.Column) == 0) {
			// to avoid a cast...
			rect.y = this.row;
			rect.y *= h;
		}
		
		if (grid & Grid.Row) {
			if ((rect.x + w) < super._tex.width)
				rect.x += w;
			else {
				rect.x = 0;

				if ((grid & Grid.Column) == 0)
					this._passedLoops++;
			}
		}
		
		if (grid & Grid.Column && rect.x == 0) {
			if ((rect.y + h) < super._tex.height)
				rect.y += h;
			else {
				rect.y = 0;

				this._passedLoops++;
			}
		}
	}
}