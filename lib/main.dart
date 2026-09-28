import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const bg = Color(0xFF0E0B1A);
const card = Color(0xFF1A1530);
const line = Color(0xFF3B2F6B);
const violet = Color(0xFF7C5CFF);
const soft = Color(0xFFB9A8FF);
const muted = Color(0xFFA99BD8);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(const NovaApp());
}

class NovaApp extends StatelessWidget {
  const NovaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nova',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: bg,
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(primary: violet),
        ),
        home: const SplashPage(),
      );
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600));
  late final AnimationController _ring = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat();

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const SignupPage(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_c, _ring]),
          builder: (_, __) {
            final pop = const Interval(0, .3, curve: Curves.elasticOut)
                .transform(_c.value);
            final name = const Interval(.15, .4, curve: Curves.easeOut)
                .transform(_c.value);
            final prog = const Interval(.1, 1, curve: Curves.easeInOut)
                .transform(_c.value);
            final r = _ring.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: (1 - r) * .8,
                      child: Transform.scale(
                        scale: 1 + .9 * r,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: violet, width: 2),
                          ),
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: pop,
                      child: Transform.rotate(
                        angle: (1 - pop.clamp(0.0, 1.0)) * -.35,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: violet,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.bolt,
                              size: 32, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Opacity(
                  opacity: name,
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - name)),
                    child: const Text('NOVA',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 3,
                            color: Color(0xFFF1EDFF))),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 120,
                  height: 3,
                  decoration: BoxDecoration(
                      color: const Color(0xFF2A2247),
                      borderRadius: BorderRadius.circular(2)),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: prog,
                    child: Container(
                        decoration: BoxDecoration(
                            color: soft,
                            borderRadius: BorderRadius.circular(2))),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500))
    ..forward();
  bool _hide = true;
  bool _loading = false;
  bool _done = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _stag(int i, Widget child) {
    final s = (i * .09).clamp(0.0, .6);
    final a = CurvedAnimation(
        parent: _c, curve: Interval(s, s + .4, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, .25), end: Offset.zero)
            .animate(a),
        child: child,
      ),
    );
  }

  Widget _field(String hint, IconData icon,
      {bool pass = false, TextInputType? type}) {
    OutlineInputBorder b(Color c, double w) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w));
    return TextField(
      obscureText: pass && _hide,
      keyboardType: type,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: muted, fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: muted),
        suffixIcon: pass
            ? IconButton(
                icon: Icon(
                    _hide
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: muted),
                onPressed: () => setState(() => _hide = !_hide),
              )
            : null,
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        enabledBorder: b(line, .6),
        focusedBorder: b(violet, 1.2),
      ),
    );
  }

  Future<void> _submit() async {
    if (_loading || _done) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _stag(
                0,
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Crée ton compte',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFF1EDFF))),
                    SizedBox(height: 6),
                    Text('Rejoins Nova en quelques secondes.',
                        style: TextStyle(fontSize: 14, color: muted)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _stag(1, _field('Nom complet', Icons.person_outline)),
              const SizedBox(height: 14),
              _stag(2, _field('Adresse e-mail', Icons.mail_outline,
                  type: TextInputType.emailAddress)),
              const SizedBox(height: 14),
              _stag(3, _field('Mot de passe', Icons.lock_outline, pass: true)),
              const SizedBox(height: 24),
              _stag(
                4,
                GestureDetector(
                  onTap: _submit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _done ? const Color(0xFF2FBF71) : violet,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _loading
                          ? const SizedBox(
                              key: ValueKey('l'),
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.4, color: Colors.white))
                          : _done
                              ? const Row(
                                  key: ValueKey('d'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text('Compte créé',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                )
                              : const Text('Créer mon compte',
                                  key: ValueKey('i'),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _stag(
                5,
                const Center(
                  child: Text('ou continuer avec',
                      style: TextStyle(fontSize: 12, color: muted)),
                ),
              ),
              const SizedBox(height: 14),
              _stag(
                6,
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF1EDFF),
                      side: const BorderSide(color: line, width: .8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _stag(
                7,
                const Center(
                  child: Text.rich(TextSpan(
                    text: 'Déjà un compte ? ',
                    style: TextStyle(fontSize: 13, color: muted),
                    children: [
                      TextSpan(
                          text: 'Se connecter',
                          style: TextStyle(color: soft)),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
