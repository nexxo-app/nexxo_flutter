import 'package:flutter/material.dart';
import 'widgets/news_card.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notícias')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        itemBuilder: (context, index) {
          return const NewsCard(
            title:
                'Banco Central anuncia novas regras para o Pix a partir do próximo mês',
            source: 'CNN Brasil',
            timeAgo: '2h atrás',
            imageUrl: '', // Placeholder
          );
        },
      ),
    );
  }
}
