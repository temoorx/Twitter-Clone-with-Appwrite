import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/storage_api.dart';
import 'package:twitter_clone/apis/tweet_api.dart';
import 'package:twitter_clone/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/models/tweet_models.dart';

final tweetControllerProvider =
    StateNotifierProvider<TweetController, bool>((ref) {
  return TweetController(
      ref: ref,
      tweetAPi: ref.watch(tweetAPiProvider),
      storageAPI: ref.watch(storageAPIProvider));
});

class TweetController extends StateNotifier<bool> {
  final TweetAPI _tweetAPi;
  final StorageAPI _storageAPI;
  final Ref _ref;

  TweetController(
      {required Ref ref,
      required TweetAPI tweetAPi,
      required StorageAPI storageAPI})
      : _ref = ref,
        _tweetAPi = tweetAPi,
        _storageAPI = storageAPI,
        super(false);

  void shareTweet({
    required List<File> images,
    required String tweetText,
    required BuildContext context,
  }) {
    if (tweetText.isEmpty) {
      showSnackBar(context, "Please enter tweet text");
      return;
    }
    if (images.isNotEmpty) {
      _shareImageTweet(context: context, images: images, tweetText: tweetText);
    } else {
      _shareTextTweet(tweetText: tweetText, context: context);
    }
  }

//share tweet with images
  void _shareImageTweet({
    required List<File> images,
    required String tweetText,
    required BuildContext context,
  }) async {
    state = false;
    final hashtags = _getHasTagFromTweetText(tweetText);
    String link = _getLinkFromTweetText(tweetText);
    final user = _ref.read(currentUserDetailsProvider).value!;
    final imageLinks = await _storageAPI.uploadImage(images);
    Tweet tweet = Tweet(
        text: tweetText,
        hashtag: hashtags,
        link: link,
        imageLinks: imageLinks,
        uid: user.uid,
        tweetType: TweetType.image,
        tweetedAt: DateTime.now(),
        likes: const [],
        commentIds: const [],
        tweetId: '',
        reshareCount: 0);
    final res = await _tweetAPi.shareTweet(tweet);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

//share tweet with text
  void _shareTextTweet({
    required String tweetText,
    required BuildContext context,
  }) async {
    state = false;
    final hashtags = _getHasTagFromTweetText(tweetText);
    String link = _getLinkFromTweetText(tweetText);
    final user = _ref.read(currentUserDetailsProvider).value!;
    Tweet tweet = Tweet(
        text: tweetText,
        hashtag: hashtags,
        link: link,
        imageLinks: const [],
        uid: user.uid,
        tweetType: TweetType.text,
        tweetedAt: DateTime.now(),
        likes: const [],
        commentIds: const [],
        tweetId: '',
        reshareCount: 0);
    final res = await _tweetAPi.shareTweet(tweet);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

//this function will return the link from the tweet text
  String _getLinkFromTweetText(String text) {
    String link = '';
    List<String> wordsInSentence = text.split(' ');
    for (String words in wordsInSentence) {
      if (words.startsWith('https//') || words.startsWith('www.')) {
        link = words;
      }
    }
    return link;
  }

//this function will return all the hashtags from the tweet text
  List<String> _getHasTagFromTweetText(String text) {
    List<String> hashtags = [];
    List<String> wordsInSentence = text.split(' ');
    for (String words in wordsInSentence) {
      if (words.startsWith('#')) {
        hashtags.add(words);
      }
    }
    return hashtags;
  }
}
