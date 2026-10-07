import '../models/gym_details.dart';
import '../models/home_page_data.dart';

abstract interface class FitnessRepository {
  Future<HomePageData> fetchHomePage();

  Future<GymDetails> fetchGymDetails();
}
