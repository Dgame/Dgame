module Dgame.Graphics.TileMap;

private {
	debug import std.stdio;
	import std.xml;
	import std.file : read;
	import std.conv : to;
	import std.math : log2, pow, round, ceil, fmax;
	import std.algorithm : canFind;
	
	import derelict.opengl.gltypes;
	
	import Dgame.Math.Rect;
	import Dgame.Graphics.Drawable;
	import Dgame.Graphics.Color;
	import Dgame.Graphics.Surface;
	import Dgame.Graphics.Texture;
	import Dgame.System.Buffer;
	import Dgame.Graphics.Interface.Transformable;
}

/**
 * This structure stores information about the tile map properties
 */
struct TileMapInfo {
public:
	/**
	 * The map filename
	 */
	string source;
	/**
	 * The map width in pixel
	 */
	ushort width;
	/**
	 * The map height in pixel
	 */
	ushort height;
	/**
	 * The tile width in pixel (for example: 16, 32, 64)
	 */
	ubyte tileWidth;
	/**
	 * The tile height in pixel
	 */
	ubyte tileHeight;
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
	const ushort[2] pixelCoords;/// = void;
	
	/**
	 * CTor
	 */
	this(ushort gid, string layer, ushort tx, ushort ty) {
		this.gid = gid;
		this.layer = layer;
		
		this.pixelCoords[0] = tx;
		this.pixelCoords[1] = ty;
	}
}

struct Sub {
public:
	Surface srfc;
	ushort gid;
}

ushort roundToNext2Pot(ushort dim) {
	float l = log2(dim);
	
	return cast(ushort) pow(2, round(l));
} unittest {
	assert(roundToNext2Pot(512) == 512);
	assert(roundToNext2Pot(832) == 1024);
}

ushort calcDim(uint tileNum, ubyte tileDim) {
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
	debug writeln("TileNum: ", tileNum, " - Dim1: ", dim1, " - Dim2: ", dim2);
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

ushort[2] calcPos(ushort gid, ushort width, ushort tw, ushort th) pure nothrow {
	const uint tilesPerRow = width / tw;
	
	uint y = gid / tilesPerRow;
	uint x = gid % tilesPerRow;
	
	if (x != 0)
		x--;
	
	return [cast(ushort)(x * tw), cast(ushort)(y * th)];
} unittest {
	assert(calcPos(109, 832, 16, 16) == [4 * 16, 2 * 16]);
}

/**
 * The Tile map consist of tiles which are stored in a XML file (preferably build with tiled)
 *
 * author: rschuett
 */
class TileMap : Drawable, Transformable {
protected:
	void _readTileMap() {
		Document doc = new Document(cast(string) read(this._filename));
		
		float[] vertices;
		
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
				}
				
				ushort row, col;
				foreach (const Element child; elem.elements[0].elements) {
					ushort gid = to!ushort(child.tag.attr["gid"]);
					
					float vx = col * this._tmi.tileWidth;
					float vy = row * this._tmi.tileHeight;
					
					this._tiles ~= Tile(gid, elem.tag.attr["name"], cast(ushort) vx, cast(ushort) vy);
					
					float vw = this._tmi.tileWidth;
					float vh = this._tmi.tileHeight;
					
					vertices ~= [vx, vy, 0f];		 	/// #1
					vertices ~= [vx + vw, vy, 0f]; 		/// #2
					vertices ~= [vx + vw, vy + vh, 0f]; /// #4
					vertices ~= [vx, vy + vh, 0f]; 		/// #3
					
					col++;
					if (col >= this._tmi.width) {
						col = 0;
						row++;
					}
				}
			}
		}
		
		/// Adjust to real size in pixel
		this._tmi.width *= this._tmi.tileWidth;
		this._tmi.height *= this._tmi.tileHeight;
		
		this._buf.bind(Buffer.Target.Vertex);
		
		if (!this._buf.isEmpty())
			this._buf.modify(&vertices[0], vertices.length * float.sizeof);
		else
			this._buf.cache(&vertices[0], vertices.length * float.sizeof);
		
		this._buf.unbind();
		
		this._vCount = vertices.length;
		
		this._loadTileset();
	}
	
	void _loadTileset() {
		assert(this._tmi.tileWidth == this._tmi.tileHeight, "Tile dimensions must be equal.");
		
		Sub[] subs;
		
		ushort[2][ushort] used;
		ushort[2]*[] coordinates;
		
		uint doubly = 0;
		
		Surface tileset = Surface(this._tmi.source);
		ShortRect src = ShortRect(0, 0, this._tmi.tileWidth, this._tmi.tileHeight);
		
		/// Sammeln der Tiles, die wirklich benötigt werden
		foreach (ref const Tile t; this._tiles) {
			if (t.gid !in used) {
				used[t.gid] = calcPos(t.gid, tileset.width, this._tmi.tileWidth, this._tmi.tileHeight);
				
				src.setPosition(used[t.gid]);
				
				subs ~= Sub(tileset.subSurface(src), t.gid);
			} else
				doubly++;
			
			coordinates ~= &used[t.gid];
		}
		
		debug writefln("%d are double used and we need %d tiles and have %d.", doubly, used.length, subs.length);
		
		ushort dim = calcDim(used.length, this._tmi.tileWidth);
		
		Surface newTileset = Surface.make(dim, dim, 32);
		newTileset.fill(Color.Black); /// notwendig!
		
		src.setPosition(0, 0); /// Reset src
		
		ushort row = 0;
		ushort col = 0;
		
		/// Anpassen der Tile Koordinaten
		foreach (ref Sub sub; subs) {
			newTileset.blit(sub.srfc, null, &src);
			
			used[sub.gid][0] = col;
			used[sub.gid][1] = row;
			
			col += this._tmi.tileWidth;
			if (col >= dim) {
				col = 0;
				row += this._tmi.tileHeight;
			}
			
			sub.srfc.free(); /// Free subsurface
			src.setPosition(col, row);
		}
		
		subs = null; /// nullify subs
		
		debug newTileset.saveToFile("new_tilset.png");
		this._tex.loadFromMemory(newTileset.getPixels(), newTileset.width, newTileset.height);
		
		this._loadTexCoords(coordinates);
	}
	
	void _loadTexCoords(ushort[2]*[] coordinates) {
		/// Sammeln der Textur Koordinaten
		float[] texCoords;
		
		const float tsw = this._tex.width;
		const float tsh = this._tex.height;
		
		const float tw = this._tmi.tileWidth;
		const float th = this._tmi.tileHeight;
		
		foreach (ushort[2]* tc; coordinates) {
			float tx = (*tc)[0];
			float ty = (*tc)[1];
			
			texCoords ~= [tx != 0 ? tx / tsw : tx,
			              ty != 0 ? ty / tsh : ty]; 	/// #1
			texCoords ~= [(tx + tw) / tsw,
			              ty != 0 ? ty / tsh : ty]; 	/// #2
			texCoords ~= [(tx + tw) / tsw,
			              (ty + th) / tsh]; 			/// #4
			texCoords ~= [tx != 0 ? tx / tsw : tx,
			              (ty + th) / tsh]; 			/// #3
		}
		
		this._buf.bind(Buffer.Target.TexCoords);
		
		if (!this._buf.isEmpty())
			this._buf.modify(&texCoords[0], texCoords.length * float.sizeof);
		else
			this._buf.cache(&texCoords[0], texCoords.length * float.sizeof);
		
		this._buf.unbind();
		
		this._tCount = texCoords.length;
	}
	
	override void _render() {
		glPushMatrix();
		scope(exit) glPopMatrix();
		
		if (this._rotAngle != 0)
			glRotatef(this._rotAngle, this._rotation.x, this._rotation.y, 1);
		
		glTranslatef(super._position.x, super._position.y, 0);
		
		if (!this._scale.x != 1.0 && this._scale.y != 1.0)
			glScalef(this._scale.x, this._scale.y, 0);
		
		this._buf.pointTo(Buffer.Target.TexCoords);
		this._buf.pointTo(Buffer.Target.Vertex);
		
		this._tex.bind();
		
		this._buf.drawArrays(GL_QUADS, this._vCount);
		
		this._buf.disableAllStates();
		this._buf.unbind();
	}
	
private:
	TileMapInfo _tmi;
	Texture _tex;
	
	Tile[] _tiles;
	
	string _filename;
	
	uint _vCount;
	uint _tCount;
	
	Buffer _buf;
	
public:
	/// mixin transformable functionality
	mixin TTransformable;
	
	/**
	 * CTor
	 */
	this(string filename) {
		this._filename = filename;
		
		this._tex = new Texture();
		this._buf = new Buffer(Buffer.Target.Vertex | Buffer.Target.TexCoords);
		
		this._readTileMap();
	}
	
	/**
	 * Reload multiple tiles.
	 * The length of coords must be equal to the length of newCoords.
	 * 
	 * See: reload for one tile
	 */
	void reload(const Vector2s[] coords, const Vector2s[] newCoords) {
		assert(coords.length == newCoords.length, "Koordinaten Arrays must have a equal length.");
		
		this._buf.bind(Buffer.Target.TexCoords);
		scope(exit) this._buf.unbind();
		
		float[] buffer = (cast(float*) this._buf.map(Buffer.Access.Read))[0 .. this._tCount];
		this._buf.unmap();
		
		foreach (uint index, ref const Vector2s coord; coords) {
			uint srcGid = coord.x * (coord.y + 1) + coord.y;
			srcGid *= 8;
			uint dstGid = newCoords[index].x * (newCoords[index].y + 1) + newCoords[index].y;
			dstGid *= 8;
			
			buffer[srcGid .. srcGid + 8] = buffer[dstGid .. dstGid + 8];
		}
	}
	
	/**
	 * Reload one tile, which means that the tile on the coordinates coord 
	 * is replaced with the tile (and the tile surface) on the coordinates newCoord
	 */
	void reload(ref const Vector2s coord, ref const Vector2s newCoord) {
		this._buf.bind(Buffer.Target.TexCoords);
		scope(exit) this._buf.unbind();
		
		float[] buffer = (cast(float*) this._buf.map(Buffer.Access.Read))[0 .. this._tCount];
		this._buf.unmap();
		
		uint srcGid = coord.x * (coord.y + 1) + coord.y;
		srcGid *= 8;
		uint dstGid = newCoord.x * (newCoord.y + 1) + newCoord.y;
		dstGid *= 8;
		
		buffer[srcGid .. srcGid + 8] = buffer[dstGid .. dstGid + 8];
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