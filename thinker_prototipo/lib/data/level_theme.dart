class LevelTheme {
  final String name;
  final String levelFileName; 
  final String previewImage; 
  bool unlocked;

  LevelTheme({
    required this.name,
    required this.levelFileName,
    required this.previewImage,
    this.unlocked = false,
  });
}


final List<LevelTheme> levelThemes = [
  LevelTheme(
    name: 'Floresta',
    levelFileName: 'level_01',
    previewImage: 'assets/images/Background/JungleBackground.png',
    unlocked: true,
  ),
  LevelTheme(
    name: 'Laboratório',
    levelFileName: 'level_02',
    previewImage: 'assets/images/Background/LaboratorioBackground.png',
    unlocked: false,
  ),
];

void unlockNextTheme(String completedLevelFileName) {
  final index = levelThemes.indexWhere((t) => t.levelFileName == completedLevelFileName);
  if (index != -1 && index + 1 < levelThemes.length) {
    levelThemes[index + 1].unlocked = true;
  }
}