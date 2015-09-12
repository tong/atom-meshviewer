
import js.Browser.document;
import js.html.Element;
import js.html.DivElement;
import js.html.SpanElement;

class StatusBarView {

    public var dom(default,null) : DivElement;

    public function new() {

        dom = document.createDivElement();
        dom.setAttribute( 'is', 'status-bar-meshviewer' );
        dom.classList.add( 'meshviewer-status', 'inline-block' );

        //dom.textContent = 'MESHVIEWER';
    }

    public function setText( text : String ) {
        dom.textContent = text;
    }

}
