// a simple structure for storing media file data within the scope of the "create thread" page

class ThreadMediaFile {
  String name = "", extension = "", path = "";
  ThreadMediaFile.all(this.name, this.extension, this.path);
  ThreadMediaFile.name(this.name);
  ThreadMediaFile.none();
}
