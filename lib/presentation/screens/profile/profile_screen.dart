import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../widgets/glass_container.dart';
import '../../../../data/repositories/supabase_repository.dart';
import '../../../../data/models/supabase_models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repository = SupabaseRepository();
  Profile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _repository.getProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _repository.signOut();
      if (mounted) context.go('/login');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao sair: $e')));
      }
    }
  }

  Future<void> _navigateToEditProfile() async {
    final result = await context.push('/edit-profile', extra: _profile);
    if (result == true) {
      // Reload profile after editing
      setState(() => _isLoading = true);
      await _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDarkMode;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              GestureDetector(
                onTap: _navigateToEditProfile,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryColor.withValues(
                        alpha: 0.2,
                      ),
                      backgroundImage: _profile?.avatarUrl != null
                          ? NetworkImage(_profile!.avatarUrl!)
                          : null,
                      child: _profile?.avatarUrl == null
                          ? Text(
                              _profile?.fullName
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                _profile?.fullName ?? 'Usuário',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _profile?.email ?? '',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Settings Section
              GlassContainer(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Editar Perfil'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _navigateToEditProfile,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                      ),
                      title: const Text('Tema Escuro'),
                      trailing: Switch.adaptive(
                        value: isDark,
                        activeThumbColor: AppTheme.primaryColor,
                        onChanged: (value) {
                          themeNotifier.toggleTheme(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Logout Button
              GlassContainer(
                color: Colors.red.withValues(alpha: 0.1),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Sair da Conta',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: _signOut,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
