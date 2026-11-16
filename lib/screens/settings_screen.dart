import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/core/theme_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Aparência e tema',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tema escuro'),
                  subtitle: const Text('Ativa o visual premium noturno'),
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (val) {
                    themeProvider.setThemeModePreference(val
                        ? AppThemeModePreference.dark
                        : AppThemeModePreference.light);
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Estilo de cores'),
                  subtitle: const Text('Personalize a identidade do app'),
                  trailing: DropdownButton<AppThemeStyle>(
                    value: themeProvider.style,
                    items: const [
                      DropdownMenuItem(
                          value: AppThemeStyle.blue,
                          child: Text('Grafite / Laranja')),
                      DropdownMenuItem(
                          value: AppThemeStyle.pink,
                          child: Text('Azul / Preto')),
                    ],
                    onChanged: (val) {
                      if (val != null) themeProvider.setThemeStyle(val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _buildSection(
            context,
            title: 'Conta',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.logout, color: Colors.red.shade400),
              title: const Text('Sair do aplicativo',
                  style: TextStyle(color: Colors.red)),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.red.shade400),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required Widget child}) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
