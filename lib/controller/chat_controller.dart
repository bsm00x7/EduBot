import 'package:flutter/cupertino.dart';

class ChatController with ChangeNotifier{


  bool isloading = false;
  static const String apikey = 'AIzaSyAPw_uTorkc1PLIbAwiKOjK_yUK8UjXRWo';
  TextEditingController controller = TextEditingController();
  static const String _apiKey = String.fromEnvironment('API_KEY', defaultValue: apikey);


   Future<void>  sendRequest() async{
  isloading = true;
  try{

  }catch (e){
    debugPrint(e.toString());
  }



  notifyListeners();
  }
}