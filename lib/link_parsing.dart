// This class is responsible for getting the links (and other information about an art piece)

class LinkParser{
  final String sourceLink;
  final List<String> crates;

  LinkParser(this.sourceLink, this.crates);

  Future<void> getArt() async {
    StringBuffer builder = StringBuffer(sourceLink);
    if(!sourceLink.contains("/photo/1")) {
      builder.write("/photo/1");
    }
    String tweetUrl = builder.toString();
    //what we need: timestamp, image url, user, hashtags, num_images, original link

    //TODO: Act as if API written, create code based upon that to save to DB


  }
}