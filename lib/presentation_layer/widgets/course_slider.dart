import '../../model/cours.dart';
import '../../pages/course_detail_page.dart';
import '../../services/workshop_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class CourseSlider extends StatefulWidget {
  const CourseSlider({super.key});
 

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
            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                final workshop = snapshot.data![index];
                return CourseTile(
                  id: workshop.id,
                  imageURL: workshop.imagePath,
                  rating: workshop.rating,
                  title: workshop.titre,
                  instructor: workshop.instructor,
                  bookmarked: workshop.bookmarked,
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

  final bool bookmarked;

  Widget child;

  CourseTile(
      {super.key,
      required this.id,
      required this.imageURL,
      required this.rating,
      required this.title,
      required this.instructor,
      required this.bookmarked,
      this.child = const SizedBox()});
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
                              rating,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Icon(
                              IconlyBold.star,
                              size: 15,
                              color: Colors.yellow[800],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 10,
                    child: Container(
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: (bookmarked)
                            ? const Icon(
                                IconlyBold.heart,
                                color: Colors.black,
                                size: 15,
                              )
                            : const Icon(
                                IconlyLight.heart,
                                color: Colors.black,
                                size: 15,
                              ),
                      ),
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
