import 'package:flutter/material.dart';

/// A widget for selecting a Flutter project directory.
class ProjectSelector extends StatelessWidget {
  const ProjectSelector({
    super.key,
    required this.projectPath,
    required this.onSelectProject,
    required this.isValid,
  });

  /// The currently selected project path.
  final String projectPath;

  /// A callback function that is called when the "Browse" button is pressed.
  final VoidCallback onSelectProject;

  /// Indicates whether the selected path is a valid Flutter project.
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Flutter Project:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.folder, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        projectPath.isEmpty
                            ? 'No project selected'
                            : projectPath,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              projectPath.isEmpty ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: projectPath.isNotEmpty,
                      replacement: const SizedBox.shrink(),
                      child:
                          isValid
                              ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                              : const Icon(Icons.error, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onSelectProject,
              child: const Text('Browse'),
            ),
          ],
        ),
        if (projectPath.isNotEmpty && !isValid)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Invalid Flutter project. Please select a valid project.',
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
