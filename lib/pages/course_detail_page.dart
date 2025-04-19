import 'package:bloc_test/model/cours.dart';
import 'package:bloc_test/pages/lesson_detail_page.dart';
import 'package:bloc_test/presentation_layer/widgets/CustomProgressBar.dart';
import 'package:bloc_test/services/workshop_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;

  const CourseDetailPage({super.key, required this.courseId});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late Future<Cours> _courseFuture;
  final WorkshopService _workshopService = WorkshopService();

  @override
  void initState() {
    super.initState();
    _courseFuture = _fetchCourse();
  }

  Future<Cours> _fetchCourse() async {
    try {
      debugPrint('Fetching course with ID: ${widget.courseId}');
      final workshops = await _workshopService.getAllWorkshops();

      debugPrint('Total workshops fetched: ${workshops.length}');
      for (var workshop in workshops) {
        debugPrint('Workshop ID: ${workshop.id}, Title: ${workshop.titre}');
      }

      final course = workshops.firstWhere(
        (course) {
          final match = course.id == widget.courseId;
          debugPrint('Checking ${course.id} == ${widget.courseId}: $match');
          return match;
        },
        orElse: () => throw Exception(
            'Course with ID ${widget.courseId} not found in ${workshops.length} workshops'),
      );

      debugPrint('Found course: ${course.titre}');
      return course;
    } catch (e) {
      debugPrint('Error fetching course: $e');
      throw Exception('Failed to load course: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              IconlyLight.arrow_left,
              size: 26,
              color: Colors.black,
            ),
            style: IconButton.styleFrom(
                shape: CircleBorder(), backgroundColor: Colors.white),
          ),
        ),
        title: const Text(
          "Course Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: FutureBuilder<Cours>(
              future: _courseFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return IconButton(
                    onPressed: () {},
                    icon: (snapshot.data!.bookmarked)
                        ? const Icon(
                            IconlyBold.heart,
                            size: 26,
                            color: Colors.black,
                          )
                        : const Icon(
                            IconlyLight.heart,
                            size: 26,
                            color: Colors.black,
                          ),
                  );
                }
                return const SizedBox();
              },
            ),
          )
        ],
      ),
      body: FutureBuilder<Cours>(
        future: _courseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No course data available'));
          }

          final selectedCourse = snapshot.data!;

          return ListView(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _courseImage(selectedCourse),
                    Text(
                      selectedCourse.titre,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(IconlyLight.time_circle,
                            size: 19, color: Colors.grey[400]),
                        const SizedBox(width: 5),
                        Text(selectedCourse.workshopDuration,
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        const SizedBox(width: 5),
                        const Text('  •  '),
                        Text('${selectedCourse.lessons.length} lessons',
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        const SizedBox(width: 5),
                        const Text('  •  '),
                        Text(selectedCourse.rating,
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        const SizedBox(width: 5),
                        Icon(IconlyBold.star,
                            size: 15, color: Colors.yellow[800]),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Sommaire',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    const SizedBox(height: 5),
                    Text(
                      selectedCourse.description,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 17),
                    CustomProgressBar(
                      completedLessons: 3,
                      totalLessons: selectedCourse.lessons.length,
                    ),
                    const SizedBox(height: 17),
                    Text('Leçons',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    const SizedBox(height: 5),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 10,
                      ),
                      itemCount: selectedCourse.lessons.length,
                      itemBuilder: (BuildContext context, int index) {
                        final lesson = selectedCourse.lessons[index];
                        return Container(
                          decoration: ShapeDecoration(
                              shadows: [
                                BoxShadow(
                                    color: Colors.grey.shade100,
                                    blurStyle: BlurStyle.outer)
                              ],
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LessonDetailPage(
                                    lessonTitle: lesson.titre,
                                    lessonDuration: lesson.lessonDuration,
                                  ),
                                ),
                              );
                            },
                            leading: Icon(
                              IconlyLight.play,
                              size: 50,
                              color: Colors.grey,
                            ),
                            title: Text(
                              lesson.titre,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15),
                            ),
                            subtitle: Row(
                              children: [
                                const Icon(
                                  IconlyLight.time_circle,
                                  size: 16,
                                  color: Colors.pink,
                                ),
                                const SizedBox(width: 3),
                                Text(lesson.lessonDuration)
                              ],
                            ),
                            trailing: Icon(
                              IconlyLight.lock,
                              size: 30,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 17),
                    Text('Exercice',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    const SizedBox(height: 5),
                    if (selectedCourse.exercice.titre.isNotEmpty)
                      Container(
                        decoration: ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                  color: Colors.grey.shade100,
                                  blurStyle: BlurStyle.outer)
                            ],
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: ListTile(
                          onTap: () {},
                          leading: Icon(
                            Icons.question_mark_rounded,
                            size: 50,
                            color: Colors.grey,
                          ),
                          title: Text(
                            selectedCourse.exercice.titre,
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                        ),
                      ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _courseImage(Cours course) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 8, right: 5),
      constraints:
          const BoxConstraints.expand(height: 230, width: double.infinity),
      padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          image: DecorationImage(
              image: AssetImage(course.imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.2), BlendMode.colorBurn))),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.6),
            radius: 50,
          ),
          Icon(
            IconlyBold.play,
            color: Colors.red,
            size: 90,
          )
        ],
      ),
    );
  }
}
