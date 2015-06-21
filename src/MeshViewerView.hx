
import js.Browser.document;
import js.Browser.window;
import js.html.Element;
import js.html.DivElement;
import js.html.CanvasElement;
import tron.control.EditorControls;
import three.*;

class MeshViewerView {

    public var dom(default,null) : DivElement;
    public var canvas(default,null) : CanvasElement;
    public var settings(default,null) : SettingsMenu;
    public var controls(default,null) : EditorControls;

    var renderInfo : Dynamic;
    var scene : Scene;
    var camera : PerspectiveCamera;
    var animationFrameId : Int;
    var dirtyRenderFrame = true;
    var renderer : WebGLRenderer;
    var meshes : Group;

    var boundingBox : BoundingBoxHelper;

    public function new( ) {

        dom = document.createDivElement();
        dom.classList.add( 'meshviewer' );
        dom.setAttribute( 'tabindex', '-1' );

        settings = new SettingsMenu();
        dom.appendChild( settings.dom );

        canvas = document.createCanvasElement();
        dom.appendChild( canvas );

        renderInfo = document.createDivElement();
        renderInfo.classList.add( 'info' );
        dom.appendChild( renderInfo );

        var w = 100;
        var h = 100;

        renderer = new WebGLRenderer({ canvas: canvas, alpha: true, antialias: false });

        scene = new Scene();

        scene.add( new AxisHelper(2) );

        var grid = new GridHelper(10,1);
        //grid.setColors();
        scene.add( grid );

        var dirLight = new DirectionalLight( 0xffffff );
        dirLight.position.set( 3, 3, 2 );
        scene.add( dirLight );
        scene.add( new DirectionalLightHelper( dirLight ) );

        camera = new PerspectiveCamera( 50, w/h, 0.00001, 1000000 );
        camera.position.set( 0, 5, 5 );
        camera.lookAt( scene.position );

        meshes = new Group();
        scene.add( meshes );

        controls = new EditorControls( canvas, camera );
        controls.onChange = function() dirtyRenderFrame = true;

        dom.addEventListener( 'contextmenu', function(e) {
            e.stopPropagation();
            return false;
        }, false );
        dom.addEventListener( 'DOMNodeInserted', handleInsert, false );
        //dom.addEventListener( 'focus', handleFocus, false );
        //dom.addEventListener( 'blur', handleBlur, false );
        //dom.addEventListener( 'DOMNodeRemoved', handleVideoRemove, false );
        //dom.addEventListener( 'mousedown', function(e) trace(e), false );
        //dom.addEventListener( 'click', function(e) trace(e), false );
        //dom.addEventListener( 'dbclick', function(e) trace(e), false );
        //dom.addEventListener( 'DOMNodeInserted', handleViewInsert, false );
    }

    public function destroy() {
        if( animationFrameId != null ) window.cancelAnimationFrame( animationFrameId );
    }

    public function addMesh( mesh : Mesh ) {

        meshes.add( mesh );
        scene.add( mesh );

        boundingBox = new BoundingBoxHelper( mesh );
        scene.add( boundingBox );
        boundingBox.update();

        var wireframeHelper = new WireframeHelper( mesh );
        scene.add( wireframeHelper );

        dirtyRenderFrame = true;

        //TODO
        /*
        var gridSize = boundingBox.scale.x;
        if( boundingBox.scale.y > gridSize ) gridSize = boundingBox.scale.y;
        if( boundingBox.scale.z > gridSize ) gridSize = boundingBox.scale.z;
        var grid = new GridHelper( gridSize/2, gridSize/10 );
        scene.add( grid );
        */
    }

    public function rotateMesh( x : Float, y : Float, z : Float ) {
        for( mesh in meshes.children ) {
            mesh.rotation.x += x/180*Math.PI;
            mesh.rotation.y += y/180*Math.PI;
            mesh.rotation.z += z/180*Math.PI;
        }
    }

    public function toggleBoundingBox() {
        //TODO
    }

    public function toggleAutoRotate() {
        if( boundingBox != null ) {
            boundingBox.visible = !boundingBox.visible;
            dirtyRenderFrame = true;
        }
    }

    public function reset() {

        camera.position.set( 0, 5, 5 );
        camera.lookAt( scene.position );
        camera.aspect = canvas.width / canvas.height;
        camera.updateProjectionMatrix();

        dirtyRenderFrame = true;
    }

    public function clear() {
        for( m in meshes.children) {
            var mesh : Mesh = cast m;
            mesh.geometry.dispose();
            mesh.material.dispose();
            meshes.remove(m);
        }
        dirtyRenderFrame = true;
    }

    function update() {

        requestAnimationFrame();

        var style = window.getComputedStyle( dom.parentElement );
        var w = Std.parseInt( style.width.substr( 0, style.width.length-2 ) );
        var h = Std.parseInt( style.height.substr( 0, style.height.length-2 ) );
        if( w != canvas.width || h != canvas.height )
            resize( w, h );

        if( dirtyRenderFrame ) {

            renderer.render( scene, camera );
            dirtyRenderFrame = false;

            var r = renderer.info.render;
            var m = renderer.info.memory;
            renderInfo.textContent = 'FACES ${r.faces}|VERTICES ${r.vertices}|POINTS ${r.points}|PROGRAMS ${m.programs}|GEOMETRIES ${m.geometries}|TEXTURES ${m.textures}';
        }
    }

    function resize( width : Int, height : Int ) {

        canvas.width = width;
        canvas.height = height;
        camera.aspect = width / height;
        camera.updateProjectionMatrix();
        renderer.setSize( width, height );

        dirtyRenderFrame = true;
    }

    function handleInsert(e) {

        dom.removeEventListener( 'DOMNodeInserted', handleInsert );

        var style = window.getComputedStyle( dom.parentElement );
        resize(
            Std.parseInt( style.width.substr( 0, style.width.length-2 ) ),
            Std.parseInt( style.height.substr( 0, style.height.length-2 ) )
        );

        dirtyRenderFrame = true;
        requestAnimationFrame();
    }

    inline function requestAnimationFrame() {
        animationFrameId = window.requestAnimationFrame( untyped update );
    }
}
