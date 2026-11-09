import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await GameStore.load();
  runApp(LanguageConquerorApp(store: store));
}

const green = Color(0xFF178B68);
const dark = Color(0xFF172B28);
const gold = Color(0xFFFFC857);
const bg = Color(0xFFF4F7F5);

class LanguageConquerorApp extends StatelessWidget {
  final GameStore store;
  const LanguageConquerorApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Language Conqueror',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: green, brightness: Brightness.light),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(backgroundColor: bg, foregroundColor: dark, elevation: 0),
      cardTheme: CardThemeData(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    ),
    home: GameShell(store: store),
  );
}

class GameStore extends ChangeNotifier {
  final SharedPreferences prefs;
  String birthplace;
  String language;
  int xp;
  int learned;
  int streak;
  int completed;
  int tab = 0;

  GameStore._(this.prefs, this.birthplace, this.language, this.xp, this.learned, this.streak, this.completed);

  static Future<GameStore> load() async {
    final p = await SharedPreferences.getInstance();
    return GameStore._(
      p, p.getString('birthplace') ?? '北京', p.getString('language') ?? '英语',
      p.getInt('xp') ?? 0, p.getInt('learned') ?? 0, p.getInt('streak') ?? 1,
      p.getInt('completed') ?? 0,
    );
  }

  int get level => 1 + xp ~/ 100;
  double get levelProgress => (xp % 100) / 100;
  int get unlockedRegions => 1 + (learned ~/ 10).clamp(0, 8).toInt();

  void navigateTo(int v) { tab = v; notifyListeners(); }

  Future<void> setBirthplace(String v) async { birthplace = v; await prefs.setString('birthplace', v); notifyListeners(); }
  Future<void> setLanguage(String v) async { language = v; await prefs.setString('language', v); notifyListeners(); }
  Future<void> reward({int words = 0, int points = 20}) async {
    learned += words; xp += points; completed++;
    await prefs.setInt('learned', learned);
    await prefs.setInt('xp', xp);
    await prefs.setInt('completed', completed);
    notifyListeners();
  }
  Future<void> reset() async {
    xp = 0; learned = 0; completed = 0; streak = 1;
    await prefs.setInt('xp', 0); await prefs.setInt('learned', 0); await prefs.setInt('completed', 0);
    notifyListeners();
  }
}

class GameShell extends StatefulWidget {
  final GameStore store;
  const GameShell({super.key, required this.store});
  @override
  State<GameShell> createState() => _GameShellState();
}

class _GameShellState extends State<GameShell> {
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) => Scaffold(
      body: SafeArea(child: IndexedStack(index: widget.store.tab, children: [
        HomePage(store: widget.store),
        LearnPage(store: widget.store),
        WorldPage(store: widget.store),
        ProfilePage(store: widget.store),
      ])),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.store.tab,
        onDestinationSelected: (v) { widget.store.tab = v; setState(() {}); },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '首页'),
          NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: '学习'),
          NavigationDestination(icon: Icon(Icons.public_outlined), selectedIcon: Icon(Icons.public), label: '世界'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: '我的'),
        ],
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  final GameStore store;
  const HomePage({super.key, required this.store});

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 14, 20, 24), children: [
    Row(children: [
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('LANGUAGE CONQUEROR', style: TextStyle(fontSize: 11, letterSpacing: 2, color: green, fontWeight: FontWeight.w800)),
        SizedBox(height: 5), Text('今天也向世界\n迈进一步。', style: TextStyle(fontSize: 29, height: 1.18, fontWeight: FontWeight.w900, color: dark)),
      ])),
      CircleAvatar(radius: 25, backgroundColor: const Color(0xFFE1F2EB), child: Text(store.birthplace == '北京' ? '🐉' : '🌍', style: const TextStyle(fontSize: 25))),
    ]),
    const SizedBox(height: 20),
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF123D35), Color(0xFF178B68)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('你的征服进度', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const Icon(Icons.explore, color: gold, size: 26),
        ]),
        const SizedBox(height: 12),
        Text('Lv. ${store.level}', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
        Text('${store.xp} XP  ·  ${store.language}学习者', style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 16),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: store.levelProgress, minHeight: 9, backgroundColor: Colors.white24, color: gold)),
        const SizedBox(height: 8),
        Text('${store.xp % 100}/100 XP 升至下一级', style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ]),
    ),
    const SizedBox(height: 18),
    Row(children: [
      Expanded(child: _StatCard(icon: Icons.menu_book, label: '已掌握词汇', value: '${store.learned}', tint: const Color(0xFFE7F4EF))),
      const SizedBox(width: 10),
      Expanded(child: _StatCard(icon: Icons.flag, label: '已完成挑战', value: '${store.completed}', tint: const Color(0xFFFFF3D9))),
      const SizedBox(width: 10),
      Expanded(child: _StatCard(icon: Icons.local_fire_department, label: '连续学习', value: '${store.streak}天', tint: const Color(0xFFFFE9E3))),
    ]),
    const SizedBox(height: 22),
    const _SectionTitle('继续你的旅程', '每日学习'),
    const SizedBox(height: 10),
    InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () { store.navigateTo(1); },
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Container(width: 54, height: 54, decoration: BoxDecoration(color: const Color(0xFFE7F4EF), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.auto_stories, color: green, size: 28)),
          const SizedBox(width: 13),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('词汇远征 · 第 1 关', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            SizedBox(height: 4), Text('完成 5 道题，赢取经验值', style: TextStyle(color: Colors.black54, fontSize: 12)),
          ])),
          const Icon(Icons.arrow_forward_ios, size: 16, color: green),
        ]),
      ),
    ),
    const SizedBox(height: 22),
    const _SectionTitle('世界正在等待你', '地图进度'),
    const SizedBox(height: 10),
    WorldPreview(store: store, onTap: () { store.navigateTo(2); }),
  ]);
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String label, value; final Color tint;
  const _StatCard({required this.icon, required this.label, required this.value, required this.tint});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)), child: Column(children: [
    CircleAvatar(radius: 17, backgroundColor: tint, child: Icon(icon, size: 17, color: dark)),
    const SizedBox(height: 8), Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: dark)),
    const SizedBox(height: 2), Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54), textAlign: TextAlign.center),
  ]));
}

class _SectionTitle extends StatelessWidget {
  final String title, subtitle;
  const _SectionTitle(this.title, this.subtitle);
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: dark)),
    Text(subtitle, style: const TextStyle(fontSize: 11, color: green, fontWeight: FontWeight.w700)),
  ]);
}

class LearnPage extends StatefulWidget {
  final GameStore store;
  const LearnPage({super.key, required this.store});
  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  int index = 0;
  int? selected;
  bool answered = false;
  final List<Map<String, dynamic>> questions = [
    {'word':'apple','translation':'苹果','options':['苹果','香蕉','橙子','葡萄'],'answer':0,'tip':'I eat an apple. 我吃一个苹果。'},
    {'word':'travel','translation':'旅行','options':['学习','旅行','工作','睡觉'],'answer':1,'tip':'I love to travel. 我喜欢旅行。'},
    {'word':'beautiful','translation':'美丽的','options':['困难的','快速的','美丽的','安静的'],'answer':2,'tip':'What a beautiful day! 多么美好的一天！'},
    {'word':'discover','translation':'发现','options':['忘记','发现','保护','选择'],'answer':1,'tip':'Discover the world. 探索世界。'},
    {'word':'language','translation':'语言','options':['地图','语言','国家','朋友'],'answer':1,'tip':'Learn a new language. 学习一门新语言。'},
  ];

  void next() {
    if (index < questions.length - 1) { setState(() { index++; selected = null; answered = false; }); }
    else {
      widget.store.reward(words: correctCount, points: 20 + correctCount * 6);
      showDialog(context: context, builder: (_) => AlertDialog(
        title: const Text('挑战完成！🎉'),
        content: Text('你答对了 $correctCount / ${questions.length} 题，获得 ${20 + correctCount * 6} XP 和 $correctCount 个词汇进度。'),
        actions: [TextButton(onPressed: () { Navigator.pop(context); setState(() { index = 0; selected = null; answered = false; correctCount = 0; }); }, child: const Text('继续征服'))],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[index];
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('DAILY EXPEDITION', style: TextStyle(color: green, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w800)),
      const SizedBox(height: 7), const Text('词汇远征', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: dark)),
      const SizedBox(height: 5), Text('第 ${index + 1} / ${questions.length} 题 · 答对题目，积累征服力量', style: const TextStyle(color: Colors.black54, fontSize: 12)),
      const SizedBox(height: 18),
      ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: (index + 1) / questions.length, minHeight: 8, color: green, backgroundColor: const Color(0xFFDCE9E2))),
      const SizedBox(height: 28),
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF153E35), borderRadius: BorderRadius.circular(24)), child: Column(children: [
        const Text('请选择正确的中文意思', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 18),
        Text(q['word'], style: const TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8), const Text('🇬🇧  ENGLISH', style: TextStyle(color: gold, letterSpacing: 2, fontSize: 10)),
      ])),
      const SizedBox(height: 20),
      ...List.generate((q['options'] as List).length, (i) {
        final isCorrect = i == q['answer'];
        final isSelected = selected == i;
        Color border = const Color(0xFFE1E9E4), fill = Colors.white;
        if (answered && isCorrect) { border = green; fill = const Color(0xFFE5F5EE); }
        else if (answered && isSelected && !isCorrect) { border = Colors.redAccent; fill = const Color(0xFFFFEEEE); }
        return Padding(padding: const EdgeInsets.only(bottom: 10), child: InkWell(
          onTap: answered ? null : () => setState(() { selected = i; answered = true; if (i == q['answer']) correctCount++; }),
          borderRadius: BorderRadius.circular(15),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17), decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(15), border: Border.all(color: border, width: 1.5)),
            child: Row(children: [
              Expanded(child: Text((q['options'] as List)[i], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
              if (answered && isCorrect) const Icon(Icons.check_circle, color: green),
              if (answered && isSelected && !isCorrect) const Icon(Icons.cancel, color: Colors.redAccent),
            ]),
          ),
        ));
      }),
      if (answered) ...[
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFE7F4EF), borderRadius: BorderRadius.circular(14)), child: Text('${selected == q['answer'] ? '回答正确！' : '正确答案：${q['translation']}'}\n${q['tip']}', style: const TextStyle(height: 1.6, color: dark))),
        const SizedBox(height: 14),
        FilledButton(onPressed: next, style: FilledButton.styleFrom(backgroundColor: green, padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(index == questions.length - 1 ? '完成挑战' : '下一题')),
      ],
    ]);
  }
}

class WorldPreview extends StatelessWidget {
  final GameStore store; final VoidCallback onTap;
  const WorldPreview({super.key, required this.store, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Container(
    padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: const Color(0xFF153E35), borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('WORLD MAP', style: TextStyle(color: gold, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w800)), Icon(Icons.open_in_full, color: Colors.white70, size: 17)]),
      const SizedBox(height: 12),
      const WorldArt(height: 118),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('起点：${store.birthplace}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        Text('${store.unlockedRegions}/9 区域已解锁', style: const TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    ]),
  ));
}

class WorldArt extends StatelessWidget {
  final double height;
  const WorldArt({super.key, this.height = 220});
  @override
  Widget build(BuildContext context) => SizedBox(height: height, width: double.infinity, child: CustomPaint(painter: WorldPainter()));
}

class WorldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final land = Paint()..color = const Color(0xFF5CA889)..style = PaintingStyle.fill;
    final land2 = Paint()..color = const Color(0xFF347A63)..style = PaintingStyle.fill;
    final glow = Paint()..color = gold.withOpacity(.9);
    final paths = <Path>[
      Path()..moveTo(.08*size.width,.25*size.height)..cubicTo(.12*size.width,.02*size.height,.33*size.width,.04*size.height,.42*size.width,.25*size.height)..cubicTo(.48*size.width,.4*size.height,.36*size.width,.52*size.height,.3*size.width,.58*size.height)..cubicTo(.2*size.width,.66*size.height,.07*size.width,.5*size.height,.08*size.width,.25*size.height),
      Path()..moveTo(.43*size.width,.55*size.height)..cubicTo(.49*size.width,.43*size.height,.57*size.width,.5*size.height,.59*size.width,.67*size.height)..cubicTo(.61*size.width,.88*size.height,.49*size.width,.96*size.height,.45*size.width,.78*size.height)..close(),
      Path()..moveTo(.53*size.width,.18*size.height)..cubicTo(.67*size.width,.02*size.height,.9*size.width,.08*size.height,.95*size.width,.27*size.height)..cubicTo(.99*size.width,.43*size.height,.84*size.width,.48*size.height,.77*size.width,.4*size.height)..cubicTo(.68*size.width,.34*size.height,.59*size.width,.4*size.height,.53*size.width,.18*size.height),
      Path()..moveTo(.76*size.width,.65*size.height)..cubicTo(.85*size.width,.55*size.height,.97*size.width,.62*size.height,.94*size.width,.78*size.height)..cubicTo(.9*size.width,.91*size.height,.78*size.width,.9*size.height,.76*size.width,.65*size.height),
    ];
    for (int i=0;i<paths.length;i++) { canvas.drawPath(paths[i], i==2 ? land : land2); }
    canvas.drawCircle(Offset(.73*size.width,.29*size.height), 5, glow);
    canvas.drawCircle(Offset(.73*size.width,.29*size.height), 11, Paint()..color=gold.withOpacity(.18));
    final line = Paint()..color=gold.withOpacity(.75)..strokeWidth=1.5..style=PaintingStyle.stroke;
    canvas.drawLine(Offset(.73*size.width,.29*size.height),Offset(.42*size.width,.35*size.height),line);
    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = const TextSpan(text:'✦',style:TextStyle(color:Color(0xFFFFC857),fontSize:16)); tp.layout(); tp.paint(canvas,Offset(.7*size.width,.1*size.height));
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WorldPage extends StatelessWidget {
  final GameStore store;
  const WorldPage({super.key, required this.store});
  static const regions = [
    ('🏯','起点城市','你的冒险从这里开始',0),
    ('🌏','东亚探索区','认识更多词汇，探索邻近区域',10),
    ('🏔️','中亚探索区','完成更多词汇挑战',20),
    ('🕌','西亚探索区','扩大你的语言版图',30),
    ('🏰','欧洲探索区','开启新的语言文化路线',40),
    ('🗽','北美探索区','向更远的世界前进',50),
    ('🌴','南美探索区','发现新的表达方式',60),
    ('🦁','非洲探索区','继续积累语言能力',70),
    ('🦘','大洋洲探索区','完成全球探索旅程',80),
  ];
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('YOUR WORLD', style: TextStyle(color: green, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w800)),
    const SizedBox(height: 6), const Text('世界地图', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: dark)),
    const SizedBox(height: 5), Text('从${store.birthplace}出发，用${store.language}解锁世界。', style: const TextStyle(color: Colors.black54)),
    const SizedBox(height: 17),
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF153E35), borderRadius: BorderRadius.circular(22)), child: const WorldArt(height: 190)),
    const SizedBox(height: 17),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('探索区域', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      Text('${store.unlockedRegions} / 9 已解锁', style: const TextStyle(color: green, fontWeight: FontWeight.w800, fontSize: 12)),
    ]),
    const SizedBox(height: 10),
    ...regions.asMap().entries.map((entry) {
      final r = entry.value; final unlocked = entry.key < store.unlockedRegions;
      return Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: unlocked ? const Color(0xFFD8EAE1) : const Color(0xFFE9ECEA))),
        child: Row(children: [
          Container(width: 44,height:44,alignment:Alignment.center,decoration:BoxDecoration(color:unlocked?const Color(0xFFE5F4ED):const Color(0xFFF0F1F0),borderRadius:BorderRadius.circular(13)),child:Text(unlocked?r.$1:'🔒',style:const TextStyle(fontSize:23))),
          const SizedBox(width:12),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(r.$2,style:const TextStyle(fontWeight:FontWeight.w800)),
            const SizedBox(height:3),Text(unlocked?r.$3:'需要累计掌握 ${r.$4} 个词汇',style:const TextStyle(color:Colors.black54,fontSize:11)),
          ])),
          Icon(unlocked?Icons.check_circle:Icons.lock_outline,color:unlocked?green:Colors.black26,size:19),
        ]),
      );
    }),
  ]);
}

class ProfilePage extends StatelessWidget {
  final GameStore store;
  const ProfilePage({super.key, required this.store});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('PLAYER PROFILE', style: TextStyle(color: green, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w800)),
    const SizedBox(height: 7), const Text('我的冒险档案', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: dark)),
    const SizedBox(height: 20),
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF153E35), borderRadius: BorderRadius.circular(22)), child: Row(children: [
      const CircleAvatar(radius: 29, backgroundColor: Color(0xFF286D59), child: Icon(Icons.explore, color: gold, size: 31)),
      const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('世界探索者 · Lv.${store.level}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
        Text('${store.xp} XP  ·  已掌握 ${store.learned} 个词汇', style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ])),
    ])),
    const SizedBox(height: 22),
    const Text('冒险设置', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
    const SizedBox(height: 10),
    _SettingTile(icon: Icons.location_on_outlined, title: '我的出生地', subtitle: store.birthplace, child: DropdownButton<String>(
      value: store.birthplace, underline: const SizedBox(), items: ['北京','上海','广州','成都','纽约','洛杉矶','巴黎','伦敦','东京'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),
      onChanged: (v) { if(v!=null) store.setBirthplace(v); },
    )),
    _SettingTile(icon: Icons.translate, title: '正在学习', subtitle: '选择你的目标语言', child: DropdownButton<String>(
      value: store.language, underline: const SizedBox(), items: ['英语','中文'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),
      onChanged: (v) { if(v!=null) store.setLanguage(v); },
    )),
    const SizedBox(height: 20),
    OutlinedButton.icon(onPressed: () => showDialog(context: context, builder: (d)=>AlertDialog(
      title: const Text('重置学习进度？'), content: const Text('这会清除经验值、词汇和挑战记录。出生地与语言设置会保留。'),
      actions: [TextButton(onPressed:()=>Navigator.pop(d),child:const Text('取消')),TextButton(onPressed:(){store.reset();Navigator.pop(d);},child:const Text('重置'))],
    )), icon: const Icon(Icons.restart_alt), label: const Text('重置学习进度')),
    const SizedBox(height: 18),
    const Text('Language Conqueror · MVP 1.0', textAlign: TextAlign.center, style: TextStyle(color: Colors.black38, fontSize: 11)),
  ]);
}

class _SettingTile extends StatelessWidget {
  final IconData icon; final String title, subtitle; final Widget child;
  const _SettingTile({required this.icon,required this.title,required this.subtitle,required this.child});
  @override
  Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.symmetric(horizontal:14,vertical:8),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),child:Row(children:[
    Icon(icon,color:green),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w800)),Text(subtitle,style:const TextStyle(color:Colors.black45,fontSize:11))])),child,
  ]));
}
