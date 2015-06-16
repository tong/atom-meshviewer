
import atom.Disposable;

using Lambda;
using haxe.io.Path;

@:keep
@:expose
class MeshViewerPackage {

    static var allowedFileTypes = ['json'];

    static var config = {};

    static var opener : Disposable;
    static var viewProvider : Disposable;

    static function activate( state ) {

        trace( 'Atom-meshviewer' );

        /*
        Atom.commands.add( 'atom-workspace', 'meshviewer:open', function(e) {
            trace(e);
            var file = getTreeViewFile();
            trace(file);
        });
        */

        viewProvider = Atom.views.addViewProvider( MeshViewer, function(model:MeshViewer) {
                var view = new MeshViewerView( model.path );
                model.initialize( view );
                return view;
            }
        );

        opener = Atom.workspace.addOpener(function(path){
            if( allowedFileTypes.has( path.extension() ) )
                return new MeshViewer( path );
            return null;
        });
    }

    static function deactivate() {
        viewProvider.dispose();
        opener.dispose();
    }

    static function getTreeViewFile() : String {
        return Atom.packages.getLoadedPackage( 'tree-view' ).serialize().selectedPath;
    }

    static inline function __init__() {
        untyped module.exports = MeshViewerPackage;
        var THREE = js.Lib.require( './three' );
    }

}
