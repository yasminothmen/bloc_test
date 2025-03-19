// import 'package:bloc_test/data/models/user_profile.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'profile_event.dart';
// import 'profile_state.dart';

// class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
//   ProfileBloc() : super(ProfileInitial()) {
//     on<LoadProfile>((event, emit) async {
//       try {
//         // Simulate fetching user data (replace with API call)
//         await Future.delayed(const Duration(seconds: 1));
//         var user = user_profile(
//           name: "Louiza Jones", imagePath: '', email: '', about: '', isDarkMode: null,
//           // : "assets/images/louiza jones.jpeg", // Replace with actual image URL
//         );
//         emit(ProfileLoaded(user));
//       } catch (e) {
//         emit(ProfileError("Failed to load profile"));
//       }
//     });

//     // on<Logout>((event, emit) {
//     //   // Handle logout logic here (e.g., clear session, navigate to login screen)
//     //   emit(ProfileInitial());
//     // });
//   }
// }
