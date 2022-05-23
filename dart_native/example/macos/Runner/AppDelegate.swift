import Cocoa
import FlutterMacOS
import CocoaLumberjack
import dart_native

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func applicationDidFinishLaunching(_ notification: Notification) {
        DDLog.add(DDOSLogger.sharedInstance)
        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
        #if DEBUG
        InterfaceRegistry.isExceptionEnabled = true
        #else
        InterfaceRegistry.isExceptionEnabled = false
        #endif
    }
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
