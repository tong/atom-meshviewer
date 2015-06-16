
import js.Browser.document;
import js.html.Element;
import js.html.DivElement;
import js.html.CanvasElement;

/*
private class MenuView {

    public var dom(default,null) : DivElement;

    public function new() {

        dom = document.createDivElement();

        var info = document.createDivElement();
        info.textContent = path;
        dom.appendChild( title );

    }
}
*/

@:forward(
    addEventListener, removeEventListener,
    //width, height,
    parentElement,
    style,
    focus
)
//abstract MeshViewerView(CanvasElement) to CanvasElement {
abstract MeshViewerView(DivElement) to DivElement {

    public var menu(get,never) : DivElement;
    public var canvas(get,never) : CanvasElement;

    public var renderInfo(never,set) : Dynamic;

    public inline function new( path : String ) {

        this = document.createDivElement();
        this.classList.add( 'meshviewer' );
        this.setAttribute( 'tabindex', '-1' );

        var menu = document.createDivElement();
        menu.classList.add( 'menu' );
        this.appendChild( menu );

        var canvas = document.createCanvasElement();
        canvas.classList.add( 'canvas' );
        this.appendChild( canvas );

        var renderInfo = document.createDivElement();
        renderInfo.textContent = path;
        menu.appendChild( renderInfo );

        //this.addEventListener( 'DOMNodeInserted', handleInsert, false );
    }

    inline function get_canvas() : CanvasElement return cast this.children[1];
    inline function get_menu() : DivElement return cast this.children[0];

    function set_renderInfo(info:Dynamic) : Dynamic {
        trace(info.memory.geometries);
        var e = this.children[0].children[0];
		//e.textContent = '|PROGRAMS:'+info.memory.programs+'|GEOMETRIES:'+info.memory.geometries+'|TEXTURES:'+info.memory.textures+'|CALLS:'+info.render.calls+'|VERTICES:'+info.render.vertices+'|FACES:'+info.render.faces+'|POINTS:'+info.render.points;
        //e.textContent = 'ROGRAMS '+Std.string( info.render.vertices);
        e.textContent = 'FACES:'+info.render.faces+'|VERTICES:'+info.render.vertices+'|POINTS:'+info.render.points;
        //e.textContent += '\nPROGRAMS:'+info.memory.programs+'|GEOMETRIES:'+info.memory.geometries+'|TEXTURES:'+info.memory.points;
        return info;
    }

    public inline function destroy() {
    }

    function handleInsert(e) {

        //this.removeEventListener( 'DOMNodeInserted', handleInsert );

        //trace(this.parentElement);
        //trace(this.parentElement);
        //trace(this.width);
        //this.width = 600;
        //this.height = 400;
    }
}
