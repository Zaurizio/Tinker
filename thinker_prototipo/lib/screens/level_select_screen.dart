import 'package:flutter/material.dart';
import 'package:tinker/data/level_theme.dart';
import 'package:tinker/homepage.dart';
import 'package:tinker/screens/game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int currentIndex = 0;

  void _goLeft() {
    setState(() {
      currentIndex = (currentIndex - 1 + levelThemes.length) % levelThemes.length;
    });
  }

  void _goRight() {
    setState(() {
      currentIndex = (currentIndex + 1) % levelThemes.length;
    });
  }

  void _play(LevelTheme theme) {
    if (!theme.unlocked) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameScreen(startingLevel: theme.levelFileName)),
    );
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Homepage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = levelThemes[currentIndex];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 36, 1),
      body: Stack(
        children: [
          const Positioned.fill(child: _ParallaxBackground()),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: _goHome,
                      icon: const Icon(Icons.home, color: Colors.white, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ESCOLHA A FASE',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pixel'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ArrowButton(asset: 'assets/images/UI/Esquerda.png', onTap: _goLeft),
                      const SizedBox(width: 32),
                      GestureDetector(
                        onTap: () => _play(theme),
                        child: _ThemeCard(theme: theme),
                      ),
                      const SizedBox(width: 32),
                      _ArrowButton(asset: 'assets/images/UI/Direita.png', onTap: _goRight),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Text(
                    '${currentIndex + 1} / ${levelThemes.length}',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParallaxBackground extends StatefulWidget {
  const _ParallaxBackground();

  @override
  State<_ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<_ParallaxBackground>
    with SingleTickerProviderStateMixin {
  // Troque aqui pra usar outro fundo: Blue, Brown, Gray, Green, Pink, Purple ou Yellow.
  static const String _imagemEscolhida = 'assets/images/Background/Blue.png';

  static const double _tamanhoTile = 128;

  late final AnimationController _controlador;
  int _colunas = 0;
  int _linhas = 0;

  @override
  void initState() {
    super.initState();
    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _atualizarGradeSeNecessario(double largura, double altura) {
    _colunas = (largura / _tamanhoTile).ceil() + 1;
    _linhas = (altura / _tamanhoTile).ceil() + 1;
  }

  Widget _construirGrade() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_linhas, (linha) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_colunas, (coluna) {
            return Image.asset(
              _imagemEscolhida,
              width: _tamanhoTile,
              height: _tamanhoTile,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            );
          }),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final altura = constraints.maxHeight;
        _atualizarGradeSeNecessario(largura, altura);

        final alturaGrade = _linhas * _tamanhoTile;

        return ClipRect(
          child: AnimatedBuilder(
            animation: _controlador,
            builder: (context, _) {
              final deslocamento = _controlador.value * alturaGrade;
              return Stack(
                children: [
                  Positioned(top: deslocamento - alturaGrade, left: 0, child: _construirGrade()),
                  Positioned(top: deslocamento, left: 0, child: _construirGrade()),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;
  const _ArrowButton({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            asset,
            width: 32,
            height: 32,
            filterQuality: FilterQuality.none,
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final LevelTheme theme;
  const _ThemeCard({required this.theme});

  static const double _cardWidth = 424;
  static const double _cardHeight = 392;
  static const Rect _centerSlice = Rect.fromLTRB(54, 54, 170, 138);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _cardWidth,
      height: _cardHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              theme.previewImage,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              'assets/images/UI/Moldura.png',
              centerSlice: _centerSlice,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),
          Positioned(
            bottom: 20,
            child: Text(
              theme.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pixel',
              ),
            ),
          ),
          if (!theme.unlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/UI/Lock.png',
                    width: 120,
                    height: 120,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}