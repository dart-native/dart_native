import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/ios/delegatestub.dart';

class RuntimeStub extends NSObject {
  RuntimeStub() : super(Class('RuntimeStub'));
  int selectorDuration = 0;

  bool fooBool(bool b) {
    return perform('fooBOOL:'.toSelector(), args: [b]);
  }

  int fooInt8(int int8) {
    return perform(Selector('fooInt8:'), args: [int8]);
  }

  String fooCharPtr(String charPtr) {
    return perform(Selector('fooCharPtr:'), args: [charPtr]);
  }

  String fooChar(String char) {
    return perform(Selector('fooChar:'), args: [char]);
  }

  String fooUChar(String char) {
    return perform(Selector('fooUChar:'), args: [char]);
  }

  NSObject fooObject(NSObject object) {
    return perform(Selector('fooObject:'), args: [object]);
  }

  Block fooBlock(Function func) {
    Block result = perform(Selector('fooBlock:'), args: [func]);
    return result;
  }

  Block fooStretBlock(Function func) {
    Block result = perform(Selector('fooStretBlock:'), args: [func]);
    return result;
  }

  Block fooCStringBlock(Function func) {
    Block result = perform(Selector('fooCStringBlock:'), args: [func]);
    return result;
  }

  CGSize fooCGSize(CGSize size) {
    return perform(Selector('fooCGSize:'), args: [size]);
  }

  CGPoint fooCGPoint(CGPoint point) {
    return perform(Selector('fooCGPoint:'), args: [point]);
  }

  CGVector fooCGVector(CGVector vector) {
    return perform(Selector('fooCGVector:'), args: [vector]);
  }

  CGRect fooCGRect(CGRect rect) {
    return perform(Selector('fooCGRect:'), args: [rect]);
  }

  NSRange fooNSRange(NSRange range) {
    return perform(Selector('fooNSRange:'), args: [range]);
  }

  UIOffset fooUIOffset(UIOffset offset) {
    return perform(Selector('fooUIOffset:'), args: [offset]);
  }

  UIEdgeInsets fooUIEdgeInsets(UIEdgeInsets insets) {
    return perform(Selector('fooUIEdgeInsets:'), args: [insets]);
  }

  NSDirectionalEdgeInsets fooNSDirectionalEdgeInsets(
      NSDirectionalEdgeInsets insets) {
    return perform(Selector('fooNSDirectionalEdgeInsets:'), args: [insets]);
  }

  CGAffineTransform fooCGAffineTransform(CGAffineTransform transform) {
    return perform(Selector('fooCGAffineTransform:'), args: [transform]);
  }

  NSString fooNSString(String string) {
    NSObject result = perform(Selector('fooNSString:'), args: [string]);
    return NSString.fromPointer(result.pointer);
  }

  NSArray fooNSArray(List list) {
    NSObject result = perform(Selector('fooNSArray:'), args: [list]);
    return NSArray.fromPointer(result.pointer);
  }

  fooDelegate(SampleDelegate delegate) {
    perform(Selector('fooDelegate:'), args: [delegate]);
  }

  fooStructDelegate(SampleDelegate delegate) {
    perform(Selector('fooStructDelegate:'), args: [delegate]);
  }
}
