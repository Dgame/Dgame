module Dgame.Graphics.TiledMap;

private {
	import std.xml : Document, Element;
	import std.file : read;
	import std.conv : to;

	import Dgame.Internal.Log;
	import Dgame.Math.Vector2;
	import Dgame.Math.Vector3;
	import Dgame.Graphics.TileMap;
	import Dgame.System.VertexRenderer : Target;
}

class TiledMap : TileMap {
protected:
	override void _readTileMap() {
		Document doc = new Document(cast(string) .read(super._filename));
		
		Vector3f[] vertices;
		
		foreach (const Element elem; doc.elements) {
			if (elem.tag.name == "tileset") {
				super._tmi.source = elem.elements[0].tag.attr["source"];
				
				super._tmi.tileWidth = to!ubyte(elem.tag.attr["tilewidth"]);
				super._tmi.tileHeight = to!ubyte(elem.tag.attr["tileheight"]);
			}
			
			if (elem.tag.name == "layer") {
				if (!super._tmi.width) {
					super._tmi.width  = to!ushort(elem.tag.attr["width"]);
					super._tmi.height = to!ushort(elem.tag.attr["height"]);
					
					if (vertices.length != 0)
						Log.error("Wrong vertice format.");
					
					const size_t cap = super._tmi.width * super._tmi.height;

					vertices.reserve(cap * 4);
					super._tiles.reserve(cap);

					debug Log.info("TiledMap: Reserve %d vertices. Get %d.", cap * 4, vertices.capacity);
					debug Log.info("TiledMap: Reserve %d Tiles. Get %d.", cap, super._tiles.capacity);
				}
				
				ushort row, col;
				foreach (const Element child; elem.elements[0].elements) {
					const ushort gid = to!ushort(child.tag.attr["gid"]);
					
					const ushort vx = cast(ushort)(col * super._tmi.tileWidth);
					const ushort vy = cast(ushort)(row * super._tmi.tileHeight);
					
					super._tiles ~= Tile(gid, [vx, vy], [col, row], elem.tag.attr["name"], );
					
					const float vw = super._tmi.tileWidth;
					const float vh = super._tmi.tileHeight;
					
					vertices ~= Vector3f(vx, vy); /// #1
					vertices ~= Vector3f(vx + vw, vy); /// #2
					vertices ~= Vector3f(vx, vy + vh); /// #3
					vertices ~= Vector3f(vx + vw, vy + vh); /// #4
					
					col++;
					if (col >= super._tmi.width) {
						col = 0;
						row++;
					}
				}
			}
		}
		
		debug Log.info("TiledMap: Needed %d vertices.", vertices.length);
		debug Log.info("TiledMap: Needed %d Tiles.", super._tiles.length);
		
		/// Store the map size
		super._tmi.mapSize[0] = super._tmi.width;
		super._tmi.mapSize[1] = super._tmi.height;
		
		/// Adjust to real size in pixel
		super._tmi.width *= super._tmi.tileWidth;
		super._tmi.height *= super._tmi.tileHeight;
		
		super._vbo.bind(Target.Vertex);
		
		if (!super._vbo.isCurrentEmpty())
			super._vbo.modify(&vertices[0], vertices.length * Vector3f.sizeof);
		else
			super._vbo.cache(&vertices[0], vertices.length * Vector3f.sizeof);
		
		super._vbo.unbind();
		
		super._loadTileset();
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

