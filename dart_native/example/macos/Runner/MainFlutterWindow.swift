import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController.init()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        let son = RuntimeSon()
        let channel = FlutterMethodChannel(name: "sample.dartnative.com", binaryMessenger: flutterViewController.engine.binaryMessenger)
        channel.setMethodCallHandler { call, result in
            if call.method == "fooString" {
                result(son.fooNSString(_: call.arguments as? String ?? ""))
            }
        }
        RegisterGeneratedPlugins(registry: flutterViewController)
        
        super.awakeFromNib()
    }
}
