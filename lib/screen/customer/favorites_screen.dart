import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/favorites_provider.dart';
import '../../model/favorite_model.dart';
import '../../widget/inggo_modal.dart';
import '../shared/widgets/profile_scaffold.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return ProfileScaffold(
      title: 'Adresses favorites',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFavoriteModal(context, ref),
        backgroundColor: const Color(0xFFFFC107),
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
      body: favorites.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFC107)),
        ),
        error: (err, stack) => Center(
          child: Text('Erreur: $err', style: const TextStyle(color: Colors.red)),
        ),
        data: (favList) {
          if (favList.isEmpty) {
            return const Center(
              child: Text(
                'Aucun favori.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF757575),
                  fontFamily: 'Roboto',
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 80),
            itemCount: favList.length,
            itemBuilder: (context, index) {
              final fav = favList[index];
              return _FavoriteItem(
                favorite: fav,
                onDelete: () => _showDeleteFavoriteModal(context, ref, fav.id),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddFavoriteModal(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final addrController = TextEditingController();

    showInggoModal(
      context: context,
      title: 'Nouveau favori',
      content: Column(
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: nameController,
              style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                hintText: 'Nom (ex: Salle de sport)',
              ),
            ),
          ),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: addrController,
              style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                hintText: 'Adresse (ex: Héron)',
              ),
            ),
          ),
        ],
      ),
      actions: [
        InggoModalButton(
          label: 'Annuler',
          isOutline: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        InggoModalButton(
          label: 'Ajouter',
          backgroundColor: const Color(0xFFFFC107),
          textColor: Colors.black,
          onPressed: () {
            final name = nameController.text.trim();
            final addr = addrController.text.trim();
            if (name.isNotEmpty && addr.isNotEmpty) {
              ref.read(favoritesProvider.notifier).addFavorite(name, addr);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Favori ajouté'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  void _showDeleteFavoriteModal(
      BuildContext context, WidgetRef ref, int id) {
    showInggoModal(
      context: context,
      title: 'Supprimer ?',
      titleColor: const Color(0xFFFF4D4D),
      content: const Text(
        'Voulez-vous vraiment supprimer ce favori ?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF757575),
          height: 1.5,
          fontFamily: 'Roboto',
        ),
      ),
      actions: [
        InggoModalButton(
          label: 'Annuler',
          isOutline: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        InggoModalButton(
          label: 'Supprimer',
          backgroundColor: const Color(0xFFFF4D4D),
          onPressed: () {
            ref.read(favoritesProvider.notifier).removeFavorite(id);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Favori supprimé'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _FavoriteItem extends StatelessWidget {
  final FavoriteModel favorite;
  final VoidCallback onDelete;

  const _FavoriteItem({required this.favorite, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Row(
            children: [
              // Icône box
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: favorite.bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    Icon(favorite.icon, size: 24, color: favorite.iconColor),
              ),
              const SizedBox(width: 15),
              // Nom + adresse
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favorite.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF121212),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      favorite.address,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton supprimer
              GestureDetector(
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.delete_outline,
                      color: Color(0xFFDDDDDD), size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
