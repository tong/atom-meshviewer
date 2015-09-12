
import js.Error;
import js.Browser.window;
import js.node.Fs;
import three.*;
import haxe.Json;
import atom.Disposable;

using haxe.io.Path;

@:keep
class MeshViewer {

    static inline function __init__() {
        //untyped module.exports = AtomPackage;
        //var THREE = js.Lib.require( './three' );
        //js.Lib.require( './OBJLoader' );
    }

    //public static var defaultMaterial = new MeshLambertMaterial({});

    public var path(default,null) : String;

    var view : MeshViewerView;
    var commandResetView : Disposable;

    public function new( path : String ) {
        this.path = path;
    }

    public function init( view : MeshViewerView, callback : String->Void ) {

        this.view = view;

        Fs.readFile( path, {encoding:'utf8'}, function(e,r){
            if( e != null ) {
                callback( e.message );
            } else {

                switch path.extension() {

                case 'dae':

                    //TODO

                    var xmlParser = new js.html.DOMParser();
                    var xml = xmlParser.parseFromString( r, js.html.SupportedType.TEXT_XML );
                    //trace(xml);
                    //trace(path);

                    //var loader = untyped __js__('new THREE.ColladaLoader()' );
                    var loader = new three.loaders.ColladaLoader();
                    untyped loader.options.convertUpAxis = true;
                    loader.parse( xml, null, path );
                    //trace( untyped __js__('new THREE.ColladaLoader()' ) );


                case 'mesh':
                    var loaded : {geometry:Geometry,materials:Array<Material>} = null;
                    try {
                        loaded = new three.JSONLoader().parse( Json.parse(r) );
                    } catch(e:Dynamic) {
                        callback( e );
                        return;
                    }
                    //TODO  validate
                    //if( json.metadata == null ) trace( 'invalid file format' );
                    var material = (loaded.materials != null) ? loaded.materials[0] : new MeshLambertMaterial({});
                    var mesh = new Mesh( loaded.geometry, material );
                    view.addMesh( mesh );
                    callback( null );

                case 'obj':
                    //var l = js.Lib.require( './OBJLoader' );
                    //trace(l);
                    //TODO
                    var l = new three.loaders.OBJLoader();
                    var obj = l.parse(r);
                    var mesh : Mesh = cast obj.children[0];
                    view.addMesh( mesh );
                    callback( null );

                //...
                }

                commandResetView = Atom.commands.add( '.meshviewer', 'meshviewer:reset-view', function(e) view.reset() );
                //commandResetView = Atom.commands.add( '.meshviewer', 'meshviewer:rotate-right', function(e) view.reset() );

                //Atom.commands.add( '.meshviewer', 'meshviewer:toggle-bounding-box', function(e) view.toggleBoundingBox() );
                //Atom.commands.add( '.meshviewer', 'meshviewer:toggle-autorotate', function(e) view.toggleAutoRotate() );
                //Atom.commands.add( '.meshviewer', 'meshviewer:pan-down', function(e) view.controls.pan( new Vector3(0,5,0) ) );
                //Atom.commands.add( '.meshviewer', 'meshviewer:pan-up', function(e) view.controls.pan( new Vector3(0,5,0) ) );
                //Atom.commands.add( '.meshviewer', 'meshviewer:rotate-right', function(_) view.rotateMesh(0,10,0) );
                //Atom.commands.add( '.meshviewer', 'meshviewer:rotate-left', function(_) view.rotateMesh(0,-10,0) );

                //callback( null );
            }
        });
    }

    /*
    public function attached() {
        trace("attached");
    }
    */

    public function destroy() {
        if( commandResetView != null ) commandResetView.dispose();
        if( view != null ) view.destroy();
    }

    /*
    public inline function getPlaceHolder() {
        return js.Browser.document.createDivElement();
    }
    */

    public inline function getPath() {
        return path;
    }

    public inline function getTitle() {
        return path.withoutDirectory();
    }

    public inline function getIconName() {
        return "file-text";
    }

}
