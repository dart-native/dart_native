import 'package:dart_objc/src/runtime/class.dart';
import 'package:dart_objc/src/runtime/message.dart';
import 'package:dart_objc/src/runtime/protocol.dart';
import 'package:dart_objc/src/runtime/selector.dart';
import 'package:flutter/material.dart';

mixin NSObjectProtocol {

  static Class type({@required NSObjectProtocol of}) {
    return of.perform(Selector('class'));
  }

  Class get superclass {
    return perform(Selector('superclass'));
  }

  bool isEqual(NSObjectProtocol object) {
    return perform(Selector('isEqual:'), args: [object]);
  }

  int get hash {
    return perform(Selector('hash'));
  }

  NSObjectProtocol self() {
    return this;
  }

  bool isKind({@required Class of}) {
    return perform(Selector('isKindOfClass:'), args: [of]);
  }

  bool isMember({@required Class of}) {
    return perform(Selector('isMemberOfClass:'), args: [of]);
  }

  bool responds({@required Selector to}) {
    return perform(Selector('respondsToSelector:'), args: [to]);
  }

  bool conforms({@required Protocol to}) {
    return perform(Selector('conformsToProtocol:'), args: [to]);
  }

  String get description {
    return perform(Selector('description'));
  }

  String get debugDescription {
    return perform(Selector('debugDescription'));
  }

  dynamic perform(Selector selector, {List args}) {
    return msgSend(this, selector, args);
  }

  bool isProxy() {
    return perform(Selector('isProxy'));
  }

  NSObjectProtocol retain() {
    return perform(Selector('retain'));
  }

  release() {
    perform(Selector('release'));
  }
}