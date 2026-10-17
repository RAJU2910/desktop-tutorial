import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const InstaLiteApp());

const ink = Color(0xFF171717);
const muted = Color(0xFF777777);
const accent = Color(0xFFDD2A7B);

class InstaLiteApp extends StatelessWidget {
  const InstaLiteApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'InstaLite',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: accent),
      scaffoldBackgroundColor: Colors.white, appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: ink)),
    home: const LoginPage(),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool hide = true;
  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  void signIn() {
    if (!form.currentState!.validate()) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(email: email.text.trim())));
  }
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: SingleChildScrollView(
    padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 380),
    child: Form(key: form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 24),
      const Icon(Icons.camera_alt_outlined, size: 52),
      const SizedBox(height: 8),
      const Text('InstaLite', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'cursive', fontSize: 42, fontWeight: FontWeight.bold)),
      const SizedBox(height: 28),
      TextFormField(controller: email, keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Email or username', border: OutlineInputBorder()),
        validator: (v) => v == null || v.trim().isEmpty ? 'Enter your email or username' : null),
      const SizedBox(height: 12),
      TextFormField(controller: password, obscureText: hide,
        decoration: InputDecoration(labelText: 'Password', border: const OutlineInputBorder(),
          suffixIcon: IconButton(onPressed: () => setState(() => hide = !hide), icon: Icon(hide ? Icons.visibility : Icons.visibility_off))),
        validator: (v) => v == null || v.length < 4 ? 'Use at least 4 characters' : null),
      const SizedBox(height: 18),
      FilledButton(style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, padding: const EdgeInsets.all(15)),
        onPressed: signIn, child: const Text('Log in')),
      const SizedBox(height: 18),
      const Text('OR', textAlign: TextAlign.center, style: TextStyle(color: muted)),
      const SizedBox(height: 18),
      OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage())),
        child: const Text('Create new account')),
      const SizedBox(height: 18),
      const Text('Demo app: use any email/username and a password with 4+ characters.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: muted)),
    ]))))));
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}
class _SignupPageState extends State<SignupPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(), email = TextEditingController(), password = TextEditingController();
  @override
  void dispose() { name.dispose(); email.dispose(); password.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Create account')),
    body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400), child: Form(key: form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(Icons.person_add_alt_1, size: 48), const SizedBox(height: 16),
        const Text('Join InstaLite', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder()),
          validator: (v) => v == null || v.trim().isEmpty ? 'Enter your name' : null),
        const SizedBox(height: 12),
        TextFormField(controller: email, keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email address', border: OutlineInputBorder()),
          validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null),
        const SizedBox(height: 12),
        TextFormField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
          validator: (v) => v == null || v.length < 4 ? 'Use at least 4 characters' : null),
        const SizedBox(height: 18),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, padding: const EdgeInsets.all(15)),
          onPressed: () { if (form.currentState!.validate()) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(email: email.text.trim(), displayName: name.text.trim()))); },
          child: const Text('Sign up')),
        const SizedBox(height: 12),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Already have an account? Log in')),
        const SizedBox(height: 12),
        const Text('Demo only: account details are not saved to a server.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 12)),
      ]))))));
}

class Post {
  final int id; final String title, body;
  const Post(this.id, this.title, this.body);
  factory Post.fromJson(Map<String, dynamic> j) => Post(j['id'] as int, j['title'] as String, j['body'] as String);
}
class HomePage extends StatefulWidget {
  final String email; final String? displayName;
  const HomePage({super.key, required this.email, this.displayName});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  int tab = 0;
  late Future<List<Post>> posts;
  final liked = <int>{};
  @override
  void initState() { super.initState(); posts = loadPosts(); }
  Future<List<Post>> loadPosts() async {
    final res = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=12')).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('API request failed: ${res.statusCode}');
    return (jsonDecode(res.body) as List).map((x) => Post.fromJson(x as Map<String, dynamic>)).toList();
  }
  String get username => (widget.displayName?.trim().isNotEmpty == true ? widget.displayName! : widget.email.split('@').first);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('InstaLite', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, fontFamily: 'cursive')),
      actions: [IconButton(tooltip: 'Messages', onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Messaging will be added in a future version.'))), icon: const Icon(Icons.send_outlined))]),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650), child: tab == 2 ? profile() : tab == 1 ? explore() : feed())),
    bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v),
      destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Explore'), NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile')]),
  );
  Widget stories() => SizedBox(height: 112, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    children: [story('Your story', 0), story('alex', 1), story('priya', 2), story('sam', 3), story('maria', 4), story('dev', 5)]));
  Widget story(String name, int i) => SizedBox(width: 76, child: Column(children: [
    Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: i == 0 ? Colors.grey.shade300 : accent, width: 2)),
      child: CircleAvatar(radius: 27, backgroundColor: Colors.primaries[i % Colors.primaries.length].shade100,
        child: Icon(i == 0 ? Icons.add : Icons.person, color: Colors.primaries[i % Colors.primaries.length]))),
    const SizedBox(height: 5), Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))
  ]));
  Widget feed() => FutureBuilder<List<Post>>(future: posts, builder: (context, snap) {
    if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
    if (snap.hasError) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.wifi_off, size: 40), const Text('Could not load the feed.'),
      TextButton(onPressed: () => setState(() => posts = loadPosts()), child: const Text('Try again'))]));
    final data = snap.data ?? [];
    return RefreshIndicator(onRefresh: () async => setState(() => posts = loadPosts()), child: ListView(padding: EdgeInsets.zero, children: [
      stories(),
      const Divider(height: 1),
      for (final p in data) postCard(p),
      const Padding(padding: EdgeInsets.all(20), child: Text('Demo posts are provided by JSONPlaceholder. Photos, comments, and likes are not stored.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 12)))
    ]));
  });
  Widget postCard(Post p) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    ListTile(leading: CircleAvatar(backgroundColor: Colors.primaries[p.id % Colors.primaries.length].shade100, child: const Icon(Icons.person)),
      title: Text('user${p.id}', style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('Suggested for you'),
      trailing: IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post options are demo-only.'))), icon: const Icon(Icons.more_horiz))),
    Container(height: 210, color: Colors.primaries[p.id % Colors.primaries.length].shade100,
      child: Center(child: Icon(Icons.photo_camera_back_outlined, size: 80, color: Colors.primaries[p.id % Colors.primaries.length].shade400))),
    Row(children: [
      IconButton(onPressed: () => setState(() { liked.contains(p.id) ? liked.remove(p.id) : liked.add(p.id); }),
        icon: Icon(liked.contains(p.id) ? Icons.favorite : Icons.favorite_border, color: liked.contains(p.id) ? Colors.red : ink)),
      IconButton(onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Comments'), content: const Text('Comments are not available in this demo.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))])),
        icon: const Icon(Icons.mode_comment_outlined)),
      IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share is demo-only.'))), icon: const Icon(Icons.send_outlined)),
    ]),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('${liked.contains(p.id) ? 'You and others' : 'Liked by'}', style: const TextStyle(fontWeight: FontWeight.bold))),
    Padding(padding: const EdgeInsets.fromLTRB(16, 6, 16, 16), child: Text.rich(TextSpan(children: [
      TextSpan(text: 'user${p.id} ', style: const TextStyle(fontWeight: FontWeight.bold)),
      TextSpan(text: p.title),
      TextSpan(text: '\n${p.body}', style: const TextStyle(color: muted)),
    ]))),
    const Divider(height: 1),
  ]);
  Widget explore() => FutureBuilder<List<Post>>(future: posts, builder: (context, snap) {
    if (!snap.hasData) return const Center(child: CircularProgressIndicator());
    return GridView.builder(padding: const EdgeInsets.all(3), itemCount: snap.data!.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3),
      itemBuilder: (_, i) => Container(color: Colors.primaries[i % Colors.primaries.length].shade100,
        child: Center(child: Icon(Icons.image_outlined, size: 42, color: Colors.primaries[i % Colors.primaries.length].shade400))));
  });
  Widget profile() => ListView(padding: const EdgeInsets.all(24), children: [
    Row(children: [const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 42)), const SizedBox(width: 24),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8), const Text('0 posts    120 followers    180 following'),
        const SizedBox(height: 10), OutlinedButton(onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Edit profile'), content: Text('Signed in as ${widget.email}'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))])), child: const Text('Edit profile')),
      ]))]),
    const Divider(height: 32),
    const ListTile(leading: Icon(Icons.email_outlined), title: Text('Email'), subtitle: Text('Your demo login email')),
    ListTile(leading: const Icon(Icons.alternate_email), title: const Text('Account'), subtitle: Text(widget.email)),
    const SizedBox(height: 20),
    OutlinedButton.icon(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false),
      icon: const Icon(Icons.logout), label: const Text('Log out')),
    const SizedBox(height: 16),
    const Text('Profile information is temporary and stored only in this app session.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 12)),
  ]);
}
