import 'dart:io';

import 'package:baller_app/repositories/repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.imageUrl, required this.onUpload});

  final String? imageUrl;
  final void Function(String imageUrl) onUpload;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image == null) return;
        // Uploads to B2 in API mode (presign + PUT) or Supabase Storage in
        // legacy mode, returning the public URL.
        final publicUrl =
            await RepositoryProvider.uploads.uploadAvatar(File(image.path));
        final bustedUrl = Uri.parse(publicUrl).replace(
          queryParameters: {
            't': DateTime.now().millisecondsSinceEpoch.toString(),
          },
        ).toString();
        onUpload(bustedUrl);
      },
      child: CircleAvatar(
        radius: 60,
        backgroundColor: const Color.fromRGBO(231, 85, 39, 100),
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
        child: imageUrl == null
            ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
            : null,
      ),
    );
  }
}
