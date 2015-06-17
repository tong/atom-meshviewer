package meshviewer;

import js.Browser.window;
import three.*;
import haxe.Json;
import js.node.Fs;
import tron.control.EditorControls;

using haxe.io.Path;

@:keep
@:expose
class MeshViewer {

    public var path(default,null) : String;

    var tabTitle : String;
    var subscriptions : atom.CompositeDisposable;
    var view : MeshViewerView;

    var scene : Scene;
    //var grid : GridHelper;
    var camera : PerspectiveCamera;
    var controls : EditorControls;
    var renderer : WebGLRenderer;
    var renderFrame = true;
    var lastWidth : Int;
    var lastHeight : Int;
    var animationFrameId : Int;

    //var materials : Array<>;
    var material : Material;

    public function new( path : String ) {

        this.path = path;
        this.tabTitle = path.withoutDirectory();

        subscriptions = new atom.CompositeDisposable( );
    }

    public function initialize( view : MeshViewerView ) {

        this.view = view;

        //view.addEventListener( 'focus', handleFocus, false );
        //view.addEventListener( 'blur', handleBlur, false );
        //view.addEventListener( 'DOMNodeRemoved', handleVideoRemove, false );
        //view.addEventListener( 'dbclick', function(e) trace(e), false );
        view.addEventListener( 'DOMNodeInserted', handleViewInsert, false );
    }

    public function destroy() {

        subscriptions.dispose();

        view.removeEventListener( 'focus', handleFocus );
        view.removeEventListener( 'blur', handleBlur );
        view.destroy();
    }

    public inline function getTitle() {
        return tabTitle;
    }

    function update() {

        if( view == null || view.parentElement == null ) {
            window.cancelAnimationFrame( animationFrameId );
            return;
        }

        requestAnimationFrame();

        var style = window.getComputedStyle( view.parentElement );
        var width = Std.parseInt( style.width.substr( 0, style.width.length-2 ) );
        var height = Std.parseInt( style.height.substr( 0, style.height.length-2 ) );
        if( width != lastWidth || height != lastHeight ) {
            renderer.setSize( width, height );
            camera.aspect = width/height;
            camera.updateProjectionMatrix();
            renderFrame = true;
        }
        lastWidth = width;
        lastHeight = height;

        if( renderFrame ) {

            renderer.render( scene, camera );
            renderFrame = false;

            view.renderInfo = renderer.info;
        }
    }

//    function addCommand( id : String, fun )
//        subscriptions.add( Atom.commands.add( 'atom-workspace', 'meshviewer:$id', function(_) fun() ) );

    function handleViewInsert(e) {

        var style = window.getComputedStyle( view.parentElement );
        var width = Std.parseInt( style.width.substr( 0, style.width.length-2 ) );
        var height = Std.parseInt( style.height.substr( 0, style.height.length-2 ) );

        scene = new Scene();

        scene.add( new AxisHelper(1) );

        //var grid = new GridHelper(10,1);
        //scene.add( grid );

        camera = new PerspectiveCamera( 50, width/height, 0.00001, 1000000 );
        camera.position.set( 0, 5, 5 );
        camera.lookAt( scene.position );

        var light = new DirectionalLight( 0xffffff );
        //var light = new tron.light.ThreePointLighting();
        light.position.set( 5, 5, 5 );
        //light.lookAt( scene.position );
        scene.add( light );
        scene.add( new DirectionalLightHelper( light ) );

        renderer = new WebGLRenderer({
            canvas: view.canvas,
            alpha: true,
            antialias: false,
        });
        renderer.render( scene, camera );
        renderer.setSize( width, height );

        material = new MeshLambertMaterial( {color:'#aaa' });

        Fs.readFile( path, {encoding:'utf8'}, function(e,r){
            if( e != null ) {
                Atom.notifications.addWarning( Std.string(e) );
            } else {
                switch path.extension() {
                case 'json':
                    var geometry : Geometry = null;
                    try {
                        geometry = new three.JSONLoader().parse( Json.parse(r) ).geometry;
                    } catch(e:Dynamic) {
                        Atom.notifications.addWarning( path+': '+Std.string(e) );
                        return;
                    }
                    //var material = new MeshBasicMaterial( {color:'#aaa' });
                    var mesh = new Mesh( geometry, material );
                    scene.add( mesh );

                    var boundingBox = new BoundingBoxHelper( mesh );
                    scene.add( boundingBox );
                    boundingBox.update();

                    //trace(boundingBox);
                    //trace(boundingBox.scale);
                    var gridSize = boundingBox.scale.x;
                    if( boundingBox.scale.y > gridSize ) gridSize = boundingBox.scale.y;
                    if( boundingBox.scale.z > gridSize ) gridSize = boundingBox.scale.z;
                    var grid = new GridHelper( gridSize/2, gridSize/10 );
                    scene.add( grid );

                default:

                }
            }
            requestAnimationFrame();
        });

        controls = new EditorControls( view.canvas, camera );
        controls.onChange = function() {
            //TODO
            //view.renderInfo = renderer.info;
            renderFrame = true;
        }
        controls.enabled = true;

        window.addEventListener( 'keydown', handleKeyDown, false );

        requestAnimationFrame();

        //view.parentElement.addEventListener( 'resize', function(e) trace(e) );
    }

    function handleFocus(e) {
    }

    function handleBlur(e) {
        subscriptions.dispose();
    }

    function handleKeyDown(e) {
        trace(e);
    }

    inline function requestAnimationFrame() {
        animationFrameId = window.requestAnimationFrame( untyped update );
    }

}
