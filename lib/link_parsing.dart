
import 'package:twitter_extractor/twitter_extractor.dart';

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
    Twitter tweet = await  TwitterExtractor.extract(tweetUrl);
    //what we need: timestamp, image url, description, user, tags, num_images, original link

    // tweet.videos.single.type gets whether or not it is an image
  }
}