import 'package:flutter/material.dart';
import 'package:mediawiki_import/widgets/wiki_folder_action.dart';
import 'package:mediawiki_import/widgets/wiki_settings_form.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  bool hasImportPermission = false;
  Map<String, dynamic>? wikiResult;

  void _onCheckResult(Map<String, dynamic> result) {
    final rights = Map<String, bool>.from(result['userRights'] ?? {});
    final canImport = (rights['createpage'] ?? false) && (rights['edit'] ?? false);
    setState(() {
      hasImportPermission = canImport;
      wikiResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        // Cuộn dọc toàn trang
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 320,
                child: WikiSettingsForm(onCheckCompleted: _onCheckResult),
              ),

              // B chiếm phần còn lại, nhưng không nhỏ hơn 400
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 400),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 320 - 8,
                  child: WikiFolderActions(
                    enabled: hasImportPermission,
                    wikiInfo: wikiResult,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}