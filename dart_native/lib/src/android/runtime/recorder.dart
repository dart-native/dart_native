library dart_native;

int currentTimeMicros() {
  return new DateTime.now().microsecondsSinceEpoch;
}

int beginMST;
int startMST;

void markBegin() {
  beginMST = new DateTime.now().microsecondsSinceEpoch;
  startMST = beginMST;
}

void markItemFinish(String msg) {
  int now = new DateTime.now().microsecondsSinceEpoch;
  int use = now - startMST;
  startMST = now;
  print("$msg cost: $use");
}

void markFinish(dynamic msg) {
  int use = new DateTime.now().microsecondsSinceEpoch - beginMST;
  print("all finish cost: $use , msg: $msg" );
}