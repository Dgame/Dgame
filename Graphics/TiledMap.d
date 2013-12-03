module Dgame.Graphics.TiledMap;

private {
	import std.xml : Document, Element;
	import std.file : read;
	import std.conv : to;
	
	import Dgame.Math.Vector2;
	import Dgame.Math.Vector3;
	import Dgame.Graphics.TileMap;
	import Dgame.System.VertexBufferObject : Primitive;
	import Dgame.Internal.Log;
}

class TiledMap : TileMap {
protected:
	override void _readTileMap() {
		Document doc = new Document(cast(string) .read(this._filename));
		
		Vector3f[] vertices;
		
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
						Log.error("Wrong vertice format.");
					
					const size_t cap = this._tmi.width * this._tmi.height * 4;
					debug Log.info("TileMap: Reserve %d vertices.", cap);
					
					vertices.reserve(cap);
				}
				
				ushort row, col;
				foreach (const Element child; elem.elements[0].elements) {
					const ushort gid = to!ushort(child.tag.attr["gid"]);
					
					const ushort vx = cast(ushort)(col * this._tmi.tileWidth);
					const ushort vy = cast(ushort)(row * this._tmi.tileHeight);
					
					this._tiles ~= Tile(gid, [vx, vy], [col, row], elem.tag.attr["name"], );
					
					const float vw = this._tmi.tileWidth;
					const float vh = this._tmi.tileHeight;
					
					vertices ~= Vector3f(vx, vy); /// #1
					vertices ~= Vector3f(vx + vw, vy); /// #2
					vertices ~= Vector3f(vx, vy + vh); /// #3
					vertices ~= Vector3f(vx + vw, vy + vh); /// #4
					
					col++;
					if (col >= this._tmi.width) {
						col = 0;
						row++;
					}
				}
			}
		}
		
		debug Log.info("TileMap: Needed %d vertices.", vertices.length);
		
		/// Store the map size
		this._tmi.mapSize[0] = this._tmi.width;
		this._tmi.mapSize[1] = this._tmi.height;
		
		/// Adjust to real size in pixel
		this._tmi.width *= this._tmi.tileWidth;
		this._tmi.height *= this._tmi.tileHeight;
		
		this._vbo.bind(Primitive.Target.Vertex);
		
		if (!this._vbo.isCurrentEmpty())
			this._vbo.modify(&vertices[0], vertices.length * Vector3f.sizeof);
		else
			this._vbo.cache(&vertices[0], vertices.length * Vector3f.sizeof);
		
		this._vbo.unbind();
		
		this._loadTileset();
	}
	
public:
	/**
	 * CTor
	 * 
	 * If compress is true, only the needed Tiles are stored
	 * (which means that are new tileset is created which contains only the needed tiles)
	 * otherwise the whole tileset is taken.
	 */
	this(string filename, bool compress = true) {
		super(filename, compress);
	}
}

