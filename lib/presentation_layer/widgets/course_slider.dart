import 'package:firebase_auth/firebase_auth.dart';

import '../../model/cours.dart';
import '../Screens/course_detail_page.dart';
import '../Screens/favorisManager.dart';
import '../../services/workshop_service.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class CourseSlider extends StatefulWidget {
  final String searchLetter;
  const CourseSlider({super.key, required this.searchLetter});

  @override
  State<CourseSlider> createState() => _CourseSliderState();
}

class _CourseSliderState extends State<CourseSlider> {
  final WorkshopService _workshopService = WorkshopService();
  late Future<List<Cours>> _workshopsFuture;
  @override
  void initState() {
    super.initState();
    _workshopsFuture = _fetchWorkshops();
  }

  Future<List<Cours>> _fetchWorkshops() async {
    try {
      return await _workshopService.getAllWorkshops();
    } catch (e) {
      debugPrint('Error fetching workshops: $e');
      rethrow;
    }
  }

  List<Cours> _filterWorkshops(List<Cours> workshops, String searchLetter) {
    if (searchLetter.isEmpty) return workshops;

    return workshops.where((workshop) {
      if (workshop.titre.isEmpty) return false;
      return workshop.titre[0].toLowerCase() == searchLetter.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: FutureBuilder<List<Cours>>(
        future: _workshopsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No workshops available'));
          } else {
           
            final filteredWorkshops =
                _filterWorkshops(snapshot.data!, widget.searchLetter);

            if (filteredWorkshops.isEmpty) {
              return const Center(child: Text('Aucun cours trouvé'));
            }
            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: filteredWorkshops.length,
              itemBuilder: (BuildContext context, int index) {
                final workshop = filteredWorkshops[index];
                return CourseTile(
                  id: workshop.id,
                  imageURL: workshop.imagePath,
                  rating: workshop.rating,
                  title: workshop.titre,
                  instructor: workshop.instructor,
                  bookmarked: workshop.bookmarked,
                  classe: workshop.classe,
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CourseTile extends StatelessWidget {
  String? id;
  final String imageURL;
  final String rating;
  final String title;
  final String instructor;
  final String classe;
  final bool bookmarked;

  Widget child;

  CourseTile(
      {super.key,
      required this.id,
      required this.imageURL,
      required this.rating,
      required this.title,
      required this.instructor,
      required this.classe,
      required this.bookmarked,
      this.child = const SizedBox()});
  Future<void> _toggleFavorite(BuildContext context) async {
    if (id == null) return;
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) return;

    try {
      await FavoriteManager().toggleFavorite(
        Cours(
          id: id!,
          titre: title,
          description: '', 
          instructor: instructor,
          rating: rating,
          bookmarked:
              !FavoriteManager().isFavoriteById(id!), 
          matiere: '', 
          classe: classe,
          imagePath: imageURL,
          lessons: [], 
          exercice: Exercice(titre: '', exerciceUrl: ''),
          workshopDuration: '', 
        ),
        userEmail,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void selectedCourse(BuildContext context) {
    if (id == null || id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course ID is missing')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseDetailPage(courseId: id!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() => selectedCourse(context)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8, right: 5),
              constraints: const BoxConstraints.expand(height: 150, width: 250),
              padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                      image: AssetImage(imageURL), fit: BoxFit.cover)),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 10,
                    child: Container(
                      height: 25,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              classe,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow[800]),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            // Icon(
                            //   IconlyBold.star,
                            //   size: 15,
                            //   color: Colors.yellow[800],
                            // )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 10,
                    child: ListenableBuilder(
                      listenable: FavoriteManager(),
                      builder: (context, _) {
                        final isFavorite = id != null
                            ? FavoriteManager().isFavoriteById(id!)
                            : false;
                        return GestureDetector(
                          onTap: () => _toggleFavorite(context),
                          child: Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                isFavorite
                                    ? IconlyBold.heart
                                    : IconlyLight.heart,
                                color: isFavorite ? Colors.red : Colors.black,
                                size: 15,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
            Text(
              instructor,
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
