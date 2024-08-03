// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;

// class SharedUrlHandler {
//   static StreamSubscription? _intentSub;
//   static Set<String> _processedUrls = {};
//   static bool _isInitialized = false;

//   static Future<void> handleSharedUrl(
//       BuildContext context, String sharedUrl) async {
//     if (_processedUrls.contains(sharedUrl)) {
//       print('URL already processed: $sharedUrl');
//       return;
//     }

//     _processedUrls.add(sharedUrl);

//     final firestore = FirebaseFirestore.instance;
//     final encodedUrl = Uri.encodeComponent(sharedUrl);
//     final endpoint =
//         'https://process-url-2sel6rjo4q-uc.a.run.app/?url=$encodedUrl';

//     try {
//       final response = await http.get(Uri.parse(endpoint));
//       if (response.statusCode == 200) {
//         await firestore.collection('user1').add({
//           'url': sharedUrl,
//           'status': 'processing',
//           'timestamp': FieldValue.serverTimestamp(),
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//                   Text('Processing $sharedUrl. This may take a few minutes.')),
//         );
//       } else {
//         throw Exception('Failed to process URL');
//       }
//     } catch (e) {
//       print('Error processing shared URL: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Error processing URL. Please try again.')),
//       );
//       _processedUrls.remove(sharedUrl);
//     }
//   }

//   static void listenForSharedUrls(BuildContext context) {
//     if (_isInitialized) return;
//     _isInitialized = true;

//     _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
//       (List<SharedMediaFile> value) {
//         if (value.isNotEmpty) {
//           final sharedUrl = value.first.path;
//           handleSharedUrl(context, sharedUrl);
//         }
//       },
//       onError: (err) {
//         print("getMediaStream error: $err");
//       },
//     );

//     ReceiveSharingIntent.instance
//         .getInitialMedia()
//         .then((List<SharedMediaFile> value) {
//       if (value.isNotEmpty) {
//         final sharedUrl = value.first.path;
//         handleSharedUrl(context, sharedUrl);
//       }
//       ReceiveSharingIntent.instance.reset();
//     });
//   }

//   static void dispose() {
//     _intentSub?.cancel();
//     _processedUrls.clear();
//     _isInitialized = false;
//   }
// }
