
import js.node.Fs;
import atom.Disposable;

using Lambda;
using haxe.io.Path;

@:keep
class Main {

    static inline function __init__() {
        untyped module.exports = Main;
        var THREE = js.Lib.require( './three' );
    }

    static var allowedFileTypes = ['mesh','obj'];

    static var config = {
        //TODO
    };

    static var opener : Disposable;
    static var viewProvider : Disposable;
    static var statusBar : StatusBarView;

    static function activate( state ) {

        trace( 'Atom-meshviewer' );

        statusBar = new StatusBarView();

        viewProvider = Atom.views.addViewProvider( MeshViewer, function(model:MeshViewer) {
                var view = new MeshViewerView();
                model.init( view, function(e) {
                    if( e != null ) {
                        Atom.notifications.addError( 'Mesh error   ```'+e+'```' );
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
