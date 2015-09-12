
import js.node.Fs;
import atom.Disposable;

using Lambda;
using haxe.io.Path;

@:keep
class AtomPackage {

    static inline function __init__() {

        untyped module.exports = AtomPackage;

        //var THREE = js.Lib.require( './three' );

        haxe.macro.Compiler.includeFile("data/three.js");
        haxe.macro.Compiler.includeFile("data/loaders/OBJLoader.js");

        /*
        haxe.macro.Compiler.includeFile("data/loaders/OBJMTLLoader.js");
        //haxe.macro.Compiler.includeFile("data/loaders/ColladaLoader.js");
        haxe.macro.Compiler.includeFile("data/loaders/MTLLoader.js");
        */
    }

    static var allowedFileTypes = [
        'mesh',
        //'dae',
        'obj'
    ];

    /*
    static var config = {};
    */

    static var opener : Disposable;
    static var viewProvider : Disposable;
    static var statusBar : StatusBarView;

    static function activate( state ) {

        trace( 'Atom-meshviewer-dev' );

        statusBar = new StatusBarView();

        viewProvider = Atom.views.addViewProvider( MeshViewer, function(model:MeshViewer) {
                var view = new MeshViewerView();
                model.init( view, function(e) {
                    if( e != null ) {
                        Atom.notifications.addError( 'Mesh error  ```'+e+'```' );
                        //TODO close meshviewer pane
                        //model.destroy();
                    }
                });
                return view.dom;
        });

        opener = Atom.workspace.addOpener(function(path){
            var ext = path.extension().toLowerCase();
            if( allowedFileTypes.has( ext ) ) {
                return new MeshViewer( path );
            }
            return null;
        });
    }

    static function deactivate() {
        viewProvider.dispose();
        opener.dispose();
    }

    static function consumeStatusBar( bar ) {
        bar.addLeftTile( { item: statusBar.dom, priority:-10 } );
    }

    static function getTreeViewFile() : String {
        return Atom.packages.getLoadedPackage( 'tree-view' ).serialize().selectedPath;
    }

}
