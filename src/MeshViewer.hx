
import js.Error;
import js.Browser.window;
import js.node.Fs;
import three.*;
import haxe.Json;
import atom.Disposable;

using haxe.io.Path;

@:keep
class MeshViewer {

    public static var defaultMaterial = new MeshLambertMaterial({});

    public var path(default,null) : String;

    var view : MeshViewerView;
    var commandResetView : Disposable;

    public function new( path : String ) {
        this.path = path;
    }

    public function init( view : MeshViewerView ) {

        this.view = view;

        Fs.readFile( path, {encoding:'utf8'}, function(e,r){
            if( e != null ) {
                Atom.notifications.addWarning( e.message );
            } else {
                switch path.extension() {
                case 'mesh':
                    var json : Dynamic = try Json.parse(r) catch(e:Dynamic){
                        trace(e);//TODO
                        return;
                    }
                    //TODO  validate
                    if( json.metadata == null ) trace( 'invalid file format' );
                    var loaded = new three.JSONLoader().parse( json );
                    var material = (loaded.materials != null) ? loaded.materials[0] : defaultMaterial;
                    var mesh = new Mesh( loaded.geometry, material );
                    view.addMesh( mesh );
                case 'obj':
                    var l = new three.loaders.OBJLoader();
                    var obj = l.parse(r);
                    var mesh : Mesh = cast obj.children[0];
                    view.addMesh( mesh );
                //...
                }

                commandResetView = Atom.commands.add( '.meshviewer', 'meshviewer:reset-view', function(e) view.reset() );

                //Atom.commands.add( '.meshviewer', 'meshviewer:toggle-bounding-box', function(e) view.toggleBoundingBox() );
                //Atom.commands.add( '.meshviewer', 'meshviewer:toggle-autorotate', function(e) view.toggleAutoRotate() );
                //Atom.commands.add( '.meshviewer', 'meshviewer:pan-down', function(e) view.controls.pan( new Vector3(0,5,0) ) );
                //Atom.commands.add( '.meshviewer', 'meshviewer:pan-up', function(e) view.controls.pan( new Vector3(0,5,0) ) );

                //Atom.commands.add( '.meshviewer', 'meshviewer:rotate-right', function(_) view.rotateMesh(0,10,0) );
                //Atom.commands.add( '.meshviewer', 'meshviewer:rotate-left', function(_) view.rotateMesh(0,-10,0) );
            }
        });
    }

    public function destroy() {
        if( commandResetView != null ) commandResetView.dispose();
        if( view != null ) view.destroy();
    }

    public inline function getTitle() {
        return path.withoutDirectory();
    }

    public inline function getIconName() {
        return "file-text";
    }

}
