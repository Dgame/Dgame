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
module Dgame.Graphics.TileMap;

private {
	import std.xml : Document, Element;
	import std.file : read;
	import std.conv : to;
	import std.string : format;
	import std.math : log2, pow, round, ceil, floor, fmax;
	
	import derelict.opengl3.gl;
	import derelict.sdl2.sdl;

	import Dgame.Internal.Array;
	
	import Dgame.Math.Vector2;
	import Dgame.Math.Rect;
	import Dgame.Math.VecN;
	
	import Dgame.Graphics.Drawable;
	import Dgame.Graphics.Surface;
	import Dgame.Graphics.Texture;
	import Dgame.Graphics.Transform;
	import Dgame.System.VertexBufferObject;
}

/**
 * This structure stores information about the tile map properties
 */
struct TileMapInfo {
public:
	/**
	 * The map width in pixel
	 */
	ushort width;
	/**
	 * The map height in pixel
	 */
	ushort height;
	/**
	 * The map size.
	 * index 0 is width / tileWidth and index 1 is height / tileHeight
	 */
	ushort[2] mapSize;
	/**
	 * The tile width in pixel (for example: 16, 32, 64)
	 */
	ubyte tileWidth;
	/**
	 * The tile height in pixel
	 */
	ubyte tileHeight;
	/**
	* The map filename
	*/
	string source;
}

/**
 * The Tile structure contains informations about every tile on the map
 */
struct Tile {
public:
	/**
	 * The gid is the Tile id.
	 * It contains the positions of this tile on the tileset.
	 * ----
	 * const uint tilesPerRow = mapWidth / tileWidth;
	 * 
	 * uint y = gid / tilesPerRow;
	 * uint x = gid % tilesPerRow;
	 * ----
	 */
	const ushort gid;
	/**
	 * The layer of the tile, if any
	 */
	string layer;
	/**
	 * The coordinates in pixel of this tile on the map
	 */
	const ushort[2] pixelCoords;
	/**
	 * The coordinates of this tile on the map
	 */
	const ushort[2] tileCoords;
	
	void opAssign(ref const Tile t) nothrow {
		.memcpy(&this, &t, Tile.sizeof);
	}
	
	void opAssign(const Tile t) nothrow {
		this.opAssign(t);
	}
}

struct SubSurface {
public:
	Surface clip;
	ushort gid;
}

ushort roundToNext2Pot(ushort dim) {
	float l = log2(dim);
	
	return cast(ushort) pow(2, round(l));
} unittest {
	assert(roundToNext2Pot(512) == 512);
	assert(roundToNext2Pot(832) == 1024);
}

ushort calcDim(size_t tileNum, ubyte tileDim) {
	if (tileDim == 0)
		return 0;
	if (tileNum == 0)
		return 0;
	if (tileNum == 1)
		return tileDim;
	if (tileNum >= ubyte.max)
		throw new Exception("Too large dimensions");
	
	ubyte dim1 = cast(ubyte) tileNum;
	ubyte dim2 = 1;
	
	while (dim1 > dim2) {
		dim1 = cast(ubyte) ceil(dim1 / 2f);
		dim2 *= 2;
	}
	///debug writeln("TileNum: ", tileNum, " - Dim1: ", dim1, " - Dim2: ", dim2);
	version (none) {
		return roundToNext2Pot(dim1);
	} else {
		return cast(ushort)(fmax(dim1, dim2) * tileDim);
	}
} unittest {
	assert(calcDim(14 , 16) == 64);
	assert(calcDim(2  , 16) == 32);
	assert(calcDim(0  , 16) == 0);
	assert(calcDim(1  , 16) == 16);
	assert(calcDim(4  , 16) == 32);
	assert(calcDim(28 , 16) == 128);
	assert(calcDim(100, 16) == 256);
	assert(calcDim(96 , 16) == 256);
	assert(calcDim(63 , 16) == 128);
	assert(calcDim(65 , 16) == 256);
	assert(calcDim(46 , 16) == 128);
}

short[2] calcPos(ushort gid, ushort width, ushort tw, ushort th) pure nothrow {
	uint tilesPerRow = width / tw;
	
	uint y = gid / tilesPerRow;
	uint x = gid % tilesPerRow;
	
	if (x)
		x -= 1;
	else {
		y -= 1;
		x = tilesPerRow - 1;
	}
	
	return [cast(ushort)(x * tw), cast(ushort)(y * th)];
} unittest {
	assert(calcPos(109, 832, 16, 16) == [4 * 16, 2 * 16]);
}

/**
 * The Tile map consist of tiles which are stored in a XML file (preferably build with tiled)
 *
 * Author: rschuett
 */
class TileMap : Drawable {
private:
	void _readTileMap() {
		Document doc = new Document(cast(string) .read(this._filename));
		
		array!vec3f vertices;
		
		foreach (const Element elem; doc.elements) {
			if (elem.tag.name == "tileset") {
				this._tmi.source = elem.elements[0].tag.attr["source"];
				
				this._tmi.tileWidth = to!ubyte(elem.tag.attr["tilewidth"]);
				this._tmi.tileHeight = to!ubyte(elem.tag.attr["tileheight"]);
			}
			
			if (elem.tag.name == "layer") {
				if (!this._tmi.width) {
					this._tmi.width  = to!ushort(elem.tag.attr["width"]);
					this._tmi.height = to!ushort(elem.tag.attr["height"]);
					
					if (vertices.length != 0)
						throw new Exception("Wrong format.");
					
					const size_t cap = vertices.reserve(this._tmi.width * this._tmi.height * 4);
					debug writefln("TileMap: Reserve %d vertices.", cap);
				}
				
				ushort row, col;
				foreach (const Element child; elem.elements[0].elements) {
					ushort gid = to!ushort(child.tag.attr["gid"]);
					
					float vx = col * this._tmi.tileWidth;
					float vy = row * this._tmi.tileHeight;
					
					this._tiles ~= Tile(gid, elem.tag.attr["name"],
					                    [cast(ushort) vx, cast(ushort) vy],
					                    [col, row]);
					
					float vw = this._tmi.tileWidth;
					float vh = this._tmi.tileHeight;
					
					vertices ~= vec3f(vx, vy, 0f); /// #1
					vertices ~= vec3f(vx + vw, vy, 0f); /// #2
					vertices ~= vec3f(vx, vy + vh, 0f); /// #3
					vertices ~= vec3f(vx + vw, vy + vh, 0f); /// #4
					
					col++;
					if (col >= this._tmi.width) {
						col = 0;
						row++;
					}
				}
			}
		}
		
		debug writefln("TileMap: Needed %d vertices.", vertices.length);
		
		/// Store the map size
		this._tmi.mapSize[0] = this._tmi.width;
		this._tmi.mapSize[1] = this._tmi.height;
		
		/// Adjust to real size in pixel
		this._tmi.width *= this._tmi.tileWidth;
		this._tmi.height *= this._tmi.tileHeight;
		
		this._vbo.bind(Primitive.Target.Vertex);
		
		if (!this._vbo.isCurrentEmpty())
			this._vbo.modify(&vertices[0], vertices.length * vec3f.sizeof);
		else
			this._vbo.cache(&vertices[0], vertices.length * vec3f.sizeof);
		
		this._vbo.unbind();
		
		this._loadTileset();
	}
	
	void _loadTileset() in {
		assert(this._tmi.tileWidth == this._tmi.tileHeight, "Tile dimensions must be equal.");
	} body {
		SubSurface[] subs;
		
		short[2][ushort] used;
		short[2]*[] coordinates;
		
		//uint doubly = 0;
		
		Surface tileset = Surface(this._tmi.source);
		ShortRect src = ShortRect(0, 0, this._tmi.tileWidth, this._tmi.tileHeight);
		
		/// Sammeln der Tiles, die wirklich benötigt werden
		foreach (ref const Tile t; this._tiles) {
			if (t.gid !in used) {
				used[t.gid] = calcPos(t.gid, tileset.width,
				                      this._tmi.tileWidth, this._tmi.tileHeight);
				if (this._doCompress) {
					src.setPosition(used[t.gid]);
					subs ~= SubSurface(tileset.subSurface(src), t.gid);
				}
			}/* else
				doubly++;*/
			
			coordinates ~= &used[t.gid];
		}
		
		//writefln("%d are double used and we need %d tiles and have %d.", doubly, used.length, subs.length);

		this._compress(tileset, used, subs);
		this._loadTexCoords(coordinates);
	}
	
	void _compress(ref Surface tileset, short[2][ushort] used, SubSurface[] subs) {
		if (this._doCompress) {
			const ushort dim = calcDim(used.length, this._tmi.tileWidth);
			
			Surface newTileset = Surface.make(dim, dim, 32);
			ShortRect src = ShortRect(0, 0, this._tmi.tileWidth, this._tmi.tileHeight);
			
			ushort row = 0;
			ushort col = 0;
			
			/// Anpassen der Tile Koordinaten
			//int c = 0;
			foreach (ref SubSurface sub; subs) {
				if (!newTileset.blit(sub.clip, null, &src)) {
					throw new Exception("An error occured by blitting the tile on the new tileset: "
										~ to!string(SDL_GetError()));
				}
				
				used[sub.gid][0] = col;
				used[sub.gid][1] = row;
				
				col += this._tmi.tileWidth;
				if (col >= dim) {
					col = 0;
					row += this._tmi.tileHeight;
				}
				
				//sub.clip.saveToFile("tile_" ~ to!string(c) ~ ".png");
				//c++;
				sub.clip.free(); // Free subsurface
				src.setPosition(col, row);
			}
			
			//newTileset.saveToFile("new_tilset.png");
			
			Texture.Format t_fmt = Texture.Format.None;
			if (!newTileset.isMask(Surface.Mask.Red, 0x000000ff))
				t_fmt = newTileset.countBits() == 24 ? Texture.Format.BGR : Texture.Format.BGRA;
			
			this._tex.loadFromMemory(newTileset.getPixels(), newTileset.width,
			                         newTileset.height, newTileset.countBits(), t_fmt);
		} else {
			//tileset.saveToFile("new_tilset.png");
			
			Texture.Format t_fmt = Texture.Format.None;
			if (!tileset.isMask(Surface.Mask.Red, 0x000000ff))
				t_fmt = tileset.countBits() == 24 ? Texture.Format.BGR : Texture.Format.BGRA;
			
			this._tex.loadFromMemory(tileset.getPixels(), tileset.width,
			                         tileset.height, tileset.countBits(), t_fmt);
		}
	}
	
	void _loadTexCoords(short[2]*[] coordinates) {
		/// Sammeln der Textur Koordinaten
		array!vec2f texCoords;
		texCoords.reserve(coordinates.length * 4);
		
		debug writefln("TileMap: Reserve %d texCoords (%d).",
		               texCoords.capacity, coordinates.length * 4);
		
		const float tsw = this._tex.width;
		const float tsh = this._tex.height;
		
		const float tw = this._tmi.tileWidth;
		const float th = this._tmi.tileHeight;
		
		foreach (nr, short[2]* tc; coordinates) {
			float tx = (*tc)[0];
			float ty = (*tc)[1];
			
			texCoords ~= vec2f(tx > 0 ? (tx / tsw) : tx, ty > 0 ? (ty / tsh) : ty); /// #1
			texCoords ~= vec2f((tx + tw) / tsw,  ty > 0 ? (ty / tsh) : ty); /// #2
			texCoords ~= vec2f(tx > 0 ? (tx / tsw) : tx, (ty + th) / tsh); /// #3
			texCoords ~= vec2f((tx + tw) / tsw, (ty + th) / tsh); /// #4
		}
		
		debug writefln("TileMap: Needed %d texCoords.", texCoords.length);
		
		this._vbo.bind(Primitive.Target.TexCoords);
		
		if (!this._vbo.isCurrentEmpty())
			this._vbo.modify(&texCoords[0], texCoords.length * vec2f.sizeof);
		else
			this._vbo.cache(&texCoords[0], texCoords.length * vec2f.sizeof);
		
		this._vbo.unbind();
	}
	
protected:
	void _render() in {
		assert(this._transform !is null, "Transform is null.");
	} body {
		if (!glIsEnabled(GL_TEXTURE_2D))
			glEnable(GL_TEXTURE_2D);

		glPushAttrib(GL_ENABLE_BIT);
		scope(exit) glPopAttrib();
		
		glPushMatrix();
		scope(exit) glPopMatrix();
		
		glDisable(GL_BLEND);
		scope(exit) glEnable(GL_BLEND);
		
		this._transform.applyViewport();
		this._transform.applyTranslation();
		
		this._vbo.bindTexture(this._tex);
		this._vbo.drawArrays(Primitive.Type.TriangleStrip,
		                     this._tiles.length * 4);
		
		this._vbo.disableAllStates();
		this._vbo.unbind();
	}
	
private:
	TileMapInfo _tmi;
	Texture _tex;
	Transform _transform;
	
	Tile[] _tiles;
	
	string _filename;
	bool _doCompress;
	
	VertexBufferObject _vbo;
	
public:
final:
	/**
	 * CTor
	 * 
	 * If compress is true, only the needed Tiles are stored
	 * (which means that are new tileset is created which contains only the needed tiles)
	 * otherwise the whole tileset is taken.
	 */
	this(string filename, bool compress = true) {
		this._tex = new Texture();
		this._vbo = new VertexBufferObject(Primitive.Target.Vertex | Primitive.Target.TexCoords);
		
		this._transform = new Transform();

		this.load(filename, compress);
	}
	
	/**
	 * Returns the Transformation for this TileMap
	 */
	inout(Transform) getTransform() inout pure nothrow {
		return this._transform;
	}
	
	/**
	 * Set a (new) Trandformation.
	 */
	void setTransform(ref Transform tf) {
		this._transform = tf;
	}
	
	/**
	 * Load a new TileMap
	 */
	void load(string filename, bool compress = true) {
		if (!exists(filename))
			throw new Exception("Could not find tilemap " ~ filename);

		this._filename = filename;
		this._doCompress = compress;
		
		this._vbo.depleteAll();
		
		if (this._tiles.length != 0) {
			.destroy(this._tmi);
			.destroy(this._tiles);
		}
		
		this._readTileMap();

		// Area Size
		this._transform._setAreaSize(this._tmi.width, this._tmi.height);
	}
	
	/**
	 * If compress is true, only the needed Tiles are stored
	 * (which means that are new tileset is created which contains only the needed tiles)
	 * otherwise the whole tileset is taken.
	 */
	@property
	bool doCompress() const pure nothrow {
		return this._doCompress;
	}
	
	/**
	 * Convert from pixel coordinates to tile coordinates.
	 */
	short[2] convertCoords(T)(T cx, T cy) const {
		short x = cx >= this._tmi.tileWidth  ? cast(short) .round(cx / this._tmi.tileWidth)  : 0;
		short y = cy >= this._tmi.tileHeight ? cast(short) .floor(cy / this._tmi.tileHeight) : 0;
		
		return [x, y];
	}
	
	/**
	 * Convert from pixel coordinates to tile coordinates.
	 */
	short[2] convertCoords(T)(ref const Vector2!T vec) const {
		return this.convertCoords(vec.x, vec.y);
	}
	
	/**
	 * Convert from pixel coordinates to tile coordinates.
	 */
	short[2] convertCoords(T)(T[2] coords) const {
		return this.convertCoords(coords[0], coords[1]);
	}
	
	/**
	 * Convert from tile coordinates to pixel coordinates.
	 */
	short[2] reconvertCoords(T)(T cx, T cy) const {
		short x = cx != 0 ? cast(short) round(cx * this._tmi.tileWidth)  : 0;
		short y = cy != 0 ? cast(short) floor(cy * this._tmi.tileHeight) : 0;
		
		return [x, y];
	}
	
	/**
	 * Convert from tile coordinates to pixel coordinates.
	 */
	short[2] reconvertCoords(T)(ref const Vector2!T vec) const {
		return this.reconvertCoords(vec.x, vec.y);
	}
	
	/**
	 * Convert from tile coordinates to pixel coordinates.
	 */
	short[2] reconvertCoords(T)(T[2] coords) const {
		return this.reconvertCoords(coords[0], coords[1]);
	}
	
	/**
	 * Adjusted pixel coordinates so that they lie on valid pixel
	 * coordinates based on tile coordinates.
	 */
	short[2] adjustCoords(T)(T cx, T cy) const {
		short[2] convCoords = this.convertCoords(cx, cy);
		
		return this.reconvertCoords(convCoords);
	}
	
	/**
	 * Adjusted pixel coordinates so that they lie on valid pixel coordinates
	 * based on tile coordinates.
	 */
	short[2] adjustCoords(T)(ref const Vector2!T vec) const {
		return this.adjustCoords(vec.x, vec.y);
	}
	
	/**
	 * Adjusted pixel coordinates so that they lie 
	 * on valid pixel coordinates based on tile coordinates.
	 */
	short[2] adjustCoords(T)(T[2] coords) const {
		return this.adjustCoords(coords[0], coords[1]);
	}
	
	/**
	 * Reload multiple tiles.
	 * The length of coords must be equal to the length of newCoords.
	 * 
	 * See: reload for one tile
	 */
	void reload(const Vector2s[] coords, const Vector2s[] newCoords) in {
		assert(coords.length == newCoords.length, "Koordinaten Arrays must have a equal length.");
	} body {
		this._vbo.bind(Primitive.Target.TexCoords);
		scope(exit) this._vbo.unbind();
		
		float* buffer = cast(float*) this._vbo.map(VertexBufferObject.Access.Read);
		this._vbo.unmap();
		
		foreach (uint index, ref const Vector2s coord; coords) {
			uint srcGid = coord.x * (coord.y + 1) + coord.y;
			srcGid *= 8;
			uint dstGid = newCoords[index].x * (newCoords[index].y + 1) + newCoords[index].y;
			dstGid *= 8;
			
			buffer[srcGid .. srcGid + 8] = buffer[dstGid .. dstGid + 8];
			
			this.replaceTileAt(coord, this.getTileAt(newCoords[index]));
		}
	}
	
	/**
	 * Replace multiple tiles with another.
	 */
	void reload(const Vector2s[] coords, ref const Vector2s newCoord) {
		const Tile tile = this.getTileAt(newCoord);
		
		foreach (ref const Vector2s coord; coords) {
			this.reload(coord, newCoord);
			this.replaceTileAt(coord, tile);
		}
	}
	
	/**
	 * Rvalue version
	 */
	void reload(const Vector2s[] coords, const Vector2s newCoord) {
		this.reload(coords, newCoord);
	}
	
	/**
	 * Reload one tile, which means that the tile on the coordinates coord 
	 * is replaced with the tile (and the tile surface) on the coordinates newCoord
	 */
	void reload(ref const Vector2s coord, ref const Vector2s newCoord) {
		this._vbo.bind(Primitive.Target.TexCoords);
		scope(exit) this._vbo.unbind();
		
		float* buffer = cast(float*) this._vbo.map(VertexBufferObject.Access.Read);
		this._vbo.unmap();
		
		uint srcGid = coord.x * (coord.y + 1) + coord.y;
		srcGid *= 8;
		uint dstGid = newCoord.x * (newCoord.y + 1) + newCoord.y;
		dstGid *= 8;
		
		buffer[srcGid .. srcGid + 8] = buffer[dstGid .. dstGid + 8];
		
		this.replaceTileAt(coord, this.getTileAt(newCoord));
	}
	
	/**
	 * Rvalue version
	 */
	void reload(const Vector2s coord, const Vector2s newCoord) {
		this.reload(coord, newCoord);
	}
	
	/**
	 * Exchange the tileset
	 */
	void exchangeTileset(Texture tex) {
		this._tex = null;
		this._tex = tex;
	}
	
	/**
	 * Returns all containing tiles
	 */
	inout(Tile[]) getTiles() inout {
		return this._tiles;
	}
	
	/**
	 * Check whether a tile exist on the given Coordinates.
	 * If idx isn't null, the calculated index of the Tile at the given position is stored there.
	 * 
	 * Note: The position must be in tile coordinates, not pixel coordinates.
	 */
	bool isTileAt(ref const Vector2s vec, uint* idx = null) const pure nothrow {
		return this.isTileAt(vec.x, vec.y, idx);
	}
	
	/**
	 * Check whether a tile exist on the given Coordinates.
	 * If idx isn't null, the calculated index of the Tile at the given position is stored there.
	 * 
	 * Note: The position must be in tile coordinates, not pixel coordinates.
	 */
	bool isTileAt(short[2] tilePos, uint* idx = null) const pure nothrow {
		return this.isTileAt(tilePos[0], tilePos[1], idx);
	}
	
	/**
	 * Check whether a tile exist on the given Coordinates.
	 * If idx isn't null, the calculated index of the Tile at the given position is stored there.
	 * 
	 * Note: The position must be in tile coordinates, not pixel coordinates.
	 */
	bool isTileAt(short x, short y, uint* idx = null) const pure nothrow {
		uint index = y * this._tmi.mapSize[0] + x;
		if (idx)
			*idx = index;
		
		return index < this._tiles.length;
	}
	
	/**
	 * Replace the tile at the given position with the given new Tile.
	 * If oldtile is not null, the former Tile is stored there.
	 * 
	 * Note: This method is designated as helper method for reload
	 * Note: The position must be in tile coordinates, not pixel coordinates.
	 */
	void replaceTileAt(ref const Vector2s vec, ref const Tile newTile, Tile* oldTile = null) {
		this.replaceTileAt(vec.x, vec.y, newTile, oldTile);
	}
	
	/**
	 * Replace the tile at the given position with the given new Tile.
	 * If oldtile is not null, the former Tile is stored there.
	 * 
	 * Note: This method is designated as helper method for reload
	 * Note: The position must be in tile coordinates, not pixel coordinates.
	 */
	void replaceTileAt(short[2] tilePos, ref const Tile newTile, Tile* oldTile = null) {
		this.replaceTileAt(tilePos[0], tilePos[1], newTile, oldTile);
	}
	
	/**
	 * Replace the tile at the given position with the given new Tile.
	 * If oldtile is not null, the former Tile is stored there.
	 * 
	 * Note: This method is designated as helper method for reload
	 * Note: The position must be in tile coordinates, not pixel coordinates.
	 */
	void replaceTileAt(short x, short y, ref const Tile newTile, Tile* oldTile = null) {
		uint index = 0;
		
		if (this.isTileAt(x, y, &index)) {
			if (oldTile)
				.memcpy(oldTile, &this._tiles[index], Tile.sizeof);
			
			this._tiles[index] = newTile;
		}
	}
	
	/**
	 * Returns the tile at the given position, or throw an Exception
	 * Note: The position must be in tile coordinates, not pixel coordinates.
	 */
	ref const(Tile) getTileAt(ref const Vector2s vec) const {
		return this.getTileAt(vec.x, vec.y);
	}
	
	/**
	 * Returns the tile at the given position, or throw an Exception
	 * 
	 * Note: The position must be in tile coordinates, not pixel coordinates.
	 * Note: This function is fast and takes ~ O(1) for a lookup.
	 */
	ref const(Tile) getTileAt(short[2] tilePos) const {
		return this.getTileAt(tilePos[0], tilePos[1]);
	}
	
	/**
	 * Returns the tile at the given position, or throw an Exception
	 * Note: The position must be in tile coordinates, not pixel coordinates.
	 */
	ref const(Tile) getTileAt(short x, short y) const {
		uint index = 0;
		if (!this.isTileAt(x, y, &index))
			throw new Exception(.format("No Tile at position %d:%d", x, y));
		
		return this._tiles[index];
	}
	
	/**
	 * Returns the information structure of this tilemap
	 */
	ref const(TileMapInfo) getInfo() const pure nothrow {
		return this._tmi;
	}
	
	/**
	 * Returns the .xml filename of this tilemap
	 */
	string getFilename() const pure nothrow {
		return this._filename;
	}
}